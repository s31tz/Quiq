#!/usr/bin/env perl

package Quiq::Cascm::Test;
use base qw/Quiq::Test::Class/;

use strict;
use warnings;
use v5.10.0;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Cascm');
}

# -----------------------------------------------------------------------------

sub test_unitTest: Test(0) {
    my $self = shift;
}

# -----------------------------------------------------------------------------

sub test_new: Test(11) {
    my $self = shift;

    my $user = 'xv882js';
    my $password = '*secret*';
    my $credentialsFile = '/home/xv882js/etc/cascm/credentials.dfo';
    my $hsqlCredentialsFile = '/apps/scmclient/ruv/dfo/TU_CheckOut.dfo';
    my $broker = 'cascm';
    my $projectContext = 'S6800_DSS-PG_2014_N';
    my $viewPath = 'S6800_DSS_PG';
    my $workspace = sprintf '%s/var/workspace',Quiq::Process->homeDir;
    my $defaultState = 'Entwicklung';
    my $keepTempFiles = 0;
    my $verbose = 1;

    my $scm = Quiq::Cascm->new(
        user => $user,
        password => $password,
        credentialsFile => $credentialsFile,
        hsqlCredentialsFile => $hsqlCredentialsFile,
        broker => $broker,
        projectContext => $projectContext,
        viewPath => $viewPath,
        workspace => $workspace,
        defaultState => $defaultState,
        keepTempFiles => $keepTempFiles,
        verbose => $verbose,
    );

    $self->is(ref($scm),'Quiq::Cascm');
    $self->is($scm->user,$user);
    $self->is($scm->password,$password);
    $self->is($scm->credentialsFile,$credentialsFile);
    $self->is($scm->hsqlCredentialsFile,$hsqlCredentialsFile);
    $self->is($scm->broker,$broker);
    $self->is($scm->projectContext,$projectContext);
    $self->is($scm->workspace,$workspace);
    $self->is($scm->defaultState,$defaultState);
    $self->is($scm->keepTempFiles,0);
    $self->is($scm->verbose,1);

    $self->set(scm=>$scm);
}

# -----------------------------------------------------------------------------

sub test_credentialsOptions: Test(1) {
    my $self = shift;

    my $scm = $self->get('scm');

    my @arr = $scm->credentialsOptions;
    $self->isDeeply(\@arr,[-eh=>'/home/xv882js/etc/cascm/credentials.dfo']);
}

# -----------------------------------------------------------------------------

package main;
Quiq::Cascm::Test->runTests;

# eof
