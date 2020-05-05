# Download publications


download_pubs = function(year, destdir, name_stem = "RePORTER_PUB_C_"){
  
  # https://exporter.nih.gov/CSVs/final/RePORTER_PUB_C_2013.zip
  
  for (i in year){
    
    file_url = paste0("https://exporter.nih.gov/CSVs/final/RePORTER_PUB_C_", 
                      i, ".zip")
    
    message(paste("Download from", file_url," \n to", 
                  paste0(destdir, "/", name_stem, i, ".zip")))
    
    
    download.file(url = file_url,
                  destfile = paste0(destdir, name_stem, i, ".zip"),
                  mode = "wb")
    
  }
  
}

# destdir =  "/Volumes/Peach/nih_exporter/projects/"
destdir = "downloaded_data/"
purrr::map(1980:2018, ~ download_pubs(., destdir = destdir))

# Supplementary files containing affiliations
destdir = "D:/nih_exporter/pubs/affils_supp"

download_pubaffil = function(year, destdir, name_stem = "RePORTER_AFFLNK_C_"){
  
  for (i in year){
    
    file_url = paste0("https://exporter.nih.gov/CSVs/final/RePORTER_AFFLNK_C_", 
                      i, ".zip")
    
    message(paste("Download from", file_url," \n to", 
                  paste0(destdir, "/", name_stem, i, ".zip")))
    
    
    download.file(url = file_url,
                  dest = paste0(destdir, "/", name_stem, i, ".zip"),
                  mode = "wb")
    
  }
}

purrr::map(2014:2017, ~ download_pubaffil(., destdir = destdir))

# Project-Pub crosswalks

destdir = "downloaded_data/pub_link"

download_publink = function(year, destdir, name_stem = "RePORTER_PUBLNK_C_"){
  
  for (i in year){
    
    file_url = paste0("https://exporter.nih.gov/CSVs/final/RePORTER_PUBLNK_C_", 
                      i, ".zip")
    
    message(paste("Download from", file_url," \n to", 
                  paste0(destdir, "/", name_stem, i, ".zip")))
    
    
    download.file(url = file_url,
                  dest = paste0(destdir, "/", name_stem, i, ".zip"),
                  mode = "wb")
    
  }
  
}

purrr::map(1980:2018, ~ download_publink(., destdir = destdir))



