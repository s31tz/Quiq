package Quiq::SQLite;
use base qw/Quiq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.193';

use Quiq::Path;
use Quiq::Database::Connection;
use Quiq::Unindent;
use Quiq::Shell;

# -----------------------------------------------------------------------------

=head1 NAME

Quiq::SQLite - Operationen auf SQLite-Datenbank

=head1 BASE CLASS

L<Quiq::Object>

=head1 METHODS

=head2 Klassenmethoden

=head3 export() - Exportiere Datenbank in Verzeichnis

=head4 Synopsis

  $class->export($dbFile,$exportDir);

=head4 Arguments

=over 4

=item $dbFile

SQLite Datenbank-Datei.

=item $exportDir

Verzeichnis, in das die Datenbank (Schema, Daten, Skripte)
gesichert wird.  Existiert das Verzeichnis nicht, wird es erzeugt.

=back

=head4 Description

Sichere den Inhalt der SQLite-Datenbank $dbFile in Verzeichnis $exportDir.

=head4 Example

  Quiq::SQLite->export('~/var/knw/knw.db','/tmp/knw');

=cut

# -----------------------------------------------------------------------------

sub export {
    my ($class,$dbFile,$exportDir) = @_;

    my $p = Quiq::Path->new;

    # Erzeuge Exportverzeichnis, falls es nicht existiert
    $p->mkdir($exportDir,-recursive=>1);

    my $udl = "dbi#sqlite:$dbFile";
    my $db = Quiq::Database::Connection->new($udl,-utf8=>1);
    my @tables = $db->values(
        -select => 'name',
        -from => 'sqlite_master',
        -where,type => 'table',
        -orderBy => 'name',
    );
    $db->disconnect;

    # Erzeuge SQLite Export-Skript

    my $script = Quiq::Unindent->string(q~
        .output create.sql
        .schema
        .mode csv
        .headers on
    ~);
    for my $table (@tables) {
        $script .= ".output $table.csv\n";
        $script .= "SELECT * FROM $table;\n";
    }
    $script .= ".exit\n";

    $p->write("$exportDir/export.sqlite",$script);
    $p->write("$exportDir/export.sh","sqlite3 $dbFile <export.sqlite\n");
    $p->chmod("$exportDir/export.sh",0775);

    my $sh = Quiq::Shell->new;
    $sh->cd($exportDir);
    $sh->exec('./export.sh');

    # Erzeuge Import-Skript

    $script = Quiq::Unindent->string(q~
        .read create.sql
        .mode csv
        .headers on
    ~);
    for my $table (@tables) {
        $script .= ".import $table.csv $table\n";
    }
    $script .= ".exit\n";

    $p->write("$exportDir/import.sqlite",$script);
    $p->write("$exportDir/import.sh",
        "rm -f $dbFile\n".
        "sqlite3 $dbFile <import.sqlite\n"
    );
    $p->chmod("$exportDir/import.sh",0775);

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
