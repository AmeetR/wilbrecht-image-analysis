# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains the Local Control Code, which contains
# functions for creating a custom R library Bundle and for creating a
# computational Project in the Techila environment.

# Load the techila library
library(techila)

# This function will create a Bundle from the 'techilaTestPackage' by
# using the 'bundleit' function.
#
# Usage:
# packagename <- create_package()
create_package <- function() {

  # Create a Bundle from the 'techilaTestPackage' package
  packagename <- bundleit("techilaTestPackage",
                          allPlatforms = TRUE,
                          sdkroot = "../../../..")
  # Display the name of the Bundle
  print(paste("The name of the Bundle is:", packagename))
  # Return the name of the Bundle
  packagename
}

# This function will call the 'peach' function, which will create the
# Project.
#
# Usage: result <- run_packagetest(input, packagename)
# input = String
# Example:
# result <- run_packagetest("testvalue", packagename)
run_packagetest <- function(input, packagename) {

  result <- peach(funcname = "packagetest_dist", # Function that will be executed on Workers
                  params = list(input), # Input parameters for the executable function
                  files = list("packagetest_dist.r"), # Files that will be sourced on Workers
                  imports = list(packagename), # Import the bundle created by the bundleit function
                  peachvector = 1:1, # Set the number of Jobs to one (1)
                  sdkroot = "../../../.." # Location of the techila_settings.ini file
                 )
}
