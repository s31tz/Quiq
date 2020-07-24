package Quiq::PlotlyJs::Parameter;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.186';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::PlotlyJs::Parameter - Eine zu plottender Parameter

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Ein Objekt der Klasse speichert Information über einen Parameter,
der von der Klasse B<< Quiq::PlotlyJs::DiagramGroup >> in ein
Diagramm geplottet werden soll.

Die zu plottenden Daten können entweder über die Komponenten B<x>,
B<y> (und ggf. B<z>) übergeben werden oder sie werden per
Ajax-Aufruf geholt, wenn das Attribut url gesetzt ist.

Es ist sinnvoll, die Wertebereiche B<xMin>, B<xMax>, B<yMin>, B<yMax>
explizit vorzugeben. Dies ist nicht zwingend erforderlich,
Plotly.js setzt die Wertebereiche auch selbständig, dann aber nach
eigenen Kriterien. Ist kein Y-Wertebereich vorgegeben, wird dann bei
B<fill: 'tozeroy'> die Y-Achse bis 0 ausgedeht, auch wenn alle
Y-Werte > 0 sind.

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $par = $class->new(@attVal);

=head4 Attributes

Pflichtangaben sind B<fett> wiedergegeben. Die zu plottenden Daten
werden entweder per B<x>, B<y> (und ggf. B<z>) übergeben oder via
B<url> abgerufen.

=over 4

=item B<< color => $color >>

Farbe, in der die Zeitreihe dargestellt wird. Alle Schreibweisen,
die in CSS erlaubt sind, sind zulässig, also NAME, #XXXXXX
oder rgb(NNN,NNN,NNN,NNN).

=item B<< name => $name >>

Name des Parameters.

=item B<< unit => $unit >>

Einheit der Parameterwerte.

=item x => \@x

Referenz auf Array der Zeit-Werte in JavaScript-Epoch.

=item xMin => $val

Kleinster Zeitwert der Zeitreihe.

=item xMax => $val

Größter Zeitwert der Zeitreihe.

=item y => \@y

Referenz auf Array der Y-Werte (Weltkoordinaten).

=item yMin => $val

Kleinster Parameterwert der Zeitreihe.

=item xMax => $val

Größter Parameterwert der Zeitreihe.

=item url => $url

URL des Ajax-Requests, mit die Zeitreihendaten (Zeitpunkt, Wert)
abgerufen werden.

=item z => \@z

Referenz auf Array von Z-Werten, die als CSS Markerfarben
interpretiert werden.

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
        color => '#ff0000',
        name => 'plot',
        x => [],
        xMin => undef,
        xMax => undef,
        y => [],
        yMin => undef,
        yMax => undef,
        unit => undef,
        url => '',
        z => [],
    );
    $self->set(@_);

    return $self;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.186

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2020 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof