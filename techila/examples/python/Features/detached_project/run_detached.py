# Copyright 2012-2013 Techila Technologies Ltd.

# This file contains the Local Control Code, which contains two
# functions:
#
# * run_detached - used to create the computational Project.
# * download_result - used to download the results
#
# The run_detached function will return immediately after all
# necessary computational data has been transferred to the server. The
# function will return the Project ID of the Project that was created.
#
# Usage:
# execfile('run_detached.r')
#
# Create Project with command:
# pid = run_detached(jobs, loops)
#
# jobs = number of jobs
# loops = number of iterations performed in each Job
#
# Download results with command:
# result = download_result(pid)
#
# pid = Project ID number

# Load the techila library
import techila

# Function for creating the computational Project
def run_detached(jobs, loops):

    pid = techila.peach(funcname = 'mcpi_dist', # Function that will be executed on Workers
                        params = [loops], # Input parameters for the executable function
                        files = ['mcpi_dist.py'], # Files that will be sourced on Workers
                        peachvector = range(1, jobs + 1), # Length of the peachvector determines the number of Jobs.
                        donotwait = True, # Detach project and return the Project ID number
                        )
    return(pid)

# Function for downloading the results of a previously completed Project
def download_result(pid):

    results = techila.peach(projectid = pid) # Link to an existing Project.

    points = 0 # Initialize result counter to zero

    for res in results:  # Process each Job result
        points = points + int(res.get('count')) # Calculate the total number of points within the unitary

    result = 4 * float(points) / (len(results) * int(results[0].get('loops'))) # Calculate the approximated value of Pi
    return(result)
