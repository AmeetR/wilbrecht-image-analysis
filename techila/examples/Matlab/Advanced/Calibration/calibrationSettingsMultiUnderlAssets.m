function settings = calibrationSettingsMultiUnderlAssets
% In this function, the settings of the calibration problem are specified
%
% Copyright 2017 Juho Kanniainen
% Copyright 2017 Techila Technologies Ltd.

%% GENERAL SETTINGS
% Number of days in a year
settings.tradingDaysInYear = 252;
% Minumum and maximum values of strike prices applied in calibration
settings.StrikeRange = [0.7, 1.3];
% Number of paraller calibrations (with different initial values)
settings.numberOfAssets = 100;

%% MONTE-CARLO SETTINGS
% Number of iterations in Monte-Carlo Simulation
settings.nSim = 10000;
% Seed number for random number generator
settings.seedNumber = 1;

%% MINUMUM AND MAXIMUM VALUES for the parameters of volatility model
settings.minKappa = 0.5; settings.maxKappa = 6;
settings.minTheta = 0.01^2; settings.maxTheta = 1;
settings.minXi = 0.05^2; settings.maxXi = 2;
settings.minRho = -1; settings.maxRho = 1;
settings.minGamma = 0; settings.maxGamma = 1;
settings.minV0 = 0.01^2; settings.maxV0 = 1;
settings.numberOfVariables = 6;

%% SETTINGS FOR INITIAL PARAMETERS
% If uniform distribution is used to generate initial parameter values. If false, normal
% distribution used.
settings.randInitParamUniform = false;
% Standard deviation of random numbers used to generate initial parameteres with normal distribution
settings.stdInitParam = 0; 

%% OPTIMIZATION SETTINGS
settings.calibrOptions.MaxFunEvals = 10; 
settings.calibrOptions.MaxIter = 10; 
settings.calibrOptions.TolFun = 1e-4;
settings.calibrOptions.TolX = 1e-4;

%% DISPLAY SETTINGS, provisional result
settings.displayProvisionalResults = true;

if settings.displayProvisionalResults
    settings.indPlotSurface = 1;
    settings.showParameters = 1;
    settings.calibrOptions.Display = 'iter';
    settings.calibrOptions.FunValCheck = 'on';
else
    settings.indPlotSurface = 0;
    settings.showParameters = 0;
    settings.calibrOptions.Display = 'off';
    settings.calibrOptions.FunValCheck = 'off';
end
end

