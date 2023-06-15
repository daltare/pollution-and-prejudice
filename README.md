# README

<!-- README.md is generated from README.qmd - edit that file -->

# Pollution & Prejudice

NOTE: this is an update to the Redline Mapping project contained here:
<https://github.com/daltare/Redline-Mapping>

## Background

The purpose of this project is to analyze present-day environmental and
socioeconomic conditions in neighborhoods in California cities that were
assessed by the federal Home Owners’ Loan Corporation (HOLC) in the
1930s. As part of its assessment process, the HOLC produced maps that
are today commonly known as “Redlining” maps, which divided up selected
cities (generally those with a population greater than 40,000) into
neighborhoods, and assigned each of those neighborhoods a grade that
reflected its percieved credit worthiness, on a scale of A (Best)
through D (Hazardous). Those assessments often included explicit
references to both the racial makeup of a neighborhood’s population and
the environmental conditions in and around that neighborhood as
important factors in assigning each neighborhood’s grade.

Our goal is to analyze whether or not present-day pollution burdens, as
well as vulnerability to the effects of pollution (due to socioeconomic
conditions), tend to show any association with historical HOLC grade in
neighborhoods assessed by the HOLC in the 1930s. In other words, we are
exploring whether historical HOLC grade continues to be a possible
predictor of present-day environmental and socioeconomic conditions. We
also explore the present-day racial / ethnic makeup of those
neighborhoods, to assess whether racial disparities by HOLC grade tend
to persist today.

## Data Sources

The primary data sources used in this analysis are:

- [Mapping Inequality: Redlining in New Deal
  America](https://dsl.richmond.edu/panorama/redlining/#loc=6/36.37/-121.816)
  - provides the HOLC (or “Redlining”) maps, which are available to
    download in various formats
  - a version of the dataset processed for use in this analysis
    (including data for all 8 California urban areas assessed by the
    HOLC) is available to download at [this
    link](https://github.com/daltare/pollution-and-prejudice/raw/main/tar_data_processed/holc_data/redline_maps_processed.gpkg)
- [CalEnviroScreen
  4.0](https://oehha.ca.gov/calenviroscreen/report/calenviroscreen-40)
  - assesses relative pollution burden and vulnerability for each census
    tract in California, providing an overall score as well as scores
    for 21 specific indicators of pollution burden or population
    characteristics for each tract, available to access/download in
    various formats
  - a version of the dataset processed for use in this analysis (with
    cleaned / expanded field names, missing values encoded as `NA`, and
    revised geographic representation of census tracts - to fix
    inconsistent boundaries between tracts - based on simplified 2010
    TIGER data) is available to download at [this
    link](https://github.com/daltare/pollution-and-prejudice/raw/main/tar_data_processed/ces_data/calenviroscreen_4-0_processed_tiger_simple.gpkg)

## Analytical Process and Results

For an overview of the analytical process and results, see the
[summary_report.md](tar_reports/summary_report.md) document.

The primary results are available in the
`tar_data_results/redline_CES_scores.gpkg` file, which can be downloaded
using [this
link](https://github.com/daltare/pollution-and-prejudice/raw/main/tar_data_results/HOLC_CES_scores_demographics.gpkg).
This file includes estimated CalEnviroScreen 4.0 scores and estimated
population by racial / ethnic group for each neighborhood in the 1930s
HOLC maps. Note that the CES scores and demographics in this dataset are
estimates that are intended to be used for relative comparisons across
groups, and should be used with caution when looking at individual or
small numbers of neighborhoods in isolation.

## Reproducibility

### Workflow - {targets}

This project uses the [`targets`
package](https://docs.ropensci.org/targets/) for workflow management.
The entire workflow is defined and managed through the
[\_targets.R](_targets.R) file.

Run `targets::tar_make()` from the console to run the workflow and
reproduce all results. For some more pointers on using the `targets`
package, see the [targets_notes.md](targets_notes.md) file.

#### Targets workflow:

This figure provides a visualization of the workflow defined in the
[\_targets.R](_targets.R) file:

``` mermaid
graph LR
  subgraph legend
    direction LR
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x0a52b03877696646([""Outdated""]):::outdated
    x0a52b03877696646([""Outdated""]):::outdated --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    x723651d51c4d9039>"ggplot_box_legend"]:::uptodate --> x9fc5d9228e2f8c78>"f_plot_scores_box_departure_legend"]:::uptodate
    xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::outdated --> x7774e14ad1201765(["sf_combined_results"]):::outdated
    x722c080414fdf571(["df_holc_demographics_summary"]):::outdated --> x7774e14ad1201765(["sf_combined_results"]):::outdated
    xf90b49dd379c5312>"f_combine_computed_data"]:::uptodate --> x7774e14ad1201765(["sf_combined_results"]):::outdated
    xd358c84560a350ea(["sf_formatted_holc_data"]):::outdated --> x7774e14ad1201765(["sf_combined_results"]):::outdated
    x661c36f456260220>"f_plot_scores_points_average_by_grade"]:::uptodate --> x26888c3adf53b8ba(["plot_scores_points_average_by_grade"]):::outdated
    x7774e14ad1201765(["sf_combined_results"]):::outdated --> x26888c3adf53b8ba(["plot_scores_points_average_by_grade"]):::outdated
    xb84eb9d541120890>"f_compute_HOLC_CES_scores"]:::uptodate --> xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::outdated
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::outdated
    xd358c84560a350ea(["sf_formatted_holc_data"]):::outdated --> xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::outdated
    x05780902aff2e52e>"f_plot_scores_points_departure"]:::uptodate --> x85db2b90c235dab6(["plot_scores_points_departure"]):::outdated
    x7774e14ad1201765(["sf_combined_results"]):::outdated --> x85db2b90c235dab6(["plot_scores_points_departure"]):::outdated
    xd22b3ef3698af9c3>"f_plot_race_bars_by_group"]:::uptodate --> xe2341aac6be6d5c3(["plot_race_bars_by_group"]):::outdated
    x7774e14ad1201765(["sf_combined_results"]):::outdated --> xe2341aac6be6d5c3(["plot_race_bars_by_group"]):::outdated
    xcdcbc8327c73002a(["ces_scores_missing_check"]):::outdated --> xe24c603975ef95ce(["summary_report"]):::outdated
    xe2341aac6be6d5c3(["plot_race_bars_by_group"]):::outdated --> xe24c603975ef95ce(["summary_report"]):::outdated
    xd261dc6bb4fd422e(["plot_scores_box_departure_legend"]):::outdated --> xe24c603975ef95ce(["summary_report"]):::outdated
    x26888c3adf53b8ba(["plot_scores_points_average_by_grade"]):::outdated --> xe24c603975ef95ce(["summary_report"]):::outdated
    x85db2b90c235dab6(["plot_scores_points_departure"]):::outdated --> xe24c603975ef95ce(["summary_report"]):::outdated
    xd06bbe78c7eb9f6c(["plot_scores_points_raw"]):::outdated --> xe24c603975ef95ce(["summary_report"]):::outdated
    x7774e14ad1201765(["sf_combined_results"]):::outdated --> xe24c603975ef95ce(["summary_report"]):::outdated
    xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::outdated --> xcdcbc8327c73002a(["ces_scores_missing_check"]):::outdated
    x1909355c81c03a12>"f_check_missing_CES_scores"]:::uptodate --> xcdcbc8327c73002a(["ces_scores_missing_check"]):::outdated
    x6a4e5ab768f76050>"f_plot_scores_points_raw"]:::uptodate --> xd06bbe78c7eb9f6c(["plot_scores_points_raw"]):::outdated
    x7774e14ad1201765(["sf_combined_results"]):::outdated --> xd06bbe78c7eb9f6c(["plot_scores_points_raw"]):::outdated
    x4baab69ddc05606c>"f_compute_HOLC_demographics"]:::uptodate --> x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::outdated
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::outdated
    xd358c84560a350ea(["sf_formatted_holc_data"]):::outdated --> x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::outdated
    x3566400abf0582d0>"f_process_holc_data"]:::uptodate --> xd358c84560a350ea(["sf_formatted_holc_data"]):::outdated
    xc134b761ca90db6a(["holc_area_descriptions"]):::outdated --> xd358c84560a350ea(["sf_formatted_holc_data"]):::outdated
    x7deb259c829fdb2e(["raw_holc_data_files"]):::uptodate --> xd358c84560a350ea(["sf_formatted_holc_data"]):::outdated
    x13ecd6c730196e92>"f_plot_scores_box_departure"]:::uptodate --> xc0917568d2ce3bee(["plot_scores_box_departure"]):::outdated
    x7774e14ad1201765(["sf_combined_results"]):::outdated --> xc0917568d2ce3bee(["plot_scores_box_departure"]):::outdated
    xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::outdated --> xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::outdated
    x24483bb6f5885403>"f_summarize_HOLC_CES_scores"]:::uptodate --> xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::outdated
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::outdated
    x7ad41e3fd12f2676(["ces_names_file"]):::uptodate --> x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate
    xdca65f7684d779f0>"f_process_ces_data"]:::uptodate --> x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate
    x6538bfb2bd8fa5af(["raw_ces_data_file"]):::uptodate --> x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate
    x9fc5d9228e2f8c78>"f_plot_scores_box_departure_legend"]:::uptodate --> xd261dc6bb4fd422e(["plot_scores_box_departure_legend"]):::outdated
    x7774e14ad1201765(["sf_combined_results"]):::outdated --> xd261dc6bb4fd422e(["plot_scores_box_departure_legend"]):::outdated
    xf443f725966ed075{{"last_report_update"}}:::uptodate --> x3b5990520b2e818d(["summary_report_html"]):::uptodate
    xe7b24c87dabecd62>"f_parse_holc_descriptions"]:::uptodate --> xc134b761ca90db6a(["holc_area_descriptions"]):::outdated
    x7deb259c829fdb2e(["raw_holc_data_files"]):::uptodate --> xc134b761ca90db6a(["holc_area_descriptions"]):::outdated
    xc11e093e8a0331b6>"f_plot_map_panels"]:::uptodate --> x52b2d35838d1c908(["plot_map_panels"]):::outdated
    x7774e14ad1201765(["sf_combined_results"]):::outdated --> x52b2d35838d1c908(["plot_map_panels"]):::outdated
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> x52b2d35838d1c908(["plot_map_panels"]):::outdated
    xd358c84560a350ea(["sf_formatted_holc_data"]):::outdated --> x52b2d35838d1c908(["plot_map_panels"]):::outdated
    xc504145cdabdd854>"f_download_raw_ces_data"]:::uptodate --> x6538bfb2bd8fa5af(["raw_ces_data_file"]):::uptodate
    x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::outdated --> x722c080414fdf571(["df_holc_demographics_summary"]):::outdated
    x2dfdf1b5ee4ba094>"f_summarize_HOLC_demographics"]:::uptodate --> x722c080414fdf571(["df_holc_demographics_summary"]):::outdated
    xb84eb9d541120890>"f_compute_HOLC_CES_scores"]:::uptodate --> x03e01758e45bc154(["sf_holc_ces_scores_centroids"]):::outdated
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> x03e01758e45bc154(["sf_holc_ces_scores_centroids"]):::outdated
    xd358c84560a350ea(["sf_formatted_holc_data"]):::outdated --> x03e01758e45bc154(["sf_holc_ces_scores_centroids"]):::outdated
    x28598aa74e36431d>"f_download_raw_holc_data"]:::uptodate --> x7deb259c829fdb2e(["raw_holc_data_files"]):::uptodate
    x118ccf0169559b01(["readme_file"]):::outdated --> x118ccf0169559b01(["readme_file"]):::outdated
    xd244e8c357cc9580(["targets_notes_file"]):::uptodate --> xd244e8c357cc9580(["targets_notes_file"]):::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 59 stroke-width:0px;
  linkStyle 60 stroke-width:0px;
```

### Package Management - {renv}

This project uses
[`renv`](https://rstudio.github.io/renv/articles/renv.html) for package
management. When opening this project as an RStudio Project for the
first time, `renv` should automatically install itself and prompt you to
run `renv::restore()` to install all package dependencies.
