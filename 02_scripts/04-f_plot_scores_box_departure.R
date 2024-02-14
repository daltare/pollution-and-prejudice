# # Make horizontal box plot for each HOLC group showing distribution of 
# # differences between (1) computed CES score for each HOLC polygon versus (2) 
# # the average CES score for the city it's in (i.e. the 'score departure' from 
# # average)
# #
# # NOTE: plot any CES measure by changing the 'ces_measure_id' variable (and the 
# # associated 'ces_measure_title' variable) - may need to adjust some other 
# # plotting parameters when doing this
# # 
# # y-axis is grouped by HOLC grade, x-axis is CES score departure, and each 
# # box is colored by its HOLC grade
# 
# # NOTE: see this link for boxplot customization:
# # https://waterdata.usgs.gov/blog/boxplots/
# 
# # load packages -----------------------------------------------------------
# library(tidyverse)
# library(here)
# library(sf)
# library(scales)
# library(glue)
# library(cowplot)
# 
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)

# create function ----
f_plot_scores_box_departure <- function(sf_combined_results, 
                                        ces_measure_id = 'calenviroscreen_4_0_score',
                                        ces_measure_title = 'CalEnviroScreen 4.0 Score',
                                        output_directory,
                                        output_file_name) {
    
    # set.seed(1234) # for consistent jitter in geom_jitter()
    
    ## make sure the output directory exists ----------------------------------
    if (!dir.exists(here(output_directory))) {
        dir.create(here(output_directory),
                   recursive = TRUE)
    }
    
    # format data -------------------------------------------------------------
    df_scores_plot <- sf_combined_results %>%
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
        # compute departure score for each HOLC polgon (difference from city average score)
        mutate(score_departure = ces_score - city_average_score) %>% 
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
    
    
    
    # plot --------------------------------------------------------------------
    
    ## make plot ----
    plot_scores_box_departure_holcgrade <- df_scores_plot %>% 
        filter(ces_measure == ces_measure_id) %>% 
        filter(!is.na(ces_score)) %>% 
        ggplot(mapping = aes(x = fct_rev(holc_grade), 
                             y = score_departure)) +
        geom_boxplot(mapping = aes(fill = holc_grade), 
                     notch = FALSE, 
                     outlier.shape = NA) +
        scale_fill_manual(values = alpha(c('green', 'blue', 'yellow', 'red'),
                                         0.6),
                          name = 'HOLC Grade') +
        # stat_boxplot(geom ='errorbar', width = 0.2) +
        geom_jitter(aes(color = 'HOLC Neighborhood'), 
                    # color = 'black',
                    size = 1.2, # 0.6, 
                    alpha = 0.5, 
                    width = 0.2) +
        scale_color_manual(values = 'black',
                           name = NULL) +
        labs(
            x = 'HOLC Grade',
            # y = glue('Difference in {ces_measure_title} from City Average Score (Increasing Disadvantage \u2192)'),
            y = glue('{ces_measure_title} Departure (Increasing Disadvantage \u2192)'),
            # y = glue('{ces_measure_title} Relative to Respective City-Wide Average Score (Increasing Disadvantage \u2192)'),
            # title = glue('Difference in {ces_measure_title} from Respective City Average Score for Neighborhoods in California Cities Assessed by the HOLC in the 1930s'),
            title = glue('{ces_measure_title} Departure for Neighborhoods in California\'s HOLC Maps'),
            subtitle = glue('Each point represents a neighborhood in the 1930s HOLC maps'), 
            caption = glue('HOLC = Home Owners\' Loan Corporation
                           CES = CalEnviroScreen
                           Departure = difference from respective city-wide average score'# 'Higher {str_replace(ces_measure_title, "Score", "score")}s indicate greater pollution burden and/or population vulnerability
            )
        ) +    
        coord_flip() + # ylim = c(axis_min, axis_max)) +
        # NOTE: if not flipping the coordinates, use coord_cartesian(ylim = c(axis_min, axis_max))
        theme_minimal() +
        NULL
    
    
    ## save plot ----
    ggsave(filename = here(output_directory, 
                           glue('{output_file_name}.png')), 
           plot = plot_scores_box_departure_holcgrade, 
           # bg = 'transparent',
           bg = 'white',
           scale = 1.0, # 1.5 # increasing scale reduces relative size of text
           width = 10, 
           height = 4.5, 
           dpi = 300)
    
    ggsave(filename = here(output_directory, 
                           glue('{output_file_name}_transparent.png')), 
           plot = plot_scores_box_departure_holcgrade, 
           bg = 'transparent',
           # bg = 'white',
           scale = 1.0, # 1.5 # increasing scale reduces relative size of text
           width = 10, 
           height = 4.5, 
           dpi = 300)
    
    ## return plot ----
    return(plot_scores_box_departure_holcgrade)
    
}
