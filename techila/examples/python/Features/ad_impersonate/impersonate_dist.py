def impersonate_dist():
    import subprocess
    o,e = subprocess.Popen(['whoami'], stdout=subprocess.PIPE).communicate()
    worker_useraccount = o.rstrip()
    return(worker_useraccount)