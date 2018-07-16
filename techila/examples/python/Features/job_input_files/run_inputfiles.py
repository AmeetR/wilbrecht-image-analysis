# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# The Python script named 'inputfiles_dist.py' will be distributed and
# evaluated on Workers. Job specific input files will be transferred
# with each Job, each Job receiving one input file.
#
# Usage:
# execfile('run_inputfiles.py')
# result = run_inputfiles()
#
# Note: The number of Jobs in the Project will be automatically set to 4.

# Load the techila library
import techila

def run_inputfiles():

    # Will be used to set the number of jobs to 4 to match the number of input files
    jobs = 4

    result = techila.peach(funcname = 'inputfiles_dist', # Name of the executable function
                           files = ['inputfiles_dist.py'], # Files that will be evaluated on Workers
                           jobs = jobs, # Set the number of Jobs to 4
                           jobinputfiles = {  # Job Input Bundle
                               'datafiles' : [ # Files for the Job Input Bundle
                                   'input1.txt',  # File input1.txt for Job 1
                                   'input2.txt', # File input2.txt for Job 2
                                   'input3.txt', # File input3.txt for Job 3
                                   'input4.txt'  # File input4.txt for Job 4
                                   ],
                               'filenames' : ['input.txt'] # Name of the file on the Worker
                               },
                           )
    return result
