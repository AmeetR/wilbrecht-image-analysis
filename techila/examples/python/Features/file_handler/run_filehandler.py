# Copyright 2012-2016 Techila Technologies Ltd.

# This script contains the Local Control Code, which will be used to create the
# computational Project and post-process the output files.
#
# Usage:
# execfile('run_filehandler.py')
# run_filehandler()

# Import the techila package
import techila

# Load other necessary packages
import os
import shutil

# This function is the filehandler function, which will be
# used to post-process the output files. Function will be called once for
# each output file.
def filehandler_func(file):
  # Display the location of the file on the End-Users computer
  print(file)

  # Display contents of the file
  f = open(file, 'r')
  line = f.readline()
  print(line)
  f.close()

  # Copy the file to the current working directory
  filename = os.path.basename(file)
  shutil.copy(file, os.getcwd())

# This function contains the peach function call, which will be
# used to create the computational Project
def run_filehandler():
    jobs = 5 # Will be used to set the number of Jobs to 5

    result = techila.peach(funcname = 'worker_dist', # Function that will be called on Workers
                           files = 'worker_dist.py', # Files that will be sourced on Workers
                           params = ['<param>'], # Input parameters for the executable function
                           peachvector = range(1, jobs+1), # Set the number of Jobs to 5
                           outputfiles = ['output_file.*;regex=1'], # Files to returned from Workers
                           filehandler = filehandler_func, # Name of the filehandler function
                           )
