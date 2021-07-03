library(tidyverse)
library(magrittr)
library(httr)
library(tictoc)

exporter <- fst::read_fst("/Volumes/research_data/nihexporter/projects/nih_exporter_projects.fst") %>% 
  as_tibble()

mainproj_missingcost <- exporter %>% filter(is.na(subproject_id), is.na(total_cost)) 

appids <- mainproj_missingcost$application_id

ask_exporter <- function(appids){
  url <- "https://api.reporter.nih.gov/v1/projects/Search"
  json_body <- jsonlite::toJSON(list(criteria = list(appl_ids = appids), limit = "500"), auto_unbox = TRUE)
  res <- POST(url, body=json_body, encode='raw', add_headers('Content-Type'='application/json'))
  results <- content(res)[[2]]
  
  map_df(results, 
         ~tibble(application_id = if_else(is_null(.$appl_id), NA_integer_, .$appl_id), 
                 total_cost = if_else(is_null(.$award_amount), NA_integer_, .$award_amount)))
}

n <- length(appids)

step <- 400

tic()
appid_cost <- map_df(seq(0, n, by = step), 
       ~{k <- (1:step) + .
       appids_subset <- appids[k]
       appids_subset <- appids_subset[!is.na(appids_subset)]
       Sys.sleep(1.2)
       ask_exporter(appids_subset)})
toc()

write_rds(appid_cost, here::here("data/appid-totalcost-reporterapi.rds"))
