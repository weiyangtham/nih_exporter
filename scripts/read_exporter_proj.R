
# Read in zipped ExPorter project files
read_exporter_proj <- function(fyr, projfile = "RePORTER_PRJ_C_FY", destdir = "/Volumes/research_data/nihexporter/projects/"){
  
  proj_filename <- str_c(projfile, fyr, ".csv")
  if(fyr %in% 2016:2019){
    proj_filename <- str_c(projfile, fyr, "_new", ".csv")
  }
  
  message("extract ", str_c(projfile, fyr, ".csv"), " from \n", str_c(destdir, proj_filename))
  
  # Direct/indirect costs appear from 2012 onwards
  if (fyr < 2012){
    df <- readr::read_csv(unz(str_c(destdir, projfile, fyr, ".zip"), proj_filename),
                    col_types = cols(.default = 'c', FY = 'i', 
                                     TOTAL_COST = 'i', TOTAL_COST_SUB_PROJECT = 'i'),
                    n_max = Inf)
  } else {
    df <- readr::read_csv(unz(str_c(destdir, projfile, fyr, ".zip"), proj_filename),
                    col_types = cols(.default = 'c', FY = 'i', 
                                     TOTAL_COST = 'i', TOTAL_COST_SUB_PROJECT = 'i',
                                     DIRECT_COST_AMT = 'i', INDIRECT_COST_AMT = 'i'),
                    n_max = Inf)
  }
  
  return(list(data = df %>% rename_all(str_to_lower), 
         problems = problems(df) %>% mutate(fy = fyr)))
}
