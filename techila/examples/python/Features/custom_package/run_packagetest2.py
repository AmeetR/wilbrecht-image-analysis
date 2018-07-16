# Copyright 2012-2016 Techila Technologies Ltd.

# This script contains the Local Control Code containing function
# definition for running packagetest example.
#
# Usage:
#
# execfile('run_packagetest2.py')
# result = run_packagetest2()
#
# Import the techila package
import techila

# This function is used to create a computational Project that will import
# the Bundle containing the 'techilatest' package.
def run_packagetest2():
    results = techila.peach(funcname = 'packagetest_dist', # Function executed on Workers
                            params = ['<vecidx>','<param>'], # Input arguments to the executable function
                            files = ['packagetest_dist.py'], # File that will be evaluated at the start
                            packages = ['techilatest'],
                            peachvector = [1, 2, 4, 8, 16], # Peachvector containing five integer elements
                            )

    # Display the results
    for row in results:
        print(row)
