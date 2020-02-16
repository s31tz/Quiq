#!/usr/bin/env perl

package Quiq::Html::Component::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Html::Component');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Html::Component::Test->runTests;

# eof
