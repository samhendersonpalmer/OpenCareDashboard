# A function that returns the latest datastore URL

latest_url <- function() {
  # Load packages
  library(tidyverse)
  library(rvest)
  
  
# Front page of datastore
base_URL <- "https://www.careinspectorate.scot/resources-data/data-and-statistics/datastore"

# Read in URL
base_pg <- read_html(base_URL)

# Extract URLs on main page
base_urls <-
  base_pg %>%
  html_nodes("a") %>%                           # find all links
  html_attr("href") %>%                         # get the url
  str_subset("datastore-")

base_urls_df <-
  base_urls %>%                       
  paste0("https://www.careinspectorate.scot", .) %>%  # Add website prefix
  as.data.frame(nm = "URL")

result <- base_urls_df %>%
  slice(1) %>%
  pull(URL)


# Extract csv URLs on sub page
page_url <-
  read_html(result) %>%
  html_nodes("a") %>%                           # find all links
  html_attr("href") %>%                         # get the url
  str_subset("\\.csv")

url_name <- lubridate::dmy(str_extract(result, "(?<=library/datastore).*") %>%
                             str_replace_all("-", ""))

list("url" = page_url, "date" = url_name)
}
