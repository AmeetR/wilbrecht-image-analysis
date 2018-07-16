%% mainMultiUnderlAssets
% Calibrates a volatility model for different underlying assets in a
% distributed way
%
% Copyright 2017 Juho Kanniainen
% Copyright 2017 Techila Technologies Ltd.

% Input data: 
% A "market" implied volatility surface for each underlying 
% asset, for which the model is calibrated.
% Starting values of parameters

% Output data:
% Initial parameters, final parameters, initial option pricing error, final
% option pricing error

% Reference: J. Kanniainen and M. Koskinen, "Distributed Calibration of Option Pricing Models with
% Multiple Contracts Written on Different Underlying Assets", 2017, Techila Technologies report

% Related literature:
% Kanniainen, Juho, Binghuan Lin, and Hanxue Yang.
% "Estimating and using GARCH models with VIX data for option valuation."
% Journal of Banking & Finance 43 (2014): 200-211.

% Yang, Hanxue, and Juho Kanniainen.
% "Jump and Volatility Dynamics for the S&P 500: Evidence for Infinite-Activity Jumps with
% Non-Affine Volatility Dynamics from Stock and Option Markets."
% Forthcoming in Review of Finance (2017)

% Larikka, Mauri, and Juho Kanniainen.
% "Calibration strategies of stochastic volatility models for option pricing."
% Applied Financial Economics 22.23 (2012): 1979-1992.

% Christoffersen, Peter, Kris Jacobs, and Karim Mimouni.
% "Models for S&P 500 dynamics: Evidence from realized volatility, daily returns, and
% option prices." Review of Financial Studies (2007).

clear all; clc; close all

path = cd;
addpath(genpath(path));

%% Settings
settings = calibrationSettingsMultiUnderlAssets;

%% Input data (volatility surfaces)
% struct: data
% Fields: T (time to maturity), K (strike price), r (interest rate), S0
% (underlying price)
% Additional fields (not used in calibration but in the verification of 
% calibration): callPrices (actual call option prices), IVol (actual
% implied volatility surface), parameters (actual parameters)

load('priceDataMultiAssets.mat'); % under subfolder 'data'
settings.numberOfAssets = min(settings.numberOfAssets, size(data,2));

load('initialParameterSettings.mat'); % under subfolder 'data'
%% Distribution of calibrations with different initial values

% Pre-allocate memory
fFinal = zeros(settings.numberOfAssets, 1);
fInitial = zeros(settings.numberOfAssets, 1);
exitFlag = zeros(settings.numberOfAssets, 1);
kappaInitial = zeros(settings.numberOfAssets, 1);
kappaFinal = zeros(settings.numberOfAssets, 1);
thetaInitial = zeros(settings.numberOfAssets, 1);
thetaFinal = zeros(settings.numberOfAssets, 1);
xiInitial = zeros(settings.numberOfAssets, 1);
xiFinal = zeros(settings.numberOfAssets, 1);
rhoInitial = zeros(settings.numberOfAssets, 1);
rhoFinal = zeros(settings.numberOfAssets, 1);
gammaInitial = zeros(settings.numberOfAssets, 1);
gammaFinal = zeros(settings.numberOfAssets, 1);
V0Initial = zeros(settings.numberOfAssets, 1);
V0Final = zeros(settings.numberOfAssets, 1);

% Create a figure that will be used to display a bar graph of the asset
% errors.
imidx=1:settings.numberOfAssets ;
imdata=NaN(settings.numberOfAssets,1);
scrsz = get(groot,'ScreenSize');
set(figure(1),'Position',[scrsz(3)*0.71 scrsz(4)*0.5 scrsz(3)*0.4 scrsz(4)*0.4])
h=bar(imidx,imdata);
h.XDataSource = 'imidx';
h.YDataSource = 'imdata';
set(gcf, 'renderer', 'zbuffer');
axis([0 100 0 4]);
colormap(winter)
ylabel('Asset pricing error')
xlabel('Asset Sample Number')
title('Asset pricing error summary')
refreshdata(h,'caller')
drawnow;

% Create Project using Techila Distributed Computing Engine 'cloudfor' function.
% 
% Results will be visualized by using the plotting functionality in 
% 'plotresults' function. 
cloudfor i = 1:settings.numberOfAssets
    %cloudfor('imcallback','plotresults(TECHILA_FOR_IMRESULT,h)')
    % ith volatility surface data
    if isdeployed
    rng(i) % Fixed seed for repeatability      
    % ith volatility surface data
    data_i = data{i};
    
    % Initial parameters
    parametersInitial = initialParameterSettings(i);
    % Calibration
    [parametersFinal, fFinal(i, 1), fInitial(i, 1), exitFlag(i, 1)] = ...
        calibration(data_i, settings, parametersInitial, i);
    
    % Store the results
    results{i}.kappaInitial = parametersInitial.kappa;
    results{i}.kappaFinal = parametersFinal.kappa;
    
    results{i}.thetaInitial = parametersInitial.theta;
    results{i}.thetaFinal = parametersFinal.theta;
    
    results{i}.xiInitial = parametersInitial.xi;
    results{i}.xiFinal= parametersFinal.xi;
    
    results{i}.rhoInitial = parametersInitial.rho;
    results{i}.rhoFinal = parametersFinal.rho;
    
    results{i}.gammaInitial = parametersInitial.gamma;
    results{i}.gammaFinal = parametersFinal.gamma;
    
    results{i}.V0Initial = parametersInitial.V0;
    results{i}.V0Final = parametersFinal.V0;
    
    disp([num2str(i),'th calibration finished with value ', num2str(fFinal(i, 1))]);
    end
cloudend
