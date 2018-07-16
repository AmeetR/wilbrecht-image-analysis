# Copyright 2010-2013 Techila Technologies Ltd.

# compute a price for a single point with given parameters

asian_function <- function(S0,v0,M,nn,r,N,rho,kappa,psi,E,T) {

  Dt <- 1/N/nn
  x <- matrix(0,N,1)
  Csum <- 0
  for (m in 1:M) {
    w <- matrix(rnorm(N*nn),N,nn)
    y <- matrix(rnorm(N*nn),N,nn)
    z <- rho*w+sqrt(1-rho^2)*y
    v <- v0
    x[1] <- 0
    xx <- x[1]
    for (j in 1:(N-1)) {
      for (k in 1:nn) {
        xx <- xx+(r-0.5*v)*Dt+sqrt(v*Dt)*w[j,k]
        v <- max(0,v+kappa*(v0-v)*Dt+psi*sqrt(v*Dt)*z[j,k]+0.25*psi^2*Dt*(z[j,k]^2-1))
      }
      x[j+1] <- xx
    }
    S <- S0*exp(x)
    Csum <- Csum + max(sum(S)/N-E,0)
  }
  price <- exp(-r*T)*Csum/M
  return(price)
}
