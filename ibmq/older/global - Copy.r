rm(list = setdiff(ls(), lsf.str()))

options(shiny.sanitize.errors = FALSE)

library(htmltools)
library(htmlwidgets)
library(shiny)
library(shinyalert)
library(shinyBS)
library(shinyjs)
library(shinyWidgets)
library(highcharter)
#library(envnames)

token.UC <- 'e7b72db6919022a00d9a75557392311954b58280de131c451c9939ccb701b69a6d0d63e3fb912f086723d8cdcaf45c7f710d4c3ab1930c4df1a13768ad476202'

load_data <- function() {
  Sys.sleep(0.1)
  hide("loading_page")
  show("main_content")
}

