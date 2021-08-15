package Quiq::Dumper;
use base qw/Quiq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.195';

use Scalar::Util ();

# -----------------------------------------------------------------------------

=head1 NAME

Quiq::Dumper - Ausgabe Datenstruktur

=head1 BASE CLASS

L<Quiq::Object>

=head1 METHODS

=head2 Klassenmethoden

=head3 dump() - Liefere Datenstruktur in lesbarer Form

=head4 Synopsis

  $str = $this->dump($ref);

=head4 Arguments

=over 4

=item $ref

Referenz auf eine Datenstruktur.

=back

=head4 Description

Liefere eine Perl-Datenstruktur beliebiger Tiefe in lesbarer Form
als Zeichenkette, so dass sie zu Debugzwecken ausgegeben werden kann.

=head4 Example

  Quiq::Dumper->dump($obj);

=cut

# -----------------------------------------------------------------------------

sub dump {
    my ($this,$ref) = splice @_,0,2;
    my $seenH = shift // {};

    my $str = '';
    if (!ref $ref) {
        $this->throw(
            'DUMPER-00001: Argument must be a reference',
            Argument => $ref,
        );
    }

    my $refType = Scalar::Util::reftype($ref);
    if ($refType eq 'SCALAR') {
        if (!defined $$ref) {
            $str = 'undef';
        }
        else {
            $str = qq|"$$ref"|;
        }
        $str = '\\'.$str;
    }
    else {
        $this->throw(
            'DUMPER-00002: Unknown reference type',
            ReferenceType => "$refType - $ref",
        );
    }

    return $str;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.195

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2021 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
