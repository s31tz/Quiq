#!/usr/bin/env perl

package Quiq::Sftp::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;
use utf8;

use Test::More;
use Quiq::Config;
use Quiq::Path;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('Quiq::Sftp');
}

# -----------------------------------------------------------------------------

sub test_unitTest: Test(14) {
    my $self = shift;

    my $conf = Quiq::Config->new('./Blob/conf/test-ftp.conf');
    my $sftpUrl = $conf->get('SftpUrl');
    unless ($sftpUrl) {
        $self->skipAllTests('In test.conf kein SftpUrl definiert');
        return;
    }

    # diag $sftpUrl;

    my $sftp = eval { Quiq::Sftp->new($sftpUrl,-debug=>0) };
    if ($@) {
         $self->skipAllTests($@);
         return;
    }
    is ref($sftp),'Quiq::Sftp','new';

    my $local = "/tmp/test_unitTest$$.dat";
    my ($base) = $local =~ m|([^/]+)$|;
    my $rename = "test_unitTest$$.xyz";

    # Lokale Testdatei erzeugen

    Quiq::Path->write($local,"Testdatei\n");

    # put()

    my $remote = $sftp->put($local);
    is $remote,$base,'put: Dateiname';

    # mtime()

    my $mtime = $sftp->mtime($base);
    ok $mtime > 0,'mtime';

    # get()

    $local = $sftp->get($base);
    is $local,$base,'get: Dateiname';
    ok -e $local,'get: Datei existiert';
    Quiq::Path->delete($local);

    # rename()

    eval { $sftp->rename($base,$rename) };
    ok !$@,'rename: Umbenennung durchgeführt';

    eval { $sftp->get($base) };
    ok $@,'get: ursprüngliche Datei kann nicht geholt werden';

    # ls()

    my $arr = $sftp->ls;
    ok @$arr,'ls: alle Dateien';

    # Memo: Wildcards sind bei Net::SFTP::Foreign nicht erlaubt

    $arr = $sftp->ls("*");
    ok @$arr,'ls: mit wildcard';

    $arr = $sftp->ls("*$$.xyz");
    is @$arr,1,'ls: mit wildcard';

    $arr = $sftp->ls('foo.*.*.*.bar');
    is @$arr,0,'ls: leere Liste';

    # delete()

    eval { $sftp->delete($rename) };
    ok !$@,'delete: Datei gelöscht';

    eval { $sftp->get($rename) };
    ok $@,'get: gelöschte Datei kann nicht mehr geholt werden';

    # quit()

    eval { $sftp->quit; };
    ok !$@,'quit: Verbindung getrennt';

    # Lokale Testdatei löschen
    Quiq::Path->delete($local);
}

# -----------------------------------------------------------------------------

package main;
Quiq::Sftp::Test->runTests;

# eof
