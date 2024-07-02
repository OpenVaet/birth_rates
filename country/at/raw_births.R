# Loads required libraries
library(ggplot2)

# Births data
years <- 2013:2023
births <- c(79330, 81722, 84381, 87675, 87633, 85535, 84952, 83603, 86078, 82627, 77605)

data <- data.frame(year = years, births = births)

# Fits a linear model to data from 2013 to 2019
fit <- lm(births ~ year, data = data[data$year <= 2019,])

# Predicts births for the years 2020 to 2023
data$predicted <- predict(fit, newdata = data)

# Calculates the percentage deviation for the years 2020 to 2023
data$deviation <- with(data, 100 * (births - predicted) / predicted)

# Creates plot
ggplot(data, aes(x = year, y = births)) +
  geom_line() +
  geom_point() +
  geom_line(aes(y = predicted), linetype = "dashed", color = "blue") +
  geom_text(aes(label = ifelse(year >= 2020, paste0(round(deviation, 1), "%"), "")),
            vjust = -1) +
  labs(title = "Births and Deviation from Linear Trend (2013-2019)",
       x = "Year",
       y = "Number of Births",
       caption = "Dashed line represents the linear trend (2013-2019)") +
  theme_minimal() +
  ylim(0, max(data$births) + 5000) +
  scale_x_continuous(breaks = years)
