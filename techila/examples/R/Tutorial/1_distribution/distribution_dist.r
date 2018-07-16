# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the function that will be executed during
# computational Jobs. Each Job will perfom the same computational
# operations: calculating 1+1.
distribution_dist <- function() {

  # Store the sum of 1 + 1 to variable 'result'
  result <- 1 + 1

  # Return the value of the 'result' variable. This value will be
  # returned from each Job and the values be displayed on the
  # End-Users computer after the Project is completed.
  return(result)
}
