# Copyright 2012-2016 Techila Technologies Ltd.

# This script contains the Local Control Code containing two function
# definitions.
# These functions can be used to create a Bundle containing the 'techilatest'
# and for creating a computational Project that will import the Bundle.
#
# Usage:
#
# execfile('run_packagetest.py')
# bundlename=create_package()
# result=run_packagetest(bundlename)
#
# Import the techila package
import techila

# The function used to store the 'techilatest' package in a Bundle.
def create_package():
    # Create the Bundle from the 'techilatest' package.
    bundlename = techila.bundleit('techilatest', all_platforms = True)

    print('package bundlename is \'%s\'' % bundlename) # Print the Bundle name

    # Return the name of the Bundle.
    return(bundlename)

# This function is used to create a computational Project that will import
# the Bundle containing the 'techilatest' package.
def run_packagetest(bundlename):
    results = techila.peach(funcname = 'packagetest_dist', # Function executed on Workers
                            params = ['<vecidx>','<param>'], # Input arguments to the executable function
                            files = ['packagetest_dist.py'], # File that will be evaluated at the start
                            imports = [bundlename], # Import the Bundle containing the 'techilatest' package
                            peachvector = [1, 2, 4, 8, 16], # Peachvector containing five integer elements
                            )

    # Display the results
    for row in results:
        print(row)
