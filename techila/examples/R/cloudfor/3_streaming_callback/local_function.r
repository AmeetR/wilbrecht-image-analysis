# Copyright 2012-2013 Techila Technologies Ltd.

multiply <- function(a,b){
  # Function containing simple arithmetic operation.
  a * 10 + b
}

local_function <- function() {
  # This function will be executed locally on your computer and will not
  # communicate with the Techila environment.
  #
  # Usage:
  #
  # result <- local_function()

  # Create empty matrix for results
  result <- matrix(0, 2, 3)
  print("Results generated during loop evaluations:")


  for (i in 1:3) {
    for (j in 1:2) {
     # Pass the values of the loop counters to the 'multiply' function and
      # store result in the 'result' matrix
      result[j, i] <- multiply(j, i)
      print(result[j, i]) # Display value returned by the 'multiply' function
    }
  }
  print("Content of the 'result' matrix:")
  print(result)
  result
}
