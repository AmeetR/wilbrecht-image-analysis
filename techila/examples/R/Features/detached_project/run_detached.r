# Copyright 2010-2013 Techila Technologies Ltd.

# This file contains the Local Control Code, which contains two
# functions:
#
# * run_detached - used to create the computational Project.
# * download_result - used to download the results
#
# The run_detached function will return immediately after all
# necessary computational data has been transferred to the server. The
# function will return the Project ID of the Project that was created.
# The donwnload_result function can be used to download Project
# results by using Project ID number.
#
# Usage:
# Source with command:
# source("run_detached.r")
# Create Project with command:
# projectid <- run_detached(jobs,loops)
# Download results with command:
# result <- download_result(projectid)
#
# jobs = number of jobs
# loops = number of iterations performed in each Job

# Load the techila library
library(techila)

run_detached <- function(jobs,loops) {

  pid <- peach(funcname = "mcpi_dist", # Function that will be executed on Workers
               params = list(loops), # Input parameters for the executable function
               files = list("mcpi_dist.r"), # Files that will be sourced on Workers
               peachvector = 1:jobs, # Length of the peachvector determines the number of Jobs.
               sdkroot = "../../../..", # Location of the techila_settings.ini file
               donotwait = TRUE # Detach project and return after all computational data has been transferred
              )
}

download_result <- function(pid) {

  result <- peach(projectid = pid, # Link to an existing Project.
                  sdkroot = "../../../..") # Location of the techila_settings ini

  points <- 0 # Initialize result counter to zero

  for (i in 1:length(result)) {  # Process each Job result
    points <- points + result[[i]]$count # Calculate the total number of points within the unitary
  }
  result <- 4 * points / (length(result) * result[[1]]$loops) # Calculate the approximated value of Pi
}
