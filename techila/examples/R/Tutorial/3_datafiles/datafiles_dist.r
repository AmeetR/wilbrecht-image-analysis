# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the function that will be executed during
# computational Jobs. Each Job will sum the values in a specific
# column in the file 'datafile.txt' and return the value as the
# output.
datafiles_dist <- function(jobidx) {

  # Read the file 'datafile.txt' from the temporary working directory.
  contents = read.table("datafile.txt")  

  # Sum the values in the column. The column is chosen based on the value
  # of the 'jobidx' parameter.
  result = sum (contents[1:length(contents), jobidx])

}
