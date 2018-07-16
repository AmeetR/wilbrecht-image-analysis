function res = ...
    pricingError(data, settings, taskNumber, parametersVect)
% This function computes the option pricing error (IVRMSE) between model and market implied
% volatility surfaces.
%
% Copyright 2017 Juho Kanniainen
% Copyright 2017 Techila Technologies Ltd.

%% Check that parameters are within boundaries

parameters.kappa = parametersVect(1);
parameters.theta = parametersVect(2);
parameters.xi = parametersVect(3);
parameters.rho = parametersVect(4);
parameters.gamma = parametersVect(5);
parameters.V0 = parametersVect(6);

inBounds = true;

if parameters.kappa < settings.minKappa || parameters.kappa > settings.maxKappa || ...
        parameters.theta < settings.minTheta || parameters.theta > settings.maxTheta || ...
        parameters.xi < settings.minXi || parameters.xi > settings.maxXi || ...
        parameters.rho < settings.minRho || parameters.rho > settings.maxRho || ...
        parameters.gamma < settings.minGamma || parameters.gamma> settings.maxGamma || ...
        parameters.V0 < settings.minV0 || parameters.V0 > settings.maxV0
    inBounds = false;
end

if inBounds
    %% Filtering option contracts with respect to strike prices
    indK = data.K >= settings.StrikeRange(1) & data.K <= settings.StrikeRange(2);
    K = data.K(indK);
    T = data.T(indK);
    r = data.r(indK);
    S0 = data.S0(indK);
    IVol = data.IVol(indK);
    
    %% Pricing options
    callPricesModel = MonteCarloPricing(S0, K, r, T, parameters, ...
        settings.nSim, settings.seedNumber, settings.tradingDaysInYear);
    
    IVolModel = blsimpv(S0, K, r, T, callPricesModel);
    IVolModel(isnan(IVolModel)) = 0;
    
    %% Option pricing error
    res = 100*sqrt(mean((IVolModel - IVol).^2));
    
    %% Showing results
    k = 0;
    for i = 1:length(unique(T))
        for j = 1:length(unique(K))
            k = k+1;
            IVolSurfModel(i,j) = IVolModel(k);
            IVolSurf(i,j) = IVol(k);
        end
    end
    
    if settings.indPlotSurface
        figure(taskNumber);
        surf(log(unique(K)), unique(T), IVolSurfModel);
        alpha(0.2)
        hold on;
        surf(log(unique(K)), unique(T), IVolSurf);
        hold off;
        xlabel('Log-Strike ($\log(K/S_0)$)','Interpreter','LaTex');
        ylabel('Maturity time ($T$, in years)','Interpreter','LaTex');
        zlabel('Implied volatility','Interpreter','LaTex');
        title('Data (non-transparent), model (transparent)','Interpreter','LaTex');
        drawnow;
    end
    
    if settings.showParameters
        disp(['Task number ', num2str(taskNumber)]);
        disp(['kappa:   ', num2str(parameters.kappa), ' (', num2str(data.parameters.kappa), ')']);
        disp(['theta:   ', num2str(parameters.theta), ' (', num2str(data.parameters.theta), ')']);
        disp(['xi:      ', num2str(parameters.xi), ' (', num2str(data.parameters.xi), ')']);
        disp(['rho:     ', num2str(parameters.rho), ' (', num2str(data.parameters.rho), ')']);
        disp(['gamma:   ', num2str(parameters.gamma), ' (', num2str(data.parameters.gamma), ')']);
        disp(['V0:      ', num2str(parameters.V0), ' (', num2str(data.parameters.V0), ')']);
        disp(['IVRMSE:  ', num2str(res)]);
        disp('-------------------');
    end
    
    % Techila Distributed Computing Engine functionality. 
    % Saves the variables defined in the list into an intermediate data file,
    % which will be automatically transferred back to the End-User's computer.
    % The data in these variables will be used to visualize the progress.
    saveIMData('res','parameters','K','T','IVolSurfModel','IVolSurf')
    
else
    res = 1e10;
end
end