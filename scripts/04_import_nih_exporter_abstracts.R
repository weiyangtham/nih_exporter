#' Import abstracts from NIH ExPorter (https://exporter.nih.gov/ExPORTER_Catalog.aspx?sid=0&index=1)

download_abstracts = function(fiscalyear, destdir, name_stem = "RePORTER_PRJABS_C_FY"){
  
  for (i in fiscalyear){
    
    file_url = paste0("https://exporter.nih.gov/CSVs/final/RePORTER_PRJABS_C_FY", 
                 i, ".zip")
    
    message(paste("Download from", file_url," \n to", 
                   paste0(destdir, "/", name_stem, i, ".zip")))
    

    download.file(url = file_url,
                  dest = paste0(destdir, "/", name_stem, i, ".zip"),
                  mode = "wb")
    
  }
  
}

download_abstracts(1985:2016, destdir = "/Volumes/research_data/nihexporter/abstracts/")
