library(ggplot2)
library(readr)
library(dplyr)
library(tidyr)
library(scales)

# Reads the CSV files
women_age_groups <- read_csv('data/at/women_age_groups_by_year.csv')
births_by_age_group <- read_csv('data/at/births_by_mother_age_group_year.csv')

# Reshapes births data from wide to long format
births_long <- births_by_age_group %>%
  pivot_longer(cols = starts_with("20"), names_to = "Year", values_to = "Births") %>%
  mutate(Year = as.integer(Year))

# Merges the data frames by Age and Year
data <- women_age_groups %>%
  inner_join(births_long, by = c("Age", "Year"))

# Calculates the birth rate per 1000 women for each age group and year
data <- data %>%
  mutate(birth_rate = (Births / Count) * 1000)

# Initializes a list to store the results for each age group
results <- list()

# Performs linear regression and calculate deviations for each age group
for(age_group in unique(data$Age)) {
  age_data <- data %>%
    filter(Age == age_group)
  
  # Fits a linear model to birth rates from 2013 to 2019
  fit <- lm(birth_rate ~ Year, data = age_data[age_data$Year <= 2019,])
  
  # Predicts birth rates for the years 2020 to 2023
  age_data$predicted_rate <- predict(fit, newdata = age_data)
  
  # Calculates the percentage deviation for the years 2020 to 2023
  age_data$deviation <- with(age_data, 100 * (birth_rate - predicted_rate) / predicted_rate)
  
  # Stores the results
  results[[age_group]] <- age_data
}

# Combines the results into a single data frame
final_data <- bind_rows(results)

# Creates plot
ggplot(final_data, aes(x = Year, y = birth_rate, color = Age)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_line(aes(y = predicted_rate), linetype = "dashed", size = 1.2) +
  geom_text(aes(label = ifelse(Year >= 2020, paste0(round(deviation, 1), "%"), "")),
            vjust = -1, size = 6) +
  labs(title = "AT - Birth Rates per 1000 Women in Age Group and Deviation from Linear Trend (2013-2019)",
       x = "Year",
       y = "Birth Rate per 1000 Women",
       color = "Age Group",
       caption = "Dashed line represents the linear trend (2013-2019)") +
  theme_minimal() +
  ylim(0, max(final_data$birth_rate, na.rm = TRUE) + 5) +
  scale_x_continuous(breaks = 2013:2023) +
  theme(
    text = element_text(size = 18),
    plot.title = element_text(size = 22, face = "bold"),
    axis.title = element_text(size = 20),
    axis.text = element_text(size = 18),
    legend.title = element_text(size = 20),
    legend.text = element_text(size = 18),
    plot.caption = element_text(size = 16)
  )
