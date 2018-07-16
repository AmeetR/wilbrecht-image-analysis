#!/bin/sh
# Copyright 2011-2013 Techila Technologies Ltd.
# Store the name of the Job specific input files to variables
filename1=$1
filename2=$2
# Store a list of the files in the temporary directory to the
# 'techila_result' file
echo Files in the temporary working directory: > techila_result
ls  >> techila_result
echo Content of the Job Input File "#1" associated with this Job: >> techila_result
# Store the name of the Job-specific input file into the 'techila_result' 
# file
cat "$filename1" >> techila_result
echo Content of the Job Input File "#2" associated with this Job: >> techila_result
# Store the name of the Job-specific input file into the 'techila_result' 
# file
cat "$filename2" >> techila_result
