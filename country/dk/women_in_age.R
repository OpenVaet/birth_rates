library(ggplot2)
library(readr)
library(tidyr)
library(dplyr)
library(scales)

# Reads the CSV file
file_path <- "data/dk/women_age_groups_by_year.csv"
data_long <- read_csv(file_path)

# Summarizes the total number of women for each year
total_by_year <- data_long %>%
  group_by(Year) %>%
  summarize(Total = sum(Count))

# Prints the total of women in age by year.
write.csv(total_by_year, 'data/dk/women_in_age_by_year.csv')
print(total_by_year)

# Plots the total number of women for each year
ggplot(total_by_year, aes(x = Year, y = Total)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  labs(title = "DK - Total Number of 15-44 Women (2013-2023)",
       x = "Year",
       y = "Total Number of Women") +
  theme_minimal() +
  scale_x_continuous(breaks = 2013:2023) +
  scale_y_continuous(labels = scales::comma, limits = c(0, max(total_by_year$Total) + 10000)) +
  theme(
    text = element_text(size = 18),
    plot.title = element_text(size = 22, face = "bold"),
    axis.title = element_text(size = 20),
    axis.text = element_text(size = 18),
    legend.title = element_text(size = 20),
    legend.text = element_text(size = 18),
    plot.caption = element_text(size = 16)
  )

# Plots the evolution of women by age group
ggplot(data_long, aes(x = Year, y = Count, color = Age)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  labs(title = "DK - Evolution of 15-44 Women by Age Group (2013-2023)",
       x = "Year",
       y = "Number of Women",
       color = "Age Group") +
  theme_minimal() +
  scale_x_continuous(breaks = 2013:2023) +
  scale_y_continuous(labels = scales::comma, limits = c(0, max(data_long$Count) + 10000)) +
  theme(
    text = element_text(size = 18),
    plot.title = element_text(size = 22, face = "bold"),
    axis.title = element_text(size = 20),
    axis.text = element_text(size = 18),
    legend.title = element_text(size = 20),
    legend.text = element_text(size = 18),
    plot.caption = element_text(size = 16)
  )
