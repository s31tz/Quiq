#!/usr/bin/env perl

package Quiq::PlotlyJs::Parameter::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::PlotlyJs::Parameter');
}

# -----------------------------------------------------------------------------

package main;
Quiq::PlotlyJs::Parameter::Test->runTests;

# eof
