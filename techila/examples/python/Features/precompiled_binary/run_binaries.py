# Copyright 2012-2016 Techila Technologies Ltd.

""" This script contains the Local Control Code, which can be used to
    create the computational Project.

    To run the example, execute commands:

    execfile('run_binaries.py')
    result = run_binaries()

    Input arguments:

    jobcount: defines the number of Jobs in the Project
    loops: defines the number of iterations performed in each Job

    Example:

    run_binaries(jobcount = 20, loops = 100000000)
"""

# Load the techila library
import techila

def fh(file):
    """ Used to process each output file that will be returned from the Workers;
    return a list containing values read from the file. """

    # Read values returned from the Worker
    f = open(file, 'r')
    l = f.readline()
    f.close()

    values = l.split() # Parse values read from the file
    in_points = int(values[0]) # Points inside unitary circle
    all_points = int(values[1]) # Iterations performed in the job

    # Print information where the temporary output file is located on
    # End-Users computer and the content of the file.
    print('Path of the output file:\n', file)
    print('Values read from the output file:\n', l)

    # Return values read from the file.
    return (in_points, all_points)

def run_binaries(jobcount = 20, loops = 100000000):
    """ Creates computational Project in the Techila environment; return an
    integer containg approximated value of Pi."""


    results = techila.peach( # Peach function call starts
        executable = True, # Define that we're using a precompiled executable
        python_required = False, # Python runtime libraries not required on Workers
        funcname = 'Precompiled binary', # Name can be chosen freely
        binaries = [{'file': 'mcpi', 'osname': 'Linux'}, # Execute 'mcpi' binary on Linux Workers
                    {'file': 'mcpi.exe', 'osname': 'Windows'}], # Execute 'mcpi.exe' binary on Windows Workers
        project_parameters = {'loops':loops}, # Define value for the 'loops' input argument
        outputfiles = ['output;file=output.data'],
        params = '%P(jobidx) %P(loops) %O(output)', # Input arguments given to the executable binary
        jobs = jobcount, # Set the number of jobs based on the value of the input argument
        filehandler = fh, # Use funtion 'fh' to process each output file returned from Workers
        stream = True, # Enable streaming
        )

    # Permute results returned by the peach function
    (in_points, all_points) = map(lambda *x:x ,*results)

    # Sum values received from jobs and calculate an approximated value for Pi
    pivalue = 4 * float(sum(in_points)) / float(sum(all_points))

    # Print and returnt the value of the approximation
    print('Approximated value of Pi ', pivalue)
    return(pivalue)

