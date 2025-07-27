# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::StreamServe::Block - Inhalt eines StreamServe Blocks

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert den Inhalt eines StreamServe-Blocks,
also eine Menge von Schlüssel/Wert-Paaren eines Typs (der durch den
gemeinsamen Namenspräfix gegeben ist).

=cut

# -----------------------------------------------------------------------------

package Quiq::StreamServe::Block;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.229';

use Quiq::Hash;

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $ssb = $class->new($prefix);
  $ssb = $class->new($prefix,$h);

=head4 Arguments

=over 4

=item $prefix

Block-Präfix

=item $h (Default: {})

Hash mit den Schlüssel/Wert-Paaren des Blocks

=back

=head4 Returns

Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere dieses zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$prefix) = splice @_,0,2;
    my $h = shift // {};

    return $class->SUPER::new(
        prefix => $prefix,
        # hash => Quiq::Hash->new($h)->unlockKeys,
        hash => Quiq::Hash->new($h),
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 add() - Setze Schlüssel/Wert-Paar ohne Exception

=head4 Synopsis

  $ssb->add($key,$val);

=head4 Description

Ist der Schlüssel vorhanden, wird sein Wert gesetzt. Ist er nicht
vorhanden wird er mit dem angegebenen Wert hinzugefügt.

=cut

# -----------------------------------------------------------------------------

sub add {
    my ($self,$key,$val) = @_;

    $self->hash->add($key,$val);

    return;
}

# -----------------------------------------------------------------------------

=head3 set() - Setze Schlüssel/Wert-Paar

=head4 Synopsis

  $ssb->set($key,$val);

=cut

# -----------------------------------------------------------------------------

sub set {
    my ($self,$key,$val) = @_;

    $self->hash->set($key,$val);

    return;
}

# -----------------------------------------------------------------------------

=head3 get() - Liefere Wert eines Schlüssels

=head4 Synopsis

  $val = $ssb->get($key);
  $val = $ssb->get($key,$sloppy);

=head4 Arguments

=over 4

=item $key

Schlüssel

=back

=head4 Options

=over 4

=item $sloppy (Default: 0)

Wirf bei Nichtexistenz von $key keine Exception, sondern liefere C<undef>.

=back

=cut

# -----------------------------------------------------------------------------

sub get {
    my ($self,$key,$sloppy) = @_;

    if ($sloppy) {
        local $@;
        return eval {$self->hash->get($key)};
    }

    return $self->hash->get($key);
}

# -----------------------------------------------------------------------------

=head3 prefix() - Liefere Präfix

=head4 Synopsis

  $prefix = $ssb->prefix;

=cut

# -----------------------------------------------------------------------------

# Attributmethode

# -----------------------------------------------------------------------------

=head1 VERSION

1.229

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
