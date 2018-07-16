// Copyright 2011-2013 Techila Technologies Ltd.

/* This file contains the Worker Code, which will be compiled in to a binary
when the example is compiled using make. The operations shown in this file
will be executed on the Workers. Input arguments for the program have been
defined in the Local Control Code. */

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
  int multip = atoi(argv[1]); // Read 1st input argument
  int jobidx = atoi(argv[2]);  // Read 2nd input argument

  // Operations corresponding to one iteration in the local program
  int result =  multip * jobidx;

  FILE *fp;
  fp=fopen("techila_output", "w");
  fprintf(fp, "%i\n", result); // Write the result in the output file
  fclose(fp);
  return 0;
}
