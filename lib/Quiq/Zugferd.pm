# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Zugferd - Generiere das XML von ZUGFeRD-Rechnungen

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Diese Klasse dient der Generung des XMLs von E-Rechnungen nach dem
ZUGFeRD/Factur-X-Standard. Sie kapselt die Profile des Standards,
sowohl die XSD-Dateien (XML-Schemadefinition) als auch fertige
Templates.

Die Generierung eines Rechnungs-XMLs erfolgt durch Einsetzung der
Rechnungswerte in das Template des jeweiligen Profils.

=head1 EXAMPLES

Zeige das Template des Profils EN16931:

  $ perl -MQuiq::Zugferd -E 'print Quiq::Zugferd->new("en16931")->template'

=cut

# -----------------------------------------------------------------------------

package Quiq::Zugferd;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.226';

use Quiq::PerlModule;
use Quiq::Path;
use XML::Compile::Schema ();
use XML::LibXML ();
use XML::Compile::Util ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $zug = $class->new($profile,%options);

=head4 Arguments

=over 4

=item $profile

Name des ZUGFeRD-Profils. Es existieren die ZUGFeRD-Profile: C<minimum>,
C<basicwl>, C<basic>, C<en16931>, C<extended>.

=back

=head4 Options

=over 4

=item -version => $version (Default: '2.3.2')

Die ZUGFeRD-Version.

=back

=head4 Returns

Object

=head4 Description

Instantiiere ein ZUGFeRD-Objekt des Profils $profile und der
ZUGFeRD-Version $version und liefere dieses zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;

    # Optionen und Argumente

    my $version = '2.3.2';

    my $argA = $class->parameters(1,1,\@_,
        -version => \$version,
    );
    my $profile = shift @$argA;

    my $mod = Quiq::PerlModule->new('Quiq::Zugferd');
    my $modDir = $mod->loadPath;
    $modDir =~ s/\.pm//;

    my $zugferdDir = "$modDir/$version/profile/$profile";
    my $xmlTemplateFile = "$zugferdDir/template.xml";
    my $xsdDir = $zugferdDir;

    my $p = Quiq::Path->new;

    if (!$p->exists($xsdDir)) {
        $class->throw(
            'ZUGFERD-00099: XSD directory does not exist',
            Dir => $xsdDir,
        );
    }
    if (!$p->exists($xmlTemplateFile)) {
        $class->throw(
            'ZUGFERD-00099: XML template does not exist',
            Template => $xmlTemplateFile,
        );
    }

    # Ermittele .xsd-Dateien
    my @xsdFiles = Quiq::Path->find($xsdDir,-pattern=>'\.xsd$');

    # Instantiiere Schema-Objekt

    my $sch = XML::Compile::Schema->new;
    for my $file (@xsdFiles) {
        $sch->importDefinitions($file);
    }

    # Lies Template-Datei
    my $template = $p->read($xmlTemplateFile);

    # Entferne Zeilen mit # am Anfang
    $template =~ s|^\s*#.*\n||gm;

    # Ermittele den Typ des Wurzelelements

    my $doc = XML::LibXML->load_xml(
        string => $template,
        no_blanks => 1,
    );
    my $top = $doc->documentElement;
    my $rootType = XML::Compile::Util::type_of_node($top);

    return bless {
        sch => $sch,
        rootType => $rootType,
        template => $template,
        version => $version,
    },$class;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 template() - Liefere das ZUGFeRD-Template

=head4 Synopsis

  $xml = $zug->template;

=head4 Returns

(String) XML

=cut

# -----------------------------------------------------------------------------

# Accessor-Methode

# -----------------------------------------------------------------------------

=head1 VERSION

1.226

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2025 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
