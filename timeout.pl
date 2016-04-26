#!/usr/bin/perl

# timeout
#
# (c) 2004-2007, 2016 Piotr Roszatycki <dexter@debian.org>, GPL

=head1 NAME

timeout - Run command with bounded time.

=head1 SYNOPSIS

B<timeout> S<B<-h>>

B<timeout>
S<[-I<signal>]>
I<time>
I<command>
...

=head1 README

B<timeout> executes a command and imposes an elapsed time limit.  When the
time limit is reached, B<timeout> sends a predefined signal to the target
process.

=cut


use 5.006;
use strict;
use warnings;

use Config;
use POSIX ();


our $NAME = 'timeout';
our $VERSION = '0.12';


# Prints usage message.
sub usage {
    require Pod::Usage;
    Pod::Usage::pod2usage(2);
}


# Prints help message.
sub help {
    require Pod::Usage;
    Pod::Usage::pod2usage(-verbose=>1, -message=>"$NAME $VERSION\n");
}


# Handler for signals to clean up child processes
sub signal_handler {
    my ($child_pid, $kill_signal, $signal) = @_;

    if ($signal eq 'ALRM') {
        print STDERR "Timeout: aborting command ``@ARGV'' with signal SIG$kill_signal\n";
    } else {
        print STDERR "Got signal SIG$signal: aborting command ``@ARGV'' with signal SIG$signal\n";
    }

    kill $kill_signal, -$child_pid;

    exit -1;
}


# Main subroutine
sub main {
    # Signals to handle
    my @signals = qw{HUP INT QUIT TERM SEGV PIPE XCPU XFSZ ALRM};

    # Default signal to stop child process
    my $kill_signal = 'KILL';

    # Default time to wait
    my $time = 0;

    # Parse command line arguments without Getopt::Long
    my $arg = $ARGV[0];
    usage() unless $arg;

    if (my ($opt) = $arg =~ /^-(.*)$/) {
        if ($arg eq '-h' || $arg eq '--help') {
            help();
        } elsif ($opt =~ /^[A-Z0-9]+$/) {
            if ($opt =~ /^\d+/) {
    	    # Convert numeric signal to name by using the perl interpreter's
    	    # configuration:
                usage() unless defined $Config{sig_name};
                $kill_signal = (split(' ', $Config{sig_name}))[$opt];
            } else {
                $opt =~ s/^SIG//;
                $kill_signal = $opt;
            }
    	shift @ARGV;
        } else {
            usage();
        }
    }

    usage() if @ARGV < 2;

    $arg = $ARGV[0];
    usage() unless $arg =~ /^\d+$/;

    $time = $arg;
    shift @ARGV;

    # Fork for exec
    if (not defined(my $child_pid = fork)) {
        die "Could not fork: $!\n";
    } elsif ($child_pid == 0) {
        # child

        # Set new process group
        POSIX::setsid;

        # Execute command
        exec @ARGV or die "Can not run command @ARGV: $!\n";

        # Should not be occured
        die "Could not exec: $!\n";
    } else {
        # parent

        # Set the handle for signals
        foreach my $signal (@signals) {
            $SIG{$signal} = sub { signal_handler($child_pid, $kill_signal, @_) };
        }

        # Set the alarm
        alarm $time;

        # Wait for child
        my $pid;
        while (($pid = wait) != -1 && $pid != $child_pid) {}

        # Clean exit
        exit ($pid == $child_pid ? $? >> 8 : -1);
    }
}


main();


__END__

=head1 DESCRIPTION

B<timeout> executes a command and imposes an elapsed time limit.
The command is run in a separate POSIX process group so that the
right thing happens with commands that spawn child processes.

=head1 OPTIONS

=over 8

=item -I<signal>

Specify an optional signal name to send to the controlled process. By default,
B<timeout> sends B<KILL>, which cannot be caught or ignored.

=item I<time>

The elapsed time limit after which the command is terminated.

=item I<command>

The command to be executed.

=back

=head1 RETURN CODES

=over 8

=item S<0..253>

Return code from called command.

=item S<254>

Internal error. No return code could be fetched.

=item S<255>

The timeout was occured.

=back

=head1 PREREQUISITES

=over 2

=item *

L<perl> >= 5.006

=item *

L<POSIX>

=back

=head1 COREQUISITES

=over 2

=item *

L<Pod::Usage>

=back

=head1 SCRIPT CATEGORIES

UNIX/System_administration

=head1 AUTHORS

Piotr Roszatycki <dexter@debian.org>

=head1 LICENSE

Copyright 2004-2007, 2016 by Piotr Roszatycki <dexter@debian.org>.

Inspired by timeout.c that is part of The Coroner's Toolkit.

All rights reserved.  This program is free software; you can redistribute it
and/or modify it under the terms of the GNU General Public License, the
latest version.
