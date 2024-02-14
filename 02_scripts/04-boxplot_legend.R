# create boxplot legend
# from: https://waterdata.usgs.gov/blog/boxplots/

ggplot_box_legend <- function(family = NULL, 
                              transparent = FALSE, 
                              outer_point = TRUE, 
                              error_bar = TRUE) {
    library(ggplot2)
    
    # Create data to use in the boxplot legend:
    set.seed(100)
    
    sample_df <- data.frame(parameter = "test",
                            values = sample(500))
    
    # Extend the top whisker a bit:
    sample_df$values[1:100] <- 701:800
    # sample_df$values[1:100] <- sample(100) + 500
    
    # Make sure there's only 1 lower outlier:
    if (outer_point == TRUE) {
        sample_df$values[1] <- -350   
    }
    
    # Function to calculate important values:
    ggplot2_boxplot <- function(x){
        
        quartiles <- as.numeric(quantile(x,
                                         probs = c(0.25, 0.5, 0.75)))
        
        names(quartiles) <- c("25th percentile",
                              "50th percentile\n(median)",
                              "75th percentile")
        
        IQR <- diff(quartiles[c(1,3)])
        
        upper_whisker <- max(x[x < (quartiles[3] + 1.5 * IQR)])
        lower_whisker <- min(x[x > (quartiles[1] - 1.5 * IQR)])
        
        upper_dots <- x[x > (quartiles[3] + 1.5*IQR)]
        lower_dots <- x[x < (quartiles[1] - 1.5*IQR)]
        
        return(list("quartiles" = quartiles,
                    "25th percentile" = as.numeric(quartiles[1]),
                    "50th percentile\n(median)" = as.numeric(quartiles[2]),
                    "75th percentile" = as.numeric(quartiles[3]),
                    "IQR" = IQR,
                    "upper_whisker" = upper_whisker,
                    "lower_whisker" = lower_whisker,
                    "upper_dots" = upper_dots,
                    "lower_dots" = lower_dots))
    }
    
    # Get those values:
    ggplot_output <- ggplot2_boxplot(sample_df$values)
    
    # Lots of text in the legend, make it smaller and consistent font:
    update_geom_defaults("text",
                         list(size = 3,
                              hjust = 0,
                              family = family))
    # Labels don't inherit text:
    update_geom_defaults("label",
                         list(size = 3,
                              hjust = 0,
                              family = family))
    
    # Create the legend:
    # The main elements of the plot (the boxplot, error bars, and count)
    # are the easy part.
    # The text describing each of those takes a lot of fiddling to
    # get the location and style just right:
    explain_plot <- ggplot() +
        geom_boxplot(data = sample_df,
                     aes(x = parameter, y=values), 
                     width = 0.3, fill = "lightgrey") +
        # ADDED - use this to add some extra points
        # geom_jitter(data = sample_df %>% 
        #                 # slice(-(1:100)) %>% 
        #                 sample_n(15),
        #             aes(x = parameter, y=values),
        #             color = 'black', 
        #             size = 1.5, 
        #             alpha = 0.5, 
        #             width = 0.1) +
        # geom_text(aes(x = 1, y = 950, label = "500"), hjust = 0.5) +
        geom_text(aes(x = 1, y = 900, 
                      label = 'Boxplot Explanation'),
                  # hjust = 0.5,
                  fontface = "bold", 
                  size = 5) + 
        # geom_text(aes(x = 1.17, y = 950,
        #               label = "Number of values"),
        #           fontface = "bold", vjust = 0.4) +
        theme_minimal(base_size = 5, base_family = family) +
        geom_segment(aes(x = 2.3, xend = 2.3,
                         y = ggplot_output[["25th percentile"]],
                         yend = ggplot_output[["75th percentile"]])) +
        # geom_segment(aes(x = 1.2, xend = 2.3, # original: x = 1.2
        #                  y = ggplot_output[["25th percentile"]],
        #                  yend = ggplot_output[["25th percentile"]])) +
        # geom_segment(aes(x = 1.2, xend = 2.3, # original: x = 1.2
        #                  y = ggplot_output[["75th percentile"]],
        #                  yend = ggplot_output[["75th percentile"]])) +
        geom_text(aes(x = 2.4, y = ggplot_output[["50th percentile\n(median)"]]),
                  label = "Interquartile\nrange", fontface = "bold",
                  vjust = 0.4) +
        geom_text(aes(x = c(1.17,1.17),
                      y = c(ggplot_output[["upper_whisker"]],
                            ggplot_output[["lower_whisker"]]),
                      label = c("Largest value within 1.5 times\ninterquartile range above\n75th percentile",
                                "Smallest value within 1.5 times\ninterquartile range below\n25th percentile")),
                  fontface = "bold", vjust = 0.9) +
        # geom_text(aes(x = 1.17,
        #               y = ggplot_output[["lower_dots"]],
        #               label = "<3 times the interquartile range\nbeyond either end of the box"),
        #           vjust = 1.5) +
        # geom_label(aes(x = 1.17, y = ggplot_output[["quartiles"]],
        #                label = names(ggplot_output[["quartiles"]])),
        #            # vjust = c(0.4,0.85,0.4),
        #            vjust = c(0.4,0.5,0.4),
        #            fill = "white",
        #            # fill = 'transparent',
        #            label.size = 0) +
        ylab("") + xlab("") +
        theme(axis.text = element_blank(),
              axis.ticks = element_blank(),
              panel.grid = element_blank(),
              aspect.ratio = 4/3,
              plot.title = element_text(hjust = 0.5, size = 10)) +
        # coord_cartesian(xlim = c(1.4,3.1), ylim = c(-600, 900)) +
        # labs(title = 'Boxplot Explanation') +
        NULL
    
    if (outer_point == TRUE) {
        explain_plot <- explain_plot + 
            geom_text(aes(x = c(1.17),
                          y =  ggplot_output[["lower_dots"]],
                          label = "Outside value"),
                      vjust = 0.5, fontface = "bold") +
            geom_text(aes(x = c(1.9),
                          y =  ggplot_output[["lower_dots"]],
                          label = "Value is > 1.5 times the \ninterquartile range beyond \neither end of the box"),
                      vjust = 0.5) + 
            coord_cartesian(xlim = c(1.4,3.1), ylim = c(-600, 900))
    } else {
        explain_plot <- explain_plot + 
            coord_cartesian(xlim = c(1.4,3.1), ylim = c(-100, 900))
    }
    
    if (error_bar == TRUE) {
        explain_plot <- explain_plot + 
            stat_boxplot(data = sample_df,
                         aes(x = parameter, y=values),
                         geom ='errorbar', width = 0.1)
    }
    
    if (transparent == FALSE) {
        explain_plot <- explain_plot + 
            geom_segment(aes(x = 1.2, xend = 2.3, # original: x = 1.2
                             y = ggplot_output[["25th percentile"]],
                             yend = ggplot_output[["25th percentile"]])) +
            geom_segment(aes(x = 1.2, xend = 2.3, # original: x = 1.2
                             y = ggplot_output[["75th percentile"]],
                             yend = ggplot_output[["75th percentile"]])) +
            geom_label(aes(x = 1.17, y = ggplot_output[["quartiles"]],
                       label = names(ggplot_output[["quartiles"]])),
                   vjust = c(0.4,0.5,0.4),
                   fill = "white",
                   label.size = 0)
    } else {
        explain_plot <- explain_plot + 
            geom_segment(aes(x = 1.9, xend = 2.3, # original: x = 1.2
                             y = ggplot_output[["25th percentile"]],
                             yend = ggplot_output[["25th percentile"]])) +
            geom_segment(aes(x = 1.9, xend = 2.3, # original: x = 1.2
                             y = ggplot_output[["75th percentile"]],
                             yend = ggplot_output[["75th percentile"]])) +
            geom_label(aes(x = 1.17, y = ggplot_output[["quartiles"]],
                           label = names(ggplot_output[["quartiles"]])),
                       vjust = c(0.4,0.85,0.4),
                       fill = 'transparent',
                       label.size = 0)
    }
    
    return(explain_plot)
    
}

# ggplot_box_legend(transparent = TRUE, outer_point = FALSE, error_bar = TRUE)

