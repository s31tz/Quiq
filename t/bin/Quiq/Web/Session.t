#!/usr/bin/env perl

package Quiq::Web::Session::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Web::Session');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Web::Session::Test->runTests;

# eof
