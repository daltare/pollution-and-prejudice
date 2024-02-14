# # Convert results from geopackage to shapefile format
# 
# # packages ----
# library(tidyverse)
# library(here)
# library(sf)
# library(zip)
# 
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)

# create function ----
f_convert_to_shapefile <- function(sf_combined_summary, 
                                   output_file_name,
                                   output_directory) {
    
    ## make sure the output directory exists ----
    if (!dir.exists(here(output_directory))) {
        dir.create(here(output_directory),
                   recursive = TRUE)
    }
    
    ## revise names to fit 10 character shapefile limit ----
    sf_combined_summary_rev <- sf_combined_summary
    
    ### get new field names (manually created) ----
    col_names_rev <- read_csv(here('03-1_output_data',
                                   'data_dictionary_outputs.csv'))
    ### set names ----
    names(sf_combined_summary_rev) <- col_names_rev$field_name_shapefile
    
    ## save to shapefile ----
    st_write(sf_combined_summary_rev, 
             here(output_directory,
                  paste0(output_file_name)),
             append = FALSE
    )
    
    ## zip shapefile ----
    zip::zip(zipfile = paste0(here(output_directory), '.zip'),  
             files = dir(here(output_directory), full.names = TRUE), 
             mode =  'cherry-pick')
    
    ## remove unzipped shapefile
    unlink(here(output_directory), recursive = TRUE)
    
    ## return path to file ----
    return(paste0(here(output_directory), '.zip'))
}
