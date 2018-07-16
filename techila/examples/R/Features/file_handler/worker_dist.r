# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the function that will be executed 
# during computational Jobs. Each Job will generate two variables,
# which will be stored in files called 'file1' and 'file2'.
worker_dist <- function(jobidx) {

  sample1 <- paste("This file was generated in job: ", jobidx)
  sample2 <- "This is a static string stored in file2"
  save(sample1, file = "file1")
  save(sample2, file = "file2")
}
