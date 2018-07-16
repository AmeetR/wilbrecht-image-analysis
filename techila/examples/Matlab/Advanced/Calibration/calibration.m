function [parametersFinal, fFinal, fInitial, exitFlag] = ...
        calibration(data, settings, parametersInitial, taskNumber)
% This function executes the model calibration with Nelder-Mead Simplex optimization algorithm 
% (fminsearch)
%
% Copyright 2017 Juho Kanniainen
% Copyright 2017 Techila Technologies Ltd.

%% Parameter values
parametersInitialVect = [parametersInitial.kappa, parametersInitial.theta, parametersInitial.xi, ...
    parametersInitial.rho, parametersInitial.gamma, parametersInitial.V0];


%% Calibrate model
f = @(x)pricingError(data, settings, taskNumber, x);

fInitial = f(parametersInitialVect);

try
    [parametersFinalVect, fFinal, exitFlag] = fminsearch(f, parametersInitialVect, settings.calibrOptions);
catch ME
    disp('Error in calibration (fminsearch)');
    disp('--------------------------------');
    disp(['Error identifier: ', ME.identifier]);
    disp(['Error message: ', ME.message]);
    for n = 1:length(ME.stack)
        disp(' ');
        disp(['Function: ', ME.stack(n).name]);
        disp(['File: ', ME.stack(n).file]);
        disp(['Line number: ', num2str(ME.stack(n).line)]);
    end
    disp('--------------------------------');
    parametersFinalVect = NaN.*parametersInitialVect;
    fFinal = NaN;
    exitFlag = NaN;
end

parametersFinal.kappa = parametersFinalVect(1);
parametersFinal.theta = parametersFinalVect(2);
parametersFinal.xi = parametersFinalVect(3);
parametersFinal.rho= parametersFinalVect(4);
parametersFinal.gamma= parametersFinalVect(5);
parametersFinal.V0 = parametersFinalVect(6);
