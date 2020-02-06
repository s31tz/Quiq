package Quiq::Sql::Sequence;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.173';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Sql::Sequence - Folge von SQL-Statements

=head1 BASE CLASS

L<Quiq::Hash>

=head1 SYNOPSIS

  use Quiq::Sql::Sequence;
  
  my $seq = Quiq::Sql::Sequence->new;
  $seq->push($s);
  printf "%.3f\n",$seq->duration;

=head1 DESCRIPTION

Ein Objekt der Klasse speichert eine Folge von SQL-Statements
(siehe Klasse Quiq::Sql::Statement).

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

  $seq = $class->new;

=head4 Returns

Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf dieses
Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;

    return $class->SUPER::new(
        stmtA => [],
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 stmts() - Liste der Statement-Objekte

=head4 Synopsis

  @stmts | $stmtA = $seq->stmts;

=head4 Returns

Liste von Statement-Objekte. Im Skalarkontext eine Referenz auf die Liste.

=head4 Description

Liefere die Liste der Statement-Objekte.

=cut

# -----------------------------------------------------------------------------

sub stmts {
    my $self = shift;
    my $arr = $self->{'stmtA'};
    return wantarray? @$arr: $arr;
}

# -----------------------------------------------------------------------------

=head3 duration() - Gesamt-Ausführungsdauer

=head4 Synopsis

  $sec = $seq->duration;

=head4 Returns

Sekunden (Float)

=head4 Description

Gesamt-Ausführungszeit in Sekunden (mit Nachkommastellen).

=cut

# -----------------------------------------------------------------------------

sub duration {
    my $self = shift;

    my $duration = 0;
    for my $s (@{$self->stmts}) {
        $duration += $s->duration;
    }

    return $duration;
}

# -----------------------------------------------------------------------------

=head3 push() - Füge Statement-Objekt hinzu

=head4 Synopsis

  $seq->push($s);

=head4 Description

Füge Statement-Objekt zu Statement-Sequenz hinzu.

=cut

# -----------------------------------------------------------------------------

sub push {
    my ($self,$s) = @_;
    $self->SUPER::push(stmtA=>$s);
    return;
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
