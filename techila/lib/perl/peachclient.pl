#!/usr/bin/perl -w
# Copyright 2010-2013 Techila Technologies Ltd.

use strict;
use Cwd;
use FreezeThaw qw(freeze thaw);
use File::Copy;
use Data::Dumper;

my $origdir = getcwd();

my $jobidx = $ARGV[0];
my $inputdir = $ARGV[1];
my $output = $ARGV[2];

#print "argv = $jobidx $inputdir $output\n";

my $inputdata = $inputdir . "/techila_perl_peach_inputdata";

# read inputdata
open(IN, "< $inputdata") || die "Can't open inputdata";
my ($funcname, $params, $peachvector, $files, $datafiles) = thaw(<IN>);
close(IN);

# get <param> from peachvector
foreach my $p (@{$params})
{
    if ($p eq "<param>")
    {
        $p = @{$peachvector}[$jobidx - 1];
    }
    elsif ($p eq "<jobidx>")
    {
        $p = $jobidx;
    }
    elsif ($p eq "<datafiles>")
    {
        $p = $datafiles;
    }
}

# copy files
if (defined($datafiles))
{
    foreach my $df (@{$datafiles})
    {
        copy($inputdir . "/" . $df, $df);
    }
}

# required files
foreach my $file (@{$files})
{
    require("./" . $file);
}

# run
my @r;
{
    no strict 'refs';
    @r = &{$funcname}(@{$params});
}

#print Dumper(@r);

# save output
chdir($origdir);
if (defined($output))
{
    open(OUT, "> $output") || die "failed opening output file";
    print OUT freeze(@r);
    close(OUT);
}
