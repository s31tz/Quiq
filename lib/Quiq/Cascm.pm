package Quiq::Cascm;
use base qw/Quiq::Hash/;

use strict;
use warnings;
use v5.10.0;

our $VERSION = 1.135;

use Quiq::Database::Row::Array;
use Quiq::Shell;
use Quiq::Path;
use Quiq::CommandLine;
use Quiq::TempFile;
use Quiq::Stopwatch;
use Quiq::Unindent;
use Quiq::AnsiColor;
use Quiq::Database::ResultSet::Array;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Cascm - Schnittstelle zu CA Harvest SCM

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Ein Objekt der Klasse stellt eine Schnittstelle zu einem
CA Harvest SCM Server zur Verfügung.

=head1 SEE ALSO

=over 2

=item *

L<https://docops.ca.com/ca-harvest-scm/13-0/en>

=back

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

    $scm = $class->new(@attVal);

=head4 Arguments

=over 4

=item @attVal

Liste von Attribut-Wert-Paaren.

=back

=head4 Returns

Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @attVal

    my $self = $class->SUPER::new(
        user => undef,                # -usr (deprecated)
        password => undef,            # -pw (deprecated)
        credentialsFile => undef,     # -eh
        hsqlCredentialsFile => undef, # -eh - für Datenbankabfragen
        broker => undef,              # -b
        projectContext => undef,      # -en
        viewPath => undef,            # -vp
        workspace => undef,           # -cp
        defaultState => undef,        # -st
        keepTempFiles => 0,
        verbose => 1,
        sh => undef,
    );
    $self->set(@_);

    my $sh = Quiq::Shell->new(
        log => $self->verbose,
        logDest => *STDERR,
        cmdPrefix => '> ',
        cmdAnsiColor => 'bold',
    );
    $self->set(sh=>$sh);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Externe Dateien

=head3 putFiles() - Füge Dateien zum Repository hinzu

=head4 Synopsis

    $scm->putFiles($package,$repoDir,@files);

=head4 Arguments

=over 4

=item $packge

Package, dem die Dateien innerhalb von CASCM zugeordnet werden.

=item $repoDir

Zielverzeichnis I<innerhalb> des Workspace, in das die Dateien
kopiert werden. Dies ist ein I<relativer> Pfad.

=item @files

Liste von Dateien I<außerhalb> des Workspace.

=back

=head4 Returns

nichts

=head4 Description

Kopiere die Dateien @files in das Workspace-Verzeichnis $repoDir
und checke sie anschließend ein, d.h. füge sie zum Repository hinzu.
Eine Datei, die im Workspace-Verzeichnis schon vorhanden ist, wird
zuvor ausgecheckt.

Mit dieser Methode ist es möglich, sowohl neue Dateien zum Workspace
hinzuzufügen als auch bereits existierende Dateien im Workspace
zu aktualisieren. Dies geschieht für den Aufrufer transparent, er
braucht sich um die Unterscheidung nicht zu kümmern.

=cut

# -----------------------------------------------------------------------------

sub putFiles {
    my ($self,$package,$repoDir,@files) = @_;

    my $workspace = $self->workspace;
    my $p = Quiq::Path->new;

    for my $srcFile (@files) {
        my (undef,$file) = $p->split($srcFile);
        my $repoFile = sprintf '%s/%s',$repoDir,$file;

        if (-e "$workspace/$repoFile") {
            # Die Workspace-Datei existiert bereits. Prüfe, ob Quelldatei
            # und die Workspace-Datei sich unterscheiden. Wenn nein, ist
            # nichts zu tun.

            if (!$p->different($srcFile,"$workspace/$repoFile")) {
                # Bei fehlender Differenz tun wir nichts
                next;
            }

            # Checke Repository-Datei aus
            $self->checkout($package,$repoFile);
        }

        # Kopiere externe Datei in den Workspace. Entweder ist
        # sie neu oder sie wurde zuvor ausgecheckt.

        $p->copy($srcFile,"$workspace/$repoFile",
            -overwrite => 1,
            -preserve => 1,
        );

        # Checke Workspace-Datei ins Repository ein
        $self->checkin($package,$repoFile);
    }

    return;
}

# -----------------------------------------------------------------------------

=head2 Workspace-Dateien

=head3 checkout() - Checke Repository-Dateien aus

=head4 Synopsis

    $scm->checkout($package,@repoFiles);

=head4 Arguments

=over 4

=item $package

Package, dem die ausgecheckte Datei (mit reservierter Version)
zugeordnet wird.

=item @repoFiles

Liste von Workspace-Dateien, die ausgecheckt werden.

=back

=head4 Returns

nichts

=head4 Description

Checke die Workspace-Dateien @repoFiles aus.

=cut

# -----------------------------------------------------------------------------

sub checkout {
    my ($self,$package,@repoFiles) = @_;

    # Checke Workspace-Dateien aus

    my $c = Quiq::CommandLine->new;
    for my $repoFile (@repoFiles) {
        $c->addArgument($repoFile);
    }
    $c->addOption(
        $self->credentialsOptions,
        -b => $self->broker,
        -en => $self->projectContext,
        -st => $self->defaultState,
        -vp => $self->viewPath,
        -cp => $self->workspace,
        -p => $package,
    );
    $c->addBoolOption(
        -up => 1,
        -r => 1,
    );

    $self->run('hco',$c);

    return;
}

# -----------------------------------------------------------------------------

=head3 checkin() - Checke Workspace-Datei ein

=head4 Synopsis

    $scm->checkin($package,$repoFile);

=head4 Arguments

=over 4

=item $package

Package, dem die neue Version der Datei zugeordnet wird.

=item $repoFile

Datei I<innerhalb> des Workspace. Der Dateipfad ist ein I<relativer> Pfad.

=back

=head4 Returns

nichts

=head4 Description

Checke die Workspace-Datei $repoFile ein, d.h. übertrage ihren Stand
als neue Version ins Repository und ordne diese dem Package $package zu.

=cut

# -----------------------------------------------------------------------------

sub checkin {
    my ($self,$package,$repoFile) = @_;

    # Checke Repository-Dateien ein

    my $c = Quiq::CommandLine->new;
    $c->addArgument($repoFile);
    $c->addOption(
        $self->credentialsOptions,
        -b => $self->broker,
        -en => $self->projectContext,
        -st => $self->defaultState,
        -vp => $self->viewPath,
        -cp => $self->workspace,
        -p => $package,
    );

    $self->run('hci',$c);

    return;
}

# -----------------------------------------------------------------------------

=head3 version() - Versionsnummer Repository-Datei

=head4 Synopsis

    $version = $scm->version($repoFile);

=head4 Arguments

=over 4

=item $repoFile

Repository-Datei

=back

=head4 Returns

Versionsnummer (String)

=cut

# -----------------------------------------------------------------------------

sub version {
    my ($self,$repoFile) = @_;

    my $output = $self->listVersion($repoFile);
    my ($version) = $output =~ /;(\d+)$/m;
    if (!defined $version) {
        $self->throw("Can't find version number");
    }

    return $version;
}

# -----------------------------------------------------------------------------

=head3 listVersion() - Versionsinformation zu Repository-Datei

=head4 Synopsis

    $info = $scm->listVersion($repoFile);

=head4 Arguments

=over 4

=item $repoFile

Der Pfad der Repository-Datei.

=back

=head4 Returns

Informations-Text (String)

=head4 Description

Ermittele die Versionsinformation über Datei $repoFile und liefere
diese zurück.

=cut

# -----------------------------------------------------------------------------

sub listVersion {
    my ($self,$repoFile) = @_;

    my ($dir,$file) = Quiq::Path->split($repoFile);
    my $viewPath = $self->viewPath;

    my $c = Quiq::CommandLine->new;
    $c->addArgument($file);
    $c->addOption(
        $self->credentialsOptions,
        -b => $self->broker,
        -en => $self->projectContext,
        -vp => $dir? "$viewPath/$dir": $viewPath,
        -st => $self->defaultState,
    );

    return $self->run('hlv',$c);
}

# -----------------------------------------------------------------------------

=head3 deleteVersion() - Lösche Repository-Datei

=head4 Synopsis

    $scm->deleteVersion($repoFile);

=head4 Arguments

=over 4

=item $repoFile

Der Pfad der zu löschenden Repository-Datei.

=back

=head4 Returns

Nichts

=cut

# -----------------------------------------------------------------------------

sub deleteVersion {
    my ($self,$repoFile) = @_;

    my ($dir,$file) = Quiq::Path->split($repoFile);
    my $viewPath = $self->viewPath;

    my $c = Quiq::CommandLine->new;
    $c->addArgument($file);
    $c->addOption(
        $self->credentialsOptions,
        -b => $self->broker,
        -en => $self->projectContext,
        -vp => $dir? "$viewPath/$dir": $viewPath,
        -st => $self->defaultState,
    );

    return $self->run('hdv',$c);
}

# -----------------------------------------------------------------------------

=head2 Packages

=head3 createPackage() - Erzeuge Package

=head4 Synopsis

    $scm->createPackage($package);

=head4 Arguments

=over 4

=item $packge

Name des Package, das erzeugt werden soll.

=back

=head4 Returns

nichts

=head4 Description

Erzeuge Package $package.

=cut

# -----------------------------------------------------------------------------

sub createPackage {
    my ($self,$package) = @_;

    # Erzeuge Package

    my $c = Quiq::CommandLine->new;
    $c->addArgument($package);
    $c->addOption(
        $self->credentialsOptions,
        -b => $self->broker,
        -en => $self->projectContext,
        -st => $self->defaultState,
    );

    $self->run('hcp',$c);

    return;
}

# -----------------------------------------------------------------------------

=head3 deletePackage() - Lösche Package

=head4 Synopsis

    $scm->deletePackage($package);

=head4 Arguments

=over 4

=item $packge

Name des Package, das gelöscht werden soll.

=back

=head4 Returns

nichts

=head4 Description

Lösche Package $package.

=cut

# -----------------------------------------------------------------------------

sub deletePackage {
    my ($self,$package) = @_;

    # Lösche Package

    # Anmerkung: Das Kommando hdlp kann auch mehrere Packages auf
    # einmal löschen. Es ist jedoch nicht gut, es so zu
    # nutzen, da dann nicht-existente Packages nicht bemängelt
    # werden, wenn mindestens ein Package existiert.

    my $c = Quiq::CommandLine->new;
    $c->addOption(
        $self->credentialsOptions,
        -b => $self->broker,
        -en => $self->projectContext,
        -pkgs => $package,
    );

    $self->run('hdlp',$c);

    return;
}

# -----------------------------------------------------------------------------

=head3 renamePackage() - Benenne Package um

=head4 Synopsis

    $scm->renamePackage($oldName,$newName);

=head4 Arguments

=over 4

=item $oldName

Bisheriger Name des Package.

=item $newName

Zukünftiger Name des Package.

=back

=head4 Returns

nichts

=head4 Description

Benenne Package $oldName in $newName um.

=cut

# -----------------------------------------------------------------------------

sub renamePackage {
    my ($self,$oldName,$newName) = @_;

    # Benenne Package um

    my $c = Quiq::CommandLine->new;
    $c->addOption(
        $self->credentialsOptions,
        -b => $self->broker,
        -en => $self->projectContext,
        -p => $oldName,
        -npn => $newName,
    );

    $self->run('hup',$c);

    return;
}

# -----------------------------------------------------------------------------

=head3 promotePackage() - Promote Package

=head4 Synopsis

    $scm->promotePackage($package,$state);

=head4 Arguments

=over 4

=item $packge

Package, das promotet werden soll.

=item $state

Stufe, auf dem sich das Package befindet.

=back

=head4 Returns

nichts

=head4 Description

promote Package $package, das sich auf Stufe $state befindet
(befinden muss) auf die darüberliegende Stufe. Befindet sich das
Package auf einer anderen Stufe, schlägt das Kommando fehl.

=cut

# -----------------------------------------------------------------------------

sub promotePackage {
    my ($self,$package,$state) = @_;

    # Promote Package

    my $c = Quiq::CommandLine->new;
    $c->addArgument($package);
    $c->addOption(
        $self->credentialsOptions,
        -b => $self->broker,
        -en => $self->projectContext,
        -st => $state,
    );

    $self->run('hpp',$c);

    return;
}

# -----------------------------------------------------------------------------

=head3 demotePackage() - Demote Package

=head4 Synopsis

    $scm->demotePackage($package,$state);

=head4 Arguments

=over 4

=item $package

Package, das demotet werden soll.

=item $state

Stufe, auf dem sich das Package befindet.

=back

=head4 Returns

nichts

=head4 Description

Demote Package $package, das sich auf Stufe $state befindet
(befinden muss) auf die darunterliegende Stufe. Befindet sich das
Package auf einer anderen Stufe, schlägt das Kommando fehl.

=cut

# -----------------------------------------------------------------------------

sub demotePackage {
    my ($self,$package,$state) = @_;

    # Demote Package

    my $c = Quiq::CommandLine->new;
    $c->addArgument($package);
    $c->addOption(
        $self->credentialsOptions,
        -b => $self->broker,
        -en => $self->projectContext,
        -st => $state,
    );

    $self->run('hdp',$c);

    return;
}

# -----------------------------------------------------------------------------

=head3 packageState() - Stufe des Pakets

=head4 Synopsis

    $state = $scm->packageState($package);

=head4 Arguments

=over 4

=item $package

Package.

=back

=head4 Returns

=over 4

=item $state

Stufe.

=back

=head4 Description

Liefere die Stufe $stage, auf der sich Package $package befindet.

=cut

# -----------------------------------------------------------------------------

sub packageState {
    my ($self,$package) = @_;

    my $projectContext = $self->projectContext;

    my $tab = $self->runSql("
        SELECT
            sta.statename
        FROM
            harPackage pkg
            JOIN harEnvironment env
                ON env.envobjid = pkg.envobjid
            JOIN harState sta
                ON sta.stateobjid = pkg.stateobjid
        WHERE
            env.environmentname = '$projectContext'
            AND pkg.packagename = '$package'
    ");

    return $tab->count? $tab->rows->[0]->[0]: '';
}

# -----------------------------------------------------------------------------

=head3 listPackages() - Liste aller Pakete

=head4 Synopsis

    $tab = $scm->listPackages;

=head4 Returns

=over 4

=item @packages | $packageA

Liste aller Packages (Array of Arrays). Im Skalarkontext eine Referenz
auf die Liste.

=back

=head4 Description

Liefere die Liste aller Packages.

=cut

# -----------------------------------------------------------------------------

sub listPackages {
    my $self = shift;

    my $projectContext = $self->projectContext;

    return $self->runSql("
        SELECT
            pkg.packagename
            , sta.statename
        FROM
            harPackage pkg
            JOIN harEnvironment env
                ON pkg.envobjid = env.envobjid
            JOIN harState sta
                ON pkg.stateobjid = sta.stateobjid
        WHERE
            env.environmentname = '$projectContext'
        ORDER BY
            1
    ");
}

# -----------------------------------------------------------------------------

=head3 findItem() - Zeige Information über Item an

=head4 Synopsis

    $tab = $scm->findItem($namePattern);

=head4 Arguments

=over 4

=item $namePattern

Name des Item (File oder Directory), SQL-Wildcards sind erlaubt.

=back

=head4 Returns

=over 4

=item $tab

Ergebnismengen-Objekt.

=back

=cut

# -----------------------------------------------------------------------------

sub findItem {
    my ($self,$namePattern) = @_;

    my $projectContext = $self->projectContext;

    return $self->runSql("
        SELECT
            itm.itemobjid AS id
            , par.itemname AS parent
            , itm.itemname AS item
            , ver.mappedversion AS version
            , ver.versiondataobjid
            , pkg.packagename AS package
            , sta.statename AS state
        FROM
            haritems itm
            JOIN harversions ver
                ON ver.itemobjid = itm.itemobjid
            JOIN harpackage pkg
                ON pkg.packageobjid = ver.packageobjid
            JOIN harenvironment env
                ON env.envobjid = pkg.envobjid
            JOIN harstate sta
                ON sta.stateobjid = pkg.stateobjid
            JOIN haritems par
                ON par.itemobjid = itm.parentobjid
        WHERE
            env.environmentname = '$projectContext'
            AND itm.itemname LIKE '$namePattern'
        ORDER BY
            itm.itemobjid
            , TO_NUMBER(ver.mappedversion)
    ");
}

# -----------------------------------------------------------------------------

=head2 Workspace

=head3 sync() - Synchronisiere Workspace mit Repository

=head4 Synopsis

    $scm->sync;

=head4 Description

Bringe den Workspace auf den Stand des Repository.

=cut

# -----------------------------------------------------------------------------

sub sync {
    my $self = shift;

    my $c = Quiq::CommandLine->new;
    $c->addOption(
        $self->credentialsOptions,
        -b => $self->broker,
        -en => $self->projectContext,
        -vp => $self->viewPath,
        -cp => $self->workspace,
        -st => $self->defaultState,
    );

    my $output = $self->run('hsync',$c);
    $output =~ s/^.*No need.*\n//gm;
    $self->writeOutput($output);

    return;
}

# -----------------------------------------------------------------------------

=head2 Database

=head3 sql() - Führe SQL aus

=head4 Synopsis

    $tab = $scm->sql($file);
    $tab = $scm->sql($sql);

=cut

# -----------------------------------------------------------------------------

sub sql {
    my ($self,$arg) = @_;

    my $projectContext = $self->projectContext;

    my $sqlFile;
    if ($arg !~ /\s/) {
        $sqlFile = $arg;
    }
    else {
        $sqlFile = Quiq::TempFile->new(-unlink=>!$self->keepTempFiles);
        Quiq::Path->write($sqlFile,$arg,-unindent=>1);
    }

    my $c = Quiq::CommandLine->new;
    $c->addOption(
        $self->credentialsOptions('hsql'),
        -b => $self->broker,
        -f => $sqlFile,
    );
    $c->addBoolOption(
        -t => 1,  # tabellarische Ausgabe
    );

    return $self->run('hsql',$c);
}

# -----------------------------------------------------------------------------

=head2 Privat

=head3 credentialsOptions() - Liste der Credential-Optionen

=head4 Synopsis

    @arr = $scm->credentialsOptions;

=cut

# -----------------------------------------------------------------------------

sub credentialsOptions {
    my $self = shift;
    my $cmd = shift // '';

    my $credentialsFile;
    if ($cmd eq 'hsql') {
        $credentialsFile = $self->get("${cmd}CredentialsFile");
    }
    $credentialsFile ||= $self->credentialsFile;
    if ($credentialsFile) {
        return (-eh=>$credentialsFile);
    }

    return $credentialsFile? (-eh=>$credentialsFile):
        (-usr=>$self->user,-pw=>$self->password);
}

# -----------------------------------------------------------------------------

=head3 run() - Führe CA Harvest SCM Kommando aus

=head4 Synopsis

    $str | $tab = $scm->run($scmCmd,$c);

=head4 Description

Führe das CA Harvest SCM Kommando $scmCmd mit den Optionen des
Kommandozeilenobjekts $c aus und liefere die Ausgabe des
Kommandos zurück.

=cut

# -----------------------------------------------------------------------------

sub run {
    my ($self,$scmCmd,$c) = @_;

    my $stw = Quiq::Stopwatch->new;

    # Output-Datei zu den Optionen hinzufügen

    my $outputFile = Quiq::TempFile->new(-unlink=>!$self->keepTempFiles);
    $c->addOption(-o=>$outputFile);

    # Kommando ausführen. Das Kommando schreibt Fehlermeldungen nach
    # stdout (!), daher leiten wir stdout in die Output-Datei um.

    my $cmd = sprintf '%s %s >>%s',$scmCmd,$c->command,$outputFile;
    my $r = $self->sh->exec($cmd,-sloppy=>1);
    my $output = Quiq::Path->read($outputFile);
    if ($r) {
        $self->throw(
            q~CASCM-00001: Command failed~,
            Command => $cmd,
            Output => $output,
        );
    }

    # Wir liefern den Inhalt der Output-Datei zurück

    if ($scmCmd ne 'hsql') {
        $output .= sprintf "---\n%.2fs\n",$stw->elapsed;
    }

    return $output;
}

# -----------------------------------------------------------------------------

=head3 runSql() - Führe SQL-Statement aus

=head4 Synopsis

    $tab = $scm->runSql($sql);

=cut

# -----------------------------------------------------------------------------

sub runSql {
    my ($self,$sql) = @_;

    my $stw = Quiq::Stopwatch->new;

    $sql = Quiq::Unindent->trimNl($sql);
    if ($self->verbose) {
        my $a = Quiq::AnsiColor->new;
        (my $sql = "$sql\n") =~ s/^(.*)/'> '.$a->str('bold',$1)/meg;
        warn $sql;
    }    

    my $sqlFile = Quiq::TempFile->new(-unlink=>!$self->keepTempFiles);
    Quiq::Path->write($sqlFile,$sql);

    my $c = Quiq::CommandLine->new;
    $c->addOption(
        $self->credentialsOptions('hsql'),
        -b => $self->broker,
        -f => $sqlFile,
    );
    $c->addBoolOption(
        -t => 1,  # tabellarische Ausgabe
    );

    my $output = $self->run('hsql',$c);

    # Wir liefern ein Objekt mit Titel und Zeilenobjekten zurück
    # <NL> und <TAB> ersetzen wir in den Daten durch \n bzw. \t.

    my @rows = map {s/<NL>/\n/g; $_} split /\n/,$output;
    my @titles = map {lc} split /\t/,shift @rows;

    my $rowClass = 'Quiq::Database::Row::Array';
    my $width = @titles;

    for my $row (@rows) {
        $row = $rowClass->new(
            [map {s/<TAB>/\t/g; $_} split /\t/,$row,$width]);
    }

    return Quiq::Database::ResultSet::Array->new($rowClass,\@titles,\@rows,
        execTime => $stw->elapsed,
    );
}

# -----------------------------------------------------------------------------

=head3 writeOutput() - Schreibe Kommando-Ausgabe

=head4 Synopsis

    $scm->writeOutput($output);

=cut

# -----------------------------------------------------------------------------

sub writeOutput {
    my ($self,$output) = @_;

    if ($self->verbose) {
        $output =~ s/^/| /mg;
        warn $output;
    }

    return;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.135

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
