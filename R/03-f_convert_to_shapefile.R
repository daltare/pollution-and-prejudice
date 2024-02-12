# # Convert results from geopackage to shapefile format
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
    col_names_rev <- read_csv(here('data_input_manual',
                                   'col_names_outputs.csv'))
    ### set names ----
    names(sf_combined_summary_rev) <- col_names_rev$col_name_shp
    
    ## save to shapefile ----
    st_write(sf_combined_summary_rev, 
             here(output_directory, 
                  output_file_name),
             append = FALSE
    )
    
    ## return path to file ----
    return(here(output_directory,
                glue('{output_file_name}')))
    
}
