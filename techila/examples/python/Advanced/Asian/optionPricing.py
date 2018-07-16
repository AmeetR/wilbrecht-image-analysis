def optionPricing(Sx,vx,M,nn,r,N,rho,kappa,psi,E,T,jobidx):
    # Function containing the computationally intensive operations.
    
    import numpy
    import math
    numpy.random.seed(jobidx)
    S0 = Sx[math.floor((jobidx-1)/len(vx))]
    v0 = vx[(jobidx-1)%(len(vx))]
    Dt = 1/float(N)/float(nn)
    x = numpy.zeros((N,1))
    C = numpy.zeros((M,1))
    for m in range(M):
        w = numpy.random.normal(size=(N,nn))
        y = numpy.random.normal(size=(N,nn))
        z = rho*w+math.sqrt(1-math.pow(rho,2))*y
        v = v0
        x[1] = 0
        xx = x[1]
        for j in range(N-1):
            for k in range(nn):
                xx = xx+(r-0.5*v)*Dt+math.sqrt(v*Dt)*w[j,k]
                v = max(0,v+kappa*(v0-v)*Dt+psi*math.sqrt(v*Dt)*z[j,k]+0.25*math.pow(psi,2)*Dt*(math.pow(z[j,k],2)-1))
            x[j+1] = xx
        S = S0*numpy.exp(x)
        C[m] = max(sum(S)/float(N)-float(E),0)
    price = numpy.exp(-r*float(T))*sum(C)/float(M)
    return (price,math.floor((jobidx-1)/len(vx)),(jobidx-1)%(len(vx)))
