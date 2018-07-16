# Copyright 2012-2016 Techila Technologies Ltd.

# This Python contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# Usage:
# execfile('run_funchandle.py')
# result = run_funchandle(jobcount,loops)
#
# jobcount: number of Jobs in the Project
# loops: number of Monte Carlo approximations performed per Job
#
# Example:
# result = run_funchandle(10, 100000)
import techila

# This function executed on Workers. The values of the input parameters will be
# received from the parameters defined in the Local Control Code.
def mcpi_dist(loops):
    import random
    count = 0
    i = 0
    while i < loops:
        if point_dist() < 1:
            count = count + 1
        i = i + 1

    return count

# This is a subfunction called from mcpi_dist and executed also on Workers.
def point_dist():
    return pow(pow(random.random(), 2) + pow(random.random(), 2), 0.5)

# This function will distribute create the computational Project by
# using peach.
def run_funchandle(jobcount, loops):
    result = techila.peach(funcname = mcpi_dist,    # Execute the mcpi_dist-function on Workers
                           funclist = [point_dist], # Additional function required on Workers
                           params = [loops],        # Input argument to the mcpi_dist-function
                           jobs=jobcount,           # Number of Jobs in the Project
                           )

    # Calculate the approximated value of Pi
    result = 4 * float(sum(result)) / (jobcount * loops)

    # Display results
    print('The approximated value of Pi is:', result)
    return result
