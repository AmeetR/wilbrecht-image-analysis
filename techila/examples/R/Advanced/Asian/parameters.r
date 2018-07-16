# Copyright 2010-2013 Techila Technologies Ltd.

# This file is sourced to set the asian simulation parameters.

S0x1 <- 45
S0x2 <- 47
S0n <- 9
sigma0x1 <- 0.35
sigma0x2 <- 0.4
sigma0n <- 9

S0 <- seq(S0x1, S0x2, length.out = S0n)
sigma0 <- seq(sigma0x1, sigma0x2, length.out = sigma0n)
total$price <- matrix(0, sigma0n, S0n)

M <- 20000
N <- 365
nn <- 1
rho <- -0.5
kappa <- 0.1
psi <- 0.5
E <- 70
T <- 1
r <- 0.05
