# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the locally executable function, which can be
# executed on the End-Users computer. This function does not
# communicate with the Techila environment. The function implements a
# Monte Carlo routine, which approximates the value of Pi.
#
# Usage:
# source("local_function.r")
# result <- local_function(mloops)
# loops: the number of iterations in Monte Carlo approximation
#
# Example:
# result <- local_function(100000)

local_function <- function(loops){

  # Initialize counter to zero.
  count <- 0

  # Perform the Monte Carlo approximation.
  for (i in 1:loops) {
    if ((sum(((runif(1) ^ 2)  + (runif(1) ^ 2))) ^ 0.5) < 1) { # Calculate the distance of the random point
     count <- count + 1  # Increment counter, when the point is located within the unitary circle.
    }
  }
  # Calculate the approximated value of Pi based on the generated data.
  pivalue <- 4 * count / loops
  # Display results
  print(c("The approximated value of Pi is:", pivalue))
  pivalue
}
