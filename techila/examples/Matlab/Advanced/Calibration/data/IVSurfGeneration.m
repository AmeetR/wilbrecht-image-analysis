% This script generates implied volatility surfaces for given model parameters. The output data is
% used as a "market data" for which the models are calibrated.
%
% Copyright 2017 Juho Kanniainen
% Copyright 2017 Techila Technologies Ltd.

%% Settings
clear all; close all;

% GENERAL
settings.numberOfAssets = 100;
settings.tradingDaysInYear = 252;
settings.nSim = 200000;

% MINUMUM AND MAXIMUM VALUES for the parameters of volatility model
settings.minKappa = 0.5; settings.maxKappa = 6;
settings.minTheta = 0.01^2; settings.maxTheta = 1;
settings.minXi = 0.05^2; settings.maxXi = 2;
settings.minRho = -1; settings.maxRho = 1;
settings.minGamma = 0; settings.maxGamma = 1;
settings.minV0 = 0.01^2; settings.maxV0 = 1;
settings.numberOfVariables = 6;

% SETTINGS FOR INITIAL PARAMETERS
% If uniform distribution is used to generate initial parameter values. If false, normal
% distribution used.
settings.randInitParamUniform = false;
% Standard deviation of random numbers used to generate initial parameteres with normal distribution
settings.stdInitParam = 0.4;

% SETTINGS FOR MATURITY TIMES AND STRIKES
settings.T_range = [3*21, 6*21, 9*21, 12*21, 1.5*12*21, 2*12*21, 3*12*21, 5*12*21, 10*12*21, 20*12*21]'/settings.tradingDaysInYear;
settings.K_range = [0.5:0.1:1.5]';


for assetNum = 1:settings.numberOfAssets
    
    seed = assetNum;
    
    IVolPassed = false;
    while IVolPassed == false
        parameters = loadSurfaceParameters(settings, seed);
        disp([assetNum, [parameters.kappa, parameters.theta, parameters.xi, parameters.rho,parameters.gamma, parameters.V0]]);
        
        T = []; K = [];
        for i = 1:length(settings.T_range)
            for j = 1:length(settings.K_range)
                T = [T; settings.T_range(i)];
                K = [K; settings.K_range(j)];
            end
        end
        
        S0 = ones(size(T));
        r = 0.01*ones(size(T));
        
        %% Call prices
        callPrices = MonteCarloPricing(S0, K, r, T, parameters, ...
            settings.nSim, seed, settings.tradingDaysInYear);
        
        %% Implied volatilities
        IVol = blsimpv(S0, K, r, T, callPrices);
        if min(IVol) > 0
            IVolPassed = true;
        end
    end
    
    %% Implied volatility surface
    k = 0;
    for i = 1:length(settings.T_range)
        for j = 1:length(settings.K_range)
            k = k + 1;
            IVolSurf{assetNum}(i,j) = IVol(k);
        end
    end
    
    figure(assetNum); surf(log(settings.K_range), settings.T_range, IVolSurf{assetNum});
    drawnow;
    
    %% Data
    data{assetNum}.T = T;
    data{assetNum}.K = K;
    data{assetNum}.r = r;
    data{assetNum}.S0 = S0;
    data{assetNum}.callPrices = callPrices;
    data{assetNum}.IVol = IVol;
    data{assetNum}.parameters = parameters;
    
    %% Save data
    save('priceDataMultiAssets', 'data');
    
end
