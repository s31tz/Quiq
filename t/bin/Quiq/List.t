#!/usr/bin/env perl

package Quiq::List::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

use Quiq::Hash;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::List');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(8) {
    my $self = shift;

    my $lst = Quiq::List->new;
    $self->is(ref($lst),'Quiq::List');

    my @objs = $lst->elements;
    $self->isDeeply(\@objs,[]);

    my $n = $lst->count;
    $self->is($n,0);

    my $obj = $lst->push(Quiq::Hash->new(
        id => 1,
        name => 'Birgit',
    ));
    $n = $lst->count;
    $self->is($n,1);
    $self->is(ref($obj),'Quiq::Hash');
    $self->is($obj->id,1);
    $self->is($obj->name,'Birgit');

    @objs = $lst->elements;
    $self->isDeeply(\@objs,[{id=>1,name=>'Birgit'}]);
}

# -----------------------------------------------------------------------------

package main;
Quiq::List::Test->runTests;

# eof
