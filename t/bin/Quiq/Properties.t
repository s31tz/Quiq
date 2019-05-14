#!/usr/bin/env perl

package Quiq::Properties::Test;
use base qw/Quiq::Test::Class/;

use strict;
use warnings;
use v5.10.0;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Properties');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Properties::Test->runTests;

# eof
