# Copyright 2010-2013 Techila Technologies Ltd.

# This R-script contains a code, which will be executed on
# your local computer only.
#
# The R-script named "asian_function.r" contains a computationally
# intensive code, which will be executed according to the
# defined input parameters.
#
# Results will be visualized by displaying a graph on the screen.
#
# Usage:
#
# source("local_asian.r")
# price <- local_asian()

total<-new.env()

local_asian <- function() {
  source("parameters.r")

  source("plotresults.r")
  source("asian_function.r")

  for (i in 1:S0n) {
    for (j in 1:sigma0n) {
      jobprice <- asian_function(S0[i], sigma0[j]^2, M, nn, r, N, rho, kappa, psi, E, T)
      plotresults(list(i_index=i, j_index=j, price=jobprice))
    }
  }
  total$price
}
