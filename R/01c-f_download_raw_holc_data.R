# # Process HOLC data (i.e., the 1930s redline maps) to prepare for use in the 
# # redline mapping analysis (and potentially other analyses) - 
# # for HOLC data (redline maps), see: https://dsl.richmond.edu/panorama/redlining/#text=downloads
# 
# # packages ----
# library(tidyverse)
# library(sf)
# library(here)
# 
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)
# 
# HOLC maps URL
# url_base <- 'https://dsl.richmond.edu/panorama/redlining/static/downloads/'

# function ----

f_download_raw_holc_data <- function(url_base, 
                                     download_directory) {
    
    ## make sure the local directory exists ----
    if (!dir.exists(here(download_directory))) {
        dir.create(here(download_directory), 
                   recursive = TRUE)
    }
    
    ## list cities with HOLC maps, and associated zip file names ----
    ## (find at: https://dsl.richmond.edu/panorama/redlining/#text=downloads)
    redline_cities <- tribble(
        ~holc_city, ~holc_filename, 
        'Fresno', 'CAFresno1936',
        'LosAngeles', 'CALosAngeles1939', 
        'Oakland', 'CAOakland1937', 
        'Sacramento', 'CASacramento1937', 
        'SanDiego', 'CASanDiego1938', 
        'SanFrancisco', 'CASanFrancisco1937', 
        'SanJose', 'CASanJose1937', 
        'Stockton', 'CAStockton1938', 
    )
    
    ## add year
    redline_cities <- redline_cities %>% 
        mutate(holc_year = parse_number(holc_filename))
    
    ## download zipped shapefiles to local directory ----
    # walk2(.x = redline_cities$holc_city,
    #       .y = redline_cities$holc_filename, 
    #       .f = ~ GET(url = paste0(url_base, 'shapefiles/', .y, '.zip'), 
    #                  write_disk(here(download_directory, 
    #                                  paste0(.y, '.zip')),
    #                             overwrite = TRUE)))
    
    ## download geojson files to local directory ----
    walk2(.x = redline_cities$holc_city,
          .y = redline_cities$holc_filename, 
          .f = ~ GET(url = paste0(url_base, 'geojson/', .y, '.geojson'), 
                     write_disk(here(download_directory, 
                                     paste0(.y, '.geojson')),
                                overwrite = TRUE)))
    
    ## return data frame including path to raw data files (all files) ----
    raw_files_info <- redline_cities %>% 
        # mutate(file_path = here(download_directory, 
        #                         paste0(redline_cities$holc_filename, '.zip'))
        # )
        mutate(file_path = here(download_directory, 
                                paste0(redline_cities$holc_filename, '.geojson'))
        )
    
    return(raw_files_info)
}
