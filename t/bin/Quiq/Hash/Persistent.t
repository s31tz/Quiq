#!/usr/bin/env perl

package Quiq::Hash::Persistent::Test;
use base qw/Quiq::Test::Class/;

use strict;
use warnings;
use v5.10.0;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Hash::Persistent');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Hash::Persistent::Test->runTests;

# eof
