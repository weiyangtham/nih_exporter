# Download NIH exporter data
# URL used for download is in this FAQ 
# ("What does bulk RePORTER data include for ExPORTER files?")

# "FY 1985-1999 Updated funding and DUNS information" data downloaded by 
# clicking on the link at https://reporter.nih.gov/exporter

source("scripts/00_load-packages.R")

projfile = "RePORTER_PRJ_C_FY"

csvlink = "https://reporter.nih.gov/exporter/projects/download/"

destdir = here::here("downloaded_data/2024/projects/")

# Download Project files ----

# "Projects" files
emptylist = purrr::map(1985:2023, 
           function(fyr) {
             message(str_c("Downloading from ", csvlink, projfile, fyr), 
                     " \n to ", str_c(destdir, projfile, fyr, ".zip"))
             download.file(url = str_c(csvlink, fyr),
                           dest = str_c(destdir, projfile, fyr, ".zip"),
                           mode = "wb")
             })
rm(emptylist)

# number of files downloaded is same as number of years
assertthat::assert_that(
  length(list.files(here::here("downloaded_data/2024/projects/"))) == 
                      length(1985:2023))

# # Supplementary files ----
# 
# # DUNS files from 2000 to 2008
# projfile_duns_00_08 = "RePORTER_DUNS_C_FY"
# destdir = "/Volumes/Peach/nih_exporter/projects/supp_files/"
# 
# emptylist = purrr::map(2000:2008, 
#                        function(fyr) {
#                          message(str_c("Downloading from ", csvlink, projfile_duns_00_08, fyr, ".zip"), 
#                                  " \n to ", str_c(destdir, projfile_duns_00_08, fyr, ".zip"))
#                          download.file(url = str_c(csvlink, projfile_duns_00_08, fyr, ".zip"),
#                                        dest = str_c(destdir, projfile_duns_00_08, fyr, ".zip"),
#                                        mode = "wb")
#                        })
# rm(emptylist, destir)
# 
# # Supplementary files for DUNS and funding from 1985 to 1999
# projfile_dunsfunds_85_99 = "RePORTER_PRJFUNDING_C_FY"
# destdir = "/Volumes/Peach/nih_exporter/projects/supp_files/"
# 
# emptylist = purrr::map(1985:1999, 
#                        function(fyr) {
#                          message(str_c("Downloading from ", csvlink, projfile_dunsfunds_85_99, fyr, ".zip"), 
#                                  " \n to ", str_c(destdir, projfile_dunsfunds_85_99, fyr, ".zip"))
#                          download.file(url = str_c(csvlink, projfile_dunsfunds_85_99, fyr, ".zip"),
#                                        dest = str_c(destdir, projfile_dunsfunds_85_99, fyr, ".zip"),
#                                        mode = "wb")
#                        })
# rm(emptylist, destdir)

# allproj file is big, keep subset on local hard drive
# write_csv(allproj %>% filter(activity == "R01"),
#           "/Users/weiyangtham/Documents/WYT Projects/nih_exporter/projects/nih_exporter_projects_r01.csv")

