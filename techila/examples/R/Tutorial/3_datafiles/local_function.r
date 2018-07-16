# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the locally executable function, which can be
# executed on the End-Users computer. This function does not
# communicate with the Techila environment.
#
# Usage:
# source("local_function.r")
# result <- local_function()
# Example:
# result <- local_function()
local_function <- function() {
  contents <- read.table("datafile.txt")
  n <- length(contents)
  result <- 0
  for (x in 1:n) {
    result[x] <-  sum(contents[1:length(contents), x])
  }
  result
}

