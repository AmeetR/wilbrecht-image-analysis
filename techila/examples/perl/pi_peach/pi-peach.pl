#!/usr/bin/perl -w

# Copyright 2010-2013 Techila Technologies Ltd.

# Compute approximate value of pi with peach.

use strict;
#use Data::Dumper;

use lib ('../../../lib/perl'); # include SDK
use Techila;

my $techila = new Techila();

my $jobs = 10; # Number of jobs
my $loops = 10000000; # Number of loops per job

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
        bundleparameters => {
            "ExpirationPeriod" => 1800000, # 30 minutes
        },
        binarybundleparameters => {
            "ExpirationPeriod" => 7200000, # 2 hours
        },
    },
    );

my $totalin = 0;
my $totalloops = 0;

foreach my $r (@result)
{
    $totalin += $r->{in};
    $totalloops += $r->{loops};
}

if ($totalloops > 0)
{
    # print out the result
    print("==== ==== ==== ====\n");
    print("total in = $totalin\n");
    print("total loops = $totalloops\n");
    print("value of PI is approx. " . (($totalin / $totalloops) * 4) . "\n");
    print("==== ==== ==== ====\n");
}
