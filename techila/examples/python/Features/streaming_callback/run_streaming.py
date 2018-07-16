# Copyright 2012-2016 Techila Technologies Ltd.

# This Python script contains the Local Control Code, which will be
# used to distribute computations to the Techila environment.
#
# The Python script named 'mcpi_dist.py' will be distributed to
# Workers, where the function mcpi_dist will be executed according to
# the defined input parameters.
#
# The peachvector will be used to control the number of Jobs in the
# Project.
#
# Results will be streamed from the Workers in the order they will be
# completed. Results will be visualized by displaying intermediate
# results on the screen.
#
# Usage:
# execfile('run_streaming.py')
# result = run_streaming(jobs, loops)
# jobs: number of Jobs in the Project
# loops: number of iterations performed in each Job
#
# Example:
# result = run_streaming(10, 10000000)


# Load the techila library
import techila


# This is the callback function, which will be executed once for each
# Job result received from the Techila environment.
def callbackfun(jobresult):
    global total_jobs
    global total_loops
    global total_count

    total_jobs = total_jobs + 1 # Update the number of Job results processed
    total_loops = total_loops + int(jobresult.get('loops')) # Update the number of Monte Carlo loops performed
    total_count = total_count + int(jobresult.get('count'))# Update the number of points within the unitary circle
    result = 4 * float(total_count) / total_loops # Update the Pi value approximation

    # Display intermediate results
    print('Number of results included:', total_jobs, 'Estimated value of Pi:', result)
    return(jobresult)


# When executed, this function will create the computational Project
# by using peach.
def run_streaming(jobs, loops):
    global total_jobs
    global total_loops
    global total_count

    # Initialize the global variables to zero.
    total_jobs = 0
    total_loops = 0
    total_count = 0

    result = techila.peach(funcname = 'mcpi_dist', # Name of the executable function
                           params = [loops], # Input parameters for the executable function
                           files = ['mcpi_dist.py'], # Files for the executable function
                           peachvector = range(1, jobs + 1), # Length of the peachvector will determine the number of Jobs in the Project
                           stream = True, # Enable streaming
                           callback = callbackfun, # Name of the callback function
                           )

    return(result)
