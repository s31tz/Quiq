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

  $str = $this->dump($scalar);

=head4 Arguments

=over 4

=item $scalar

Referenz auf eine Datenstruktur.

=back

=head4 Description

Liefere eine Perl-Datenstruktur beliebiger Tiefe in lesbarer Form
als Zeichenkette, so dass sie zu Debugzwecken ausgegeben werden kann.

=head4 Example

  Quiq::Dumper->dump($obj);

=cut

# -----------------------------------------------------------------------------

my $maxDepth = 2;

sub dump {
    my ($this,$arg) = splice @_,0,2;
    my $depth = shift // 0;
    my $seenH = shift // {};

    $depth++;

    # Einfacher Skalar

    if (!ref $arg) {
        if (!defined $arg) {
            return 'undef';
        }
        $arg =~ s/\n/\\n/g;
        $arg =~ s/\r/\\r/g;
        return qq|"$arg"|;
    }

    # Referenz

    if ($seenH->{$arg}) {
        return "SEEN $arg";
    }
    $seenH->{$arg}++;

    my $ref = ref $arg;
    my $refType = Scalar::Util::reftype($arg);

    if ($refType eq 'SCALAR') {
        return '\\'.$this->dump($$arg,$depth,$seenH);
    }
    elsif ($refType eq 'ARRAY') {
        my $str = '';
        if ($depth <= $maxDepth) {
            for (my $i = 0; $i < @$arg; $i++) {
                if ($str) {
                    $str .= ",\n";
                }
                $str .= $this->dump($arg->[$i],$depth,$seenH);
            }
            if ($str) {
                $str =~ s/^/  /mg;
                $str = "\n$str\n";
            }
        }
        $str = "[$str]";
        if ($refType ne $ref) {
            $str = "$ref $str";
        }
        return $str;
    }
    elsif ($refType eq 'HASH') {
        my $str = '';
        if ($depth <= $maxDepth) {
            for my $key (sort keys %$arg) {
                if ($str) {
                    $str .= ",\n";
                }
                $str .= "$key => ".$this->dump($arg->{$key},$depth,$seenH);
            }
            if ($str) {
                $str =~ s/^/  /mg;
                $str = "\n$str\n";
            }
        }
        $str = "{$str}";
        if ($refType ne $ref) {
            $str = "$ref $str";
        }
        return $str;
    }
    elsif ($refType eq 'REGEXP') {
        return "/$arg/";
    }

    $this->throw(
        'DUMPER-00002: Unknown reference type',
        ReferenceType => "$refType - $arg",
    );
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
