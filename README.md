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
    x716156bac81cd62e(["df_holc_ces_scores_comparison"]):::uptodate --> xe4dc7810b8261f38(["plot_scores_method_comparison_scatter_facet"]):::uptodate
    x3b0727f79ff18b40>"f_plot_scores_method_comparison_scatter_facet"]:::uptodate --> xe4dc7810b8261f38(["plot_scores_method_comparison_scatter_facet"]):::uptodate
    xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate --> x716156bac81cd62e(["df_holc_ces_scores_comparison"]):::uptodate
    x1362e4f419a24a87>"f_combine_HOLC_CES_score_methods"]:::uptodate --> x716156bac81cd62e(["df_holc_ces_scores_comparison"]):::uptodate
    x03e01758e45bc154(["sf_holc_ces_scores_centroids"]):::uptodate --> x716156bac81cd62e(["df_holc_ces_scores_comparison"]):::uptodate
    xc504145cdabdd854>"f_download_raw_ces_data"]:::uptodate --> x6538bfb2bd8fa5af(["raw_ces_data_file"]):::uptodate
    xc11e093e8a0331b6>"f_plot_map_panels"]:::uptodate --> x52b2d35838d1c908(["plot_map_panels"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> x52b2d35838d1c908(["plot_map_panels"]):::uptodate
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> x52b2d35838d1c908(["plot_map_panels"]):::uptodate
    xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate --> x52b2d35838d1c908(["plot_map_panels"]):::uptodate
    xd22b3ef3698af9c3>"f_plot_race_bars_by_group"]:::uptodate --> xe2341aac6be6d5c3(["plot_race_bars_by_group"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> xe2341aac6be6d5c3(["plot_race_bars_by_group"]):::uptodate
    x661c36f456260220>"f_plot_scores_points_average_by_grade"]:::uptodate --> x26888c3adf53b8ba(["plot_scores_points_average_by_grade"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> x26888c3adf53b8ba(["plot_scores_points_average_by_grade"]):::uptodate
    xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::uptodate --> x7774e14ad1201765(["sf_combined_results"]):::uptodate
    x722c080414fdf571(["df_holc_demographics_summary"]):::uptodate --> x7774e14ad1201765(["sf_combined_results"]):::uptodate
    xf90b49dd379c5312>"f_combine_computed_data"]:::uptodate --> x7774e14ad1201765(["sf_combined_results"]):::uptodate
    xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate --> x7774e14ad1201765(["sf_combined_results"]):::uptodate
    xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate --> xcdcbc8327c73002a(["ces_scores_missing_check"]):::uptodate
    x1909355c81c03a12>"f_check_missing_CES_scores"]:::uptodate --> xcdcbc8327c73002a(["ces_scores_missing_check"]):::uptodate
    xb8f0b2810f342081(["ces_coverage_threshold"]):::uptodate --> xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate
    xb84eb9d541120890>"f_compute_HOLC_CES_scores"]:::uptodate --> xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate
    xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate --> xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate
    x28598aa74e36431d>"f_download_raw_holc_data"]:::uptodate --> x7deb259c829fdb2e(["raw_holc_data_files"]):::uptodate
    x3566400abf0582d0>"f_process_holc_data"]:::uptodate --> xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate
    xc134b761ca90db6a(["holc_area_descriptions"]):::uptodate --> xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate
    x7deb259c829fdb2e(["raw_holc_data_files"]):::uptodate --> xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate
    x6a4e5ab768f76050>"f_plot_scores_points_raw"]:::uptodate --> xd06bbe78c7eb9f6c(["plot_scores_points_raw"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> xd06bbe78c7eb9f6c(["plot_scores_points_raw"]):::uptodate
    xb8f0b2810f342081(["ces_coverage_threshold"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    xcdcbc8327c73002a(["ces_scores_missing_check"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    xe2341aac6be6d5c3(["plot_race_bars_by_group"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    xd261dc6bb4fd422e(["plot_scores_box_departure_legend"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    x30558efb09c7936d(["plot_scores_method_comparison_scatter"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    xe4dc7810b8261f38(["plot_scores_method_comparison_scatter_facet"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    x26888c3adf53b8ba(["plot_scores_points_average_by_grade"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    x85db2b90c235dab6(["plot_scores_points_departure"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    xd06bbe78c7eb9f6c(["plot_scores_points_raw"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    x05780902aff2e52e>"f_plot_scores_points_departure"]:::uptodate --> x85db2b90c235dab6(["plot_scores_points_departure"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> x85db2b90c235dab6(["plot_scores_points_departure"]):::uptodate
    xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate --> xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::uptodate
    x24483bb6f5885403>"f_summarize_HOLC_CES_scores"]:::uptodate --> xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::uptodate
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::uptodate
    x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::uptodate --> x722c080414fdf571(["df_holc_demographics_summary"]):::uptodate
    x2dfdf1b5ee4ba094>"f_summarize_HOLC_demographics"]:::uptodate --> x722c080414fdf571(["df_holc_demographics_summary"]):::uptodate
    xe7b24c87dabecd62>"f_parse_holc_descriptions"]:::uptodate --> xc134b761ca90db6a(["holc_area_descriptions"]):::uptodate
    x7deb259c829fdb2e(["raw_holc_data_files"]):::uptodate --> xc134b761ca90db6a(["holc_area_descriptions"]):::uptodate
    x7ad41e3fd12f2676(["ces_names_file"]):::uptodate --> x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate
    xdca65f7684d779f0>"f_process_ces_data"]:::uptodate --> x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate
    x6538bfb2bd8fa5af(["raw_ces_data_file"]):::uptodate --> x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate
    x716156bac81cd62e(["df_holc_ces_scores_comparison"]):::uptodate --> x30558efb09c7936d(["plot_scores_method_comparison_scatter"]):::uptodate
    xfded34a4d23e9e5d>"f_plot_scores_method_comparison_scatter"]:::uptodate --> x30558efb09c7936d(["plot_scores_method_comparison_scatter"]):::uptodate
    x4baab69ddc05606c>"f_compute_HOLC_demographics"]:::uptodate --> x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::uptodate
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::uptodate
    xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate --> x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::uptodate
    x9fc5d9228e2f8c78>"f_plot_scores_box_departure_legend"]:::uptodate --> xd261dc6bb4fd422e(["plot_scores_box_departure_legend"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> xd261dc6bb4fd422e(["plot_scores_box_departure_legend"]):::uptodate
    x13ecd6c730196e92>"f_plot_scores_box_departure"]:::uptodate --> xc0917568d2ce3bee(["plot_scores_box_departure"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> xc0917568d2ce3bee(["plot_scores_box_departure"]):::uptodate
    x716156bac81cd62e(["df_holc_ces_scores_comparison"]):::uptodate --> xdf491333e4fb171a(["holc_ces_score_methods_correlation"]):::uptodate
    x9f27f4335306e40c>"f_HOLC_CES_score_methods_correlation"]:::uptodate --> xdf491333e4fb171a(["holc_ces_score_methods_correlation"]):::uptodate
    xcda122252060630c>"f_compute_HOLC_CES_scores_centroids"]:::uptodate --> x03e01758e45bc154(["sf_holc_ces_scores_centroids"]):::uptodate
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> x03e01758e45bc154(["sf_holc_ces_scores_centroids"]):::uptodate
    xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate --> x03e01758e45bc154(["sf_holc_ces_scores_centroids"]):::uptodate
    xf443f725966ed075{{"last_report_update"}}:::uptodate --> x3b5990520b2e818d(["summary_report_html"]):::uptodate
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
  linkStyle 73 stroke-width:0px;
  linkStyle 74 stroke-width:0px;
```

### Package Management - {renv}

This project uses
[`renv`](https://rstudio.github.io/renv/articles/renv.html) for package
management. When opening this project as an RStudio Project for the
first time, `renv` should automatically install itself and prompt you to
run `renv::restore()` to install all package dependencies.
