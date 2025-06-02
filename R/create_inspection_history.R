# This script aims to produce an approximation of inspection history from datastore data
# From March 2017 (the start of monthly datastore files) to the present day.
# The final dataframe will detail an approximation of inspection history for each service
# with each observation representing an individual inspection


# Load packages -----------------------------------------------------------
library(tidyverse)

# Read all datastore files from March 2017 to present ---------------------

## Find names of all files ----------------------------------------------
datastore_filenames <- rownames(file.info(list.files("Data", full.names = T)))

# Complete monthly data appears to have commenced in March of 2017 so start there by removing older datastores
datastore_filenames <- datastore_filenames[!(datastore_filenames %in% c("Data/2015-03-31_datastore.rds", "Data/2016-03-31_datastore.rds"))]


## Combine datastore files -------------------------------------------------
combined_datastores <- datastore_filenames |> 
  map_dfr(~ readRDS(.x) |> 
            # convert every field to character to prevent type-clashing in bind_rows when reading in
            mutate(across(everything(), as.character)), .id = "URL")

# Check how many observations are in each datastore (URL number 1 is the oldest i.e. March 2017)
print(
  combined_datastores |> 
  group_by(URL) |> 
  mutate(URL = as.numeric(URL)) |> 
  summarise(count = n()),
  n = 98)


# Clean data --------------------------------------------------------------
# First select the relevant shared columns

# Keep CSNumber, Grading information including date of first inspection of the year and last inspection date, requirements and recommendations/improvements
combined_datastores_variables <- combined_datastores |>  
  select(CSNumber, 
         ServiceName,
         MinGrade, 
         # Date that the latest graded inspection report was published
         Publication_of_Latest_Grading, 
         # Based on date that the last inspection was completed, the inspection report may not be published yet however
         Last_inspection_Date,  
         # Date of the first inspection of each inspection year (April to March)
         starts_with("first_date"),  
         # Newer Key Question framework and remove those columns that just indicate a change
         (starts_with("KQ_") & !ends_with("_change")),
         # Older Quality theme framework and remove those columns that just indicate a change
         (starts_with("Quality_") & !ends_with("_change")),
         # Indicates if the service had any requirements made at inspections in 2023/24
         starts_with("any_requirements"), 
         URL,
         contains("_recs_"),
         contains("_reqs_")
         ) |> 
  # Replace spaces with NA and those fields where only a single full 
  # stop (i.e. in March 2021 service list under "first_recs_2021" for many services)
  mutate(across(where(is.character),
                ~ replace(., . %in% c("", "."), NA))) |> 
  # Remove all columns that are completely NA
  select(where( ~!all(is.na(.x))))


## Grading data focus --------------------------------------------------
# As of June 2022 the Care Inspectorate transitioned from Quality Themes to Key Questions:
# - "Quality of care and support" to "How good is our care, play and learning?"
# - "Quality of environment" to "How good is our setting?"
# - "Quality of management and leadership" to "How good is our leadership?"
# - "Quality of staffing" to "How good is our staff team?"

# KQ_Care_and_Support_Planning == Quality_of_Care_and_Support
# KQ_Care_Play_and_Learning == Quality_of_Care_and_Support
# KQ_Setting == Quality_of_Environment 
# KQ_Leadership == Quality_of_Mgmt_and_Lship
# KQ_Staff_Team == Quality_of_Staffing
# KQ_Support_Wellbeing == No older equivalent...


# Initially, we can just include service information, date fields and grading data
combined_datastores_grading <- combined_datastores_variables |>  
  select(CSNumber, 
         ServiceName,
         Publication_of_Latest_Grading, 
         Last_inspection_Date,
         (starts_with("KQ_") & !ends_with("_change")),
         (starts_with("Quality_") & !ends_with("_change")),
         URL) |> 
  # We can add multiple date formats to check for
  mutate(across(c("Publication_of_Latest_Grading", "Last_inspection_Date"), ~parse_date_time(.x, c("dmy"))))
  

# Create time series of inspections ----------------------------------
inspection_series <- combined_datastores_grading |>
  # Create time series for each individual service
  group_by(CSNumber) |> 
  # Filter to only include observations where the publication of latest grades is after the last inspection date
  # to make sure we're only including the information from that most recent inspection
  filter(Publication_of_Latest_Grading > Last_inspection_Date) |> 
  # Remove duplicate entries over datastore series
  distinct(Publication_of_Latest_Grading, .keep_all = TRUE)



# Save data -------------------------------------------------------------
saveRDS(inspection_series, file = "Data/inspection_series.rds")
  
  
  
  
  
  