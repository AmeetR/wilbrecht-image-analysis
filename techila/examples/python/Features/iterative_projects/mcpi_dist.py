# Copyright 2012-2013 Techila Technologies Ltd.

# This Python scrip contains the Worker Code, which will be
# distributed and sourced on the Workers. The values of the input
# parameters will be received from the parameters defined in the Local
# Control Code.

import random

def mcpi_dist(loops, jobidx, iteration):
    random.seed(jobidx * iteration)

    count = 0 # No random points generated yet, init to 0.

    i = 0
    while i < loops:
        if pow(pow(random.random(), 2) + pow(random.random(), 2), 0.5) < 1:
            count = count + 1
        i = i + 1

    return count # Return the results as a list
