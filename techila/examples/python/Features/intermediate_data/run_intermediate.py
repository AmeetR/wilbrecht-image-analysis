# Copyright 2017 Techila Technologies Ltd.

# This function contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# Usage:
# execfile('run_intermediate.py')
# result = run_intermediate()
#
# Note: The number of Jobs in the Project will be automatically set to 2

def myfunction(a, jobid, jobidx):
# Intermediate callback function. Called each time new intermediate data
# has been received.
    from techila import send_im_data

    print('Received intermediate data from Job #' + str(jobidx))
    print('Value of received variable is: ' + str(a))
    a = a + 2 # Increase value of variable so we know it was processed here
    print('Increased value of variable to: ' + str(a))
    print('Sending updated value of variable as intermediate data to Job #' + str(jobidx))
    send_im_data(jobid, a); # Send the updated value of 'a' back to the same Job
    print('Finished sending intermediate data to Job #' + str(jobidx))


# Load the techila library
import techila

def run_intermediate():

    # Will be used to set the number of jobs to 2
    jobs = 2

    result = techila.peach(funcname = "intermediate_dist",   # Name of the executable function
                           files = ['intermediate_dist.py'], # File with function definitions
                           params = '<param>', # Input argument for executable function
                           peachvector = range(1,jobs+1), # Number of Jobs and input args
                           stream = True, # Enable streaming 
                           intermediate_callback = myfunction, # Intermediate callback function 
                           )
    # Print and return results
    print(result)
    return result  