# Copyright 2012-2013 Techila Technologies Ltd.

# This function contains the function that will be executed
# during computational Jobs. Each Job will generate one output file, which
# will be named according to the value of the 'jobidx' variable.
def worker_dist(jobidx):
  # Generate a sample string that will be stored in the output file
  sample1 = 'This file was generated in Job: ' + str(jobidx)

  # Create the output file
  f = open('output_file' + str(jobidx), 'w')
  # Write the string the output file
  f.write(sample1)
  f.close
