# Copyright 2010-2013 Techila Technologies Ltd.

=head1 NAME

Techila - Perl module for commanding the Techila system

=head1 SYNOPSIS

  use Techila;

  my $techila = new Techila(sdkRoot => "/opt/techila/");

  my @result = $techila->peach(
      funcname => "function",
      params => [
          "<param>",
          1234,
          4321,
      ],
      files => ["function.pl"],
      peachvector => [1..$jobs],
      messages => 1,
      );

=head1 DESCRIPTION

This module wraps the Java methods into a more perl-like interface.
More information about the methods are available in the javadocs.

=head2 Requirements

Required Perl modules: Inline::Java, FreezeThaw, Digest::MD5, POSIX,
Carp, Data::Dumper, File::Basename.

=head2 Parameters

=over 12

=item sdkRoot

Root directory of Techila SDK package. If sdkRoot is not defined it is
assumed to be ../../ relative to the Techila.pm file.

=item trace

Display trace messages on error.

=item jni

Enable JNI with Inline::Java.

=item test

Set to 1 to enable test mode (dry-run). Prints the calls to various
Techila User Interface methods but does not execute them.

=back

=head1 init

Initialize the library.

=head2 Parameters

=over 12

=item settingsfile

File to be used as techila_settings.ini. Default =
$sdkRoot/techila_settings.ini

=item password

Password for the user keystore. If not defined the password is read
from the settings file or asked from the user.

=item test

Set to 1 to enable test mode (dry-run). Prints the calls to various
Techila User Interface methods but does not execute them.

=back

=head1 peach

Peach is short for parallel each. It is a helper function which can
be used to run a function in the Techila system and return the results.

Peach will initialize the library if not yet done, so calling init
separately is not necessary.

Peach returns a list of return values returned by the called function
(defined by funcname).

=head2 Peach Parameters

=over 12

=item funcname

The name of the function to be run on the clients.

=item params

List of common params for each job. Parameter <param> is replaced with
a value from the peachvector

=item files

List of files to be included in the "binary" bundle. The file
containing the function named by funcname must be listed here. See
also binaries.

=item datafiles

List of files to be included in the parameter bundle.

=item datadir

Directory where datafiles are located.

=item peachvector

List of values to replace <param> in the params. Number of jobs
created in the project is the number of items in this list.

=item binaries

List of compiled binaries/executables to be used instead of perl
script. The list contains a hash per executable platform. The hash
contains keys file which is the actual executable file, osname = name
of the operating system platform the binary is built for and processor
= the processor architecture the binary is built for. See also
executable bit. Example:

binaries => [
    { file => "test.sh", osname => "Linux" },
    { file => "test.bat", osname => "Windows" },
],

=item databundles

List of extra databundles to be created. Each databundle definition is
a hash containing at least name parameter or datafiles parameter, a
list of filenames. Additionally datadir parameter can be defined to
tell where the datafiles are to be loaded from.

If libraryfiles => 1 the files in the databundle won't
be copied to the binary working directory but are instead used
directly from the repository on the client. Use
%L(perl_peach_datafiles_<index>) to get a directory of the data, where
index starts from 0.

The skipmd5 => 1 can be used to skip MD5 check of the database files and
only use mtime. This will speed up the check done to determine if the
databundle needs to be created.

if name is defined the named bundle is included and other parameters
are ignored, no bundle is created.

Additionally parameters hash can be used to define any extra parameter
for the bundle.

databundles => [
    {
        datadir => "datadir",
        datafiles => ["data1", "data2"],
        libraryfiles => 1,
        parameters => {
            "ExpirationPeriod" => 3600000
        }
    },
    {
        name => "bundle.name",
    },
],

=item jobinputfiles

A special job input file databundle contains one or more files per
job. The number of files must be equal to the number of elements in
peachvector.

datadir defines the directory where the files are located.

datafiles is a list of filenames or a list of lists of filenames.

filenames is a list of filenames to be used on the client side. Files
will be copied to the working directory to the given names.

If skipmd5 => 1 can be used to skip MD5 check of the files and only
use mtime. This will speed up the check done to determine if the
job input file databundle needs to be created.

Additionally parameters hash can be used to define any extra parameter
for the bundle.

jobinputfiles => {
    datadir => "jobinputdir",
    datafiles => [["q-1-1", "q-1-2"],["q-2-1", "q-2-2"],["q-3-1", "q-3-2"]],
    filenames => ["qfile1", "qfile2"],
    skipmd5 => 1,
    parameters => {
        "ExpirationPeriod" => 3600000, # 60 minutes
    }
},

=item settingsfile

Techila SDK settings file to be used as configuration
(techila_settings.ini). Defaults to techila_settins.ini in sdkkRoot.

=item password

Password for the user keystore. If not defined it is read from the
config file or asked from the user with a dialog (if enabled).

=item messages

Print debugging messages inside peach.

=item description

Project description.

=item allowpartial

Allow partial results (some of the results are allowed to fail).

=item resultsrequired

Amount of results required before stopping project. May be amount of
jobs, e.g. "20", or percentage value "25%". (Default = 100%).

=item timelimit

When resultsrequired is defined, the number of seconds to wait for
results (Default = 0) before returning.

=item stream

Stream results. Each jos result is downloaded as they complete. If
this is false or no defined the full project result is downloaded
after the project finished.

=item callback

Function to be called as callback when results are processed. The
parameters for the callback function are those returned by the
funcname function. If this is defined peach returns a list of values
returned by the callback function. The order of results is
undetermined.

=item filehandler

Callback function to handle extra files in the result. Use outputfiles
to define the extra files. The first parameter for the function is the
name of the file.

Example: filehandler => sub {move($_[0], $destination_dir);}

=item finish

Callback function to handle project finish. Called after project is
done and results have been downloaded and processed. The function will
get a handle as a first parameter. This only works when peach waits
and downloads results. Useful for example getting project statistics.

=item outputfiles

Define extra outputfiles required in the result. Use filehandler to
process the files.

Example: outputfiles => "datafiles;file=data_\\\\d+\\\\.dat;regex=true"

This will match all files named data_\d+.dat, note the amount of
escape backslashes.

=item executable

Given files are executable directly without perl interpreter. See also
binaries and perlrequired. (Default = false)

=item perlrequired

Is perl bundle required on the client, i.e. is the computation written
in perl or plain executable. See also executable bit. (Default = true)

=item priority

Project priority 1 .. 7 (1 = highest, 4 = normal, 7 = lowest).

=item projectparameters

A hash of additional project parameters.

=item bundleparameters

A hash of additional bundle parameters (for the data bundle).

=item binarybundleparameters

A hash of additional binary bundle parameters.

=item imports

Comma separated list of additional bundle names to be imported = included.

Example: imports => "perl.testpackage1,perl.testpackage2"

=item paramcopy

Set parameter bundle files (defined with datafiles) to be copied to
the working directory (1) or not (0, default). This is useful when
using binaries / executable as no peachclient is used. When
peachclient is used it will itself copy the files.

=item donotuninit

Do not call unload when peach is done. User must call unload. (Default
= false)

=item donotwait

Return immediately after the project is created. Peach returns an
array with the handle to the project as the first element. (Default =
false)

=item removeproject

Remove Project from the Techila system after the results are
downloaded. (Default = false)

=item cleanup

Cleanup handle files (results etc.) after everything is ready.
(Default = true)

=item close

Close handle after everything is ready. (Default = true)

=back

=cut

package Techila;

use strict;
use FreezeThaw qw(freeze thaw);

use Digest::MD5;
use File::Basename;
use Data::Dumper;
use POSIX qw(floor);
use Carp qw(cluck croak);
use Archive::Extract;
use Inline;

1;

sub new
{
    my $class = shift;

    my %params = @_;

    my $defaultRoot = __FILE__;
    $defaultRoot =~ s![/\\]lib[/\\]perl[/\\]Techila.pm$!!;

    my $sdkRoot = $params{sdkRoot} || $params{gmkRoot} || $defaultRoot;
    my $jni = $params{jni} || 0;

    my $jar = "$sdkRoot/lib/techila.jar";

    if (! -e $jar)
    {
        croak "$jar not found (check sdkRoot)";
    }

    Inline->bind(
        Java => 'STUDY',
        JNI => $jni,
        CLASSPATH => $jar,
        STUDY => [
            'java.util.Hashtable',
            'java.util.Enumeration',
            'fi.techila.user.TechilaManagerFactory',
        ],
        AUTOSTUDY => 1,
        );

    my $self = {};

    $self->{init} = 0;
    $self->{sdkRoot} = $sdkRoot;
    $self->{trace} = $params{trace} || 0;
    $self->{test} = $params{test} || 0; # test-mode = dry-run

    bless $self, $class;

    return $self;
}

sub init
{
    my $self = shift;
    my $argc = $#_ + 1;

    if ($self->{test})
    {
        $self->{init} = 1;
        return 0;
    }

    # the defaults
    my $file = undef; #$self->{sdkRoot} . "/techila_settings.ini";
    my $password = "";

    if ($argc == 1)
    {
        # old backward compatible, only one parameter = config file
        $file = shift;
    }
    elsif ($argc > 1)
    {
        my %params = @_;
        if (defined($params{settingsfile}))
        {
            $file = $params{settingsfile};
        }
        if (defined($params{password}))
        {
            $password = $params{password};
        }
        if (defined($params{test}))
        {
            $self->{test} = $params{test};
        }
    }

    my $gm = Techila::fi::techila::user::TechilaManagerFactory->getTechilaManager();

    $gm = Inline::Java::cast('fi.techila.user.TechilaManager', $gm);

    # Get and cast other managers...

    my $bm = $gm->bundleManager();
    $bm = Inline::Java::cast('fi.techila.user.BundleManager', $bm);
    my $pm = $gm->projectManager();
    $pm = Inline::Java::cast('fi.techila.user.ProjectManager', $pm);
    my $rm = $gm->resultManager();
    $rm = Inline::Java::cast('fi.techila.user.ResultManager', $rm);
    my $support = $gm->support();
    $support = Inline::Java::cast('fi.techila.user.Support', $support);


    $self->{gm} = $gm;
    $self->{bm} = $bm;
    $self->{pm} = $pm;
    $self->{rm} = $rm;
    $self->{support} = $support;

    my $statuscode = $gm->initFile($file, $password);
    $self->checkstatuscode($statuscode);

    $self->{init} = 1;

    return $statuscode;
}


# -- gm

sub unload
{
    my $self = shift;
    my $p1 = shift;
    my $p2 = shift;

    if ($self->{test})
    {
        $self->{init} = 0;
        return 0;
    }

    if (!defined($p1))
    {
        $p1 = 1;
    }
    if (!defined($p2))
    {
        $p2 = 1;
    }

    if (defined($self->{gm}))
    {
        $self->{gm}->unload($p1, $p2);
        $self->{init} = 0;
    }
}

sub open
{
    my $self = shift;

    if ($self->{test})
    {
        if (!defined($self->{test_handleindex}))
        {
            $self->{test_handleindex} = 0;
        }
        my $handle = $self->{test_handleindex};
        $self->{test_handleindex}++;
        print "---- TEST: open $handle\n";
        return $handle;
    }

    return $self->{gm}->open();
}

sub close
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: close $handle\n";
        return 0;
    }

    return $self->{gm}->close($handle);
}

sub cleanup
{
    my $self = shift;
    my $handle = shift;
    my $mode = shift;

    if ($self->{test})
    {
        print "---- TEST: cleanup $handle $mode\n";
        return 0;
    }

    return $self->{gm}->cleanup($handle, $mode);
}

sub execute
{
    my $self = shift;
    my $manager = shift;
    my $method = shift;

    if ($self->{test})
    {
        print "---- TEST: execute $method\n";
        return 0;
    }

    return $self->{$manager}->$method(@_);
}

sub testSession
{
    my $self = shift;

    if ($self->{test})
    {
        print "---- TEST: testSesion\n";
        return 0;
    }

    return $self->{gm}->testSession();
}

sub getTempDir
{
    my $self = shift;

    if ($self->{test})
    {
        print "---- TEST: getTempDir\n";
        return undef;
    }

    return $self->{gm}->getTempDir();
}

# -- bm

sub useBundle
{
    my $self = shift;
    my $handle = shift;
    my $bundlename = shift;

    if ($self->{test})
    {
        print "---- TEST: useBundle\n";
        return 0;
    }


    return $self->{bm}->useBundle($handle, $bundlename);
}

sub getBundleId
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: getBundleId\n";
        return 1234;
    }

    return $self->{bm}->getBundleId($handle);
}

sub bundleVersionExists
{
    my $self = shift;
    my $bundlename = shift;
    my $bundleversion = shift;

    if ($self->{test})
    {
        print "---- TEST: bundleVersionExists $bundlename $bundleversion\n";
        return 0;
    }

    return $self->{bm}->bundleVersionExists($bundlename, $bundleversion);
}

sub createBundle
{
    my $self = shift;
    my $handle = shift;
    my $bundleprefix = shift;
    my $bundlename = shift;
    my $description = shift;
    my $bundleversion = shift;
    my $imports = shift;
    my $exports = shift;
    my $category = shift;
    my $resources = shift;
    my $executor = shift;
    my %extras = %{shift()};
    my %files = %{shift()};

    if ($self->{test})
    {
        print "---- TEST: createBundle $handle \n";
        print "  bundleprefix  = $bundleprefix\n";
        print "  bundlename    = $bundlename\n";
        print "  description   = $description\n";
        print "  bundleversion = $bundleversion\n";
        print "  imports       = $imports\n";
        print "  exports       = $exports\n";
        print "  category      = $category\n";
        print "  resources     = $resources\n";
        print "  executor      = $executor\n";
        print "  extras        = ", Dumper(\%extras);
        print "  files         = ", Dumper(\%files);
        return 0;
    }

    my $extrasht = _convert_hash(%extras);
    my $filesht = _convert_hash(%files);

    return $self->{bm}->createBundle($handle,
                                     $bundleprefix,
                                     $bundlename,
                                     $description,
                                     $bundleversion,
                                     $imports,
                                     $exports,
                                     $category,
                                     $resources,
                                     $executor,
                                     $extrasht,
                                     $filesht);
}


sub createSignedBundle
{
    my $self = shift;
    my $handle = shift;
    my $bundlename = shift;
    my $description = shift;
    my $bundleversion = shift;
    my $imports = shift;
    my $exports = shift;
    my $natives = shift;
    my $category = shift;
    my $resources = shift;
    my $activator = shift;
    my $executor = shift;

    my %extras = %{shift()};
    my %files = %{shift()};

    if ($self->{test})
    {
        print "---- TEST: createSignedBundle $handle \n";
        print "  bundlename    = $bundlename\n";
        print "  description   = $description\n";
        print "  bundleversion = $bundleversion\n";
        print "  imports       = $imports\n";
        print "  exports       = $exports\n";
        print "  natives       = $natives\n";
        print "  category      = $category\n";
        print "  resources     = $resources\n";
        print "  activator     = $activator\n";
        print "  executor      = $executor\n";
        print "  extras        = ", Dumper(\%extras);
        print "  files         = ", Dumper(\%files);
        return 0;
    }

    my $extrasht = _convert_hash(%extras);
    my $filesht = _convert_hash(%files);

    my $statuscode;

    # create the bundle...
    $statuscode = $self->{bm}->createSignedBundle($handle,
                                                  $bundlename,
                                                  $description,
                                                  $bundleversion,
                                                  $imports,
                                                  $exports,
                                                  $natives,
                                                  $category,
                                                  $resources,
                                                  $activator,
                                                  $executor,
                                                  $extrasht,
                                                  $filesht);
    if ($statuscode != 0)
    {
        return $statuscode;
    }

    # upload the bundle to the server...
    $statuscode = $self->{bm}->uploadBundle($handle);
    if ($statuscode != 0)
    {
        return $statuscode;
    }

    # approve the uploaded bundle on the server...
    $statuscode = $self->{bm}->approveUploadedBundles($handle);

    return $statuscode;
}

sub createExecutorBundle
{
    # additional helper method
    my $self = shift;
    my $handle = shift;
    my $bundlename = shift;
    my $description = shift;
    my $bundleversion = shift;

    my %extras = %{shift()};
    my %files = %{shift()};

    my $perlrequired = shift;
    if (!defined($perlrequired))
    {
        $perlrequired = 1;
    }

    my $imports = shift;
    if (defined($imports))
    {
        $imports .= ",";
    }
    else
    {
        $imports = "";
    }

    if ($perlrequired)
    {
        $imports .= "fi.techila.grid.cust.common.library.perl.v510.client,";

        my $val = $extras{"Environment"};
        if (defined($val))
        {
            $val .= ",";
        }
        else
        {
            $val = "";
        }
        $val .= "PERL5LIB;value=\"%C(perl5lib,PGET)\"";
        $extras{"Environment"} = $val;
    }
    $imports .= $bundlename;

    my $statuscode = $self->createSignedBundle($handle,
                                               $bundlename,
                                               $description,
                                               $bundleversion,
                                               $imports,
                                               "",
                                               "",
                                               "",
                                               "",
                                               "",
                                               $bundlename . ";specification-version=" . $bundleversion, # executor
                                               \%extras,
                                               \%files,
        );

    return $statuscode;

}



# -- pm

sub createProject
{
    my $self = shift;
    my $handle = shift;
    my $priority = shift;
    my $description = shift;
    my %params = %{shift()};

    if ($self->{test})
    {
        print "---- TEST: createProject $handle \n";
        print "  priority    = $priority\n";
        print "  description = $description\n";
        print "  params      = \n", Dumper(\%params);
        return 0;
    }

    my $ht = _convert_hash(%params);

    return $self->{pm}->createProject($handle, $priority, $description, $ht);
}

sub waitCompletion
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: waitCompletion $handle \n";
        sleep(1);
        return 0;
    }

    return $self->{pm}->waitCompletion($handle);
}

sub waitCompletionBG
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: waitCompletionBG $handle \n";
        return 0;
    }

    return $self->{pm}->waitCompletionBG($handle);
}

sub stopProject
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: stopProject $handle \n";
        return 0;
    }

    return $self->{pm}->stopProject($handle);
}

sub removeProject
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: removeProject $handle \n";
        return 0;
    }

    return $self->{pm}->removeProject($handle);
}

sub ready
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: ready $handle \n";
        return 100;
    }

    return $self->{pm}->ready($handle);
}

sub isCompleted
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: isCompleted $handle \n";
        return 1;
    }

    return $self->{pm}->isCompleted($handle);
}

sub isFailed
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: isFailed $handle \n";
        return 0;
    }

    return $self->{pm}->isFailed($handle);
}

sub actionWait
{
    my $self = shift;
    my $timeout = shift || 0;

    if ($self->{test})
    {
        print "---- TEST: actionWait $timeout \n";
        sleep(1);
        return 1;
    }

    return $self->{pm}->actionWait($timeout);
}

sub getProjectId
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: getProjectId $handle \n";
        return 9999;
    }

    return $self->{pm}->getProjectId($handle);
}

sub setProjectId
{
    my $self = shift;
    my $handle = shift;
    my $projectid = shift;

    if ($self->{test})
    {
        print "---- TEST: setProjectId $handle \n";
        return 0;
    }

    return $self->{pm}->setProjectId($handle, $projectid);
}

sub getProjectStatus
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: getProjectStatus $handle \n";
        return 0;
    }

    return $self->{pm}->getProjectStatus($handle);
}

sub getUsedCpuTime
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: getUsedCpuTime $handle \n";
        return 1200;
    }

    return $self->{pm}->getUsedCpuTime($handle);
}

sub getUsedTime
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: getUsedTime $handle \n";
        return 120;
    }

    return $self->{pm}->getUsedTime($handle);
}

sub getProjectStatistics
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: getProjectStatistics $handle \n";
        return ();
    }

    my $javaht = $self->{pm}->getProjectStatistics($handle);
    my %rethash;

    my $e = Inline::Java::cast('java.util.Enumeration',$javaht->keys());
    while ($e->hasMoreElements())
    {
        my $key = $e->nextElement();

        $rethash{$key} = $javaht->get($key);
    }

    return %rethash;
}


# -- rm

sub setStreamResults
{
    my $self = shift;
    my $handle = shift;
    my $set = shift;

    if ($self->{test})
    {
        print "---- TEST: setStreamResults $handle \n";
        return 0;
    }

    return $self->{rm}->setStreamResults($handle, $set);
}

sub downloadResult
{
    my $self = shift;
    my $handle = shift;
    my $allowPartial = shift || 0;
    my $streamResults = shift || 0;

    if ($self->{test})
    {
        print "---- TEST: downloadResult $handle $allowPartial $streamResults\n";
        return 0;
    }

    return $self->{rm}->downloadResult($handle, $allowPartial, $streamResults);
}

sub unzip
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: unzip $handle\n";
        return 0;
    }

    return $self->{rm}->unzip($handle);
}

sub getResultFiles
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: getResultFiles $handle\n";
        return ();
    }

    return $self->{rm}->getResultFiles($handle);
}

sub getNewStreamedResultFiles
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: getNewStreamedResultFiles $handle\n";
        return ();
    }

    return $self->{rm}->getNewStreamedResultFiles($handle);
}

sub getFilesReceived
{
    my $self = shift;
    my $handle = shift;

    if ($self->{test})
    {
        print "---- TEST: getFilesReceived $handle\n";
        return 0;
    }

    return $self->{rm}->getFilesReceived($handle);
}

sub setFilesReceived
{
    my $self = shift;
    my $handle = shift;
    my $count = shift;

    if ($self->{test})
    {
        print "---- TEST: setFilesReceived $handle $count\n";
        return 0;
    }

    return $self->{rm}->setFilesReceived($handle, $count);
}


# -- support

sub log
{
    my $self = shift;
    my $level = shift;
    my $msg = shift;

    if ($self->{test})
    {
        print "---- TEST: getNewStreamedResultFiles $level $msg\n";
        return 0;
    }

    return $self->{support}->log($level, $msg);
}

sub describeStatusCode
{
    my $self = shift;
    my $code = shift;

    if ($self->{test})
    {
        print "---- TEST: getNewStreamedResultFiles $code\n";
        return "N/A (test-mode)";
    }

    return $self->{support}->describeStatusCode($code);
}


# -- peach

sub getPeach
{
    my $self = shift;
    my $name = shift;

    if ($self->{test})
    {
        print "---- TEST: newPeach $name\n";
        return ();
    }

    my $peach = $self->{gm}->newPeach($name);

    $peach = Inline::Java::cast('fi.techila.user.Peach', $peach);

    return $peach;
}

sub nectarine
{
    return peach(@_);
}

# rewritten peach using Java Peach class
sub peach
{
    my $self = shift;

    my %params = @_;

    my $statuscode;

    my $douninit = 0;

    if (defined($params{conf}))
    {
        # backwards compatibility, move conf section one level up
        my %conf = %{$params{conf}};
        $params{conf} = undef;
        %params = (%conf, %params);
    }

    my $messages = $params{messages} || 0;
    my $priority = $params{priority} || 4; # default = NORMAL
    my $stream = $params{stream} || 0;
    my $allowpartial = $params{allowpartial} || 0;
    my $resultsrequired = $params{resultsrequired};
    my $timelimit = $params{timelimit} || 0;
    my $donotuninit = $params{donotuninit} || 0;
    my $donotwait = $params{donotwait} || 0;
    my $removeproject = $params{removeproject};
    my $cleanup = $params{cleanup};
    my $close = $params{close};

    my $projectid = $params{projectid};

    my %projectparameters = %{$params{projectparameters} || {}};
    my %bundleparameters = %{$params{bundleparameters} || {}};
    my %binarybundleparameters = %{$params{binarybundleparameters} || {}};
    my $outputfiles = $params{outputfiles};

    my $perlrequired = $params{perlrequired};
    my $perlversion = $params{perlversion};
    my $imports = $params{imports};
    my $executable = $params{executable} || 0;
    my $realexecutable = $params{realexecutable};

    if (!defined($removeproject))
    {
        $removeproject = 0;
    }
    if (!defined($cleanup))
    {
        $cleanup = 1;
    }
    if (!defined($close))
    {
        $close = 1;
    }
    if (!defined($perlrequired))
    {
        $perlrequired = 1;
    }
    if ($donotwait)
    {
        $removeproject = 0;
    }

    my $peachclient = 1;
    if ($executable)
    {
        $peachclient = 0;
    }

    if ($self->{test})
    {
        print "---- TEST: peach\n";
        print Dumper(\%params);
        return;
    }

    if (!$self->{init})
    {
        $douninit = 1;
        $statuscode = $self->init(
            settingsfile => $params{settingsfile},
            password => $params{password},
            );
        $self->checkstatuscode($statuscode);
    }

    #$self->log("FINEST", "perl peach called: " . Dumper(\%params));

    if (!defined($params{funcname}))
    {
        $params{funcname} = "undefined_" . rand(10000);
    }

    my $peach = $self->getPeach($params{funcname});

    my $description = $params{description} || $params{funcname} . " with peach";

    $peach->setDescription($description);
    $peach->setMessages($messages);

    if (defined($projectid))
    {
        $peach->setProjectId($projectid);
    }
    else
    {
        # exe
        if (defined($realexecutable))
        {
            $peach->setExecutable($realexecutable);
        }

        if (defined($imports))
        {
            for my $imp (split(/,/, $imports))
            {
                $peach->addExeImport($imports);
            }
        }

        foreach my $exefile (@{$params{files}})
        {
            $peach->addExeFile($exefile, $exefile);
        }

        foreach my $bin (@{$params{binaries}})
        {
            my $res = $bin->{res} || "exe";
            $peach->addExeFile($res, $bin->{file}, $bin->{osname}, $bin->{processor});
        }

        if ($peachclient)
        {
            $peach->addOutputFile("output;file=techila_peach_result.dat");
            $peach->addExeFile("peachclient.pl", $self->{sdkRoot} . "/lib/perl/peachclient.pl");
            $peach->setExecutable("%L(perl)/usr/bin/perl;osname=Linux,"
                                  . "%L(perl)/perl/bin/perl.exe;osname=Windows");
            $peach->putExeExtras("Parameters", "%I(peachclient.pl) %P(jobidx) %L(techila_peach_inputdata) %O(output)");
        }
        elsif (defined($params{params}))
        {
            $peach->putExeExtras("Parameters", join(" ", @{$params{params}}));
        }

        if ($perlrequired)
        {
            my $envver = $ENV{TECHILA_PERL_VERSION};
            if (!defined($perlversion) && defined($envver))
            {
                $perlversion = $envver;
            }

            my $verstr;
            if (!defined($perlversion) || $perlversion eq "auto")
            {
                # do automatic
                my $str = $];

                # split into parts
                $str =~ m/(\d+)\.(\d{3})(\d{3})/;
                my ($revision, $version, $subversion) = ($1, $2, $3);

                # strip leading zeros from version
                $version =~ s/^0+//;

                # construct string, subversion is not used
                $verstr = "v" . $revision . $version;
            }
            else
            {
                $verstr = "v" . $perlversion;
            }

            #print "Using verstr = \"$verstr\"\n";

            $peach->addExeImport("fi.techila.grid.cust.common.library.perl.$verstr.client");
            $peach->putExeExtras("ExternalResources", "perl;resource=perl");
            $peach->putExeExtras("Environment", "PERL5LIB;value=\"%C(perl5lib,PGET)\"");;
        }

        if (defined($outputfiles))
        {
            my @ofs = split(/,/, $outputfiles);
            foreach my $of (@ofs)
            {
                $peach->addOutputFile($of);
            }
        }

        my $ht = _convert_hash(%binarybundleparameters);
        $peach->putAllExeExtras($ht);

        # data
        if (defined($params{databundles}))
        {
            foreach my $databundle (@{$params{databundles}})
            {
                if (defined($databundle->{name}))
                {
                    $peach->newDataBundle($databundle->{name});
                }
                else
                {
                    my $datadir = $databundle->{datadir} || ".";

                    $peach->newDataBundle();

                    if (defined($databundle->{libraryfiles})
                        && $databundle->{libraryfiles} == 1)
                    {
                        $peach->setDataCopy(0);
                    }

                    if (defined($databundle->{datafiles}))
                    {
                        foreach my $df (sort(@{$databundle->{datafiles}}))
                        {
                            $peach->addDataFileWithDir($datadir, $df);
                        }
                    }
                    if (defined($databundle->{parameters}))
                    {
                        $ht = _convert_hash(%{$databundle->{parameters}});
                        $peach->putAllDataExtras($ht);
                    }
                }
            }
        }

        # job input
        if (defined($params{jobinputfiles}))
        {
            my $jobbundle = $params{jobinputfiles};

            my $datadir = $jobbundle->{datadir} || ".";

            if (defined($jobbundle->{datafiles}))
            {
                foreach my $df (@{$jobbundle->{datafiles}})
                {
                    if (ref($df) eq "ARRAY")
                    {
                        $peach->addJobFileWithDir($datadir, $df);
                    }
                    else
                    {
                        $peach->addJobFileWithDir($datadir, [$df]);
                    }
                }
            }
            if (defined($jobbundle->{filenames}))
            {
                $peach->setJobFileNames($jobbundle->{filenames});
            }
            if (defined($jobbundle->{parameters}))
            {
                $ht = _convert_hash(%{$jobbundle->{parameters}});
                $peach->putAllJobExtras($ht);
            }
        }


        # param
        my $inputdataname;
        if ($peachclient)
        {
            $inputdataname = "techila_perl_peach_inputdata." . $$ . "." . int(rand(10000));
            CORE::open(OUT, "> $inputdataname");
            my $inputdata = freeze($params{funcname},
                                   $params{params},
                                   $params{peachvector},
                                   $params{files},
                                   $params{datafiles},
                );
            print OUT $inputdata;
            CORE::close(OUT);

            $peach->addParamFile($inputdataname,
                                 "techila_perl_peach_inputdata");

        }

        if (defined($params{datafiles}))
        {
            my $datadir = $params{datadir} || ".";

            foreach my $df (@{$params{datafiles}})
            {
                $peach->addParamFileWithDir($datadir, $df);
            }
        }


        $ht = _convert_hash(%bundleparameters);
        $peach->putAllParamExtras($ht);

        $peach->setParamCopy($params{paramcopy} || 0);

        # project stuff
        $peach->setPriority($priority);

        $peach->setJobs($#{$params{peachvector}} + 1);

        $ht = _convert_hash(%projectparameters);
        $peach->putAllProjectParams($ht);

        # execute
        $peach->execute();

        if (defined($inputdataname) && -e $inputdataname)
        {
            unlink($inputdataname);
        }
    }

    # other
    $peach->setAllowPartial($allowpartial);
    $peach->setStream($stream);
    $peach->setRemove($removeproject);
    $peach->setCleanup($cleanup);
    $peach->setClose($close);

    # handle results

    my $projecthandle = $peach->getProjectHandle();
    my @resultvector;

    if ($donotwait)
    {
        if ($close)
        {
            # return project id
            my $pid = $self->getProjectId($projecthandle);
            push(@resultvector, $pid);
        }
        else
        {
            # return project handle
            push(@resultvector, $projecthandle);
        }
    }
    else
    {
        my $callback = $params{callback};
        my $filehandler = $params{filehandler};
        my $file;
        my $rnd = int(rand() * 10000);
        my $count = 0;

        my $now = time();
        my $waitstarted = $now;

        my $stop_called = 0;

        while (defined($file = $peach->nextFile()))
        {
            my $now = time();
            my $zip = 0;
            my @resfiles;
            my $tempdir = undef;
            if (defined($outputfiles)
                && ($peachclient || $outputfiles =~ m/,/))
            {
                # result file is a zip
                my $unzip = Archive::Extract->new( archive => $file,
                                                   type => "zip");

                $tempdir = $self->getTempDir() . "/perl_peach_${rnd}_${count}/";
                mkdir($tempdir);

                my $ok = $unzip->extract( to => $tempdir );

                @resfiles = @{$unzip->files};

                $zip = 1;
            }
            else
            {
                # single file result
                push(@resfiles, $file);
            }

            foreach my $ufile (@resfiles)
            {
                if (defined($tempdir))
                {
                    $ufile = $tempdir . $ufile;
                }

                if ($peachclient
                    && ($zip == 0
                        || $ufile =~ m/techila_peach_result.dat$/))
                {
                    # peachclient result
                    CORE::open(RES, "< $ufile");
                    my @result = thaw(<RES>);

                    if (defined($callback))
                    {
                        # use callback
                        push(@resultvector, &$callback(@result));
                    }
                    else
                    {
                        push(@resultvector, @result);
                    }

                    CORE::close(RES);

                    if (defined($tempdir) && $zip == 1)
                    {
                        unlink($ufile);
                    }
                }
                else
                {
                    # pass other files to filehandler
                    if (defined($filehandler))
                    {
                        my @result = &$filehandler($ufile);

                        if (!$peachclient)
                        {
                            if (defined($callback))
                            {
                                # use callback
                                push(@resultvector, &$callback(@result));
                            }
                            else
                            {
                                push(@resultvector, @result);
                            }
                        }
                    }

                    if (-e $ufile && $zip == 1)
                    {
                        unlink($ufile);
                    }
                }
            }

            if (defined($tempdir))
            {
                rmdir($tempdir);
            }

            $count++;

            if (defined($resultsrequired) && !$stop_called)
            {
                if ($self->_check_results_required($projecthandle, $resultsrequired)
                    && $now >= $waitstarted + $timelimit)
                {
                    print "Required amount of results, stopping...\n" if $messages;
                    $self->stopProject($projecthandle);
                    $stop_called = 1;
                }
            }

        }

        my $finishfunc = $params{finish};
        if (defined($finishfunc))
        {
            &$finishfunc($projecthandle);
        }
    }

    # done
    if ($donotwait)
    {
        # don't print statistics...
        $peach->setMessages(0);
    }
    $peach->done();

    if ($douninit && !$donotuninit)
    {
        # init was called by this peach and not excplicitly told to not uninit
        $self->unload(1, 1);
    }

    return @resultvector;
}

sub oldpeach
{
    my $self = shift;

    my %params = @_;

    my $statuscode;

    my $douninit = 0;

    if (defined($params{conf}))
    {
        # backwards compatibility, move conf section one level up
        my %conf = %{$params{conf}};
        $params{conf} = undef;
        %params = (%conf, %params);
    }

    if (!$self->{init})
    {
        $douninit = 1;
        $statuscode = $self->init(
            settingsfile => $params{settingsfile},
            password => $params{password},
            );
        $self->checkstatuscode($statuscode);
    }

    my $messages = $params{messages} || 0;

    my $allowpartial = $params{allowpartial} || 0;
    my $resultsrequired = $params{resultsrequired};
    my $timelimit = $params{timelimit} || 0;
    my $stream = $params{stream} || 0;
    my $callback = $params{callback};

    my $priority = $params{priority} || 4; # default = NORMAL

    my %projectparameters = %{$params{projectparameters} || {}};
    my %bundleparameters = %{$params{bundleparameters} || {}};
    my %binarybundleparameters = %{$params{binarybundleparameters} || {}};
    my $outputfiles = $params{outputfiles};

    my $donotuninit = $params{donotuninit} || 0;
    my $donotwait = $params{donotwait} || 0;
    my $removeproject = $params{removeproject};
    my $cleanup = $params{cleanup};
    my $close = $params{close};

    my $perlrequired = $params{perlrequired};
    my $imports = $params{imports};
    my $executable = $params{executable} || 0;
    my $realexecutable = $params{realexecutable};

    my $filehandler = $params{filehandler};

    my $projectid = $params{projectid};

    if (!defined($removeproject))
    {
        $removeproject = 1;
    }
    if (!defined($cleanup))
    {
        $cleanup = 1;
    }
    if (!defined($close))
    {
        $close = 1;
    }
    if (!defined($perlrequired))
    {
        $perlrequired = 1;
    }

    my $peachclient = 1;
    if ($executable)
    {
        $peachclient = 0;
    }

    my $handle;

    if (!defined($projectid))
    {
        my $description = $params{description} || $params{funcname} . " with peach";


        #
        # create "binary" bundle if needed
        #
        my $binarybundlename;
        my $binarybundleversion = "0.0.1";
        my %storedbinarystate;
        my %storedbinaryextrastate;
        my %storeddatastate;
        my $savestate = 0;

        # read stored state
        my $storefile = $params{funcname} . ".lastmod";

        if (-r $storefile)
        {
            CORE::open(SF, "$storefile") || croak "error opening $storefile";
            my $sfline = <SF>;
            chomp($sfline);
            ($binarybundlename, %storedbinarystate) = thaw($sfline);

            $sfline = <SF>;
            if (defined($sfline))
            {
                chomp($sfline);
                %storedbinaryextrastate = thaw($sfline);
            }

            $sfline = <SF>;
            if (defined($sfline))
            {
                chomp($sfline);
                %storeddatastate = thaw($sfline);
            }

            CORE::close(SF);
        }

        #print "storedbinarystate = ", Dumper(%storedbinarystate);

        #
        # Binary Bundle
        #

        my %currentbinarystate;
        my %currentbinaryextrastate;

        # compute current state of files
        if (defined($params{binaries}))
        {
            foreach my $bin (@{$params{binaries}})
            {
                if (defined($bin->{file})
                    && !grep(/$bin->{file}/, @{$params{files}}))
                {
                    push(@{$params{files}}, $bin->{file});
                }
            }
        }

        my @includedfiles = [];

        if (defined($params{files}))
        {
            @includedfiles = @{$params{files}};
        }

        if ($peachclient)
        {
            # include peachclient
            push(@includedfiles, $self->{sdkRoot} . "/lib/perl/peachclient.pl");
        }

        my @execs;
        my $clientos;
        if ($executable)
        {
            my @clientoslist;
            foreach my $bin (@{$params{binaries}})
            {
                if (defined($bin->{file}))
                {
                    $clientos = undef;
                    my $exe = $bin->{file};
                    if (defined($bin->{osname}))
                    {
                        $exe .= ";osname=" . $bin->{osname};
                        $clientos .= $bin->{osname};
                    }
                    if (defined($bin->{processor}))
                    {
                        $exe .= ";processor=" . $bin->{processor};
                        $clientos .= "," . $bin->{processor};
                    }
                    push(@execs, $exe);
                    if (defined($clientos))
                    {
                        push(@clientoslist, $clientos);
                    }
                }
            }
            # reuse variable
            $clientos = join("; ", @clientoslist);
        }

        my @copylist; # list of copyfiles
        my @internallist; # internal resources

        my %binaryfiles;

        # make list of files to be included in the binary bundle
        if ($peachclient)
        {
            $binaryfiles{"peachclient.pl"} = $self->{sdkRoot} . "/lib/perl/peachclient.pl";
            push(@internallist, "peachclient.pl;file=peachclient.pl;destination=peachclient.pl");
        }

        foreach my $file (@{$params{files}})
        {
            my $basename = (fileparse($file,()))[0];

            push(@copylist, $basename);
            push(@internallist, "$basename;file=$basename;destination=$basename");
            $binaryfiles{$basename} = $file;
        }

        # compare states
        my ($makebinary, $cstmp) = _compare_filestates(\%binaryfiles, \%storedbinarystate, 0);
        %currentbinarystate = %{$cstmp};

        # extra state
        $currentbinaryextrastate{executable} = $executable;
        $currentbinaryextrastate{peachclient} = $peachclient;
        $currentbinaryextrastate{perlrequired} = $perlrequired;
        $currentbinaryextrastate{outputfiles} = $outputfiles;
        $currentbinaryextrastate{imports} = $imports;
        $currentbinaryextrastate{parameters} = \%binarybundleparameters;
        $currentbinaryextrastate{realexecutable} = $realexecutable;

        if ($executable)
        {
            $currentbinaryextrastate{params} = \@{$params{params}};
        }

        # compare extra state
        if (!$makebinary)
        {
          L1:
            foreach my $key (keys(%currentbinaryextrastate))
            {
                my $c = $currentbinaryextrastate{$key};
                my $s = $storedbinaryextrastate{$key};

                if (!defined($c))
                {
                    if (defined($s))
                    {
                        $makebinary = 1;
                        last;
                    }
                    else
                    {
                        next;
                    }
                }

                if (defined($c) && !defined($s))
                {
                    $makebinary = 1;
                    last;
                }

                if (ref($c) eq "HASH")
                {
                    my %ch = %{$c};
                    my %sh = %{$s};

                    foreach my $skey (keys(%ch))
                    {
                        if (!defined($sh{$skey}) || $ch{$skey} ne $sh{$skey})
                        {
                            $makebinary = 1;
                            last L1;
                        }
                    }
                }
                elsif (ref($c) eq "ARRAY")
                {
                    my @ca = @{$c};
                    my @sa = @{$s};

                    while (my $ce = shift(@ca))
                    {
                        my $se = shift(@sa);

                        if (!defined($se)
                            || $ce ne $se)
                        {
                            $makebinary = 1;
                            last L1;
                        }
                    }
                }
                else
                {
                    if (!defined($s) || $c ne $s)
                    {
                        $makebinary = 1;
                        last;
                    }
                }
            }
        }

        # check if bundle exists
        if (!$makebinary)
        {
            my $exists = $self->bundleVersionExists($binarybundlename, $binarybundleversion);
            if (!$exists)
            {
                $makebinary = 1;
            }
        }

        if ($makebinary)
        {
            my $bundledescription = $params{funcname} . " with peach";
            $binarybundlename = $params{funcname} . "_" . time() . '_' . int(rand(1000000));

            $savestate = 1;

            #print "Creating Binary Bundle...\n";

            my $internal = join(",", @internallist);
            my $copy = join(",", @copylist);

            my %extras;
            $extras{"ResultHandler"} = "default";
            $extras{"Splitter"} = "default";
            $extras{"Copy"} = $copy;
            $extras{"InternalResources"} = $internal;

            my $externalresources = "";
            if ($perlrequired)
            {
                $externalresources = "perl;resource=perl,";
            }
            $externalresources .= "techila_perl_peach_inputdata;resource=techila_perl_peach_inputdata";
            $extras{"ExternalResources"} = $externalresources;

            if ($executable)
            {
                if (defined($realexecutable))
                {
                    $extras{"Executable"} = $realexecutable;
                }
                else
                {
                    $extras{"Executable"} = join(",", @execs);
                }
            }
            else
            {
                $extras{"Executable"} =
                    "%L(perl)/usr/bin/perl;osname=Linux,"
                    . "%L(perl)/perl/bin/perl.exe;osname=Windows";
            }

            if($peachclient)
            {
                $extras{"OutputFiles"} = "output;file=techila_peach_result.dat";
                $extras{"Parameters"} = "%I(peachclient.pl) %P(jobidx) %L(techila_perl_peach_inputdata) %O(output)";
            }
            else
            {
                $extras{"Parameters"} = join(" ", @{$params{params}});
            }

            $extras{"ExpirationPeriod"} = 604800000; # one week

            if (defined($outputfiles))
            {
                if (defined($extras{"OutputFiles"}))
                {
                    $extras{"OutputFiles"} .= ",";
                }
                $extras{"OutputFiles"} .= $outputfiles;
            }


            # merge %binarybundleparameters to %extras
            %extras = (%extras, %binarybundleparameters);

            $handle = $self->open();

            $statuscode = $self->createExecutorBundle($handle,
                                                      $binarybundlename,
                                                      $bundledescription,
                                                      $binarybundleversion,
                                                      \%extras,
                                                      \%binaryfiles,
                                                      $perlrequired,
                                                      $imports,
                );

            $self->cleanup($handle, 63);
            $self->close($handle);

            $self->checkstatuscode($statuscode);

            print "Created signed binary bundle.\n" if $messages;
        }

        #
        # Create additional data bundles = extrabundles
        #
        my %currentdatastate;
        my @databundlenames;
        my $dataindex = 0;
        if (defined($params{databundles}))
        {
            foreach my $extrabundle (@{$params{databundles}})
            {
                if (defined($extrabundle->{name})) {
                    push(@databundlenames, $extrabundle->{name});
                }
                else
                {
                    # create bundle
                    my $resourcename = "perl_peach_datafiles_$dataindex";
                    #print Dumper($extrabundle);
                    my $datadir = $extrabundle->{datadir} || ".";

                    my @copylist; # list of copyfiles
                    my @externallist;
                    my %files;
                    my $bundlelength = 0;
                    if (defined($extrabundle->{datafiles}))
                    {
                        foreach my $df (sort(@{$extrabundle->{datafiles}}))
                        {
                            my $realdf = $datadir . "/" . $df;
                            $bundlelength += (stat($realdf))[7];

                            $files{$df} = $realdf;
                            push(@copylist, $df);
                            push(@externallist, "$df;resource=$resourcename");
                        }
                    }

                    my %extras;

                    $extras{"ExpirationPeriod"} = 3600000; # 1 hour

                    if ($bundlelength > 1048576)
                    {
                        # longer expiration for bigger data bundles
                        $extras{"ExpirationPeriod"} = 86400000;
                    }

                    if (!(defined($extrabundle->{libraryfiles})
                          && $extrabundle->{libraryfiles} == 1))
                    {
                        my $copy = join(",", @copylist);
                        my $external = join(",", @externallist);

                        $extras{"Copy"} = $copy;
                        $extras{"ExternalResources"} = $external;
                    }

                    my %ebp = %{$extrabundle->{parameters} || {}};

                    %extras = (%extras, %ebp);

                    # compare states
                    my %ebstoredstate = %{$storeddatastate{bundles}->[$dataindex]->{files} || {}};

                    my ($makedata, $cdstmp) = _compare_filestates(\%files, \%ebstoredstate, $extrabundle->{skipmd5});
                    my %ebcurrentstate = %{$cdstmp};

                    # compare extras
                    if (!$makedata)
                    {
                        foreach my $ekey (keys(%extras))
                        {
                            my $sval = $storeddatastate{bundles}->[$dataindex]->{extras}->{$ekey};
                            if (!defined($sval)
                                || $extras{$ekey} ne $sval)
                            {
                                $makedata = 1;
                                last;
                            }
                        }
                    }

                    my $databundlename = $storeddatastate{bundles}->[$dataindex]->{name};
                    my $databundleversion = $storeddatastate{bundles}->[$dataindex]->{version} || "0.0.1";

                    # check if bundle exists
                    if (!$makedata)
                    {
                        my $exists = $self->bundleVersionExists($databundlename, $databundleversion);
                        if (!$exists)
                        {
                            $makedata = 1;
                        }
                    }

                    # make it
                    if ($makedata)
                    {
                        $databundlename = $binarybundlename . "_data_" . $dataindex . "_" . time() . "_" . int(rand(10000));


                        $savestate = 1;

                        $handle = $self->open();

                        # data bundle
                        $statuscode = $self->createSignedBundle($handle,
                                                                $databundlename,
                                                                "data $dataindex for " . $binarybundlename,
                                                                $databundleversion,
                                                                "",
                                                                "",
                                                                "",
                                                                "",
                                                                $resourcename,
                                                                "",
                                                                "",
                                                                \%extras,
                                                                \%files,
                            );

                        $self->cleanup($handle, 63);
                        $self->close($handle);

                        $self->checkstatuscode($statuscode);

                        print "Created data bundle $dataindex.\n" if $messages;
                    }

                    push(@databundlenames, $databundlename);

                    $currentdatastate{bundles}->[$dataindex] = {
                        name => $databundlename,
                        version => $databundleversion,
                        index => $dataindex,
                        files => \%ebcurrentstate,
                        extras => \%extras,
                    };

                    $dataindex++;
                }
            }
        }

        #
        # Create Bundle for job input files
        #

        my $jobfileparameters = "";
        if (defined($params{jobinputfiles}))
        {
            my $extrabundle = $params{jobinputfiles};

            my $datadir = $extrabundle->{datadir} || ".";

            my %files;
            if (defined($extrabundle->{datafiles}))
            {
                my $jiidx = 1;
                foreach my $df (@{$extrabundle->{datafiles}})
                {
                    my $jobinputfn;
                    if (ref($df) eq "ARRAY")
                    {
                        my $subindex = 0;
                        foreach my $dff (@{$df})
                        {
                            $jobinputfn = "input_" . $jiidx . "_" . ($subindex + 1);
                            $files{$jobinputfn} = $datadir . "/" . $dff;
                            $subindex++;
                        }
                    }
                    else
                    {
                        $jobinputfn = "input_" . $jiidx . "_1";
                        $files{$jobinputfn} = $datadir . "/" . $df;
                    }
                    $jiidx++;
                }

            }

            my %jbstoredstate = %{$storeddatastate{bundles}->[$dataindex]->{files} || {}};

            my ($makejobdata, $cjdstmp) = _compare_filestates(\%files, \%jbstoredstate, $extrabundle->{skipmd5});
            my %jbcurrentstate = %{$cjdstmp};

            my %extras;

            $extras{"ExpirationPeriod"} = 3600000; # 1 hour

            my %ebp = %{$extrabundle->{parameters} || {}};

            %extras = (%extras, %ebp);

            # compare extras
            if (!$makejobdata)
            {
                foreach my $ekey (keys(%extras))
                {
                    my $sval = $storeddatastate{bundles}->[$dataindex]->{extras}->{$ekey};
                    if (!defined($sval)
                        || $extras{$ekey} ne $sval)
                    {
                        $makejobdata = 1;
                        last;
                    }
                }
            }

            my $databundlename = $storeddatastate{bundles}->[$dataindex]->{name};
            my $databundleversion = $storeddatastate{bundles}->[$dataindex]->{version} || "0.0.1";

            # check if bundle exists
            if (!$makejobdata)
            {
                my $exists = $self->bundleVersionExists($databundlename, $databundleversion);
                if (!$exists)
                {
                    $makejobdata = 1;
                }
            }

            if ($makejobdata)
            {
                $savestate = 1;

                $databundlename = $binarybundlename . "_jobinputfiles_" . $dataindex . "_" . time() . "_" . int(rand(10000));

                $handle = $self->open();

                # data bundle
                $statuscode = $self->createSignedBundle($handle,
                                                        $databundlename,
                                                        "job input files $dataindex for " . $binarybundlename,
                                                        $databundleversion,
                                                        "",
                                                        "",
                                                        "",
                                                        "",
                                                        "perl_peach_jobinputfiles_$dataindex",
                                                        "",
                                                        "",
                                                        \%extras,
                                                        \%files,
                    );

                $self->cleanup($handle, 63);
                $self->close($handle);

                $self->checkstatuscode($statuscode);

                print "Created job input file bundle $dataindex.\n" if $messages;
            }

            $currentdatastate{bundles}->[$dataindex] = {
                name => $databundlename,
                version => $databundleversion,
                index => $dataindex,
                files => \%jbcurrentstate,
                extras => \%extras,
            };

            if (defined($extrabundle->{filenames}))
            {
                my $jiidx = 1;
                foreach my $fn (@{$extrabundle->{filenames}})
                {
                    if ($jobfileparameters ne "")
                    {
                        $jobfileparameters .= " ";
                    }
                    $jobfileparameters .= "%B(input${jiidx};bundle=${databundlename};returnfile=false;file=input_%P(jobidx)_${jiidx};dest=${fn})";
                    $jiidx++;
                }
            }
            #$dataindex++;
        }

        #
        # Save state
        #

        if ($savestate)
        {
            CORE::open(SF, "> $storefile") || croak "unable to write $storefile";
            print SF freeze($binarybundlename, %currentbinarystate), "\n";
            print SF freeze(%currentbinaryextrastate), "\n";
            print SF freeze(%currentdatastate), "\n";
            CORE::close(SF);
        }

        #
        # create data bundle
        #

        $handle = $self->open();

        my %files;

        # create inputdata file
        my $inputdataname;
        if ($peachclient)
        {
            $inputdataname = "techila_perl_peach_inputdata." . $$ . "." . int(rand(10000));

            CORE::open(OUT, "> $inputdataname");
            my $inputdata = freeze($params{funcname},
                                   $params{params},
                                   $params{peachvector},
                                   $params{files},
                                   $params{datafiles},
                );
            print OUT $inputdata;
            CORE::close(OUT);

            $files{"techila_perl_peach_inputdata"} = $inputdataname;
        }

        my $datadir = $params{datadir} || ".";

        if (defined($params{datafiles}))
        {
            foreach my $df (@{$params{datafiles}})
            {
                $files{$df} = $datadir . "/" . $df;
            }
        }

        my %extras;

        $extras{"ExpirationPeriod"} = 3600000; # 1 hour

        if ($jobfileparameters ne "")
        {
            if ($peachclient)
            {
                $extras{"Parameters"} = "%I(peachclient.pl) %P(jobidx) %L(techila_perl_peach_inputdata) %O(output) " . $jobfileparameters;
            }
            else
            {
                if (defined($params{params}))
                {
                    $extras{"Parameters"} = join(" ", @{$params{params}}) . " " . $jobfileparameters;
                }
                else {
                    $extras{"Parameters"} = $jobfileparameters;
                }
            }
        }

        %extras = (%extras, %bundleparameters);

        if ($dataindex > 0)
        {
            my @extres;
            for (my $i = 0; $i < $dataindex; $i++)
            {
                my $resname = "perl_peach_datafiles_$i";
                push(@extres, "$resname;resource=$resname");
            }
            if (defined($extras{"ExternalResouces"}))
            {
                push(@extres, $extras{"ExternalResouces"});
            }
            $extras{"ExternalResources"} = join(", ", @extres);
        }

        my $databundlename = $binarybundlename . "_data_" . time() . "_" . int(rand(10000));

        my @imports;
        if (@databundlenames)
        {
            @imports = @databundlenames;
        }
        push(@imports, $binarybundlename);
        my $imports_str = join(",", @imports);

        # data bundle
        $statuscode = $self->createSignedBundle($handle,
                                                $databundlename,
                                                "data for " . $binarybundlename,
                                                "0.0.1",
                                                $imports_str,
                                                "",
                                                "",
                                                "",
                                                "techila_perl_peach_inputdata",
                                                "",
                                                $binarybundlename,
                                                \%extras,
                                                \%files,
            );
        $self->checkstatuscode($statuscode);

        if (defined($inputdataname))
        {
            unlink($inputdataname);
        }

        print "Created bundle.\n" if $messages;

        $statuscode = $self->useBundle($handle, $databundlename);
        $self->checkstatuscode($statuscode);

        # create project

        $projectparameters{jobs} = $#{$params{peachvector}} + 1;

        if (defined($clientos) && $clientos ne "")
        {
            $projectparameters{"techila_client_os"} = $clientos;
        }

        $statuscode = $self->createProject($handle,
                                           $priority,
                                           $description,
                                           \%projectparameters,
            );
        $self->checkstatuscode($statuscode);

        print "Project created with id: " . $self->getProjectId($handle) . "\n" if $messages;

    }
    else
    {
        # project id defined
        $handle = $self->open();
        $self->setProjectId($handle, $projectid);
    }

    my @resultvector;

    if ($donotwait)
    {
        push(@resultvector, $handle);
    }
    else # wait
    {
        my $fail = 0;
        if ($stream)
        {
            print "Streaming results...\n" if $messages;
            $self->setStreamResults($handle, 1);
            $statuscode = $self->waitCompletionBG($handle);
            $self->checkstatuscode($statuscode);
        }
        else
        {
            $statuscode = $self->waitCompletion($handle);
            $self->checkstatuscode($statuscode);

            if (!$self->isFailed($handle)
                || $allowpartial) {

                print "Downloading results...\n" if $messages;

                $statuscode = $self->downloadResult($handle, $allowpartial, 0);
                $self->checkstatuscode($statuscode);

                print "Result downloaded, extracting...\n" if $messages;
                $self->unzip($handle);

            } else {
                print "Project failed.\n" if $messages;
                $fail = 1;
            }
        }

        my $waitstarted = time();

        my $running = 1;
        while (!$fail && $running)
        {
            # on normal download this loop is run only once
            # on streaming this loop is run many times

            my $now = time();

            if ($stream)
            {
                #print "waiting for action\n" if $messages;
                $self->actionWait(10000);
                #print "action\n" if $messages;
            }

            my $ref;

            if ($stream)
            {
                $ref = $self->getNewStreamedResultFiles($handle);
            }
            else
            {
                # normal, all files at once
                $ref = $self->getResultFiles($handle);
            }

            #print Dumper($ref);

            if (defined($ref))
            {
                my @resultFiles = @{$ref};

                my $rnd = int(rand() * 10000);
                my $count = 0;

                foreach my $file (@resultFiles)
                {
                    my $zip = 0;
                    my @resfiles;
                    my $tempdir = undef;
                    if (defined($outputfiles)
                        && ($peachclient || $outputfiles =~ m/,/))
                    {
                        # result file is a zip
                        my $unzip = Archive::Extract->new( archive => $file,
                                                           type => "zip");

                        $tempdir = $self->getTempDir() . "/perl_peach_${rnd}_${count}/";
                        mkdir($tempdir);

                        my $ok = $unzip->extract( to => $tempdir );

                        @resfiles = @{$unzip->files};

                        $zip = 1;
                    }
                    else
                    {
                        # single file result
                        push(@resfiles, $file);
                    }

                    foreach my $ufile (@resfiles)
                    {
                        if (defined($tempdir))
                        {
                            $ufile = $tempdir . $ufile;
                        }

                        if ($peachclient
                            && ($zip == 0
                                || $ufile =~ m/techila_peach_result.dat$/))
                        {
                            # peachclient result
                            CORE::open(RES, "< $ufile");
                            my @result = thaw(<RES>);

                            if (defined($callback))
                            {
                                # use callback
                                push(@resultvector, &$callback(@result));
                            }
                            else
                            {
                                push(@resultvector, @result);
                            }

                            CORE::close(RES);

                            if (defined($tempdir) && $zip == 1)
                            {
                                unlink($ufile);
                            }
                        }
                        else
                        {
                            # pass other files to filehandler
                            if (defined($filehandler))
                            {
                                my @result = &$filehandler($ufile);

                                if (!$peachclient)
                                {
                                    if (defined($callback))
                                    {
                                        # use callback
                                        push(@resultvector, &$callback(@result));
                                    }
                                    else
                                    {
                                        push(@resultvector, @result);
                                    }
                                }
                            }

                            if (-e $ufile && $zip == 1)
                            {
                                unlink($ufile);
                            }
                        }
                    }

                    if (defined($tempdir))
                    {
                        rmdir($tempdir);
                    }

                    $count++;
                }
                #print "Results loaded.\n" if $messages;
            }

            if (!$stream || $self->isCompleted($handle))
            {
                $running = 0;
            }

            if (defined($resultsrequired))
            {
                if ($self->_check_results_required($handle, $resultsrequired)
                    && $now >= $waitstarted + $timelimit)
                {
                    print "Required amount of results, stopping...\n" if $messages;
                    $self->stopProject($handle);
                    $running = 0;
                }
            }
        }

        if ($messages)
        {
            $self->printStatistics($handle);
        }

        my $finishfunc = $params{finish};
        if (defined($finishfunc))
        {
            &$finishfunc($handle);
        }

        if ($removeproject)
        {
            $self->removeProject($handle);
        }

    } # wait results


    if ($cleanup)
    {
        $self->cleanup($handle, 63);
    }
    if ($close)
    {
        $self->close($handle);
    }

    # done
    if ($douninit && !$donotuninit)
    {
        # init was called by this peach and not excplicitly told to not uninit
        $self->unload(1, 1);
    }

    return @resultvector;
}


# -- other


sub checkstatuscode
{
    my $self = shift;
    my $statuscode = shift;
    if ($statuscode != 0)
    {
        my $desc = $self->describeStatusCode($statuscode);
        my $msg = "ERROR ($statuscode): $desc";
        cluck 'trace:' if $self->{trace};
        croak $msg;
    }
}

sub printStatistics
{
    my $self = shift;
    my $handle = shift;

    my $cputime = $self->getUsedCpuTime($handle);
    my $realtime = $self->getUsedTime($handle);

    if ($realtime > 0)
    {
        printf("Acceleration factor = %1.2f%%.\n", $cputime * 100 / $realtime);
    }

    if ($cputime >= 0)
    {
        printf("CPU time used %i d %i h %i m %i s.\n",
               floor($cputime / 3600 / 24),
               floor($cputime / 3600 - floor($cputime / 3600 / 24) * 24),
               floor($cputime / 60 - floor($cputime / 3600) * 60),
               floor($cputime - floor($cputime / 60) * 60));
    }
    if ($realtime >= 0)
    {
        printf("Real time used %i d %i h %i m %i s.\n",
               floor($realtime / 3600 / 24),
               floor($realtime / 3600 - floor($realtime / 3600 / 24) * 24),
               floor($realtime / 60 - floor($realtime / 3600) * 60),
               floor($realtime - floor($realtime / 60) * 60));
    }

    my %statistics = $self->getProjectStatistics($handle);

    my $clientcount = $statistics{'clientcount'};
    my $avgeff = $statistics{'avgefficiency'};
    my $mincputime = $statistics{'mincputime'};
    my $avgcputime = $statistics{'avgcputime'};
    my $maxcputime=  $statistics{'maxcputime'};
    my $maxpeakmem = $statistics{'maxpeakmem'};
    my $avgpeakmem = $statistics{'avgpeakmem'};
    my $maxioread = $statistics{'maxioread'};
    my $avgioread = $statistics{'avgioread'};
    my $maxiowrite = $statistics{'maxiowrite'};
    my $avgiowrite = $statistics{'avgiowrite'};
    my $avgiototal = ($avgioread + $avgiowrite) / 1048576;

    print("\nProject Statistics:\n");
    printf("    %d nodes participated\n", $clientcount);
    printf("    Avg efficiency per job:      %2.2f%%\n", $avgeff*100);
    printf("    CPU Time per job:            %1.3fs (min) %1.3fs (avg) %1.3fs (max)\n", $mincputime / 1000, $avgcputime / 1000, $maxcputime / 1000);
    printf("    Memory used per job:         %1.3fMB (avg) %1.3fMB (max)\n", $avgpeakmem / 1048576, $maxpeakmem / 1048576);
    printf("    I/O read per job:            %1.3fMB (avg) %1.3fMB (max)\n", $avgioread / 1048576, $maxioread / 1048576);
    printf("    I/O write per job:           %1.3fMB (avg) %1.3fMB (max)\n", $avgiowrite / 1048576, $maxiowrite / 1048576);
    printf("    Average total I/O per job:   %1.3fMB", $avgiototal);
    if ($avgcputime > 0)
    {
        printf(" (%1.3fMB/s)", $avgiototal / ($avgcputime / 1000));
    }
    print("\n");
}


sub _check_results_required
{
    my $self = shift;
    my $handle = shift;
    my $required = shift;

    if ($required =~ m/^(\d+)%$/)
    {
        my $percent = $1;

        return $self->ready($handle) >= $percent;
    }
    else
    {
        my $handle = $self->{gm}->getHandle($handle);

        return $handle->getReady() >= $required;
    }
    return 0;
}

sub _convert_hash
{
    my %hash = @_;

    my $javaht = Techila::java::util::Hashtable->new();

    foreach my $key (keys(%hash))
    {
        $javaht->put($key, $hash{$key});
    }
    return $javaht;
}


sub _compare_filestates
{
    my %files = %{shift()};
    my %storedstate = %{shift()};
    my $skipmd5 = shift;

    my %currentstate;

    # compute current state
    foreach my $f (sort(keys(%files)))
    {
        #print " $f\n";
        my $realf = $files{$f};
        CORE::open(IF, "$realf") || croak "unable to open $realf";
        my $mtime = (stat(IF))[9];

        my $md5hex;

        if ($skipmd5)
        {
            # use old value or "skipped" if missing
            if (defined($storedstate{$f}->{md5}))
            {
                $md5hex = $storedstate{$f}->{md5};
            }
            else
            {
                $md5hex = "skipped";
            }
        }
        else
        {
            my $md5 = Digest::MD5->new();
            $md5->addfile(*IF);

            $md5hex = $md5->hexdigest();
        }
        CORE::close(IF);

        $currentstate{$f} = {
            md5 => $md5hex,
            mtime => $mtime,
        };

    }

    # compare states
    my $make = 0;
    foreach my $key (keys(%currentstate))
    {
        my %c = %{$currentstate{$key}};
        my %s;

        if (defined($storedstate{$key}))
        {
            %s = %{$storedstate{$key}};
        }
        else
        {
            %s = (mtime => -1, md5 => "x");
        }

        if ($c{mtime} != $s{mtime}
            || $c{md5} ne $s{md5})
        {
            $make = 1;
            last;
        }
    }

    return ($make, \%currentstate);
}
