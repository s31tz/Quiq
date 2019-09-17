#!/usr/bin/env perl

package Quiq::Database::ResultSet::Object::Test;
use base qw/Quiq::Test::Class/;

use v5.10.0;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Database::ResultSet::Object');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Database::ResultSet::Object::Test->runTests;

# eof
