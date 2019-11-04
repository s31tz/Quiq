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
use Quiq::Gd::Graphic::BlockDiagram;
use Quiq::Gd::Image;
use Quiq::Path;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::ProcessMatrix');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(5) {
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

    # Klasse, Anzahl Zeitschienen, Anzahl Einträge auf der
    # längsten Zeitschiene

    $self->is(ref $mtx,'Quiq::ProcessMatrix');
    $self->is($mtx->width,396);
    $self->is($mtx->maxLength,167);

    # Einträge auf der ersten Zeitschiene
    
    my @entries = $mtx->entries(0);
    $self->is(scalar @entries,167);

    # Einträge auf allen Zeitschienen zusammen

    @entries = $mtx->entries;
    $self->is(scalar @entries,3123);

    # Zeitspanne

    warn "\n";
    warn $mtx->minTime,"\n";
    warn $mtx->maxTime,"\n";
    warn $mtx->maxTime-$mtx->minTime,"\n";

    # Grafik erzeugen

    my $width = $mtx->width * 5;
    my $height = 400;

    my $g = Quiq::Gd::Graphic::BlockDiagram->new(
        width => $width,
        height => $height,
    );

    my $img = Quiq::Gd::Image->new($width,$height);
    $img->background('ffffff');
    $img->border('f0f0f0');

    $g->render($img,0,0,
    );

    my $file = Quiq::Path->tempFile(-unlink=>0);
    Quiq::Path->write($file,$img->png);

    return;
}

# -----------------------------------------------------------------------------

package main;
Quiq::ProcessMatrix::Test->runTests;

# eof
