#!/usr/bin/env perl

package Quiq::Tag::Producer::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;
use utf8;

use Quiq::Unindent;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Tag::Producer');
}

# -----------------------------------------------------------------------------

sub test_unitTest : Test(5) {
    my $self = shift;

    # Instantiierung

    my $p = Quiq::Tag::Producer->new;
    $self->is(ref $p,'Quiq::Tag::Producer');

    # Generierung

    # 1.

    my $code = $p->tag('person',
        firstName => 'Lieschen',
        lastName => 'Müller',
    );
    $self->is($code,qq|<person first-name="Lieschen" last-name="Müller" />\n|);

    # 2.

    $code = $p->tag('bold','sehr schön');
    $self->is($code,"<bold>sehr schön</bold>\n");

    # 3.

    $code = $p->tag('descr',"Dies ist\nein Test\n");
    $self->is($code,Quiq::Unindent->trimNl(q~
        <descr>
          Dies ist
          ein Test
        </descr>
    ~));

    # 4.

    $code = $p->tag('person','-',
        $p->tag('firstName','Lieschen'),
        $p->tag('lastName','Müller'),
    );
    $self->is($code,Quiq::Unindent->trimNl(q~
        <person>
          <first-name>Lieschen</first-name>
          <last-name>Müller</last-name>
        </person>
    ~));
}

# -----------------------------------------------------------------------------

package main;
Quiq::Tag::Producer::Test->runTests;

# eof
