package Quiq::Tag::Producer;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.165';

use Quiq::Converter;
use Quiq::Unindent;
use Quiq::Template;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Tag::Producer - Erzeuge Markup-Code gemäß XML-Regeln

=head1 BASE CLASS

L<Quiq::Hash>

=head1 SYNOPSIS

=head3 Modul laden und Objekt instantiieren

  use Quiq::Tag::Producer;
  
  my $p = Quiq::Tag::Producer->new;

=head3 Tag ohne Content

  $code = $p->tag('person',
      firstName => 'Lieschen',
      lastName => 'Müller',
  );

liefert

  <person first-name="Lieschen" last-name="Müller" />

Die Attribute C<firstName> und C<lastName> werden von Camel- nach
SnakeCase gewandelt. Dadurch ist kein Quoting im Perlcode nötig.

=head3 Tag mit Content

  $code = $p->tag('bold','sehr schön');

liefert

  <bold>sehr schön</bold>

Enthält der Content, wie hier, keine Zeilenumbrüche, werden Begin-
und End-Tag unmittelbar um den Content gesetzt. Andernfalls wird
der Content eingerückt mehrzeilig zwischen Begin- und End-Tag
gesetzt. Siehe nächstes Beispiel.

=head3 Tag mit Unterstruktur

  $code = $p->tag('person','-',
      $p->tag('first-name','Lieschen'),
      $p->tag('last-name','Müller'),
  );

liefert

  <person>
    <first-name>Lieschen</first-name>
    <last-name>Müller</last-name>
  </person>

Das Bindestrich-Argument (C<'-'>) bewirkt, dass die nachfolgenden
Argumente zum Content des Tag konkateniert werden. Die umständlichere
Formulierung wäre:

  $code = $p->tag('person',$p->cat(
      $p->tag('first-name','Lieschen'),
      $p->tag('last-name','Müller'),
  ));

=head1 DESCRIPTION

Ein Objekt der Klasse erzeugt Markup-Code gemäß den Regeln von XML.
Mittels der beiden Methoden L<tag|"tag() - Erzeuge Tag-Code">() und L<cat|"cat() - Füge Sequenz zusammen">() kann Markup-Code
beliebiger Komplexität erzeugt werden. Element- und Attributbezeichner
können in CamelCase geschrieben werden. Sie werden automatisch in
SnakeCase gewandelt. Dies ist vor allem bei Attribut/Wert-Paaren
nützlich, da der Attributname dann nicht gequotet werden muss.

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

=head3 tag() - Erzeuge Tag-Code

=head4 Synopsis

  $code = $p->tag($elem,@opts,@attrs);
  $code = $p->tag($elem,@opts,@attrs,$content);
  $code = $p->tag($elem,@opts,@attrs,'-',@content);

=head4 Arguments

=over 4

=item $elem

Name des Elements.

=item @opts

Optionen. Siehe unten.

=item @attrs

Element-Attribute und ihre Werte.

=item $content

Inhalt des Tag.

=item @contents

Sequenz von Inhalten.

=back

=head4 Description

Erzeuge den Code eines Tag und liefere diesen zurück.

=cut

# -----------------------------------------------------------------------------

sub tag {
    my $self = shift;
    my $elem = Quiq::Converter->camelCaseToSnakeCase(shift);

    # MEMO: Dies ist eine abgespeckte Variante der Methode tag() in
    # Quiq::Html::Tag. Etwaige Ergänzungen, die hier gebraucht
    # werden, von dort übernehmen.

    my $ind = 2;

    my $code = "<$elem";
    while (@_) {
        if (@_ == 1) {
            # Letztes Argument ist Content. Dieser Test muss als erstes
            # kommen, damit '-' als Content nicht unter den Tisch fällt.
            last;
        }
        elsif (defined $_[0] && $_[0] eq '-') {
            # explizites Ende der Options- und Attributliste
            shift; # '-' konsumieren
            last;
        }

        my $key = Quiq::Converter->camelCaseToSnakeCase(shift);
        my $val = shift;

        if (defined $val) {
            $val =~ s/"/&quot;/g;
            $code .= qq| $key="$val"|;
        }
    }

    # Content bestimmen
    my $content = $self->cat(@_);

    # Content bearbeiten

    $content = Quiq::Unindent->trim($content);
    if ($content =~ /\n/ && $ind) {
        # Mehrzeiligen Content einrücken. Wir berücksichtigen,
        # dass wir enthaltene Leerzeilen nicht einrücken.

        my $space = ' ' x $ind;
        $content =~ s/^(?!$)/$space/gm;
        $content = "\n$content\n";
    }

    # End-Tag

    if ($content ne '') {
        $code .= ">$content</$elem>";
    }
    else {
        $code .= ' />';
    }

    # Newlinw
    $code .= "\n";

    return $code;
}

# -----------------------------------------------------------------------------

=head3 cat() - Füge Sequenz zusammen

=head4 Synopsis

  $code = $p->cat(@opt,@args);

=head4 Arguments

=over 4

=item @args

Sequenz von Werten.

=back

=head4 Options

=over 4

=item -placeholders => \@keyVal (Default: undef)

Ersetze im generierten Code die angegebenen Platzhalter durch
die angegebenen Werte.

=back

=head4 Description

Füge die Arguments @args zusammen und liefere den resultierenden
Code zurück.

=cut

# -----------------------------------------------------------------------------

sub cat {
    my $self = shift;

    # Optionen

    my $placeholderA = undef;

    while (@_) {
        if (!defined $_[0]) {
            last;
        }
        elsif ($_[0] eq '-') {
            # explizites Ende der Optionen
            shift; # '-' konsumieren
            last;
        }
        elsif ($_[0] eq '-placeholders') {
            $placeholderA = splice @_,0,2;
            next;
        }
        last;
    }

    # Argumente konkatenieren

    my $code = join '',@_;

    # Platzhalter ersetzen

    if ($placeholderA) {
        my $tpl = Quiq::Template->new('text',\$code);
        $tpl->replace(@$placeholderA);
        $code = $tpl->asStringNL;
    }

    return $code;
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
