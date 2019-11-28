#!/usr/bin/env perl

package Quiq::ChartJs::TimeSeries::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

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
        push @rows,$_;
        # Begrenzung der Anzahl der Messwerte
        if (@rows == 200) {
            last;
        }
    }
    $fh->close;

    my $ch = Quiq::ChartJs::TimeSeries->new(
        parameter => 'Windspeed',
        unit => 'm/s',
        aspectRatio => 8/2.2,
        points => \@rows,
        pointCallback => sub {
             my ($point,$i) = @_;
             my ($iso,$val) = split /\t/,$point,2;
             return [Quiq::Epoch->new($iso)->epoch*1000,$val];
        },
    );
    $self->is(ref($ch),'Quiq::ChartJs::TimeSeries');
    $self->is($ch->name,'plot');

    my $h = Quiq::Html::Producer->new;

    #my $html = Quiq::Html::Page->html($h,
    #    title => 'Chart.js testpage',
    #    load => [
    #        js => $ch->cdnUrl('2.8.0'),
    #    ],
    #    body => $h->cat(
    #        $h->tag('canvas',
    #            id => $ch->name,
    #        ),
    #        $ch->html($h),
    #    ),
    #);

    my $html = Quiq::Html::Fragment->html($h,
        html => $h->cat(
            $h->tag('script',
                src => $ch->cdnUrl('2.8.0'),
            ),
            $h->tag('canvas',
                 id => $ch->name,
            ),
            $ch->html($h),
        ),
    );

    my $p = Quiq::Path->new;
    my $blobFile = 'Blob/doc-content/quiq-chartjs-timeseries.html';
    if ($p->exists('Blob/doc-content') && $p->compareData($blobFile,$html)) {
        $p->write($blobFile,$html);
    }
    my $pod = "=format html\n\n$html\n=end html\n";
    $blobFile = 'Blob/doc-content/quiq-chartjs-timeseries.pod';
    if ($p->exists('Blob/doc-content') && $p->compareData($blobFile,$pod)) {
        $p->write($blobFile,$pod);
    }
}

# -----------------------------------------------------------------------------

package main;
Quiq::ChartJs::TimeSeries::Test->runTests;

# eof
