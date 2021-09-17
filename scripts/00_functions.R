ask_reporter <- function(appids){
  url <- "https://api.reporter.nih.gov/v1/projects/Search"
  json_body <- jsonlite::toJSON(list(criteria = list(appl_ids = appids), limit = "500"), auto_unbox = TRUE)
  res <- POST(url, body=json_body, encode='raw', add_headers('Content-Type'='application/json'))
  results <- content(res)[[2]]
  
}

ask_reporter_for_cost = function(appids){
  ask_reporter(appids)
  map_df(results,
         ~tibble(application_id = if_else(is_null(.$appl_id), NA_integer_, .$appl_id),
                 total_cost = if_else(is_null(.$award_amount), NA_integer_, .$award_amount)))
}