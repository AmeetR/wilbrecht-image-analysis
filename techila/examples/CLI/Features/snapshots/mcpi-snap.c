// Copyright 2011-2013 Techila Technologies Ltd.

#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <time.h>

#define SNAPSHOT_FILE "snapshot.dat"
#define SNAPSHOT_INTERVAL 60

void save(long long in, long long loops, char* file)
{
  char buf[64];
  int len = snprintf(buf, sizeof(buf), "%" PRId64 " %" PRId64 "\n", in, loops);

  printf("%s", buf);

  FILE *f = fopen(file, "w");

  int w = fwrite(buf, len, 1, f);

  fclose(f);

  printf("saved \"%s\"\n", file);
}


int main(int argc, char** argv)
{
  int jobidx = atoi(argv[1]);
  long long loops = atoll(argv[2]);
  char* output = argv[3];
  long long i;

  long long start = 0;
  long long in = 0;

  struct stat sb;

  printf("jobidx = %i, loops = %" PRId64 "\n", jobidx, loops);

  if (stat(SNAPSHOT_FILE, &sb) == 0)
  {
    FILE *f;
    
    f = fopen(SNAPSHOT_FILE, "r");

    int s = fscanf(f, "%" PRId64 "%" PRId64, &in, &start);

    fclose(f);
  }
  
  srand(jobidx * 12837);

  time_t t = time(NULL);
  time_t next_snapshot = t + SNAPSHOT_INTERVAL;
  

  printf("running from %" PRId64 " to %" PRId64 "\n", start, loops);

  for(i = start; i < loops; i++)
  {
    double x = (double)rand() / RAND_MAX;
    double y = (double)rand() / RAND_MAX;
    double r = sqrt(pow(x, 2) + pow(y, 2));

    if (r <= 1)
    {
      in++;
    }

    if (i > 0
        && i % 10000000 == 0
        && (t = time(NULL)) > next_snapshot)
    {
      save(in, i, SNAPSHOT_FILE);
      next_snapshot = t + SNAPSHOT_INTERVAL;
    }
  }

  save(in, loops, output);

  return 0;
}
