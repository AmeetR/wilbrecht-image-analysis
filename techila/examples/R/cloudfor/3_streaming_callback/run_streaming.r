# Copyright 2012-2013 Techila Technologies Ltd.

library(techila)

cbfun <- function(job_result) {
  # Callback function. Will be called once for each result streamed from the
  # Techila Server.
  print(paste("Job result: ", job_result)) # Display the result
  job_result # Return the result
}

multiply <- function(a, b){
  # Function containing simple arithmetic operation.  Will be automatically
  # made available on the Workers
  a * 10 + b
}

run_streaming <- function() {
  # Function for creating the computational Project.
  project_result <- cloudfor (i = 1:3) %to% # Outer cloudfor loop
                    cloudfor (j = 1:2,
                              .steps=1, # One iteration per Job
                              .callback="cbfun",  # Pass each returned result to function 'cbfun'
                              .stream=TRUE, # Enable streaming
                              .sdkroot="../../../.." # Path to the 'techila' directory
                             ) %t% { # Start of code block that will be executed on Workers
    multiply(j, i) # This operation will be performed on Workers
  } # End of code block executed on Workers

  # After Project has been completed, display results
  print("Content of the reshaped 'result' matrix:")
  print(project_result)
  project_result
}
