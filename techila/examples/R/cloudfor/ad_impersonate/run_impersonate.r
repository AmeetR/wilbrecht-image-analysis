run_impersonate <- function() {
# This function contains the cloudfor-loop, which will be used to distribute
# computations to the Techila environment.
#
# During the computational Project, Active Directory impersonation will be 
# used to run the Job under the End-User's own AD user account.
#
# Syntax:
#
# source("run_impersonate.r")
# res <- run_impersonate()

# Copyright 2015 Techila Technologies Ltd.

  # Load the techila package
  library(techila)
  
  # Check which user account is used locally
  local_username <- system("whoami",intern=TRUE)
  
  worker_username <-  cloudfor (i=1:1, # Set the maximum number of iterations to one
                                .sdkroot="../../../..", # Location of the Techila SDK 'techila' directory
                                .ProjectParameters = list("techila_ad_impersonate" = "true") # Enable AD impersonation
  ) %t% {
    # Check which user account is used to run the computational Job.
    worker_username <- system("whoami",intern=TRUE)
  }
  
  # Print and return the results
  cat("Username on local computer:",local_username, "\n")
  cat("Username on Worker computer:",worker_username, "\n")
  list(local_username,worker_username)
}
