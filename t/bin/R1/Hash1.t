#!/usr/bin/env perl

package R1::Hash1::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('R1::Hash1');
}

# -----------------------------------------------------------------------------

package main;
R1::Hash1::Test->runTests;

# eof
