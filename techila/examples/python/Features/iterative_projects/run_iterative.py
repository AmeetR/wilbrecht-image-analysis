# Copyright 2012-2016 Techila Technologies Ltd.

# This Python script contains the Local Control Code, which will be
# used to distribute computations to the Techila environment.
#
# The Python script named 'mcpi_dist.py' will be distributed and
# evaluated Workers. Several consecutive Projects will be created,
# during which the value of Pi will be calculated using the Monte
# Carlo method. Results of the Projects will be used to improve the
# accuracy of the approximation. Projects will be created until the
# amount of error in the approximation is below the threshold value.
#
# Usage:
# execfile('run_iterative.py')
# result=run_iterative()
#
# Note: The number of Jobs in the Project will be automatically set to
# 20.

import math
import techila

def run_iterative():
  threshold = 0.00004      # Maximum allowed error
  jobs = 20                # Number of Jobs
  loops = 1e7              # Number of iterations performed in each Job
  total_result = 0         # Initial result when no approximations have been performed.
  iteration = 1            # Project counter, first Project will
  current_error = math.pi  # Initial error, no approximations have been performed

  techila.init()

  while abs(current_error) >= threshold:

      result = techila.peach(
          funcname = 'mcpi_dist', # Function that will be executed
          params = [loops, '<param>', iteration], # Input parameters for the executable function
          files = ['mcpi_dist.py'], # Files that will be evaluated on Workers
          peachvector = range(1, jobs + 1), # Length of the peachvector is 20 -> set the number of Jobs to 20
          messages = False, # Disable message printing
          )

      # If result is None after peach exits, stop creating projects.
      if result == None or len(result) == 0:
          break

      total_result = total_result + sum(result) # Update the total result based on the project results
      approximated_pi = float(total_result) * 4 / (loops * jobs * iteration)  # Update the approximation value
      current_error = approximated_pi - math.pi   # Calculate the current error in the approximation
      print('Amount of error in the approximation = ', current_error)  # Display the amount of current error
      iteration = iteration + 1 # Store the number of completed projects

  # Display notification after the threshold value has been reached
  print('Error below threshold, no more Projects needed.')
  techila.uninit()
  return current_error
