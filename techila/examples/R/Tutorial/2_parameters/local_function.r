# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the locally executable function, which
# can be executed on the End-Users computer. This function
# does not communicate with the Techila environment.
#
# Usage:
# source("local_function.r")
# result <- local_function(multip, loops)
# multip: value of the multiplicator
# loops: the number of iterations in the 'for' loop.
#
# Example:
# result <- local_function(2, 5)
local_function <- function(multip, loops) {
  result <- 0
  for (x in 1:loops) {
    result[x] <- multip * x
  }
  print(result)
  result
}
