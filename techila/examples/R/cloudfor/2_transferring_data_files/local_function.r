# Copyright 2012-2013 Techila Technologies Ltd.

local_function <- function() {
  # This function will be executed locally on your computer and will not
  # communicate with the Techila environment.
  #
  # Usage:
  #
  # result <- local_function()

  # Read values from the data files
  values <- read.table("datafile.txt", header=TRUE, as.is=TRUE)
  targetvalue <- read.table("datafile2.txt", header=TRUE, as.is=TRUE)

  # Determine the number of rows and columns of data
  rows <- nrow(values)
  cols <- ncol(values)

  # Create empty matrix for results
  result <- matrix(rep(NA, 12), rows, cols)

  for (i in 1:rows) { # For each row of data

    data <- values[i,] # Read the values on the row
    for (j in 1:cols) { # For each element on the row

      # Compare values on the row to the ones on the target row
      if(identical(values[[i, j]], targetvalue[[j]])) {
        result[i, j] <- TRUE  # If rows match
      }
      else {
        result[i, j] <- FALSE # If rows don't match
      }
    }
  }
  print(result)
  result
}


