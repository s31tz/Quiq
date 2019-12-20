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
        parameter => undef,
        shape => 'spline',
        title => undef,
        x => [],
        xTickFormat => '%Y-%m-%d %H:%M:%S',
        y => [],
        yMin => undef,
        yMax => undef,
        yTitle => undef,
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

    my ($name,$parameter,$shape,$title,$xA,$xTickFormat,$yA,$yMin,$yMax,
        $yTitle) = $self->get(qw/name parameter shape title x xTickFormat
        y yMin yMax yTitle/);

    # Erzeuge JSON-Code

    my $j = Quiq::Json->new;

    # Traces

    push my @traces,$j->o(
        type => 'scatter',
        mode => 'lines',
        # name => $parameter,
        fill => 'tonexty',
        fillcolor => 'rgb(230,230,230,0.1)',
        line => $j->o(
            width => 1,
            color => 'rgb(255,0,0,1)',
            shape => $shape,
        ),
        x => $xA,
        y => $yA,
    );
    if (!@$xA) {
        $yMin = 0;
        $yMax = 1;
    }

    # Layout

    my $layout = $j->o(
        title => $title,
        spikedistance => -1,
        margin => $j->o(
            l => 90,
            r => 90,
            t => 60,
            b => 10,
        ),
        xaxis => $j->o(
            type => 'date',
            autorange => \'true',
            gridcolor => 'rgb(232,232,232,1)',
            tickformat => $xTickFormat,
            tickangle => 30,
            ticklen => 4,
            tickcolor => 'rgb(64,64,64,1)',
            showspikes => \'true',
            spikethickness => 1,
            spikesnap => 'data',
            spikecolor => 'rgb(0,0,0,1)',
            spikedash => 'dot',
            rangeslider => $j->o(
                autorange => \'true',
            ),
        ),
        yaxis => $j->o(
            type => 'linear',
            defined($yMin) && defined($yMax)? (range => [$yMin,$yMax]):
                (autorange => \'true'),
            ticklen => 4,
            tickcolor => 'rgb(64,64,64,1)',
            gridcolor => 'rgb(232,232,232,1)',
            showspikes => \'true',
            spikethickness => 1,
            spikesnap => 'data',
            spikecolor => 'rgb(0,0,0,1)',
            spikedash => 'dot',
            title => $j->o(
                text => $yTitle,
            ),
        ),
    );

    # Extra

    my $extra = $j->o(
        displayModeBar => \'false',
        responsive => \'true',
    );

    # Erzeuge JavaScript-Code

    return Quiq::Template->combine(
        placeholders => [
            __NAME__ => $name,
            __TRACES__ => \@traces,
            __LAYOUT__ => $layout,
            __EXTRA__ => $extra,
        ],
        template => q~
            Plotly.newPlot('__NAME__',[__TRACES__],__LAYOUT__,__EXTRA__);
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
