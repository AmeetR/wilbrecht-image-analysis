# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will create the
# computational Project.
#
# Usage:
# execfile('run_parameters.py')
# result = run_parameters(multip, jobs)
# multip: value of the multiplicator
# jobs: the number of iterations in the 'for' loop.
#
# Example:
# result = run_parameters(2, 5)
def run_parameters(multip, jobs):

    # Load the techila package
    import techila

    # Create the computational Project with the peach function.
    result = techila.peach(funcname = 'parameters_dist',     # Function that will be called on Workers
                           params = [multip, '<param>'],     # Parameters for the function that will be executed
                           files = ['parameters_dist.py'],    # Files that will be sourced at the preliminary stages
                           peachvector = range(1, jobs + 1), # Number of Jobs. Peachvector elements will also be used as input parameters.
                           )

    # Display the results after the Project is completed
    print(result)
    return(result)

