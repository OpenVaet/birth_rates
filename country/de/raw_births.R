library(ggplot2)
library(scales)

# Births data
years <- 2013:2023
births <- c(682069, 714927, 737575, 792141, 784901, 787523, 778090, 773144, 795492, 738819, 692989)

data <- data.frame(year = years, births = births)
data$births <- as.integer(data$births)

# Prints the yearly births.
write.csv(data, 'data/de/births_by_year.csv')

# Fits a linear model to data from 2013 to 2019
fit <- lm(births ~ year, data = data[data$year <= 2019,])

# Predicts births for the years 2020 to 2023
data$predicted <- predict(fit, newdata = data)

# Calculates the percentage deviation for the years 2020 to 2023
data$deviation <- with(data, 100 * (births - predicted) / predicted)

# Creates plot
ggplot(data, aes(x = year, y = births)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_line(aes(y = predicted), linetype = "dashed", color = "blue", size = 1.2) +
  geom_text(aes(label = ifelse(year >= 2020, paste0(round(deviation, 1), "%"), "")),
            vjust = -1, size = 6) +
  labs(title = "DE - Births and Deviation from Linear Trend (2013-2019)",
       x = "Year",
       y = "Number of Births",
       caption = "Dashed line represents the linear trend (2013-2019)") +
  theme_minimal() +
  scale_x_continuous(breaks = years) +
  scale_y_continuous(labels = scales::comma, limits = c(0, max(data$births) + 150000)) +
  theme(
    text = element_text(size = 18),
    plot.title = element_text(size = 22, face = "bold"),
    axis.title = element_text(size = 20),
    axis.text = element_text(size = 18),
    legend.title = element_text(size = 20),
    legend.text = element_text(size = 18),
    plot.caption = element_text(size = 16)
  )
