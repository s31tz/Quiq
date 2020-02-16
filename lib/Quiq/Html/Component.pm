package Quiq::Html::Component;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.174';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Html::Component - Eigenständige Komponente einer HTML-Seite

=head1 BASE CLASS

L<Quiq::Hash>

=head1 SYNOPSIS

  use Quiq::Html::Component;
  
  $c = Quiq::Html::Component->new(
      name => $name
      resources => \@resources,
      css => $css | \@css,
      html => $html | \@html,
      js => $js | \@js,
      ready => $js | \@js,
  );
  
  $name = $c->name;
  @resources = $c->resources;
  $css | @css = $c->css;
  $html | @html = $c->html;
  $js | @js = $c->js;
  $ready | @ready = $c->ready;

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert eine eigenständige Komponente einer
HTML-Seite bestehend aus HTML-, CSS- und JavaScript-Code. Der Zweck
besteht darin, diese einzelnen Bestandteile zu einer Einheit
zusammenzufassen. Die Bestandteile können über Methoden der Klasse
abgefragt werden, um sie systematisch in die unterschiedlichen Abschnitte
einer HTML-Seite (<head>, <body>, <style>, <script>, $(function() {...}))
einsetzen zu können. Die Resourcen mehrerer Komponenten können
zu einer Liste ohne Dubletten konsolidiert werden.

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $c = $class->new(@keyVal);

=head4 Attributes

=over 4

=item name => $name

Name der Komponente. Unter diesem Namen kann die Komponente aus einem
Bündel von Komponenten ausgewählt werden. Siehe Quiq::Html::Bundle.

=item resources => \@reasources

Liste von Resourcen (CSS- und JavaScript-Dateien), die von der
Komponente benötigt werden. Eine Resource wird durch ihren
URL spezifiziert. Es sollte eine einheitliche Schreibweise über
mehreren Komponenten verwendet werden, damit die Resource-Listen
konsolidiert werden können.

=item css => $css | \@css

Der CSS-Code der Komponente. Besteht der CSS-Code aus mehreren Teilen,
kann das Attribut mehrfach oder eine Array-Referenz angegeben
werden.

=item html => $html | \@html (Default: '')

Der HTML-Code der Komponente. Besteht der HTML-Code aus
mehreren Teilen, kann das Attribut mehrfach oder eine Array-Referenz
angegeben werden.

=item js => $js | \@js

Der JavaScript-Code der Komponente. Besteht der JavaScript-Code aus
mehreren Teilen, kann das Attribut mehrfach oder eine Array-Referenz
angegeben werden.

=item ready => $js | \@js

Der Ready-Handler der Komponente. Gibt es mehrere Ready-Handler
kann das Attribut mehrfach oder eine Array-Referenz angegeben werden.

=back

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @keyVal

    my $self = $class->SUPER::new(
        css => [],
        html => [],
        js => [],
        name => undef,
        ready => [],
        resources => [],
    );
    while (@_) {
        $self->setOrPush(splice @_,0,2);
    }

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 css() - CSS-Code der Komponente

=head4 Synopsis

  $css | @css = $c->css;

=head4 Description

Liefere den CSS-Code der Komponente. Im Arraykontext die Liste der
Array-Elemente, im Skalarkontext deren Konkatenation.

=cut

# -----------------------------------------------------------------------------

sub css {
    my ($self,$h) = @_;
    return $self->attributeValue('css');
}

# -----------------------------------------------------------------------------

=head3 html() - HTML-Code der Komponente

=head4 Synopsis

  $html | @html = $c->html;

=head4 Description

Liefere den HTML-Code der Komponente. Im Arraykontext die Liste der
Array-Elemente, im Skalarkontext deren Konkatenation.

=cut

# -----------------------------------------------------------------------------

sub html {
    my $self = shift;
    return $self->attributeValue('html');
}

# -----------------------------------------------------------------------------

=head3 js() - JavaScript-Code der Komponente

=head4 Synopsis

  $js | @js = $c->js;

=head4 Description

Liefere den JavaScript-Code der Komponente. Im Arraykontext die Liste der
Array-Elemente, im Skalarkontext deren Konkatenation.

=cut

# -----------------------------------------------------------------------------

sub js {
    my $self = shift;
    return $self->attributeValue('js');
}

# -----------------------------------------------------------------------------

=head3 name() - Name der Komponente

=head4 Synopsis

  $name = $c->name;

=head4 Description

Liefere den Namen der Komponente.

=cut

# -----------------------------------------------------------------------------

sub name {
    return shift->{'name'};
}

# -----------------------------------------------------------------------------

=head3 ready() - Ready-Handler der Komponente

=head4 Synopsis

  $ready | @ready = $c->ready;

=head4 Description

Liefere den/die Ready-Handler der Komponente. Im Arraykontext die
Liste der Array-Elemente, im Skalarkontext deren Konkatenation.

=cut

# -----------------------------------------------------------------------------

sub ready {
    my $self = shift;
    return $self->attributeValue('ready');
}

# -----------------------------------------------------------------------------

=head3 resources() - Resourcen der Komponente

=head4 Synopsis

  @resources = $c->resources;

=head4 Description

Liefere die Liste der Resourcen der Komponente.

=cut

# -----------------------------------------------------------------------------

sub resources {
    return @{shift->{'resources'}};
}

# -----------------------------------------------------------------------------

=head2 Private Methoden

=head3 attributeValue() - Liefere Attributwert

=head4 Synopsis

  $str | @arr = $obj->attributeValue($key);

=head4 Description

Liefere den Wert des Attributs $key. Im Arraykontext die Liste der
Array-Elemente, im Skalarkontext deren Konkatenation.

=cut

# -----------------------------------------------------------------------------

sub attributeValue {
    my ($self,$key) = @_;
    my $arr = $self->{$key};
    return wantarray? @$arr: join('',@$arr);
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.174

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
