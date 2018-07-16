function asian_legacy_wrapper(jobidx,S0x1,S0x2,S0n,sigma0x1,sigma0x2,sigma0n,M,nn,r,N,rho,kappa,psi,E,T,output)
% Worker Code. Function asian_legacy_wrapper contains a legacy wrapper
% for the computationally intensivy function 'asian_function'.
% This function will be compiled and then executed on the Techila Workers.
% This function will perform the necessary input parameter handling and
% will call the original asian function to perform the calculation. The
% results will be stored into a file, which will be transferred to the
% Techila Server

%As the function is executed as binary, all the command line parameters
%are string values. In this case they are needed to be converted to numeric
%format.
if(isdeployed)
    jobidx = str2num(jobidx);
    S0x1 = str2num(S0x1);
    S0x2 = str2num(S0x2);
    S0n = str2num(S0n);
    sigma0x1 = str2num(sigma0x1);
    sigma0x2 = str2num(sigma0x2);
    sigma0n = str2num(sigma0n);
    M = str2num(M);
    nn = str2num(nn);
    r = str2num(r);
    N = str2num(N);
    rho = str2num(rho);
    kappa = str2num(kappa);
    psi = str2num(psi);
    E = str2num(E);
    T = str2num(T);
end

% Initialize random number generator
% This is needed for all the different clients to generate different
% random number. If the random number generator is not seeded it will
% always produce the same sequence of numbers, which would mean that each
% job would produce the same result.
randn('state',jobidx);

S0 = linspace(S0x1, S0x2, S0n);
sigma0 = linspace(sigma0x1, sigma0x2, sigma0n);

indexi = floor((jobidx-1)/sigma0n)+1;
indexj = rem((jobidx-1), sigma0n)+1;

%Call asian function to calculate jobprice

jobprice=asian_function(S0(indexi),sigma0(indexj)^2,M,nn,r,N,rho,kappa,psi,E,T);

%Saves jobprice, indexi and indexj to the output file.
save(output, 'jobprice', 'indexi', 'indexj');
