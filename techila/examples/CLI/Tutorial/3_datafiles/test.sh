#!/bin/sh
# Copyright 2011-2013 Techila Technologies Ltd.
# Store the input argument in to variable 'a'. The input argument will be 
# an element of the peachvector as defined in the Local Control Code.
a=$1
# Append the value of variable 'a' to both data files
echo $a >> datafile1
echo $a >> datafile2
# Store a list of files in the temporary directory to the result file
echo The current working directory contains the following files: >> output_1
echo -------------- >> output_1
ls >> output_1
echo -------------- >> output_1
# Store the contents of 'datafile1' to the result file 'output_1'
echo The content of the modified 'datafile1' is: >> output_1
echo -------------- >> output_1
cat datafile1 >> output_1
echo -------------- >> output_1
# Store the contents of 'datafile2' to the result file 'output_1'
echo The content of the modified 'datafile2' is:  >> output_1
echo -------------- >> output_1
cat datafile2 >> output_1
echo -------------- >> output_1
