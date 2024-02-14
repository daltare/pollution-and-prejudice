# # Process CalEnviroScreen (CES) data to prepare it for use in the redline
# # mapping analysis (and potentially other analyses)
# # for CES 4.0 info, see: https://oehha.ca.gov/calenviroscreen/report/calenviroscreen-40
# 
# # packages ----
# library(tidyverse)
# library(sf)
# library(here)
# library(httr)
# library(tools)
# library(janitor)
# library(tigris)
# library(rmapshaper)
# library(glue)
# 
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)

# create function ----
f_process_ces_data <- function(raw_ces_data_file, 
                               ces_names_file, 
                               output_file_name, 
                               output_directory,
                               projected_crs = 3310) {
    
    ### NOTE: I manually created the ces-4_names.csv file to make more descriptive 
    ### names for the fields in the CES 4.0 shapefile, based on the 'Data Dictionary'
    ### tab in the excel workbook at: 
    ### https://oehha.ca.gov/media/downloads/calenviroscreen/document/calenviroscreen40resultsdatadictionaryf2021.zip
    
    
    # make sure the output directory exists ----
    if (!dir.exists(here(output_directory))) {
        dir.create(here(output_directory), 
                   recursive = TRUE)
    }
    
    # unzip raw CES data to temporary directory & read into R --------------
    ## create temporary directory ----
    temp_dir <- tempdir()
    
    ## unzip ----
    unzip(zipfile = raw_ces_data_file,
          exdir = file.path(temp_dir,
                            basename(raw_ces_data_file) %>%
                                file_path_sans_ext()))
    ## read CES data ----
    sf_ces_raw <- st_read(file.path(temp_dir,
                                    basename(raw_ces_data_file) %>%
                                        file_path_sans_ext())) %>%
        arrange(Tract) %>%
        clean_names()
    
    
    # process CES data ------------------------------------------------------
    ## create processed dataset ----
    sf_ces_processed <- sf_ces_raw
    
    ## fix self-intersecting polygons ----
    if (sum(!st_is_valid(sf_ces_processed)) > 0) {
        sf_ces_processed <- st_buffer(sf_ces_processed, 
                                      dist = 0)
    }
    
    ## remove un-needed fields ----
    sf_ces_processed <- sf_ces_processed %>% 
        select(-shape_leng, -shape_area)
    
    ## clean field names (make more descriptive) ----
    ### get new names ----
    ces_names <- read_csv(ces_names_file) %>% 
        mutate(ces_variable = make_clean_names(variable_name, 
                                               case = 'snake', 
                                               replace = c('CalEnviroScreen' = 'calenviroscreen',
                                                           '(%)' = 'percent')), 
               .before = 1)
    
    ### set names in the sf dataset ----
    if (all(ces_names$ces_variable_original_shapefile == names(sf_ces_processed))) { # make sure the field names in the SF dataset match the names from the ces-4_names.csv file 
        names(sf_ces_processed) <- ces_names$ces_variable
    }
    
    ## set missing / negative values to NA ----
    ### check
    # map_dbl(.x = sf_ces_processed %>% 
    #             st_drop_geometry() %>% 
    #             select_if(is.numeric), 
    #         .f = ~sum(.x < 0, na.rm = TRUE)) 
    ### replace 
    sf_ces_processed <- sf_ces_processed %>% 
        mutate(across(.cols = where(is.numeric), 
                      .fns = ~ifelse(. < 0, NA, .)))
    
    ## set demographic percentages to raw number (0-1) ----
    ## (these raw numbers make for valid calculations)
    sf_ces_processed <- sf_ces_processed %>% 
        mutate(across(.cols = ends_with('percent'), 
                      .fns = ~ . /100))
    
    ## use TIGER census tract geometry ----
    ### Data Sources:
    ### FTP: https://www2.census.gov/geo/pvs/tiger2010st/06_California/06/tl_2010_06_tract10.zip
    ### Web Inerface: https://www.census.gov/cgi-bin/geo/shapefiles/index.php?year=2010&layergroup=Census+Tracts
    ### tigris package: tract_2010 <- tigris::tracts(state = 'CA', year = 2010)
    
    ### get tiger data ----
    sf_tracts_2010_tiger <- tracts(state = 'CA', 
                                   year = 2010)
    sum(!st_is_valid(sf_tracts_2010_tiger)) # should be zero
    
    ### clean up tiger data ----
    sf_ces_tiger <- sf_tracts_2010_tiger %>% 
        select(GEOID10, geometry) %>%
        mutate(GEOID10 = as.numeric(GEOID10)) %>% 
        filter(GEOID10 %in% sf_ces_processed$census_tract_2010) %>% 
        st_transform(projected_crs) %>% 
        rename(census_tract_2010 = GEOID10) %>% 
        arrange(census_tract_2010) %>% 
        {.}
    
    ## add CES data to 2010 tiger tracts ----
    sf_ces_tiger <- sf_ces_tiger %>% 
        left_join(sf_ces_processed %>% 
                      st_drop_geometry(), 
                  by = c('census_tract_2010'))
    
    # names(sf_ces_tiger)
    # glimpse(sf_ces_tiger)
    
    ## simplify ----
    sf_ces_tiger_simple <- sf_ces_tiger %>% 
        ms_simplify(keep = 0.3, # keep = 0.05 (default)
                    keep_shapes = TRUE, 
                    snap = TRUE) 
    sum(!st_is_valid(sf_ces_tiger_simple)) # should be zero
    
    ### preserve column order after simplification ----
    ### (for some reason, the simplification operation seems to re-order the fields)
    if (sum(names(sf_ces_tiger_simple) != names(sf_ces_processed)) > 0) {
        sf_ces_tiger_simple <- sf_ces_tiger_simple %>% 
            select(all_of(names(sf_ces_processed)))
    }
    
    
    
    # write processed CES data ----------------------------------------------
    
    ## file w/ original geometry ----
    st_write(sf_ces_processed, 
             here(output_directory,
                       glue('{output_file_name}.gpkg')), 
             append = FALSE)
    
    ## file w/ raw TIGER geometry (may be large) ----
    # st_write(sf_ces_tiger,
    #          here(output_directory, 
    #               glue('{output_file_name}_tiger.gpkg')),
    #          append = FALSE)
    
    ## file w/ simplified TIGER geometry
    st_write(sf_ces_tiger_simple, 
             here(output_directory,
                       glue('{output_file_name}_tiger_simple.gpkg')), 
             append = FALSE)

    
    
    # return processed dataset ------------------------------------------------
    return(sf_ces_tiger_simple)
    
    
    # ## return path to processed dataset ----
    # return(here(output_directory,
    #             glue('{output_file_name}_tiger_simple.gpkg')))
    
}
