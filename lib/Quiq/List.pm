package Quiq::List;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.173';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::List - Liste von Objekten

=head1 BASE CLASS

L<Quiq::Hash>

=head1 SYNOPSIS

  use Quiq::List;
  
  # Instantiiere Liste
  $lst = Quiq::List->new(\@objects);
  
  # Anzahl der enthaltenen Objekte
  $n = $lst->count;
  
  # Array der enthaltenen Objekte
  @obj = $lst->elements;
  
  # Füge Objekt zur Liste hinzu (am Ende)
  $obj = $lst->push($obj);
  
  # Bilde Objekte auf Werte ab
  
  @arr = $lst->map(sub {
      my $obj = shift;
      ...
      return (...);
  };

=head1 DESCRIPTION

Ein Objekt der Klasse speichert eine Ansammlung von (beliebigen) Objekten.
Mit den Methoden der Klasse kann auf dieser Ansammlung operiert werden.

=head1 EXAMPLES

Bilde die Summe über einem Attributwert:

  use Hash::Util 'sum';
  $sum = sum $lst->map(sub {
      my $obj = shift;
      ...
      return $x;
  });

Bilde die Summe über einem Attributwert:

  $str = join "\n",$lst->map(sub {
      my $obj = shift;
      ...
      return '...';
  });

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

  $lst = $class->new;
  $lst = $class->new(\@objects);

=head4 Arguments

=over 4

=item @objects

Array von Objekten.

=back

=head4 Returns

Listen-Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf dieses
Objekt zurück. Der Aufruf ohne Argument ist äquivalent zu einem
Aufruf mit einem leeren Array. Das Array und die Objekte werden nicht
kopiert, es wird lediglich die übergebene Referenz gespeichert, d.h.
alle Operationen finden auf den Originalstrukturen statt.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    my $objectA = shift // [];

    return $class->SUPER::new(
        objectA => $objectA,
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 count() - Anzahl der Objekte

=head4 Synopsis

  $n = $lst->count;

=head4 Returns

Nicht-negative ganze Zahl

=head4 Description

Liefere die Anzahl der in der Liste gespeichteren Objekte.

=cut

# -----------------------------------------------------------------------------

sub count {
    return scalar @{shift->{'objectA'}};
}

# -----------------------------------------------------------------------------

=head3 elements() - Liste der Objekte

=head4 Synopsis

  @objects | $objectA = $lst->elements;

=head4 Returns

Liste von Objekten. Im Skalarkontext eine Referenz auf die Liste.

=head4 Description

Liefere das Array der in der Liste gespeicherten Objekte.

=cut

# -----------------------------------------------------------------------------

sub elements {
    my $self = shift;
    my $arr = $self->{'objectA'};
    return wantarray? @$arr: $arr;
}

# -----------------------------------------------------------------------------

=head3 map() - Bilde Objekte auf Werte ab

=head4 Synopsis

  @arr | $arr = $lst->map($sub);

=head4 Arguments

=over 4

=item $sub

Subroutine, die für jedes Objekt eine Liste von Werten liefert.
Die Subroutine hat die Signatur

  sub {
      my $obj = shift;
      ...
      return @arr;
  }

=back

=head4 Returns

Array aller Werte. Im Skalarkontext eine Referenz auf das Array.

=head4 Description

Rufe die Subroutine $sub für jedes Element der Liste auf, sammele
alle gelieferten Werte ein und liefere das resultierende Array
zurück.

=cut

# -----------------------------------------------------------------------------

sub map {
    my ($self,$sub) = @_;

    my @arr;
    for (@{$self->elements}) {
        CORE::push @arr,$sub->($_);
    }

    return wantarray? @arr: \@arr;
}

# -----------------------------------------------------------------------------

=head3 push() - Füge Objekt am Ende der Liste hinzu

=head4 Synopsis

  $obj = $lst->push($obj);

=head4 Arguments

=over 4

=item $obj

Objekt

=back

=head4 Returns

Objekt

=head4 Description

Füge Objekt $obj am Ende der Liste hinzu und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub push {
    my ($self,$obj) = @_;
    CORE::push @{$self->{'objectA'}},$obj;
    return $obj;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.173

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2020 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
