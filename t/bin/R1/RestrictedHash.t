#!/usr/bin/env perl

package R1::RestrictedHash::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('R1::RestrictedHash');
}

# -----------------------------------------------------------------------------

#sub test_copy : Test(4) {
#    my $self = shift;

#    my $h1 = R1::RestrictedHash->new(a=>1,b=>2,c=>3);
#    $self->isDeeply($h1,{a=>1,b=>2,c=>3});
#    eval {$h1->set(d=>4)};
#    $self->ok($@);

#    my $h2 = $h1->copy;
#    $self->isDeeply($h2,{a=>1,b=>2,c=>3});
#    eval {$h2->set(d=>4)};
#    $self->ok($@);
#}

# -----------------------------------------------------------------------------

sub test_add : Test(3) {
    my $self = shift;

    my $h = R1::RestrictedHash->new(a=>1,b=>2,c=>3);

    $h->add(d=>5,e=>7);
    $self->is($h->{'d'},5);
    $self->is($h->{'e'},7);

    my $val = eval {$h->{'f'}};
    $self->ok($@);
}

# -----------------------------------------------------------------------------

sub test_rebless : Test(1) {
    my $self = shift;

    my $class = "R1::RestrictedHash::rebless";
    Quiq::Perl->createClass($class,'R1::RestrictedHash');

    my $obj = R1::RestrictedHash->new;

    $obj->rebless($class);
    $self->is(ref($obj),$class);
}

# -----------------------------------------------------------------------------

package main;
R1::RestrictedHash::Test->runTests;

# eof
