#!/usr/bin/env perl

package Quiq::Svg::Tag::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;
use utf8;

use Quiq::Path;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Svg::Tag');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(5) {
    my $self = shift;

    # Instantiierung

    my $t = Quiq::Svg::Tag->new;
    $self->is(ref $t,'Quiq::Svg::Tag');

    # Präambel

    my $svg = $t->preamble;
    $self->like($svg,qr/<!DOCTYPE/);

    $svg = $t->svg(width=>400,height=>300);
    $self->like($svg,qr/width="400"/);
    $self->like($svg,qr/height="300"/);
    $self->like($svg,qr{\Qxmlns:xlink="http://www.w3.org/1999/xlink"});

    $svg = $t->cat(
        $t->preamble,
        $t->svg(
            width => 100,
            height => 100,
            '-',
            $t->tag('circle',
                cx => 50,
                cy => 50,
                r => 49,
                style => 'stroke: black; fill: yellow',
            ),
        ),
    );

    my $p = Quiq::Path->new;
    my $blobFile = 'Blob/doc-image/quiq-svg-tag-01.svg';
    if ($p->exists('Blob/doc-image') && $p->compareData("$blobFile",$svg)) {
        $p->write("$blobFile",$svg);
    }
}

# -----------------------------------------------------------------------------

package main;
Quiq::Svg::Tag::Test->runTests;

# eof
