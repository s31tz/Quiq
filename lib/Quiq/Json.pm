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

=head1 SYNOPSIS

Klasse laden:

  use Quiq::Json;

JSON-Code erzeugen:

  $j = Quiq::Json->new;
  $json = $j->encode($arg);

=head1 DESCRIPTION

Diese Klasse erzeugt JSON-Code in einem Coding-Style, wie ich ihn
in JavaScript-Quelltexten verwende. Die Übersetzung erfolgt nach
folgenden Regeln:

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

Wird beim Konstruktoraufruf C<< indentHashElements=>0 >> angegeben,
werden die Schlüssel/Wert-Paare nicht eingerückt:

  {KEY1:VALUE1,KEY2:VALUE2,...}

Die Reihenfolge der Schlüssel KEYI ist alphanumerisch. Ein Schlüssel
KEYI wird in einfache Anführungsstriche eingefasst, wenn
er mindestens ein Zeichen enthält, das nicht zum Zeichenvorrat \w
gehört.

=back

=head1 METHODS

=head2 Instantiierung

=head3 new() - Konstruktor

=head4 Synopsis

  $j = $class->new(@attVal);

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

    my $self = $class->SUPER::new(
        indent => 4,
        indentArrayElements => 0,
        indentHashElements => 1,
        indentStr => undef,
    );
    $self->set(@_);
    $self->{'indentStr'} = ' ' x $self->{'indent'};

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 encode() - Erzeuge JSON

=head4 Synopsis

  $json = $j->encode($arg);

=head4 Arguments

=over 4

=item $arg

Wert.

=back

=head4 Returns

JSON-Code (String)

=head4 Description

Wandele Wert $arg nach JSON und liefere den JSON-Code zurück.

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
            $json = $arg;
        }
    }
    elsif ($refType eq 'ARRAY') {
        if ($self->{'indentArrayElements'}) {
            for (my $i = 0; $i < @$arg; $i++) {
                my $code = $self->encode($arg->[$i]);
                if ($json && $code !~ /^[\[{]/) {
                    $json .= "\n";
                }
                $json .= $code.',';
            }
            if ($json) {
                $json =~ s/^/$self->{'indentStr'}/mg;
                $json = "[\n$json\n]";
            }
            else {
                $json = '[]';
            }
        }
        else {
            for (my $i = 0; $i < @$arg; $i++) {
                if ($json) {
                    $json .= ',';
                }
                $json .= $self->encode($arg->[$i]);
            }
            $json = "[$json]";
        }
    }
    elsif ($refType eq 'HASH') {
        if ($self->{'indentHashElements'}) {
            for my $key (sort keys %$arg) {
                if ($json) {
                    $json .= "\n";
                }
                $json .= $key =~ /\W/? "'$key'": $key;
                $json .= ': '.$self->encode($arg->{$key}).',';
            }
            if ($json) {
                $json =~ s/^/$self->{'indentStr'}/mg;
                $json = "{\n$json\n}";
            }
            else {
                $json .= '{}';
            }
        }
        else {
            for my $key (sort keys %$arg) {
                if ($json) {
                    $json .= ',';
                }
                $json .= $key =~ /^\w+$/? $key: "'$key'";
                $json .= ':'.$self->encode($arg->{$key});
            }
            $json = "{$json}";
        }
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
