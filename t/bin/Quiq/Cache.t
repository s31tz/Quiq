#!/usr/bin/env perl

package Quiq::Cache::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Cache');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Cache::Test->runTests;

# eof
