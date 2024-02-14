# This file defines the pipeline to do all data gathering, data processing, and 
# computations for the CalEPA Pollution & Prejudice project. It also creates 
# some output plots and maps, and puts them in a summary report.
#
# Follow the manual to check and run the pipeline:
# https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline 



# setup -------------------------------------------------------------------

## Load packages required to define the pipeline
library(targets)
library(tarchetypes) 
library(here)

# force report to render to html if source qmd file changes
last_report_update <- file.info('03-3_output_reports/summary_report.qmd')$mtime

## Set target options:
tar_option_set(
    # packages that targets need to run
    packages = c('tidyverse', 
                 'conflicted',
                 'here',
                 'glue', 
                 'janitor',
                 'tools',
                 'httr',
                 'sf',
                 'jsonlite',
                 'geojsonsf',
                 'tigris',
                 'rmapshaper',
                 'units',
                 'scales',
                 'cowplot',
                 'tmap',
                 'tmaptools',
                 'ceramic', 
                 'rosm',
                 'sp',
                 'quarto',
                 'gt',
                 'knitr',
                 'zip'
    ), 
    # default storage format
    format = "rds",
    # set seed (for consistent geom_jitter)
    seed = 1234,
    # for debugging (if needed) - on error, call tar_workspace() to load the workspace
    workspace_on_error = TRUE,
    # for saving workspaces for specific targets (can be useful for development / debugging)
    workspaces = NULL # c('sf_formatted_holc_data') # enter names of targets to save workspaces for - call tar_workspace() to load the workspace
)

## parallel options (set by targets) ---- 
### tar_make_clustermq() configuration
options(clustermq.scheduler = "multiprocess")

### tar_make_future() configuration
future::plan(future.callr::callr)



# define pipeline ---------------------------------------------------------

## get functions (from R folder) ----
tar_source(files = c('R', '02_scripts'))

## build pipeline ----
list(
    ### 01 - get / process data ------------------------------------------------
    #### 01-1 - CES data ----
    tar_target(name = raw_ces_data_file, 
               command = f_download_raw_ces_data(
                   url_ces_shp = 'https://oehha.ca.gov/media/downloads/calenviroscreen/document/calenviroscreen40shpf2021shp.zip',
                   download_directory = '01-2_data_raw/ces_data'),
               format = 'file'
    ),
    #### NOTE: I manually created the ces-4_names.csv file to make more descriptive 
    #### names for the fields in the CES 4.0 shapefile, based on the 'Data Dictionary'
    #### tab in the excel workbook at: 
    #### https://oehha.ca.gov/media/downloads/calenviroscreen/document/calenviroscreen40resultsdatadictionaryf2021.zip
    tar_target(name = ces_names_file,
               command = here('01-1_data_input_manual',
                              'ces-4_names.csv'),
               format = 'file'
    ),
    tar_target(name = sf_formatted_ces_data,
               command = f_process_ces_data(
                   raw_ces_data_file,
                   ces_names_file,
                   output_file_name = 'calenviroscreen_4-0_processed',
                   output_directory = '01-3_data_processed/ces_data')
    ),
    
    #### 01-2 - HOLC (redline) data ----
    tar_target(name = raw_holc_data_files,
               command = f_download_raw_holc_data(
                   url_base = 'https://dsl.richmond.edu/panorama/redlining/static/downloads/', 
                   download_directory = '01-2_data_raw/holc_data')
    ),
    tar_target(name = holc_area_descriptions,
               command = f_parse_holc_descriptions(
                   raw_holc_data_files, 
                   output_directory = '01-3_data_processed/holc_data/area_descriptions')
    ),
    tar_target(name = sf_formatted_holc_data,
               command = f_process_holc_data(
                   raw_holc_data_files,
                   holc_area_descriptions,
                   output_file_name = 'HOLC_maps_processed',
                   output_directory = '01-3_data_processed/holc_data')
    ),
    
    
    ### 02 - calculate CES scores & demographics -------------------------------
    #### 02-1 - assign minimum CES coverage threshold ----
    ## (this represents the minimum portion of a HOLC neighborhood's area that needs to 
    ## be covered by CES tracts that have CES scores (for any given CES indicator) 
    ## in order to assign a score to a HOLC neighborhood - some tracts are missing 
    ## scores for individual indicators or overall CES scores)
    tar_target(name = ces_coverage_threshold, 
               command = {
                   ces_coverage_threshold <- 0.5
               }
    ),
    #### 02-2 - calculate CES scores (by HOLC neighborhood) ----
    tar_target(name = df_holc_ces_scores_calculations, 
               command = f_compute_HOLC_CES_scores(
                   sf_formatted_ces_data,
                   sf_formatted_holc_data,
                   ## set minimum portion of a HOLC polygon that must be covered 
                   ## by CES polygon(s) with CES score for given CES measure
                   ## (if coverage < threshold, set CES score to NA for that measure)
                   ces_coverage_threshold)
    ),
    tar_target(name = ces_scores_missing_check,
               command = f_check_missing_CES_scores(
                   df_holc_ces_scores_calculations)
    ),
    tar_target(name = df_holc_ces_scores_summary, 
               command = f_summarize_HOLC_CES_scores(
                   df_holc_ces_scores_calculations,
                   sf_formatted_ces_data
               )),
    
    #### 02-3 - calculate demographics (by HOLC neighborhood) ----
    tar_target(name = df_holc_demographics_calculations, 
               command = f_compute_HOLC_demographics(
                   sf_formatted_ces_data,
                   sf_formatted_holc_data)
    ),
    tar_target(name = df_holc_demographics_summary, 
               command = f_summarize_HOLC_demographics(
                   df_holc_demographics_calculations)
    ),
    
    #### 02-4 - calculate / compare nearest centroid CES scores (by HOLC neighborhood) ----
    tar_target(name = sf_holc_ces_scores_centroids, 
               command = f_compute_HOLC_CES_scores_centroids(
                   sf_formatted_ces_data, 
                   sf_formatted_holc_data, 
                   ces_measure_id = 'calenviroscreen_4_0_score',
                   output_file_name = 'HOLC_CES_scores_centroids.gpkg',
                   output_directory = '03-1_output_data')
    ),
    tar_target(name = df_holc_ces_scores_comparison, 
               command = f_combine_HOLC_CES_score_methods(
                   df_holc_ces_scores_calculations,
                   sf_holc_ces_scores_centroids,
                   ces_measure_id = 'calenviroscreen_4_0_score'
               )
    ),
    tar_target(name = holc_ces_score_methods_correlation, 
               command = f_HOLC_CES_score_methods_correlation(
                   df_holc_ces_scores_comparison
               )
    ),
    
    ### 03 - combine data & create output file ---------------------------------
    #### 03-1 - combine data and create geopackage
    tar_target(name = sf_combined_results, 
               command = f_combine_computed_data(
                   df_holc_ces_scores_summary, 
                   df_holc_demographics_summary,
                   sf_formatted_holc_data,
                   output_file_name = 'HOLC_CES_scores_demographics.gpkg',
                   output_directory = '03-1_output_data')
    ),
    
    #### 03-2 - write shapefile
    tar_target(name = write_shapefile, 
               command = f_convert_to_shapefile(
                   sf_combined_results, 
                   output_file_name = 'HOLC_CES_scores_demographics.shp',
                   output_directory = '03-1_output_data/HOLC_CES_scores_demographics_shp'),
               format = 'file'
    ),
    
    
    ### 04 - create plots & maps -----------------------------------------------
    #### 04-1 - map (showing analysis process) - 4 panes ----
    #### NOTE: this plot can't be saved as an RDS file, so the target is just 
    #### saving the path to the output png file - read the plot into R with:
    ####    magick::image_read(tar_read(plot_map_panels))
    tar_target(name = plot_map_panels,
               command = f_plot_map_panels(
                   sf_formatted_ces_data,
                   sf_formatted_holc_data,
                   sf_combined_results,
                   city_selected = 'Stockton',
                   ces_measure_id = 'calenviroscreen_4_0_score',
                   ces_measure_title = 'CES 4.0 Score', # 'CalEnviroScreen 4.0 Score',
                   output_directory = '03-2_output_plots',
                   output_file_name = '01_map-combined',
                   mapbox_api_key = Sys.getenv('mapbox_api_key'), # need to have a mapbox API key (free) saved as an environment variable
                   basemap_type = 'mapbox'), # 'mapbox' or 'osm'
               format = 'file'
    ),
    #### 04-2 - CES scores - points - raw score (grouped by city / HOLC grade) ----
    tar_target(name = plot_scores_points_raw,
               command = f_plot_scores_points_raw(
                   sf_combined_results,
                   ces_measure_id = 'calenviroscreen_4_0_score',
                   ces_measure_title = 'Estimated CES 4.0 Score', # 'CalEnviroScreen 4.0 Score',
                   output_directory = '03-2_output_plots',
                   output_file_name = '02_raw-score_point_by-city')
    ),
    #### 04-3 - CES scores - points - average score by city / HOLC grade ----
    tar_target(name = plot_scores_points_average_by_grade,
               command = f_plot_scores_points_average_by_grade(
                   sf_combined_results,
                   ces_measure_id = 'calenviroscreen_4_0_score',
                   ces_measure_title = 'Estimated CES 4.0 Score', # 'CalEnviroScreen 4.0 Score',
                   output_directory = '03-2_output_plots',
                   output_file_name = '03_average-score_point_by-city')
    ),
    #### 04-3 - demographics (race) - bar plot ----
    tar_target(name = plot_race_bars_by_group, 
               command = f_plot_race_bars_by_group(
                   sf_combined_results, 
                   output_directory = '03-2_output_plots',
                   output_file_name = '04_race_bar_by-race')
    ),
    #### 04-4 - CES scores - points - departure score (grouped by city / HOLC grade) ----
    tar_target(name = plot_scores_points_departure,
               command = f_plot_scores_points_departure(
                   sf_combined_results,
                   ces_measure_id = 'calenviroscreen_4_0_score',
                   ces_measure_title = 'Estimated CES 4.0 Score', # 'CalEnviroScreen 4.0 Score',
                   output_directory = '03-2_output_plots',
                   output_file_name = '99_departure-score_point_by-city')
    ),
    #### 04-5 - CES departure scores - box plot  ----
    tar_target(name = plot_scores_box_departure,
               command = f_plot_scores_box_departure(
                   sf_combined_results,
                   ces_measure_id = 'calenviroscreen_4_0_score',
                   ces_measure_title = 'Estimated CES 4.0 Score', # 'CalEnviroScreen 4.0 Score',
                   output_directory = '03-2_output_plots',
                   output_file_name = '99_departure-score_box_by-holc-grade')
    ),
    #### 04-6 - CES departure scores - box plot w/ legend  ----
    tar_target(name = plot_scores_box_departure_legend,
               command = f_plot_scores_box_departure_legend(
                   sf_combined_results,
                   ces_measure_id = 'calenviroscreen_4_0_score',
                   ces_measure_title = 'Estimated CES 4.0 Score', # 'CalEnviroScreen 4.0 Score',
                   output_directory = '03-2_output_plots',
                   output_file_name = '99_departure-score_box_by-holc-grade_with-legend',
                   error_bar = TRUE,
                   outer_point = FALSE)
    ),
    #### 04-7 - CES scores method comparison  ----
    tar_target(name = plot_scores_method_comparison_scatter, 
               command = f_plot_scores_method_comparison_scatter(
                   df_holc_ces_scores_comparison,
                   ces_measure_id = 'calenviroscreen_4_0_score',
                   ces_measure_title = 'CES 4.0 Score',
                   output_directory = '03-2_output_plots',
                   output_file_name = '99_score_method_comparison_scatter'
               )
    ),
    #### 04-8 - CES scores method comparison - faceted  ----
    tar_target(name = plot_scores_method_comparison_scatter_facet, 
               command = f_plot_scores_method_comparison_scatter_facet(
                   df_holc_ces_scores_comparison,
                   ces_measure_id = 'calenviroscreen_4_0_score',
                   ces_measure_title = 'CES 4.0 Score',
                   output_directory = '03-2_output_plots',
                   output_file_name = '99_score_method_comparison_scatter_facet'
               )
    ),
    
    
    ### 05 - create reports / presentations ------------------------------------
    tar_quarto(name = summary_report, 
               path = '03-3_output_reports/summary_report.qmd'
    ),
    tar_target(name = summary_report_html, 
               command = {
                   # force this to re-run if the qmd file has changed
                   last_report_update
                   # render
                   quarto_render(input = '03-3_output_reports/summary_report.qmd', 
                                 output_format = 'html')
               },
               format = 'file'),
    tar_quarto(name = targets_notes_file, 
               path = 'targets_notes.qmd'),
    
    ### 06 - readme file -------------------------------------------------------
    tar_quarto(name = readme_file,
               path = 'README.qmd')
)

