function parameters = loadSurfaceParameters(settings, seed)
% This function specifies parameter values used to generate "market data".
%
% Copyright 2017 Juho Kanniainen
% Copyright 2017 Techila Technologies Ltd.

%% Load initial values for parameters    
if settings.randInitParamUniform
    %% Randomized initial parameters with uniform distribution
    rand('state',sum(clock)*seed);
    
    parameters.kappa    = rand*(settings.maxKappa - settings.minKappa) + settings.minKappa;
    parameters.theta    = rand*(settings.maxTheta - settings.minTheta) + settings.minTheta;
    parameters.xi       = rand*(settings.maxXi - settings.minXi) + settings.minXi;
    parameters.rho      = rand*(settings.maxRho - settings.minRho) + settings.minRho;
    parameters.gamma    = rand*(settings.maxGamma - settings.minGamma) + settings.minGamma;
    parameters.V0       = rand*(settings.maxV0 - settings.minV0) + settings.minV0;

else
    %% Randomized initial parameters with normal distribution
    randn('state',sum(clock)*seed);
    
    kappa = 2;       % mean reversion speed of variance
    theta = 0.25^2;  % long term variance
    xi =  0.8;       % volatility of variance
    rho = -.8;       % correlation between returns and variance
    gamma = 0.7;     % second non-affinity coefficient
    V0 = 0.3^2;      % initial volatility
    
    parameters.kappa =   min(max(kappa*(1 + settings.stdInitParam*randn), settings.minKappa), ...
        settings.maxKappa);
    
    parameters.theta =   min(max(theta*(1 + settings.stdInitParam*randn), settings.minTheta), ...
        settings.maxTheta);
    
    parameters.xi =      min(max(xi*(1 + settings.stdInitParam*randn), settings.minXi), ...
        settings.maxXi);
    
    parameters.rho =     min(max(rho*(1 + settings.stdInitParam*randn), settings.minRho), ...
        settings.maxRho);

    parameters.gamma = min(max(gamma*(1 + settings.stdInitParam*randn), settings.minGamma), ...
        settings.maxGamma);
    
    parameters.V0 =      min(max(V0*(1 + settings.stdInitParam*randn), settings.minV0), ...
        settings.maxV0);
    
end
end
