# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script will be sourced at the preliminary stages of a
# computational Job. The value of input argument in the Local Control
# Code will determine, which function will be called on the Worker.

function1 <- function() {
  # When called in the computational Job, the function return the value 2.
  result <- 1 + 1
}

function2 <- function() {
  # When called in the computational Job, the function return the value 100.
  result <- 10 * 10
}
