# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Web::Navigation - Webseiten-Navigation

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Die Klasse erstellt eine Seitenhistorie auf Basis des HTTP-Headers
C<Referer:> und speichert diese in einer Navigationsdatenbank.
Dadurch wird eine Navigation zwischen Webseiten möglich,
insbesondere eine Zurücknavigation zu einer zuvor festgelegten
Rückkehrseite.

=head2 Navigationsdatenbank

Die Navigationssdatenbanken werden in einem ausgezeichneten
Verzeichnis DIR gespeichert. In jedem Unterverzeichnis SID befindet
sich die Navigationsdatenbank zu einer Sitzung. DIR und SID
werden beim Konstruktoraufruf angegeben.

  DIR/SID/            Verzeichnis zu einer Sitzung
  DIR/SID/rid         aktuelle Request-Id der Sitzung
  DIR/SID/referer.db  Request-Ids zu URLs der Sitzung
  DIR/SID/call.db     Seitenaufrufe der Sitzung
  DIR/nosession.log   Log der sitzungslosen Zugriffe

Folgende Datenbankdateien werden von der Klasse sitzungsbezogen
geschrieben und gelesen. Alle Dateien werden von der Klasse
automatisch angelegt, wenn sie benötigt werden.

=over 4

=item rid

Datei mit einer einzigen Zeile, die die aktuelle Request-Id
enthält. Die Datei stellt den Request-Zähler für die Sitzung
dar. Die Zählung beginnt mit 1. Ferner findet über dieser
Datei die Synchronisation von parallel verlaufenden Schreib-
und Leseoperationen statt. Sie wird vor Schreiboperationen auf
einer oder mehreren Datenbankdateien mit einem Exklusiv-Lock
belegt und bei Leseoperationen mit einem Shared-Lock.

=item referer.db

Hash-Datei, die Request-Ids zu Referer-URLs speichert. Über diese
Zuordnung stellt die Klasse ohne weitere Information von außen die
Aufrufreihenfolge her. Schlüssel der Datei ist der URL des Aufrufs.

  referer | rid
  
  referer : Referer-URL des Aufrufs
  -------
  rid     : Request-Id des jüngsten Aufrufs mit dem
            betreffenden URL

=item call.db

Hash-Datei, in der die Aufrufe protokolliert werden. Schlüssel
ist die Request-Id des Aufrufs.

  rid | rrid \0 brid \0 args \0 post
  
  rid     : Request-Id des aktuellen Aufrufs
  -------
  args    : CGI-Parameter des Aufrufs in Querystring-Kodierung
  post    : CGI-Parameter, die die Seite gepostet hat (wird von
            der Folgeseite gesetzt)
  rrid    : Request-Id der rufenden Seite
  brid    : Request-Id der Rückkehrseite

=back

=cut

# -----------------------------------------------------------------------------

package Quiq::Web::Navigation;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.198';

use Quiq::Path;
use Quiq::LockedCounter;
use Quiq::Hash::Db;
use POSIX ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Navigationsobjekt

=head4 Synopsis

  $nav = $class->new($dir,$sid,$obj);

=head4 Arguments

=over 4

=item $dir

Verzeichnis, in dem die Daten zur Session-Id $sid gespeichert werden.

=item $sid

Id für der Session.

=item $obj

Objekt mit Informationen zum aktuellen Aufruf. Im Falle von Mojolicious
übergeben wir das Controller-Objekt.

=back

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$dir,$sid,$obj) = @_;

    # Allgemeine Objekte
    my $p = Quiq::Path->new;

    # Request-Information, die wir im Zuge der folgenden
    # Verarbeitung benötigen. FIXME: In einem speziellen Request-Objekt
    # Kapseln

    my $time = POSIX::strftime '%Y-%m-%d %H:%M:%S',localtime;
    my $absUrl = $obj->req->url->to_abs;
    my $url = $obj->req->url;
    my $referer = $obj->req->headers->referer;
    my $browser = $obj->req->headers->user_agent;
    my $remoteAddr = $obj->tx->original_remote_address;
    my $rrid = $obj->param('rrid');

    # Allgemeines Navigations-Verzeichnis erzeugen
    $p->mkdir($dir);

    # Aufrufe ohne Session-Id speichern wir in einer speziellen Datei.
    # Bei diesen Aufrufen ohne $sid ist keine Navigation möglich.

    if (!$sid) {
        $p->write("$dir/no-session.log","$time|$remoteAddr|$browser|$absUrl\n",
            -append => 1,
            -lock => 1,
        );
        return;
    }

    # Navigationsdatenbank für Session aufbauen

    my $sidDir = "$dir/$sid";
    $p->mkdir($sidDir);

    # Die Dateien im Navigationsverzeichnis der Session

    my $ridFile = "$sidDir/rid";
    my $refererDb = "$sidDir/referer.db";
    my $callDb = "$sidDir/call.db";

    # Wir ermitteln die Request-Id der aktuellen Seite

    my $cnt = Quiq::LockedCounter->new($ridFile)->increment;
    my $rid = $cnt->count;

    my $refererH = Quiq::Hash::Db->new($refererDb,'rw');

    # Wir ermitteln die Request-Id der Vorgängerseite. Von dort übernehmen
    # die Request-Id der Rückkehr-Seite.
    $rrid ||= $referer && $refererH->{$referer} || '';

    # Wir speichern die Request-Id des aktuellen Seitenaufrufs
    $refererH->{$absUrl} = $rid;

    $refererH->sync;
    $refererH->close;

    # Wir schreiben einen neuen Eintrag in die Call-DB, wobei wir
    # die Request-Id der Rückkehr-Seite übernehmen
    
    my $brid = '';
    my $callH = Quiq::Hash::Db->new($callDb,'rw');
    if ($rrid) {
        my $data = $callH->{$rrid} // $class->throw;
        # $args,$post,$rrid,$brid
        (undef,undef,undef,$brid) = split /\0/,$data,4;
    }
    $callH->{$rid} = "$url\0\0$rrid\0$brid";

    $callH->sync;
    $callH->close;

    return;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.198

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2022 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
