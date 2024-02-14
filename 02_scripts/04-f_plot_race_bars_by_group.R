# # Make horizontal bar chart showing present-day distribution of each 
# # racial / ethnic group's population in HOLC polygons (y-axis shows racial 
# # group, x-axis shows percent of population, all bars add to 100%)
# # 
# # Demographic data comes from the data contained in CalEnviroScreen (CES) - 
# # CES 4.0 data is from 2019 5-year ACS (2015-2019)
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
f_plot_race_bars_by_group <- function(sf_combined_results, 
                                      output_directory,
                                      output_file_name) {
    
    ## make sure the output directory exists ----------------------------------
    if (!dir.exists(here(output_directory))) {
        dir.create(here(output_directory),
                   recursive = TRUE)
    }
    
    # format data -------------------------------------------------------------
    df_demographic_plot <- sf_combined_results %>%
        st_drop_geometry() %>% 
        # select needed columns
        select(holc_id_unique:holc_id, starts_with('population_race')) %>% 
        # pivot to long format
        pivot_longer(cols = starts_with('population_race'),
                     names_to = 'demographic_group', 
                     names_pattern = 'population_race_(.*)', 
                     values_to = 'demographic_population_holc_total') %>% 
        # compute total population for each HOLC grade and demographic group
        group_by(holc_grade, demographic_group) %>% 
        summarize(grade_group_total = sum(demographic_population_holc_total)) %>% 
        arrange(demographic_group) %>% 
        ungroup() %>%
        # compute total population for each demographic group (across all HOLC grades)
        group_by(demographic_group) %>% 
        mutate(group_total = sum(grade_group_total)) %>% 
        ungroup() %>% 
        # compute percent of each group's population that's in each HOLC grade
        mutate(grade_group_percent = grade_group_total/ group_total) %>% 
        # fix demographic group names (add spaces in names with multiple words, and
        # convert to title format)
        mutate(demographic_group = demographic_group %>% 
                   str_replace_all('other_multiple', 'Other / Multiple') %>% 
                   str_replace_all('_', ' ') %>% 
                   str_to_title()) %>% 
        # annotate HOLC grade names
        mutate(holc_grade = case_when(holc_grade == 'A' ~ 'A (Best)', 
                                      holc_grade == 'B' ~ 'B (Desirable)', 
                                      holc_grade == 'C' ~ 'C (Declining)', 
                                      holc_grade == 'D' ~ 'D (Hazardous)')) %>%  
        # convert fields to factor
        mutate(holc_grade = as.factor(holc_grade),
               demographic_group = as.factor(demographic_group))
    
    
    
    # make plot ---------------------------------------------------------------
    plot_race <- df_demographic_plot %>% 
        # arrange to get correct ordering of demographic groups (use fct_inorder below to apply ordering)
        arrange(holc_grade, grade_group_percent) %>% 
        ggplot() +
        geom_bar(mapping = aes(x = fct_inorder(demographic_group), 
                               y = grade_group_percent, 
                               fill = fct_rev(holc_grade)), 
                 stat = 'identity') + 
        scale_fill_manual(values = rev(alpha(c('green', 'blue', 'orange', 'red'), 
                                             1.0)),
                          name = 'HOLC Grade') +
        guides(fill = guide_legend(reverse = TRUE, title = 'HOLC Grade')) +
        scale_y_continuous(labels = scales::percent) + 
        labs(x = 'Racial / Ethnic Group',
             y = 'Percent of Population',
             title = 'Estimated Present-Day Distribution of Racial / Ethnic Groups in California\'s HOLC Neighborhoods', 
             # title = 'Present-Day Distribution of Racial / Ethnic Group Populations in Neighborhoods Assessed by the HOLC in the 1930s in California', 
             # subtitle = 'Present-Day Demographic Data from 2010 Census', 
             caption = glue('Demographic data from 2015-2019 American Community Survey (ACS)
                        HOLC = Home Owners\' Loan Corporation')) +
        coord_flip() + 
        theme_minimal() +
        # # code below adds labels
        # geom_text(mapping = aes(x = demographic_group,
        #                         y = grade_group_percent,
        #                         # label = format(x = value * 100,
        #                         #                digits = 1,
        #                         #                nsmall = 1)
        #                         label = percent(grade_group_percent, accuracy = 1)),
        #           size = 3,
        #           color = 'gray10',
        #           position = position_stack(vjust = 0.5)) +
        NULL
    
    
    
    ## save plot ----
    
    ggsave(filename = here(output_directory, 
                           glue('{output_file_name}.png')), 
           plot = plot_race, 
           # bg = 'transparent',
           bg = 'white',
           scale = 1.0, # 1.5 # increasing scale reduces relative size of text
           width = 10,
           height = 3, # original: 4.5
           dpi = 300)
    
    ggsave(filename = here(output_directory, 
                           glue('{output_file_name}_transparent.png')), 
           plot = plot_race, 
           bg = 'transparent',
           # bg = 'white',
           scale = 1.0, # 1.5 # increasing scale reduces relative size of text
           width = 10,
           height = 3, # original: 4.5
           dpi = 300)
    
    
    ## return plot ----
    return(plot_race)
    
}


