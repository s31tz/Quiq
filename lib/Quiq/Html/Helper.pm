package Quiq::Html::Helper;
use base qw/Quiq::Html::Tag/;

use strict;
use warnings;
use v5.10.0;

our $VERSION = '1.154';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Html::Helper - Generierung von einfachen Tag-Konstrukten

=head1 BASE CLASS

L<Quiq::Html::Tag>

=head1 DESCRIPTION

Die Klasse enthält Methoden zum Erzeugen von HTML-Konstrukten, die
einerseits über Einzeltags hinausgehen (die in Quiq::Html::Tag
implementiert sind), die andererseits aber nicht die Komplexität
besitzen, dass hierfür eine eigene Klasse gerechtfertigt wäre.

=head1 VERSION

1.154

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
