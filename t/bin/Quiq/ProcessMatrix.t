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
use Quiq::Axis::Numeric;
use Quiq::Gd::Font;
use Quiq::Gd::Graphic::Axis;
use Quiq::Gd::Image;
use Quiq::Path;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::ProcessMatrix');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(7) {
    my $self = shift;

    # Daten einlesen und Prozess-Objekte erzeugen

    my $dataFile = Quiq::Test::Class->testPath(
        'quiq/test/data/db/process.dat');
    my $fh = Quiq::FileHandle->new('<',$dataFile);

    my @objects;
    while (<$fh>) {
        chomp;
        my $prc = [split /\t/];
        push @objects,$prc;
    }
    $fh->close;

    # Prozess-Matrix erzeugen

    my $mtx = Quiq::ProcessMatrix->new(\@objects,sub {
        my $obj = shift;
        return (
            Quiq::Epoch->new($obj->[4])->epoch,
            defined $obj->[5]? Quiq::Epoch->new($obj->[5])->epoch: undef,
        );
    });

    # Klasse, Anzahl Zeitschienen, Anzahl Einträge auf der
    # längsten Zeitschiene

    $self->is(ref $mtx,'Quiq::ProcessMatrix');
    $self->is($mtx->width,396);
    $self->is($mtx->maxLength,162);

    # Einträge auf der ersten Zeitschiene
    
    my @entries = $mtx->entries(0);
    $self->is(scalar @entries,162);

    # Einträge auf allen Zeitschienen zusammen

    @entries = $mtx->entries;
    $self->is(scalar @entries,3126);

    # Zeitgrenzen

    $self->is($mtx->minTime,'1572371670.3300000');
    $self->is($mtx->maxTime,'1572444527.0130000');

    # Grafik erzeugen

    my $width = $mtx->width * 10;
    my $height = ($mtx->maxTime-$mtx->minTime)/30; # 1 Pixel == 30s

    my $g = Quiq::Gd::Graphic::BlockDiagram->new(
        width => $width,
        height => $height,
        xMin => 0,
        xMax => $mtx->width-1,
        yMin => $mtx->minTime,
        yMax => $mtx->maxTime,
        objects => \@entries,
        objectCallback => sub {
            my $obj = shift;
            my $color;
            if ($obj->object->[1] eq 'STRT') {
                $color = '#0000ff';
            }
            elsif ($obj->object->[0] eq 'UOW') {
                $color = '#ffff00';
            }
            else {
                $color = '#ff0000';
            }
            return (
                $obj->timeline,        # x-Position
                $obj->begin,           # y-Position
                1,                     # Block-Breite
                $obj->end-$obj->begin, # Block-Höhe
                $color,                # Block-Farbe
            ),
        },
    );

    my $ax = Quiq::Axis::Numeric->new(
        orientation => 'x',
        font => Quiq::Gd::Font->new('gdSmallFont'),
        length => $width,
        min => 0.5,
        max => $mtx->width,
    );
    my $gAx = Quiq::Gd::Graphic::Axis->new(axis=>$ax);
    my $axHeight = $gAx->height;

    my $ay = Quiq::Axis::Numeric->new(
        orientation => 'y',
        font => Quiq::Gd::Font->new('gdSmallFont'),
        length => $height,
        min => $mtx->minTime,
        max => $mtx->maxTime,
    );
    my $gAy = Quiq::Gd::Graphic::Axis->new(axis=>$ay);
    my $ayWidth = $gAy->width;

    my $img = Quiq::Gd::Image->new($width+$ayWidth,$height+$axHeight);
    $img->background('#ffffff');

    $g->render($img,$ayWidth,0);
    $gAx->render($img,$ayWidth,$height);
    $gAy->render($img,$ayWidth,$height);

    # my $file = Quiq::Path->tempFile(-unlink=>0);
    my $file = '/tmp/blockdiagram.png';
    Quiq::Path->write($file,$img->png);

    return;
}

# -----------------------------------------------------------------------------

package main;
Quiq::ProcessMatrix::Test->runTests;

# eof
