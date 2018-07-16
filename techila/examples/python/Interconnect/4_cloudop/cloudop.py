# This Python script contains the Local Control Code and Worker Code, which will be
# used to perform the computations in the Techila environment.
#
# Usage:
# execfile('cloudop.py')
# result = run_cloudop()

# Copyright 2015 Techila Technologies Ltd.

def cloudop_dist(idx):
    """
    This function contains the Worker Code and will be executed on Techila Workers. 
    Each Job will transfer a simple string to all other Jobs in the Project using
    the Techila interconnect functions.
    """
    
    # Import the Techila interconnect functions from the peachclient.py file
    from peachclient import TechilaInterconnect
    
    # Import the random package so we can generate random numbers
    import random
    
    # Define a simple function for multiplying values. This function will be executed
    # across all Jobs by using the 'cloudop' method.
    def multiply(a,b):
        return(a*b)
    
    # Create a TechilaInterconnect object, which contains the interconnect methods.
    ti = TechilaInterconnect()
    
    # Set the random number generator seed
    random.seed(idx)
    
    # Generate a random number
    data = random.random() 
    
    # Execute the 'multiply' function across all Jobs with input 'data'. Final 
    # multiplication result will be stored in 'mulval' in all Jobs.
    mulval = ti.cloudop(multiply, data)
    
    # Wait until all Jobs have reached this point before continuing
    ti.wait_for_others()
    
    return(ti.myjobid,mulval)

def run_cloudop():
    """
    This function contains the Local Control Code, which will be executed on the 
    End-User's computer. This function will create a computational Project, where
    simple message strings will be transferred between all Jobs in the Project.
    """
    import techila
    
    # Set the number of Jobs to three.
    jobs = 3
    results = techila.peach(funcname = cloudop_dist, # Execute this function on Workers
                            params = ['<vecidx>'],   # Define one input argument for the function.
                            jobs = jobs,             # # Define number of Jobs in the Project.
                            #project_parameters = {'techila_worker_group' : 'IC Group 1'}  # Uncomment to enable. Limit Project to Worker Group 'IC Group 1'.
                            )
                            
    # Print the results.
    for res in results:
        jobid = str(res[0])
        result = str(res[1])
        print('Result from Job #' + jobid  + ': ' + result)
    return(results)
