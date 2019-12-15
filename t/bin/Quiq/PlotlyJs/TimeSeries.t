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

sub test_unitTest: Test(1) {
    my $self = shift;

    my $plt = Quiq::PlotlyJs::TimeSeries->new;
    $self->is(ref($plt),'Quiq::PlotlyJs::TimeSeries');

    $self->diag($plt->js);
}

# -----------------------------------------------------------------------------

package main;
Quiq::PlotlyJs::TimeSeries::Test->runTests;

# eof
