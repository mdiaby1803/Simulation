# Set a random seed for reproducibility
set.seed(2100)

# Install necessary packages if not already installed
if (!require("readxl")) install.packages("readxl", dependencies = TRUE)
if (!require("ggplot2")) install.packages("ggplot2", dependencies = TRUE)
if (!require("reshape2")) install.packages("reshape2", dependencies = TRUE)

# Load necessary libraries
library(readxl)
library(ggplot2)
library(reshape2)

# Specify the correct file path to the Excel file containing the data
file_path <- "C:/Users/meman/Downloads/Task 2024/Task 2024/Task 1 simulation data.xlsx"

# Load the data from Excel into R
data <- read_excel(file_path)

# Check the column names to ensure we use the correct ones
print(colnames(data))

# Function to simulate the chain of giving
simulate_chain <- function(initial_amt, rounds = 6) {
  chain <- numeric(rounds)  # Initialize an empty numeric vector to store the captchas completed in each round
  chain[1] <- initial_amt   # Set the first round to the initial amount of captchas
  
  # Iterate through each round of the simulation
  for (round in 2:rounds) {
    similar_participants <- data[data$initial_amt == chain[round - 1], ]  # Subset data to find participants with the same initial amount
    
    # If no similar participants found, use the overall mean of captchas completed (PIF_amt)
    if (nrow(similar_participants) == 0) {
      chain[round] <- mean(data$PIF_amt, na.rm = TRUE)
    } else {
      # Sample a value of captchas completed from similar participants
      chain[round] <- sample(similar_participants$PIF_amt, 1)
    }
  }
  
  return(chain)  # Return the chain of captchas completed in each round
}

# Set initial conditions for the simulation (different initial amounts of captchas completed)
initial_conditions <- c(0, 5, 10, 15, 20)

# Create an empty data frame to store the simulated chains of giving
chains <- data.frame(Round = 1:6)

# Simulate chains for each initial condition and store in the 'chains' data frame
for (initial_amt in initial_conditions) {
  chains[paste("Initial", initial_amt, sep = "_")] <- simulate_chain(initial_amt)
}

# Convert the data from wide to long format for easier plotting
chains_long <- melt(chains, id.vars = "Round", variable.name = "Initial_Condition", value.name = "Captchas")

# Save the plot to a PDF file
pdf("chains_of_giving.pdf")

# Create the plot using ggplot2
ggplot(chains_long, aes(x = Round, y = Captchas, color = Initial_Condition)) +
  geom_line() +                      # Add lines connecting data points
  geom_point() +                     # Add points for each data point
  labs(title = "Simulation of Chains of Giving Seed (2100)",  # Add title
       x = "Round of Giving",         # Label x-axis
       y = "Number of Captchas Completed",  # Label y-axis
       color = "Initial Amount") +    # Label color legend
  theme_minimal()                    # Apply a minimal theme for aesthetics

# Close the PDF device to save the plot
dev.off()
