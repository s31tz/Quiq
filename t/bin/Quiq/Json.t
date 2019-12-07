#!/usr/bin/env perl

package Quiq::Json::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;
use utf8;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Json');
}

# -----------------------------------------------------------------------------

sub test_encode : Test(12) {
    my $self = shift;

    # Instantiierung

    my $j = Quiq::Json->new;
    $self->is(ref $j,'Quiq::Json');

    # Skalar

    my $json = $j->encode(undef);
    $self->is($json,'null');

    $json = $j->encode(5);
    $self->is($json,'5');

    $json = $j->encode(3.14159);
    $self->is($json,'3.14159');

    $json = $j->encode('abc');
    $self->is($json,"'abc'");

    $json = $j->encode(\1);
    $self->is($json,'true');

    $json = $j->encode(\0);
    $self->is($json,'false');

    # Array

    $json = $j->encode([]);
    $self->is($json,'[]');

    $json = $j->encode([undef,5,3.14159,['abc',\1,\0]]);
    $self->is($json,"[null,5,3.14159,['abc',true,false]]");

    # Hash

    $json = $j->encode({});
    $self->is($json,'{}');

    $json = $j->encode({a=>1,b=>2});
    $self->is($json,'{a:1,b:2}');

    # Array of Hashes

    $json = $j->encode([{a=>1},{b=>2}]);
    $self->is($json,'[{a:1},{b:2}]');
}

# -----------------------------------------------------------------------------

sub test_object : Test(4) {
    my $self = shift;

    # Instantiierung

    my $j = Quiq::Json->new;
    $self->is(ref $j,'Quiq::Json');

    # Object

    my $json = $j->object(
        a => 1,
        b => 'xyz',
    );
    $self->is($json,Quiq::Unindent->trim(q~
        {
            a: 1,
            b: 'xyz',
        }
    ~));

    # Objekt (ohne Einrückung)

    $json = $j->object(
        -indent => 0,
        a => 1,
        b => 2,
    );
    $self->is($json,'{a:1,b:2}');

    # Geschachtelte Objekte

    $json = $j->object(
        a => 1,
        b => $j->object(
            c => 2,
        ),
    );
    $self->is($json,Quiq::Unindent->trim(q~
        {
            a: 1,
            b: {
                c: 2,
            },
        }
    ~));
}

# -----------------------------------------------------------------------------

sub test_key : Test(2) {
    my $self = shift;

    my $j = Quiq::Json->new;
 
    my $json = $j->key('borderWidth');
    $self->is($json,'borderWidth');

    $json = $j->key('border-width');
    $self->is($json,"'border-width'");
}

# -----------------------------------------------------------------------------

package main;
Quiq::Json::Test->runTests;

# eof
