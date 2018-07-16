function varargout = run_VaR_cloudfor
% Main function. Creates the computational Project.

% Copyright 2017 Verhoog Consultancy
% Copyright 2017 Techila Technologies Ltd.

% Load parameters with market data, scenario data, instrument data and position data
parameters

% Determine base portfolio value, value without changes in market data
% calculate options values
rate = interp1(ir.t,ir.r,option.Maturity, 'linear');
vol = interp2(iv.t,iv.M,iv.sigma,option.Maturity,max(min(S0./K,max(iv.M)),min(iv.M)));
baseOptionValue = sum(bs_function(S0,K,option.Maturity,rate,vol,isCall) * pos(1:nrOfOptions));

% Calculate bond values
rate = interp1(ir.t,ir.r,couponTimes,'linear');
baseBondValue = sum(CFs.*exp(-couponTimes.*rate/100),2,'omitnan')' * pos((1+nrOfOptions):(nrOfOptions+nrOfBonds));

% Calculate total portfolio value
basePortfolioValue = baseOptionValue + baseBondValue;

% Variable for storing results
portfolioValue = zeros(nrOfScenarios,1);
% Create empty figure that will be used to visualise graph data
figure

% How many iterations per Job
itersinjob = 500;

% Create Project using cloudfor.
% 
% Parameter explanations:
% %cloudfor('stepsperjob',itersinjob): Sets number of iterations performed in a
% Job to match value of itersinjob.
%
% %cloudfor('callback','cbfun(portfolioValue,basePortfolioValue)'):
% Executes 'cbfun' function each time new Job result data has been
% received. Updates the graph.
%
% %cloudfor('force:largedata'): Enables sending large data amounts to the
% computational environment
%
% %cloudfor('outputparam',portfolioValue): Return only portfolioValue from
% the computational environment. Improves performance because amount of
% transferred data is kept at a minimum.
%
% %cloudfor('callbackinterval','1s'): Limit callback function execution
% interval to once in 1 seconds.

cloudfor i = 1:nrOfScenarios
%cloudfor('stepsperjob',itersinjob)
%cloudfor('callback','cbfun(portfolioValue,basePortfolioValue)')
%cloudfor('force:largedata')
%cloudfor('outputparam',portfolioValue)
%cloudfor('callbackinterval','1s')
    if isdeployed
    % Apply scenario on the interest rate curve
    PCAshock = scenarios(i,1)*PCA1+scenarios(i,2)*PCA2+scenarios(i,3)*PCA3;
    rateShock = exp(interp1(PCA.t,PCAshock,ir.t,'spline'));
    shockedRate = ((ir.r+ir.displacement) .* rateShock) - ir.displacement;
    
    % Option valuation under the different scenarios
    rate = interp1(ir.t,shockedRate,option.Maturity,'linear');
    vol = interp2(iv.t,iv.M,(scenarios(i,5)-1*volshock.surface)+1,option.Maturity,max(min(S0*scenarios(i,4)./K,max(iv.M)),min(iv.M)));
    p_options = bs_function(S0*scenarios(i,4),K,option.Maturity,rate,vol,isCall)';
    
    % Bond valuation under the different scenarios
    rate = interp1(ir.t,shockedRate,couponTimes,'linear');
    p_bonds = sum(CFs.*exp(-couponTimes.*rate/100),2,'omitnan');
    
    % Return the result
    portfolioValue(i) = [p_options;p_bonds]'*pos;
    end
cloudend

% Plot histogram and calculate quantiles 
probs = [0.001,0.005,0.01,0.1,0.25,0.5,0.75,0.9,0.99,0.995,0.999];
quantiles = quantile(100*(portfolioValue/basePortfolioValue-1), probs);
disp('Quantiles:')
disp(probs)
disp(quantiles)
subplot(2,1,1), histfit(100*(portfolioValue/basePortfolioValue-1),100,'kernel');
title('Profit & Loss Distribution')
subplot(2,1,2), histfit(100*(portfolioValue/basePortfolioValue-1),100,'kernel');
title('Profit and Loss Distribution 0.1-1% percentile')
xlim([quantile(100*(portfolioValue/basePortfolioValue-1),0.001) quantile(100*(portfolioValue/basePortfolioValue-1),0.01)])

% Only return portfolio values if requested
if nargout > 0
    varargout{1} = portfolioValue;
end
end
    




