package Quiq::PostgreSql::Catalog;
use base qw/Quiq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.177';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::PostgreSql::Catalog - PostgreSQL Catalog-Operationen

=head1 BASE CLASS

L<Quiq::Object>

=head1 METHODS

=head2 Klassenmethoden

=head3 correctFunctionDef() - Korrigiere Quelltext einer Funktionsdefinition

=head4 Synopsis

  $newSql = $class->correctFunctionDef($sql);

=head4 Arguments

=over 4

=item $sql

CREATE FUNCTION Statement, das von pg_get_functiondef(oid)
geliefert wurde.

=back

=head4 Returns

Umgeschriebenes CREATE FUNCTION Statement (String)

=head4 Description

PostgreSQL stellt die Funktion pg_get_functiondef(oid) zur Verfügung,
die den Quelltext einer Datenbankfunktion liefert. Leider ist
der Quelltext manchmal fehlerbehaftet, zumindest in der Version 8.3.
Diese Methode korrigiert diese Fehler.

=cut

# -----------------------------------------------------------------------------

sub correctFunctionDef {
    my ($class,$sql) = @_;

    # 1) LANGUAGE korrigieren: Enthält der Quelltext kein BEGIN,
    # setzen wird sql statt plpgsql als Sprache.

    if ($sql !~ /\bBEGIN\b/i) {
        $sql =~ s/plpgsql/sql/;
    }

    # 2) VOLATILESECURITY korrigieren: Der erzeugte Code enthält
    # gelegentlich den Ausdruck Q{VOLATILESECURITY}. Dieser ist syntaktisch
    # falsch, richtig ist Q{VOLATILE SECURITY}.
    
    $sql =~ s/VOLATILESECURITY/VOLATILE SECURITY/i;

    # $sql =~ s/character varying\(-4\)/character varying(4)/ig;

    return $sql;
}

# -----------------------------------------------------------------------------

=head3 functions() - Selektiere Information über Funktionen

=head4 Synopsis

  @rows|$tab = $class->functions($db,@select,@opt);

=head4 Arguments

=over 4

=item $db

Datenbank-Verbindung (PostgreSQL).

=item @select

Alle Optionen von $db->select(), bis auf -from.

=back

=head4 Options

Alle Optinen von $db->select().

=head4 Returns

Liste von Datensätzen. Im Skalarkontext ein Ergebnismengen-Objekt.

=head4 Description

Selektiere Information über eine oder mehrere Funktionen von einer
PostgreSQL-Datenbank. Die Eigenschaften, die geliefert werden und
über die selektiert werden kann, sind

=over 4

=item fun_oid

PostgreSQL-Objekt-Id der Funktion.

=item fun_owner

Name des Owners der Funktion.

=item fun_schema

Name des Schemas, in dem sich die Funktion befindet.

=item fun_name

Name der Funktion.

=item fun_arguments

Argumentliste der Funktion als kommaseparierte Liste der Typ-Namen.

=item fun_signature

Name plus Argumentliste der Funktion in der Form:

  FUNCTION(TYPE,...)

=item fun_source

Der vollständige Quelltext der Funktion. B<ACHTUNG:> Der Quelltext
kann Fehler enthalten. Diese können mit Methode L<correctFunctionDef|"correctFunctionDef() - Korrigiere Quelltext einer Funktionsdefinition">()
korrigiert werden.

=back

=cut

# -----------------------------------------------------------------------------

sub functions {
    my ($class,$db) = splice @_,0,2;
    # @_: @select

    return $db->selectWith(q~
        SELECT
            fun.oid AS fun_oid
            , usr.usename AS fun_owner
            , nsp.nspname AS fun_schema
            , fun.proname AS fun_name
            , pg_get_function_identity_arguments(fun.oid) AS fun_arguments
            , fun.proname || '(' ||
                COALESCE(pg_get_function_identity_arguments(fun.oid), '')
                || ')' AS fun_signature
            , pg_get_functiondef(fun.oid) AS fun_source
        FROM
            pg_proc AS fun
            JOIN pg_namespace AS nsp
                ON fun.pronamespace = nsp.oid
            JOIN pg_user usr
                ON fun.proowner = usr.usesysid
        ~,
        @_,
    );
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.177

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
