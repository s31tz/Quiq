# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Zugferd::Tree - Operatonen auf ZUGFeRD-Baum

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Ein ZUGFeRD-Baum ist die Repräsentation von ZUGFeRD-XML in Form einer
Perl-Datenstruktur. Diese Repräsentation wird genutzt, um die XML-Struktur
geeignet bearbeiten zu können.

=cut

# -----------------------------------------------------------------------------

package Quiq::Zugferd::Tree;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.223';

use Quiq::Tree;

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

  $ztr = $class->new($ref);

=head4 Description

Instantiiere einen ZUGFeRD-Baum und liefere eine Referenz auf dieses
Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$ref) = @_;
    return bless $ref,$class;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 reduce() - Reduziere den Baum

=head4 Synopsis

  $ztr->reduce;

=head4 Description

Reduziere den ZUGFeRD-Baum auf ein Minumum, d.h.

=over 2

=item *

Entferne alle Knoten mit unersetzten Platzhaltern

=item *

Entferne alle leeren Knoten

=back

=cut

# -----------------------------------------------------------------------------

sub reduce {
    my $self = shift;

    # Entferne Knoten mit unersetzten Platzhaltern

    Quiq::Tree->setLeafValue($self,sub {
        my $val = shift;
        if (defined $val && $val =~ /^__\w+__$/) {
            $val = undef;
        }
        return $val;
    });

    # Entferne alle leere Knoten
    Quiq::Tree->removeEmptyNodes($self);

    return;
}

# -----------------------------------------------------------------------------

=head3 substitutePlaceholders() - Ersetze Platzhalter

=head4 Synopsis

  $ztr->substitutePlaceholders(@keyVal);

=head4 Arguments

=over 4

=item @keyVal

Liste der Platzhalter und ihrer Werte

=back

=head4 Description

Durchlaufe den ZUGFeRD-Baum rekursiv und ersetze auf den Blattknoten
die Platzhalter durch ihre Werte.

=cut

# -----------------------------------------------------------------------------

sub substitutePlaceholders {
    my $self = shift;
    # @_: @keyVal

    my %map = @_;
    Quiq::Tree->setLeafValue($self,sub {
        my $val = shift;
        return defined $val? $map{$val} // $val: undef;
    });

    return;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.223

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2025 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
