#!/usr/bin/env perl

package Quiq::PlotlyJs::DiagramGroup::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::PlotlyJs::DiagramGroup');
}

# -----------------------------------------------------------------------------

package main;
Quiq::PlotlyJs::DiagramGroup::Test->runTests;

# eof
