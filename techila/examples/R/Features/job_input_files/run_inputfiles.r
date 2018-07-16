# Copyright 2010-2013 Techila Technologies Ltd.

# This function contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# The R-script named "inputfiles_dist" will be distributed and
# executed on Workers. Job specific input files will be transferred
# with each Job, each Job receiving one input file.
#
# To create the Project, use command:
#
# result <- run_inputfiles()
#
# Note: The number of Jobs in the Project will be automatically set to
# four.

# Load the techila library
library(techila)

run_inputfiles <- function() {

  # Set the number of jobs to four
  jobs <- 4

  result <- peach(funcname = "inputfiles_dist", # Name of the executable function
                  files = list("inputfiles_dist.r"), # Files that will be sourced on Workers
                  peachvector = 1:jobs, # Length of the peacvector determines the number of jobs; in this example four (4)
                  sdkroot = "../../../..", # Location of the techila_settings.ini file
                  jobinputfiles = list(  # Job Input Bundle
                    datafiles = list( # Files for the Job Input Bundle
                      "input1.txt",  # File input1.txt for Job 1
                      "input2.txt", # File input2.txt for Job 2
                      "input3.txt", # File input3.txt for Job 3
                      "input4.txt"  # File input4.txt for Job 4
                    ),
                    filenames = list("input.txt") # Name of the file on the Worker side
                  )
                 )
}
