import time

def semaphore_dist():    
    from peachclient import TechilaSemaphore
    import os
    
    result=['Results from Job #' + os.getenv('TECHILA_JOBID_IN_PROJECT')]      
    jobStart = time.time()
    with TechilaSemaphore("examplesema") as ts:
        start = time.time()
        genLoad(30);
        twindowstart = start - jobStart
        twindowend = time.time() - jobStart
        result.append('Project-specific semaphore reserved for the following time window: ' + str(round(twindowstart)) + '-' + str(round(twindowend)))
    
    with TechilaSemaphore("globalsema", isglobal = True, ignoreerror = True) as ts:
        if (ts == True):
            # This code block will be executed only if a token was successfully reserved.
            start2 = time.time()
            genLoad(5)
            twindowstart = start2 - jobStart
            twindowend = time.time() - jobStart
            result.append('Global semaphore reserved for the following time window: ' + str(round(twindowstart)) + '-' + str(round(twindowend)))
            
        if (ts == False):
            # This code block will be executed if no token could be reserved
            result.append('Error when using global semaphore')
    return(result)
    
def genLoad(duration):
    import random
    a = time.time()
    while ((time.time() - a) < duration):
        random.random()
    return(0)
