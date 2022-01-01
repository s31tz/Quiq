#!/usr/bin/env perl

package Quiq::Html::Resources::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Html::Resources');
}

# -----------------------------------------------------------------------------

sub test_unitTest: Test(5) {
    my $self = shift;

    my $res = Quiq::Html::Resources->new(
        jquery => {
            js => [
                'https://code.jquery.com/jquery-latest.min.js',
            ],
        },
        datatables => {
            css => [
                'https://cdn.datatables.net/v/dt/dt-1.11.3/'.
                    'datatables.min.css',
            ],
            js => [
                'https://cdn.datatables.net/v/dt/dt-1.11.3/'.
                    'datatables.min.js',
            ],
        },
    );
    $self->is(ref($res),'Quiq::Html::Resources');

    my @arr = $res->resources('datatables','css');
    $self->isDeeply(\@arr,[
        'https://cdn.datatables.net/v/dt/dt-1.11.3/datatables.min.css',
    ]);

    @arr = $res->resources('datatables','js');
    $self->isDeeply(\@arr,[
        'https://cdn.datatables.net/v/dt/dt-1.11.3/datatables.min.js',
    ]);

    eval {$res->resources('unknown','css')};
    $self->like($@,qr/Key does not exist/);

    eval {$res->resources('datatables','unknown')};
    $self->like($@,qr/Unexpected value/);

    return;
}

# -----------------------------------------------------------------------------

package main;
Quiq::Html::Resources::Test->runTests;

# eof
