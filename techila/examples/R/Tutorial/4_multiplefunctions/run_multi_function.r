# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will create the
# computational Project. The value of the input argument will
# determine which function will be executed in the computational Jobs.
#
# Usage:
# source("run_multi_function.r")
# result <- run_multi_function(funcname)
# Example:
# result <- run_multi_function("function1")

run_multi_function <- function(funcname) {

  # Load the techila library
  library(techila)

  # Create the computational Project with the peach function.
  result <- peach(funcname = funcname, # Executable function determined by the input argument of 'run_multi_function'
                  files = list("multi_function_dist.r"), # The R-script that will be sourced on Workers
                  peachvector = 1:1, # Set the number of Jobs to one (1)
                  sdkroot = "../../../..") # Location of the techila_settings.ini file

  # Convert the results to numeric format and display them.
  print(as.numeric(result))
}
