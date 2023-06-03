# # Compute race/ethnicity demographics for each HOLC polygon, from the demographic 
# # data included in the CalEnviroScreen (CES) dataset (CES 4.0 demographic data 
# # comes from the 2015-2019 ACS)
# #
# # for CES 4.0 info, see: https://oehha.ca.gov/calenviroscreen/report/calenviroscreen-40
# # for HOLC polygons (redline maps), see: https://dsl.richmond.edu/panorama/redlining/#text=downloads
# #
# # NOTE: this includes both race/ethnicity and age group demographics - need to 
# # be careful with the calculations since that means that the population is 
# # essentially double counted in the data (i.e., every person is included in 
# # both an age category and a race/ethnicity category) - this is accounted for 
# # by adding the 'demographic_type' field into the dataset (which can be either 
# # 'age' or 'race')
# 
# # packages ----
# library(tidyverse)
# library(sf)
# library(here)
# library(units)
# library(scales)
# 
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)

# create function ----
f_compute_HOLC_demographics <- function(sf_formatted_ces_data, 
                                        sf_formatted_holc_data, 
                                        projected_crs = 3310) {
    # analyze - clip CES polygons ---------------------------------------------
    
    ## get total area of full CES polygons ----
    sf_formatted_ces_data <- sf_formatted_ces_data %>% 
        mutate(ces_area_total = st_area(.))
    
    ## calculate CES populations for each demographic group ----
    ### see: https://www.njtierney.com/post/2022/08/08/fun-across/
    # sf_formatted_ces_data <- sf_formatted_ces_data %>%
    #     mutate(
    #         across(
    #             .cols = ends_with('_percent'),
    #             .fns = ~ .x * total_population_2019_acs,
    #             .names = "{str_replace(.col, '_percent', '_pop_ces_total')}"
    #         ))
    
    ## clip CES polygons by HOLC polygons ----
    ### this clips the CES polygons to the area contained within the redline polygons,
    ### and gives the CES component polygons used to calculate the populations for 
    ## HOLC polygons 
    ces_data_clipped <- sf_formatted_ces_data %>% 
        st_intersection(sf_formatted_holc_data) %>% 
        mutate(ces_area_clipped = st_area(.), 
               .after = 'ces_area_total') # add area of each clipped polygon
    
    ## (for reference) number of clipped polygons with missing demographics ---- 
    missing_dem_values <- map_dbl(.x = ces_data_clipped %>%
                                      st_drop_geometry() %>%
                                      select(ends_with(c('_percent'))),
                                  .f = ~ sum(is.na(.x)))
    ### NOTE: all of these clipped CES polygons with missing values are 
    ### a part of CES polygons with zero population, see:
    missing_zero_ces_pop <- sum(ces_data_clipped$total_population_2019_acs == 0)
    
    
    
    # analyze - population of clipped CES polygons ----------------------------
    
    ## compute total population within each clipped CES polygon ----
    ces_data_clipped <- ces_data_clipped %>% 
        mutate(ces_population_clipped = 
                   total_population_2019_acs * 
                   drop_units(ces_area_clipped / ces_area_total))
    
    ## (for reference) number of clipped CES polygons in each HOLC polygon  ----
    ces_data_clipped <- ces_data_clipped %>%
        group_by(holc_id_unique) %>%
        mutate(n_ces_components_in_holc = n()) %>%
        ungroup()
    
    ## pivot long ----
    ### each row represents a clipped census tract (i.e., clipped CES polygon) and 
    ### a racial ethnic group's percentage of the total population in the CES polygon
    df_ces_clipped_demographics_long <- ces_data_clipped %>% 
        st_drop_geometry() %>% 
        select(census_tract_2010, total_population_2019_acs,
               holc_id:holc_id_unique,
               n_ces_components_in_holc,           
               ces_area_clipped, ces_area_total,
               ces_population_clipped, 
               ends_with(c('_percent'))) %>% 
        pivot_longer(cols = ends_with(c('_percent')), 
                     names_to = 'demographic_group', 
                     names_pattern = '(.*)_percent', 
                     values_to = 'demographic_percent_ces') # %>% 
    # arrange(holc_id_unique, demographic_group)
    
    ## add a variable to distinguish race/ethnicity variables from age variables ----
    df_ces_clipped_demographics_long <- df_ces_clipped_demographics_long %>% 
        mutate(demographic_type = if_else(
            demographic_group %in% 
                c('children_10_years', 'pop_10_64_years', 'elderly_64_years'),
            'age',
            'race'))
    
    ## compute population of each demographic group in each clipped CES polygon ----
    df_ces_clipped_demographics_long <- df_ces_clipped_demographics_long %>%
        mutate(demographic_population_ces_clipped = 
                   ifelse(ces_population_clipped == 0,
                          0,
                          ces_population_clipped * demographic_percent_ces
                   )
        )
    
    
    
    # analyze - summarize population by HOLC polygon --------------------------
    
    ## compute total population within each HOLC polygon ----
    df_ces_clipped_demographics_long <- df_ces_clipped_demographics_long %>%
        group_by(holc_id_unique, demographic_group) %>%
        mutate(population_holc_total = sum(ces_population_clipped)) %>%
        ungroup()
    
    ## compute total population of each demographic group in each HOLC polygon ----
    df_ces_clipped_demographics_long <- df_ces_clipped_demographics_long %>%
        group_by(holc_id_unique, demographic_group, demographic_type) %>%
        mutate(demographic_population_holc_total = sum(demographic_population_ces_clipped)) %>%
        ungroup()
    
    ## compute percent of each demographic group in each HOLC polygon
    df_ces_clipped_demographics_long <- df_ces_clipped_demographics_long %>%
        mutate(demographic_percent_holc = demographic_population_holc_total / population_holc_total)
    
    
    
    # summarize - created nested data frame -----------------------------------
    
    ## nest ----
    df_summarize_demographics_nest <- df_ces_clipped_demographics_long %>% 
        nest(.by = c(holc_id_unique, holc_city, holc_grade, holc_id,
                     demographic_group, demographic_type,
                     n_ces_components_in_holc,
                     demographic_population_holc_total,
                     population_holc_total, 
                     demographic_percent_holc
        ))
    
    ## summarize / investigate data ----
    ## pull the data back out of the nested data frame to view the calculation for 
    ## one HOLC polygon / demographic group
    # df_summarize_demographics_nest %>%
    #     f_get_detailed_demographic_data(ethnic_group = 'hispanic',
    #                                     holc = 'Fresno_A1') %>%
    #     View()
    
    # df_summarize_demographics_nest %>% 
    #     filter(demographic_group == 'asian_american', 
    #            holc_id_unique == 'Fresno_A1') %>% 
    #     unnest(cols = c(data)) %>% 
    #     select(census_tract_2010, holc_id_unique:holc_id,
    #            demographic_group, demographic_type,
    #            total_population_2019_acs,
    #            demographic_percent_ces,
    #            ces_area_total, ces_area_clipped, 
    #            ces_population_clipped,
    #            demographic_population_ces_clipped,
    #            demographic_population_holc_total,
    #            population_holc_total,
    #            demographic_percent_holc
    #     ) %>%
    #     View()
    
    ## return nested data ----
    return(df_summarize_demographics_nest)
    
}
