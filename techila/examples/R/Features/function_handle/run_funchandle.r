# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# A function handle to the 'mcpi_dist' function will be given to the
# funcname parameter, meaning the 'mcpi_dist' function will be
# executed on Workers. The 'loops' parameter will be transferred to
# all Jobs. The peachvector will be used to control the number of Jobs
# in the Project.
#
#
# Usage:
# source("run_funchandle.r")
# result <- run_funchandle(jobs,loops)
# jobs: number of Jobs in the Project
# loops: number of Monte Carlo approximations performed per Job
#
# Example:
# result <- run_funchandle(10,100000)
library(techila)

# This function contains the Worker Code, which will be distributed
# and executed on Workers. The values of the input parameters will be
# received from the parameters defined in the Local Control Code.
mcpi_dist <- function(loops) {
  count <- 0
  for (i in 1:loops) {
    if ((sum(((runif(1) ^ 2)  + (runif(1) ^ 2))) ^ 0.5) < 1) {
      count <- count + 1
    }
  }
  return(count)
}

# This function will distribute create the computational Project by
# using peach.
run_funchandle <- function(jobs,loops) {

  result <- peach(funcname = mcpi_dist,  # Name of the function executed on Workers
                  params = list(loops),   # Input parameters for the executable function
                  peachvector = 1:jobs,   # Length of the peachvecto determines number of Jobs
                  sdkroot = "../../../.." # Location of the techila_settings.ini file
                 )
  # Calculate the approximated value of Pi
  result <- 4 * sum(as.numeric(result)) / (jobs * loops)

  # Display results
  print(c("The approximated value of Pi is:", result))
  result
}


