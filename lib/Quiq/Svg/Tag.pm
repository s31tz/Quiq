package Quiq::Svg::Tag;
use base qw/Quiq::Tag/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.165';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Svg::Tag - Erzeuge SVG Markup-Code

=head1 BASE CLASS

L<Quiq::Tag>

=head1 SYNOPSIS

=head3 Modul laden und Objekt instantiieren

  use Quiq::Svg::Tag;
  
  my $p = Quiq::Svg::Tag->new;

=head3 Dokument erzeugen

  $svg = $p->cat(
      $p->preamble,
      $p->svg(
          width => 80,
          height => 80,
          $p->tag('circle',
              cx => 40,
              cy => 40,
              r => 39,
              style => 'stroke: black; fill: none',
          ),
      ),
  );

erzeugt SVG-Code

  <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
  <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
  
  <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <circle cx="50" cy="50" r="49" style="stroke: black; fill: yellow" />
  </svg>

mit der Darstellung

=begin html

<p class="sdoc-fig-p">
  <img class="sdoc-fig-img" src="https://raw.github.com/s31tz/Quiq/master/img/quiq-svg-tag-01.png" alt="" />
</p>

=end html

=head1 DESCRIPTION

Ein Objekt der Klasse erzeugt SVG Markup-Code beliebiger Komplexität.

=head1 SEE ALSO

=over 2

=item *

L<SVG Element Reference|https://developer.mozilla.org/en-US/docs/Web/SVG/Element>

=back

=head1 METHODS

=head2 Instantiierung

=head3 new() - Konstruktor

=head4 Synopsis

  $p = $class->new;

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

=head3 preamble() - SVG-Vorspann

=head4 Synopsis

  $svg = $p->preamble;

=head4 Returns

String

=head4 Description

Liefere die SVG-Präambel bestehend aus der "XML Processing Instruction"
und der "DOCTYPE Declaration":

  <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
  <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

=cut

# -----------------------------------------------------------------------------

sub preamble {
    my $self = shift;

    return qq|<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n|.
        qq|<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"|.
        qq| "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n\n|;
}

# -----------------------------------------------------------------------------

=head3 svg() - Tag <svg>

=head4 Synopsis

  $svg = $p->svg(@params,$content);

=head4 Returns

SVG-Code (String)

=head4 Description

Erzeuge einen <svg> Tag und liefere diesen zurück.

=cut

# -----------------------------------------------------------------------------

my @SvgDefaults = (
    xmlns => 'http://www.w3.org/2000/svg',
    'xmlns:svg' => 'http://www.w3.org/2000/svg',
    'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
);

sub svg {
    my $self = shift;
    return $self->tag('svg',-defaults=>\@SvgDefaults,@_);
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
