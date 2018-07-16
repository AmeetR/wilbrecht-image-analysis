# Copyright 2012-2013 Techila Technologies Ltd.

# This Python-script will be evaluted at the preliminary stages of a
# computational Job. When evaluated, two functions will be defined.
# Either one of these functions can be then used as an entry point 
# by defining the applicable function name  as the value of
# the funcname parameter in the Local Control Code.

def function1():
    # When called, this function will return the value 2.
    return(1 + 1)

def function2():
    # When called, this function will return the value 100.
    return(10 * 10)
