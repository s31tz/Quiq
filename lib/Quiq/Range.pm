package Quiq::Range;
use base qw/Quiq::Hash/;

use strict;
use warnings;
use v5.10.0;

our $VERSION = '1.156';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Range - Bereich von Integern

=head1 BASE CLASS

L<Quiq::Hash>

=head1 SYNOPSIS

    use Quiq::Range;
    
    # Instantiierung
    my $rng = Quiq::Range->new($rangeSpec);
    
    # Range als Array von Integern
    my @arr = Quiq::Range->numbers;

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert einen Bereich. Ein Bereich ist eine
Aufzählung von Integer-Werten der Art

    1,2,3,4
    1-4
    3,5,7-10,16,81-89,101

=head1 ATTRIBUTES

=over 4

=item rangeSpec => $rangeSpec

Bereichs-Spezifikation, die dem Konstruktur übergeben wurde.

=item numberA => \@numbers

Der Bereich als Array von Integer-Werten.

=back

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

    $rng = $class->new($rangeSpec);

=head4 Arguments

=over 4

=item $rangeSpec

Spezifikation des Bereichs.

=back

=head4 Returns

Range-Objekt

=head4 Description

Instantiiere ein Range-Objekt für Bereichsspezifikation $rangeSpec und
liefere eine Referenz auf dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    my $rangeSpec = shift // '';

    my @arr;
    for (split /,/,$rangeSpec) {
        my ($min,$max) = split /-/;
        push @arr,$max? ($min..$max): $_;
    }

    # Objekt instantiieren

    return $class->SUPER::new(
        rangeSpec => $rangeSpec,
        numberA => \@arr,
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 numbers() - Nummern des Bereichs

=head4 Synopsis

    @numbers | $numberA = $rng->numbers;
    @numbers | $numberA = $class->numbers($rangeSpec);

=head4 Returns

Liste von Nummern (Array of Integers). Im Skalarkontext eine Referenz
auf die Liste.

=head4 Description

Liefere die Liste der Nummern des Bereichs.

=cut

# -----------------------------------------------------------------------------

sub numbers {
    my $self = ref $_[0]? shift: shift->new(shift);
    my $arr = $self->{'numberA'};
    return wantarray? @$arr: $arr;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.156

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
