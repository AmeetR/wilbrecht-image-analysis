# This Python script contains the Local Control Code and Worker Code, which will be
# used to perform the computations in the Techila environment.
#
# Usage:
# execfile('alltoall.py')
# result = run_alltoall()

# Copyright 2015 Techila Technologies Ltd.

def alltoall_dist():
    """
    This function contains the Worker Code and will be executed on Techila Workers. 
    Each Job will transfer a simple string to all other Jobs in the Project using
    the Techila interconnect functions.
    """
    # Import the Techila interconnect functions from the peachclient.py file
    from peachclient import TechilaInterconnect
    
    # Create a TechilaInterconnect object, which contains the interconnect methods.
    ti = TechilaInterconnect()
    
    # Get the Job's index number
    jobidx = ti.myjobid
    
    # Get the number of Jobs in the Project
    jobcount = ti.jobcount
    dataall=[]
    
    # Create message string
    data = 'Hi from Job ' + str(ti.myjobid)
    
    # Send the message string to all other Jobs in the Project
    for src in range(1,jobcount+1):
        for dst in range(1,jobcount+1):
            if src == jobidx and dst != jobidx:
                ti.send_data_to_job(dst,data)
            elif src != jobidx and dst == jobidx:
                recvdata = ti.recv_data_from_job(src)
                dataall.append(recvdata)
            else:
                print('Do nothing')
                
    # Wait until all Jobs have reached this point before continuing
    ti.wait_for_others()
    
    return (jobidx, dataall)

def run_alltoall():
    """
    This function contains the Local Control Code, which will be executed on the 
    End-User's computer. This function will create a computational Project, where
    simple message strings will be transferred between all Jobs in the Project.
    """
    import techila
    
    # Set the number of Jobs to four.
    jobs = 4
    
    results = techila.peach(funcname = 'alltoall_dist', # Execute this function on Workers
                            files = ['alltoall.py'], # Source this file on Workers
                            jobs = jobs, # Define the number of Jobs
                            #project_parameters = {'techila_worker_group' : 'IC Group 1'}  # Uncomment to enable. Limit Project to Worker Group 'IC Group 1'.
                            )
    # Print the results
    for res in results:
        jobid = str(res[0])
        result = str(res[1])
        print('Result from Job #' + jobid  + ': ' + result)
    return(results)
