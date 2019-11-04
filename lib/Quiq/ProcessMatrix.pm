package Quiq::ProcessMatrix;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.163';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::ProcessMatrix - Matrix von zeitlichen Vorgängen

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Ordne eine Menge von zeitlichen Vorgängen (z.B. gelaufene Prozesse)
in einer Reihe von Zeitschienen (Matrix) an. Finden Vorgänge parallel
(also zeitlich überlappend) statt, hat die Matrix mehr als eine
Zeitschiene.

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

  $mtx = $class->new(\@objects,$sub);

=head4 Arguments

=over 4

=item @objects

Liste von Objekten, die einen Anfangs- und einen End-Zeitpunkt
besitzen.

=item $sub

Subroutine, die den Anfangs- und den Ende-Zeitpunkt des
Objektes in Unix-Epoch liefert.

=back

=head4 Returns

Matrix-Objekt

=head4 Description

Instantiiere ein Matrix-Objekt für die Vorgänge @objects und
liefere eine Referenz auf dieses Objekt zurück.

B<Algorithmus>

=over 4

=item 1.

Wir beginnen mit einer leeren Liste von Zeitschienen.

=item 2.

Die Objekte @objects werden nach Anfangszeitpunkt aufsteigend
sortiert.

=item 3.

Es wird über die Objekte iteriert. Das aktuelle Objekt wird zu der
ersten Zeitschiene hinzugefügt, die frei ist. Eine Zeitschiene
ist frei, wenn sie leer ist oder der Ende-Zeitpunkt des letzten
Elements vor dem Anfangs-Zeitpunkt des aktuellen Objekts liegt.

=back

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$processA,$sub) = @_;

    # Anfangs- und Endezeit in Epoch ermitteln und zu
    # jedem Objekt einen (temporären) Eintrag bestehend
    # aus [$begin,$end,$obj] erzeugen.

    my @arr;
    for my $obj (@$processA) {
        push @arr,[$sub->($obj),$obj];
    }

    # Einträge auf die Zeitschienen verteilen

    my @timelines;
    for my $e (sort {$a->[0] <=> $b->[0]} @arr) {
        for (my $i = 0; $i <= @timelines; $i++) {
            if ($timelines[$i] && $e->[0] < $timelines[$i]->[-1]->[1]) {
                # Zeitschiene ist durch einen anderen Prozess belegt.
                # Wir versuchen es mit der nächsten Zeitschiene.
                next;
            }
            # Freie Zeitschiene gefunden, Eintrag hinzufügen
            push @{$timelines[$i]},$e;
            last;
        }
    }

    # Matrix-Objekt instantiieren

    return $class->SUPER::new(
        timelineA => \@timelines,
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 width() - Breite der Matrix

=head4 Synopsis

  $width = $mtx->width;

=head4 Returns

Integer

=head4 Description

Liefere die Anzahl der Kolumnen der Matrix.

=cut

# -----------------------------------------------------------------------------

sub width {
    return scalar @{shift->{'timelineA'}};
}

# -----------------------------------------------------------------------------

=head3 maxLength() - Maximale Anzahl Einträge in einer Zeitleiste

=head4 Synopsis

  $n = $mtx->maxLength;

=head4 Returns

Integer

=head4 Description

Liefere die maximale Anzahl an Einträgen in einer Zeitschiene.

=cut

# -----------------------------------------------------------------------------

sub maxLength {
    my $self = shift;

    my $maxLength = 0;

    my $width = $self->width;
    my $timelineA = $self->{'timelineA'};

    for (my $i = 0; $i < $width; $i++) {
        my $n = @{$timelineA->[$i]};
        if ($n > $maxLength) {
            $maxLength = $n;
        }
    }

    return $maxLength;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.163

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
