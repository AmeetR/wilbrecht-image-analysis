# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the function that will be executed during
# computational Jobs. Each Job will multiply the values of the two
# input arguments, 'multip' and 'jobidx'. 'multip' will be same for
# all Jobs, 'jobidx' will receive a different peachvector element.
parameters_dist <- function(multip, jobidx) {

  # Multiply the values of variables 'multip' and 'jobidx
  result <- multip * jobidx

  # Return the value of the 'result' variable from the Job.
  return(result)
}
