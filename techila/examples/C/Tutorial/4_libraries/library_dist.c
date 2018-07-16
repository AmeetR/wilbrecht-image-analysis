// Copyright 2011-2013 Techila Technologies Ltd.

/* This file contains the Worker Code, which will be compiled in to a binary
when the example is compiled using make. The operations shown in this file
will be executed on the Workers. */

#include <stdio.h>
#include <stdlib.h>
#include "library.h"

int main(int argc, char** argv) {

  int jobidx = atoi(argv[1]); // Read 1st input argument
  int result =  libraryfunction(jobidx); // Call function from shared library

  FILE *fp;
  fp = fopen("techila_output", "w"); // Create output file
  fprintf(fp, "%i\n", result);  // Write result into output file
  fclose(fp);
  return 0;
}
