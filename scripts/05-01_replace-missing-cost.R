# For projects with missing cost amounts, retrieve cost 
# from RePORTER through API

library(tidyverse)
library(magrittr)
library(httr)
library(tictoc)

source("scripts/00_functions.R")

# Find all core projects with missing total cost ----
exporter <- fst::read_fst(here::here("data/nih_exporter_projects.fst")) %>% 
  as_tibble()

mainproj_missingcost <- exporter %>% filter(is.na(subproject_id), is.na(total_cost)) 

appids <- unique(mainproj_missingcost$application_id)

# Retrieve total cost for those projects from NIH RePORTER API ----

n <- length(appids)
step <- 400
v = seq_last(0, n, by = step)

# Ping API in batches of size `step` ----
message("Pinging API takes a while. Uncomment if want to do it")

appids_list = map(head(seq_along(v), -1), 
                  ~{a = v[.] + 1
                  b = v[. + 1] 
                  k = seq(a, b, by = 1)
                  appids_subset <- appids[k]
                  ask_reporter(appids_subset)
                  })

assertthat::assert_that(length(appids_list) == (length(v) - 1), 
                        msg = "Number of batches of records retrieved is correct")
appid_cost = map_df(appids_list, ~extract_reporter_variable(., "award_amount"))
appid_cost %<>% rename(total_cost = name)

write_rds(appid_cost, here::here("data/appid-totalcost-reporterapi.rds"))

# Link application IDs back to ExPORTER and update missing total cost entries ----

appid_cost = read_rds(here::here("data/appid-totalcost-reporterapi.rds"))
appid_cost %<>% rename(total_cost_api = total_cost)

k = nrow(exporter)
exporter = exporter %>% left_join(appid_cost, by = "application_id") 
assertthat::assert_that(k == nrow(exporter))

exporter %<>%
  mutate(total_cost_updated  = coalesce(total_cost, total_cost_api)) 

assertthat::assert_that(
  exporter %>% 
    filter(!is.na(total_cost), is.na(total_cost_updated)) %>% 
    nrow() == 0,
  msg = "If cost is not missing originally, then it should not be missing after updating"
)

updated_appids = appid_cost %>% filter(!is.na(total_cost_api)) %>% pull(application_id)

assertthat::assert_that(
  exporter %>% 
    filter(application_id %in% updated_appids, is.na(total_cost_api)) %>% 
    nrow() == 0, 
  msg = "Total cost missing for application ID that had non-missing total cost in RePORTER"
)

exporter %<>% select(-total_cost_api) 

fst::write_fst(exporter, "/Volumes/research_data/nihexporter/projects/nih_exporter_projects_apiupdate.fst")
fst::write_fst(exporter, here::here("data/nih_exporter_projects_apiupdate.fst"))
