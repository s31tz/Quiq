#!/usr/bin/env perl

package Quiq::GD::Image::Test;
use base qw/Quiq::Test::Class/;

use strict;
use warnings;
use v5.10.0;

use Test::More;

# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

sub initMethod : Init(2) {
    my $self = shift;

    eval {require GD};
    if ($@) {
        $self->skipAllTests('GD nicht installiert');
        return;
    }
    ok 1;

    $self->useOk('Quiq::GD::Image');
}

sub test_unitTest : Test(4) {
    my $self = shift;

    my $img = Quiq::GD::Image->new(100,100);
    is ref($img),'Quiq::GD::Image','new';

    my $white = $img->background(255,255,255);
    ok $white >= 0,'background';

    my $white2 = $img->color(255,255,255);
    is $white,$white2;

    my $black = $img->color(0,0,0);
    isnt $black,$white;
}

# -----------------------------------------------------------------------------

sub test_color_truecolor : Test(9) {
    my $self = shift;

    my $img = Quiq::GD::Image->new(100,100); # TrueColor
    my $black = $img->color('#000000');
    my $white = $img->color('#ffffff');
    isnt $white,$black;
    my $white2 = $img->color('#ffffff');
    is $white2,$white;

    # Dasselbe mit Farbangabe ohne #

    $black = $img->color('000000');
    $white = $img->color('ffffff');
    isnt $white,$black;
    $white2 = $img->color('ffffff');
    is $white2,$white;

    # ($r,$g,$b) und [$r,$g,$b]
    my $color1 = $img->color(50,100,200);
    my $color2 = $img->color([50,100,200]);
    is $color2,$color2;

    # Defaultfarbe
    my $color = $img->color(undef);
    is $color,$black;

    # Defaultfarbe
    $color = $img->color;
    is $color,$black;

    # GD-Farbe
    $color = $img->color($black);
    is $color,$black;

    $color = $img->color($white);
    is $color,$white;
}

sub test_color_palette : Test(7) {
    my $self = shift;

    my $img = Quiq::GD::Image->new(100,100,10); # TrueColor
    my $black = $img->color('#000000');
    my $white = $img->color('#ffffff');
    isnt $white,$black;
    my $white2 = $img->color('#ffffff');
    is $white2,$white;

    # ($r,$g,$b) und [$r,$g,$b]
    my $color1 = $img->color(50,100,200);
    my $color2 = $img->color([50,100,200]);
    is $color2,$color2;

    # Defaultfarbe
    my $color = $img->color(undef);
    is $color,$black;

    # Defaultfarbe
    $color = $img->color;
    is $color,$black;

    # GD-Farbe
    $color = $img->color($black);
    is $color,$black;

    $color = $img->color($white);
    is $color,$white;
}

# -----------------------------------------------------------------------------

sub test_rainbowColors : Test(9) {
    my $self = shift;

    for my $n (4,8,16,32,64,128,256,512,1024) {
        my $img = Quiq::GD::Image->new(500,20);
        my @colors = $img->rainbowColors($n);
        is @colors,$n,"rainbowColors: $n Farben";
    }
}

# -----------------------------------------------------------------------------

package main;
Quiq::GD::Image::Test->runTests;

# eof
