library(ggplot2)
library(readr)
library(dplyr)

# Reads the CSV files
births_data <- read_csv('data/bg/births_by_year.csv')
women_data <- read_csv('data/bg/women_in_age_by_year.csv')

# Calculates the birth rate per 1000 women for each year
data <- births_data %>%
  inner_join(women_data, by = c("year" = "Year")) %>%
  mutate(birth_rate = (births / Total) * 1000)

# Fits a linear model to birth rates from 2013 to 2019
fit <- lm(birth_rate ~ year, data = data[data$year <= 2019,])

# Predicts birth rates for the years 2020 to 2023
data$predicted_rate <- predict(fit, newdata = data)

# Calculates the percentage deviation for the years 2020 to 2023
data$deviation <- with(data, 100 * (birth_rate - predicted_rate) / predicted_rate)

# Creates plot
ggplot(data, aes(x = year, y = birth_rate)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_line(aes(y = predicted_rate), linetype = "dashed", color = "blue", size = 1.2) +
  geom_text(aes(label = ifelse(year >= 2020, paste0(round(deviation, 1), "%"), "")),
            vjust = -1, size = 6) +
  labs(title = "BE - Birth Rates per 1000 Women in Age and Deviation from Linear Trend (2013-2019)",
       x = "Year",
       y = "Birth Rate per 1000 Women",
       caption = "Dashed line represents the linear trend (2013-2019)") +
  theme_minimal() +
  ylim(0, max(data$birth_rate, na.rm = TRUE) + 5) +
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
