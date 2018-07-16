# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the Worker Code, which will be distributed
# and executed on the Workers. The databundle_dist function will
# access each file stored in two databundles and return results based
# on the values in the files.
databundle_dist <- function() {
 
  # Access a file, which was transferred in Data Bundle #1
  a <- read.table("file1_bundle1")
  # Access a file, which was transferred in Data Bundle #1
  b <- read.table("file2_bundle1")
  # Access a file, which was transferred in Data Bundle #2
  c <- read.table("file1_bundle2")
  # Access a file, which was transferred in Data Bundle #2
  d <- read.table("file2_bundle2")
  # Return a list of the values stored in the four data files.
  return(list(a, b, c, d))
}
