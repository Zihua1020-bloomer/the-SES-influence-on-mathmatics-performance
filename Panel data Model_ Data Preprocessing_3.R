# Load the library--------------
library(dplyr)

# merge the data of 2019 and 2015-------
data_2019 <- read.csv("merged_data_2019.csv")
data_2015 <- read.csv("merged_data_2015.csv")
data <- rbind(data_2015, data_2019)

# Prepare the data for panel data model------------
# remove records for NA
data<- na.omit(data)
# Filter out countries that only appear in one year
data <- data %>%
  group_by(country) %>%
  mutate(year_count = n_distinct(year)) %>%
  filter(year_count > 1) %>%
  select(-year_count)  # Remove the auxiliary column 'year_count'

# Inspect the first few rows of the filtered data
head(data)

# save the clean data-------------------- 
# Save the cleaned and filtered data to a new CSV file if needed
write.csv(data, "data.csv", row.names = FALSE)



