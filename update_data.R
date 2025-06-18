# This script will be automated in Github actions to check daily for a new datastore file
# available on the Care Inspectorate's website. If available it will then download the 
# latest datastore version and save it as an RDS file to the /Data directory


# Date of latest locally saved datastore ----------------------------------
# Find most recent modified file for latest downloaded datastore:
modified_filenames <- file.info(list.files("Data", full.names = T))

# Locate filename of object most recently modified and adding to object
latest_local_datastore <- rownames(modified_filenames)[which.max(modified_filenames$mtime)]

# Extract date from rds string
latest_local_datastore_date <- sub("Data/(.*)_datastore.rds", "\\1", latest_local_datastore)


# Find the latest published datastore date --------------------------------
source("R/latest_url.R")

latest_online_datastore_date <- as.character(latest_url()$date)

# Download latest datastore if dates don't match --------------------------
# Source the function to download and save latest datastore object if dates don't match
source("R/download_latest_datastore.R")
source("R/append_to_inspection_history.R")

if(latest_local_datastore_date != latest_online_datastore_date){
  
  # Download latest datastore and assing to object to update time series
  new_datastore <- download_latest_datastore()
  
  # Append to the inspection series object to continue time series
  append_to_inspection_history(new_datastore)
  
} else {NULL}


