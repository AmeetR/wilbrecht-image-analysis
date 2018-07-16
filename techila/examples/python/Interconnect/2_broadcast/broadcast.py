# This Python script contains the Local Control Code and Worker Code, which will be
# used to perform the computations in the Techila environment.
#
# Usage:
# execfile('broadcast.py')
# result = run_cloudbc()

# Copyright 2015 Techila Technologies Ltd.

def cloudbc_dist(sourcejob):
    """
    This function contains the Worker Code and will be executed on Techila Workers. 
    The code will broadcast a simple string from 'sourcejob' to all Jobs in the 
    Project using the Techila interconnect functions.
    """
    # Import the Techila interconnect functions from the peachclient.py file
    from peachclient import TechilaInterconnect
    
    # Create a TechilaInterconnect object, which contains the interconnect methods.
    ti = TechilaInterconnect()
    
    # Build a simple message string that will be broadcasted from one Job to 
    # all other Jobs in the Project.
    datatotransfer = 'Hi from Job ' + str(ti.myjobid)
    
    # Broadcast the message str
    result = ti.cloudbc(datatotransfer, sourcejob)
    
    # Wait until all Jobs have reached this point before continuing
    ti.wait_for_others()
    
    return (ti.myjobid, result)

def run_cloudbc():
    """
    This function contains the Local Control Code, which will be executed on the 
    End-User's computer. This function will create a computational Project, where
    one Job will broadcast to all other Jobs in the Project.
    """
    import techila
    
    # Define number of Jobs in the Project.
    jobs = 3
    
    # Define which Job will broadcast data.
    sourcejob = 2
    results = techila.peach(funcname = 'cloudbc_dist', # Execute this function on Workers
                            files = ['broadcast.py'],  # Source this file on Workers.
                            params = [sourcejob],      # Pass 'sourcejob' as an input argument
                            jobs = jobs,               # Set the Job count 
                            #project_parameters = {'techila_worker_group' : 'IC Group 1'}  # Uncomment to enable. Limit Project to Worker Group 'IC Group 1'.
                            )
    # Print the results.
    for res in results:
        jobid = str(res[0])
        result = res[1]
        print('Result from Job #' + jobid + ': ' + result)
    return(results)
