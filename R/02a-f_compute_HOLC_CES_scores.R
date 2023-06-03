# # Compute weighted average CalEnviroScreen (CES) scores for each HOLC polygon 
# # (for all CES measures)
# #
# # for CES 4.0 info, see: https://oehha.ca.gov/calenviroscreen/report/calenviroscreen-40
# # for HOLC polygons (redline maps), see: https://dsl.richmond.edu/panorama/redlining/#text=downloads
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

f_compute_HOLC_CES_scores <- function(sf_formatted_ces_data, 
                                      sf_formatted_holc_data, 
                                      ces_coverage_threshold, 
                                      projected_crs = 3310) {
    
    # analyze - clip CES polygons ---------------------------------------------
    
    ## get area of redline polygons ----
    sf_formatted_holc_data <- sf_formatted_holc_data %>% 
        mutate(holc_area = st_area(.))
    
    ## get total area of full CES polygons ----
    sf_formatted_ces_data <- sf_formatted_ces_data %>% 
        mutate(ces_area_total = st_area(.))
    
    ## clip CES polygons by HOLC polygons ----
    ### this clips the CES polygons to the area contained within the redline polygons,
    ### and gives the CES component polygons used to calculate the weighted average 
    ## scores for HOLC polygons 
    ces_data_clipped <- sf_formatted_ces_data %>% 
        st_intersection(sf_formatted_holc_data) %>% 
        mutate(ces_area_clipped = st_area(.), 
               .after = 'ces_area_total') # add area of each clipped polygon
    
    ## (for reference) number of clipped CES polygons in each HOLC polygon  ----
    ces_data_clipped <- ces_data_clipped %>%
        group_by(holc_id_unique) %>%
        mutate(n_ces_components_in_holc = n()) %>%
        ungroup()
    
    ## (for reference) number of clipped polygons with missing scores ----
    missing_values <- map_dbl(.x = ces_data_clipped %>% 
                                  st_drop_geometry() %>% 
                                  select(ends_with(c('_score', 'score_scaled'))), 
                              .f = ~ sum(is.na(.x)))
    
    
    
    # analyze - compute weighted average scores -----------------------------------
    
    ## pivot long ----
    ### each row represents a clipped census tract and a score for a single CES measure
    df_ces_clipped_scores_long <- ces_data_clipped %>% 
        st_drop_geometry() %>% 
        select(census_tract_2010, 
               holc_id:holc_area, 
               n_ces_components_in_holc,
               ces_area_clipped, ces_area_total,
               ends_with(c('_score', 'score_scaled'))) %>% 
        pivot_longer(cols = ends_with(c('_score', 'score_scaled')), 
                     names_to = 'ces_measure',
                     values_to = 'ces_score') %>% 
        arrange(holc_id_unique, ces_measure) %>%
        relocate(ces_measure, ces_score, ces_area_clipped, ces_area_total,
                 holc_id_unique,
                 .after = census_tract_2010)
    
    ## (for reference) - number of NAs in each HOLC polygon for each CES measure ----
    df_ces_clipped_scores_long <- df_ces_clipped_scores_long %>%
        group_by(holc_id_unique, ces_measure) %>%
        mutate(n_na_components_in_holc = sum(is.na(ces_score))) %>% 
        ungroup()
    
    ## compute % of total HOLC polygon each clipped CES polygon covers ----
    df_ces_clipped_scores_long <- df_ces_clipped_scores_long %>%
        mutate(pct_of_holc = 
                   ifelse(is.na(ces_score),
                          NA,
                          drop_units(ces_area_clipped / holc_area)
                   )
        )
    
    ## compute weighted scores ----
    df_ces_clipped_scores_long <- df_ces_clipped_scores_long %>%
        mutate(weighted_score = pct_of_holc * ces_score)
    
    ## compute sum of weighted scores for each HOLC polygon & CES measure ----
    df_ces_clipped_scores_long <- df_ces_clipped_scores_long %>%
        group_by(holc_id_unique, ces_measure) %>%
        mutate(weighted_score_total = sum(weighted_score, 
                                          na.rm = TRUE)) %>% 
        ungroup()
    
    ## compute % of each HOLC polygon covered by CES tracts w/ scores for each metric ----
    ## (this acts as an adjustment factor)
    df_ces_clipped_scores_long <- df_ces_clipped_scores_long %>%
        group_by(holc_id_unique, ces_measure) %>%
        mutate(holc_coverage_total = sum(pct_of_holc, 
                                         na.rm = TRUE)) %>% 
        ungroup()
    
    ## compute adjusted weighted score totals ----
    ### (apply the adjustment factor, to account for HOLC polygons not completely 
    ### covered by CES polygons with scores for the given CES measure, but only if 
    ### the coverage of the HOLC polygon is greater than the ces_coverage_threshold -
    ### otherwise, assume we can't calculate a score for the HOLC polygon for that
    ### CES measure)
    df_ces_clipped_scores_long <- df_ces_clipped_scores_long %>%
        mutate(weighted_score_total_adjusted = if_else(
            holc_coverage_total < ces_coverage_threshold,
            NA,
            weighted_score_total / holc_coverage_total
        ))
    
    
    
    # summarize - created nested data frame -----------------------------------
    
    ## nest ----
    df_summarize_scores_nest <- df_ces_clipped_scores_long %>% 
        nest(.by = c(holc_id_unique, holc_city, holc_grade, holc_id,
                     ces_measure, 
                     n_ces_components_in_holc, n_na_components_in_holc,
                     weighted_score_total,
                     holc_coverage_total, weighted_score_total_adjusted
        ))
    
    ## summarize / investigate data ----
    # ## pull the data back out of the nested data frame to view the calculation for 
    # ## one HOLC polygon / CES measure
    # df_summarize_scores_nest %>% 
    #     filter(ces_measure == 'calenviroscreen_4_0_score', 
    #            holc_id_unique == 'Fresno_A1') %>% 
    #     unnest(cols = c(data)) %>% 
    #     # select(-n_na_components_in_holc, -n_ces_components_in_holc) %>% 
    #     select(census_tract_2010, holc_id_unique:holc_id,
    #            ces_measure, ces_score, ces_area_total,
    #            ces_area_clipped, holc_area, 
    #            pct_of_holc, weighted_score, holc_coverage_total, 
    #            weighted_score_total_adjusted) %>%
    #     # relocate(ces_measure, census_tract_2010) %>% 
    #     View()
    
    ## return nested data ----
    return(df_summarize_scores_nest)
    
}
