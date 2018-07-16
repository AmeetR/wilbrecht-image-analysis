# Copyright 2012-2013 Techila Technologies Ltd.

# This Python scrip contains the Worker Code, which will be
# distributed and evaluated on the Workers. The value of the input
# parameter will be received from the parameters defined in the Local
# Control Code.

# Import necessary packages
import random

def mcpi_dist(loops):
    count = 0 # No random points generated yet, init to 0.

    i = 0
    while i < loops:
        if pow(pow(random.random(), 2) + pow(random.random(), 2), 0.5) < 1:
            count = count + 1
        i = i + 1

    return({'count': count, 'loops': loops}) # Return the results as a list
