ask_reporter <- function(appids){
  
  # If vector is only length 1, then need to make it a list for 
  # retrieval to work. But making a vector greater than length 1
  # a list doesn't work, so just leave it as a vector in that case
  if (length((appids)) == 1){
    appids = list(appids)
  }
  
  url <- "https://api.reporter.nih.gov/v2/projects/Search"
  json_body <- jsonlite::toJSON(list(criteria = list(appl_ids=appids), limit = "500"), auto_unbox = TRUE)
  res <- POST(url, body=json_body, encode='raw', add_headers('Content-Type'='application/json'))
  
  content(res)[[2]]
  
}

# Take in a list of results from pinging the RePORTER API
# and return the desired variable as a tibble
extract_reporter_variable = function(reporter_list, var){
  map_df(reporter_list,
         ~{value = pluck(., var)
         tibble(application_id = pluck(., "appl_id"),
                 total_cost = ifelse(is_null(value), NA, value))
         })
}

ask_reporter_for_cost = function(appids){
  results = ask_reporter(appids)
  map_df(results,
         ~tibble(application_id = if_else(is_null(.$appl_id), NA_integer_, .$appl_id),
                 total_cost = if_else(is_null(.$award_amount), NA_integer_, .$award_amount)))
}

# seq() function but including the last value if it is not 
# a multiple of `by` argument
seq_last = function(from, to, by){
  x = seq(from = from, to = to, by = by)
  
  # include last value in vector if it's not in there
  if(max(x) != to){
    x = c(x, to)
  }
  
  x}