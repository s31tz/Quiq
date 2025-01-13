#!/usr/bin/env perl

package Quiq::Zugferd::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;
use utf8;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Zugferd');
}

# -----------------------------------------------------------------------------

sub test_unitTest: Test(1) {
    my $self = shift;

    if ($0 =~ /\.cotedo/) {
        $ENV{'ZUGFERD_DIR'} = $ENV{'HOME'}.'/dvl/jaz/Blob/zugferd';
    }
    my $zug = Quiq::Zugferd->new;
    $self->is(ref($zug),'Quiq::Zugferd');

    # FIXME: Tests hinzufügen

    my $str = $zug->doc('xml');
    $str = $zug->doc('tree');

    my $xml = $zug->xml('empty');
    $xml = $zug->xml('placeholders');
    $xml = $zug->xml('values');

    my $h = $zug->tree('empty'); # Kann nicht nach XML gewandelt werden
    $h = $zug->tree('placeholders'); # Kann nicht nach XML gewandelt werden
    $h = $zug->tree('values');
    $xml = $zug->treeToXml($h);
}

# -----------------------------------------------------------------------------

package main;
Quiq::Zugferd::Test->runTests;

# eof
