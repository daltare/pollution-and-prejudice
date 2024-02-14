# # Make faceted scatter plot with points showing computed CES score for each 
# # HOLC neighborhood (faceted by HOLC grade), with scores computed using the 
# # area weighted average method on the x-axis, and scores computed using the 
# # nearest centroid method on the y-axis. 
# 
# # packages -----------------------------------------------------------
# library(tidyverse)
# library(here)
# library(sf)
# library(scales)
# library(glue)
# 
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)

f_plot_scores_method_comparison_scatter_facet <- function(df_holc_ces_scores_comparison,
                                                          ces_measure_id = 'calenviroscreen_4_0_score',
                                                          ces_measure_title = 'CES 4.0 Score',
                                                          output_directory,
                                                          output_file_name) {
    
    ## filter ----
    df_holc_ces_scores_comparison <- df_holc_ces_scores_comparison %>% 
        filter(ces_measure == ces_measure_id)
    
    ## make plot ----
    method_comarison_scatter_facet <- ggplot(data = df_holc_ces_scores_comparison,
                                       mapping = aes(x = weighted_average_score,
                                                     y = nearest_centroid_score)) +
        geom_point(aes(color = holc_grade)) +
        geom_smooth(method = 'lm') +
        scale_color_manual(values = alpha(c('green', 'blue', 'yellow', 'red'), 0.5),
                           name = 'HOLC Grade',
                           labels = c('A (Best)', 'B (Desirable)', 'C (Declining)', 'D (Hazardous)')) +
        geom_abline(slope = 1, 
                    linetype = 'dashed') +
        # xlim(c(0,100)) +
        # ylim(c(0,100)) + 
        labs(x = glue('Area Weighted Average {str_replace(ces_measure_title, "CalEnviroScreen", "CES")} (Increasing Disadvantage \u2192)'),
             y = glue('Nearest Centroid {str_replace(ces_measure_title, "CalEnviroScreen", "CES")} (Increasing Disadvantage \u2192)'),
             title = glue('Comparison of Methods for Estimating {ces_measure_title}'), # for Neighborhoods in California\'s HOLC Maps'),
             subtitle = glue('Each point represents a neighborhood in the 1930s HOLC maps'),
             caption = glue('HOLC = Home Owners\' Loan Corporation
                        CES = CalEnviroScreen')#'Higher {str_replace(ces_measure_title, "Score", "score")}s indicate greater pollution burden and/or population vulnerability
             
        ) +
        facet_wrap(~ holc_grade) +
        coord_fixed() +
        theme_minimal() +
        NULL
    
    
    ## save plot ----
    ggsave(filename = here(output_directory, 
                           glue('{output_file_name}.png')), 
           plot = method_comarison_scatter_facet, 
           # bg = 'transparent',
           bg = 'white',
           scale = 1.0, #1.5 # increasing scale reduces relative size of text
           width = 6, 
           height = 6, 
           dpi = 300)
    
    ggsave(filename = here(output_directory, 
                           glue('{output_file_name}_transparent.png')), 
           plot = method_comarison_scatter_facet, 
           bg = 'transparent',
           # bg = 'white',
           scale = 1.0, # 1.5 # increasing scale reduces relative size of text
           width = 6, 
           height = 6, 
           dpi = 300)
    
    return(method_comarison_scatter_facet)
    
}
