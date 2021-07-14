package Quiq::SQLite;
use base qw/Quiq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.193';

use Quiq::Path;
use Quiq::FileHandle;
use Quiq::Database::Connection;
use Quiq::Unindent;
use Quiq::Shell;

# -----------------------------------------------------------------------------

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

    # Erzeuge Exportverzeichnis, falls es nicht existiert. Falls es
    # existiert, lösche seinen Inhalt.
    
    $p->mkdir($exportDir,-recursive=>1);
    $p->deleteContent($exportDir);

    # Ermittele die zu exportierenden Tabellen

    # Exportiere das Schema in zwei Dateien. Die erste Datei enthält
    # die Tabellendefinitionen, die zweite Datei den Rest (Indizes usw.)

    my $fh = Quiq::FileHandle->new('|-',"sqlite3 $dbFile");
    $fh->print(".output $exportDir/schema.sql\n");
    $fh->print(".schema\n");
    $fh->print(".exit\n");
    $fh->close;

    my $schema1;
    my $schema2 = Quiq::Path->read("$exportDir/schema.sql");
    while ($schema2 =~ s/^(CREATE TABLE.*?\);\n)//s) {
        my $stmt = $1;
        if ($stmt =~ / sqlite_/) {
            next;
        }
        $schema1 .= $stmt;
    }
    Quiq::Path->write("$exportDir/schema1.sql",$schema1);
    Quiq::Path->write("$exportDir/schema2.sql",$schema2);
    Quiq::Path->delete("$exportDir/schema.sql");

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

    # Import-Skript erzeugen

    $p->write("$exportDir/import.sh",Quiq::Unindent->string(qq~
        perl -MQuiq::SQLite -E 'Quiq::SQLite->importDatabase("$dbFile",".")'
    ~));
    $p->chmod("$exportDir/import.sh",0775);

    return;
}

# -----------------------------------------------------------------------------

=head3 importDatabase() - Importiere SQLite Datenbank aus Verzeichnis

=head4 Synopsis

  $class->importDatabase($db,$name);

=cut

# -----------------------------------------------------------------------------

sub importDatabase {
    my ($class,$dbFile,$importDir) = @_;

    my $p = Quiq::Path->new;
    my $sh = Quiq::Shell->new;

    # Datenbank entfernen (sichern). Sie wird anschließend neu erzeugt.
    $sh->exec("mv $dbFile /tmp/".$p->filename($dbFile));

    # Erzeuge Tabellen
    $sh->exec("sqlite3 $dbFile <$importDir/schema1.sql");

    # Importiere Tabellendaten

    my $udl = "dbi#sqlite:$dbFile";
    my $db = Quiq::Database::Connection->new($udl,-utf8=>1);

    for my $file ($p->glob("$importDir/*.dat")) {
        my ($table) = $file =~ m|/([^/]+).dat$|;
        $db->importTable($table,$file);
    }
    $db->disconnect(1);

    # Erzeuge Indizes usw.
    $sh->exec("sqlite3 $dbFile <$importDir/schema2.sql");

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
