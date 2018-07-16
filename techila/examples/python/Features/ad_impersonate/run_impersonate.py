# Copyright 2015 Techila Technologies Ltd.

""" This script contains the Local Control Code, which can be used to
    create the computational Project.

    To run the example, execute commands:

    execfile('run_impersonate.py')
    result = run_impersonate()

    Example:

    run_impersonate()
"""

# Load the techila library
import techila
import subprocess

def run_impersonate():
    """ Creates computational Project in the Techila environment."""
    
    o,e = subprocess.Popen(['whoami'], stdout=subprocess.PIPE).communicate()
    local_username = o.rstrip()

    worker_username= techila.peach( # Peach function call starts
        funcname = 'impersonate_dist', # Name can be chosen freely
        files = ['impersonate_dist.py'], # Files that will be evaluated on Workers
        project_parameters = {'techila_ad_impersonate':True}, # Enable AD impersonation
        jobs = 1 # Set the number of jobs to 1
        )

    print('Username on local computer: ' + bytes.decode(local_username));
    print('Username on Worker computer: ' + bytes.decode(worker_username[0]));
    return(worker_username)
