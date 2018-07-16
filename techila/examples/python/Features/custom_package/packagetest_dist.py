# Copyright 2012-2013 Techila Technologies Ltd.

# This script contains the Worker Code, which contains the
# packagetest_dist function that will be executed in each
# computational Job.

# Load the the techilatest module.
import techilatest.functions as test

# Define the function that will be called on Workers
def packagetest_dist(a, b):
    # Call the functions defined in the 'techilatest' package
    res1 = test.summation(a,b)
    res2 = test.multiplication(a,b)
    res3 = test.subtraction(a,b)
    res4 = test.division(a,b)

    # Return results in a list
    return([res1, res2, res3, res4])
