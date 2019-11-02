package Quiq::Gd::Graphic::BlockDiagram;
use base qw/Quiq::Gd::Graphic::Graph/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.163';

use POSIX ();

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Gd::Graphic::BlockDiagram - Farbige Blöcke in einer Fläche

=head1 BASE CLASS

L<Quiq::Gd::Graphic::Graph>

=head1 METHODS

=head2 Konstruktor

=head3 new() - Konstruktor

=head4 Synopsis

  $g = $class->new(@keyVal);

=head4 Description

Instantiiere ein Blockdiagramm-Objekt mit den Eigenschaften @keyVal
(s. Abschnitt [ANCHOR NOT FOUND]) und liefere eine Referenz auf das Objekt
zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @keyVal

    my $self = $class->SUPER::new(@_);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Zeichnen

=head3 render() - Zeichne Grafik

=head4 Synopsis

  $g->render($img);
  $g->render($img,$x,$y,@keyVal);
  $class->render($img,$x,$y,@keyVal);

=head4 Description

Zeichne die Grafik in Bild $img an Position ($x,$y).

=cut

# -----------------------------------------------------------------------------

sub render {
    my $this = shift;
    my $img = shift;
    my $x = shift || 0;
    my $y = shift || 0;
    # @_: @keyVal

    my $self = $this->self(@_);

    # Zeichnen (übernimmt die Basisklasse)

    $self->SUPER::render($img,$x,$y,
    );

    return;
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
