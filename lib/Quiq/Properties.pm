package Quiq::Properties;
use base qw/Quiq::Object/;

use strict;
use warnings;
use v5.10.0;

our $VERSION = 1.140;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Properties - Eigenschaften einer Menge von Werten

=head1 BASE CLASS

L<Quiq::Object>

=head1 DESCRIPTION

Ein Objekt der Klasse ist Träger von Information über eine
Menge von Werten. Diese Information ist nützlich, wenn
die Werte tabellarisch dargestellt werden sollen.

=head1 ATTRIBUTES

=over 4

=item type

Typ des Werts: s (Text), f (Float), d (Integer).

=item width

Maximale Länge eines Werts.

=item scale

Maximale Anzahl an Nachkommastellen im Falle eines Float (f).

=item align

Bevorzugte Ausrichtung: l (left), r (right). Im Falle von Float
und Integer r und im Falle von Text per Default l.

=back

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

    $prp = $class->new;

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    #             0     1     2
    return bless [undef,undef,undef],$class;
}

# -----------------------------------------------------------------------------

=head2 Akzessoren

=head3 type() - Typ der Kolumne

=head4 Synopsis

    $type = $fmt->type;

=cut

# -----------------------------------------------------------------------------

sub type {
    return shift->[0];
}

# -----------------------------------------------------------------------------

=head3 scale() - Maximale Anzahl Nachkommastellen

=head4 Synopsis

    $scale = $fmt->scale;

=cut

# -----------------------------------------------------------------------------

sub scale {
    return shift->[2];
}

# -----------------------------------------------------------------------------

=head3 width() - Länge des längsten Werts

=head4 Synopsis

    $width = $fmt->width;

=cut

# -----------------------------------------------------------------------------

sub width {
    return shift->[1];
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 add() - Füge Wert hinzu

=head4 Synopsis

    $fmt->add($value);

=cut

# -----------------------------------------------------------------------------

sub add {
    my ($self,$value) = @_;

    # FIXME: Implementieren

    return;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.140

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
