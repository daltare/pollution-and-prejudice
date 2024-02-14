# # Download raw CalEnviroScreen (CES) data 
# # for CES 4.0 info, see: https://oehha.ca.gov/calenviroscreen/report/calenviroscreen-40
# 
# # packages ----
# library(tidyverse)
# library(httr)
# 
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)
# 
# CES 4 URL
# url_ces_shp <- 'https://oehha.ca.gov/media/downloads/calenviroscreen/document/calenviroscreen40shpf2021shp.zip',

# create function ----
f_download_raw_ces_data <- function(url_ces_shp, 
                                    download_directory) {
    
    ## make sure the local directory exists ----
    if (!dir.exists(here(download_directory))) {
        dir.create(here(download_directory), 
                   recursive = TRUE)
        }
    
    ## download zipped shapefile to local directory ----
    GET(url = url_ces_shp, 
        write_disk(here(download_directory, 
                             basename(url_ces_shp)),
                   overwrite = TRUE))
    
    ## return path to raw dataset (character vector) ----
    return(here(download_directory, basename(url_ces_shp)))
    
}
