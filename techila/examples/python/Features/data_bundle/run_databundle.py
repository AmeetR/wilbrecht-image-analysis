# Copyright 2012-2013 Techila Technologies Ltd.

# This Python script contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# The Python script named 'databundle_dist.py' will be distributed and
# evaluated on Workers. Necessary data files will be transferred to Workers
# in Data Bundles.
#
# Usage:
# execfile('run_databundle.py')
# result = run_databundle()


# Import the techila package
import techila

def run_databundle():

    # Create the computational Project with the peach function.
    result = techila.peach(
        funcname = 'databundle_dist', # Function that will be executed on Workers
        files = ['databundle_dist.py'], # Files that will be evaluated on Workers
        jobs = 1, # Set the number of Jobs to 1
        databundles = [ # Define a databundle
            { # Data Bundle #1
                'datadir' : './storage/', # The directory from where files will be read from
                'datafiles' : [ # Files for Data Bundle #1
                    'file1_bundle1',
                    'file2_bundle1',
                    ],
                'parameters' : { # Parameters for Data Bundle #1
                    'ExpirationPeriod' : '60 m', # Remove the Bundle from Workers if not used in 60 minutes
                    }
                },
            { # Data Bundle #2
                'datafiles' : [ # Files for Data Bundle #2, from the current working directory
                    'file1_bundle2',
                    'file2_bundle2',
                    ],
                'parameters' : { # Parameters for Data Bundle #2
                    'ExpirationPeriod' : '30 m', # Remove the Bundle from Workers if not used in 30 minutes
                      }
                    }
                  ]
        )
    return(result)
