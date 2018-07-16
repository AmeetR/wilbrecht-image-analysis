# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will create the
# computational Project.
#
# Usage:
# source("run_parameters.r")
# result <- run_parameters(multip, jobs)
# multip: value of the multiplicator
# jobs: the number of iterations in the 'for' loop.
#
# Example:
# result <- run_parameters(2, 5)

run_parameters <- function(multip, jobs) {

  # Load the techila library
  library(techila)

  # Create the computational Project with the peach function.
  result <- peach(funcname = "parameters_dist",  # Function that will be called on Workers
                  params = list(multip, "<param>"), # Parameters for the function that will be executed
                  files = list("parameters_dist.r"),  # Files that will be sourced at the preliminary stages
                  peachvector = 1:jobs, # Number of Jobs. Peachvector elements will also be used as input parameters.
                  sdkroot = "../../../..") # The location of the techila_settings.ini file.

  # Convert results to numeric format.
  result <- as.numeric(result)
  # Display the results after the Project is completed
  print(result)
  result
}
