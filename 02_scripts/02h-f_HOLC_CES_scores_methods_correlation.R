# # Perform a spearman test to look at correlations between the HOLC 
# # neighborhood CES scores calculated with the area weighted average method 
# # and scores calculated with the centroid method.
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

f_HOLC_CES_score_methods_correlation <- function(df_holc_ces_scores_comparison) {
    
    correlation_spearman_test <- cor.test(
        x = df_holc_ces_scores_comparison$weighted_average_score,
        y = df_holc_ces_scores_comparison$nearest_centroid_score,
        method = 'spearman')
    
    correlation_spearman_test
    # p-value < 0.00000000000000022
    # rho: 0.9663347
}