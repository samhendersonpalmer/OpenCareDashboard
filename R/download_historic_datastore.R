# Compiling archive of historic datastore files ---------------------------

# Source code for retrieving all datastore URLs
source("R/all_urls.R")

# Pull just URL column
historic_datastore_urls <- all_urls()

# Download each csv and save as RDS in Data folder
mapply(function(URL, upload_date) {
  # Read each csv and encode text
  datastore <- read_csv(URL, locale = readr::locale(encoding = "Windows-1252"))
  
  # save as RDS file for compression and preserve column types
  saveRDS(datastore, file = paste0("Data/", upload_date, "_datastore.rds"))
},
historic_datastore_urls$URL,
historic_datastore_urls$upload_date)

# Need to make the following have first rows as headers due to added line in CSV file:
# 2017-07-31 
# 2017-08-31 
# 2017-09-30 

# step 1: Copy 1st row to header
names(`2017-07-31_datastore`) <- `2017-07-31_datastore`[1,]

# step 2: Delete 1st row
`2017-07-31_datastore` <- `2017-07-31_datastore`[-1,]

# step 3: Save new RDS object
saveRDS(`2017-07-31_datastore`, file = paste0("Data/", "2017-07-31_datastore.rds"))



# step 1: Copy 1st row to header
names(`2017-08-31_datastore`) <- `2017-08-31_datastore`[1,]

# step 2: Delete 1st row
`2017-08-31_datastore` <- `2017-08-31_datastore`[-1,]

# step 3: Save new RDS object
saveRDS(`2017-08-31_datastore`, file = paste0("Data/", "2017-08-31_datastore.rds"))



# step 1: Copy 1st row to header
names(`2017-09-30_datastore`) <- `2017-09-30_datastore`[1,]

# step 2: Delete 1st row
`2017-09-30_datastore` <- `2017-09-30_datastore`[-1,]

# step 3: Save new RDS object
saveRDS(`2017-09-30_datastore`, file = paste0("Data/", "2017-09-30_datastore.rds"))
  
  