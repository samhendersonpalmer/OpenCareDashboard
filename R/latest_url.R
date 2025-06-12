# A function that returns the latest datastore URL

latest_url <- function() {
  # Load packages
  library(tidyverse)
  library(rvest)
  
  # Front page of datastore
  base_URL <- "https://www.careinspectorate.com/index.php/publications-statistics/93-public/datastore"
  
  # Read in URL
  base_pg <- read_html(base_URL)
  
  # Extract csv URLs on page
  base_urls <-
    base_pg %>%
    html_nodes("a") %>%                           # find all links
    html_attr("href") %>%                         # get the url
    str_subset("\\.csv")
  
  base_urls_df <-
    base_urls %>%                       # Subset CSV URLs
    paste0("https://www.careinspectorate.com", .) %>%  # Add website prefix
    as.data.frame(nm = "URL")
  
  result <- base_urls_df %>%
    slice(1) %>%
    pull(URL)
  
  url_name <- dmy(gsub(" ", "_", str_extract(base_urls[1], "(?<=data_).+(?=.csv)")))
  
  list("url" = result, "date" = url_name)
}
