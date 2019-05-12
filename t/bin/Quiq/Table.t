#!/usr/bin/env perl

package Quiq::Table::Test;
use base qw/Quiq::Test::Class/;

use strict;
use warnings;
use v5.10.0;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Table');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(10) {
    my $self = shift;

    my @columnsExpected = qw/a b c d/;

    # new()

    my $tab = Quiq::Table->new(\@columnsExpected);
    $self->is(ref($tab),'Quiq::Table');

    # columns()

    my @columns = $tab->columns;
    $self->isDeeply(\@columns,\@columnsExpected);

    my $columnA = $tab->columns;
    $self->isDeeply($columnA,\@columnsExpected);

    # columnIndex()

    my $i = $tab->columnIndex('a');
    $self->is($i,0);

    $i = $tab->columnIndex('d');
    $self->is($i,3);

    eval {$tab->columnIndex('z')};
    $self->ok($@);

    # count()

    my $count = $tab->count;
    $self->is($count,0);

    # rows()

    my @rows = $tab->rows;
    $self->isDeeply(\@rows,[]);

    my $rowA = $tab->rows;
    $self->isDeeply($rowA,[]);

    # width()

    my $width = $tab->width;
    $self->is($width,4);
}

# -----------------------------------------------------------------------------

package main;
Quiq::Table::Test->runTests;

# eof
