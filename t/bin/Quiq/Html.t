#!/usr/bin/env perl

package Quiq::Html::Test;
use base qw/Quiq::Test::Class/;

use strict;
use warnings;
use v5.10.0;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Html');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Html::Test->runTests;

# eof
