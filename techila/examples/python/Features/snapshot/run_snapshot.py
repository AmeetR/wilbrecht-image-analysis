# Copyright 2012-2016 Techila Technologies Ltd.

# This function contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# The Python script named 'snapshot_dist.py' will be distributed to
# Workers, where the function snapshot_dist will be executed according
# to the specified input parameters. The peachvector will be used to
# control the number of Jobs in the Project.
#
# Snapshotting will be implemented with the default values, as the
# Local Control Code does not specify otherwise.
#
# To create the Project, use command:
#
# result = run_snapshot(jobs, loops)
#
# jobs = number of jobs
# loops = number of iterations performed in each Job

# Load the techila library
import techila

# This function will create the computational Project by using peach.
def run_snapshot(jobs, loops):

    result = techila.peach(
        funcname = 'snapshot_dist', # Function that will be executed on Workers
        params = [loops], # Input parameters for the executable function
        files = ['snapshot_dist.py'], # Files that will be sourced on the Workers
        peachvector = range(1, jobs + 1), # Length of the peachvector will determine the number of Jobs
        snapshot = True, # Enable snapshotting
        )

    # Calculate the approximated value of Pi based on the received results
    result = 4 * float(sum(result)) / (jobs * loops)

    # Display the results
    print('The approximated value of Pi is:', result)
    return(result)
