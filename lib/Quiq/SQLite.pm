package Quiq::SQLite;
use base qw/Quiq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.193';

use Quiq::Path;
use Quiq::FileHandle;
use Quiq::Database::Connection;
use Quiq::Shell;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::SQLite - Operationen auf einer SQLite-Datenbank

=head1 BASE CLASS

L<Quiq::Object>

=head1 METHODS

=head2 Klassenmethoden

=head3 exportDatabase() - Exportiere SQLite Datenbank in Verzeichnis

=head4 Synopsis

  $class->exportDatabase($dbFile,$exportDir);

=head4 Arguments

=over 4

=item $dbFile

SQLite Datenbank-Datei.

=item $exportDir

Verzeichnis, in das die Datenbank (Schema und Daten)
gesichert wird. Existiert das Verzeichnis nicht, wird es angelegt.

=back

=head4 Description

Exportiere den Inhalt der SQLite-Datenbank $dbFile in
Verzeichnis $exportDir.

=head4 Example

  Quiq::SQLite->export('~/var/myapp/myapp.db','/tmp/myapp');

=cut

# -----------------------------------------------------------------------------

sub exportDatabase {
    my ($class,$dbFile,$exportDir) = @_;

    my $p = Quiq::Path->new;

    # Exportiere Tabellendaten ($exportDir wird implizit erzeugt bzw.
    # dessen Inhalt gelöscht)
    $class->exportData($dbFile,$exportDir);

    # Exportiere Schema

    my $schemaFile = "$exportDir/schema.sql";
    my $fh = Quiq::FileHandle->new('|-',"sqlite3 $dbFile");
    $fh->print(".output $schemaFile\n");
    $fh->print(".schema\n");
    $fh->print(".exit\n");
    $fh->close;

    # * Ignoriere SQLite-interne Tabellen

    my $sql = $p->read($schemaFile);
    $sql =~ s/CREATE TABLE sqlite_.*?;\n//g;
    $p->write($schemaFile,$sql);

    return;
}

# -----------------------------------------------------------------------------

=head3 exportData() - Exportiere SQLite Tabellendaten in Verzeichnis

=head4 Synopsis

  $class->exportData($dbFile,$exportDir);

=head4 Arguments

=over 4

=item $dbFile

SQLite Datenbank-Datei.

=item $exportDir

Verzeichnis, in das die Tabellendaten gesichert werden. Existiert das
Verzeichnis nicht, wird es angelegt.

=back

=head4 Description

Exportiere die Tabellendaten der SQLite-Datenbank $dbFile in
Verzeichnis $exportDir.

=head4 Example

  Quiq::SQLite->export('~/var/myapp/myapp.db','/tmp/myapp');

=cut

# -----------------------------------------------------------------------------

sub exportData {
    my ($class,$dbFile,$exportDir) = @_;

    my $p = Quiq::Path->new;

    # Erzeuge Exportverzeichnis, falls es nicht existiert. Falls es
    # existiert, lösche seinen Inhalt.
    
    $p->mkdir($exportDir,-recursive=>1);
    $p->deleteContent($exportDir);

    # Exportiere die Tabellendaten

    my $udl = "dbi#sqlite:$dbFile";
    my $db = Quiq::Database::Connection->new($udl,-utf8=>1);
    my @tables = $db->values(
        -select => 'name',
        -from => 'sqlite_master',
        -where,
            type => 'table',
            "tbl_name NOT LIKE 'sqlite_%'",
        -orderBy => 'name',
    );

    for my $table (@tables) {
        $db->exportTable($table,"$exportDir/$table.dat");
    }

    $db->disconnect;

    return;
}

# -----------------------------------------------------------------------------

=head3 importDatabase() - Importiere SQLite Tabellendaten aus Verzeichnis

=head4 Synopsis

  $class->importDatabase($dbFile,$exportDir);

=cut

# -----------------------------------------------------------------------------

sub importDatabase {
    my ($class,$dbFile,$importDir) = @_;

    my $p = Quiq::Path->new;
    my $sh = Quiq::Shell->new;

    # Datenbankdatei sichern (sichern) und leeren.

    $sh->exec("cp $dbFile /tmp/".$p->filename($dbFile).'.bak');
    $p->write($dbFile,'');

    # Erzeuge Schema
    $sh->exec("sqlite3 $dbFile <$importDir/schema.sql");

    # Importiere Tabellendaten
    $class->importData($dbFile,$importDir);

    return;
}

# -----------------------------------------------------------------------------

=head3 importData() - Importiere SQLite Datenbank aus Verzeichnis

=head4 Synopsis

  $class->importData($dbFile,$exportDir);

=cut

# -----------------------------------------------------------------------------

sub importData {
    my ($class,$dbFile,$importDir) = @_;

    # Importiere Tabellendaten

    my $udl = "dbi#sqlite:$dbFile";
    my $db = Quiq::Database::Connection->new($udl,-utf8=>1);

    for my $file (Quiq::Path->glob("$importDir/*.dat")) {
        my ($table) = $file =~ m|/([^/]+).dat$|;
        $db->delete($table);
        $db->importTable($table,$file);
    }
    $db->disconnect(1);

    return;
}

# -----------------------------------------------------------------------------

=head3 recreateDatabase() - Erzeuge SQLite Datenbank neu

=head4 Synopsis

  $class->recreateDatabase($dbFile,$sub);

=head4 Arguments

=over 4

=item $dbFile

SQLite Datenbank-Datei.

=item $sub

Refenz auf eine Subroutine, die das Schema auf einer I<leeren>
Datenbank erzeugt. Als Parameter wird $dbFile übergeben.

  $class->recreateDatabase('~/var/myapp/myapp.db',sub {
      my $dbPath = shift;
  
      my $db = %<Quiq::Database::Connection->new("dbi#sqlite:$dbPath",
          -utf8 => 1,
      );
  
      # via $db alle Schemaobjekte erzeugen,
      # aber keine Daten importieren!
      ...
  
      return;
  });

=back

=head4 Description

Erzeuge die Datenbank in fünf Schritten neu:

=over 4

=item 0.

Die Datenbank wird gesichert

=item 1.

Alle Tabellendaten werden exportiert (in temporäres Verzeichnis)

=item 2.

Die Datenbank wird komplett geleert

=item 4.

Die Subroutine $sub wird aufgerufen, welche die Datenbankstrukturen
neu erzeugt

=item 5.

Die zuvor exportierten Daten werden importiert

=back

=cut

# -----------------------------------------------------------------------------

sub recreateDatabase {
    my ($class,$dbFile,$sub) = @_;

    my $p = Quiq::Path->new;

    # Exportiere Tabellendaten

    my $exportDir = $p->tempDir(-cleanup=>0);
    warn "Exporting table data to directory: $exportDir\n";
    $class->exportData($dbFile,$exportDir);

    # Sichere Datenbank

    warn "Saving database file $dbFile to directory $exportDir\n";
    $p->copyToDir($dbFile,$exportDir,-preserve=>1);

    # Erzeuge Datenbank neu

    warn "Emptying database $dbFile\n";
    $p->truncate($dbFile);

    my $db = Quiq::Database::Connection->new("dbi#sqlite:$dbFile",
        -utf8=>1,
    );
    warn "Creating schema\n";
    $sub->($dbFile);
    $db->disconnect(1);

    # Importiere Tabellendaten

    warn "Importing table data from directory: $exportDir\n";
    $class->importData($dbFile,$exportDir);

    # Wenn alles gut gegangen ist, löschen wir das Exportverzeichnis

    warn "Deleting directory: $exportDir\n";
    $p->delete($exportDir);

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
