# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::PhotoStorage - Foto-Speicher

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert einen Speicher für Fotos. Der Speicher
besitzt folgende Eigenschaften:

=over 2

=item *

Der Name der Foto-Datei bleibt erhalten

=item *

Jedes Foto bekommt eine eindeutige Zahl zugewiesen

=item *

Es wird der SHA1-Hash der Datei gebildet

=item *

Jede Datei wird nur einmal gespeichert, d.h. Dubletten werden
zurückgewiesen

=back

=cut

# -----------------------------------------------------------------------------

package Quiq::PhotoStorage;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.210';

use Quiq::Path;
use Quiq::LockedCounter;
use Quiq::Hash::Db;

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $pst = $class->new($dir);

=head4 Description

Öffne den Fotospeicher in Verzeichnis $dir.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$dir) = @_;

    my $p = Quiq::Path->new;

    if (!$p->exists($dir)) {
        $p->mkdir($dir,-recursive=>1);
        $p->mkdir("$dir/pic");
        
        say "Photo Storage $dir created";
    }
    my $cnt = Quiq::LockedCounter->new("$dir/cnt.txt");
    my $hsh = Quiq::Hash::Db->new("$dir/sha1.hash",'rw');

    return $class->SUPER::new(
        dir => $dir,
        cnt => $cnt,
        hsh => $hsh,
    );
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.210

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2023 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
