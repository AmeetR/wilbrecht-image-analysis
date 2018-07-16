# Copyright 2016 Techila Technologies Ltd.

run_ddply<- function() {
  # This function registers the Techila foreach backend and uses the 
  # .parallel option in ddply to execute computations in parallel,
  # in the Techila environment.
  #
  # Example usage:
  #
  # source('run_ddply.r')
  # res <- run_ddply()
  
  # Load required packages.
  library(techila)
  library(plyr)
  
  # Register the Techila foreach backend and define the 'techila' folder 
  # location.
  registerDoTechila(sdkroot = "../../../..")
  
  # Create the computational Project using ddply with the .parallel=TRUE option.
  result <- ddply(iris,         # Split this data frame 
                  .(Species),   # According to the values in the Species column
                  numcolwise(mean), # And perform this operation on the column data.
                  .parallel=TRUE, # Process the computations in Techila
                  .paropts=list(.options.packages=list("plyr")) # Transfer plyr package to Workers.
                  )
                  
  # Print and return results
  print(result)
  result
}
