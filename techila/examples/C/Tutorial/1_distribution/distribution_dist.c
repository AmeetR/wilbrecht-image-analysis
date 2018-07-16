// Copyright 2011-2013 Techila Technologies Ltd.

/* This file contains the Worker Code, which will be compiled in to a binary
when the example is compiled using make. The operations shown in this file
will be executed on the Techila Workers. */

#include <stdio.h>

int main(int argc, char** argv) {

  FILE *fp;
  int result;

  // Operations corresponding to one iteration in the local program
  result = 1 + 1;

  fp = fopen("techila_output", "w");
  fprintf(fp, "%i\n", result);  // Write the result in the output file
  fclose(fp);

  return 0;
}
