#!/usr/bin/env perl

package Quiq::Json::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Json');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Json::Test->runTests;

# eof
