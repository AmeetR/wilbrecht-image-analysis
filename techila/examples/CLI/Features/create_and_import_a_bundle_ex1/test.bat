@ECHO OFF
REM Copyright 2011-2013 Techila Technologies Ltd.
REM Store the input argument in to variable 'a'. The input argument will be 
REM an element of the peachvector.
set a=%1%
REM Append the value of variable 'a' to both data files
echo %a% >> datafile1
echo %a% >> datafile2
REM Store a list of files in the temporary directory to the result file
echo The current working directory contains the following files: >> output_1
echo -------------- >> output_1
dir /b >> output_1
echo -------------- >> output_1
REM Store the contents of 'datafile1' to the result file 'output_1'
echo The content of the modified 'datafile1' is: >> output_1
echo -------------- >> output_1
type datafile1 >> output_1
echo -------------- >> output_1
REM Store the contents of 'datafile2' to the result file 'output_1'
echo The content of the modified 'datafile2' is:  >> output_1
echo -------------- >> output_1
type datafile2 >> output_1
echo -------------- >> output_1
