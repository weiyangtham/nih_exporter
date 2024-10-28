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

dunsfunds %<>% rename_all(str_to_lower) %>% rename(fiscal_year = fy)

write_csv(dunsfunds,"/Volumes/Peach/nih_exporter/projects/supp_files/projsupp_dunsfunds.csv")