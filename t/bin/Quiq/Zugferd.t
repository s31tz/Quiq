#!/usr/bin/env perl

package Quiq::Zugferd::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Zugferd');
}

# -----------------------------------------------------------------------------

sub test_unitTest: Test(3) {
    my $self = shift;

    my $zug = eval {Quiq::Zugferd->new('non_existent')};
    $self->like($@,qr/XSD directory does not exist/);

    $zug = Quiq::Zugferd->new('~/doc/2024-09-19_0054_ZUGFeRD/example_basic');
    $self->is(ref($zug),'Quiq::Zugferd');

    my $h = $zug->asHash;
    $self->is(ref($h),'HASH');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Zugferd::Test->runTests;

# eof
