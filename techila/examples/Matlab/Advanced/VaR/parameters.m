% Copyright 2017 Verhoog Consultancy
% Copyright 2017 Techila Technologies Ltd.

% This file is sourced to set the parameters for the VaR simulations

% Number of scenarios. This value defines the amount of computational
% work done during the Project. You can modify this value to either
% increase or decrease the amount of work done.
% Recommended range: 10000 - 1000000
nrOfScenarios = 100000;

% Set other parameters.
nrOfOptions = 2000;

% If number of bonds is changed from 10000, a new data set will be created
% automatically (takes time).
nrOfBonds = 10000;

% Create set of market data
% Interest rate
ir.t = [1/365.25,1,2,3,4,5,10,20,30];
ir.r = [0,0.04,0.07,0.09,0.11,0.12,0.15,0.2,0.22];
% Vol surface
iv.t=[1/365.25,1,2,3,4,5];
iv.M = [0.5,0.75,1,1.25,1.5];
iv.sigma=   [   0.29,0.29,0.23,0.20,0.184,0.175
    0.26,0.26,0.21,0.19,0.182,0.172
    0.25,0.25,0.20,0.19,0.180,0.170
    0.25,0.25,0.21,0.19,0.181,0.171
    0.28,0.28,0.22,0.19,0.182,0.173];

% Instrument definition

% Create set of random options
S0 = max(0,100*(lognrnd(0,0.5,nrOfOptions,1)));
K = max(0,S0 .* normrnd(1,0.05,nrOfOptions,1));
option.Maturity=max(1/365.25,3*rand(nrOfOptions,1));
isCall = round(rand(nrOfOptions,1));

% Create set of random bonds
bond.Maturity = datasample(datenum('2017/04/01','yyyy/mm/dd'):datenum('2047/03/31','yyyy/mm/dd'),nrOfBonds);
currentDate = datenum('2017/03/31','yyyy/mm/dd');
couponRate = datasample(1:0.05:5,nrOfBonds)/100;

% Calculate CFs for bonds
couponTimes = zeros(nrOfBonds,(year(max(bond.Maturity))-year(datenum(currentDate)))*2);
CFs = zeros(nrOfBonds,(year(max(bond.Maturity))-year(currentDate))*2);

% Load or generate bond data
if nrOfBonds == 10000
    % Use existing data set for 10000 bonds
    disp('Using existing bond data set')
    load bondData
else
    disp('Creating new bond data set...this may take several minutes.')
    % Create new data set
    stats = floor(nrOfBonds / 20);
    for i = 1:nrOfBonds
        if mod(i,stats) == 0
            % Progress indicator
            fprintf('%i of %i bonds\n',i,nrOfBonds);
        end
        couponDates = datenum(datetime(datestr(bond.Maturity(i))):calmonths(-6):datetime(datestr(currentDate)));
        couponTimes(i,1:length(couponDates)) = (couponDates-currentDate)/365.25;
        CFs(i,1:length(couponDates)) = couponRate(i)/2;   % coupon CFs
        CFs(i,1) = CFs(i,1)+1;                            % principle CFs
    end
    fprintf('%i of %i bonds\n',i,nrOfBonds);
    disp('New bond data set created')
end

% Create a random position matrix
pos = [datasample(-5000:100:5000,nrOfOptions),datasample(10000:10000:1000000,nrOfBonds)]';

% Scenario definition
% 3 interest rate PCA factor, equity vol, vol vol)
scenarios = [normrnd(0,0.15,nrOfScenarios,1),normrnd(0,0.01,nrOfScenarios,1), ...
    normrnd(0,0.001,nrOfScenarios,1),lognrnd(0,0.20,nrOfScenarios,1), ...
    lognrnd(0,0.25,nrOfScenarios,1)];

% Interest rate PCA factor that defines how ir curve is shocked
PCA.t = [1/365.25,3/12,6/12,1,5,10,30];
PCA1 = [-0.3,-0.3,-0.3,-0.3,-0.3,-0.3,-0.3];
PCA2 = [0.7,0.5,0.2,0.1,-0.15,-0.18,-0.2];
PCA3 = [0.6,-0.3,-0.5,-0.35,-0.1,0.15,0.25];
ir.displacement = 4;

% Matrix that defines how vol surface is shocked
volshock.surface = [    1.25,1.25,1.07,0.97,0.86,0.74; ...
    1.10,1.10,1.05,0.95,0.84,0.73; ...
    1.05,1.05,1.00,0.90,0.80,0.70; ...
    1.07,1.07,1.04,0.93,0.83,0.72; ...
    1.12,1.12,1.06,0.95,0.84,0.73];
