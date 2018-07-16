# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# The R-script named "mcpi_dist.r" will be distributed to Workers,
# where the function mcpi_dist will be executed according to the
# defined input parameters.
#
# The peachvector will be used to control the number of Jobs in the
# Project.
#
# Results will be streamed from the Workers in the order they will be
# completed. Results will be visualized by displaying intermediate
# results on the screen.
#
# To create the Project, use command:
#
# result <-  run_streaming(jobs,loops)
#
# jobs = number of jobs
# loops = number of iterations performed in each Job

# Load the techila library
library(techila)

# Create a global variable to store intermediate results.
total<-new.env()

# This is the callback functions, which will be executed once for each
# Job result received from the Techila environment.
callbackFun <- function(result) {

  total$jobs <- total$jobs + 1 # Update the number of Job results processed
  total$loops <- total$loops + result$loops # Update the number of Monte Carlo loops performed
  total$count <- total$count + result$count # Update the number of points within the unitary circle
  result <- 4 * total$count / total$loops # Update the Pi value approximation

  # Display intermediate results
  print(paste("Number of results included:",total$jobs," Estimated value of Pi:",result))
  result
}

# When executed, this function will create the computational Project
# by using peach.
run_streaming <- function(jobs,loops) {

  # Initialize the global variables to zero.
  total$jobs <- 0
  total$loops <- 0
  total$count <- 0

  result <- peach(funcname = "mcpi_dist", # Name of the executable function
                  params = list(loops), # Input parameters for the executable function
                  files = list("mcpi_dist.r"), # Files for the executable function
                  peachvector = 1:jobs, # Length of the peachvector will determine the number of Jobs in the Project
                  sdkroot = "../../../..", # Location of the techila_settings.ini file
                  stream = TRUE, # Enable streaming
                  callback = "callbackFun" # Name of the callback function
                 )
}
