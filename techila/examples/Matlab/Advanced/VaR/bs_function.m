function price = bs_function(S0,K,t,r,sigma,call)
% Compute a price for a option with given parameters

% Copyright 2017 Verhoog Consultancy
% Copyright 2017 Techila Technologies Ltd.
d1 = 1./(sigma.*sqrt(t)).*(log(S0./K)+(r+(sigma.^2)./2).*t);
d2 = d1-sigma.*sqrt(t);

priceCall = normcdf(d1,0,1).*S0-normcdf(d2).*K.*exp(-r.*t);
pricePut = normcdf(-d2).*K.*exp(-r.*t)-normcdf(-d1,0,1).*S0;

price(call==1) = priceCall(call==1);
price(call==0) = pricePut(call==0);
end