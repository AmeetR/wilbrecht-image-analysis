# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will create the
# computational Project.
#
# Usage:
# source("run_distribution.r")
# result <- run_distribution(jobs)
# jobs: the number of Jobs in the Project
#
# Example:
# result <- run_distribution(5)
run_distribution <- function(jobs) {

  # Load the techila library
  library(techila)

  # Create the computational Project with the peach function.
  result <- peach(funcname = "distribution_dist",    # Function that will be called on Workers
                  files = list("distribution_dist.r"), # R-file that will be sourced on Workers
                  peachvector = 1:jobs,                 # Number of Jobs in the Project
                  sdkroot = "../../../..")              # Location of the techila_settings.ini file

  # Display results after the Project has been completed. Each element
  # will correspond to a result from a different Job.
  print(as.numeric(result))
  result
}
