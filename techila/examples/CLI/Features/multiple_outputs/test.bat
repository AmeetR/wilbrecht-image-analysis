@ECHO OFF
REM Copyright 2011-2013 Techila Technologies Ltd.
REM Set the values of variables 'a' and 'b' based on the values defined
REM in the 'parameters' in the Local Control Code.
set a=%1%
set b=%2%
REM Multiply the variables 'a' and 'b'
set /A result=%a%*%b%
REM Store the result in to the result file called 'output_1', which will
REM be returned from the Worker
echo %result% > output_1
REM Echo the values of the variables. This stdout stream will be stored in
REM a file, which will also be returned from the Worker
echo %a% %b% %result%
