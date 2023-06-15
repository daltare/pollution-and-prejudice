# # Compute CalEnviroScreen (CES) scores for each HOLC neighborhood, using a 
# # nearest centroid approach. 
# # 
# # This is just for comparison with the area weighted average approach - it is 
# # not necessarily intended for any other use.
# # 
# # This nearest centroid approach finds the CES census tract (excluding tracts
# # without CES scores) whose centriod is closest to the 
# # centroid of each HOLC neighborhood, and assigns the CES score of the matched 
# # census tract to that HOLC neighborhood. There are 103 tracts with missing 
# # overall CES scores which are excluded (and varying numbers of tracts with 
# # missing scores for individual indicators - this includes 23 tracts with zero 
# # population).
# # 
# # This is done to test the sensitivity of the results to the different
# # approaches used to estimate CES scores for each HOLC neighborhood. If they
# # are substantially the same, that gives us greater confidence in our
# # estimated CES scores (because they are not sensitive to different calculation
# # methods - i.e., they are robust, and would likely be similar regardless of
# # the way we estimate them, given the underlying spatial patterns).
# #
# # For CES 4.0 info, see: 
# # https://oehha.ca.gov/calenviroscreen/report/calenviroscreen-40
# # 
# # For HOLC neighborhoods (redline maps), see: 
# # https://dsl.richmond.edu/panorama/redlining/#text=downloads
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

f_compute_HOLC_CES_scores_centroids <- function(sf_formatted_ces_data, 
                                                sf_formatted_holc_data, 
                                                ces_measure_id = 'calenviroscreen_4_0_score',
                                                output_file_name,
                                                output_directory, 
                                                projected_crs = 3310) {
    
    ## make sure projections are consistent ----
    sf_formatted_holc_data <- sf_formatted_holc_data %>% 
        st_transform(projected_crs)
    
    sf_formatted_ces_data <- sf_formatted_ces_data %>% 
        st_transform(projected_crs)
    
    ## exclude CES tracts with missing scores ----
    sf_formatted_ces_data <- sf_formatted_ces_data %>% 
        filter(!is.na(get(ces_measure_id)))
    
    ## compute centroids of HOLC neighborhoods ----
    sf_holc_centroids <- sf_formatted_holc_data %>% 
        st_centroid(.)
    
    ## compute centroids of CES tracts ----
    sf_ces_centroids <- sf_formatted_ces_data %>% 
        st_centroid(.)
    
    ## connect centroid of each HOLC polygon to nearest centroid of a CES tract ----
    ## this returns a vector of row numbers corresponding to matching CES tracts
    holc_nearest_centroid <- sf_holc_centroids %>% 
        st_nearest_feature(sf_ces_centroids)
    
    ## get CES tract that matches each HOLC neighborhhod ----
    sf_holc_centroid_scores <- sf_formatted_holc_data %>% 
        bind_cols(sf_formatted_ces_data %>% 
                      slice(holc_nearest_centroid) %>% 
                      select(census_tract_2010, all_of(ces_measure_id)) %>% 
                      st_drop_geometry()
        ) %>% 
        mutate(ces_measure = ces_measure_id) %>% 
        rename('ces_score' = all_of(ces_measure_id),
               ces_census_tract_2010 = census_tract_2010) %>% 
        # rearrange
        relocate(ces_measure, ces_score, ces_census_tract_2010, starts_with('geom'),
                 .after = last_col())
    
    ## write to file
    st_write(obj = sf_holc_centroid_scores,
             here(output_directory,
                  output_file_name),
             append = FALSE)
    
    
    # # get lines connecting HOLC neighborhoods to their matched CES tracts
    # # draw lines
    # connecting_lines <- st_nearest_points(sf_holc_centroids, 
    #                                       sf_ces_centroids %>% 
    #                                           slice(holc_nearest_centroid), 
    #                                       pairwise = TRUE)
    # # write to output file
    # st_write(obj = connecting_lines,
    #          here(output_directory,
    #               'holc_ces_centroid_connecting_lines.gpkg'),
    #          append = FALSE)
    
    
    ## return results ----
    return(sf_holc_centroid_scores)
    
}