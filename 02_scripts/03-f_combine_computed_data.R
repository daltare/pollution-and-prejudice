# # Combine weighted average CES scores and demographic data for each HOLC polygon,
# # and save in a geospatial format (geopackage)
# 
# # packages ----
# library(tidyverse)
# library(here)
# library(sf)
# 
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)

# create function ----
f_combine_computed_data <- function(df_holc_ces_scores_summary, 
                                    df_holc_demographics_summary, 
                                    sf_formatted_holc_data,
                                    output_file_name,
                                    output_directory, 
                                    projected_crs = 3310) {
    
    ## make sure the output directory exists ----
    if (!dir.exists(here(output_directory))) {
        dir.create(here(output_directory),
                   recursive = TRUE)
    }
    
    ## join CES scores and demographics data ----
    df_combined_summary <- df_holc_ces_scores_summary %>% 
        left_join(df_holc_demographics_summary %>% select(-c(holc_city:holc_id)), 
                  by = 'holc_id_unique')
    
    ## add geometry ----
    sf_combined_summary <- df_combined_summary %>% 
        left_join(sf_formatted_holc_data %>% 
                      st_transform(projected_crs) %>% 
                      select(holc_id_unique, holc_year, holc_url, 
                             holc_area_description_excerpts,
                             starts_with('geom')),
                  by = 'holc_id_unique') %>% 
        relocate(holc_year, holc_url, 
                 holc_area_description_excerpts, .after = holc_id) %>% 
        st_as_sf()
    
    ## save to geopackage file ----
    st_write(sf_combined_summary, 
             here(output_directory, 
                  output_file_name),
             append = FALSE
    )
    
    ## return combined dataset ----
    return(sf_combined_summary)
    
}
