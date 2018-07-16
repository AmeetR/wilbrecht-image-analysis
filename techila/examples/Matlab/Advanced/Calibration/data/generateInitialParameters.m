% This script generates inital parameters for all the 100 assets for model calibration. Each asset
% has the unique set of initial parameters.
%
% Copyright 2017 Juho Kanniainen
% Copyright 2017 Techila Technologies Ltd.

%% Settings
clear all; close all;

settings = calibrationSettingsMultiUnderlAssets;

% SETTINGS FOR MATURITY TIMES AND STRIKES
settings.T_range = [3*21, 6*21, 9*21, 12*21, 1.5*12*21, 2*12*21, 3*12*21, 5*12*21, 10*12*21, 20*12*21]'/settings.tradingDaysInYear;
settings.K_range = [0.5:0.1:1.5]';

load('priceDataMultiAssets.mat'); % under subfolder 'data'
settings.numberOfAssets = min(settings.numberOfAssets, size(data,2));

initialParameterSettings = [];

for x=1:size(data,2)
     seed = x;
     parameters = loadInitialParametersMultiUnderlAssets(settings, seed, data, x);
     initialParameterSettings = [initialParameterSettings parameters];
end
save('initialParameterSettings.mat','initialParameterSettings')