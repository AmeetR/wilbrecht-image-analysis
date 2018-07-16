# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains the Local Control Code, which will be used to
# distribute computations to the Techila environment using cloudfor.
#
# The R-script named "asian_function.r" will be sourced and call to
# the "asian_function" is used inside the cloudfor loops.
#
# Results will be visualized by displaying a graph on the screen.
#
# Usage:
#
# source("run_asian_cloudfor.r")
# price <- run_asian_cloudfor()

library(techila)

total <- new.env()

run_asian_cloudfor<- function() {
  source("parameters.r")

  source("plotresults.r")
  source("asian_function.r")

  cloudfor(i = 1:length(S0)) %to%
  cloudfor(j = 1:length(sigma0),
           .callback = plotresults,
           .stream = TRUE,
           .sdkroot="../../../../"
           ) %t% {

    jobprice <- asian_function(S0[i], sigma0[j]^2, M, nn, r, N, rho, kappa, psi, E, T)
    list(i_index=i, j_index=j, price=jobprice)
  }

  total$price
}
