#!/usr/bin/env perl

package Quiq::Html::Helper::Test;
use base qw/Quiq::Test::Class/;

use strict;
use warnings;
use v5.10.0;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Html::Helper');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Html::Helper::Test->runTests;

# eof
