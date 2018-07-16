# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will create the
# computational Project.
#
# Usage:
# execfile('run_datafiles.py')
# result = run_datafiles()

def run_datafiles():

    # Import the techila package
    import techila

    jobs = 4 # Will be used to define the 'peachvector'.

    result = techila.peach(funcname = 'datafiles_dist',       # The function that will be executed
                           params = ['<vecidx>'],             # Input argument for the executable function
                           files = ['datafiles_dist.py'],     # Files that will be evaluated on Workers
                           datafiles = ['datafile.txt'],      # Datafiles that will be transferred to Workers
                           peachvector = range(1, jobs + 1),  # Length of the peachvector determines the number of Jobs.
                           )
    print('Sums of rows: ', result) # Display the sums
    return(result) # Return list containing summation results
