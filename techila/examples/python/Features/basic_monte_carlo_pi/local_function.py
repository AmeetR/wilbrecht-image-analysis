# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the locally executable function, which can be
# executed on the End-Users computer. This function does not
# communicate with the Techila environment. The function implements a
# Monte Carlo routine, which approximates the value of Pi.
#
# Usage:
# execfile('local_function.py')
# result = local_function(loops)
# loops: the number of iterations in Monte Carlo approximation
#
# Example:
# result = local_function(100000000)

import random

def local_function(loops):

    # Initialize counter to zero.
    count = 0

    # Perform the Monte Carlo approximation.
    i = 0
    while i < loops:
        if pow(pow(random.random(), 2) + pow(random.random(), 2), 0.5) < 1:
            count = count + 1
        i = i + 1

    # Calculate the approximated value of Pi based on the generated data.
    pivalue = 4 * float(count) / loops

    # Display results
    print 'The approximated value of Pi is:', pivalue
    return(pivalue)
