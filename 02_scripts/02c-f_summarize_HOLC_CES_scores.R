# # Create wide data frame to summarize computed HOLC polygon weighted average 
# # CalEnviroScreen (CES) scores (for all CES measures)
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

f_summarize_HOLC_CES_scores <- function(df_holc_ces_scores_calculations, 
                                        sf_formatted_ces_data) {
    
    # summarize (create wide data frame) ----
    
    ## pivot wider ----
    df_summarize_scores_wide <- df_holc_ces_scores_calculations %>% 
        select(holc_id_unique:ces_measure, 
               weighted_score_total_adjusted) %>% 
        pivot_wider(names_from = ces_measure, 
                    values_from = weighted_score_total_adjusted)
    
    ## reorder columns ----
    col_order <- names(sf_formatted_ces_data)[str_detect(names(sf_formatted_ces_data), pattern = 'score')]
    df_summarize_scores_wide <- df_summarize_scores_wide %>% 
        select(holc_id_unique:holc_id, all_of(col_order))
    
    ## check - NAs ----
    # df_summarize_scores_wide %>%
    #     select(ends_with(c('score', 'score_scaled'))) %>%
    #     map_dbl(.f = ~ sum(is.na(.x)))
    
    ## return summarized data ----
    return(df_summarize_scores_wide)
    
}
