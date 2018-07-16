# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will create the
# computational Project.
#
# Usage:
# source("run_datafiles.r")
# result <- run_datafiles()
# Example:
# result <- run_datafiles()
run_datafiles <- function()  {

  # Load the techila library
  library(techila)

  # Set the value of the jobs variable to four. The 'jobs' variable
  # will be used to determine the length of peachvector.
  jobs <- 4

  # Create the computational Project with the peach function.
  result <- peach(funcname = "datafiles_dist",  # The function that will be called
                  params = list("<param>"), # Parameters for the executable function
                  files = list("datafiles_dist.r"), # Files that will be sourced on Workers
                  datafiles = list("datafile.txt"),  # Datafiles that will be transferred to Workers
                  peachvector = 1:jobs, # Length of the peachvector determines the number of Jobs.
                  sdkroot = "../../../..") # Location of the techila_settings.ini file.

  # Convert the results to numeric format
  result <- as.numeric(result)
  # Display the results.
  print(result)
  result
}
