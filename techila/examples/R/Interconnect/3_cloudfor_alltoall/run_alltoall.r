run_alltoall <- function() {
# This function contains the cloudfor-loop, which will be used to distribute
# computations to the Techila environment.
#
# This code will create a Project, which will have 4 Jobs. Each Job will send
# a short string to all other Jobs in the Project by using the Techila
# interconnect feature.
#
# Syntax:
#
# source("run_alltoall.r")
# jobres <- run_alltoall()
#

# Copyright 2015 Techila Technologies Ltd.

    # Load the techila package
    library(techila)
    
    # Set loops to four
    loops <- 4
    res <- cloudfor (jobidx=1:loops, # Set number of iterations to four
                      .sdkroot="../../../..", # Location of the Techila SDK 'techila' directory.
                      #.ProjectParameters = list("techila_worker_group" = "IC Group 1"), # Uncomment to use. Limit Project to Workers in Worker Group 'IC Group 1'
                      .steps=1 # Set number of iterations per Job to one.
                     ) %t% {  
                     
            # Initialize the interconnect network. 
            techila.ic.init()
            dataall = list()
            
            # Get the number of Jobs in the Project
            jobcount = techila.get_jobcount()
            
            # Build a simple message string
            msg = paste("Hi from Job", jobidx)
          
            # For loops for sending data to all other Jobs.
            for (src in 1:jobcount) {
              for (dst in 1:jobcount) {
                if (src == jobidx && dst != jobidx) {
                  techila.ic.send_data_to_job(dst,msg)
                }
                else if (src != jobidx && dst == jobidx) {
                  data = techila.ic.recv_data_from_job(src)
                  dataall = c(dataall, data);
                }
                else {
                  print('Do nothing')
                }
              }
            }
            # Wait until all Jobs have reached this point before continuing
            techila.ic.wait_for_others()
            
            techila.ic.disconnect()
            dataall
        } 
        
    # Print and return the results
    for (i in 1:length(res)) {
      jobres = unlist(res[i])
      cat("Result from Job #",i,":",jobres, "\n")
    }
    return(res)
}
