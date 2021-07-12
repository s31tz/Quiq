#!/usr/bin/env perl

package Quiq::SQLite::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::SQLite');
}

# -----------------------------------------------------------------------------

package main;
Quiq::SQLite::Test->runTests;

# eof
