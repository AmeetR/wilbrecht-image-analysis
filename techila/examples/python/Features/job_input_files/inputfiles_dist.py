# Copyright 2012-2016 Techila Technologies Ltd.

# This file contains the Worker Code, which will be distributed
# and evaluated on the Workers. The Jobs will access their Job-specific
# input files with the name 'input.txt', which is defined in the Local
# Control Code

# Import required packages
import csv

# The function that will be executed in each Job
def inputfiles_dist():

    # Read the file 'input.txt' from the temporary working directory.
    data = list(csv.reader(open('input.txt', 'r'), delimiter=' '))

    # Sum the values onthe row.
    row_int = map(int,data[0]) # Convert to integers
    sum_row_int = sum(row_int) # Sum the values on the row

    return(sum_row_int) # Return summation as the result
