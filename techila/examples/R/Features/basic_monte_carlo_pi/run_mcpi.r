# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# The R-script named "mcpi_dist.r" will be distributed and sourced on
# Workers. The 'loops' parameter will be transferred to all Jobs. The
# peachvector will be used to control the number of Jobs in the
# Project. The 'run_mcpi' function will return the value of the
# 'result' variable, which will contain the approximated value of Pi.
#
# Usage:
# source("run_mcpi.r")
# result <- run_mcpi(jobs, loops)
# jobs: number of Jobs in the Project
# loops: number of Monte Carlo approximations performed per Job
#
# Example:
# result <- run_mcpi(10, 100000)

# Load the techila library
library(techila)

run_mcpi <- function(jobs, loops) {

  # Create the computational Project with the peach function.
  result <- peach(funcname = "mcpi_dist", # Function that will be executed on Workers
                  params = list(loops), # Parameters for the executable function
                  files = list("mcpi_dist.r"), # Files that will be sourced on Workers
                  peachvector = 1:jobs, # Length of the peachvector determines the number of Jobs.
                  sdkroot = "../../../..") # Location of the techila_settings.ini file

  # Calculate the approximated value of Pi based on the generated data.
  result <- 4 * sum(as.numeric(result)) / (jobs * loops)

  # Display results
  print(c("The approximated value of Pi is:", result))
  result
}
