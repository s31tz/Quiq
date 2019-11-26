#!/usr/bin/env perl

package Quiq::ChartJs::TimeSeries::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::ChartJs::TimeSeries');
}

# -----------------------------------------------------------------------------

sub test_unitTest: Test(2) {
    my $self = shift;

    my $ch = Quiq::ChartJs::TimeSeries->new;
    $self->is(ref($ch),'Quiq::ChartJs::TimeSeries');
    $self->is($ch->name,'timeseries');

    # warn $ch->javaScript;
}

# -----------------------------------------------------------------------------

package main;
Quiq::ChartJs::TimeSeries::Test->runTests;

# eof
