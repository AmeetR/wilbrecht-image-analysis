# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the function that will be executed during
# computational Jobs. Each Job will perfom the same computational
# operations: calculating 1 + 1.
def distribution_dist():

    # Store the sum of 1 + 1 to variable 'result'
    result = 1 + 1

    # Return the value of the 'result' variable. This value will be
    # returned from each Job and the values will be stored in the list
    # returned by the peach-function.
    return(result)
