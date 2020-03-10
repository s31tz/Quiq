package Quiq::PostgreSql::Catalog;
use base qw/Quiq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.178';

use Quiq::Unindent;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::PostgreSql::Catalog - PostgreSQL Catalog-Operationen

=head1 BASE CLASS

L<Quiq::Object>

=head1 METHODS

=head2 Datenbank-Anfragen

=head3 grepFunction() - Durchsuche Funktions-Quelltexte

=head4 Synopsis

  @rows | $tab = $class->grepFunction($db,$regex);

=head4 Arguments

=over 4

=item $regex

Regulärer Ausdruck, mit dem gesucht wird.

=back

=head4 Returns

Liste der Funktions-Datensätze. Im Skalarkontext ein ResultSet-Objekt.

=head4 Description

Durchsuche die Quelltexte der Datenbank-Funktionen nach Muster $regex.

=cut

# -----------------------------------------------------------------------------

sub grepFunction {
    my ($class,$db,$regex) = @_;

    return $db->select(
        -with,$class->functionSelect,
        -where =>
            "fnc_schema NOT IN ('public', 'information_schema',".
                " 'pg_catalog')",
            "fnc_source ~ '$regex'",
        -orderBy => 'fnc_schema', 'fnc_name',
    );
}

# -----------------------------------------------------------------------------

=head2 Hilfsmethoden

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

=head2 SQL-Statements

=head3 functionSelect() - Statement: Selektiere Funktionen

=head4 Synopsis

  $stmt = $class->functionSelect;

=head4 Returns

SQL-Statement (String)

=head4 Description

Liefere ein SELECT-Statement, das Informationen über Funktionen
abfragt. Folgende Information wird geliefert:

=over 4

=item fnc_oid

PostgreSQL-Objekt-Id der Funktion.

=item fnc_owner

Name des Owners der Funktion.

=item fnc_schema

Name des Schemas, in dem sich die Funktion befindet.

=item fnc_name

Name der Funktion.

=item fnc_arguments

Argumentliste der Funktion als kommaseparierte Liste der Typ-Namen.

=item fnc_signature

Name plus Argumentliste der Funktion in der Form:

  FUNCTION(TYPE,...)

=item fnc_source

Der vollständige Quelltext der Funktion. B<ACHTUNG:> Der Quelltext
kann (zumindest bei PostgreSQL 8.3) Fehler enthalten, siehe Methode
L<correctFunctionDef|"correctFunctionDef() - Korrigiere Quelltext einer Funktionsdefinition">(), die ggf. auf die Werte der Kolumne
angewendet werden sollte.

=back

Wird das Statement in eine WITH- oder FROM-Klausel Klausel eingebettet,
können auch die Suchkriterien über obige Kolumnennamen formuliert werden:

  $tab = $db->selectWith(
      Quiq::PostgreSql::Catalog->functionSelect,
      -select => 'fnc_source',
      -where, fnc_name = 'rv_copy_to',
          fnc_arguments = 'text, text, text',
  );

=head4 Details

Das gelieferte SELECT-Statement:

  SELECT
      fnc.oid AS fnc_oid
      , usr.usename AS fnc_owner
      , nsp.nspname AS fnc_schema
      , fnc.proname AS fnc_name
      , pg_get_function_identity_arguments(fnc.oid) AS fnc_arguments
      , fnc.proname || '(' ||
          COALESCE(pg_get_function_identity_arguments(fnc.oid), '')
          || ')' AS fnc_signature
      , pg_get_functiondef(fnc.oid) AS fnc_source
  FROM
      pg_proc AS fnc
      JOIN pg_namespace AS nsp
          ON fnc.pronamespace = nsp.oid
      JOIN pg_user usr
          ON fnc.proowner = usr.usesysid

=cut

# -----------------------------------------------------------------------------

sub functionSelect {
    my $class = shift;

    return Quiq::Unindent->trim(q~
    SELECT
        fnc.oid AS fnc_oid
        , usr.usename AS fnc_owner
        , nsp.nspname AS fnc_schema
        , fnc.proname AS fnc_name
        , pg_get_function_identity_arguments(fnc.oid) AS fnc_arguments
        , fnc.proname || '(' ||
            COALESCE(pg_get_function_identity_arguments(fnc.oid), '')
            || ')' AS fnc_signature
        , pg_get_functiondef(fnc.oid) AS fnc_source
    FROM
        pg_proc AS fnc
        JOIN pg_namespace AS nsp
            ON fnc.pronamespace = nsp.oid
        JOIN pg_user usr
            ON fnc.proowner = usr.usesysid
    ~);
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.178

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
