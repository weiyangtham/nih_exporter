#' Download publications


download_pubs = function(fiscalyear, destdir, name_stem = "RePORTER_PUB_C_FY"){
  
  # https://exporter.nih.gov/CSVs/final/RePORTER_PUB_C_2013.zip
  
  for (i in fiscalyear){
    
    file_url = paste0("https://exporter.nih.gov/CSVs/final/RePORTER_PUB_C_FY", 
                      i, ".zip")
    
    message(paste("Download from", file_url," \n to", 
                  paste0(destdir, "/", name_stem, i, ".zip")))
    
    
    download.file(url = file_url,
                  dest = paste0(destdir, "/", name_stem, i, ".zip"),
                  mode = "wb")
    
  }
  
}
