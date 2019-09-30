package Quiq::PostgreSql::Catalog;
use base qw/Quiq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.159';

# -----------------------------------------------------------------------------

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

CREATE FUNCTION Statement, das von pg_get_function_identity_arguments(oid)
geliefert wurde.

=back

=head4 Returns

Umgeschriebenes CREATE FUNCTION Statement (String)

=cut

# -----------------------------------------------------------------------------

sub correctFunctionDef {
    my ($class,$sql) = @_;

    # Enthält die Prozedur lediglich ein SELECT, wird plpgsql als
    # Language-Bezeichnung gesetzt, sie muss aber sql lauten.

    #if ($sql =~ m{\$BODY\$\s*(/\*.*?\*/)?\s*(WITH|SELECT)}si) {
    #    # falsche LANGUAGE-Bezeichnung. Wieso?
    #    $sql =~ s/plpgsql/sql/;
    #}

    # Enthält die Prozedur kein BEGIN, setzen wird sql
    # statt plpgsql als Sprache

    if ($sql !~ /BEGIN/) {
        # LANGUAGE-Bezeichnung korrigieren
        $sql =~ s/plpgsql/sql/;
    }

    # Der von pg_get_functiondef() erzeugte Code enthält gelegentlich
    # den Ausdruck VOLATILESECURITY, dieser muss aber lauten
    # VOLATILE SECURITY, also aus zwei Worten bestehen.
    $sql =~ s/VOLATILESECURITY/VOLATILE SECURITY/i;

    # $sql =~ s/character varying\(-4\)/character varying(4)/ig;

    return $sql;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.159

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
