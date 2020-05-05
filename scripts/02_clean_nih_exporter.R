library(tidyverse)
library(magrittr)
library(stringr)

# Unzip and bind "Project" files ----
projfile = "RePORTER_PRJ_C_FY"
destdir = "/Volumes/Peach/nih_exporter/projects/"

allproj = purrr::map_df(1985:2018, function(fyr){
  message("extract ", str_c(projfile, fyr, ".csv"), " from \n", str_c(destdir, projfile, fyr, ".zip"))
  if (fyr < 2012){
    readr::read_csv(unz(str_c(destdir, projfile, fyr, ".zip"), str_c(projfile, fyr, ".csv")),
                    col_types = cols(.default = 'c', FY = 'i', 
                                     TOTAL_COST = 'i', TOTAL_COST_SUB_PROJECT = 'i'),
                    n_max = Inf)
  } else {
    readr::read_csv(unz(str_c(destdir, projfile, fyr, ".zip"), str_c(projfile, fyr, ".csv")),
                    col_types = cols(.default = 'c', FY = 'i', 
                                     TOTAL_COST = 'i', TOTAL_COST_SUB_PROJECT = 'i',
                                     DIRECT_COST_AMT = 'i', INDIRECT_COST_AMT = 'i'),
                    n_max = Inf)
  }
})


projcols = colnames(allproj)

allproj %<>% 
  rename_(.dots = setNames(as.list(projcols), as.list(stringr::str_to_lower(projcols))))

datecols = c("award_notice_date", "budget_start", "budget_end", "project_start", "project_end")

# Parse dates
datefun = function(x){
  is_datetime = stringr::str_length(x) == 19
  x_datetime = if_else(is_datetime, x, NA_character_)
  x_date = if_else(!is_datetime, x, NA_character_)
  
  k1 = sum(is_datetime, na.rm = TRUE)
  k2 = sum(!is_datetime, na.rm = TRUE)
  
  nx = sum(!is.na(x), na.rm = TRUE)
  
  if (k1 + k2 != nx){stop('formats do not capture all non-missing values')}
  
  if (k1 > 0 & k2 > 0){
    message("mixture of dates and date-times")
    # mixture of dates and date-times
    x_parsed = if_else(is_datetime, lubridate::date(lubridate::ymd_hms(x_datetime)), lubridate::mdy(x_date))
  } else if (k1 == nx & k2 == 0){
    message("date-times only")
    # this is the all are date-time case
    x_parsed = lubridate::date(lubridate::ymd_hms(x_datetime))
  } else if (k1 == 0 & k2 == nx) {
    message("dates only")
    x_parsed = lubridate::mdy(x_date)
  }
  x_parsed
}

# x = c("1995-01-01T00:00:00", "1/1/1985")
# df = data_frame(d = x)
# 
# df %>% mutate(y = datefun(d))

allproj %<>% mutate_at(vars(one_of(datecols)), funs("parsed" = datefun(.)))

not_parsed = function(datecol){
  lazyeval::interp(~ !is.na(col1) & is.na(col2), 
                   col1 = as.name(datecol), col2 = as.name(str_c(datecol, "_parsed")))
}

kvec = 
  purrr::map_int(datecols, function(v) {
    k = allproj %>% filter_(not_parsed(v)) %>% nrow()
  })

if (sum(kvec) > 0L){
  datecols[kvec > 0]
  stop('date not parsed. Check the above columns')
}

# Replace date columns with parsed columns
allproj %<>% 
  select(-one_of(datecols)) %>% 
  rename_(.dots = setNames(as.list(str_c(datecols, "_parsed")), as.list(datecols))) %>% 
  rename(fiscal_year = fy)

rm(destdir)

# Unzip and bind supplementary files ----
destdir = "/Volumes/Peach/nih_exporter/projects/supp_files/"

projfile_duns_00_08 = "RePORTER_DUNS_C_FY"
duns_00_08 = purrr::map_df(2000:2008, function(fyr){
  message("extract ", 
          str_c(projfile_duns_00_08, fyr, ".csv"), " from \n", 
          str_c(destdir, projfile_duns_00_08, fyr, ".zip"))
  readr::read_csv(unz(str_c(destdir, projfile_duns_00_08, fyr, ".zip"), 
                      str_c(projfile_duns_00_08, fyr, ".csv")),
                  col_types = cols(.default = 'c'),
                  n_max = Inf)
})

dunscols = colnames(duns_00_08)
duns_00_08 %<>% 
  rename_(.dots = setNames(as.list(dunscols), as.list(stringr::str_to_lower(dunscols)))) 

write_csv(duns_00_08,"/Volumes/Peach/nih_exporter/projects/supp_files/projsupp_duns.csv")

# Supplementary DUNS and funding amounts from 1985 to 1999 ----

projfile_dunsfunds_85_99 = "RePORTER_PRJFUNDING_C_FY"

dunsfunds = purrr::map_df(1985:1999, function(fyr){
  message("extract ", 
          str_c(projfile_dunsfunds_85_99, fyr, ".csv"), " from \n", 
          str_c(destdir, projfile_dunsfunds_85_99, fyr, ".zip"))
  readr::read_csv(unz(str_c(destdir, projfile_dunsfunds_85_99, fyr, ".zip"), 
                      str_c(projfile_dunsfunds_85_99, fyr, ".csv")),
                  col_types = cols(.default = 'c', FY = 'i', 
                                   TOTAL_COST = 'i', TOTAL_COST_SUB_PROJECT = 'i'),
                  n_max = Inf)
})

dunsfundscols = colnames(dunsfunds)
dunsfunds %<>% 
  rename_(.dots = setNames(as.list(dunsfundscols), as.list(stringr::str_to_lower(dunsfundscols)))) %>% 
  rename(fiscal_year = fy)

write_csv(dunsfunds,"/Volumes/Peach/nih_exporter/projects/supp_files/projsupp_dunsfunds.csv")

# Update Project files with supplementary files ----
duns_00_08 = read_csv("/Volumes/Peach/nih_exporter/projects/supp_files/projsupp_duns.csv", 
                      col_types = cols(.default = 'c'))
dunsfunds = read_csv("/Volumes/Peach/nih_exporter/projects/supp_files/projsupp_dunsfunds.csv", 
                     col_types = cols(.default = 'c', fiscal_year = 'i', 
                                      total_cost = 'i', total_cost_sub_project = 'i'))

# Update DUNS numbers from 2000 to 2008
duns_00_08 %<>% rename(org_duns_update = org_duns)

k = nrow(allproj)
allproj %<>% 
  left_join(duns_00_08, by = "application_id")

if (k != nrow(allproj)){stop('too many obs after joining')}
rm(k)

allproj %<>% 
  mutate(org_duns = if_else(!is.na(org_duns_update), org_duns_update, org_duns)) %>% 
  select(-org_duns_update)

# Update DUNS and funding amounts from 1985 to 1999
updatecols = c('funding_ics', 'org_duns', 'total_cost', 'total_cost_sub_project')
dunsfunds %<>% 
  rename_(.dots = setNames(as.list(updatecols), as.list(str_c(updatecols, '_update'))))

k = nrow(allproj)
allproj %<>% 
  left_join(dunsfunds %>% select(one_of(c('application_id', str_c(updatecols, '_update')))), 
            by = 'application_id')

if (k != nrow(allproj)){stop('too many obs after joining')}
rm(k)

updatefun = function(updatecol){
  lazyeval::interp(~ if_else(!is.na(col2), col2, col1), 
                   col1 = as.name(updatecol), col2 = as.name(str_c(updatecol, "_update")))
}

for (i in seq_along(updatecols)){
  var = updatecols[i]
  print(var)
  allproj %<>% mutate_(.dots = setNames(list(updatefun(var)), var)) 
}

allproj %<>% select(-ends_with('update'))

write_csv(allproj, "/Volumes/Peach/nih_exporter/projects/nih_exporter_projects.csv")

# allproj file is big, keep subset on local hard drive
write_csv(allproj %>% filter(activity == "R01"),
          "/Users/weiyangtham/Documents/WYT Projects/nih_exporter/projects/nih_exporter_projects_r01.csv")
