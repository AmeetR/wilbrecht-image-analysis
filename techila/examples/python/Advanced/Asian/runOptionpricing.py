# Import required packages.
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import matplotlib.pyplot as plt
import math
import numpy
import time
import warnings
import sys
warnings.filterwarnings("ignore") 

# Check which version of python is used (2/3)
major = sys.version_info[0]

# Get the computationally intensive function definition.
if major == 2:
    execfile("optionPricing.py")
else:
    from optionPricing import *

def plotResults(x=None, y=None, value=None):
    # Function for updating the surface plot. Used as a callback function by peach
    # and will be executed automatically as new result data has been received.
    global total
    global S0
    global sigma0
    global ax
    global fig
    global lastupdate
    if x is None:
        plt.ion()
        fig = plt.figure()
        ax = fig.gca(projection='3d')
        plt.draw()
        plt.pause(.01)
        lastupdate=time.clock()
        total=numpy.zeros((S0.size, sigma0.size))
        return
    if value is not None:
        total[x,y] = total[x,y] + value
    if time.clock()-lastupdate > 5 or value is None:
        plt.gcf().clear()
        X, Y = numpy.meshgrid(sigma0, S0)        
        ax = fig.gca(projection='3d')
        surf = ax.plot_surface(X, Y, total, rstride=1, cstride=1, cmap=cm.hot, linewidth=0, antialiased=False)
        if total.min() != total.max():
            ax.set_zlim(total.min(), total.max())
        plt.draw()
        plt.pause(.01)
        lastupdate=time.clock()

def run_option_pricing(M,MperJob,N,nn,rho,kappa,psi,E,T,r,S0x1,S0x2,S0n,sigma0x1,sigma0x2,sigma0n,local=True):
    # Function for performing the computations.

    global S0
    global sigma0
    S0 = numpy.linspace(S0x1,S0x2,S0n)
    sigma0 = numpy.linspace(sigma0x1,sigma0x2,sigma0n)
    
    loopRange = list(range(1,S0n*sigma0n+1))*int((M/MperJob))
    plotResults()
    
    if local == True:
        # Execute computations locally.
        for param in loopRange:
            (price,i,j) = optionPricing(S0,numpy.power(sigma0,2),MperJob,nn,r,N,rho,kappa,psi,E,T,param)
            plotResults(i, j, price)
    else:
        # Execute computations in a Project using peach.
        import techila        
        for (price,i,j) in techila.peach('optionPricing', [S0,numpy.power(sigma0,2),MperJob,nn,r,N,rho,kappa,psi,E,T,"<param>"],
                  files = "optionPricing.py", peachvector = loopRange, return_iterable = True, stream = True,
                  packages=["numpy"]):
            plotResults(i, j, price)

    plotResults(0,0)

    
def runDemo():
    # Run this function to start the example.
    # This function sets the parameters for the computations. 

    # Number of simulations performed per data point. Larger values will result
    # in a more accurate surface plot. Larger values will also increase the 
    # amount of computational work (=computations will take longer).
    M = 2000

    # Number of simulations performed in one Job. Smaller values will
    # increase the number of Jobs in the Project. 
    MperJob = 1000

    # M needs to be dividable by MperJob, so check the values:
    if (M % MperJob is not 0):
        raise ValueError('M: ' + str(M) + ' is not dividable by MperJob: ' + str(MperJob) + ' . Please adjust values accordingly.')
        
    # Execute computations in a computational Project. 
    # To run the code locally, change the last input argument to True.
    run_option_pricing(M,MperJob,365,1,-0.5,0.1,0.5,70,1,0.05,45,47,9,0.35,0.4,9, False)