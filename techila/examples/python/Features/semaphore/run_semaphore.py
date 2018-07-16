def run_semaphore():
    import techila
    jobs = 4
    results = techila.peach(funcname = 'semaphore_dist',
                            files = ['semaphore_dist.py'],
                            jobs = jobs,
                            project_parameters =
                            {
                                'techila_semaphore_examplesema' : '2',
                            }
                            )
    for jobresult in results:
        for message in jobresult:
            print(message)
    
    return results
