# Copyright 2012-2013 Techila Technologies Ltd.

library(techila)

run_jobs <- function(loops) {
  # This function contains  the distributed version, where operations inside the
  # loop structure will be executed on Workers.
  #
  # Example usage:
  #
  # loops <- 100
  # result <- run_jobs(loops)

  result <- cloudfor (i=1:loops,
                      .sdkroot="../../../..", # Path of the techila folder
                      .steps=2 # Perform two iterations per Job
                     ) %t% {  # Start of code block that will be executed on Workers
      i * i # This operation will be performed on the Workers
  } # End of code block executed on Workers
}
