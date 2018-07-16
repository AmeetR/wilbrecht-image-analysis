function [indexi, indexj, jobprice]=asian_function_wrapper(S0,sigma0,M,nn,r,N,rho,kappa,psi,E,T, jobidx)
% Wrapper for the computationally intensive Asian routine. This wrapper
% will be used automatically when running example that uses the 'peach'
% function to distribute the computations.

% Get the loop indexes from the jobidx value
[indexi,indexj] = ind2sub([length(S0), length(sigma0)], jobidx);

% Call the computationally intensive Asian routine
jobprice= asian_function(S0(indexi),sigma0(indexj),M,nn,r,N,rho,kappa,0.5,E,T)

end
