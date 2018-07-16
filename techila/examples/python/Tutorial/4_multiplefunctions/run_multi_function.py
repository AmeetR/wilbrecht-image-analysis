# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will create the
# computational Project. The value of the input argument will
# determine which function will be executed in the computational Jobs.
#
# Usage:
# execfile('run_multi_function.py')
# result = run_multi_function(funcname)
# Example:
# result = run_multi_function('function1')

def run_multi_function(funcname):

    # Load the techila library
    import techila

    # Create the computational Project with the peach function.
    result = techila.peach(funcname = funcname, # Executable function determined by the input argument of 'run_multi_function'
                           files = ['multi_function_dist.py'], # The Python-script that will be evaluated on Workers
                           peachvector = [1], # Set the number of Jobs to one (1)
                           )

    print(result)
    return(result)
