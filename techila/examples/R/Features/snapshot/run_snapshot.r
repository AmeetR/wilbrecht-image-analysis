# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# The R-script named "snapshot_dist.r" will be distributed to Workers,
# where the function snapshot_dist will be executed according to the
# input parameters specified. The peachvector will be used to control
# the number of Jobs in the Project.
#
# Snapshotting will be implemented with the default values, as the
# Local Control Code does not specify otherwise.
#
# To create the Project, use command:
#
# result <- run_snapshot(jobs, loops)
#
# jobs = number of jobs
# loops = number of iterations performed in each Job

# Load the techila library
library(techila)

# This function will create the computational Project by using peach.
run_snapshot <- function(jobs, loops) {

  result <- peach(funcname = "snapshot_dist", # Function that will be executed on Workers
                  params = list(loops), # Input parameters for the executable function
                  files = list("snapshot_dist.r"), # Files that will be sourced on the Workers
                  peachvector = 1:jobs, # Length of the peachvector will determine the number of Jobs
                  snapshot = TRUE, # Enable snapshotting
                  sdkroot = "../../../.." # Location of the techila_settings.ini file
                 )

  # Calculate the approximated value of Pi based on the received results
  result <- 4 * sum(as.numeric(result)) / (jobs * loops)

  # Display the results
  print(c("The approximated value of Pi is:", result))
  result
}
