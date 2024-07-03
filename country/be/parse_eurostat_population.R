library(readxl)
library(dplyr)

# Define the path to the Excel file
file_path <- "data/be/raw/demo_pjan__custom_12038045_spreadsheet.xlsx"


# Get the sheet names
sheet_names <- excel_sheets(file_path)

# Initialize an empty data frame to store the consolidated data
all_data <- data.frame()

# Function to read and parse a sheet
read_and_parse_sheet <- function(sheet_name) {
  # Read the age from cell C7
  age <- read_excel(file_path, sheet = sheet_name, range = "C7", col_names = FALSE) %>% pull(1)
  
  # Read the data from cells B12 to K12
  yearly_data <- read_excel(file_path, sheet = sheet_name, range = "B12:K12", col_names = FALSE)
  
  # Extract the values as a vector
  values <- as.numeric(yearly_data[1, ])
  
  # Create a data frame with year, age, and value
  data <- data.frame(
    year = 2014:2023,
    age = age,
    value = values
  )
  
  return(data)
}

# Loop through each sheet and parse the data
for (sheet in sheet_names) {
  # Skip the summary and structure sheets
  if (sheet %in% c("Summary", "Structure")) next
  
  # Parse the sheet
  sheet_data <- read_and_parse_sheet(sheet)
  
  # Append the data to the all_data data frame
  all_data <- bind_rows(all_data, sheet_data)
}

# Write the consolidated data to a CSV file
write.csv(all_data, "data/be/eurostat_consolidated_data.csv", row.names = FALSE)
