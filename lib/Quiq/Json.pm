package Quiq::Json;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.167';

use Scalar::Util ();

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Json - Erzeuge JSON-Code

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Die Klasse erzeugt JSON-Code in einem Coding-Style, wie ich ihn
in JavaScript-Quelltexten verwende. Durch die Methode $j->L<object|"object() - Erzeuge Code für JSON-Objekt">()
besteht Kontrolle über die Reihenfolge der Schlüssel/Wert-Paare.
Darüber hinaus werden sie per Default eingerückt dargestellt.

=head1 METHODS

=head2 Instantiierung

=head3 new() - Konstruktor

=head4 Synopsis

  $j = $class->new(@keyVal);

=head4 Attributes

=over 4

=item indent => $n (Default: 4)

Tiefe der Einrückung.

=back

=head4 Returns

Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz
auf dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @keyVal

    my $self = $class->SUPER::new(
        indent => 4,
    );
    $self->set(@_);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 encode() - Wandele Perl-Datenstruktur in JSON-Code

=head4 Synopsis

  $json = $j->encode($scalar);

=head4 Arguments

=over 4

=item $scalar

Skalarer Wert: undef, \0, \1, Number, String, String-Referenz,
Array-Referenz, Hash-Referenz.

=back

=head4 Returns

JSON-Code (String)

=head4 Description

Wandele $scalar nach JSON und liefere den resultierenden Code zurück.
Die Übersetzung erfolgt (rekursiv) nach folgenden Regeln:

=over 4

=item undef

Wird abgebildet auf: C<null>

=item \1

Wird abgebildet auf: C<true>

=item \0

Wird abgebildet auf: C<false>

=item NUMBER

Wird unverändert übernommen:

  NUMBER

=item STRING

Wird abgebildet auf:

  'STRING'

=item STRING_REF

Wird abgebildet auf:

  STRING

Dies ist nützlich, wenn ein Teil der Datenstruktur
abweichend formatiert werden soll.

=item ARRAY_REF

Wird abgebildet auf:

  [ELEMENT1,ELEMENT2,...]

Wird beim Konstruktoraufruf C<< indentArrayElements=>1 >> angegeben,
werden die Elemente eingerückt:

  [
      ELEMENT1,
      ELEMENT2,
      ...,
  ]

=item HASH_REF

Wird abgebildet auf:

  {
      KEY1: VALUE1,
      KEY2: VALUE2,
      ...,
  }

=back

=cut

# -----------------------------------------------------------------------------

sub encode {
    my ($self,$arg) = @_;

    my $json = '';

    my $refType = Scalar::Util::reftype($arg);
    if (!defined $refType) {
        if (!defined $arg) {
            $json = 'null';
        }
        elsif (Scalar::Util::looks_like_number($arg)) {
            $json = $arg;
        }
        else {
            $json = "'$arg'";
        }
    }
    elsif ($refType eq 'SCALAR') {
        if ($$arg eq '1') {
            $json = 'true';
        }
        elsif ($$arg eq '0') {
            $json = 'false';
        }
        else {
            $json = $$arg;
        }
    }
    elsif ($refType eq 'ARRAY') {
        for (my $i = 0; $i < @$arg; $i++) {
            if ($json) {
                $json .= ',';
            }
            $json .= $self->encode($arg->[$i]);
        }
        $json = "[$json]";
    }
    elsif ($refType eq 'HASH') {
        for my $key (sort keys %$arg) {
            if ($json) {
                $json .= ',';
            }
            $json .= $self->key($key);
            $json .= ':'.$self->encode($arg->{$key});
        }
        $json = "{$json}";
    }
    else {
        $self->throw(
            'JSON-00001: Unknown data type',
            Arg => $arg,
            Type => $refType,
        );
    }

    return $json;
}

# -----------------------------------------------------------------------------

=head3 object() - Erzeuge Code für JSON-Objekt

=head4 Synopsis

  $json = $j->object(@opt,@keyVal);

=head4 Arguments

=over 4

=item @keyVal

Liste der Schlüssel/Wert-Paare

=back

=head4 Options

=over 4

=item -indent => $bool (Default: 1)

Rücke die Elemente des Hash ein.

=back

=head4 Returns

JSON-Code (String)

=head4 Description

Erzeuge den Code für ein JSON-Objekt mit den Attribut/Wert-Paaren
@keyVal und liefere diesen zurück.

=cut

# -----------------------------------------------------------------------------

sub object {
    my $self = shift;
    # @_: @keyVal

    # Optionen

    my $indent = 1;

    while (@_) {
        if (substr($_[0],0,1) ne '-') {
            # Implizites Ende der Optionsliste
            last;
        }
        my $opt = shift;
        if ($opt eq '-') {
            # Explizites Ende der Optionsliste
            last;
        }
        elsif ($opt eq '-indent') {
            $indent = shift;
        }
        else {
            $self->throw(
                'JSON-00001: Unknown option',
                Option => $opt,
                Value => shift,
            );
        }
    }

    my $json = '';
    if ($indent) {
        while (@_) {
            if ($json) {
                $json .= "\n";
            }
            $json .= sprintf '%s: %s,',$self->key(shift),$self->encode(shift);
        }
        if ($json) {
            my $indent = ' ' x $self->{'indent'};
            $json =~ s/^/$indent/mg;
            $json = "{\n$json\n}";
        }
        else {
            $json = '{}';
        }
    }
    else {
        while (@_) {
            if ($json) {
                $json .= ',';
            }
            $json .= $self->key(shift).':'.$self->encode(shift);
        }
        $json = "{$json}";
    }

    return wantarray? \$json: $json;
}

# -----------------------------------------------------------------------------

=head2 Hilfsmethoden

=head3 key() - Schlüssel eines JSON-Objekts

=head4 Synopsis

  $str = $j->key($key);

=head4 Arguments

=over 4

=item $key

Schlüssel.

=back

=head4 Returns

String

=head4 Description

Erzeuge den Code für den Schlüssel $key eines JSON-Objekts und
liefere diesen zurück. Enthält der Schlüssel nur Zeichen, die
in einem JavaScript-Bezeichner vorkommen dürfen, wird er unverändert
geliefert, ansonsten wird er in einfache Anführungsstriche eingefasst.

=head4 Example

Schlüssel aus dem Zeichenvorrat eines JavaScript-Bezeichners:

  $str = $j->Quiq::Json('borderWidth');
  ==>
  "borderWidth"

Schlüssel mit Zeichen, die nicht in einem JavaScript-Bezeichner vorkommen:

  $str = $j->Quiq::Json('border-width');
  ==>
  "'border-width'"

=cut

# -----------------------------------------------------------------------------

sub key {
    my ($self,$key) = @_;
    return $key =~ /\W/? "'$key'": $key;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.167

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
