# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the locally executable function, which can be
# executed on the End-Users computer. This function does not
# communicate with the Techila environment.
#
# Usage:
# source("local_function.r")
# result <- local_function(x)
# x: the number of iterations in the for loop.
#
# Example:
# result <- local_function(5)

local_function <- function(x) {
 result <- array(0, dim = c(1, x))
 for (j in 1:x)
 result[1, j] <- 1 + 1
 result
}
