# Copyright 2012-2016 Techila Technologies Ltd.

# This script contains the function that will be executed during
# computational Jobs. Each Job will sum the values in a specific
# column in the file 'datafile.txt' and return the value as the
# output.

# Import the csv package
import csv

def datafiles_dist(jobidx):

    # Read the file 'datafile.txt' from the temporary working directory.
    rows = list(csv.reader(open('datafile.txt', 'r'), delimiter=' '))

    # Sum the values in the row. The row is chosen based on the value
    # of the 'jobidx' parameter.

    row = rows[jobidx]   # Choose row based on the 'jobidx' parameter
    row_int = map(int,row) # Convert to integers
    sum_row_int=sum(row_int) # Sum the values on the row

    return(sum_row_int) # Return summation as the result
