# # Create a static map with 4 panels, that show the following panes for a 
# # selected city:
# # 1. HOLC (redline) polygons, filled with color indicating their grade (A-D)
# # 2. CalEnviroScreen Polygons in the selected city (filled with color indicating
# #    their CES score for a selected measure), with HOLC polygon borders (colored 
# #    by grade) on top
# # 3. CalEnviroScreen Polygons (filled with color indicating
# #    their CES score for a selected measure) clipped to HOLC polygons, with 
# #    HOLC polygon borders (colored by grade) on top
# # 4. HOLC polygons with their calculated CES score (filled with color indicating
# #    their CES score for a selected measure), with HOLC polygon borders 
# #    (colored by grade) on top
# # 
# # NOTE: plot any CES measure by changing the 'ces_measure_id' variable (and the 
# # associated 'ces_measure_title' variable) - may need to adjust some other 
# # plotting parameters when doing this
# 
# # packages -----------------------------------------------------------
# library(tidyverse)
# library(here)
# library(sf)
# library(scales)
# library(glue)
# library(tmap)
# library(tmaptools)
# library(ceramic)
# 
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)

# create function ----
f_plot_map_panels <- function(sf_formatted_ces_data,
                              sf_formatted_holc_data,
                              sf_combined_results,
                              city_selected = 'Stockton', # city in the HOLC dataset to map
                              ces_measure_id = 'calenviroscreen_4_0_score', # name of field in CES dataset to map
                              ces_measure_title = 'CES 4.0 Score', # title of field for map
                              output_directory, 
                              output_file_name,
                              basemap_type = 'mapbox', # 'mapbox' or 'osm'
                              mapbox_api_key = Sys.getenv('mapbox_api_key'), # need to have a mapbox API key (free) saved as an environment variable
                              projected_crs = 3310, 
                              geographic_crs = 4269) {
    
    
    # setup -------------------------------------------------------------------
    pdf(NULL) # prevent Rplots.pdf file from being generated
    
    # see: https://github.com/rspatial/terra/issues/343#issuecomment-929334064
    sf_proj_network(TRUE)
    
    ## set variables ----
    ces_palette <- '-RdYlGn' # color palette for mapping CES scores - use NULL for the tmap default
    ces_breaks <- seq(from = 0, to = 100, by = 10) # color breaks for mapping CES scores - use NULL for the tmap default
    
    ## set other tmap options across all maps ----
    legend_color <- 'white'
    legend_alpha  <- 0.4
    legend_frame  <- TRUE
    basemap_alpha <- 0.5
    
    
    
    # process data ------------------------------------------------------------
    
    ## create dataset of CES clipped to HOLC polygons ----
    sf_ces_clipped <- sf_formatted_ces_data %>%
        st_transform(projected_crs) %>% 
        st_intersection(sf_formatted_holc_data %>% 
                            st_transform(projected_crs))
    
    ## create hulls of HOLC polygons for each city ----
    sf_hulls <- map_df(.x = sf_formatted_holc_data %>% 
                           st_transform(projected_crs) %>% 
                           distinct(holc_city) %>% 
                           pull(holc_city), 
                       .f = ~ sf_formatted_holc_data %>% 
                           st_transform(projected_crs) %>%
                           filter(holc_city == .x) %>% 
                           st_union() %>% 
                           st_convex_hull() %>% 
                           st_sf() %>% 
                           mutate(city = .x))
    
    ## convert all to geographic coordinates (for map making) ----
    sf_combined_results <- sf_combined_results %>% st_transform(geographic_crs)
    sf_formatted_holc_data <- sf_formatted_holc_data %>% st_transform(geographic_crs)
    sf_formatted_ces_data <- sf_formatted_ces_data %>% st_transform(geographic_crs)
    sf_ces_clipped <- sf_ces_clipped %>% st_transform(geographic_crs)
    sf_hulls <- sf_hulls %>% st_transform(geographic_crs)
    
    ## annotate HOLC grade names
    sf_formatted_holc_data <- sf_formatted_holc_data %>% 
        mutate(holc_grade = case_when(holc_grade == 'A' ~ 'A (Best)', 
                                  holc_grade == 'B' ~ 'B (Desirable)', 
                                  holc_grade == 'C' ~ 'C (Declining)', 
                                  holc_grade == 'D' ~ 'D (Hazardous)'))
    
    
    # get basemap -------------------------------------------------------------
    ## get a basemap to add to each map pane - may be a few different options for
    ## this, including:
    ## - {ceramic} package - gets data from mapbox
    ## - {rosm} package - gets data from OSM / Bing / etc
    ## - {mapboxapi} package - gets data from mapbox
    
    if (basemap_type == 'mapbox') {
        ## mapbox / ceramic ----
        centroid <- sf_hulls %>%
            filter(city == city_selected) %>%
            st_transform(4326) %>%
            st_centroid()
        
        centroid_point <- centroid %>%
            st_geometry() %>%
            unlist() %>%
            matrix(nrow = 1)
        
        Sys.setenv(MAPBOX_API_KEY = mapbox_api_key)
        map_background <- cc_location(centroid_point,
                                      buffer = 15000, # original: 10000
                                      verbose = FALSE)
    } else if (basemap_type == 'osm') {
        ## rosm ----
        # library(rosm)
        # library(sp)

        # osm.types() # available types
        map_background <- sf_hulls %>%
            filter(city == city_selected) %>%
            st_buffer(3500) %>% ## NEED TO ADJUST FOR DIFFERENT CITIES
            st_transform(geographic_crs) %>%
            as_Spatial() %>%
            sp::bbox() %>%
            # osm.plot(type = 'osm') # to view
            osm.raster(type = 'osm') # for use in maps
        map_background[map_background[]>255]=255
        map_background[map_background[]<0]=0
    }
    
    
    # create map template -----------------------------------------------------
    
    ## create template that will be added on to maps 2-4 below (after adding the 
    ## basemap and CES polygons) - the template:
    ## - sets the default view
    ## - adds HOLC polygon borders (colored by grade), and 
    ## - adds a legend 
    
    ## set default view
    map_template <- tm_shape(sf_formatted_holc_data %>% 
                                 filter(holc_city == city_selected), 
                             is.master = TRUE) +
        tm_borders(lwd = 0, alpha = 0)
    
    ## add HOLC polygons - class D ----
    map_template <- map_template +
        tm_shape(sf_formatted_holc_data %>% 
                     filter(holc_city == city_selected, 
                            holc_grade == 'D (Hazardous)')) + 
        tm_borders(lwd = 2, col = 'red') + 
        # tm_text('holc_grade', size = 0.5, col = 'red') +
        NULL
    
    ## add HOLC polygons - class C ----
    map_template <- map_template + 
        tm_shape(sf_formatted_holc_data %>% 
                     filter(holc_city == city_selected, 
                            holc_grade == 'C (Declining)')) + 
        tm_borders(lwd = 2, col = 'gold2') + 
        # tm_text('holc_grade', size = 0.5, col = 'gold2') +
        NULL
    
    ## add HOLC polygons - class B ----    
    map_template <- map_template + 
        
        tm_shape(sf_formatted_holc_data %>%
                     filter(holc_city == city_selected, 
                            holc_grade == 'B (Desirable)')) + 
        tm_borders(lwd = 2, col = 'blue') + 
        # tm_text('holc_grade', size = 0.5, col = 'blue') +
        NULL
    
    ## add HOLC polygons - class A ----
    map_template <- map_template + 
        tm_shape(sf_formatted_holc_data %>% 
                     filter(holc_city == city_selected, 
                            holc_grade == 'A (Best)')) + 
        tm_borders(lwd = 2, col = 'green') +
        # tm_text('holc_grade', size = 0.5, col = 'green') + 
        NULL
    
    ## add legend ----
    map_template <- map_template + 
        tm_layout(legend.bg.color = legend_color, 
                  legend.bg.alpha = legend_alpha, 
                  legend.frame = legend_frame)
    
    
    
    # map 1 - HOLC (redline) polygons -----------------------------------------
    
    ## map of HOLC polygons in the selected city, colored by HOLC grade (A-D)
    
    map_redline <- tm_shape(map_background) + 
        tm_rgb(alpha = basemap_alpha) +
        tm_shape(sf_formatted_holc_data %>% 
                     filter(holc_city == city_selected), 
                 is.master = TRUE) + 
        tm_polygons('holc_grade', 
                    palette = c('green', 'blue', 'yellow', 'red'), 
                    title = 'HOLC Grade') + 
        tm_layout(legend.bg.color = legend_color, 
                  legend.bg.alpha = legend_alpha, 
                  legend.frame = legend_frame)
    
    
    
    # map 2 - CES / HOLC overlap ----------------------------------------------
    
    # CalEnviroScreen Polygons in the selected city (filled with color indicating
    # their CES score for a selected measure), with HOLC polygon borders (colored 
    # by grade) on top
    
    map_ces <-  tm_shape(map_background) + 
        tm_rgb(alpha = basemap_alpha) +
        ## add CES
        tm_shape(sf_formatted_ces_data %>% 
                     st_filter(sf_hulls %>% 
                                   filter(city == city_selected))) + 
        tm_polygons(col = ces_measure_id, 
                    palette = ces_palette, 
                    breaks = ces_breaks,
                    title = ces_measure_title, 
                    border.alpha = 1) + 
        map_template
    
    
    
    # map 3 - CES clipped to HOLC ---------------------------------------------
    
    ## CalEnviroScreen Polygons (filled with color indicating
    ## their CES score for a selected measure) clipped to HOLC polygons, with 
    ## HOLC polygon borders (colored by grade) on top
    
    map_overlap <- tm_shape(map_background) + 
        tm_rgb(alpha = basemap_alpha) +
        ## add CES outlines (full CES polygons)
        tm_shape(sf_formatted_ces_data %>% 
                     st_filter(sf_hulls %>% 
                                   filter(city == city_selected))) +
        tm_borders(lwd = 1) + 
        ## add clipped CES polygons (filled)
        tm_shape(sf_ces_clipped %>% 
                     filter(holc_city == city_selected)) + 
        tm_polygons(col = ces_measure_id, 
                    palette = ces_palette, 
                    breaks = ces_breaks,
                    title = ces_measure_title, 
                    border.alpha = 1) + 
        map_template
    
    
    
    # map 4 - HOLC computed CES scores ----------------------------------------
    
    # HOLC polygons with their calculated CES score (filled with color indicating
    # their CES score for a selected measure), with HOLC polygon borders 
    # (colored by grade) on top
    
    map_holc_scores <- tm_shape(map_background) + 
        tm_rgb(alpha = basemap_alpha) +
        ## add CES outlines (full CES polygons)
        tm_shape(sf_formatted_ces_data %>% 
                     st_filter(sf_hulls %>% 
                                   filter(city == city_selected))) +
        tm_borders(lwd = 1) + 
        ## add HOLC polygons with CES polygons (filled)
        tm_shape(sf_combined_results %>% 
                     filter(holc_city == city_selected), 
                 is.master = TRUE) + 
        tm_polygons(col = ces_measure_id, 
                    palette = ces_palette, 
                    breaks = ces_breaks,
                    title = ces_measure_title, 
                    border.alpha = 0) + 
        map_template
    
    
    
    # combine and save --------------------------------------------------------
    
    ## combine ----
    map_combined <- tmap_arrange(map_redline, map_ces, map_overlap, map_holc_scores, 
                                 nrow = 1)
    
    ## save ----
    tmap_save(tm = map_combined, 
              filename = here(output_directory, 
                              glue('{output_file_name}_{city_selected}.png')),
              bg = 'white',
              # bg = 'transparent',
              width = 10.0, # original: 10.0
              height = 4.5, # original: 4.0
              dpi = 300 # default: 300
    ) 
    
    tmap_save(tm = map_combined, 
              filename = here(output_directory, 
                              glue('{output_file_name}_{city_selected}_transparent.png')),
              # bg = 'white',
              bg = 'transparent',
              width = 10.0, # original: 10.0
              height = 4.5, # original: 4.0
              dpi = 300 # default: 300
    )
    
    ## return map ----
    # return(map_combined)
    
    ## return path to map image ----
    return(here(output_directory,
                glue('{output_file_name}_{city_selected}.png')))
    
}
