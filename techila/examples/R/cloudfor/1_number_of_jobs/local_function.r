# Copyright 2012-2013 Techila Technologies Ltd.

local_function <- function(loops) {
  # This function will be executed locally on your computer and will not
  # communicate with the Techila environment.
  #
  # Example usage:
  #
  # loops <- 100
  # result <- local_function(loops)

  result <-  rep(0, loops) # Create empty array for results

  for (i in 1:loops) {
    result[i] = i * i  # Store result in array
  }
  result
}
