# Unzip and bind "Project" files ----
projfile = "RePORTER_PRJ_C_FY"
destdir = "/Volumes/research_data/nihexporter/projects/"

source("scripts/00_load-packages.R")
source("scripts/read_exporter_proj.R")
source("scripts/parse_proj_dates.R")

allproj <- purrr::map(1985:2018, ~read_exporter_proj(fyr = .))

allproj <- map_df(seq_along(1985:2018), ~pluck(pluck(allproj, .), "data"))

datecols = c("award_notice_date", "budget_start", "budget_end", "project_start", "project_end")

# Parse dates
allproj %<>% mutate_at(vars(one_of(datecols)), list("parsed" = ~ datefun(.)))

# Replace original dates with parsed dates
allproj %>% 
  select(-all_of(datecols)) %>% 
  rename_at(paste0(datecols, "_parsed"), ~datecols)

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

duns_00_08 %<>% rename_all(str_to_lower)

# write_csv(duns_00_08,"/Volumes/Peach/nih_exporter/projects/supp_files/projsupp_duns.csv")

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

dunsfunds %<>% rename_all(str_to_lower) %>% rename(fiscal_year = fy)

# write_csv(dunsfunds,"/Volumes/Peach/nih_exporter/projects/supp_files/projsupp_dunsfunds.csv")

# Update Project files with supplementary files ----
# duns_00_08 = read_csv("/Volumes/Peach/nih_exporter/projects/supp_files/projsupp_duns.csv", 
#                       col_types = cols(.default = 'c'))
# dunsfunds = read_csv("/Volumes/Peach/nih_exporter/projects/supp_files/projsupp_dunsfunds.csv", 
#                      col_types = cols(.default = 'c', fiscal_year = 'i', 
#                                       total_cost = 'i', total_cost_sub_project = 'i'))

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
dunsfunds %<>% rename_at(updatecols, ~paste0(updatecols, '_update'))

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

updatefun <- function(newcol, oldcol){
  if_else(!is.na(newcol), newcol, oldcol)
}

allproj %<>% 
  mutate(funding_ics = updatefun(funding_ics_update, funding_ics), 
         org_duns = updatefun(org_duns_update, org_duns), 
         total_cost = updatefun(total_cost_update, total_cost), 
         total_cost_sub_project = updatefun(total_cost_sub_project_update, total_cost_sub_project))

# for (i in seq_along(updatecols)){
#   oldvar = updatecols[i]
#   newvar = paste0(oldvar, "_update")
#   print(oldvar)
#   allproj %<>% mutate(!!sym(oldvar) = updatefun(newcol = !!sym(newvar), oldcol = !!sym(oldvar)))
# }



allproj %<>% select(-ends_with('update'))

# Save data ----

write_csv(allproj, "/Volumes/research_data/nihexporter/projects/nih_exporter_projects.csv")

# allproj file is big, keep subset on local hard drive
# write_csv(allproj %>% filter(activity == "R01"),
#           "/Users/weiyangtham/Documents/WYT Projects/nih_exporter/projects/nih_exporter_projects_r01.csv")
