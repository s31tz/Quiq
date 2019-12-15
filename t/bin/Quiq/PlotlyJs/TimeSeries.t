#!/usr/bin/env perl

package Quiq::PlotlyJs::TimeSeries::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::PlotlyJs::TimeSeries');
}

# -----------------------------------------------------------------------------

package main;
Quiq::PlotlyJs::TimeSeries::Test->runTests;

# eof
