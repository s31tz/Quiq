# -----------------------------------------------------------------------------

=head1 NAME

Quiq::DataStructure - Operationen auf Datenstrukturen

=head1 BASE CLASS

L<Quiq::Object>

=cut

# -----------------------------------------------------------------------------

package Quiq::DataStructure;
use base qw/Quiq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.209';

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Klassenmethoden

=head3 validate() - Gleiche Datenstruktur gegen Vorlage ab

=head4 Synopsis

  $class->validate($ref0,$ref1);

=head4 Arguments

=over 4

=item $ref0

Datenstruktur als Vorlage

=item $ref1

Datenstruktur

=back

=cut

# -----------------------------------------------------------------------------

sub validate {
    my ($class,$ref0,$ref1) = splice @_,0,3;
    my $keyA = shift // [];

    my $type1 = ref $ref1;
    my $type0 = ref $ref0;

    if ($type1 ne $type0) {
        $class->throw(
            'VALIDATE-00099: Type mismatch',
            Path => join('.',@$keyA),
            Types => "$type1 vs. ".($type0 || 'SCALAR'),
        );
    }

    if ($type1 eq '') {
        # SCALAR
        return;
    }
    elsif ($type1 eq 'ARRAY') {
        if (ref($ref0->[0]) eq '' && ref($ref0->[1]) ne '') {
            # KEYVAL
            for (my $i = 0; $i < @$ref1; $i += 2) {
                $class->validate($ref0->[0],$ref1->[$i]);
                $class->validate($ref0->[1],$ref1->[$i+1],[@$keyA,$ref1->[$i]]);
            }
            return;
        }
        # ARRAY
        for (my $i = 0; $i < @$ref1; $i++) {
            $class->validate($ref0->[0],$ref1->[$i],[@$keyA,"[$i]"]);
        }
        return;
    }
    elsif ($type1 eq 'HASH') {
        for my $key (keys %$ref1) {
            if (!exists $ref0->{$key}) {
                $class->throw(
                    'VALIDATE-00001: Key does not exist',
                    Path => join('.',@$keyA,$key),
                );
            }
            $class->validate($ref0->{$key},$ref1->{$key},[@$keyA,$key]);
        }
        return;
    }

    $class->throw(
        'VALIDATE-00099: Unknown Type',
        Type => $type1,
        Path => join('.',@$keyA),
    );
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.209

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2023 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
