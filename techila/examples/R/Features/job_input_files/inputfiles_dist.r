# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the Worker Code, which will be distributed
# and executed on the Workers. The Jobs will access their Job-specific
# input files with the name "input.txt", which is defined in the Local
# Control Code
inputfiles_dist <- function() {
  table_contents <- read.table("input.txt")
  result <- sum(table_contents)
  return(result)
}
