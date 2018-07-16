# Copyright 2010-2013 Techila Technologies Ltd.

# This script contains the Worker Code, which contains the
# packagetest_dist function that will be executed in each
# computational Job.

# Load the The techilaTestPackage library. 
library(techilaTestPackage)

packagetest_dist <- function(input) {
  # Call the techilaTestFunction from the techilaTestPackage
  result <- techilaTestFunction(input) 
}
