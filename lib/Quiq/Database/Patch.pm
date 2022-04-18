# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Database::Patch - Definiere Datenbankpatches und wende sie an (Basisklasse)

=head1 BASE CLASS

L<Quiq::Hash>

=cut

# -----------------------------------------------------------------------------

package Quiq::Database::Patch;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.202';

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $pat = $class->new($db);

=head4 Arguments

=over 4

=item $db

(Object) Datenbankverbindung

=back

=head4 Returns

Patch-Object

=head4 Description

Instantiiere eine Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$db) = @_;

    return $class->SUPER::new(
        db => $db,
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 apply() - Wende Patch(es) an

=head4 Synopsis

  $pat->apply($level);

=head4 Arguments

=over 4

=item $level

(Integer) Patchlevel

=back

=head4 Description

Wende alle Patches an, bis Patchlevel $level erreicht ist.

=cut

# -----------------------------------------------------------------------------

sub apply {
    my ($self,$level) = @_;

    return;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.202

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2022 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
