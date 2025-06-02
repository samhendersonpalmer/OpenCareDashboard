# This script creates a likert chart of proportions of grades over time as part of 
# an inspection time-series

# Load packages and data -----------------------------------------------------------
library(tidyverse)

inspection_series <- readRDS("Data/inspection_series.rds")
unique_csnumbers <- unique(inspection_series$CSNumber)

# Sample service ----------------------------------------------------------
service_sample <- sample(1:length(unique_csnumbers), 1)

# Filter for selected service
sample_inspection <- inspection_series |> 
  filter(CSNumber == unique_csnumbers[service_sample]) |>
  # Pivot to create a single column for all grades at each inspection and grade label
  pivot_longer(5:17, values_to = "Grade", names_to = "Question") |> 
  mutate(Grade_descr = case_when(
    Grade == 1  ~ "Unsatisfactory", 
    Grade == 2  ~ "Weak", 
    Grade == 3  ~ "Adequate",
    Grade == 4  ~ "Good", 
    Grade == 5  ~ "Very good", 
    Grade == 6  ~ "Excellent")) |> 
  na.omit(Grade)

# Change grade column to factor for ordering in legend
sample_inspection$Grade_descr <- factor(sample_inspection$Grade_descr, levels = c("Unsatisfactory", 
                                                                                  "Weak", 
                                                                                  "Adequate",
                                                                                  "Good", 
                                                                                  "Very good", 
                                                                                  "Excellent"))

# Custom colours for grading
myColors <- c("Unsatisfactory" = "#d73027", 
              "Weak" = "#fc8d59", 
              "Adequate" = "#fdcc3f", 
              "Good" = "#c3e648", 
              "Very good" = "#91cf60", 
              "Excellent" = "#1a9850")


# Create Likert chart -----------------------------------------------------


ggplot(sample_inspection, aes(x = as.Date(Last_inspection_Date), y = as.numeric(Grade), fill = Grade_descr)) +
  geom_bar(position = position_fill(reverse = TRUE), stat = "identity", show.legend=TRUE) +
  scale_y_continuous(labels = scales::percent) +
  # Drop and show.legend above means we keep all grade labels even if not visible
  scale_fill_manual(values = myColors, drop = F) +
  scale_x_date(date_labels = "%b\n%Y") +
  xlab("Inspections") +
  ylab("") +
  theme_gray(base_size = 14) +
  # Amend legend positioning
  theme(legend.position = "top",
        legend.justification.top = "centre",
        legend.position.inside =c(0.5, 1.5),
        legend.direction = "horizontal",
        plot.margin=unit(c(0,0,0,0), 'cm'),
        legend.title=element_blank()) + 
  # Have legend just on one line
  guides(fill = guide_legend(nrow = 1))
