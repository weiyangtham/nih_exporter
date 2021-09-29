# For projects with missing budget date, 
# retrieve date from RePORTER through API

library(tidyverse)
library(magrittr)
library(httr)
library(tictoc)

source("scripts/00_functions.R")

# Find all core projects with missing total cost ----
exporter <- fst::read_fst(here::here("data/nih_exporter_projects_apiupdate.fst")) %>% 
  as_tibble()

mainproj_missingdate <- exporter %>% filter(is.na(subproject_id), (is.na(budget_start) | is.na(budget_end))) 

appids <- unique(mainproj_missingdate$application_id)

# Retrieve RePORTER info for those projects from NIH RePORTER API ----

n <- length(appids)
step <- 400
v = seq_last(0, n, by = step)

# Ping API in batches of size `step` ----
message("Pinging API takes a while. Uncomment if want to do it")

# appids_list = map(head(seq_along(v), -1), 
#                   ~{a = v[.] + 1
#                   b = v[. + 1] 
#                   k = seq(a, b, by = 1)
#                   appids_subset <- appids[k]
#                   ask_reporter(appids_subset)
#                   })
# 
# assertthat::assert_that(length(appids_list) == (length(v) - 1), 
#                         msg = "Number of batches of records retrieved is correct")
# 
# appid_budgetstart = map_df(appids_list, ~extract_reporter_variable(., "budget_start"))
# appid_budgetstart %<>% rename(budget_start_api = name)
# 
# appid_budgetend = map_df(appids_list, ~extract_reporter_variable(., "budget_end"))
# appid_budgetend %<>% rename(budget_end_api = name)
# 
# write_rds(appid_budgetstart, here::here("data/appid-budgetstart-reporterapi.rds"))
# write_rds(appid_budgetend, here::here("data/appid-budgetend-reporterapi.rds"))

# Link application IDs back to ExPORTER and update missing total cost entries ----

appid_budgetstart = read_rds(here::here("data/appid-budgetstart-reporterapi.rds"))
appid_budgetend = read_rds(here::here("data/appid-budgetend-reporterapi.rds"))

k = nrow(exporter)
exporter = exporter %>% 
  left_join(appid_budgetstart, by = "application_id") %>% 
  left_join(appid_budgetend, by = "application_id") 
assertthat::assert_that(k == nrow(exporter))

exporter %<>%
  mutate(across(c(budget_start_api, budget_end_api), .fns = lubridate::as_date), 
         budget_start_updated  = coalesce(budget_start, budget_start_api), 
         budget_end_updated  = coalesce(budget_end, budget_end_api)) 

# Checks for budget_start ----
assertthat::assert_that(
  exporter %>% 
    filter(!is.na(budget_start), is.na(budget_start_updated)) %>% 
    nrow() == 0,
  msg = "If not missing originally, then it should not be missing after updating")

updated_appids = appid_budgetstart %>% filter(!is.na(budget_start_api)) %>% pull(application_id)

assertthat::assert_that(
  exporter %>% 
    filter(application_id %in% updated_appids, is.na(budget_start_api)) %>% 
    nrow() == 0, 
  msg = "missing for application ID that had non-missing in RePORTER")

# Checks for budget_end ----
assertthat::assert_that(
  exporter %>% 
    filter(!is.na(budget_end), is.na(budget_end_updated)) %>% 
    nrow() == 0,
  msg = "If not missing originally, then it should not be missing after updating")

updated_appids = appid_budgetend %>% filter(!is.na(budget_end_api)) %>% pull(application_id)

assertthat::assert_that(
  exporter %>% 
    filter(application_id %in% updated_appids, is.na(budget_end_api)) %>% 
    nrow() == 0, 
  msg = "missing for application ID that had non-missing in RePORTER")

exporter %<>% select(-c(budget_start, budget_end, budget_start_api, budget_end_api))
exporter %<>% rename(budget_start = budget_start_updated, 
                     budget_end = budget_end_updated)

fst::write_fst(exporter, "/Volumes/research_data/nihexporter/projects/nih_exporter_projects_apiupdate.fst")
fst::write_fst(exporter, here::here("data/nih_exporter_projects_apiupdate.fst"))
