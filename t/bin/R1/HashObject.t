#!/usr/bin/env perl

package R1::HashObject::Test;
use base qw/Quiq::Test::Class/;

use strict;
use warnings;
use v5.10.0;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('R1::HashObject');
}

# -----------------------------------------------------------------------------

package main;
R1::HashObject::Test->runTests;

# eof
