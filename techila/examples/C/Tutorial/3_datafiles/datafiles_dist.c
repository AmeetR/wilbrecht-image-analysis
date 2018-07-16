// Copyright 2011-2013 Techila Technologies Ltd.

/* This file contains the Worker Code, which will be compiled in to a binary
when the example is compiled using make. The operations shown in this file
will be executed on the Workers. Input arguments for the program have been
defined in the Local Control Code. */

#include <stdio.h>
#include <stdlib.h>

#define SIZE 5

int main(int argc, char** argv) {
  int jobidx = atoi(argv[1]); // Read 1st input argument
  int r1, r2;
  int result = 0;
  // Create arrays that will contain one row of data
  int m1[SIZE] = {0};
  int m2[SIZE] = {0};
  int i = 0;

  // Open files that contain the data
  FILE* f1 = fopen("datafile0", "r");
  FILE* f2 = fopen("datafile1", "r");

  // Read row matching the value of the 'jobidx' variable from file 'datafile0'
  while (i < jobidx) {
    r1 = fscanf(f1, "%i,%i,%i,%i,%i", &m1[0], &m1[1], &m1[2], &m1[3], &m1[4]);
    printf("File 1 = %i  %i  %i  %i  %i\n", m1[0], m1[1], m1[2], m1[3], m1[4]);
    i++;
  }

  i = 0;
  // Read row matching the value of the 'jobidx' variable from file 'datafile1'
  while (i < jobidx) {
    r2 = fscanf(f2, "%i,%i,%i,%i,%i", &m2[0], &m2[1], &m2[2], &m2[3], &m2[4]);
    printf("File 2 = %i  %i  %i  %i  %i\n", m2[0], m2[1], m2[2], m2[3], m2[4]);
    i++;
  }

  fclose(f1);
  fclose(f2);

  // Sum values stored in the arrays
  for (i = 0; i < SIZE; i++) {
    result = result + m1[i] + m2[i];
  }

  FILE *fp;
  fp = fopen("techila_output", "w"); // Create the output file
  fprintf(fp, "%i\n", result);  // Write result in the output file
  fclose(fp);

  return 0;
}
