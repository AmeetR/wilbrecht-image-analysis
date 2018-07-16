// Copyright 2011-2013 Techila Technologies Ltd.

/* This file contains the locally executable program and does not communicate
with the Techila environment in any way. This program will be compiled when
passing the argument 'local_program' to make. */

#include <stdio.h>

#define SIZE 5

int main(int argc, char** argv) {
  int r1, r2;
  int result[SIZE] = {0}; // Create array for results

  // Create arrays for the values that will be read from text files
  int m1[SIZE][SIZE];
  int m2[SIZE][SIZE];
  int i, j;

  // Open files that contain the data
  FILE* f1 = fopen("datafile0", "r");
  FILE* f2 = fopen("./storage/datafile1", "r");
  i=0;

  // Read contents of datafile0 and store values in array 'm1'
  while ((r1 = fscanf(f1, "%i,%i,%i,%i,%i", &m1[i][0], &m1[i][1], &m1[i][2], &m1[i][3], &m1[i][4])) != EOF) {
    printf("File 1 = %i  %i  %i  %i  %i\n", m1[i][0], m1[i][1], m1[i][2], m1[i][3], m1[i][4]);
    i++;
  }

  i = 0;
  // Read contents of datafile1 and store values in array 'm2'
  while ((r2 = fscanf(f2, "%i,%i,%i,%i,%i", &m2[i][0], &m2[i][1], &m2[i][2], &m2[i][3], &m2[i][4])) != EOF) {
    printf("File 2 = %i  %i  %i  %i  %i\n", m2[i][0], m2[i][1], m2[i][2], m2[i][3], m2[i][4]);
    i++;
  }

  fclose(f1);
  fclose(f2);

  // Sum values stored in the arrays and store result in the array 'result'
  for (i = 0; i < SIZE; i++) {
    for ( j = 0; j < SIZE; j++) {
      result[i] = result[i] + m1[i][j] + m2[i][j];
    }
  }

  // Display results
  printf("Sum of lines = %i  %i  %i  %i  %i\n", result[0], result[1], result[2],result[3], result[4]);
  return 0;
}
