# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains the Worker Code, which will be distributed and sourced
# on the Workers. The values of the input parameters will be received from the
# parameters defined in the Local Control Code.
mcpi_dist <- function(loops) {

  count <- 0 # No random points generated yet, init to 0.
  for (i in 1:loops) { # Monte Carlo loop from 1 to loops
    if ((sum(((runif(1) ^ 2)  + (runif(1) ^ 2))) ^ 0.5) < 1) { # Point within the circle?
      count <- count + 1 # Increment if the point is within the circle.
    }
  }
  return(list(count=count,loops=loops)) # Return the results as a list
}
