# Copyright 2016 Techila Technologies Ltd.

# This R-script contains the Local Control Code, which will be used to
# distribute computations to the Techila environment using plyr.
#
# The R-script named "asian_function.r" will be sourced and call to
# the "asian_function" is used inside the plyr.
#
# Results will be visualized by displaying a graph on the screen.
#
# Usage:
#
# source("run_asian_plyr.r")

library(plyr)
library(techila)

total <- new.env()

source("asian_function.r");
source("parameters.r")
source("plotresults.r")

wrapPlotResults <- function(preresult) {
  result<-data.frame(price=preresult[[1]]$price,
                     j_index=match(preresult[[1]]$S0,S0),
                     i_index=match(preresult[[1]]$v0,sigma0^2))
  result$price = result$price + total$price[result$j_index,result$i_index];
  plotresults(result)
  preresult
}

wrapAsian <- function(S0,v0,M,nn,r,N,rho,kappa,psi,E,T) {
  price<-asian_function(S0,v0,M,nn,r,N,rho,kappa,psi,E,T)
  result<-data.frame(price=price,S0=S0,v0=v0)
}

#registerDoTechila(packages=list("plyr"), sdkroot = "../../../..")
registerDoTechila(sdkroot = "../../../..")

p <- expand.grid(S0=S0, v0=sigma0^2)

price<-maply(p, wrapAsian, M, nn, r, N, rho, kappa, psi, E, T,
      .parallel = TRUE, .paropts=list(.options.callback=wrapPlotResults,
                                      .options.files=list('asian_function.r')))

price

