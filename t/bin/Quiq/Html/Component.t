#!/usr/bin/env perl

package Quiq::Html::Component::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;

use Quiq::Css;
use Quiq::Html::Tag;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Html::Component');
}

# -----------------------------------------------------------------------------

sub test_unitTest_1 : Test(12) {
    my $self = shift;

    my $c = Quiq::Css->new('flat');
    my $h = Quiq::Html::Tag->new;

    my $cssCode = $c->rule('body',color=>'#40808');
    my $htmlCode = $h->tag('p','Ein Test');
    my $jsCode = 'alert("hallo");';

    # Konstruktor

    my $obj = Quiq::Html::Component->new;
    $self->is(ref($obj),'Quiq::Html::Component');

    $obj = Quiq::Html::Component->new(
        name => 'sql-analysis',
        resources => ['js/jquery.js'],
        css => $cssCode,
        html => $htmlCode,
        js => $jsCode,
        ready => $jsCode,
    );

    # Name

    my $name = $obj->name;
    $self->is($name,'sql-analysis');

    # CSS

    my @css = $obj->css;
    $self->isDeeply(\@css,[$cssCode]);
    my $css = $obj->css;
    $self->is($css,$cssCode);

    # HTML

    my @html = $obj->html;
    $self->isDeeply(\@html,[$htmlCode]);
    my $html = $obj->html;
    $self->is($html,$htmlCode);

    # JavaScript

    my @js = $obj->js;
    $self->isDeeply(\@js,[$jsCode]);
    my $js = $obj->js;
    $self->is($js,$jsCode);

    # Ready-Handler

    my @ready = $obj->ready;
    $self->isDeeply(\@ready,[$jsCode]);
    my $ready = $obj->ready;
    $self->is($ready,$jsCode);

    # Resourcen

    my @resources = $obj->resources;
    $self->isDeeply(\@resources,['js/jquery.js']);
    my $n = $obj->resources;
    $self->is($n,1);
}

# -----------------------------------------------------------------------------

package main;
Quiq::Html::Component::Test->runTests;

# eof
