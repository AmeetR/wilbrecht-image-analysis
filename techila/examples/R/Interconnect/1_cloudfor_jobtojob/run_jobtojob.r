run_jobtojob <- function() {
# This function contains the cloudfor-loop, which will be used to distribute
# computations to the Techila environment.
#
# This code will create a Project, which will have 2 Jobs. Each Job will send
# a short string to the other Job in the Project by using the Techila
# interconnect feature.
#
# To create the Project, use command:
#
# source("run_jobtojob.r")
# jobres <- run_jobtojob()

# Copyright 2015 Techila Technologies Ltd.

    library(techila)
    
    # Set the number of loops to two
    loops <- 2
    result <- cloudfor (i=1:loops, # Set number of iterations to two.
                      .sdkroot="../../../..", # Location of the Techila SDK 'techila' directory.
                      #.ProjectParameters = list("techila_worker_group" = "IC Group 1"), # Uncomment to use. Limit Project to Workers in Worker Group 'IC Group 1'
                      .steps=1 # Set number of iterations per Job to one.
                     ) %t% {  
                     
            # Initialize the interconnect network. 
            techila.ic.init()
            
            # Build a message string 
            msg = paste("Hi from Job", i)
            if (i == 1){ # Job #1 will execute this block
                techila.ic.send_data_to_job(2, msg) # Send message to Job #2
                rcvd = techila.ic.recv_data_from_job(2) # Receive message from Job #2
            } else if (i == 2) { # Job #2 will execute this block
                rcvd = techila.ic.recv_data_from_job(1) # Receive message from Job #1
                techila.ic.send_data_to_job(1, msg) # Send message to Job #1
            }
            
            # Wait until all Jobs have reached this point before continuing
            techila.ic.wait_for_others()
            
            # Disconnect from the interconnect network.
            techila.ic.disconnect()
            
            # Return the data that was received.
            rcvd
        } 
    # Print and return the results
    for (i in 1:length(result)) {
      print(paste("Result from Job #",i,": ",result[i],sep=""))
    }
    return(result)
}
