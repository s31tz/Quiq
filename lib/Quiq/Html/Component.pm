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

Die Ready-Handler der Komponente. Gibt es mehrere Ready-Handler
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
        doctype => 0,
        html => [],
        js => [],
        placeholders => undef,
    );
    while (@_) {
        my $key = shift;
        my $val = shift;

        if ($key =~ /^(css|html|js)$/) {
            my $arr = $self->get($key);
            push @$arr,ref $val? @$val: $val;
        }
        else {
            $self->set($key=>$val);
        }
    }

    return $self;
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
