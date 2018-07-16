# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the locally executable function, which can be
# executed on the End-Users computer. This function does not
# communicate with the Techila environment.
#
# Usage:
# execfile('local_function.py')
# result = local_function()

# Import the csv package
import csv

def local_function():

    # Read the file from the current working directory
    rows = list(csv.reader(open('datafile.txt', 'rb'), delimiter=' '))

    # Create empty list for results
    contents=[]

    for row in rows: # For each row
        row_int = map(int,row)       # Convert the values to integers
        sum_row_int=sum(row_int)     # Sum the integers
        contents.append(sum_row_int) # Append the summation result
    print('Sums of rows: ', contents) # Display the sums
    return(contents) # Return list containing summation results
