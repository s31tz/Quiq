#!/usr/bin/env perl

package Quiq::Smb::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Smb');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Smb::Test->runTests;

# eof
