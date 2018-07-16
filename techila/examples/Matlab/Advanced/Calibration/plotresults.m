function plotresults(jobres,h)
% Plots the results. This function updates figures each time new 
% intermediate data has been received from the Techila Workers.
%
% Copyright 2017 Juho Kanniainen
% Copyright 2017 Techila Technologies Ltd.
global jobValues
if isempty(jobValues)
    jobValues=cell(1,length(h.XData));
end

% Update the bar graph data
jobidx=jobres.TechilaJobId;
isValid = jobres.res < h.YData(jobidx);
if isValid || isnan(h.YData(jobidx))
    h.YData(jobidx) = jobres.res;
    jobValues{jobidx} = [jobValues{jobidx} jobres];
end

% Generate a sample surface plot using data from Job 1.
if jobidx == 1  
    fig2 = figure(2);
    scrsz = get(groot,'ScreenSize');
    set(fig2,'Position',[scrsz(3)*0.71 scrsz(3)*0.001 scrsz(3)*0.4 scrsz(4)*0.4])
    K = jobValues{jobidx}(end).K;
    T = jobValues{jobidx}(end).T;
    IVolSurfModel = jobValues{jobidx}(end).IVolSurfModel;
    IVolSurf = jobValues{jobidx}(end).IVolSurf;
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
end
