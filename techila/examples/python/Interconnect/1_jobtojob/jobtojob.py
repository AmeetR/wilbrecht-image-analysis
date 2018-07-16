# This Python script contains the Local Control Code and Worker Code, which will be
# used to perform the computations in the Techila environment.
#
# Usage:
# execfile('jobtojob.py')
# result = run_jobtojob()

# Copyright 2015 Techila Technologies Ltd.

def jobtojob_dist():
    """
    This function contains the Worker Code and will be executed on Techila Workers. 
    The code will transfer simple strings between Job #1 and Job #2 using the Techila
    interconnect functions.
    """
    
    # Import the Techila interconnect functions from the peachclient.py file
    from peachclient import TechilaInterconnect
    
    # Create a TechilaInterconnect object, which contains the interconnect methods.
    ti = TechilaInterconnect()
    
    rcvd = None
    if ti.myjobid == 1:                          # Job #1 will execute this code block
        ti.send_data_to_job(2, 'Hi from Job #1')  # Send message to Job #2
        rcvd = ti.recv_data_from_job(2)           # Receive message from Job #2
    elif ti.myjobid == 2:                        # Job #2 will execute this code block
        rcvd = ti.recv_data_from_job(1)           # Receive message from Job #1 
        ti.send_data_to_job(1, 'Hi from Job #2')  # Send message to Job #1
        
    # Wait until all Jobs have reached this point before continuing
    ti.wait_for_others()
    
    return (ti.myjobid, rcvd)

def run_jobtojob():
    """
    This function will be executed on the End-User's computer
    functions and will be used to create the Project.
    """
    # Load the techila package
    import techila
    
    # Set the number of Jobs to 2
    jobs = 2
    results = techila.peach(funcname = 'jobtojob_dist', # Call this function on Workers
                            files = 'jobtojob.py', # Source this file on Workers
                            jobs = jobs, # Specify Job count (2 in this example)
                            #project_parameters = {'techila_worker_group' : 'IC Group 1'}  # Uncomment to enable. Limit Project to Worker Group 'IC Group 1'.
                            )
    # Print the results
    for res in results:
        jobid = str(res[0])
        jobresult = res[1]
        print('Result from Job #' + jobid + ': ' + jobresult)
    return(results)
