run_semaphore <- function() {
  # This function contains the cloudfor-loop, which will be used to distribute
  # computations to the Techila environment.
  #
  # During the computational Project, semaphores will be used to limit the number
  # of simultaneous operations in the Project.
  #
  # Syntax:
  #
  # result = run_semaphore()

  # Copyright 2015 Techila Technologies Ltd.

  # Load the techila package
  library(techila)
  
  # Set the number of loops to four
  loops <- 4
  results <-  cloudfor (i=1:loops, # Loop contains four iterations
                        .ProjectParameters = list("techila_semaphore_examplesema" = "2"), # Create Project-specific semaphore named 'examplesema', which will have two tokens.
                        .sdkroot="../../../..", # Location of the Techila SDK 'techila' directory
                        .steps=1 # Perform one iteration per Job 
                        ) %t% {
    result <- list()
    
    # Get current timestamp. This marks the start time of the Job.
    jobStart <- proc.time()[3]
    
    # Reserve one token from the Project-specific semaphore
    techila.smph.reserve("examplesema")
    
    # Get current timestamp. This marks the time when the semaphore token was reserved.
    tstart <- proc.time()[3]
    
    # Generate CPU load for 30 seconds.
    genload(30) 
    
    # Calculate a time window during which CPU load was generated.
    twindowstart <- tstart - jobStart
    twindowend <- proc.time()[3] - jobStart
    
    # Build a result string, which includes the time window
    result <- c(result, paste("Project-specific semaphore reserved for the following time window: ", twindowstart, "-", twindowend, sep=""))
    
    # Release the token from the Project-specific semaphore 'examplesema'
    techila.smph.release("examplesema");
    
    # Attempt to reserve a token from a global semaphore named 'globalsema'
    reservedok = techila.smph.reserve("globalsema", isglobal=TRUE, ignoreerror=TRUE)
    if (reservedok) { # This code block will be executed if the semaphore was reserved successfully.
      start2 = proc.time()[3]
      genload(5)
      twindowstart = start2 - jobStart
      twindowend = proc.time()[3] - jobStart
      techila.smph.release("globalsema",isglobal=TRUE)
      result <- c(result,paste("Global semaphore reserved for the following time window:", twindowstart,"-", twindowend,sep=""))    }
    else if (!reservedok) { # This code block will be executed if there was a problem in reserving the semaphore.
      result <- c(result,"Error when using global semaphore.")
    }
    result
  }
  results
  for (x in 1:length(results)) {
    jobres = unlist(results[x])
    cat("Results from Job #", x,"\n", sep="")
    print(jobres)
  }
}

genload <- function(duration) {
  st <- proc.time()[3]
  while ((proc.time()[3] - st) < duration) {
    runif(1)
  }
}
