// Copyright 2011-2013 Techila Technologies Ltd.

/* This file contains the Local Control Code will be used to create the
computational Project. The operations shown in this file will be executed
on your computer. */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include "Techila.h"

// Function for processing each result file returned from Workers
int handle_result_file(char* file) {
  printf("file = %s\n", file);
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
    techila_describeStatusCode(status, msg,&maxsize);
    printf("Error %d: %s\n", status, msg);
    exit(1);
  }
}

int main(int argc, char** argv)
{
  int myarray[5]; // Create an array for the results

  int status = techila_initFile(NULL); // Initialize a Techila session
  checkStatus(status);  // Check that the session was created successfully

  // Get handle to peach object, will be needed in later commands
  int ph = techila_peach_handle();

  // Set a name for the Project
  techila_peach_setName(ph, "Datafile_example");

  // Check which executables exist and add the binaries to the Bundle. The
  // executables added here will be executed on Workers with the applicable
  // operating system and processor architecture combination.
  if(access("datafiles_dist64.exe", F_OK ) != -1 ) {
    techila_peach_addExeFile(ph, "exe", "datafiles_dist64.exe", "Windows", "amd64");
  }
  if(access("datafiles_dist32.exe", F_OK ) != -1 ) {
    techila_peach_addExeFile(ph, "exe", "datafiles_dist32.exe", "Windows", "x86");
  }
  if(access("datafiles_dist32", F_OK ) != -1 ) {
    techila_peach_addExeFile(ph, "exe", "datafiles_dist32", "Linux", "i386");
  }
  if(access("datafiles_dist64", F_OK ) != -1 ) {
    techila_peach_addExeFile(ph, "exe", "datafiles_dist64", "Linux", "amd64");
  }

  // Enable Project messages
  techila_peach_setMessages(ph,1);

  // Set the number of Jobs to 5
  techila_peach_setJobs(ph, 5);

  // Specify that file 'techila_output' should be returned from the Worker
  techila_peach_addOutputFile(ph, "techila_output");

  // Specify one input argument for the executable program. Will be used to
  // determine which row should be read from the transferred files
  techila_peach_putExeExtras(ph, "Parameters", "%P(jobidx)");

  // Create a new data bundle
  techila_peach_newDataBundle(ph);
  // Add file 'datafile0' from current working directory
  techila_peach_addDataFile(ph, "datafile0");
  // Add file 'datafile1' from the 'storage' folder
  techila_peach_addDataFileWithDir(ph, "./storage/", "datafile1");

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
      myarray[i] = result; // Store result in array
      printf("Job %i, result %i\n", i + 1, myarray[i]);  // Display the result
      i++;
    }
  }

  // Cleanup and print statistics
  status = techila_peach_done(ph);

  // Unload to clean up and close session
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
