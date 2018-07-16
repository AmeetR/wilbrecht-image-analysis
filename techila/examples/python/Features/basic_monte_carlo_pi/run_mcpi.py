# Copyright 2012-2016 Techila Technologies Ltd.

# This Python script contains the Local Control Code, which will be
# used to distribute computations to the Techila environment.
#
# The Python script named 'mcpi_dist.py' will be distributed and
# evaluated on Workers. The 'loops' parameter will be transferred to all
# Jobs as an input argument. The 'run_mcpi' function will return the value
# of the 'result' variable, which will contain the approximated value of Pi.
#
# Usage:
# execfile('run_mcpi.py')
# result = run_mcpi(jobcount, loops)
# jobcount: number of Jobs in the Project
# loops: number of iterations performed in each Job
#
# Example:
# result = run_mcpi(10, 100000)

# Load the techila package
import techila

def run_mcpi(jobcount, loops):

    # Create the computational Project with the peach function.
    result = techila.peach(funcname = 'mcpi_dist', # Function that will be executed on Workers
                           params = [loops], # Parameters for the executable function
                           files = ['mcpi_dist.py'], # Files that will be evaluated on Workers
                           jobs = jobcount # Number of Jobs in the Project
                           )

    # Calculate the approximated value of Pi based on the results received.
    result = 4 * float(sum(result)) / (jobcount * loops)

    # Display results
    print('The approximated value of Pi is:', result)
    return(result)
