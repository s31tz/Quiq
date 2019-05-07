package R1::Hash1;
use base qw/Quiq::Hash/;

use strict;
use warnings;
use v5.10.0;

# -----------------------------------------------------------------------------

=head1 NAME

R1::Hash1 - Hash-Klasse

=head1 BASE CLASS

L<Quiq::Hash>

=head1 METHODS

=head2 Konstruktor

=head3 new()

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @args

    my $h = $class->SUPER::new(@_);
    $h->unlockKeys;
    
    return $h;
}

# -----------------------------------------------------------------------------

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=cut

# -----------------------------------------------------------------------------

1;

# eof
