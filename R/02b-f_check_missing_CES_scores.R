# # Summarize number of missing computed HOLC polygon CalEnviroScreen (CES) 
# # scores, by CES measure, HOLC grade, and HOLC city
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

f_check_missing_CES_scores <- function(df_holc_ces_scores_calculations) {

    # summarize missing scores ------------------------------------------------

    ## get missing scores (across all CES measures) ----
    df_missing <- df_holc_ces_scores_calculations %>%
        filter(is.na(weighted_score_total_adjusted))

    ## number and % missing by CES measure (across all HOLC cities / grades)
    df_missing_measures <- df_missing %>%
        count(ces_measure, name = 'n_missing') %>%
        left_join(df_holc_ces_scores_calculations %>%
                      count(ces_measure,
                            name = 'n_total')) %>%
        mutate(pct_missing = percent(n_missing / n_total))

    ## number and % missing by HOLC grade (for each CES measure)
    df_missing_measures_grades <- df_missing %>%
        count(ces_measure, holc_grade,
              name = 'n_missing') %>%
        left_join(df_holc_ces_scores_calculations %>%
                      count(ces_measure, holc_grade,
                            name = 'n_total')) %>%
        mutate(pct_missing = percent(n_missing / n_total)) %>%
        arrange(ces_measure)

    ## number and % missing by HOLC city (for each CES measure)
    df_missing_measures_cities <- df_missing %>%
        count(ces_measure, holc_city, name = 'n_missing') %>%
        left_join(df_holc_ces_scores_calculations %>%
                      count(ces_measure, holc_city,
                            name = 'n_total')) %>%
        mutate(pct_missing = percent(n_missing / n_total))

    ## just one CES measure
    df_missing_single_measure <- df_missing %>%
        filter(ces_measure == 'linguistic_isolation_score') %>%  # 'calenviroscreen_4_0_score' 'linguistic_isolation_score' 'unemployment_score'
        count(holc_city, holc_grade, ces_measure,
              # holc_coverage_total, holc_id_unique
        )
    
    ## number and % missing by HOLC city, HOLC grade, and  CES measure
    df_missing_measures_cities_grades <- df_missing %>%
        count(ces_measure, holc_city, holc_grade, 
              name = 'n_missing') %>%
        left_join(df_holc_ces_scores_calculations %>%
                      count(ces_measure, holc_city, holc_grade,
                            name = 'n_total')) %>%
        mutate(pct_missing = percent(n_missing / n_total)) %>% 
        arrange(ces_measure)
    
    return(df_missing_measures_cities_grades)

}
