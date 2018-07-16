// Copyright 2011-2013 Techila Technologies Ltd.

/* This file contains the locally executable program and does not communicate
with the Techila environment in any way. This program will be compiled when
passing the argument 'local_program' to make. */

#include <stdio.h>
#include "library.h"

int main(int argc, char** argv) {
  int loops = 5; // Number of iterations in the for-loop
  int result;
  int myarray[5]; // Array for the results
  int i;

  for (i = 0; i < loops; i++) {
    result = libraryfunction(i + 1); // Call function from shared library
    myarray[i] = result; // Store result in array
    printf("Iteration %d, Result: %d\n", i + 1, myarray[i]); // Display progress
  }

  return 0;
}
