package Quiq::Hash::Persistent;
use base qw/Quiq::Hash/;

use strict;
use warnings;
use v5.10.0;

our $VERSION = '1.155';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Hash::Persistent - Persistente Hash-Datenstruktur

=head1 BASE CLASS

L<Quiq::Hash>

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

    my $h = $class->new($file,$timeout,@args);

=head4 Arguments

=over 4

=item $file

Datei, in der die Datenstruktur persistent gespeichert wird.

=item $timeout

Dauer in Sekunden, die die Cachdatei gültig ist. Falls nicht angegeben
oder C<undef>, ist die Cachdatei unbegrenzt lange gültig.

=item @args

Argumente des Konstrukters der Basisklasse. Dokumentation siehe dort.

=back

=head4 Returns

Referenz auf das Hash-Objekt.

=head4 Description

Instantiiere eine persistente Hash-Datenstruktur und liefere eine
Referenz auf dieses Objekt zurück. Mit der ersten Instantiierung wird die
Datenstruktur in Datei $file gespeichert und diese immer wieder
instantiiert, bis $timeout Sekunden verstrichen sind.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$file,$timeout) = splice @_,0,3;
    # @_: @args

    
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 sync() - Schreibe Cache-Daten auf Platte

=head4 Synopsis

    $h->sync;

=cut

# -----------------------------------------------------------------------------

sub sync {
    my $self = shift;

    my $x = tied %$self || $self->throw(
        'BDB-00002: Kann Tie-Objekt nicht ermitteln',
    );
    if ($x->sync < 0) {
        $self->throw(
            'BDB-00003: Sync ist fehlgeschlagen',
            Errstr => $!,
        );
    }

    return;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.155

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2019 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
