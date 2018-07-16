# Copyright 2010-2013 Techila Technologies Ltd.

# This script contains the Local Control Code, which will create the
# computational Project.
#
# Usage:
# source("run_filehandler.r")
# run_filehandler()
#
# Example:
# run_filehandler()

# Load the techila library
library(techila)


# This function contains the filehandler function, which will be
# called once for each result file received.
filehandler_func <- function(file) {

  # Display the location of the result file on the End-Users computer
  print(file)

  # Load contents of the file to memory
  load(file)
  if (exists("sample1")) {  # Current file is 'file1'
    print(sample1)
  }
  if (exists("sample2")) {  # Current file is 'file2'
    print(sample2)
  }
}

# This function contains the peach function call, which will be
# used to create the computational Project
run_filehandler <- function() {

  result <- peach(funcname = "worker_dist", # Function that will be called on Workers
                  files = "worker_dist.r", # Files that will be sourced on Workers
                  params = list("<param>"), # Input parameters for the executable function
                  peachvector = 1:2, # Set the number of Jobs to two (2)
                  outputfiles = list("file1", "file2"), # Files to returned from Workers
                  filehandler = filehandler_func, # Name of the filehandler function
                  sdkroot = "../../../..", # Location of the techila_settings.ini file
                 )
}
