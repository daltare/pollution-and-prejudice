# # Parse HOLC area descriptions, from GeoJSON data available at: 
# # https://dsl.richmond.edu/panorama/redlining/#text=downloads
#
# # packages ----
# library(tidyverse)
# library(jsonlite)
# library(janitor)
# library(readxl)
# # library(writexl)
# library(geojsonsf)
# library(here)
# library(glue)
# 
# ## conflicts ----
# library(conflicted)
# conflicts_prefer(dplyr::filter)


# create function ----

f_parse_holc_descriptions <- function(raw_holc_data_files, 
                                      output_directory) {
    
    # make sure the output directory exists ----
    if (!dir.exists(here(output_directory))) {
        dir.create(here(output_directory),
                   recursive = TRUE)
    }
    
    
    
    # Fresno ------------------------------------------------------------------
    ## Convert geojson to dataframe
    {
        geojson_fr <- (readLines(raw_holc_data_files %>% 
                                     filter(holc_city == 'Fresno') %>% 
                                     pull(file_path)) %>% 
                           fromJSON())$features
        df_description_fr <- bind_cols(geojson_fr$properties %>% 
                                           select(-area_description_data), 
                                       geojson_fr$properties$area_description_data)
        df_description_fr <- df_description_fr %>% 
            mutate(holc_city = 'Fresno') %>% 
            rename('area_description' = '1') %>% 
            select(c('holc_city', 
                     "holc_id", "name", "holc_grade",
                     'area_description'))
        ## sort rows
        df_description_fr <- df_description_fr %>% 
            separate(col = holc_id, 
                     into = c('id_grade', 'id_numb'), 
                     sep = "(?<=[A-Z])(?=[0-9])", 
                     remove = FALSE) %>% 
            mutate(id_numb = as.numeric(id_numb)) %>% 
            arrange(id_grade, id_numb) %>% 
            select(-c('id_grade', 'id_numb')) %>% 
            clean_names()
        write_csv(x = df_description_fr, 
                  file = here(output_directory, 
                              'HOLC_fresno_area-descriptions.csv'))
        # write_xlsx(x = df_description_fr, 
        #            path = here(output_directory,
        #                        'HOLC_fresno_area-descriptions.xlsx'))    
    }
    
    
    
    # San Diego ---------------------------------------------------------------
    ## Convert geojson to dataframe
    {
        geojson_sd <- (readLines(raw_holc_data_files %>% 
                                     filter(holc_city == 'SanDiego') %>% 
                                     pull(file_path)) %>% 
                           fromJSON())$features
        df_description_sd <- bind_cols(geojson_sd$properties %>% 
                                           select(-area_description_data), 
                                       geojson_sd$properties$area_description_data)
        df_description_sd <- df_description_sd %>% 
            mutate(holc_city = 'SanDiego') %>% 
            rename('area_description' = '1') %>% 
            select(c('holc_city', 
                     "holc_id", "name", "holc_grade",
                     'area_description'))
        # sort rows
        df_description_sd <- df_description_sd %>% 
            separate(col = holc_id, 
                     into = c('id_grade', 'id_numb'), 
                     sep = "(?<=[A-Z])(?=[0-9])", 
                     remove = FALSE) %>% 
            mutate(id_numb = as.numeric(id_numb)) %>% 
            arrange(id_grade, id_numb) %>% 
            select(-c('id_grade', 'id_numb')) %>% 
            clean_names()
        write_csv(x = df_description_sd, 
                  file = here(output_directory, 
                              'HOLC_san_diego_area-descriptions.csv'))
        # write_xlsx(x = df_description_sd, 
        #            path = here(output_directory,
        #                        'HOLC_san_diego_area-descriptions.xlsx')) 
    }
    
    
    
    # San Francisco -----------------------------------------------------------
    ## Convert geojson to dataframe
    {
        geojson_sf <- (readLines(raw_holc_data_files %>% 
                                     filter(holc_city == 'SanFrancisco') %>% 
                                     pull(file_path)) %>% 
                           fromJSON())$features
        df_description_sf <- bind_cols(geojson_sf$properties %>% select(-area_description_data), 
                                       geojson_sf$properties$area_description_data)
        df_description_sf <- df_description_sf %>% 
            mutate(holc_city = 'SanFrancisco') %>% 
            rename('area_description' = '1') %>% 
            select(c('holc_city', 
                     "holc_id", "name", "holc_grade",
                     'area_description'))
        # sort rows
        df_description_sf <- df_description_sf %>% 
            separate(col = holc_id, 
                     into = c('id_grade', 'id_numb'), 
                     sep = "(?<=[A-Z])(?=[0-9])", 
                     remove = FALSE) %>% 
            mutate(id_numb = as.numeric(id_numb)) %>% 
            arrange(id_grade, id_numb) %>% 
            select(-c('id_grade', 'id_numb')) %>% 
            clean_names()
        write_csv(x = df_description_sf, 
                  file = here(output_directory, 
                              'HOLC_san_francisco_area-descriptions.csv'))
        # write_xlsx(x = df_description_sf, 
        #            path = here(output_directory,
        #                        'HOLC_san_francisco_area-descriptions.xlsx'))  
    }
    
    
    
    # Los Angeles -------------------------------------------------------------
    ## Convert geojson to dataframe
    {
        # geojson_raw_la <- readr::read_lines(url_losangeles)
        # geojson_sf_la <- geojson_raw_la %>% geojson_sf()
        # geojson_list_la <- jsonlite::fromJSON(geojson_raw_la)
        # geojson_result_la <- geojson_list_la$features
        geojson_la <- (readLines(raw_holc_data_files %>% 
                                     filter(holc_city == 'LosAngeles') %>% 
                                     pull(file_path)) %>% 
                           fromJSON())$features
        
        # df_type_la <- geojson_result_la$type
        # df_geometry_la <- geojson_result_la$geometry
        # df_properties_la <- geojson_result_la$properties %>% select(-area_description_data)
        # df_properties_la_2 <- geojson_result_la$properties$area_description_data
        # df_description_la <- bind_cols(df_properties_la, df_properties_la_2)
        df_description_la <- bind_cols(geojson_la$properties %>% 
                                           select(-area_description_data), 
                                       geojson_la$properties$area_description_data)
        
        
        # dput(sort(names(df_description_la)))
        df_description_la <- df_description_la %>% 
            mutate(holc_city = 'LosAngeles') %>% 
            select(c('holc_city',
                     "0", "holc_id", "name", "holc_grade", 
                     "1a", "1b", "1c", "1d", "1e", "2", "2a", "2b", "2c", 
                     "2d", "2e", "2f", "2g", "2h", "2i", "2j", "2k", "2l", "2m", "2n", 
                     "2o", "2p", "3", "4a", "4b", 
                     "5", "5a", "5b", "6", "71", "72", 
                     "8", "9", "10"))#, "V1"))
        # sort rows
        df_description_la <- df_description_la %>% 
            separate(col = holc_id, 
                     into = c('id_grade', 'id_numb'), 
                     sep = "(?<=[A-Z])(?=[0-9])", 
                     remove = FALSE) %>% 
            mutate(id_numb = as.numeric(id_numb)) %>% 
            arrange(id_grade, id_numb) %>% 
            select(-c('id_grade', 'id_numb')) %>% 
            select(-c('name')) %>% 
            rename('holc_region' = '0',
                   'inhabitants_pop_trend' = '1a',
                   'inhabitants_occupation' = '1b',
                   # 'inhabitants_income' = '',
                   'inhabitants_foreign_pct_predominating' = '1c',
                   'inhabitants_negro' = '1d',
                   'inhabitants_infiltration' = '1e',
                   'buildings_predominating_pct' = '2',
                   'buildings_type' = '2a',
                   'buildings_construction' = '2b',
                   'buildings_avg_age' = '2c',
                   'buildings_repair' = '2d',
                   'buildings_occupancy_pct' = '2e',
                   'buildings_ownership_pct' = '2f',
                   'buildings_1935_price_range_pct' = '2g',
                   'buildings_1937_price_range_pct' = '2h',
                   'buildings_1939_price_range_pct' = '2i',
                   'buildings_sales_demand' = '2j',
                   'buildings_price_trend' = '2k',
                   'buildings_1935_rent_range_pct' = '2l',
                   'buildings_1937_rent_range_pct' = '2m',
                   'buildings_1939_rent_range_pct' = '2n',
                   'buildings_rental_demand' = '2o',
                   'buildings_rental_trend' = '2p',
                   'buildings_constructed_past_yr' = '3',
                   'buildings_overhang_holc' = '4a',
                   'buildings_overhang_institutions' = '4b',
                   'buildings_sales_yrs' = '5',
                   'buildings_sales_holc' = '5a',
                   'buildings_sales_institutions' = '5b',
                   'mortgage_avial' = '6',
                   'tax_rate_yr' = '71',
                   'tax_rate_per_1000' = '72',
                   'area_description' = '8',
                   # 'area_terrain' = '1a',
                   # 'area_favorable_influences' = '1b',
                   # 'area_detrimental_influences' = '1c',
                   # 'area_pct_improved' = '1d',
                   # 'area_desirability_trend' = '1e',               
                   'name_location_grade_number' = '9',
                   'note' = '10') %>% 
            clean_names()
        # names(df_description_la) <- gsub(pattern = 'x', replacement = 'q_', x = names(df_description_la))
        
        # z <- bind_cols(df_description_la, df_geometry_la)
        # View(z)
        
        write_csv(x = df_description_la, 
                  file = here(output_directory, 
                              'HOLC_los-angeles_area-descriptions.csv'))
        # write_xlsx(x = df_description_la, 
        #            path = here(output_directory, 
        #                        'HOLC_los-angeles_area-descriptions.xlsx'))
    }   
    
    
    
    # Sacramento --------------------------------------------------------------
    ## Convert geojson to dataframe
    {
        geojson_sac <- (readLines(raw_holc_data_files %>% 
                                      filter(holc_city == 'Sacramento') %>% 
                                      pull(file_path)) %>% 
                            fromJSON())$features
        df_description_sac <- bind_cols(geojson_sac$properties %>% 
                                            select(-area_description_data), 
                                        geojson_sac$properties$area_description_data)
        # dput(sort(names(df_description_sac)))
        df_description_sac <- df_description_sac %>% 
            mutate(holc_city = 'Sacramento') %>% 
            select(c('holc_city', 
                     "0", "holc_id", "name", "holc_grade", 
                     "1a", "1b", "1c", "1d", "1e", 
                     "2a", "2b", "2c", "2d", "2e", "2f", "2g", 
                     "31", "32", "33", 
                     "3a", "3b", "3c", "3d", "3e", "3f", "3g", 
                     "3h", "3i", "3j", "3k", "3l", "3m", "3n", 
                     "3o", "3p", "3q", 
                     "4a", "4b", "5", "6"))
        # sort rows
        df_description_sac <- df_description_sac %>% 
            separate(col = holc_id, 
                     into = c('id_grade', 'id_numb'), 
                     sep = "(?<=[A-Z])(?=[0-9])", 
                     remove = FALSE) %>% 
            mutate(id_numb = as.numeric(id_numb)) %>% 
            arrange(id_grade, id_numb) %>% 
            select(-c('id_grade', 'id_numb')) %>% 
            rename('holc_region' = '0',
                   'area_terrain' = '1a',
                   'area_favorable_influences' = '1b',
                   'area_detrimental_influences' = '1c',
                   'area_pct_improved' = '1d',
                   'area_desirability_trend' = '1e',
                   'inhabitants_occupation' = '2a',
                   'inhabitants_income' = '2b',
                   'inhabitants_foreign_pct_predominating' = '2c',
                   'inhabitants_negro' = '2d',
                   'inhabitants_infiltration' = '2e',
                   'inhabitants_relief' = '2f',
                   'inhabitants_pop_trend' = '2g',
                   'buildings_predominating_pct' = '31',
                   'buildings_other1_pct' = '32',
                   'buildings_other2_pct' = '33',
                   'buildings_type' = '3a',
                   'buildings_construction' = '3b',
                   'buildings_avg_age' = '3c',
                   'buildings_repair' = '3d',
                   'buildings_occupancy_pct' = '3e',
                   'buildings_ownership_pct' = '3f',
                   'buildings_constructed_past_yr' = '3g',
                   'buildings_1929_price_range_pct' = '3h',
                   'buildings_1935_price_range_pct' = '3i',
                   'buildings_1938_price_range_pct' = '3j',
                   'buildings_sales_demand' = '3k',
                   'buildings_sales_activity' = '3l',
                   'buildings_1929_rent_range_pct' = '3m',
                   'buildings_1935_rent_range_pct' = '3n',
                   'buildings_1938_rent_range_pct' = '3o',
                   'buildings_rental_demand' = '3p',
                   'buildings_rental_activity' = '3q',
                   'mortgage_avial_home_purchase' = '4a',
                   'mortgage_avial_home_building' = '4b',
                   'clarifying_remarks' = '5',
                   'name_location_grade_number' = '6') %>% 
            clean_names()
        write_csv(x = df_description_sac, 
                  file = here(output_directory, 
                              'HOLC_sacramento_area-descriptions.csv'))
        # write_xlsx(x = df_description_sac, 
        #            path = here(output_directory, 
        #                        'HOLC_sacramento_area-descriptions.xlsx'))
    }  
    
    
    
    # Stockton ----------------------------------------------------------------
    ## Convert geojson to dataframe
    {
        geojson_stk <- (readLines(raw_holc_data_files %>% 
                                      filter(holc_city == 'Stockton') %>% 
                                      pull(file_path)) %>% 
                            fromJSON())$features
        df_description_stk <- bind_cols(geojson_stk$properties %>% 
                                            select(-area_description_data), 
                                        geojson_stk$properties$area_description_data)
        # dput(sort(names(df_properties_3)))
        df_description_stk <- df_description_stk %>% 
            mutate(holc_city = 'Stockton') %>% 
            select(c('holc_city', #"0", 
                     "holc_id", "name", "holc_grade", 
                     "1a", "1b", "1c", "1d", "1e", 
                     '2 ',
                     "2a", "2b", "2c", "2d", "2e", "2f", "2g", 
                     "31", "32", "33", 
                     "3a", "3b", "3c", "3d", "3e", "3f", "3g", 
                     "3h", "3i", "3j", "3k", "3l", "3m", "3n", 
                     "3o", "3p", "3q", 
                     "4a", "4b", "5", "6")) %>% 
            mutate('2b' = case_when(!is.na(`2 `) ~ `2 `,
                                    TRUE ~ `2b`)) %>% 
            select(-c(`2 `))
        # sort rows
        df_description_stk <- df_description_stk %>% 
            separate(col = holc_id, 
                     into = c('id_grade', 'id_numb'), 
                     sep = "(?<=[A-Z])(?=[0-9])", 
                     remove = FALSE) %>% 
            mutate(id_numb = as.numeric(id_numb)) %>% 
            arrange(id_grade, id_numb) %>% 
            select(-c('id_grade', 'id_numb')) %>% 
            rename(# 'holc_region' = '0',
                'area_terrain' = '1a',
                'area_favorable_influences' = '1b',
                'area_detrimental_influences' = '1c',
                'area_pct_improved' = '1d',
                'area_desirability_trend' = '1e',
                'inhabitants_occupation' = '2a',
                'inhabitants_income' = '2b',
                'inhabitants_foreign_pct_predominating' = '2c',
                'inhabitants_negro' = '2d',
                'inhabitants_infiltration' = '2e',
                'inhabitants_relief' = '2f',
                'inhabitants_pop_trend' = '2g',
                'buildings_predominating_pct' = '31',
                'buildings_other1_pct' = '32',
                'buildings_other2_pct' = '33',
                'buildings_type' = '3a',
                'buildings_construction' = '3b',
                'buildings_avg_age' = '3c',
                'buildings_repair' = '3d',
                'buildings_occupancy_pct' = '3e',
                'buildings_ownership_pct' = '3f',
                'buildings_constructed_past_yr' = '3g',
                'buildings_1929_price_range_pct' = '3h',
                'buildings_1936_price_range_pct' = '3i',
                'buildings_1938_price_range_pct' = '3j',
                'buildings_sales_demand' = '3k',
                'buildings_sales_activity' = '3l',
                'buildings_1929_rent_range_pct' = '3m',
                'buildings_1936_rent_range_pct' = '3n',
                'buildings_1938_rent_range_pct' = '3o',
                'buildings_rental_demand' = '3p',
                'buildings_rental_activity' = '3q',
                'mortgage_avial_home_purchase' = '4a',
                'mortgage_avial_home_building' = '4b',
                'clarifying_remarks' = '5',
                'name_location_grade_number' = '6') %>% 
            clean_names()
        write_csv(x = df_description_stk, 
                  file = here(output_directory, 
                              'HOLC_stockton_area-descriptions.csv'))
        # write_xlsx(x = df_description_stk, 
        #            path = here(output_directory, 
        #                        'HOLC_stockton_area-descriptions.xlsx'))    
    }
    
    
    
    # Oakland -----------------------------------------------------------------
    ## Convert geojson to dataframe
    {
        geojson_oak <- (readLines(raw_holc_data_files %>% 
                                      filter(holc_city == 'Oakland') %>% 
                                      pull(file_path)) %>% 
                            fromJSON())$features
        df_description_oak <- bind_cols(geojson_oak$properties %>% 
                                            select(-area_description_data), 
                                        geojson_oak$properties$area_description_data)
        df_description_oak <- df_description_oak[-1, ]
        # dput(sort(names(df_description_oak)))
        df_description_oak <- df_description_oak %>% 
            mutate(holc_city = 'Oakland') %>% 
            select(c('holc_city', #"0", 
                     "holc_id", "name", "holc_grade", 
                     '1', '2', '3', '4',
                     "5a", "5b", "5c", "5d", "5e", "5f", "5g", 
                     "6a", "6b", "6c", "6d",
                     '7',
                     "8a", "8b", "8c",
                     "9a", "9b", "9c",
                     "10a", "10b", "10c", 
                     "11a", "11b", 
                     "12a", "12b", 
                     "13", "14", "15"))
        # sort rows
        df_description_oak <- df_description_oak %>% 
            separate(col = holc_id, 
                     into = c('id_grade', 'id_numb'), 
                     sep = "(?<=[A-Z])(?=[0-9])", 
                     remove = FALSE) %>% 
            mutate(id_numb = as.numeric(id_numb)) %>% 
            arrange(id_grade, id_numb) %>% 
            select(-c('id_grade', 'id_numb')) %>% 
            rename(# 'holc_region' = '0',
                'name_location_grade_number' = '1',
                'area_terrain' = '2',
                'area_favorable_influences' = '3',
                'area_detrimental_influences' = '4',
                'inhabitants_occupation' = '5a',
                'inhabitants_income' = '5b',
                'inhabitants_foreign_pct_predominating' = '5c',
                'inhabitants_negro' = '5d',
                'inhabitants_infiltration' = '5e',
                'inhabitants_relief' = '5f',
                'inhabitants_pop_trend' = '5g',
                'buildings_type' = '6a',
                'buildings_construction' = '6b',
                'buildings_avg_age' = '6c',
                'buildings_repair' = '6d',
                'buildings_sale_rental_history' = '7',
                'area_pct_improved' = '8a',           
                'buildings_occupancy_pct' = '8b',
                'buildings_ownership_pct' = '8c',
                'buildings_sales_demand' = '9a',
                'buildings_sales_price_range' = '9b',
                'buildings_sales_activity' = '9c',
                'buildings_rental_demand' = '10a',
                'buildings_rental_price_range' = '10b',
                'buildings_rental_activity' = '10c',
                'buildings_constructed_past_yr_type_price' = '11a',
                'buildings_constructed_past_yr' = '11b',
                'mortgage_avial_home_purchase' = '12a',
                'mortgage_avial_home_building' = '12b',
                'area_desirability_trend' = '13',            
                'clarifying_remarks' = '14',
                'information_source' = '15'
            ) %>% 
            clean_names()
        write_csv(x = df_description_oak, 
                  file = here(output_directory, 
                              'HOLC_oakland_area-descriptions.csv'))
        # write_xlsx(x = df_description_oak, 
        #            path = here(output_directory, 
        #                        'HOLC_oakland_area-descriptions.xlsx'))    
    }   
    
    
    
    
    # San Jose ----------------------------------------------------------------
    ## Convert geojson to dataframe
    {
        geojson_sj <- (readLines(raw_holc_data_files %>% 
                                     filter(holc_city == 'SanJose') %>% 
                                     pull(file_path)) %>% 
                           fromJSON())$features
        df_description_sj <- bind_cols(geojson_sj$properties %>% 
                                           select(-area_description_data), 
                                       geojson_sj$properties$area_description_data)
        # dput(sort(names(df_description_sj)))
        df_description_sj <- df_description_sj %>% 
            mutate(holc_city = 'SanJose') %>% 
            select(c('holc_city', #"0", 
                     "holc_id", "name", "holc_grade", 
                     '1', '2', '3', '4',
                     "5a", "5b", "5c", "5d", "5e", "5f", "5g", 
                     "6a", "6b", "6c", "6d",
                     '7',
                     "8a", "8b", "8c",
                     "9a", "9b", "9c",
                     "10a", "10b", "10c", 
                     "11a", "11b", 
                     "12a", "12b", 
                     "13", "14", "15"))
        # sort rows
        df_description_sj <- df_description_sj %>% 
            separate(col = holc_id, 
                     into = c('id_grade', 'id_numb'), 
                     sep = "(?<=[A-Z])(?=[0-9])", 
                     remove = FALSE) %>% 
            mutate(id_numb = as.numeric(id_numb)) %>% 
            arrange(id_grade, id_numb) %>% 
            select(-c('id_grade', 'id_numb')) %>% 
            rename(# 'holc_region' = '0',
                'name_location_grade_number' = '1',
                'area_terrain' = '2',
                'area_favorable_influences' = '3',
                'area_detrimental_influences' = '4',
                'inhabitants_occupation' = '5a',
                'inhabitants_income' = '5b',
                'inhabitants_foreign_pct_predominating' = '5c',
                'inhabitants_negro' = '5d',
                'inhabitants_infiltration' = '5e',
                'inhabitants_relief' = '5f',
                'inhabitants_pop_trend' = '5g',
                'buildings_type' = '6a',
                'buildings_construction' = '6b',
                'buildings_avg_age' = '6c',
                'buildings_repair' = '6d',
                'buildings_sale_rental_history' = '7',
                'area_pct_improved' = '8a',           
                'buildings_occupancy_pct' = '8b',
                'buildings_ownership_pct' = '8c',
                'buildings_sales_demand' = '9a',
                'buildings_sales_price_range' = '9b',
                'buildings_sales_activity' = '9c',
                'buildings_rental_demand' = '10a',
                'buildings_rental_price_range' = '10b',
                'buildings_rental_activity' = '10c',
                'buildings_constructed_past_yr_type_price' = '11a',
                'buildings_constructed_past_yr' = '11b',
                'mortgage_avial_home_purchase' = '12a',
                'mortgage_avial_home_building' = '12b',
                'area_desirability_trend' = '13',            
                'clarifying_remarks' = '14',
                'information_source' = '15'
            ) %>% 
            clean_names()
        write_csv(x = df_description_sj, 
                  file = here(output_directory, 
                              'HOLC_san-jose_area-descriptions.csv'))
        # write_xlsx(x = df_description_sj, 
        #            path = here(output_directory, 
        #                        'HOLC_san-jose_area-descriptions.xlsx'))    
    }   
    
    
    
    # Combine -----------------------------------------------------------------
    df_description_combined <- bind_rows(df_description_sac, 
                                         df_description_stk, 
                                         df_description_oak, 
                                         df_description_sj, 
                                         df_description_la,
                                         df_description_fr,
                                         df_description_sf,
                                         df_description_sd)
    
    ## create a new column with area description excerpts (for use in the app 
    ## in the popup for each holc polygon)
    df_description_combined <- df_description_combined %>% 
        mutate(area_description_excerpts = case_when(
            holc_city %in% c('Fresno', 'SanFrancisco', 'SanDiego', 'LosAngeles') ~
                area_description,
            holc_city %in% c('Oakland', 'Sacramento', 'SanJose', 'Stockton') ~
                as.character(
                    glue('FAVORABLE INFLUENCES: {area_favorable_influences} | DETRIMENTAL INFLUENCES: {area_detrimental_influences} | CLARIFYING REMARKS: {clarifying_remarks}')
                ),
            TRUE ~ area_description
        ))
    
    
    
    # Save to file ------------------------------------------------------------
    write_csv(x = df_description_combined, 
              file = here(output_directory, 
                          '_HOLC_combined_area-descriptions.csv'))
    # write_xlsx(x = df_description_combined, 
    #            path = here(output_directory, 
    #                        '_HOLC_combined_area-descriptions.xlsx'))  
    
    
    
    # return processed dataset ------------------------------------------------
    return(df_description_combined)
    
}