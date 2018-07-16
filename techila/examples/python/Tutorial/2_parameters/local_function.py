# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the locally executable function, which
# can be executed on the End-Users computer. This function
# does not communicate with the Techila environment.
#
# Usage:
# execfile('local_function.py')
# result = local_function(multip, loops)
# multip: value of the multiplicator
# loops: the number of iterations in the 'for' loop.
#
# Example:
# result = local_function(2, 5)
def local_function(multip, loops):
    result = []
    for x in range(1, loops + 1):
        result.append(multip * x)
    print(result)
    return(result)
