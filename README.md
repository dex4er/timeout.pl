# NAME

timeout - Run command with bounded time.

# SYNOPSIS

**timeout** **-h**

**timeout**
\[-_signal_\]
_time_
_command_
...

# README

**timeout** executes a command and imposes an elapsed time limit.  When the
time limit is reached, **timeout** sends a predefined signal to the target
process.

# DESCRIPTION

**timeout** executes a command and imposes an elapsed time limit.
The command is run in a separate POSIX process group so that the
right thing happens with commands that spawn child processes.

# OPTIONS

- -_signal_

    Specify an optional signal name to send to the controlled process. By default,
    **timeout** sends **KILL**, which cannot be caught or ignored.

- _time_

    The elapsed time limit after which the command is terminated.

- _command_

    The command to be executed.

# RETURN CODES

- 0..253

    Return code from called command.

- 254

    Internal error. No return code could be fetched.

- 255

    The timeout was occured.

# PREREQUISITES

- [perl](https://metacpan.org/pod/perl) >= 5.006
- [POSIX](https://metacpan.org/pod/POSIX)

# COREQUISITES

- [Pod::Usage](https://metacpan.org/pod/Pod::Usage)

# SCRIPT CATEGORIES

UNIX/System\_administration

# AUTHORS

Piotr Roszatycki <dexter@debian.org>

# LICENSE

Copyright 2004-2007, 2016 by Piotr Roszatycki <dexter@debian.org>.

Inspired by timeout.c that is part of The Coroner's Toolkit.

All rights reserved.  This program is free software; you can redistribute it
and/or modify it under the terms of the GNU General Public License, the
latest version.
