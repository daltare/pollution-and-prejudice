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
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)

#' @title 
#' Process HOLC data
#' 
#' @description 
#' Function to Process HOLC data - i.e., 1930s redline maps - to prepare for use 
#' in the redline mapping analysis (and potentially other analyses). HOLC maps 
#' are available at: https://dsl.richmond.edu/panorama/redlining/#text=downloads

#' @param raw_holc_data_files Data frame with 4 columns: (1) holc_city = name of 
#' city; (2) holc_filename = format of the name of files for the given city 
#' from: 
#' https://dsl.richmond.edu/panorama/redlining/#text=downloads); (3) holc_year = 
#' year the HOLC maps and descriptions were produced; (4) file_path = 
#' absolute path to the location where the raw data for that city is saved 
#' locally.
#' 
#' @returns 
#' Returns a simple features data frame containing geospatial and attribute data
#' for all neighborhoods assessed by the HOLC in California, which includes data 
#' from eight different cities.  Each row represents a HOLC neighborhood. The 
#' processing steps include: fixing invalid spatial data, assigning a unique ID 
#' to each neighborhood, constructing a URL that links to an online version of 
#' data for each neighborhood, and adding text from the HOLC area description 
#' for each neighborhood.
#' 

# create function ----

f_process_holc_data <- function(raw_holc_data_files, 
                                holc_area_descriptions,
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
    # temp_dir <- tempdir()
    
    ## loop through files, unzip, and read into combined data frame
    ### shapefiles ----
    # sf_redline_maps <- pmap_df(.l = raw_holc_data_files,
    #                            .f = function(holc_city, holc_filename, 
    #                                          holc_year, file_path) {
    #                                unzip(zipfile = file_path,
    #                                      exdir = file.path(temp_dir, basename(file_path)))
    #                                st_read(file.path(temp_dir, basename(file_path))) %>%
    #                                    mutate('holc_city' = holc_city,
    #                                           'holc_year' = holc_year)
    #                            }) %>%
    #     rename(holc_name = name)
    
    ### geojson ----
    sf_redline_maps <- pmap_df(.l = raw_holc_data_files,
                               .f = function(holc_city, holc_filename, 
                                             holc_year, file_path) {
                                   geojson_sf(file_path) %>%
                                       select(-area_description_data) %>%
                                       mutate('holc_city' = holc_city,
                                              'holc_year' = holc_year)
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
            .default = holc_id)) #%>% 
        # mutate(holc_id = holc_id_mod) %>% 
        # select(-holc_id_mod)
    
    ### make unique holc_id field (combine city and holc id) ----
    sf_redline_maps <- sf_redline_maps %>% 
        mutate(holc_id_unique = paste0(holc_city, '_', holc_id_mod)) %>% 
        select(-holc_id_mod)
    #### check
    if (sum(duplicated(sf_redline_maps$holc_id_unique)) > 0) {
        stop('HOLC ID not unique')
    }
    
    ## construct URL to online resources ----
    sf_redline_maps <- sf_redline_maps %>% 
        mutate(holc_url = case_when(
            is.na(holc_id) ~ NA,
            holc_city == 'LosAngeles' ~ glue('https://dsl.richmond.edu/panorama/redlining/#city=los-angeles-ca&area={holc_id}'),
            holc_city == 'SanDiego' ~ glue('https://dsl.richmond.edu/panorama/redlining/#city=san-diego-ca&area={holc_id}'),
            holc_city == 'SanFrancisco' ~ glue('https://dsl.richmond.edu/panorama/redlining/#city=san-francisco-ca&area={holc_id}'),
            holc_city == 'SanJose' ~ glue('https://dsl.richmond.edu/panorama/redlining/#city=san-jose-ca&area={holc_id}'),
            .default = glue('https://dsl.richmond.edu/panorama/redlining/#city={tolower(holc_city)}-ca&area={holc_id}')
        ) )
    
    
    ## add parsed HOLC area description excerpts ----
    sf_redline_maps <- sf_redline_maps %>% 
        left_join(holc_area_descriptions %>% 
                      filter(!is.na(holc_id)) %>% 
                      select(holc_city, 
                             holc_id, 
                             holc_area_description_excerpts = area_description_excerpts),
                  by = c('holc_city', 'holc_id'))
     
    ## rearrange fields
    sf_redline_maps <- sf_redline_maps %>% 
        relocate(holc_id_unique) %>% 
        relocate(geometry, .after = holc_area_description_excerpts)
    
    
    # write processed HOLC data ------------------------------------------------
    
    ## save to geopackage file ----
    st_write(obj = sf_redline_maps, 
             here(output_directory,
                       glue('{output_file_name}.gpkg')),
             append = FALSE)  
    
    
    
    # return processed dataset ------------------------------------------------
    return(sf_redline_maps)
    
}

