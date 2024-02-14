# .Rprofile

source("renv/activate.R")

# conflicts
conflicted::conflict_prefer(name = 'filter', winner = 'dplyr', quiet = TRUE)
conflicted::conflict_prefer(name = 'select', winner = 'dplyr', quiet = TRUE)
conflicted::conflict_prefer(name = 'zip', winner = 'zip', quiet = TRUE)

# turn off scientific notation
options(scipen = 999) 

# open _targets.R file by default
setHook("rstudio.sessionInit", function(newSession) {
  if (newSession)
    rstudioapi::navigateToFile('_targets.R', line = -1L, column = -1L)
}, action = "append")

# load here package
suppressPackageStartupMessages(library(here))
