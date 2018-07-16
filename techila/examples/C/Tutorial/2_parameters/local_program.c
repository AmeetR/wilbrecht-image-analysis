// Copyright 2011-2013 Techila Technologies Ltd.

/* This file contains the locally executable program and does not communicate
with the Techila environment in any way. This program will be compiled when
passing the argument 'local_program' to make. */

#include <stdio.h>
#include <fcntl.h>

int main(int argc, char** argv) {
  int loops = 5; // Number of iterations in the for-loop
  int result;
  int i;
  int multip = 2; // Will be used in the multiplication operation in the for-loop
  int myarray[5]; // Array for results

  for (i = 0; i < loops; i++) {
    result = multip * (i + 1); // Perform simple arithmetic operation
    myarray[i] = result; // Store result in array
    printf("Iteration %d, Result: %d\n", i + 1, myarray[i]); // Display progress
  }

  // Display the contents of the array
  printf("Content of the array 'myarray': %i %i %i %i %i\n",
         myarray[0],
         myarray[1],
         myarray[2],
         myarray[3],
         myarray[4]);
  return 0;
}
