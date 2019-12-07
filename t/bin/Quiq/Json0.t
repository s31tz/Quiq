#!/usr/bin/env perl

package Quiq::Json0::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;
use utf8;

use Quiq::Unindent;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Json0');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(15) {
    my $self = shift;

    # Instantiierung

    my $j = Quiq::Json0->new;
    $self->is(ref $j,'Quiq::Json0');

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
    $self->is($json,Quiq::Unindent->trim(q~
        {
            a: 1,
            b: 2,
        }
    ~));

    $json = $j->encode({a=>1,b=>{c=>2}});
    $self->is($json,Quiq::Unindent->trim(q~
        {
            a: 1,
            b: {
                c: 2,
            },
        }
    ~));

    # Array of Hashes

    $json = $j->encode([{a=>1},{b=>2}]);
    $self->is($json,Quiq::Unindent->trim(q~
        [{
            a: 1,
        },{
            b: 2,
        }]
    ~));

    # Array mit Einrückung

    $j = Quiq::Json0->new(
        indentArrayElements => 1,
    );
    $json = $j->encode([undef,5,3.14159,'abc',{a=>1},{b=>2}]);
    $self->is($json,Quiq::Unindent->trim(q~
        [
            null,
            5,
            3.14159,
            'abc',{
                a: 1,
            },{
                b: 2,
            },
        ]
    ~));

    # Hash ohne Einrückung

    $j = Quiq::Json0->new(
        indentHashElements => 0,
    );
    $json = $j->encode({a=>1,b=>2});
    $self->is($json,'{a:1,b:2}');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Json0::Test->runTests;

# eof
