# Copyright 2012-2013 Techila Technologies Ltd.

library(techila)

run_datafiles <- function() {
  # This function contains  the distributed version, where operations inside the
  # loop structure will be executed on Workers.
  #
  # Usage:
  #
  # result <- run_datafiles()


  # Read values from the data file
  values <- read.table("datafile.txt", header=TRUE, as.is=TRUE)

  # Determine the number of rows and columns of data
  rows <- nrow(values)
  cols <- ncol(values)

  # Create empty matrix for results that will be generated in one Job
  result <- matrix(rep(NA, 3), 1, 3)

  # Split the data read from file 'datafile.txt' to multiple files.
  # These files will be stored i the Job Input Bundle.
  for (i in 1:rows) {
    data <- values[i,]
    write.table(data, file=paste("input", as.character(i), sep=""))
  }

  # Create a list of the files generated earlier.
  inputlist <- as.list(dir(pattern="^input_*"))

  result <- cloudfor(i=1:rows,
                    .steps=1, # One iteration per Job
                    .sdkroot="../../../..", # Path to the 'techila' folder
                    .datafiles=list("datafile2.txt"), # Common data file for all Jobs
                    .jobinputfiles=list(              # Create a Job Input Bundle
                       datafiles = inputlist,         # List of files that will be placed in the Bundle
                       filenames = list("input"))     # Name of the file on the Worker
                     ) %t% { # Start of the code block that will be executed on Workers

    targetvalue <- read.table("datafile2.txt", header=TRUE, as.is=TRUE)
    values <- read.table("input", header=TRUE, as.is=TRUE)

    # Compare the values stored in the common data file ('datafile2.txt') with
    # the ones stored in teh Job-specific input file.
    for (j in 1:cols) { # For each element
        if(identical(values[[j]], targetvalue[[j]])) { # Compare element
          result[1, j] <- TRUE  # If elements match
        }
        else {
          result[1, j] <- FALSE # If elements do not match
        }
      }

    result # Return the 'result' variable

    } # End of the code block executed on Workers

  # Make result formatting match the one in the local version
  result <- matrix(unlist(result), rows, cols, byrow=TRUE)

  # Display result
  print(result)
  result
}
