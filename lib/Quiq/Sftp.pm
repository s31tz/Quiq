# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Sftp - SFTP Client-Schnittstelle

=head1 BASE CLASS

L<R1::RestrictedHash>

=head1 SYNOPSIS

  use Quiq::Sftp;
  
  # Weitere Methoden siehe Abschnitt "METHODS"
  
  my $sftp = Quiq::Sftp->new('user:passw@host:port/pub');
  $sftp->put('myfile');
  $sftp->rename('myfile','yourfile');
  $sftp->get('yourfile');
  $sftp->delete('yourfile');
  $sftp->quit;

=cut

# -----------------------------------------------------------------------------

package Quiq::Sftp;
use base qw/R1::RestrictedHash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.202';

use Net::SFTP::Foreign ();
use R1::Misc;
use Quiq::Url;

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Baue SFTP-Verbindung auf

=head4 Synopsis

  $sftp = $class->new($url);

=head4 Description

Baue eine SFTP-Verbindung zu URL $url auf und liefere eine Referenz
auf das instantiierte Objekt zurück.

Der URL hat den Aufbau:

  [ftp://][user[:passw]@]host[:port][[#/]path]

Steht vor path ein /, ist der Pfad absolut, steht vor path ein #,
ist er relativ zum Login-Directory.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    my $url = shift || '';

    my $debug = 0;

    if (@_) {
        R1::Misc->argExtract(\@_,
            -debug=>\$debug,
        );
    }

    $url = "ftp://$url" if substr($url,0,6) ne 'ftp://';
    my (undef,$user,$password,$host,$port,$path,undef,$frag) =
        Quiq::Url->split($url);

    my @opt;
    if ($host) {
        push @opt,host=>$host;
    }
    if ($port) {
        push @opt,port=>$port;
    }
    if ($user) {
        push @opt,user=>$user;
    }
    if ($password) {
        push @opt,password=>$password;
    }
    if ($debug) {
        push @opt,more=>'-v';
    }

    my $sftp = Net::SFTP::Foreign->new(@opt);
    if (my $error = $sftp->error) {
        $class->throw(
            'SFTP-00001: Verbindungsaufbau fehlgeschlagen',
            Error=>$error,
        );
    }

    return $class->SUPER::new(
        sftp=>$sftp,
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 delete() - Lösche Datei auf dem Server

=head4 Synopsis

  $sftp->delete($path);

=head4 Description

Lösche Datei $path auf dem Server. Die Methode liefert keinen Wert
zurück.

=cut

# -----------------------------------------------------------------------------

sub delete {
    my ($self,$path) = @_;

    my $sftp = $self->{'sftp'};
    $sftp->remove($path);
    if (my $error = $sftp->error) {
        $self->throw(
            'SFTP-00004: DELETE fehlgeschlagen',
            Path=>$path,
            Error=>$error,
        );
    }

    return;
}

# -----------------------------------------------------------------------------

=head3 get() - Hole Datei vom Server

=head4 Synopsis

  $local = $sftp->get($remote);
  $local = $sftp->get($remote,$local);

=head4 Description

Kopiere die Datei $remote vom Server auf den lokalen Rechner und lege
sie dort unter dem Pfad/Namen $local ab. Die Methode liefert den
lokalen Namen der Datei zurück.

=cut

# -----------------------------------------------------------------------------

sub get {
    my $self = shift;
    my $remote = shift;
    my $local = shift;

    if (!$local) {
        # als Remote-Namen den Grundnamen der lokalen Datei nehmen
        ($local = $remote) =~ s|.*/||;
    }

    my $sftp = $self->{'sftp'};
    $sftp->get($remote,$local);
    if (my $error = $sftp->error) {
        $self->throw(
            'SFTP-00002: GET fehlgeschlagen',
            Error=>$error,
        );
    }

    return $local;
}

# -----------------------------------------------------------------------------

=head3 ls() - Liste der Dateien auf dem Server

=head4 Synopsis

  @arr|$arr = $sftp->ls;
  @arr|$arr = $sftp->ls($path);

=head4 Description

Liefere die Liste der Dateien für unter Remote-Pfad $path.
Wildcards sind nicht erlaubt. Im Skalarkontext liefere eine
Referenz auf die Liste.

=cut

# -----------------------------------------------------------------------------

sub ls {
    my $self = shift;
    my $path = shift || '*';

    my $sftp = $self->{'sftp'};
    my @arr = $sftp->glob($path,names_only=>1,ordered=>1);
    if (my $error = $sftp->error) {
        $self->throw(
            'SFTP-00003: LS fehlgeschlagen',
            Path=>qq|"$path"|,
            Error=>$error,
        );
    }

    return wantarray? @arr: bless \@arr,'R1::Array';
}

# -----------------------------------------------------------------------------

=head3 put() - Kopiere Datei auf Server

=head4 Synopsis

  $remote = $sftp->put($local);
  $remote = $sftp->put($local,$remote);

=head4 Description

Kopiere die Datei $local auf den Server und lege sie dort unter dem
Pfad/Namen $remote ab. Die Methode liefert den Namen der Datei auf dem
Server zurück.

=cut

# -----------------------------------------------------------------------------

sub put {
    my $self = shift;
    my $local = shift;
    my $remote = shift;

    if (!$remote) {
        # als Remote-Namen den Grundnamen der lokalen Datei nehmen
        ($remote = $local) =~ s|.*/||;
    }

    unless (-r $local) {
        $self->throw(
            'FTP-00005: Kann lokale Datei nicht lesen',
            File=>$local,
        );
    }

    my $sftp = $self->{'sftp'};
    $sftp->put($local,$remote);
    if (my $error = $sftp->error) {
        $self->throw(
            'SFTP-00006: PUT fehlgeschlagen',
            Error=>$error,
        );
    }

    return $remote;
}

# -----------------------------------------------------------------------------

=head3 rename() - Benenne Datei auf dem Server um

=head4 Synopsis

  $sftp->rename($oldName,$newName);

=head4 Description

Benenne eine Datei auf dem Server von $oldName in $newName um.
Die Methode liefert keinen Wert zurück.

=cut

# -----------------------------------------------------------------------------

sub rename {
    my ($self,$oldName,$newName) = @_;

    my $sftp = $self->{'sftp'};
    $sftp->rename($oldName,$newName);
    if (my $error = $sftp->error) {
        $self->throw(
            'FTP-00006: RENAME fehlgeschlagen',
            Error=>$error,
        );
    }

    return;
}

# -----------------------------------------------------------------------------

=head3 mtime() - Liefere mtime von Datei

=head4 Synopsis

  $mtime = $sftp->mtime($path);

=cut

# -----------------------------------------------------------------------------

sub mtime {
    my $self = shift;
    my $path = shift;

    my $sftp = $self->{'sftp'};
    my @arr = $sftp->glob($path);
    if (my $error = $sftp->error) {
        $self->throw(
            'SFTP-00003: GLOB fehlgeschlagen',
            Path=>qq|"$path"|,
            Error=>$error,
        );
    }
    elsif (!@arr) {
        $self->throw(
            'SFTP-00004: Datei existiert nicht',
            Path=>qq|"$path"|,
        );
    }

    return $arr[0]->{'a'}->mtime;
}

# -----------------------------------------------------------------------------

=head3 quit() - Schließe SFTP-Verbindung

=head4 Synopsis

  $sftp->quit;

=head4 Description

Die Methode liefert keinen Wert zurück.

=cut

# -----------------------------------------------------------------------------

sub quit {
    my $self = shift;

    my $sftp = $self->{'sftp'};
    $sftp->disconnect;
    # Keine Fehlerbehandlung

    return;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.202

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
