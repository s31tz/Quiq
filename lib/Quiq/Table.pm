package Quiq::Table;
use base qw/Quiq::Hash/;

use strict;
use warnings;
use v5.10.0;

our $VERSION = 1.140;

use Quiq::Hash;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Table - Datenstruktur aus Zeilen und Kolumnen

=head1 BASE CLASS

L<Quiq::Hash>

=head1 SYNOPSIS

    use Quiq::Table;
    
    $tab = Quiq::Table->new(['a','b','c','d']);
    
    @columns = $tab->columns;
    # ('a','b','c','d')
    
    $columnA = $tab->columns;
    # ['a','b','c','d']
    
    $i = $tab->columnIndex('a');
    # 0
    
    $i = $tab->columnIndex('d');
    # 3
    
    $i = $tab->columnIndex('z');
    # Exception
    
    $count = $tab->count;
    # 0
    
    @rows = $tab->rows;
    # ()
    
    $rowA = $tab->rows;
    # []
    
    $width = $tab->width;
    # 4

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert eine Datenstruktur aus Zeilen
und Kolumnen. Die Namen der Kolumnen werden dem Konstruktor der Klasse
übergeben. Sie bezeichnen Komponenten der Zeilen. Die Zeilen sind Objekte
der Klasse Quiq::TableRow.

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

    $tab = $class->new(\@columns);

=head4 Arguments

=over 4

=item @columns

Liste der Kolumnennamen (Strings).

=back

=head4 Returns

Referenz auf Tabellen-Objekt

=head4 Description

Instantiiere ein Tabellen-Objekt mit den Kolumnennamen @columns und
liefere eine Referenz auf das Objekt zurück. Die Kolumnennamen werden
nicht kopiert, sondern die Referenz wird im Objekt gespeichert. Die
Liste der Zeilen ist zunächst leer.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$columnA) = @_;

    my $i = 0;
    return $class->SUPER::new(
        columnA => $columnA,
        columnH => Quiq::Hash->new({map {$_ => $i++} @$columnA}),
        rowA => [],
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 columns() - Liste der Kolumnennamen

=head4 Synopsis

    @columns | $columnA = $tab->columns;

=head4 Returns

Liste der Kolumnennamen (Strings). Im Skalarkontext eine Referenz
auf die Liste.

=head4 Description

Liefere die Liste der Kolumnennamen der Tabelle.

=cut

# -----------------------------------------------------------------------------

sub columns {
    my $self = shift;

    my $columnA = $self->{'columnA'};
    return wantarray? @$columnA: $columnA;
}

# -----------------------------------------------------------------------------

=head3 count() - Anzahl der Zeilen

=head4 Synopsis

    $count = $tab->count;

=head4 Returns

Integer

=head4 Description

Liefere die Anzahl der Zeilen der Tabelle.

=cut

# -----------------------------------------------------------------------------

sub count {
    my $self = shift;
    return scalar @{$self->{'rowA'}};
}

# -----------------------------------------------------------------------------

=head3 columnIndex() - Index einer Kolumne

=head4 Synopsis

    $i = $tab->columnIndex($column);

=head4 Returns

Integer

=head4 Description

Liefere den Index der Kolumne $column. Der Index einer Kolumne ist ihre
Position innerhalb des Kolumnen-Array.

=cut

# -----------------------------------------------------------------------------

sub columnIndex {
    my ($self,$column) = @_;
    return $self->{'columnH'}->{$column};
}

# -----------------------------------------------------------------------------

=head3 rows() - Liste der Zeilen

=head4 Synopsis

    @rows | $rowA = $tab->rows;

=head4 Returns

Liste der Zeilen (Objekte der Klasse Quiq::TableRow). Im Skalarkontext
eine Referenz auf die Liste.

=head4 Description

Liefere die Liste der Zeilen der Tabelle.

=cut

# -----------------------------------------------------------------------------

sub rows {
    my $self = shift;

    my $rowA = $self->{'rowA'};
    return wantarray? @$rowA: $rowA;
}

# -----------------------------------------------------------------------------

=head3 width() - Anzahl der Kolumnen

=head4 Synopsis

    $width = $tab->width;

=head4 Returns

Integer

=head4 Description

Liefere die Anzahl der Kolumnen der Tabelle.

=cut

# -----------------------------------------------------------------------------

sub width {
    my $self = shift;
    return scalar @{$self->{'columnA'}};
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.140

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
