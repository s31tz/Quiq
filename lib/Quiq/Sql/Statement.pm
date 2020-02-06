package Quiq::Sql::Statement;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.173';

use Quiq::Epoch;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Sql::Statement - SQL-Statement

=head1 BASE CLASS

L<Quiq::Hash>

=head1 SYNOPSIS

  use Quiq::Sql::Statement;
  
  my $s = Quiq::Sql::Statement->new($stmt,@keyVal);

=head1 DESCRIPTION

Ein Objekt der Klasse speichert ein SQL-Statement plus zusätzlicher
Information wie z.B. einen Ausführungszeitraum oder eine Dauer.

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

  $s = $class->new($stmt,@attVal);

=head4 Attributes

=over 4

=item begin => $epoch

Anfangszeitpunkt der Ausführung in ISO-Darstellung mit Nachkomastellen
(YYYY-MM-DD HH:MI:SS.XXX).

=item end => $epoch

Endezeitpunkt der Ausführung in ISO-Darstellung in ISO-Darstellung.

=item duration => $sec

Ausführungszeit in Sekunden. Wenn nicht angegeben, wird die
Ausführungszeit aus den Attributen begin und end berechnet.

=back

=head4 Arguments

=over 4

=item $stmt

Das SQL-Statement.

=item @attVal

Attribut/Wert-Paare.

=back

=head4 Returns

Statement-Objekt

=head4 Description

Instantiiere ein Statement-Objekt für Statement $stmt und liefere eine
Referenz auf dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$stmt) = splice @_,0,2;

    my $self = $class->SUPER::new(
        stmt => $stmt,
        begin => undef,
        end => undef,
        duration => undef,
    );
    $self->set(@_);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 stmt() - SQL-Statemrnt

=head4 Synopsis

  $stmt = $s->stmt;

=head4 Returns

SQL-Statement (String)

=head4 Description

Liefere das SQL-Statement.

=head3 duration() - Ausführungsdauer

=head4 Synopsis

  $sec = $s->duration;

=head4 Returns

Sekunden (Float)

=head4 Description

Ausführungszeit in Sekunden (mit Nachkommastellen).

=cut

# -----------------------------------------------------------------------------

sub duration {
    my $self = shift;

    if (defined $self->{'duration'}) {
        return $self->{'duration'};
    }
    elsif (defined($self->{'begin'}) && defined($self->{'end'})) {
        my $t0 = Quiq::Epoch->new($self->{'begin'})->epoch;
        my $t1 = Quiq::Epoch->new($self->{'end'})->epoch;
        return $t1-$t0;
    }
    $self->throw;
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
