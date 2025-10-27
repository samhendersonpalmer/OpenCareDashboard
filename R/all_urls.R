# A function that returns dataframe containing all datastore urls

all_urls <- function(month = NULL, year = NULL){
  
  # Load packages
  library(tidyverse)
  library(xml2)
  library(rvest)
  library(stringr)
  library(lubridate)
  
  # First datastore page
  base_URL <- "https://www.careinspectorate.com/index.php/publications-statistics/44-public/93-datastore"
  
  # Read in URL
  base_pg <- read_html(base_URL)
  
  # Extract csv URLs on page
  base_urls <- 
    base_pg %>%
    html_nodes("a") %>%                           # find all links
    html_attr("href") %>%                         # get the url
    str_subset("\\.csv") %>%                      # Subset CSV URLs
    str_replace_all(" ", "%20") %>%  
    paste0("https://www.careinspectorate.com", .) # Add website prefix
  
  # Other pages
  other_URL <- as.list(paste0("https://www.careinspectorate.com/index.php/publications-statistics/44-public/93-datastore?start=", seq(10, 500, by =10)))
  
  # Get URLS for each csv on all other pages
  other_urls <- lapply(other_URL, function(x) {
    read_html(x) %>%
      html_nodes("a") %>%                           # find all links
      html_attr("href") %>%                         # get the url
      str_subset("\\.csv") %>%                      # Subset CSV URLs
      str_replace_all(" ", "%20") %>%  
      paste0("https://www.careinspectorate.com", .) %>%
      as.data.frame.list %>%
      t() %>%
      as.data.frame()})
  
  # Combine to get a table of all CSV urls on website
  urls_combined <- bind_rows(as.data.frame(base_urls, nm = "V1"), other_urls) %>%
    select(URL = V1) %>%
    filter(URL != "https://www.careinspectorate.com") %>%
    remove_rownames() %>%
    # Derive custom dates as names
    mutate(
      Year = str_sub(URL, -8, -5),
      Year = case_when(
        Year == "20v2" ~ 2024,
        Year == "%202" ~ 2016,
        .default = as.numeric(as.character(Year))
      ),
      Month = str_match(URL, paste(month.name, collapse = "|")),
      Month = replace_na(Month, "January"),
      concat_date = make_date(as.numeric(Year), match(Month, month.name)),
      upload_day = str_extract(URL, "(?<=data_)[0-9]+"),
      upload_day = replace_na(upload_day, "31"),
      upload_date = concat_date - days(1) + days(upload_day)
    ) |> 
    # order by most recent at top
    arrange(desc(upload_date))
  
  return(urls_combined)
}
