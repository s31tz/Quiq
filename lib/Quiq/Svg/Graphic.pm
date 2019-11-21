package Quiq::Svg::Graphic;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.165';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Svg::Graphic - Erzeuge SVG-Grafik

=head1 BASE CLASS

L<Quiq::Hash>

=head1 SYNOPSIS

  use Quiq::Svg::Graphic;
  
  $g = Quiq::Svg::Graphic->new;
  
  $svg = $g->svg;

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert eine SVG-Grafik.

=head1 METHODS

=head2 Instantiierung

=head3 new() - Konstruktor

=head4 Synopsis

  $g = $class->new;

=head4 Returns

Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz
auf dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    return $class->SUPER::new;
}

# -----------------------------------------------------------------------------

=head2 Generierung

=head3 svg() - Generiere SVG Code

=head4 Synopsis

  $svg = $g->svg;

=head4 Description

Erzeuge den SVG-Code des Objektes und liefere diesen zurück.

=cut

# -----------------------------------------------------------------------------

sub svg {
    my $this = shift;

    my $svg = '';

    return $svg;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.165

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
