run_cloudop <- function() {
# This function contains the cloudfor-loop, which will be used to distribute
# computations to the Techila environment.
#
# This code will create a Project, which will have 4 Jobs. Each Job will
# start by generating a random number locally. The 'cloudop' function will
# then be used to find the minimum value from these local variables.
# To create the Project, use command:
#
# Syntax:
#
# source("run_cloudop.r")
# jobres <- run_cloudop()
#

# Copyright 2015 Techila Technologies Ltd.

  # Load the techila package
  library(techila)
  loops <- 3
  results <-  cloudfor (i=1:loops,
                        .sdkroot="../../../..", # Location of the Techila SDK 'techila' directory.
                        #.ProjectParameters = list("techila_worker_group" = "IC Group 1"), # Uncomment to use. Limit Project to Workers in Worker Group 'IC Group 1'
                        .steps=1 # Set number of iterations per Job to one.
                        ) %t% {  
    
    # Initialize the interconnect network. 
    techila.ic.init()
    
    # Set the random number generator seed
    set.seed(i)
    
    # Generate a random number
    data=runif(1)
    
    # Execute the 'multiply' function with input 'data' across all Jobs.
    # The result of the multiplication operation will be stored in 'mulval' in all Jobs.
    mulval <- techila.ic.cloudop(multiply,data)
    
    # Wait until all Jobs have reached this point before continuing
    techila.ic.wait_for_others()
            
    # Disconnect from the interconnect network
    techila.ic.disconnect()
    
    # Return the multiplication value as the result
    mulval
  }
  
  # Print and return the results.
  for (i in 1:length(results)) {
    jobres = unlist(results[i])
    cat("Result from Job #",i,":",jobres, "\n")
  }
}

# Define a simple function which performs multiplication. 
# This function will be executed across all Jobs by using the 'techila.ic.cloudop' function.
multiply <- function(a,b) {
  return(a * b)
}
