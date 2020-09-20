package Quiq::Sql::Composer;
use base qw/Quiq::Dbms/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.187';

use Quiq::Reference;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Sql::Composer - Klasse zum Erzeugen von SQL

=head1 BASE CLASS

L<Quiq::Dbms>

=head1 SYNOPSIS

Instantiierung:

  $s = Quiq::Sql::Composer->new($dbms); # Name des DBMS
  $s = Quiq::Sql::Composer->new($db); # Instanz einer Datenbankverbindung

=head1 METHODS

=head2 Ausdrücke

=head3 expr() - Erzeuge Ausdruck

=head4 Synopsis

  $sql = $s->expr($expr);
  $sql = $s->expr(\$val);

=head4 Arguments

=over 4

=item $expr

Ausdruck, der unverändert geliefert wird.

=item $val

Wert, der in ein SQL String-Literals gewandelt wird.

=back

=head4 Returns

Ausdruck oder String-Literal (String)

=head4 Description

Liefere den Ausdruck $expr oder den in den in ein Stringliteral
gewandelten Wert $val zurück.

=cut

# -----------------------------------------------------------------------------

sub expr {
    my ($self,$expr) = @_;

    my $refType = Quiq::Reference->refType($expr);
    if ($refType eq 'SCALAR') {
        return $self->stringLiteral($$expr);
    }

    return $expr;
}

# -----------------------------------------------------------------------------

=head3 alias() - Ergänze Ausdruck um Alias

=head4 Synopsis

  $sql = $s->alias($expr,$alias);

=head4 Arguments

=over 4

=item $expr

Ausdruck, wie er in einer Select-Liste auftreten kann.

=item $alias

Alias für den Ausdruck

=back

=head4 Returns

Ausdruck mit Alias (String)

=head4 Description

Ergänze den Ausdruck $expr um den Alias $alias in der Form
B<$expr AS $alias> und liefere diese Zeichenkette zurück.

=cut

# -----------------------------------------------------------------------------

sub alias {
    my ($self,$expr,$alias) = @_;

    my $sql = $self->expr($expr);
    $sql .= " AS $alias";

    return $sql;
}

# -----------------------------------------------------------------------------

=head3 valExpr() - Erzeuge Wert-Ausdruck

=head4 Synopsis

  $sql = $s->valExpr($val);
  $sql = $s->valExpr(\$expr);

=head4 Arguments

=over 4

=item $val

Wert, der in ein SQL String-Literals gewandelt wird (siehe Methode
$s->L<stringLiteral|"stringLiteral() - Erzeuge String-Literal">().

=item $expr

Ausdruck, der unverändert geliefert wird.

=back

=head4 Returns

Stringliteral oder Ausdruck (String)

=head4 Description

Liefere den in den in ein Stringliteral gewandelten Wert $val
oder den Ausdruck $expr zurück.

=cut

# -----------------------------------------------------------------------------

sub valExpr {
    my ($self,$expr) = @_;

    my $refType = Quiq::Reference->refType($expr);
    if ($refType eq 'SCALAR') {
        return $$expr;
    }

    return $self->stringLiteral($expr);
}

# -----------------------------------------------------------------------------

=head3 stringLiteral() - Erzeuge String-Literal

=head4 Synopsis

  $sql = $s->stringLiteral($val);
  $sql = $s->stringLiteral($val,$default);

=head4 Arguments

=over 4

=item $val

Wert, der in ein SQL String-Literals gewandelt wird.

=item $default

Defaultwert, der in ein SQL String-Literals gewandelt wird.
Als Defaultwert kann auch ein Ausdruck angegeben werden,
der I<nicht> in ein Stringliteral gewandelt wird, wenn diesem
ein Backslash (\) vorangestellt wird.

=back

=head4 Returns

Stringliteral oder Ausdruck (String)

=head4 Description

Wandele den Wert $val in ein SQL-Stringliteral und liefere
dieses zurück.

Hierbei werden alle in $str enthaltenen einfachen Anführungsstriche
verdoppelt und der gesamte String in einfache Anführungsstriche
eingefasst.

Ist der String leer ('' oder undef) liefere einen Leerstring
(kein leeres String-Literal!). Ist $default angegeben, liefere diesen
Wert als Stringliteral.

B<Anmerkung>: PostgreSQL erlaubt aktuell Escape-Sequenzen in
String-Literalen. Wir behandeln diese nicht. Escape-Sequenzen sollten
in postgresql.conf abgeschaltet werden mit der Setzung:

  standard_conforming_strings = on

=head4 Examples

Eingebettete Anführungsstriche:

  $sel->stringLiteral('Sie hat's');
  ==>
  "'Sie hat''s'"

Leerstring, wenn kein Wert:

  $sel->stringLiteral('');
  ==>
  ""

Defaultwert. wenn kein Wert:

  $sel->stringLiteral('','schwarz');
  ==>
  "'schwarz'"

NULL, wenn kein Wert:

  $sel->stringLiteral('',\'NULL');
  ==>
  "NULL"

=cut

# -----------------------------------------------------------------------------

sub stringLiteral {
    my $self = shift;
    my $str = shift;
    # @_: $default

    if (!defined $str || $str eq '') {
        return @_? $self->valExpr(shift): '';
    }
    if ($self->isMySQL) {
        $str =~ s|\\|\\\\|g;
    }
    $str =~ s/'/''/g;

    return "'$str'";
}

# -----------------------------------------------------------------------------

=head3 case() - Erzeuge CASE-Ausdruck

=head4 Synopsis

  $sql = $s->case($expr,@keyVal,@opt);
  $sql = $s->case($expr,@keyVal,$else,@opt);

=head4 Options

=over 4

=item -fmt => 'm'|'i' (Default: 'm')

Erzeuge einen mehrzeiligen (m=multiline) oder einen
einzeiligen (i=inline) Ausdruck.

=back

=cut

# -----------------------------------------------------------------------------

sub case {
    my $self = shift;
    # @_: @keyVal,@opt -or- @keyVal,$else,@opt

    my $fmt = 'm';

    my $argA = $self->parameters(2,undef,\@_,
        -fmt => \$fmt,
    );

    my $expr = $self->expr(shift @$argA);

    my @else;
    if (@$argA % 2) {
        @else = ($self->valExpr(pop @$argA));
    }

    my $sql = "CASE $expr";
    while (@$argA) {
        my $when = $self->valExpr(shift @$argA);
        my $then = $self->valExpr(shift @$argA);
        
        $sql .= $fmt eq 'm'? "\n    ": ' ';
        $sql .= "WHEN $when THEN $then";
    }
    if (@else) {
        $sql .= $fmt eq 'm'? "\n    ": ' ';
        $sql .= "ELSE $else[0]";
    }
    $sql .= $fmt eq 'm'? "\n": ' ';
    $sql .= 'END';

    return $sql;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.187

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
