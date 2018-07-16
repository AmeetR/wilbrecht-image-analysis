# Copyright 2016 Techila Technologies Ltd.

run_foreach <- function() {
  # This function registers the Techila foreach backend and uses the %dopar%
  # notation to execute the computations in parallel, in the Techila 
  # environment.
  #
  # Example usage:
  #
  # source('run_foreach.r')
  # res <- run_foreach()

  # Load required packages
  library(techila)
  library(foreach)
  
  # Register the Techila foreach backend and define the 'techila' folder 
  # location.
  registerDoTechila(sdkroot = "../../../..")

  iters=10
  
  # Create the Project using foreach and %dopar%.
  result <- foreach(i=1:iters, 
                    .options.steps=2, # Perform 2 iterations per Job
                    .combine=c # Combine results into numerical vector
                    ) %dopar% { # Execute computations in parallel
       sqrt(i) # During each iteration, calculate the square root value of i
     }
     
  # Print and return results.   
  print(result)
  result
}