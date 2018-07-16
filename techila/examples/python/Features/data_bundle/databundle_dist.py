# Copyright 2012-2016 Techila Technologies Ltd.

# This function contains the Worker Code, which will be distributed
# and executed on the Workers. The databundle_dist function will
# access each file stored in two databundles and return results based
# on the values in the files.
import csv

# The function that will be executed on Workers.
def databundle_dist():

    # Read the files from temporary working directory.
    a = list(csv.reader(open('file1_bundle1', 'r'), delimiter=' '))
    b = list(csv.reader(open('file2_bundle1', 'r'), delimiter=' '))
    c = list(csv.reader(open('file1_bundle2', 'r'), delimiter=' '))
    d = list(csv.reader(open('file2_bundle2', 'r'), delimiter=' '))

    # Cast values to integers
    a_int = map(int,a[0])
    b_int = map(int,b[0])
    c_int = map(int,c[0])
    d_int = map(int,d[0])

    return([a_int,b_int,c_int,d_int]) # Return values in a list
