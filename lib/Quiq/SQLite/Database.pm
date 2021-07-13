package Quiq::SQLite::Database;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.193';

use Quiq::Path;
use Quiq::Database::Connection;
use Quiq::FileHandle;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::SQLite::Database - Schema-Entwicklung auf SQLite-Datenbank

=head1 BASE CLASS

L<Quiq::Hash>

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere SQLite Datenbank-Objekt

=head4 Synopsis

  $sd = $class->new($dir,$name);

=head4 Arguments

=over 4

=item $dir

Verzeichnis mit Datenbank-, Schema- und Exportdateien.

=item $name

Grundname der Datenbankdatei.

=back

=head4 Returns

Object

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$dir,$name) = @_;

    my $p = Quiq::Path->new;

    $dir = $p->expandTilde($dir);
    if (!-d $dir) {
        $class->throw(
            'SQLITE-00001: Directory does not exist',
            Dir => $dir,
        );
    }

    return $class->SUPER::new(
        dir => $dir,
        name => $name,
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 connect() - Öffne Datenbankverbindung

=head4 Synopsis

  $db = $sd->connect;

=head4 Returns

Datenbankverbindung (Object)

=head4 Description

Instantiiere eine Verbindung zur SQLite-Datenbank und liefere eine
Referenz auf dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub connect {
    my $self = shift;

    my $p = Quiq::Path->new;

    # Wenn das DB-Verzeichnis nicht existiert, erzeugen wir es
    # (Parent-Verzeichnis muss existieren)

    my $dbDir = sprintf '%s/db',$self->dir;
    $p->mkdir($dbDir);
    
    my $dbFile = sprintf '%s/%s.db',$dbDir,$self->name;
    my $udl = sprintf 'dbi#sqlite:%s',$dbFile;
    
    return Quiq::Database::Connection->new($udl,
        -utf8 => 1,
        -log => 1,
    );
}

# -----------------------------------------------------------------------------

=head3 save() - Sichere Schema und Daten in Dateisystem

=head4 Synopsis

  $class->save($db,$dir);

=head4 Arguments

=over 4

=item $db

Verbindung zur zu sichernden SQLite-Datenbank.

=item $dir

Verzeichnis, in das die Datenbank (Schema und Daten) gesichert wird.

=back

=head4 Options

=over 4

=item -force => $bool

=back

=head4 Description

Sichere den Inhalt der SQLite-Datenbank $db in Verzeichnis $dir. Das
Verzeichnis hat die Substruktur:

  schema/create1.sql
  schema/create2.sql
  data/<table1>.dat

=cut

# -----------------------------------------------------------------------------

sub save {
    my $class = shift;

    my $p = Quiq::Path->new;

    # Optionen und Argumente

    my $force = 0;

    my $argA = $class->parameters(2,2,\@_,
        -force => \$force,
    );
    my $db = shift @$argA;
    my $dir = $p->expandTilde(shift @$argA);

    # Prüfe, ob Export-Verzeichnis bereits existiert

    if ($force && $p->exists($dir)) {
        $p->delete($dir);
    }

    if ($p->exists($dir)) {
        $class->throw(
            'SQLITE-00001: Export dir already exists',
            Dir => $dir,
        );
    }

    # Erzeuge Export-Verzeichnis

    my $schemaDir = "$dir/schema";
    my $dataDir = "$dir/data";

    $p->mkdir($schemaDir,-recursive=>1);
    $p->mkdir($dataDir);

    # Bestimme Datenbank-Datei

    my $tab = $db->select('PRAGMA database_list');
    my $dbFile = $tab->lookup(name=>'main')->file;

    # Sichere Schema in zwei Teilen (Tabellen, Rest)

    my $fh = Quiq::FileHandle->new('|-',"sqlite3 $dbFile");
    $fh->print(".output $schemaDir/create.sql\n");
    $fh->print(".schema\n");
    $fh->print(".exit\n");
    $fh->close;

    my $schema1;
    my $schema2 = Quiq::Path->read("$schemaDir/create.sql");
    while ($schema2 =~ s/^(CREATE TABLE.*?\);\n)//s) {
        $schema1 .= $1;
    }
    $p->write("$schemaDir/create1.sql",$schema1);
    $p->write("$schemaDir/create2.sql",$schema2);
    $p->delete("$schemaDir/create.sql");

    # Sichere Tabellendaten

    $p->mkdir($dir,-recursive=>1);
    my $tabT = $db->select(
        -select => 'name',
        -from => 'sqlite_master',
        -where,type => 'table',
        -orderBy => 'name',
    );
    for my $tab ($tabT->rows) {
        my $table = $tab->name;
        $db->exportTable($table,"$dataDir/$table.dat");
    }

    return;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.193

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
