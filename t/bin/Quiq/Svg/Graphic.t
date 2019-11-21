#!/usr/bin/env perl

package Quiq::Svg::Graphic::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Svg::Graphic');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(1) {
    my $self = shift;

    my $g = Quiq::Svg::Graphic->new;
    $self->is(ref $g,'Quiq::Svg::Graphic');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Svg::Graphic::Test->runTests;

# eof
