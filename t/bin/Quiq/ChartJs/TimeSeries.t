#!/usr/bin/env perl

package Quiq::ChartJs::TimeSeries::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;
use utf8;

use Quiq::Test::Class;
use Quiq::FileHandle;
use Quiq::Epoch;
use Quiq::Html::Producer;
use Quiq::Html::Page;
use Quiq::Html::Fragment;
use Quiq::Path;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::ChartJs::TimeSeries');
}

# -----------------------------------------------------------------------------

sub test_unitTest: Test(2) {
    my $self = shift;

    # Zeitreihendaten einlesen

    my $dataFile = Quiq::Test::Class->testPath(
        'quiq/test/data/db/timeseries.dat');
    my $fh = Quiq::FileHandle->new('<',$dataFile);

    my @rows;
    while (<$fh>) {
        if (!/^2007/) {
            next;
        }
        chomp;
        s/^2007/2019/;
        push @rows, $_;
        # Begrenzung der Anzahl der Messwerte
        if (/2019-11-13 00:00:00/) {
            last;
        }
    }
    $fh->close;

    # Koordinaten für die Klasse erstellen

    my (@t,@y);
    for (@rows) {
        my ($iso,$val) = split /\t/;
        push @t,Quiq::Epoch->new($iso)->epoch*1000;
        push @y,$val;
    }

    my $ch = Quiq::ChartJs::TimeSeries->new(
        t => \@t,
        y => \@y,
        parameter => 'Windspeed',
        unit => 'm/s',
        yMin => 0,
        showMedian => 1,
    );
    $self->is(ref($ch),'Quiq::ChartJs::TimeSeries');
    $self->is($ch->name,'plot');

    my $h = Quiq::Html::Producer->new;

    #my $html = Quiq::Html::Page->html($h,
    #    title => 'Chart.js testpage',
    #    load => [
    #        js => $ch->cdnUrl('2.8.0'),
    #    ],
    #    body => $ch->html($h),
    #    ),
    #);

    my $html = Quiq::Html::Fragment->html($h,
        html => $h->cat(
            $h->tag('script',
                src => $ch->cdnUrl('2.8.0'),
            ),
            $ch->html($h),
        ),
    );

    my $p = Quiq::Path->new;
    my $blobFile = 'Blob/doc-content/quiq-chartjs-timeseries.html';
    if ($p->exists('Blob/doc-content') && $p->compareData($blobFile,$html)) {
        $p->write($blobFile,$html);
    }
    my $pod =  "=begin html\n\n$html\n\n=end html\n";
    $blobFile = 'Blob/doc-content/quiq-chartjs-timeseries.pod';
    if ($p->exists('Blob/doc-content') && $p->compareData($blobFile,$pod)) {
        $p->write($blobFile,$pod);
    }

my $js = $ch->js;
warn $js;
}

# -----------------------------------------------------------------------------

package main;
Quiq::ChartJs::TimeSeries::Test->runTests;

# eof
