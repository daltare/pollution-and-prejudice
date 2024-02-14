# # Create wide data frame to summarize computed race/ethnicity demographics for 
# # each HOLC polygon, from the demographic data included in the CalEnviroScreen 
# # (CES) dataset (CES 4.0 demographic data comes from the 2015-2019 ACS)
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
# # packages -----
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
f_summarize_HOLC_demographics <- function(df_holc_demographics_calculations) {
    # summarize - created wide data frame -------------------------------------
    
    ## pivot wider (population numbers) ----
    df_summarize_demographics_wide <- df_holc_demographics_calculations %>% 
        select(holc_id_unique:demographic_type, 
               demographic_population_holc_total, 
               population_holc_total) %>% 
        # mutate(demographic_population_holc_total = round(demographic_population_holc_total, 2),
        #        population_holc_total = round(population_holc_total, 2)) %>%
        pivot_wider(names_from = c(demographic_type, demographic_group), 
                    values_from = demographic_population_holc_total,
                    names_prefix = 'population_') %>% 
        rename(population_age_10_64_years = population_age_pop_10_64_years)
    
    ## pivot wider (percentages) ----
    # df_summarize_demographics_pct_wide <- df_holc_demographics_calculations %>% 
    #     select(holc_id_unique:demographic_type, 
    #            demographic_percent_holc,
    #            population_holc_total) %>% 
    #     # mutate(demographic_percent_holc = round(demographic_percent_holc, 2),
    #     #        population_holc_total = round(population_holc_total, 2)) %>%
    #     pivot_wider(names_from = c(demographic_type, demographic_group), 
    #                 values_from = demographic_percent_holc,
    #                 names_prefix = 'percent_') %>% 
    #     rename(percent_age_10_64_years = percent_age_pop_10_64_years)
    
    
    ## return summarized data ----
    return(df_summarize_demographics_wide)

    # checks - missing & zero data --------------------------------------------
    
    ## check - NAs
    # df_summarize_demographics_wide %>%
    #     map_dbl(.f = ~ sum(is.na(.x)))
    
    ## check - zero
    # df_summarize_demographics_wide %>%
    #     select(where(is.numeric)) %>% 
    #     map_dbl(.f = ~ sum(.x == 0))
    
}