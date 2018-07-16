# Copyright 2017 Verhoog Consultancy
# Copyright 2017 Techila Technologies Ltd.

# Uncomment to install required packages if required.
# install.packages("R.utils")
# install.packages("rJava")
# install.packages("plyr")
# install.packages("pracma")
# install.packages("mvtnorm")
# install.packages("MASS")

# Create a global variable to store intermediate results.
total <- new.env()

cbfun <- function(portfolioValue) {
  # Function for updating the P&L histogram based on the scenario data
  # computed so far.
  total$list[total$idx] <- portfolioValue
  total$idx <- total$idx + 1

  if ((total$idx %% total$inter) == 0) {
    # Only update figure if we have a nice amount of new data points.
    histdata <- total$list - total$bpv
    portfolioValueDiff <- histdata[(histdata != -total$bpv)]
    par(mfrow = c(1, 2))
    hist(portfolioValueDiff,
         breaks = 100,
         col = "lightblue",
         prob = TRUE,
         main = "Profit & Loss Distribution") # exclude zeros
    lines(density(portfolioValueDiff))
    hist(portfolioValueDiff,
         breaks = 100,
         xlim = sort(portfolioValueDiff)[c(ceiling(0.001 * length(portfolioValueDiff)), ceiling(0.01 * length(portfolioValueDiff)))],
         col = "lightblue",
         prob = TRUE,
         main = "Profit and Loss Distribution 0.1-1% percentile",
         ylim = c(0, max(density(portfolioValueDiff)$y) / 10)) # exclude zeros
    lines(density(portfolioValueDiff))
    text(sort(portfolioValueDiff)[0.004 * length(portfolioValueDiff)],
         max(density(portfolioValueDiff)$y) / 12,
         paste("VaR 99.5% = ",
               as.character(round(-quantile(portfolioValueDiff, 0.005) / 1000000)),
               "M",
               sep = ""))

    # Allow figure time to update
    Sys.sleep(0.1)
  }
  portfolioValue
}


run_VaR_cloudfor <- function() {
  # Function for creating the computational Project.

  # Load libraries and functions
  library(techila)
  library(pracma)
  library(stats)
  library(mvtnorm)
  library(MASS)
  source("bs_function.r")

  # Load parameters with market data, scenario data, instrument data
  # and position data
  source("parameters.r")

  # Determine base portfolio value, value without changes in market data
  # Calculate options values
  rate <- interp1(ir.t, ir.r, option.Maturity, method = "linear")
  vol <- interp2(iv.t,
                 iv.M,
                 iv.sigma,
                 option.Maturity,
                 pmax(pmin(S0/K, max(iv.M)), min(iv.M)))
  baseOptionValue <- sum(bs_function(S0,
                                     K,
                                     option.Maturity,
                                     rate,
                                     vol,
                                     isCall)
                         * pos[1:nrOfOptions])

  # Calculate bond values
  rate <- matrix(interp1(ir.t,
                         ir.r,
                         couponTimes,
                         method = "linear"),
                 dim(couponTimes)[1],
                 dim(couponTimes)[2])
  baseBondValue <- sum(apply(CFs * exp(-couponTimes * rate / 100), 1, sum)
                       * pos[(1 + nrOfOptions):(nrOfOptions + nrOfBonds)])

  # Calculate total portfolio value
  basePortfolioValue <- baseOptionValue + baseBondValue

  # Initialize the global variable used to store result data
  total$bpv <- basePortfolioValue
  total$list <- vector('double', nrOfScenarios)
  total$idx <- 1

  # Number of times to update graph during computations
  updateCount <- 100
  total$inter <- floor(nrOfScenarios / updateCount)

  # Cloudfor used to create the computational Project. Cloudfor
  # parameters explained:
  # .steps = 100               Will calculate 100 iterations per Job
  # .stream = TRUE             Results will be streamed to your computer as soon Jobs are completed
  # .callback = "cbfun"        Defines that function "cbfun" will be used update the result histogram
  # .packages=list("pracma")   Transfer pracma package to Techila Workers
  portfolioValue <- cloudfor(i = 1:nrOfScenarios,
                             .steps = 100,
                             .stream = TRUE,
                             .callback = "cbfun",
                             .packages=list("pracma")
  ) %t% {

    # Apply scenario on the interest rate curve
    PCAshock <- scenarios[i, 1] * PCA1 + scenarios[i, 2] * PCA2 + scenarios[i, 3] * PCA3
    rateShock <- exp(interp1(PCA.t, PCAshock, ir.t, method = "spline"))
    shockedRate <- ((ir.r + ir.displacement) * rateShock) - ir.displacement

    # Option valuation under the different scenarios
    rate <- interp1(ir.t,
                    shockedRate,
                    option.Maturity,
                    method = "linear")
    vol <- interp2(iv.t,
                   iv.M,
                   scenarios[i, 5] * vol.shock.surface * iv.sigma,
                   option.Maturity,
                   pmax(pmin(S0 * scenarios[i, 4] / K, max(iv.M)), min(iv.M)))
    p_options <- bs_function(S0 * scenarios[i, 4],
                             K,
                             option.Maturity,
                             rate,
                             vol,
                             isCall)

    # Bond valuation under the different scenarios
    rate <- matrix(interp1(ir.t, shockedRate, couponTimes, method = "linear"), dim(couponTimes)[1], dim(couponTimes)[2])
    p_bonds <- apply(CFs * exp(-couponTimes * rate / 100), 1, sum)

    # Return the result
    portfolioValue <- pos %*% c(p_options, p_bonds)

  }

  PnL_distribution <- sort(portfolioValue - basePortfolioValue)

  # Computation done, plot final histogram and calculate quantiles
  par(mfrow = c(1, 2))
  
  # Plot entire histogram
  hist(PnL_distribution,
       breaks = 100,
       col = "lightblue",
       prob = TRUE,
       main = "Profit & Loss Distribution",
       freq = FALSE)
  lines(density(PnL_distribution))
  
  # Plot histogram tail
  hist(PnL_distribution,
       breaks = 100,
       xlim = sort(PnL_distribution)[c(0.001 * length(PnL_distribution), 0.01 * length(PnL_distribution))],
       col = "lightblue",
       prob = TRUE,
       main = "Profit and Loss Distribution 0.1-1% percentile",
       freq = FALSE,
       ylim = c(0, max(density(PnL_distribution)$y) / 10))
  lines(density(PnL_distribution))
  
  # Display additional info
  text(sort(PnL_distribution)[0.004 * length(PnL_distribution)],
       max(density(PnL_distribution)$y) / 12,
       paste("VaR 99.5% = ",
             as.character(round(-quantile(PnL_distribution, 0.005) / 1000000)),
             "M",
             sep = ""))
  print(quantile(PnL_distribution, c(0.001, 0.005, 0.01, 0.1, 0.25, 0.5, 0.75, 0.9, 0.99, 0.995, 0.999)))
}

