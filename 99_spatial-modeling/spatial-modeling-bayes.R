# https://connordonegan.github.io/geostan/articles/measuring-sa.html

# load packages -----------------------------------------------------------
library(tidyverse)
library(here)
library(sf)
# library(mapview)
library(spdep)
library(geostan)

sf::sf_use_s2(FALSE)

# get data (CES scores by HOLC neighborhood) ---------------------------
holc_ces_scores <- st_read(here('03-1_output_data', 'HOLC_CES_scores_demographics.gpkg'))
# mapview(results, zcol = 'calenviroscreen_4_0_score') | mapview(results, zcol = 'holc_grade')


sp_diag(holc_ces_scores$calenviroscreen_4_0_score, holc_ces_scores, name = "CES 4.0 Score")
