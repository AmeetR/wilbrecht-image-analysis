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

  long long in = 0;

  printf("jobidx = %i, loops = %" PRId64 "\n", jobidx, loops);

  srand(jobidx * 12837);

  for(i = 0; i < loops; i++)
  {
    double x = (double)rand() / RAND_MAX;
    double y = (double)rand() / RAND_MAX;
    double r = sqrt(pow(x, 2) + pow(y, 2));

    if (r <= 1)
    {
      in++;
    }
  }

  save(in, loops, output);

  return 0;
}
