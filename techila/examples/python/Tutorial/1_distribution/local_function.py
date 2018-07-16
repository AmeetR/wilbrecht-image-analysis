# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the locally executable function, which can be
# executed on the End-Users computer. This function does not
# communicate with the Techila environment.
#
# Usage:
# execfile('local_function.py')
# result = local_function(x)
# x: the number of iterations in the for loop.
#
# Example:
# result = local_function(5)

def local_function(x):
    result = []
    for j in range(x):
        result.append(1 + 1)
    return result

