#!/usr/bin/env perl

package Quiq::Html::HorizontalMenu::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Html::HorizontalMenu');
}

# -----------------------------------------------------------------------------

package main;
Quiq::Html::HorizontalMenu::Test->runTests;

# eof
