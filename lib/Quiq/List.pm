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
  
  my $lst = Quiq::List->new(\@objects);

=head1 DESCRIPTION

Ein Objekt der Klasse speichert eine Kollektion von (beliebigen) Objekten.
Mit den Methoden der Klasse kann auf dieser Kollektion operiert werden.

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

  $lst = $class->new;
  $lst = $class->new(\@objects);

=head4 Arguments

=over 4

=item @objects

Liste von Objekten.

=back

=head4 Returns

Listen-Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf dieses
Objekt zurück.

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

Integer

=head4 Description

Liefere die Anzahl der Objekte, also eine ganze Zahl >= 0.

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

Liefere die Liste der enthaltenen Objekte in der Reihenfolge,
wie sie intern gespeichert sind.

=cut

# -----------------------------------------------------------------------------

sub elements {
    my $self = shift;
    my $arr = $self->{'objectA'};
    return wantarray? @$arr: $arr;
}

# -----------------------------------------------------------------------------

=head3 push() - Füge Objekt zu Liste hinzu

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

Füge Objekt $obj zur Liste hinzu und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub push {
    my ($self,$obj) = @_;
    $self->SUPER::push(objectA=>$obj);
    return $obj;
}

# -----------------------------------------------------------------------------

=head3 sum() - Summiere Werte

=head4 Synopsis

  $sum = $lst->sum($sub);

=head4 Arguments

=over 4

=item $sub

Subroutine, die den Objektwert liefert, der summiert werden soll.
Die Subroutine hat die Signatur

  sub {
      my $obj = shift;
      ...
      return $val;
  }

=back

=head4 Returns

Summe (Number)

=head4 Description

Summiere alle Werte, die die Subroutine $sub liefert. Die Subroutine
wird für jedes Element der Liste gerufen, mit dem Listenelement
als erstem (und einzigem) Parameter.

=cut

# -----------------------------------------------------------------------------

sub sum {
    my ($self,$sub) = @_;

    my $sum;
    for (@{$self->elements}) {
        $sum += $sub->($_);
    }

    return $sum;
}

# -----------------------------------------------------------------------------

=head3 concat() - Konkateniere Werte

=head4 Synopsis

  $str = $lst->concat($sub);

=head4 Arguments

=over 4

=item $sub

Subroutine, die den Objektwert liefert, der concateniert werden soll.
Die Subroutine hat die Signatur

  sub {
      my $obj = shift;
      ...
      return $val;
  }

=back

=head4 Returns

String

=head4 Description

Konkateniere alle Werte, die die Subroutine $sub liefert. Die Subroutine
wird für jedes Element der Liste gerufen, mit dem Listenelement
als erstem (und einzigem) Parameter.

=cut

# -----------------------------------------------------------------------------

sub concat {
    my ($self,$sub) = @_;

    my $str;
    for (@{$self->elements}) {
        $str .= $sub->($_);
    }

    return $str;
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
