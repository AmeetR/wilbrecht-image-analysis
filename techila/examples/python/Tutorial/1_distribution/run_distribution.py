# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will create the
# computational Project.
#
# Usage:
# execfile('run_distribution.py')
# result = run_distribution(jobcount)
#
# jobcount: number of Jobs in the Project
#
# Example:
# result = run_distribution(5)
def run_distribution(jobcount):

    # Import the techila package
    import techila

    # Create the computational Project with the peach function.
    result = techila.peach(funcname = 'distribution_dist',   # Function that will be called on Workers
                           files = 'distribution_dist.py',   # Python-file that will be sourced on Workers
                           jobs = jobcount,                  # Number of Jobs in the Project
                           )

    # Display results after the Project has been completed. Each element
    # will correspond to a result from a different Job.
    print(result)
    return(result)

