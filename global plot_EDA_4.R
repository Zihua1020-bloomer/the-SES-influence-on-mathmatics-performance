# Load the packages-----------
chooseCRANmirror(graphics = FALSE, ind = 1)
install.packages("rnaturalearthdata")
library(dplyr)
library(ggplot2)
library(maps)
library(rnaturalearthdata)
library(rnaturalearth)
library(sf)

# Read and merge the data with world map---------------
data <- read.csv("data.csv")
head(data)
world <- ne_countries(scale = "medium", returnclass = "sf")
# Merge your data with the world map data
world_data <- merge(world, data, by.x = "iso_a3", by.y = "country", all.x = TRUE)


# Plotting the map for mean score
ggplot(data = world_data) +
  geom_sf(aes(fill = mean_score), color = "white", size = 0.1) +  
  scale_fill_viridis_c(na.value = "grey50", option = "plasma", direction = 1, name = "Mean Maths Score") +  
  labs(title = "The Mean Score of Maths", subtitle = "TIMSS DATA GRADE 4") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Plotting the map for mean ses
ggplot(data = world_data) +
  geom_sf(aes(fill = mean_ses), color = "white", size = 0.1) +  
  scale_fill_viridis_c(na.value = "grey50", option = "plasma", direction = 1, name = "Mean Social Economic Index") +  
  labs(title = "The Mean Score of Scocial Background", subtitle = "TIMSS DATA GRADE 4") +
  theme_minimal() +
  theme(legend.position = "bottom")


