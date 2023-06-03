# # Make plot with points showing average computed CES score by HOLC grade and 
# # city, along with overall average score for each city
# #
# # NOTE: plot any CES measure by changing the 'ces_measure_id' variable (and the 
# # associated 'ces_measure_title' variable) - may need to adjust some other 
# # plotting parameters when doing this
# # 
# # y-axis is grouped by city, x-axis is CES score (averages), and each point is 
# # colored by its HOLC grade
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

# create function ----
f_plot_scores_points_average_by_grade <- function(sf_combined_results, 
                                                  ces_measure_id = 'calenviroscreen_4_0_score',
                                                  ces_measure_title = 'CalEnviroScreen 4.0 Score',
                                                  output_directory,
                                                  output_file_name) {
    
    ## make sure the output directory exists ----------------------------------
    if (!dir.exists(here(output_directory))) {
        dir.create(here(output_directory),
                   recursive = TRUE)
    }
    
    
    # format data -------------------------------------------------------------
    df_scores_plot_summary <- sf_combined_results %>%
        st_drop_geometry() %>% 
        # select needed columns
        select(holc_id_unique:holc_id, ends_with('_score')) %>% 
        # pivot to long format
        pivot_longer(cols = ends_with('_score'),
                     names_to = 'ces_measure', 
                     # names_pattern = '(.*)_score', 
                     values_to = 'ces_score') %>% 
        # compute city average scores
        group_by(holc_city, ces_measure) %>%
        mutate(city_average_score = mean(ces_score, na.rm = TRUE)) %>%
        ungroup() %>%
        # compute city / HOLC grade average scores
        group_by(holc_city, ces_measure, holc_grade) %>%
        summarize(city_average_score = mean(city_average_score),
                  city_grade_average_score = mean(ces_score, na.rm = TRUE)) %>%
        ungroup() %>%
        # fix city names (add spaces in names with two words)
        mutate(holc_city = str_replace_all(holc_city, 
                                           '([a-z])([A-Z])', 
                                           '\\1 \\2')) %>% 
        # annotate HOLC grade names
        mutate(holc_grade = case_when(holc_grade == 'A' ~ 'A (Best)', 
                                      holc_grade == 'B' ~ 'B (Desirable)', 
                                      holc_grade == 'C' ~ 'C (Declining)', 
                                      holc_grade == 'D' ~ 'D (Hazardous)')) %>%  
        # convert fields to factor
        mutate(holc_grade = as.factor(holc_grade),
               ces_measure = as.factor(ces_measure))
    
    
    
    # make plot ---------------------------------------------------------------
    
    ## make plot ----
    plot_scores_point_average_city <- df_scores_plot_summary %>% 
        filter(ces_measure == ces_measure_id) %>% 
        # arrange to get correct ordering of cities (use fct_inorder below to apply ordering)
        arrange(city_average_score) %>% 
        ggplot(mapping = aes(x = city_grade_average_score, 
                             y = fct_inorder(holc_city))) +
        geom_point(mapping = aes(color = holc_grade), 
                   size = 3.0, 
                   alpha = 0.7) +
        scale_color_manual(values = alpha(c('green', 'blue', 'orange', 'red'), 1.0),
                           name = 'HOLC Grade') +
        geom_point(mapping = aes(x = city_average_score,
                                 shape = 'City Average Score'),
                   color = 'black',
                   size = 4.5,
                   alpha = 1,
                   stroke = 3) +
        scale_shape_manual('', 
                           values = c('City Average Score' = 124), 
                           guide = guide_legend(order = 1)) +
        scale_x_continuous(breaks = seq(0, 100, 20), limits = c(0, 90)) +
        theme(legend.position = 'right') +
        labs(x = glue('Average {ces_measure_title} (Increasing Disadvantage \u2192)'),
             y = 'City',
             # title = glue('Average {ces_measure_title} by City and HOLC Grade for Neighborhoods in California Cities Assessed by the HOLC in the 1930s'),
             title = glue('Average {ces_measure_title} by HOLC Grade for Neighborhoods California\'s HOLC Maps'),
             # subtitle = glue('Black lines represent the average {ces_measure_title} for all neighborhoods assessed by the HOLC in that city'),
             subtitle = glue('Each point represents the average score for neighborhoods with the same grade in the 1930s HOLC maps'),
             caption = glue('HOLC = Home Owners\' Loan Corporation
                            CES = CalEnviroScreen') #'Higher {str_replace(ces_measure_title, "Score", "score")}s indicate greater pollution burden and/or population vulnerability
        ) +
        theme_minimal() +
        NULL
    
    
    
    ## save plot ----
    ggsave(filename = here(output_directory, 
                           glue('{output_file_name}.png')), 
           plot = plot_scores_point_average_city, 
           # bg = 'transparent',
           bg = 'white',
           scale = 1.0, # 1.5 increasing scale reduces relative size of text
           width = 10, 
           height = 4.5, 
           dpi = 300)
    
    ggsave(filename = here(output_directory, 
                           glue('{output_file_name}_transparent.png')), 
           plot = plot_scores_point_average_city, 
           bg = 'transparent',
           # bg = 'white',
           scale = 1.0, # 1.5 # increasing scale reduces relative size of text
           width = 10, 
           height = 4.5, 
           dpi = 300)
    
    ## return plot ----
    return(plot_scores_point_average_city)
    
}
