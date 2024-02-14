# # Create combined dataframe with estimated / calculated HOLC neighborhood CES
# # scores using two different methods (area weighted average and nearest
# # centroid). This will be used to look at correlations between the estimated 
# # HOLC neighborhood CES scores calculated with the different methods.
# #
# # This is done to test the sensitivity of the results to the different
# # approaches used to estimate CES scores for each HOLC neighborhood. If they
# # are substantially the same, that gives us greater confidence in our
# # estimated CES scores (because they are not sensitive to different calculation
# # methods - i.e., they are robust, and would likely be similar regardless of
# # the way we estimate them, given the underlying spatial patterns).
#
# # packages ----
# library(tidyverse)
# library(sf)
# library(here)
#
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)

# create function ----

f_combine_HOLC_CES_score_methods <- function(df_holc_ces_scores_calculations,
                                             sf_holc_ces_scores_centroids,
                                             ces_measure_id = 'calenviroscreen_4_0_score'
                                             ) {

    ## filter area weighted scores ----
    df_holc_ces_scores_calculations <- df_holc_ces_scores_calculations %>%
        select(holc_id_unique:ces_measure, weighted_score_total_adjusted) %>%
        filter(ces_measure == ces_measure_id) %>%
        # drop neighborhoods with missing score
        filter(!is.na(weighted_score_total_adjusted))

    ## filter centroid scores ----
    df_holc_ces_scores_centroids <- sf_holc_ces_scores_centroids %>% 
        st_drop_geometry() %>% 
        filter(ces_measure == ces_measure_id) %>%
        # drop neighborhoods with missing area weighted average score
        filter(holc_id_unique %in% df_holc_ces_scores_calculations$holc_id_unique)
    
    ## create combined dataframe for comparison ----
    df_holc_ces_scores_comparison <- df_holc_ces_scores_calculations %>% 
        rename(weighted_average_score = weighted_score_total_adjusted) %>% 
        # select(holc_id_unique, holc_city, holc_grade, holc_id,
        #        weighted_average_score = weighted_score_total_adjusted) %>% 
        left_join(df_holc_ces_scores_centroids %>% 
                      select(holc_id_unique, 
                             nearest_centroid_score = ces_score), 
                  by = 'holc_id_unique')
    
    return(df_holc_ces_scores_comparison)
    
}
