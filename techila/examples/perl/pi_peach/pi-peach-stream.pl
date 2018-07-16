#!/usr/bin/perl -w

# Copyright 2010-2013 Techila Technologies Ltd.

# Compute approximate value of pi with peach,
# stream results to callback function

use strict;
#use Data::Dumper;

use lib ('../../../lib/perl'); # include SDK
use Techila;

my $techila = new Techila();

my $jobs = 20; # Number of jobs
my $loops = 50000000; # Number of loops per job

my $totalin = 0;
my $totalloops = 0;

my @result = $techila->peach(
    funcname => "mcpi",
    params => [
        "<param>",
        $loops,
    ],
    files => ["mcpi.pl"],
    peachvector => [1..$jobs],
    conf => {
        messages => 1,
        priority => 5, # below normal
        stream => 1,
        callback => \&result,
        bundleparameters => {
            "ExpirationPeriod" => 1800000, # 30 minutes
        },
        binarybundleparameters => {
            "ExpirationPeriod" => 7200000, # 2 hours
        },
    },
    );

# result is a list of values returned by the callback
print join(", ", @result), "\n";

sub result
{
    my %r = %{shift()};

    $totalin += $r{in};
    $totalloops += $r{loops};

    my $pi;
    if ($totalloops > 0)
    {
        $pi = ($totalin / $totalloops) * 4;
        # print out the result
        #print("==== ==== ==== ====\n");
        #print("total in = $totalin\n");
        #print("total loops = $totalloops\n");
        print("value of PI is approx. " . $pi . "\n");
        #print("==== ==== ==== ====\n");
    }

    return $r{jobidx};
}
