#!/usr/bin/env perl

package Quiq::Hash::Persistent::Test;
use base qw/Quiq::Test::Class/;

use strict;
use warnings;
use v5.10.0;

use Quiq::Path;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Hash::Persistent');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(5) {
    my $self = shift;

    my $p = Quiq::Path->new;

    my $file = '/tmp/Quiq::Hash::Persistent.tst'; # $p->tempFile funktioniert nicht. Warum?
    my $timeout = 5;

    my $h = Quiq::Hash::Persistent->new($file,$timeout,sub {
        my $class = shift;
        return $class->Quiq::Hash::new(
            a => 1,
            b => 2,
        );
    });

    $self->is(ref($h),'Quiq::Hash::Persistent');
    $self->is($h->a,1);
    $self->is($h->b,2);
    $self->is($h->cacheFile,$file);
    $self->is($h->cacheTimeout,$timeout);

    $p->delete($file);
}

# -----------------------------------------------------------------------------

package main;
Quiq::Hash::Persistent::Test->runTests;

# eof
