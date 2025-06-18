# Get data from saved rds object

download_latest_datastore <- function() {
  source("R/latest_url.R")
  
  latest_url_list <- latest_url()
  
  latest_datastore <-  read_csv(latest_url_list$url, locale = readr::locale(encoding = "Windows-1252"))
  
  saveRDS(latest_datastore,
          file = paste0("Data/", latest_url_list$date, "_datastore.rds"))
  
  return(latest_datastore)
}
