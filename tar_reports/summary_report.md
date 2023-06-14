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
missing_summary_all %>% 
    gt()
```

<div id="qckxfzqluk" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#qckxfzqluk table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#qckxfzqluk thead, #qckxfzqluk tbody, #qckxfzqluk tfoot, #qckxfzqluk tr, #qckxfzqluk td, #qckxfzqluk th {
  border-style: none;
}
&#10;#qckxfzqluk p {
  margin: 0;
  padding: 0;
}
&#10;#qckxfzqluk .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#qckxfzqluk .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#qckxfzqluk .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#qckxfzqluk .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#qckxfzqluk .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#qckxfzqluk .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#qckxfzqluk .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#qckxfzqluk .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#qckxfzqluk .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#qckxfzqluk .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#qckxfzqluk .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#qckxfzqluk .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#qckxfzqluk .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#qckxfzqluk .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#qckxfzqluk .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#qckxfzqluk .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#qckxfzqluk .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#qckxfzqluk .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#qckxfzqluk .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#qckxfzqluk .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#qckxfzqluk .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#qckxfzqluk .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#qckxfzqluk .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#qckxfzqluk .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#qckxfzqluk .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#qckxfzqluk .gt_left {
  text-align: left;
}
&#10;#qckxfzqluk .gt_center {
  text-align: center;
}
&#10;#qckxfzqluk .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#qckxfzqluk .gt_font_normal {
  font-weight: normal;
}
&#10;#qckxfzqluk .gt_font_bold {
  font-weight: bold;
}
&#10;#qckxfzqluk .gt_font_italic {
  font-style: italic;
}
&#10;#qckxfzqluk .gt_super {
  font-size: 65%;
}
&#10;#qckxfzqluk .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#qckxfzqluk .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#qckxfzqluk .gt_indent_1 {
  text-indent: 5px;
}
&#10;#qckxfzqluk .gt_indent_2 {
  text-indent: 10px;
}
&#10;#qckxfzqluk .gt_indent_3 {
  text-indent: 15px;
}
&#10;#qckxfzqluk .gt_indent_4 {
  text-indent: 20px;
}
&#10;#qckxfzqluk .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    &#10;    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="holc_grade">holc_grade</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n_missing">n_missing</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n_total">n_total</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="pct_missing">pct_missing</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="calenviroscreen_4_0_score">calenviroscreen_4_0_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="calenviroscreen_4_0_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="calenviroscreen_4_0_score  n_missing" class="gt_row gt_right">1</td>
<td headers="calenviroscreen_4_0_score  n_total" class="gt_row gt_right">273</td>
<td headers="calenviroscreen_4_0_score  pct_missing" class="gt_row gt_right">0.37%</td></tr>
    <tr><td headers="calenviroscreen_4_0_score  holc_grade" class="gt_row gt_left">C</td>
<td headers="calenviroscreen_4_0_score  n_missing" class="gt_row gt_right">2</td>
<td headers="calenviroscreen_4_0_score  n_total" class="gt_row gt_right">331</td>
<td headers="calenviroscreen_4_0_score  pct_missing" class="gt_row gt_right">0.60%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="drinking_water_score">drinking_water_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="drinking_water_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="drinking_water_score  n_missing" class="gt_row gt_right">1</td>
<td headers="drinking_water_score  n_total" class="gt_row gt_right">273</td>
<td headers="drinking_water_score  pct_missing" class="gt_row gt_right">0.37%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="education_score">education_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="education_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="education_score  n_missing" class="gt_row gt_right">1</td>
<td headers="education_score  n_total" class="gt_row gt_right">273</td>
<td headers="education_score  pct_missing" class="gt_row gt_right">0.37%</td></tr>
    <tr><td headers="education_score  holc_grade" class="gt_row gt_left">C</td>
<td headers="education_score  n_missing" class="gt_row gt_right">1</td>
<td headers="education_score  n_total" class="gt_row gt_right">331</td>
<td headers="education_score  pct_missing" class="gt_row gt_right">0.30%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="housing_burden_score">housing_burden_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="housing_burden_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="housing_burden_score  n_missing" class="gt_row gt_right">1</td>
<td headers="housing_burden_score  n_total" class="gt_row gt_right">273</td>
<td headers="housing_burden_score  pct_missing" class="gt_row gt_right">0.37%</td></tr>
    <tr><td headers="housing_burden_score  holc_grade" class="gt_row gt_left">C</td>
<td headers="housing_burden_score  n_missing" class="gt_row gt_right">2</td>
<td headers="housing_burden_score  n_total" class="gt_row gt_right">331</td>
<td headers="housing_burden_score  pct_missing" class="gt_row gt_right">0.60%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="lead_score">lead_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="lead_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="lead_score  n_missing" class="gt_row gt_right">1</td>
<td headers="lead_score  n_total" class="gt_row gt_right">273</td>
<td headers="lead_score  pct_missing" class="gt_row gt_right">0.37%</td></tr>
    <tr><td headers="lead_score  holc_grade" class="gt_row gt_left">C</td>
<td headers="lead_score  n_missing" class="gt_row gt_right">2</td>
<td headers="lead_score  n_total" class="gt_row gt_right">331</td>
<td headers="lead_score  pct_missing" class="gt_row gt_right">0.60%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="linguistic_isolation_score">linguistic_isolation_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="linguistic_isolation_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="linguistic_isolation_score  n_missing" class="gt_row gt_right">5</td>
<td headers="linguistic_isolation_score  n_total" class="gt_row gt_right">273</td>
<td headers="linguistic_isolation_score  pct_missing" class="gt_row gt_right">1.83%</td></tr>
    <tr><td headers="linguistic_isolation_score  holc_grade" class="gt_row gt_left">C</td>
<td headers="linguistic_isolation_score  n_missing" class="gt_row gt_right">14</td>
<td headers="linguistic_isolation_score  n_total" class="gt_row gt_right">331</td>
<td headers="linguistic_isolation_score  pct_missing" class="gt_row gt_right">4.23%</td></tr>
    <tr><td headers="linguistic_isolation_score  holc_grade" class="gt_row gt_left">D</td>
<td headers="linguistic_isolation_score  n_missing" class="gt_row gt_right">1</td>
<td headers="linguistic_isolation_score  n_total" class="gt_row gt_right">155</td>
<td headers="linguistic_isolation_score  pct_missing" class="gt_row gt_right">0.65%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="low_birth_weight_score">low_birth_weight_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="low_birth_weight_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="low_birth_weight_score  n_missing" class="gt_row gt_right">1</td>
<td headers="low_birth_weight_score  n_total" class="gt_row gt_right">273</td>
<td headers="low_birth_weight_score  pct_missing" class="gt_row gt_right">0.37%</td></tr>
    <tr><td headers="low_birth_weight_score  holc_grade" class="gt_row gt_left">C</td>
<td headers="low_birth_weight_score  n_missing" class="gt_row gt_right">3</td>
<td headers="low_birth_weight_score  n_total" class="gt_row gt_right">331</td>
<td headers="low_birth_weight_score  pct_missing" class="gt_row gt_right">0.91%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="population_characteristics_group_score">population_characteristics_group_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="population_characteristics_group_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="population_characteristics_group_score  n_missing" class="gt_row gt_right">1</td>
<td headers="population_characteristics_group_score  n_total" class="gt_row gt_right">273</td>
<td headers="population_characteristics_group_score  pct_missing" class="gt_row gt_right">0.37%</td></tr>
    <tr><td headers="population_characteristics_group_score  holc_grade" class="gt_row gt_left">C</td>
<td headers="population_characteristics_group_score  n_missing" class="gt_row gt_right">2</td>
<td headers="population_characteristics_group_score  n_total" class="gt_row gt_right">331</td>
<td headers="population_characteristics_group_score  pct_missing" class="gt_row gt_right">0.60%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="population_characteristics_group_score_scaled">population_characteristics_group_score_scaled</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="population_characteristics_group_score_scaled  holc_grade" class="gt_row gt_left">B</td>
<td headers="population_characteristics_group_score_scaled  n_missing" class="gt_row gt_right">1</td>
<td headers="population_characteristics_group_score_scaled  n_total" class="gt_row gt_right">273</td>
<td headers="population_characteristics_group_score_scaled  pct_missing" class="gt_row gt_right">0.37%</td></tr>
    <tr><td headers="population_characteristics_group_score_scaled  holc_grade" class="gt_row gt_left">C</td>
<td headers="population_characteristics_group_score_scaled  n_missing" class="gt_row gt_right">2</td>
<td headers="population_characteristics_group_score_scaled  n_total" class="gt_row gt_right">331</td>
<td headers="population_characteristics_group_score_scaled  pct_missing" class="gt_row gt_right">0.60%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="poverty_score">poverty_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="poverty_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="poverty_score  n_missing" class="gt_row gt_right">1</td>
<td headers="poverty_score  n_total" class="gt_row gt_right">273</td>
<td headers="poverty_score  pct_missing" class="gt_row gt_right">0.37%</td></tr>
    <tr><td headers="poverty_score  holc_grade" class="gt_row gt_left">C</td>
<td headers="poverty_score  n_missing" class="gt_row gt_right">1</td>
<td headers="poverty_score  n_total" class="gt_row gt_right">331</td>
<td headers="poverty_score  pct_missing" class="gt_row gt_right">0.30%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="traffic_score">traffic_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="traffic_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="traffic_score  n_missing" class="gt_row gt_right">1</td>
<td headers="traffic_score  n_total" class="gt_row gt_right">273</td>
<td headers="traffic_score  pct_missing" class="gt_row gt_right">0.37%</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="4" class="gt_group_heading" scope="colgroup" id="unemployment_score">unemployment_score</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="unemployment_score  holc_grade" class="gt_row gt_left">A</td>
<td headers="unemployment_score  n_missing" class="gt_row gt_right">3</td>
<td headers="unemployment_score  n_total" class="gt_row gt_right">109</td>
<td headers="unemployment_score  pct_missing" class="gt_row gt_right">2.75%</td></tr>
    <tr><td headers="unemployment_score  holc_grade" class="gt_row gt_left">B</td>
<td headers="unemployment_score  n_missing" class="gt_row gt_right">8</td>
<td headers="unemployment_score  n_total" class="gt_row gt_right">273</td>
<td headers="unemployment_score  pct_missing" class="gt_row gt_right">2.93%</td></tr>
    <tr><td headers="unemployment_score  holc_grade" class="gt_row gt_left">C</td>
<td headers="unemployment_score  n_missing" class="gt_row gt_right">7</td>
<td headers="unemployment_score  n_total" class="gt_row gt_right">331</td>
<td headers="unemployment_score  pct_missing" class="gt_row gt_right">2.11%</td></tr>
    <tr><td headers="unemployment_score  holc_grade" class="gt_row gt_left">D</td>
<td headers="unemployment_score  n_missing" class="gt_row gt_right">1</td>
<td headers="unemployment_score  n_total" class="gt_row gt_right">155</td>
<td headers="unemployment_score  pct_missing" class="gt_row gt_right">0.65%</td></tr>
  </tbody>
  &#10;  
</table>
</div>

## Comparison of Alternative Methods

To test the sensitivity of the computed CES scores to the analysis
method, we tried an alternative method and compared the results to the
area weighted average method.
