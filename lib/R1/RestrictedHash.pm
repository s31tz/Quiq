# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

R1::RestrictedHash - Hash-Klasse ohne änderbare Schüssel

=head1 BASE CLASS

L<R1::Hash1>

=head1 DESCRIPTION

Identisch zu R1::Hash1, nur dass am Ende des Konstruktors
alle Hash-Keys gelockt werden.

=cut

# -----------------------------------------------------------------------------

package R1::RestrictedHash;
use base qw/R1::Hash1/;

use v5.10;
use strict;
use warnings;

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new()

=head4 Description

Siehe Basisklasse R1::Hash1.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: Argumente

    my $self = $class->SUPER::new(@_);
    $self->lockKeys;

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 copy()

=head4 Description

MEMO: Diese Methode macht Probleme im Zusammenhang mit CoTeDo! Dateien
werden alternierend gelöscht und generiert. Grund unklar.

Siehe Basisklasse R1::Hash1.

=cut

# -----------------------------------------------------------------------------

#sub copy {
#    my $self = shift;
#
#    my $h = $self->SUPER::copy;
#    $h->lockKeys;
#
#    return $h;
#}

# -----------------------------------------------------------------------------

=head3 add() -  Füge neue Schlüssel/Wert-Paare hinzu

=head4 Synopsis

  $hash->add(@keyVal);

=cut

# -----------------------------------------------------------------------------

sub add {
    my $self = shift;
    # @_: @keyVal

    # FIXME: Nachdenken, ob Exception, wenn Attribut bereits existiert

    $self->unlockKeys;
    while (@_) {
        my $key = shift;
        $self->{$key} = shift;
    }
    $self->lockKeys;

    return;
}

# -----------------------------------------------------------------------------

=head3 exists()

=head4 Description

Siehe Basisklasse R1::Hash1.

=cut

# -----------------------------------------------------------------------------

sub exists {
    my ($self,$key) = @_;

    $self->unlockKeys;
    my $bool = $self->SUPER::exists($key);
    $self->lockKeys;

    return $bool;
}

# -----------------------------------------------------------------------------

=head3 rebless()

=head4 Description

Siehe Basisklasse Quiq::Object.

=cut

# -----------------------------------------------------------------------------

sub rebless {
    my ($self,$class) = @_;

    $self->unlockKeys;
    $self->SUPER::rebless($class);
    $self->lockKeys;

    return;
}

# -----------------------------------------------------------------------------

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=cut

# -----------------------------------------------------------------------------

1;

# eof
