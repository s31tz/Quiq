#!/usr/bin/env perl

package Quiq::Sftp::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Sftp');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Sftp::Test->runTests;

# eof
