function run_asian_cloudfor()
% This function shows how you can distribute the computationally intensive
% Asian routine in the 'asian_function' to the Workers by using the
% cloudfor-function.
%
%Usage: run_asian_cloudfor()
S0 = linspace(45,47,9); % initial stock price
sigma0 = linspace(0.35,0.4,9);%initial volatility of stock return

%The parameters of stock price diffusion
M = 20000; %The number of trajectories
N = 365; %The number of data points in year
nn=1;    % number of time steps per sample point

%The parameters of volatility diffusion
rho=-0.5; %The correlation between the increments of stock price and volatility
kappa=0.1; %The speed of revision
psi=0.5; %The standard deviation of volatility

%Other parameters
E=70; %Exercise price
T=1; %Maturity time
r = 0.05; % Interest rate

price = zeros(length(sigma0),length(S0));

[l_grid S2_grid] = meshgrid(S0,sigma0);
%price = nan(size(l_grid));
price = nan(length(sigma0),length(S0));
figure;
fig = surf(l_grid,S2_grid,price,'ZDataSource','price');
colormap(jet)

xlabel('Initial stock price'),ylabel('Initial volatility'),zlabel('Price of Asian Call')
title('Plot generated by the distributed version (cloudfor)')
drawnow;

cloudfor i_index=1:length(S0)
%cloudfor('stepsperjob',1)
        cloudfor j_index=1:length(sigma0)
        %cloudfor('stepsperjob',1)
            price(j_index,i_index) = asian_function(S0(i_index),sigma0(j_index)^2,M,nn,r,N,rho,kappa,0.5,E,T);
            %cloudfor('callback','refreshdata(fig, 'caller');')
            %cloudfor('callback','drawnow;')
        cloudend
cloudend

refreshdata(fig, 'caller');
drawnow;
