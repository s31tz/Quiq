#!/usr/bin/env perl

package Quiq::SQLite::Database::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::SQLite::Database');
}

# -----------------------------------------------------------------------------

package main;
Quiq::SQLite::Database::Test->runTests;

# eof
