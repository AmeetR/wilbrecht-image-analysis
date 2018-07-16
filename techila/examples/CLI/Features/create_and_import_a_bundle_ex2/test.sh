#!/bin/sh
# Copyright 2011-2013 Techila Technologies Ltd.
# Get the location of the files on the Worker by expanding the %L()
# notation in the 'parameters' parameter in the 'commands' file.
location=$1
# Set value of the 'filename' variable according to the peachvector
# element for the Job
filename=$2
echo Location of the files in the Bundle on the worker is: >> output_1
# Store the location of the files on the Worker to the 'output_1' file
echo $location >> output_1
echo Files in the directory: >> output_1
# Store a list of files in the directory to the 'output_1' file
ls $location >> output_1
echo Content of file named "$filename": >> output_1
# Store the content of the file 'output_1' file. Job #1 will display
# content of 'datafile1', Job #2 for 'datafile2'
cat $location/$filename >> output_1
