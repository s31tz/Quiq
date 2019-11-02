#!/usr/bin/env perl

package Quiq::Gd::Graphic::BlockDiagram::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

use Quiq::Gd::Image;
use Quiq::Path;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Gd::Graphic::BlockDiagram');
}

# -----------------------------------------------------------------------------

sub test_unitTest_no_arguments : Test(2) {
    my $self = shift;

    my $width = 200;
    my $height = 400;

    my $g = Quiq::Gd::Graphic::BlockDiagram->new(
        width => $width,
        height => $height,
    );
    $self->is(ref $g,'Quiq::Gd::Graphic::BlockDiagram');

    my $img = Quiq::Gd::Image->new($width,$height);
    $img->background('ffffff');
    $img->border('f0f0f0');

    $g->render($img,0,0,
    );

    my $file = '/tmp/blockdiagram.png';
    Quiq::Path->write($file,$img->png);
    $self->ok(-e $file);

    # auskommentieren, um erzeugtes Bild anzusehen
    #Quiq::Path->delete($file);
}

# -----------------------------------------------------------------------------

package main;
Quiq::Gd::Graphic::BlockDiagram::Test->runTests;

# eof
