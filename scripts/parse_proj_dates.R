# Parse dates, allowing for different formats
# x = c("1995-01-01T00:00:00", "1/1/1985")
# df = data_frame(d = x)
# 
# df %>% mutate(y = datefun(d))

datefun = function(x){
  is_datetime = stringr::str_length(x) == 19
  x_datetime = if_else(is_datetime, x, NA_character_) # vector of date-times only
  x_date = if_else(!is_datetime, x, NA_character_) # vector of dates only
  
  k1 = sum(is_datetime, na.rm = TRUE)
  k2 = sum(!is_datetime, na.rm = TRUE)
  
  nx = sum(!is.na(x), na.rm = TRUE) # number of non-missing values
  
  if (k1 + k2 != nx){stop('formats do not capture all non-missing values')}
  
  if (k1 > 0 & k2 > 0){
    message("mixture of dates and date-times")
    # mixture of dates and date-times
    x_parsed = case_when(is_datetime ~ lubridate::date(lubridate::ymd_hms(x_datetime)), 
                         !is_datetime & str_detect(x_date, "\\d{4}$") ~ lubridate::mdy(x_date), 
                         !is_datetime & str_detect(x_date, "^\\d{4}") ~ ymd(x_date))
    
  } else if (k1 == nx & k2 == 0){
    message("date-times only")
    # this is the all are date-time case
    x_parsed = lubridate::date(lubridate::ymd_hms(x_datetime))
    
  } else if (k1 == 0 & k2 == nx) {
    message("dates only")
    x_parsed = case_when(
      str_detect(x_date, "\\d{4}$") ~ mdy(x_date), 
      str_detect(x_date, "^\\d{4}") ~ ymd(x_date))
  }
  x_parsed
}


parse_proj_dates <- function(data, datecols = c("award_notice_date", "budget_start", "budget_end", "project_start", "project_end")){
  
  data <- data %>% 
    mutate_at(vars(one_of(datecols)), list("parsed" = ~ datefun(.))) 
  
  k <- data %>% 
    summarise_at(vars(one_of(c(datecols, paste0(datecols, "_parsed")))), ~sum(is.na(.))) %>% 
    gather(k, v) %>% 
    mutate(parsed = if_else(str_detect(k, "parsed"), "parsed", "notparsed"), 
           k = str_replace(k, "_parsed", "")) %>% 
    spread(parsed, v) %>% 
    filter(parsed != notparsed) %>% 
    nrow()
  
  assertthat::assert_that(assertthat::are_equal(k, 0), 
                          msg = "original date and parsed date have different number of missing values")
  
  data 
}
