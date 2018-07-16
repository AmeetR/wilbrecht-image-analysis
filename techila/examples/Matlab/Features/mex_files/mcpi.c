// Copyright 2010-2013 Techila Technologies Ltd.

#include <string.h>
#include <math.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[ ],int nrhs, const mxArray *prhs[ ])
{
int j, loops, jobidx;
double *output, x, y, c;

/* Create the output array */
plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
output = mxGetPr(plhs[0]);

/*Get input integer values*/

loops = (int)(mxGetScalar(prhs[0]));  /*The number of iterations*/
jobidx = (int)(mxGetScalar(prhs[1])); /*Used to initialize the RNG*/

/*Init the random number generator*/
srand(time(0) * jobidx * 12837);

for (j = 0; j < loops; j++) /*Monte Carlo approximation*/
 {
    x = ((float) rand()/RAND_MAX);
    y = ((float) rand()/RAND_MAX);
    c = sqrt(pow(x,2)+pow(y,2));
    if (c < 1)
    {
       output[0]++;
    }
 }
}
