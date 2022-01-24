# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Web::Navigation - Navigation zwischen Webseiten

=head1 BASE CLASS

L<Quiq::Hash>

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

=head3 new() - Instantiiere Navigationsobjekt einer Seite

=head4 Synopsis

  $nav = $class->new($dir,$sid,$obj);

=head4 Arguments

=over 4

=item $dir

Verzeichnis, in dem die Daten zur Session-Id $sid gespeichert werden.

=item $sid

Id für die Session des Nutzers.

=item $obj

Objekt mit Informationen über den Aufruf. Im Falle von Mojolicious
übergeben wir das Controller-Objekt.

=back

=head4 Description

Instatiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$dir,$sid,$obj) = @_;

    my $time = POSIX::strftime '%Y-%m-%d %H:%M:%S',localtime;
    my $url = $obj->req->url->to_abs;
    my $referer = $obj->req->headers->referer;
    if (!defined $referer) {
       warn "REFERER UNDEFINED: $url\n";
    }
    my $browser = $obj->req->headers->user_agent;
    my $remoteAddr = $obj->tx->original_remote_address;
    my $rrid = $obj->param('rrid');

    my $p = Quiq::Path->new;

    $p->mkdir($dir);

    if (!$sid) {
        $p->write("$dir/no-session.log","$time|$remoteAddr|$browser|$url\n",
            -append => 1,
            -lock => 1,
        );
        return;
    }

    my $sidDir = "$dir/$sid";
    $p->mkdir($sidDir);

    my $ridFile = "$sidDir/rid";
    my $refererDb = "$sidDir/referer.db";

    my $cnt = Quiq::LockedCounter->new($ridFile)->increment;
    my $rid = $cnt->count;

    my $refererH = Quiq::Hash::Db->new($refererDb,'rw');
    $rrid ||= $referer && $refererH->{$referer} || '';
    $refererH->{$url} = $rid;

    warn "---\n";
    for my $key (keys %$refererH) {
        warn "$key $refererH->{$key}\n";
    }

    $refererH->sync;
    $refererH->close;

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
