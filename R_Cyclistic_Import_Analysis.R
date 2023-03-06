# Set the working directory
setwd("C:/Users/Desktop/MyCaseStudy/CSV")

library(readxl)
library(dplyr)
install.packages("dplyr")

# List all CSV files in the directory
file_list <- list.files(pattern = "*.csv")

# Create an empty data frame to merge all the data
dataframe_totale <- data.frame()

# Use a for loop to read all the CSV files and merge them into a single data frame
for (i in 1:length(file_list)) {
  current_file <- read.csv(file_list[i])
  dataframe_totale <- rbind(dataframe_totale, current_file)
}

# Create the ride_length variable by calculating the difference between ended_at and started_at
dataframe_totale$ride_length <- difftime(as.POSIXct(dataframe_totale$ended_at, format="%Y-%m-%d %H:%M:%S"), as.POSIXct(dataframe_totale$started_at, format="%Y-%m-%d %H:%M:%S"), units = "mins")

# Filter the dataframe_totale by removing all rows where the ride_length variable is negative because they are considered outliers
dataframe_totale <- dataframe_totale %>% 
  filter(ride_length >= 0)

# Filter the dataframe by removing all rows where the ride_length variable is less than one minute or greater than 300 minutes because they are considered outliers
dataframe_totale <- dataframe_totale %>% 
  filter(ride_length >= 1 & ride_length <= 300)

library(dplyr)
library(tidyr)

# Calculate the mean of ride_length for each value of member_casual
media_ride_length <- dataframe_totale %>%
  filter(ride_length >= 1 & ride_length <= 300) %>%
  group_by(member_casual) %>%
  summarise(mean_ride_length = mean(ride_length))

# Create a table with pivot_wider
tabella_media_ride_length <- media_ride_length %>%
  pivot_wider(names_from = member_casual, values_from = mean_ride_length)

# Print the table
tabella_media_ride_length

# Create a new variable called day_of_week that indicates the day of the week based on the started_at variable
dataframe_totale$day_of_week <- weekdays(as.Date(dataframe_totale$started_at))

# Create a table to analyze the data
mytable <- table(dataframe_totale$member_casual, dataframe_totale$day_of_week)

# Print the table
print(mytable)

# Create a table to analyze the data
mytable2 <- table(dataframe_totale$member_casual, dataframe_totale$rideable_type)

# Print the table
print(mytable2)


# CLEAN UP #################################################

# Clear environment
rm(list = ls()) 

# Clear packages
p_unload(all)  # Remove all add-ons

# Clear console
cat("\014")  # ctrl+L

# Clear mind :)
