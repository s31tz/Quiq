#!/usr/bin/env perl

package Quiq::Sql::Statement::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Sql::Statement');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Sql::Statement::Test->runTests;

# eof
