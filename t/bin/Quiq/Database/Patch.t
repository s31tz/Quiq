#!/usr/bin/env perl

package Quiq::Database::Patch::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

use Quiq::Database::Connection;
use Quiq::Path;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Database::Patch');
}

# -----------------------------------------------------------------------------

sub test_unitTest: Test(1) {
    my $self = shift;

    my $testDb = "dbi#sqlite:/tmp/test$$.db";
    my $db = Quiq::Database::Connection->new($testDb);

    my $pat = Quiq::Database::Patch->new($db);
    $self->is(ref($pat),'Quiq::Database::Patch');

    Quiq::Path->delete($testDb);
}

# -----------------------------------------------------------------------------

package main;
Quiq::Database::Patch::Test->runTests;

# eof
