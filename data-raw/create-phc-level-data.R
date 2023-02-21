#' create PHC level data
#' MV Evans, Feb 2023
#'
#' This script creates one data frame that has the incidence,
#' number of cases, and number of cases seeking healthcare for each
#' CSB. For CSBs that share a catchment (commune), the incidence and number
#' of cases are the same because they are at the commune level, and then the
#' number of cases per CSB are specific to that CSB.

# Load Data ##################################

#created in the `back-calculate-cases.R` script
caseCSB <- readRDS("data/for-app/cases-csb.rds")

#needed to create incidence and cases at the commune level
mal.data <- readRDS("data/raw/malaria-data.rds")

## ACTUALLY I THINKT THIS IS ALREADY ALL DONE IN ANOTHER SCRIPT #############

