#!/usr/bin/env perl

package Quiq::ProcessMatrix::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;
use utf8;

use Quiq::Test::Class;
use Quiq::FileHandle;
use Quiq::ProcessMatrix;
use Quiq::Epoch;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::ProcessMatrix');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(3) {
    my $self = shift;

    # Daten einlesen und Prozess-Objekte erzeugen

    my $dataFile = Quiq::Test::Class->testPath(
        'quiq/test/data/db/process.dat');
    my $fh = Quiq::FileHandle->new('<',$dataFile);

    my @objects;
    while (<$fh>) {
        chomp;
        my $prc = [split /\t/];
        if (!$prc->[5]) {
            # Prozesse ohne Ende-Zeitpunkt übergehen wir
            next;
        }
        push @objects,$prc;
    }
    $fh->close;

    # Prozess-Matrix erzeugen

    my $mtx = Quiq::ProcessMatrix->new(\@objects,sub {
        my $obj = shift;
        return (
            Quiq::Epoch->new($obj->[4])->epoch,
            Quiq::Epoch->new($obj->[5])->epoch,
        );
    });

    $self->is(ref $mtx,'Quiq::ProcessMatrix');
    $self->is($mtx->width,396);
    $self->is($mtx->maxLength,167);

    return;
}

# -----------------------------------------------------------------------------

package main;
Quiq::ProcessMatrix::Test->runTests;

# eof
