# Pollution & Prejudice - Data Analysis Summary

<!-- summary_report.md is generated from summary_report.qmd - edit that file -->

## Background

Placeholder text.

### Intent / Purpose

- Analyze present-day pollution burden / vulnerability in neighborhoods
  that were assessed in the 1930s HOLC maps in California cities, and
  analyze trends by HOLC grade (to see if HOLC grade is a possible
  predictor of present day environmental conditions)

- Assess present-day demographics of neighborhoods assessed in the 1930s
  HOLC maps in California cities, and assess whether the distribution of
  racial / ethnic groups differs by HOLC grade (to see if those areas
  are still segregated by HOLC grade today)

### Data Sources

- CalEnviroScreen (includes 2019 5-year ACS data)
- HOLC (Redline) Maps

## Process Overview

Estimate CES scores and present-day racial / ethnic makeup for each
neighborhood in the 1930s HOLC maps in California, using an area
weighted average of CES scores / demographic data for census tracts that
overlap each HOLC neighborhood

[Figure 1](#fig-map-process) illustrates the process for estimating CES
Scores.

- Panel 1 (left) shows the HOLC neighborhoods and their respective HOLC
  grades
- Panel 2 shows the outline of the HOLC neighborhoods, overlaid on top
  of the CalEnviroScreen scores (by census tract)
- Panel 3 shows the intersection of the HOLC neighborhoods and the
  CalEnviroScreen scores
- Panel 4 (right) shows the estimated / computed CalEnviroScreen score
  for each HOLC neighborhood, based on an area weighted average of the
  CalEnviroScreen scores for the census tracts that overlap with each
  HOLC neighborhood

<img src="../tar_plots/01_map-combined_Stockton.png"
id="fig-map-process" alt="Figure 1: Process Map" />

## Results - CalEnviroScreen Scores

### Raw Scores

[Figure 2](#fig-scores-raw) shows the estimated CES score for each
neighborhood in the 1930s HOLC maps.

<img src="summary_report_files/figure-commonmark/fig-scores-raw-1.png"
id="fig-scores-raw"
alt="Figure 2: Estimated CES scores for each neighborhood in the HOLC maps in California." />

### Average Scores by HOLC Grade

[Figure 3](#fig-scores-avg-by-grade) shows the average of the estimated
CES scores for each HOLC grade (A through D) within each city.

<img
src="summary_report_files/figure-commonmark/fig-scores-avg-by-grade-1.png"
id="fig-scores-avg-by-grade"
alt="Figure 3: Average estimated CES scores for each HOLC grade within each city." />

### Adjusted (Departure) Scores

[Figure 4](#fig-scores-departure) shows how we standardize the scores to
allow for comparisons across cities.

- Calculate a “departure” score for each HOLC neighborhood, which is the
  difference between (1) the estimated CES score for that neighborhood
  and (2) the average of the estimated CES scores for all HOLC
  neighborhoods in that same city.
- Essentially, this centers the average estimated CES score for all
  cities at zero, and makes comparisons across cities possible
  (otherwise, regional differences in the factors that CES measures
  would overwhelm any differences between HOLC grades)
- A positive departure score means the CES score for that HOLC
  neighborhood is above the average for its city, whereas a negative
  score means the CES score is below the average for its city.

<img
src="summary_report_files/figure-commonmark/fig-scores-departure-1.png"
id="fig-scores-departure"
alt="Figure 4: Estimated CES departure scores." />

### Adjusted (Departure) Scores - Boxplot

[Figure 5](#fig-boxplot) shows a boxplot of the departure scores, which
helps to illustrate the scale of the differences in estimated CES scores
between the HOLC grades.

<img src="summary_report_files/figure-commonmark/fig-boxplot-1.png"
id="fig-boxplot"
alt="Figure 5: Boxplot of estimated CES departure scores by HOLC grade." />

## Results - Demographics

[Figure 6](#fig-demographics-race) shows the estimated present-day
distribution of racial/ethnic groups across HOLC grades (for the
population living within neighborhoods in California cities that were
included in the 1930s HOLC maps).

<img
src="summary_report_files/figure-commonmark/fig-demographics-race-1.png"
id="fig-demographics-race"
alt="Figure 6: Estimated present-day distribution of racial/ethnic groups across HOLC grades." />

## Missing Scores

Some census tracts are not assigned a score for individual CES 4.0
indicators or an overall CES 4.0 score. In cases where these census
tracts overlap with HOLC neighborhoods, we use a minimum threshold…

There are 3 HOLC neighborhoods with missing CES 4.0 scores. The table
below provides a summary of the number of HOLC neighborhoods with
missing CES scores by CES measure and HOLC grade.

``` r
sf_combined_results <- targets::tar_read(sf_combined_results,
                  store = here::here(tar_config_get('store'))) # allows for manual rendering

holc_grade_counts <- sf_combined_results %>% 
    st_drop_geometry() %>% 
    count(holc_grade, name = 'n_total')

missing_summary_all <- ces_scores_missing_check %>% 
    group_by(ces_measure, holc_grade) %>% 
    summarize(n_missing = sum(n_missing)) %>% 
    left_join(holc_grade_counts) %>% 
    mutate(pct_missing = n_missing / n_total * 100) %>% 
    mutate(pct_missing = format(round(x = pct_missing, 
                                      digits = 2), 
                                nsmall = 2)) %>%
    mutate(pct_missing = paste0(as.character(pct_missing), '%'))
```

    `summarise()` has grouped output by 'ces_measure'. You can override using the
    `.groups` argument.
    Joining with `by = join_by(holc_grade)`

``` r
missing_summary_all
```

    # A tibble: 25 × 5
    # Groups:   ces_measure [12]
       ces_measure                holc_grade n_missing n_total pct_missing
       <chr>                      <chr>          <int>   <int> <chr>      
     1 calenviroscreen_4_0_score  B                  1     273 0.37%      
     2 calenviroscreen_4_0_score  C                  2     331 0.60%      
     3 drinking_water_score       B                  1     273 0.37%      
     4 education_score            B                  1     273 0.37%      
     5 education_score            C                  1     331 0.30%      
     6 housing_burden_score       B                  1     273 0.37%      
     7 housing_burden_score       C                  2     331 0.60%      
     8 lead_score                 B                  1     273 0.37%      
     9 lead_score                 C                  2     331 0.60%      
    10 linguistic_isolation_score B                  5     273 1.83%      
    # ℹ 15 more rows

## Comparison of Alternative Methods

To test the sensitivity of the computed CES scores to the analysis
method, we tried an alternative method and compared the results to the
area weighted average method.
