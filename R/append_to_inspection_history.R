# This script aims to append a new datastore to the inspection history  by adding
# it to the inspection_series dataset. This step is run in the update_data.R
# script when there is a new datastore file available.

append_to_inspection_history <- function(new_datastore){
  new_datastore <- download_latest_datastore()
  
  # Clean data --------------------------------------------------------------
  # First select the relevant shared columns
  combined_datastores_variables <- new_datastore |>  
    select(CSNumber, 
           ServiceName,
           # Date that the latest graded inspection report was published
           Publication_of_Latest_Grading, 
           # Based on date that the last inspection was completed, the inspection report may not be published yet however
           Last_inspection_Date,  
           # Newer Key Question framework and remove those columns that just indicate a change
           (starts_with("KQ_") & !ends_with("_change")),
           # Older Quality theme framework and remove those columns that just indicate a change
           (starts_with("Quality_") & !ends_with("_change"))
           ) |>
    # Replace spaces with NA and those fields where only a single full 
    # stop (i.e. in March 2021 service list under "first_recs_2021" for many services)
    mutate(across(where(is.character),
                  ~ replace(., . %in% c("", "."), NA))) |> 
    # Remove all columns that are completely NA
    select(where( ~!all(is.na(.x)))) |> 
    # change all columns to character to be consistent with time series
    mutate(across(everything(), as.character)) |> 
    # We can add multiple date formats to check for
    mutate(across(c("Publication_of_Latest_Grading", "Last_inspection_Date"), ~parse_date_time(.x, c("dmy"), tz = "GMT"))) |> 
    # convert datetimes to just dates
    mutate(across(c("Publication_of_Latest_Grading", "Last_inspection_Date"), as.Date),
           URL = as.character(Sys.Date()))
  
  
  # Create time series of inspections ----------------------------------
  ## Read in inspection series
  inspection_series_old <- readRDS("Data/inspection_series.rds")
  
    # Join both first
  inspection_series <- bind_rows(combined_datastores_variables, inspection_series_old) |>
    # Create time series for each individual service
    group_by(CSNumber) |> 
    # Filter to only include observations where the publication of latest grades is after the last inspection date
    # to make sure we're only including the information from that most recent inspection
    filter(Publication_of_Latest_Grading > Last_inspection_Date) |> 
    # Remove duplicate entries over datastore series
    distinct(Publication_of_Latest_Grading, .keep_all = TRUE)
  
  
  # Save data -------------------------------------------------------------
  saveRDS(inspection_series, file = "Data/inspection_series.rds")
  
  
}