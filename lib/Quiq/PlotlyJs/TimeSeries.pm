package Quiq::PlotlyJs::TimeSeries;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.168';

use Quiq::Json;
use Quiq::Template;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::PlotlyJs::TimeSeries - Erzeuge Zeitreihen-Plot auf Basis von Plotly.js

=head1 BASE CLASS

L<Quiq::Hash>

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $plt = $class->new(@attVal);

=head4 Attributes

=over 4

=item name => $name (Default: 'plot')

Name des Plot. Der Name wird als CSS-Id für den Div-Container
und als Variablenname für die JavaScript-Instanz verwendet.

=back

=head4 Returns

Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @attVal

    my $self = $class->SUPER::new(
        name => 'plot',
    );
    $self->set(@_);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Klassenmethoden

=head3 cdnUrl() - Liefere CDN URL

=head4 Synopsis

  $url = $ch->cdnUrl($version);

=head4 Returns

URL (String)

=head4 Description

Liefere einen CDN URL für Plotly.js.

=cut

# -----------------------------------------------------------------------------

sub cdnUrl {
    my ($this,$version) = @_;

    return 'https://cdn.plot.ly/plotly-latest.min.js';
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 html() - Generiere HTML

=head4 Synopsis

  $html = $ch->html($h);

=head4 Returns

HTML-Code (String)

=head4 Description

Liefere den HTML-Code der Plot-Instanz.

=cut

# -----------------------------------------------------------------------------

sub html {
    my ($self,$h) = @_;

    # Objektattribute
    my $name = $self->get('name');

    return $h->tag('div',
        id => $name,
    );
}

# -----------------------------------------------------------------------------

=head3 js() - Generiere JavaScript

=head4 Synopsis

  $js = $ch->js;

=head4 Returns

JavaScript-Code (String)

=head4 Description

Liefere den JavaScript-Code für die Erzeugung Plot-Instanz.

=cut

# -----------------------------------------------------------------------------

sub js {
    my $self = shift;

    # Objektattribute

    my ($name) = $self->get(qw/name/);

    # Erzeuge JSON-Code

    my $j = Quiq::Json->new;

    my @traces;
    my $layout = $j->o;

    # Erzeuge JavaScript-Code

    return Quiq::Template->combine(
        placeholders => [
            __NAME__ => $name,
            __TRACES__ => \@traces,
            __LAYOUT__ => $layout,
        ],
        template => q~
            var __NAME__ = Plotly.newPlot('__NAME__',[__TRACES__],__LAYOUT__);
        ~,
    );
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.168

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
