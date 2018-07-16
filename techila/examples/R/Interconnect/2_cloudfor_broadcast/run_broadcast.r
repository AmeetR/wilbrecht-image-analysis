run_broadcast <- function() {
# This function contains the cloudfor-loop, which will be used to distribute
# computations to the Techila environment.
#
# During the computational Project, data will be broadcasted from one Job
# to all other Jobs in the Project. The broadcasted data will be returned
# from all Jobs.
#
# Syntax:
#
# source("run_broadcast.r")
# jobres <- run_broadcast()
#

# Copyright 2015 Techila Technologies Ltd.

  library(techila)
  
  # Set loops to three. Will define number of Jobs in the Project.
  loops <- 3
  
  # Set source Job to two. Will define which Job broadcasts data.
  sourcejob <- 2
  res <- cloudfor (i=1:loops, # Set number of iterations to three.
                      .sdkroot="../../../..", # Location of the Techila SDK 'techila' directory.
                      #.ProjectParameters = list("techila_worker_group" = "IC Group 1"), # Uncomment to use. Limit Project to Workers in Worker Group 'IC Group 1'
                      .steps=1 # Set number of iterations per Job to one.
                      ) %t% { 
    # Initialize the interconnect network. 
    techila.ic.init()
    
    # Build message string
    datatotransfer = paste("Hi from Job", i)
    
    # Broadcast contents of 'datatotransfer' variable from 'sourcejob' to all other Jobs in the Project
    jobres = techila.ic.cloudbc(datatotransfer,sourcejob)
    
    # Wait until all Jobs have reached this point before continuing
    techila.ic.wait_for_others()
            
    # Disconnect from the interconnect network
    techila.ic.disconnect()
    
    # Return the broadcasted data.
    jobres
  } 
  
  # Print and return the results
  for (i in 1:length(res)) {
    print(paste("Result from Job #",i,": ",res[i],sep=""))
  }
  return(res)
}
