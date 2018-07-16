# Copyright 2010-2013 Techila Technologies Ltd.
#
# Worker side part of pi computation using Monte Carlo method.

use strict;
#use warnings;

1; # must return a true value when loading file

sub mcpi
{
    my $jobidx = shift;
    my $loops = shift;

    srand($jobidx + 39487234);

    my $in = 0;
    my $i;
    for($i = 0; $i < $loops; $i++)
    {
        my $x = rand();
        my $y = rand();

        my $r = sqrt($x ** 2 + $y ** 2);

        if ($r <= 1)
        {
            $in++;
        }
    }

    return {in => $in, loops => $loops, jobidx => $jobidx};
}
