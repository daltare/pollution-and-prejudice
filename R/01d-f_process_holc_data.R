# # Process HOLC data (i.e., the 1930s redline maps) to prepare for use in the
# # redline mapping analysis (and potentially other analyses) -
# # for HOLC data (redline maps), see: https://dsl.richmond.edu/panorama/redlining/#text=downloads
# 
# # packages ----
# library(tidyverse)
# library(sf)
# library(here)
# library(tools)
# 
# # ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)

# create function ----

f_process_holc_data <- function(raw_holc_data_files, 
                                output_file_name, 
                                output_directory,
                                projected_crs = 3310) {
    
    # make sure the output directory exists ----
    if (!dir.exists(here(output_directory))) {
        dir.create(here(output_directory),
                   recursive = TRUE)
    }
    
    
    
    # unzip raw data to temporary directory & read into R ----------------------
    
    ## create temp directory
    temp_dir <- tempdir()
    
    ## loop through files, unzip, and read into combined data frame
    sf_redline_maps <- map2_df(.x = raw_holc_data_files$city,
                               .y = raw_holc_data_files$file_path,
                               .f = ~ {
                                   unzip(zipfile = .y,
                                         exdir = file.path(temp_dir, basename(.y)))
                                   st_read(file.path(temp_dir, basename(.y))) %>%
                                       mutate('holc_city' = .x)
                               }) %>%
        rename(holc_name = name)
    
    
    
    # process combined HOLC dataset --------------------------------------------
    
    ## fix self-intersecting polygons (if needed) ----
    sf_redline_maps <- sf_redline_maps %>% 
        st_transform(projected_crs)
    if (sum(!st_is_valid(sf_redline_maps)) > 0) {
        sf_redline_maps <- st_buffer(sf_redline_maps, 
                                     dist = 0)
    }
    
    ## assign arbitrary unique ID to records missing 'holc_id' (by city) ----
    sf_redline_maps <- sf_redline_maps %>% 
        mutate(holc_id_mod = case_when(
            is.na(holc_id) ~ 1,
            .default = 0)) %>% 
        group_by(holc_city, holc_grade) %>% 
        mutate(holc_id_mod = cumsum(holc_id_mod)) %>% 
        ungroup() %>% 
        mutate(holc_id_mod = case_when(
            is.na(holc_id) ~ paste0(holc_grade, 'noid', holc_id_mod),
            .default = holc_id)) %>% 
        mutate(holc_id = holc_id_mod) %>% 
        select(-holc_id_mod)
    
    ### make unique holc_id field (combine city and holc id) ----
    sf_redline_maps <- sf_redline_maps %>% 
        mutate(holc_id_unique = paste0(holc_city, '_', holc_id))
    #### check
    if (sum(duplicated(sf_redline_maps$holc_id_unique)) > 0) {
        stop('HOLC ID not unique')
    }
    
    
    
    # write processed HOLC data ------------------------------------------------
    
    ## save to geopackage file ----
    st_write(obj = sf_redline_maps, 
             here(output_directory,
                       glue('{output_file_name}.gpkg')),
             append = FALSE)  
    
    
    
    # return processed dataset ------------------------------------------------
    return(sf_redline_maps)
    
}

