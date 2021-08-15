#!/usr/bin/env perl

package Quiq::Dumper::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Dumper');
}

# -----------------------------------------------------------------------------

sub test_dump : Test(3) {
    my $self = shift;

    eval {Quiq::Dumper->dump('')};
    $self->like($@,qr/Argument must be a reference/);

    my $ref;

    my $str = Quiq::Dumper->dump(\undef);
    $self->is($str,'\undef');

    $str = Quiq::Dumper->dump(\'abc');
    $self->is($str,'\"abc"');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Dumper::Test->runTests;

# eof
