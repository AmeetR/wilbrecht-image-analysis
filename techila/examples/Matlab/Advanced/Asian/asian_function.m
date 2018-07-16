function price = asian_function(S0,v0,M,nn,r,N,rho,kappa,psi,E,T)
% This function contains the computationally intesive operations performed
% during the simulation.
Dt=1/N/nn;   % time step size

% preallocate memory
x=zeros(N,1);  % a single log-price trajectory
Csum=0;

for m=1:M
    w=randn(N,nn);
    y=randn(N,nn);
    z=rho*w+sqrt(1-rho^2)*y;
    v=v0;
    x(1)=0;
    xx=x(1);

    for j=1:N-1
        for k=1:nn
            xx=xx+(r-0.5*v)*Dt+sqrt(v*Dt)*w(j,k);
            v=max(0,v+kappa*(v0-v)*Dt ...
                +0.5*sqrt(v*Dt)*z(j,k) ...
                +0.25*0.5^2*Dt*(z(j,k)^2-1));
        end
        x(j+1)=xx;
    end
    S=S0*exp(x);
    Csum=Csum+max(sum(S)/N-E,0);
end
price=exp(-r*T)*Csum/M;

