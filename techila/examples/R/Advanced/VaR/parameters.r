# Copyright 2017 Verhoog Consultancy
# Copyright 2017 Techila Technologies Ltd.

# This file is sourced to set the parameters for the VaR simulations

# Number of scenarios. This value defines the amount of computational
# work done during the Project. You can modify this value to either
# increase or decrease the amount of work done.
# Recommended range: 10000 - 1000000
nrOfScenarios <- 10000

# Set parameters
nrOfOptions <- 2000
nrOfBonds <- 10000

# Create set of market data

# Interest rate
ir.t <- c(1 / 365.25, 1, 2, 3, 4, 5, 10, 20, 30)
ir.r <- c(0, 0.04, 0.07, 0.09, 0.11, 0.12, 0.15, 0.2, 0.22)
# Vol surface
iv.t <- c(1 / 365.25, 1, 2, 3, 4, 5)
iv.M <- c(0.5, 0.75, 1, 1.25, 1.5)
iv.sigma <- matrix(c(0.29, 0.29, 0.23, 0.20, 0.184, 0.175,
                     0.26, 0.26, 0.21, 0.19, 0.182, 0.172,
                     0.25, 0.25, 0.20, 0.19, 0.180, 0.170,
                     0.25, 0.25, 0.21, 0.19, 0.181, 0.171,
                     0.28, 0.28, 0.22, 0.19, 0.182, 0.173),
                   length(iv.M),
                   length(iv.t),
                   byrow = TRUE)

# Instrument definition

# Create set of random options
S0 <- pmax(0, 100 * (rlnorm(nrOfOptions, 0, 0.5)))
K <- pmax(0, S0 * rnorm(nrOfOptions, 1, 0.05))
option.Maturity <- pmax(1 / 365.25,runif(nrOfOptions)*3)
isCall <- sample(c(TRUE, FALSE), replace = TRUE, nrOfOptions)

# Create set of random bonds
bond.Maturity <- sample(seq(as.Date('2017/04/01'), as.Date('2047/03/31'), by="day"), nrOfBonds, replace = TRUE)
currentDate <- as.Date("2017-03-31")
couponRate <- sample(seq(1, 5, 0.05), nrOfBonds, replace = TRUE) / 100

# Calculate CFs for bonds
couponTimes <- matrix(data = NA,
                      nrOfBonds,
                      length(seq(max(bond.Maturity),
                                 currentDate,
                                 by = "-6 months")))
CFs <- matrix(data = NA,
              nrOfBonds,
              length(seq(max(bond.Maturity),
                         currentDate,
                         by = "-6 months")))
for (i in 1:nrOfBonds) {
  couponDates <- seq(bond.Maturity[i], currentDate, by = "-6 months")
  couponTimes[i, 1:length(couponDates)] <- as.numeric(couponDates - currentDate) / 365.25;
  CFs[i, 1:length(couponDates)] <- couponRate[i] / 2
  CFs[i, 1] <- CFs[i, 1] + 1
}
# Avoid issues with interpolating NA, set CFs to zero
couponTimes[is.na(couponTimes)] <- 1
couponTimes[couponTimes == 0] <- 1
CFs[is.na(CFs)] <- 0


# Create a random position matrix
pos <- c(sample(seq(-5000, 5000, 100),
                nrOfOptions,
                replace = TRUE),
         sample(seq(10000, 1000000, 10000),
                nrOfBonds,
                replace = TRUE))

# Scenario definition
# 3 interest rate PCA factor, equity vol, vol vol)
scenarios <- cbind(rnorm(nrOfScenarios,0,0.15),
                   rnorm(nrOfScenarios, 0, 0.01),
                   rnorm(nrOfScenarios, 0, 0.001),
                   rlnorm(nrOfScenarios, 0, 0.20),
                   rlnorm(nrOfScenarios, 0, 0.25))

# Interest rate PCA factor that define how ir curve is shocked
PCA.t <- c(1 / 365.25, 3 / 12, 6 / 12, 1, 5, 10, 30)
PCA1 <- c(-0.3, -0.3, -0.3, -0.3, -0.3, -0.3, -0.3)
PCA2 <- c(0.7, 0.5, 0.2, 0.1, -0.15, -0.18, -0.2)
PCA3 <- c(0.6, -0.3, -0.5, -0.35, -0.1, 0.15, 0.25)
ir.displacement <- 4

# Matrix that defines how vol surface is shocked
vol.shock.surface <- matrix(c(1.25, 1.25, 1.07, 0.97, 0.86, 0.74,
                              1.10,1.10, 1.05, 0.95, 0.84, 0.73,
                              1.05,1.05, 1.00, 0.90, 0.80, 0.70,
                              1.07,1.07, 1.04, 0.93, 0.83, 0.72,
                              1.12,1.12, 1.06, 0.95, 0.84, 0.73),
                            5,
                            6,
                            byrow = TRUE)
