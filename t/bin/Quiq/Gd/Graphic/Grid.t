#!/usr/bin/env perl

package Quiq::Gd::Graphic::Grid::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

use Quiq::Gd::Image;
use Quiq::Path;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Gd::Graphic::Grid');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(2) {
    my $self = shift;

    my $width = 400;
    my $height = 300;

    my $g = Quiq::Gd::Graphic::Grid->new(
    );
    $self->is(ref $g,'Quiq::Gd::Graphic::Grid');

    my $img = Quiq::Gd::Image->new($width,$height);
    $img->background('ffffff');
    $img->border('f0f0f0');

    $g->render($img,0,0,
    );

    # my $file = Quiq::Path->tempFile;
    my $file = '/tmp/grid.png';
    Quiq::Path->write($file,$img->png);
    $self->ok(-e $file);
}

# -----------------------------------------------------------------------------

package main;
Quiq::Gd::Graphic::Grid::Test->runTests;

# eof
