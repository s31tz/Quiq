package Quiq::Gd::Graphic::BlockDiagram;
use base qw/Quiq::Gd::Graphic/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.165';

use Quiq::Math;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Gd::Graphic::BlockDiagram - Farbige Blöcke in einer Fläche

=head1 BASE CLASS

L<Quiq::Gd::Graphic>

=head1 ATTRIBUTES

Fett hervorgehobene Attribute sind Pflichtangaben beim Konstruktor-Aufruf.

=over 4

=item B<< width => $int >> (Default: keiner)

Breite der Grafik in Pixeln.

=item B<< height => $int >> (Default: keiner)

Höhe der Grafik in Pixeln.

=item xMin => $f (Default: Minimum der X-Werte)

Anfang des X-Wertebereichs (Weltkoodinate).

=item xMax => $f (Default: Maximum der X-Werte)

Ende des X-Wertebereichs (Weltkoodinate).

=item yMin => $f (Default: Minimum der Y-Werte)

Anfang des Y-Wertebereichs (Weltkoodinate).

=item yMax => $f (Default: Maximum der Y-Werte)

Ende des Y-Wertebereichs (Weltkoodinate).

=item objects => \@objects (Default: [])

Liste der Objekte, die die Blockinformation liefern.

=item objectCallback => $sub

Subroutine, die aus einem Objekt die Block-Information liefert.
Signatur:

  sub {
      my $obj = shift;
      ...
      return ($x,$y,$width,$height,$color);
  }

=item blockCallback => $sub

Subroutine, die für jeden gezeichneten Block aufgerufen wird.
Signatur:

  sub {
      my $ = shift;
      ...
      return ($x,$y,$width,$height,$color);
  }

=back

=head1 METHODS

=head2 Konstruktor

=head3 new() - Konstruktor

=head4 Synopsis

  $g = $class->new(@keyVal);

=head4 Description

Instantiiere ein Blockdiagramm-Objekt mit den Eigenschaften @keyVal
(s. Abschnitt L<ATTRIBUTES|"ATTRIBUTES">) und liefere eine Referenz auf das Objekt
zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @keyVal

    my $self = $class->SUPER::new(
        width => undef,
        height => undef,
        xMin => undef,
        xMax => undef,
        yMin => undef,
        yMax => undef,
        objects => [],
        objectCallback => undef,
        blockCallback => undef,
    );
    $self->set(@_);

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

    # Attribute

    my $width = $self->{'width'};
    my $height = $self->{'height'};
    my $xMin = $self->{'xMin'};
    my $xMax = $self->{'xMax'};
    my $yMin = $self->{'yMin'};
    my $yMax = $self->{'yMax'};
    my $objectA = $self->{'objects'};
    my $objectCallback = $self->{'objectCallback'};
    my $blockCallback = $self->{'blockCallback'};

    # Zeichnen
    
    my $m = Quiq::Math->new;

    my $xFactor = $m->valueToPixelFactor($width,$xMin,$xMax);
    my $yFactor = $m->valueToPixelFactor($height,$yMin,$yMax);

    my $black = $img->color('#000000');
    for my $obj (@$objectA) {
        my ($oX,$oY,$oW,$oH,$rgb,$border) = $objectCallback->($obj);
        my $pX = $x+$m->valueToPixelX($width,$xMin,$xMax,$oX);
        my $pY = $y+$m->valueToPixelYTop($height,$yMin,$yMax,$oY);
        # my $pW = $m->roundToInt($oW*$xFactor)-1; # Lücke zwischen den Blöcken
        # my $pH = $m->roundToInt($oH*$yFactor);
        my $pW = $oW*$xFactor-1; # Lücke zwischen den Blöcken
        my $pH = $oH*$yFactor;
        my $color = $img->color($rgb);
        $img->filledRectangle($pX,$pY,$pX+$pW,$pY+$pH,$color);
        if ($border) {
            $img->rectangle($pX,$pY,$pX+$pW,$pY+$pH,$black);
        }
        if ($blockCallback) {
            $blockCallback->($obj,$pX,$pY,$pX+$pW,$pY+$pH);
        }
    }

    return;
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
