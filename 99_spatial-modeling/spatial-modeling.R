

# load packages -----------------------------------------------------------
library(tidyverse)
library(here)
library(sf)
# library(mapview)
library(spdep)

sf::sf_use_s2(FALSE)

# get data (CES scores by HOLC neighborhood) ---------------------------
holc_ces_scores <- st_read(here('03-1_output_data', 'HOLC_CES_scores_demographics.gpkg'))
# mapview(results, zcol = 'calenviroscreen_4_0_score') | mapview(results, zcol = 'holc_grade')



# spatial neighborhoods ---------------------------------------------------
## see: https://walker-data.com/census-r/spatial-analysis-with-us-census-data.html#understanding-spatial-neighborhoods

## contiguity neighbors ----
## see: https://r-spatial.github.io/spdep/articles/nb.html#creating-contiguity-neighbours
neighbors <- holc_ces_scores %>% poly2nb(queen = TRUE) # queens cases means polygons that share at least one vertex
summary(neighbors)
holc_coords <- holc_ces_scores %>%
    st_centroid() %>%
    st_coordinates()

## distance based neighbors ----
## see: https://r-spatial.github.io/spdep/articles/nb.html#distance-based-neighbours
neighbors_knn_4 <- holc_coords %>% 
    knearneigh(k = 4) %>% 
    knn2nb()


### visualize - Sacramento
city_plot <- 'Sacramento'
neighbors_city <- holc_ces_scores %>% 
    filter(holc_city == city_plot) %>%
    poly2nb(queen = TRUE, # queens cases means polygons that share at least one vertex
            snap = 0) 
# summary(neighbors_city)
holc_coords_city <- holc_ces_scores %>%
    filter(holc_city == city_plot) %>% 
    st_centroid() %>%
    st_coordinates()
scores_city <- holc_ces_scores %>% 
    filter(holc_city == city_plot)

plot(scores_city$geom, col = 'grey')
plot(neighbors_city, 
     coords = holc_coords_city, 
     add = TRUE, 
     col = "blue", 
     points = FALSE)

#### add snapping 
neighbors_city_2 <- holc_ces_scores %>% 
    filter(holc_city == city_plot) %>%
    poly2nb(queen = TRUE, # queens cases means polygons that share at least one vertex
            snap = 400) 
summary(neighbors_city_2)
plot(neighbors_city_2, 
     coords = holc_coords_city, 
     add = TRUE, 
     col = "red", 
     points = FALSE)

### distance based neighbors
neighbors_city_knn_4 <- holc_coords_city %>% 
    knearneigh(k = 4) %>% 
    knn2nb()
plot(scores_city$geom, col = 'grey')
plot(neighbors_city_knn_4, 
     coords = holc_coords_city, 
     add = TRUE, 
     col = "blue", 
     points = FALSE)



# spatial weights matrix --------------------------------------------------
# see: https://walker-data.com/census-r/spatial-analysis-with-us-census-data.html#generating-the-spatial-weights-matrix
weights <- nb2listw(neighbors_knn_4, style = "W")
# weights$weights[[1]]



# measures of auto-correlation --------------------------------------------
holc_ces_scores$lag_estimate <- lag.listw(weights, holc_ces_scores$calenviroscreen_4_0_score)

