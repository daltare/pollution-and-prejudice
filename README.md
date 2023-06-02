# README

<!-- README.md is generated from README.qmd. Please edit that file -->

# Pollution & Prejudice

## Reproducibility

This project uses the [`targets`
package](https://docs.ropensci.org/targets/) for workflow management.
Run `targets::tar_make()` from the console to run the workflow and
reproduce all results. You can inspect results of each step with
`tar_read()` or `tar_load()`.

**Targets workflow:**

``` mermaid
graph LR
  subgraph legend
    direction LR
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x0a52b03877696646([""Outdated""]):::outdated
    x0a52b03877696646([""Outdated""]):::outdated --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- xf0bce276fe2b9d3e>""Function""]:::none
  end
  subgraph Graph
    direction LR
    x723651d51c4d9039>"ggplot_box_legend"]:::uptodate --> x9fc5d9228e2f8c78>"f_plot_scores_box_departure_legend"]:::uptodate
    xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::uptodate --> x7774e14ad1201765(["sf_combined_results"]):::uptodate
    x722c080414fdf571(["df_holc_demographics_summary"]):::uptodate --> x7774e14ad1201765(["sf_combined_results"]):::uptodate
    xf90b49dd379c5312>"f_combine_computed_data"]:::uptodate --> x7774e14ad1201765(["sf_combined_results"]):::uptodate
    xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate --> x7774e14ad1201765(["sf_combined_results"]):::uptodate
    x661c36f456260220>"f_plot_scores_points_average_by_grade"]:::uptodate --> x26888c3adf53b8ba(["plot_scores_points_average_by_grade"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> x26888c3adf53b8ba(["plot_scores_points_average_by_grade"]):::uptodate
    xb84eb9d541120890>"f_compute_HOLC_CES_scores"]:::uptodate --> xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate
    xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate --> xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate
    x05780902aff2e52e>"f_plot_scores_points_departure"]:::uptodate --> x85db2b90c235dab6(["plot_scores_points_departure"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> x85db2b90c235dab6(["plot_scores_points_departure"]):::uptodate
    xd22b3ef3698af9c3>"f_plot_race_bars_by_group"]:::uptodate --> xe2341aac6be6d5c3(["plot_race_bars_by_group"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> xe2341aac6be6d5c3(["plot_race_bars_by_group"]):::uptodate
    xd261dc6bb4fd422e(["plot_scores_box_departure_legend"]):::uptodate --> xe24c603975ef95ce(["summary_report"]):::uptodate
    xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate --> xcdcbc8327c73002a(["ces_scores_missing_check"]):::uptodate
    x1909355c81c03a12>"f_check_missing_CES_scores"]:::uptodate --> xcdcbc8327c73002a(["ces_scores_missing_check"]):::uptodate
    x6a4e5ab768f76050>"f_plot_scores_points_raw"]:::uptodate --> xd06bbe78c7eb9f6c(["plot_scores_points_raw"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> xd06bbe78c7eb9f6c(["plot_scores_points_raw"]):::uptodate
    x4baab69ddc05606c>"f_compute_HOLC_demographics"]:::uptodate --> x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::uptodate
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::uptodate
    xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate --> x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::uptodate
    x3566400abf0582d0>"f_process_holc_data"]:::uptodate --> xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate
    x7deb259c829fdb2e(["raw_holc_data_files"]):::uptodate --> xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate
    x13ecd6c730196e92>"f_plot_scores_box_departure"]:::uptodate --> xc0917568d2ce3bee(["plot_scores_box_departure"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> xc0917568d2ce3bee(["plot_scores_box_departure"]):::uptodate
    xf2cacda6c5be1d56(["df_holc_ces_scores_calculations"]):::uptodate --> xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::uptodate
    x24483bb6f5885403>"f_summarize_HOLC_CES_scores"]:::uptodate --> xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::uptodate
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> xbc38fdbb09f54cdc(["df_holc_ces_scores_summary"]):::uptodate
    x7ad41e3fd12f2676(["ces_names_file"]):::uptodate --> x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate
    xdca65f7684d779f0>"f_process_ces_data"]:::uptodate --> x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate
    x6538bfb2bd8fa5af(["raw_ces_data_file"]):::uptodate --> x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate
    x9fc5d9228e2f8c78>"f_plot_scores_box_departure_legend"]:::uptodate --> xd261dc6bb4fd422e(["plot_scores_box_departure_legend"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> xd261dc6bb4fd422e(["plot_scores_box_departure_legend"]):::uptodate
    xc11e093e8a0331b6>"f_plot_map_panels"]:::uptodate --> x52b2d35838d1c908(["plot_map_panels"]):::uptodate
    x7774e14ad1201765(["sf_combined_results"]):::uptodate --> x52b2d35838d1c908(["plot_map_panels"]):::uptodate
    x66ea1e7e4088616e(["sf_formatted_ces_data"]):::uptodate --> x52b2d35838d1c908(["plot_map_panels"]):::uptodate
    xd358c84560a350ea(["sf_formatted_holc_data"]):::uptodate --> x52b2d35838d1c908(["plot_map_panels"]):::uptodate
    xc504145cdabdd854>"f_download_raw_ces_data"]:::uptodate --> x6538bfb2bd8fa5af(["raw_ces_data_file"]):::uptodate
    x0933fedf1eaed55e(["df_holc_demographics_calculations"]):::uptodate --> x722c080414fdf571(["df_holc_demographics_summary"]):::uptodate
    x2dfdf1b5ee4ba094>"f_summarize_HOLC_demographics"]:::uptodate --> x722c080414fdf571(["df_holc_demographics_summary"]):::uptodate
    x28598aa74e36431d>"f_download_raw_holc_data"]:::uptodate --> x7deb259c829fdb2e(["raw_holc_data_files"]):::uptodate
    x118ccf0169559b01(["readme_file"]):::outdated --> x118ccf0169559b01(["readme_file"]):::outdated
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 45 stroke-width:0px;
```
