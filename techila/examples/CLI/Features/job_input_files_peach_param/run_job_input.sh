#!/bin/sh
# Copyright 2011-2013 Techila Technologies Ltd.
techila="java -jar ../../../../lib/techila.jar"
# Define that 'test.bat' will be executed on Windows Workers and 'test.sh' on
# Linux Workers.
command="test.bat;osname=Windows,test.sh;osname=Linux" 

# Define that a file called 'techila_result' is the output file. This
# file will be returned from the Workers to the Techila Server and 
# transferred back to your computer.
outputfiles="output;file=techila_result" 

# Specify that the list of files to be stored in the Job Input Bundle will
# be read from stdin given to the command.
jobinputfiles="<stdin>"

# Specify that the Job-specific input files should be renamed to 'data1' and
# 'data2' after the files have been transferred to the Worker.
jobinputfilenames="data1 data2"

# Input parameters for the executable. In each Job, the executable script 
# will be given two input arguments. The input arguments 'data1' and 'data2'
# corresponds to the names of the Job-specific input files as defined 
# in the parameter 'jobinputfilenames'.
parameters="data1 data2" 

# Define that only Linux and Windows Workers can be assigned Jobs.
platform="Windows;Linux" 

# Create the Project with the 'peach' command using the parameters defined 
# earlier in the batch file. The output of 'ls file*' command will be 
# used to construct the list of files that be stored in the Job Input Bundle.
ls file* | $techila peach command=$command \
parameters="$parameters" outputfiles="$outputfiles" \
jobinputfiles="$jobinputfiles" jobinputfilenames="$jobinputfilenames" \
platform="$platform"
