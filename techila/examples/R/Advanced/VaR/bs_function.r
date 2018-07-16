# Copyright 2017 Verhoog Consultancy
# Copyright 2017 Techila Technologies Ltd.

bs_function <- function(S0,K,t,r,sigma,call) {
  
  price <- vector(mode="numeric", length=length(S0))
  
  d1 <- 1/(sigma*sqrt(t))*(log(S0/K)+(r+(sigma^2)/2)*t)
  d2 <- d1-sigma*sqrt(t)
  
  price[call==T] <- pnorm(d1[call==T],0,1)*S0[call==T]-pnorm(d2[call==T])*K[call==T]*exp(-r[call==T]*t[call==T])
  price[call==F] <- pnorm(-d2[call==F])*K[call==F]*exp(-r[call==F]*t[call==F])-pnorm(-d1[call==F],0,1)*S0[call==F]
  
  return(price)
}
