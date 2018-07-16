@ECHO OFF
REM Copyright 2011-2013 Techila Technologies Ltd.
REM Set the value of variables 'a' and 'b'
set a=1
set b=2
REM Calculate the sum of variables 'a' and 'b'
set /A sum=%a%+%b%
REM Store the result into the 'output_1' file
echo %sum% > output_1
