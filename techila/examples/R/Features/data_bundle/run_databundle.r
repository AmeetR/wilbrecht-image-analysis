# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# The R-script named "databundle_dist.r" will be distributed and
# sourced on Workers.
#
# Usage:
# source("run_databundle.r")
# result <- run_databundle()
# Example:
# result <- run_databundle()

# Load the techila library
library(techila)

run_databundle <- function() {

# Create the computational Project with the peach function.
  result <- peach(funcname = "databundle_dist", # Function that will be executed on Workers
                  files = list("databundle_dist.r"), # Files that will be sourced on Workers
                  peachvector = 1, # Set the number of Jobs to one (1)
                  sdkroot = "../../../..", # Location of the techila_settings.ini file
                  databundles = list( # Define a databundle
                    list( # Data Bundle #1
                      datadir = "./storage/", # The directory from where files will be read from
                      datafiles = list( # Files for Data Bundle #1
                        "file1_bundle1",
                        "file2_bundle1"
                      ),
                      parameters = list( # Parameters for Data Bundle #1
                        "ExpirationPeriod" = "60 m" # Remove the Bundle from Workers if not used in 60 minutes
                      )
                    ),
                    list( # Data Bundle #2
                      datafiles = list( # Files for Data Bundle #2, from the current working directory
                        "file1_bundle2",
                        "file2_bundle2"
                      ),
                      parameters = list( # Parameters for Data Bundle #2
                        "ExpirationPeriod" = "30 m" # Remove the Bundle from Workers if not used in 30 minutes
                      )
                    )
                  )
                 )
  result
}
