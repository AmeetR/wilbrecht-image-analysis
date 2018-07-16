@ECHO OFF
REM Copyright 2011-2013 Techila Technologies Ltd.
REM Store the name of the Job specific input files to variables
set filename1=%1%
set filename2=%2%

REM Store a list of the files in the temporary directory to the
REM 'techila_result' file
echo Files in the temporary working directory: > techila_result
dir  >> techila_result
echo Content of the Job Input File #1 associated with this Job: >> techila_result
REM Store the name of the Job-specific input file into the 'techila_result' 
REM file
type %filename1% >> techila_result
echo Content of the Job Input File #2 associated with this Job: >> techila_result
REM Store the name of the Job-specific input file into the 'techila_result' 
REM file
type %filename2% >> techila_result
