// Copyright 2011-2013 Techila Technologies Ltd.

/* This file contains the Local Control Code will be used to create the
computational Project. The operations shown in this file will be executed
on your computer. */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include "Techila.h"

// Function for processign each result file returned from Workers
int handle_result_file(char* file) {
  printf("file = %s\n", file); // Print the path of the result file
  FILE* fd = fopen(file, "r");
  int res;
  // Store the value returned from the Worker
  fscanf(fd, "%i", &res);
  fclose(fd);
  return(res);
}

// Function for checking the status codes returned by Techila API functions
void checkStatus(int status) {
  if (status < 0) {
    size_t maxsize = 256;
    char msg[maxsize];
    techila_describeStatusCode(status, msg, &maxsize);
    printf("Error %d: %s\n", status, msg);
    exit(1);
  }
}

int main(int argc, char** argv) {
  int jobs = 5; // Will be used to set the number of Jobs to 5
  int myarray[5]; // Create array for results

  // Will be passed as an input argument to the Worker Code
  char multip[] = "2";

  int status = techila_initFile(NULL); // Initialize a Techila session
  checkStatus(status);  // Check that the session was created successfully

  // Create a handle to link all subsequent peach function calls
  int ph = techila_peach_handle();

  // Set a name for the Project
  techila_peach_setName(ph, "Parameters");

  // Check which executables exist and add the binaries to the Bundle. The
  // executables added here will be executed on Workers with the applicable
  // operating system and processor architecture combination.
  if(access("parameters_dist64.exe", F_OK ) != -1 ) {
    techila_peach_addExeFile(ph, "exe", "parameters_dist64.exe", "Windows", "amd64");
  }
  if(access("parameters_dist32.exe", F_OK ) != -1 ) {
    techila_peach_addExeFile(ph, "exe", "parameters_dist32.exe", "Windows", "x86");
  }
  if(access("parameters_dist32", F_OK ) != -1 ) {
    techila_peach_addExeFile(ph, "exe", "parameters_dist32", "Linux", "i386");
  }
  if(access("parameters_dist64", F_OK ) != -1 ) {
    techila_peach_addExeFile(ph, "exe", "parameters_dist64", "Linux", "amd64");
  }

  // Enable Project messages
  techila_peach_setMessages(ph, 1);

  // Set the number of Jobs to 5 based on the value of the 'jobs' variable
  techila_peach_setJobs(ph, jobs);

  // Specify that file 'techila_output' should be returned from Workers
  techila_peach_addOutputFile(ph, "techila_output");

  // Define a Project parameter and define its value
  techila_peach_putProjectParam(ph, "multip", multip);

  // Define 2 input arguments for the executable program. The 1st input arg
  // will be "2" for all Jobs, the 2nd input arg will have a different value
  // for each Job.
  techila_peach_putExeExtras(ph, "Parameters", "%P(multip) %P(jobidx)");

  printf("Creating Project...\n");
  // Create the computational Project based on defined parameters
  status = techila_peach_execute(ph);
  checkStatus(status);

  printf("Attempting to download results...\n");
  char file[512];
  size_t len = sizeof(file);
  int i = 0;
  int result;

  // Wait and download result files from the Techila Server
  while (len > 0) { // Do while more result files are available
    status = techila_peach_nextFile(ph, file, &len); // Download the next result file
    checkStatus(status);
    if (len > 0) { // Do if a valid result file is available
      file[len] = '\0';
      result=handle_result_file(file); // Process the result file
      myarray[i] = result;
      printf("Job %i, result %i\n", i + 1, myarray[i]);
      i++;
    }
  }

  // Cleanup and print statistics
  status = techila_peach_done(ph);
  status = techila_unload(1);

  if (i > 0) { // If results were downloaded succesfully
    printf("Results succesfully downloaded.\n");
    printf("Content of the array 'myarray': %i %i %i %i %i\n",
           myarray[0],
           myarray[1],
           myarray[2],
           myarray[3],
           myarray[4]);
  }
  else {
    printf("Project failed, please check the log files for more information on what went wrong.\n");
  }

  return 0;
}
