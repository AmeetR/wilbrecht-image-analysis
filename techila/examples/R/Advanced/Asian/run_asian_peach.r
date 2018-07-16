# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains the Local Control Code, which will be used to
# distribute computations to the Techila environment.
#
# The R-script named "asian_function.r" will be distributed to Workers,
# where the function asian_haj will be executed according to the
# defined input parameters.
#
# The peachvector will be used to control the number of Jobs in the
# Project.
#
# Results will be visualized by displaying a graph on the screen.
#
# Usage:
#
# source("run_asian_peach.r")
# price <- run_asian_peach()

# Load the techila library
library(techila)

total<-new.env()


# asian_wrapper is used to wrap the actual call to the asian_function.
asian_wrapper <- function(S0, sigma0, M, nn, r, N, rho, kappa, psi, E, T, jobidx) {

  sub <- ind2sub(c(length(S0), length(sigma0)), jobidx)

  i <- sub[1]
  j <- sub[2]

  jobprice <- asian_function(S0[i], sigma0[j]^2, M, nn, r, N, rho, kappa, psi, E, T)

  list(i_index=i, j_index=j, price=jobprice)
}

run_asian_peach <- function() {
  source("parameters.r")

  source("plotresults.r")

  sdkroot <- "../../../../"; # Techila SDK root

  peach(funcname = asian_wrapper, # Function executed on Workers
        params = list(S0, sigma0, M, nn, r, N, rho, kappa, psi, E, T, "<param>"), # Input parameters for the executable function
        files = list("asian_function.r"), # Files that will be sourced on Workers
        peachvector = 1:(S0n * sigma0n), # Determines the number of Jobs. Elements used as input parameters.
        stream = TRUE, # Enable streaming
        callback = "plotresults", # Name of the callback
        sdkroot = sdkroot) # Location of the techila_settings.ini file

  total$price
}
