# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# The R-script named "mcpi_dist.r" will be distributed and executed
# Workers. Several consecutive Projects will be created, during which
# the value of Pi will be calculated using the Monte Carlo method.
# Results of the Projects will be used to improve the accuracy of the
# approximation. Projects will be created until the amount of error in
# the approximation is below the threshold value.
#
# To create the Projects, use command:
#
# result <- run_iterative()
#
# Note: The number of Jobs in the Project will be automatically set to
# 20.

library(techila)

run_iterative <- function() {
  threshold <-  0.0003  # Maximum allowed error
  jobs <- 20            # Number of Jobs
  loops <- 1e5          # Number of iterations performed in each Job
  total_result <- 0     # Initial result when no approximations have been performed.
  iteration <- 1        # Project counter, first Project will
  current_error <- pi   # Initial error, no approximations have been performed

  while ( abs(current_error) >= threshold ) {

    result <- peach(funcname = "mcpi_dist", # Function that will be executed
                    params = list(loops, "<param>", iteration), # Input parameters for the executable function
                    files = list("mcpi_dist.r"), # Files that will be sourced on Workers
                    peachvector = 1:jobs, # Length of the peachvector is 20 -> set the number of Jobs to 20
                    sdkroot = "../../../..", # Location of the techila_settings.ini file
                    donotuninit = TRUE,  # Do not uninitialize the Techila environment after completing the Project
                    messages = FALSE # Disable message printing
                   )

    # If result is NULL after peach exits, stop creating projects.
    if (is.null(result)) {
      uninit()
      stop("Project failed, stopping example.")			   
    }

    total_result <- total_result + sum(as.numeric(result)) # Update the total result based on the project results
    approximated_pi <- total_result * 4 / (loops * jobs * iteration)  # Update the approximation value
    current_error <- approximated_pi - pi   # Calculate the current error in the approximation
    print(paste("Amount of error in the approximation = ", current_error))  # Display the amount of current error
    iteration <-iteration+1 # Store the number of completed projects
  }
  # Display notification after the threshold value has been reached
  print("Error below threshold, no more Projects needed.")
  uninit()
  current_error
}
