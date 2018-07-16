# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains the Local Control Code.
#
# Load the techila library
library(techila)

# This function will call the 'peach' function, which will create the
# Project.
#
# Usage: result <- run_packagetest2(input)
# input = String
# Example:
# result <- run_packagetest2("testvalue")
run_packagetest2 <- function(input) {

  result <- peach(funcname = "packagetest_dist", # Function that will be executed on Workers
                  params = list(input), # Input parameters for the executable function
                  files = list("packagetest_dist.r"), # Files that will be sourced on Workers
                  packages = list("techilaTestPackage"),
                  peachvector = 1:1, # Set the number of Jobs to one (1)
                  sdkroot = "../../../.." # Location of the techila_settings.ini file
                 )
}
