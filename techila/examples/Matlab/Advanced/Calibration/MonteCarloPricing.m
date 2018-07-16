function callPrices = ...
    MonteCarloPricing(S0, K, r, T, parameters, nSim, seedNumber, tradingDaysInYear)
% Monte-Carlo pricing function. It employes three variance reduction techniques: Antithetic
% variates, control variates, and emirical martingale simulation.
%
% Copyright 2017 Juho Kanniainen
% Copyright 2017 Techila Technologies Ltd.

%% Settings
rng(seedNumber,'v5normal')

kappa = parameters.kappa; 
theta = parameters.theta; 
xi = parameters.xi; 
rho = parameters.rho; 
gamma = parameters.gamma;
V0 = parameters.V0; 

% Time to maturity and interest rates converted to daily ones
T = T*tradingDaysInYear; 
r = r/tradingDaysInYear;

% Time increment (one day)
dt = 1/tradingDaysInYear;

% Option pricing done for adjusted strike (K/S0) and underlying price 1.
K_adj = K./S0;

%% Black-Scholes price, serves as a control variate
sigma = sqrt(V0);
BSAnalytical = blsprice(S0, K, r*tradingDaysInYear, T/tradingDaysInYear, sigma);


%% Initalization of vectors

% Stock prices
X1 = ones(nSim, 1);
X1_star = X1;

% Antithetic stock prices
X2 = ones(nSim, 1);
X2_star = X2;

% Control variate stock prices
X1_BS = ones(nSim, 1);
X1_BS_star = X1_BS;

% Antithetic, control variate stock prices
X2_BS = ones(nSim, 1);
X2_BS_star = X2_BS;

% Call prices
callPrices = ones(length(T), 1);


%% Simulation of the paths

% Initial volatility
V0_1 = V0; V0_2 = V0;

for time=1:max(T)
    % Random variables for return process
    epsilon1 = randn(nSim, 1);
    epsilon2 = -epsilon1;
    
    X1_previous = X1;
    X1 = X1(:,end).*exp(-0.5*V0_1*dt + sqrt(V0_1*dt).*epsilon1);
    
    % Black-Scholes solution serves as a control variate
    X1_BS_previous = X1_BS;
    X1_BS = X1_BS(:,end).*exp(-0.5*(sigma^2)*dt + sigma*sqrt(dt).*epsilon1);
    
    % Empirical Martingale Simulation (EMS):
    % Duan and Simonato, Management Science 44.9 (1998), 1218-1233.
    Z = (X1./X1_previous).*X1_star;
    Z_mean = mean(Z);
    X1_star = Z./Z_mean(end);
    
    % EMS - Control variate version
    Z_BS = (X1_BS./X1_BS_previous).*X1_BS_star;
    Z_mean_BS = mean(Z_BS);
    X1_BS_star = Z_BS./Z_mean_BS(end);
    
    % Antithetic version
    X2_previous = X2;
    X2 = X2(:,end).*exp(-0.5*V0_2*dt + sqrt(V0_2*dt).*epsilon2);
    
    % Antithetic and control variate version
    X2_BS_previous = X2_BS;
    X2_BS = X2_BS(:,end).*exp(-0.5*(sigma^2)*dt + sigma*sqrt(dt).*epsilon2);
    
    % EMS and antithetic version
    Z2 = (X2./X2_previous).*X2_star;
    Z2_mean = mean(Z2);
    X2_star = Z2./Z2_mean(end);
    
    % EMS, antithetic, and control variate version
    Z2_BS = (X2_BS./X2_BS_previous).*X2_BS_star;
    Z2_mean_BS = mean(Z2_BS);
    X2_BS_star = Z2_BS./Z2_mean_BS(end);
    
    % Random variables for volatility process, correlated with returns
    zVol = randn(nSim, 1);
    epsilonVol1 = rho.*epsilon1+sqrt(1-rho^2)*zVol;
    epsilonVol2 = rho.*epsilon2+sqrt(1-rho^2)*(-zVol);
    %epsilonVol2 = -epsilonVol1;
    
    % Volatility process
    V0_1 = max(V0_1 + kappa.*(theta - V0_1)*dt + xi.*V0_1.^gamma.*epsilonVol1.*sqrt(dt),0);
    V0_2 = max(V0_2 + kappa.*(theta - V0_2)*dt + xi.*V0_2.^gamma.*epsilonVol2.*sqrt(dt),0);
    
    if ~isempty(find(T==time, 1))
        for T_index = find(T==time)'
            
            % Simulated payoffs
            payoffs1 = (exp(-r(T_index)*T(T_index))*...
                max(exp(r(T_index)*T(T_index))*X1_star - K_adj(T_index), 0));
            payoffs2 = (exp(-r(T_index)*T(T_index))*...
                max(exp(r(T_index)*T(T_index))*X2_star - K_adj(T_index), 0));
            payoffs1_BS = (exp(-r(T_index)*T(T_index))*...
                max(exp(r(T_index)*T(T_index))*X1_BS_star - K_adj(T_index), 0));
            payoffs2_BS = (exp(-r(T_index)*T(T_index))*...
                max(exp(r(T_index)*T(T_index))*X2_BS_star - K_adj(T_index), 0));
            
            % Optimizing control variates
            alpha1 = cov(payoffs1', payoffs1_BS')./var(payoffs1_BS'); alpha1 = alpha1(1,2);
            alpha2 = cov(payoffs1', payoffs2_BS')./var(payoffs2_BS'); alpha2 = alpha2(1,2);
            
            % Simulated payoffs after control variate correction
            adjustedPayoffs1 = S0(T_index).*(payoffs1 - alpha1*payoffs1_BS) + ...
                alpha1*BSAnalytical(T_index);
            adjustedPayoffs2 = S0(T_index).*(payoffs2 - alpha2*payoffs2_BS) + ...
                alpha2*BSAnalytical(T_index);
            
            if (adjustedPayoffs1) <0
                adjustedPayoffs1 = S0(T_index).*(payoffs1);
            elseif max(isnan(adjustedPayoffs1))
                adjustedPayoffs1 = 0;
            end
            
            if (adjustedPayoffs2) <0
                adjustedPayoffs2 = S0(T_index).*(payoffs2);
            elseif max(isnan(adjustedPayoffs2))
                adjustedPayoffs2 = 0;
            end
            
            payoffs = (adjustedPayoffs1 + adjustedPayoffs2)/2;
            callPrices(T_index) = max(sum(payoffs)./nSim, 0);
        end
    end   
end
end
