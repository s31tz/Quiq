package Quiq::PlotlyJs::Reference;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.169';

use Quiq::Path;
use HTML::TreeBuilder ();
use Quiq::Hash;
use Quiq::Sdoc::Producer;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::PlotlyJs::Reference - Erzeuge Plotly.js Dokumentation

=head1 BASE CLASS

L<Quiq::Hash>

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $obj = $class->new;

=head4 Returns

Object

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;

    # my $url = 'https://plot.ly/javascript/reference/';
    my $file = Quiq::Path->expandTilde('~/tmp/plotlyjs-reference.html');

    return $class->SUPER::new(
        # root => HTML::TreeBuilder->new_from_url($url)->elementify,
        root => HTML::TreeBuilder->new_from_file($file)->elementify,
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 tree() - Dokumentbaum des PlotlyJs Referenz-Manuals

=head4 Synopsis

  $tree = $obj->tree;

=head4 Returns

Wurzelknoten des Dokumentbaums (Object)

=head4 Description

Überführe das PlotlyJs Referenz-Manual in HTML in einen Dokumentbaum
mit den enthaltenen Informationen und liefere eine Referenz auf
dessen Wurzelknoten zurück.

=cut

# -----------------------------------------------------------------------------

sub tree {
    my $self = shift;

    my $i = 0;
    my @sections;
    my $hRoot = $self->root;
    for my $hSec ($hRoot->look_down(_tag=>'div',class=>'row')) {
        if (!$i++) {
            # Die Einleitung des Reference-Dokuments übergehen wir
            next;
        }

        my $title = ucfirst $hSec->look_down(_tag=>'h4')->as_text;
        $title =~ s/^\s+//;
        $title =~ s/\s+$//;

        my $descr;
        my $e = $hSec->look_down(_tag=>'div',class=>'description');
        if ($e) {
            $descr = $e->as_text;
        }

        push @sections,Quiq::Hash->new(
            title => $title,
            description => $descr,
            attributeA => $self->attributes($hSec),
        );
    }

    return Quiq::Hash->new(
        title => 'Plotly.js Reference',
        sectionA => \@sections,
    );
}

# -----------------------------------------------------------------------------

=head3 asSdoc() - Wandele die Dokumentation nach Sdoc

=head4 Synopsis

  $sdoc = $obj->asSdoc;

=head4 Returns

Sdoc-Code (String)

=head4 Description

Liefere die plotly.js Dokumentation in Sdoc.

=cut

# -----------------------------------------------------------------------------

sub asSdoc {
    my $self = shift;

    my $str = '';

    my $sdoc = Quiq::Sdoc::Producer->new(
        indentation => 2,
    );

    $str .= $sdoc->document(
        title => 'Plotly.js Reference',
        sectionNumberLevel => 6,
    );

    $str .= $sdoc->tableOfContents(
        maxLevel => 6,
    );

    my $i = 0;
    my $root = $self->root;
    for my $sec ($root->look_down(_tag=>'div',class=>'row')) {
        if (!$i++) {
            # Die Einleitung des Reference-Dokuments übergehen wir
            next;
        }
        my $title = ucfirst $sec->look_down(_tag=>'h4')->as_text;
        $title =~ s/^\s+//;
        $title =~ s/\s+$//;
        $str .= $sdoc->section(-1,$title);

        my $e = $sec->look_down(_tag=>'div',class=>'description');
        if ($e) {
            my $descr = $e->as_text;
            $str .= $sdoc->paragraph($descr);
        }

        $str .= $self->attributesAsSdoc($sdoc,1,$sec);
    }

    return $str;
}

# -----------------------------------------------------------------------------

=head2 Hilfsmethoden

=head3 attributes() - Attribut-Knoten

=head4 Synopsis

  $node = $obj->attributes($h);

=head4 Returns

Attribut-Knoten (Object)

=cut

# -----------------------------------------------------------------------------

sub attributes {
    my ($self,$h) = @_;

    my @attributes;

    my $ul = $h->look_down(_tag=>'ul');
    if ($ul) {
        for my $li ($ul->content_list) {
            # Name

            my $name = $li->look_down(class=>'attribute-name')->as_text;
            $name =~ s/^\s+//;
            $name =~ s/\s+$//;

            my $html = $li->as_HTML;

            # Parent

            my ($parent) = $html =~ m|Parent:.*?<code>(.*?)</code>|;
            if (!defined $parent) {
                # Angabe Parent: erwarten wir immer
                $self->throw;
            }

            # Type

            my $type;
            if ($html =~ /Type:/) {
                ($type) = $html =~ m{Type:</em>(.*?)(<br|<p>|<ul>|$)}s;
                if (!defined $type) {
                    # Wenn Angabe Type: vorkommt, müssen wir sie
                    # extrahieren können
                    $self->throw(
                         'PLOTYJS-00001: Can\'t extract Type: from HTML',
                         Html => $html,
                    );
                }
                $type =~ s|</?code>||g;
                $type =~ s|&quot;|"|g;
            }

            # Default

            my $default;
            if ($html =~ /Default:/) {
                ($default) = $html =~ m|Default:.*?<code>(.*?)</code>|;
                if (!defined $default) {
                    # Wenn Angabe Default: vorkommt, müssen wir sie
                    # extrahieren können
                    $self->throw(
                         'PLOTYJS-00001: Can\'t extract Default: from HTML',
                         Html => $html,
                    );
                }
                $default =~ s|</?code>||g;
                $default =~ s|&quot;|"|g;
            }

            # Description

            my $descr;
            my $p = $li->look_down(_tag=>'p');
            if ($p) {
                $descr = $p->as_text;
                $descr =~ s|M~|\\M~|g;
            }

            push @attributes,Quiq::Hash->new(
                name => $name,
                parent => $parent,
                type => $type,
                default => $default,
                description => $descr,
                attributeA => $self->attributes($li),
            );
        }
    }

    return \@attributes;
}

# -----------------------------------------------------------------------------

=head3 attributesAsSdoc() - Beschreibung der Attribute

=head4 Synopsis

  $sdoc = $obj->attributesAsSdoc($e);

=head4 Returns

Sdoc-Code (String)

=cut

# -----------------------------------------------------------------------------

sub attributesAsSdoc {
    my ($self,$sdoc,$level,$e) = @_;

    my $str = '';

    my $ul = $e->look_down(_tag=>'ul');
    if ($ul) {
        for my $li ($ul->content_list) {
            my $attribute = $li->look_down(class=>'attribute-name')->as_text;
            $str .= $sdoc->section($level,$attribute);

            my $html = $sdoc->paragraph($li->as_HTML);

            my @arr;

            # Parent:

            my ($parent) = $html =~ m|Parent:.*?<code>(.*?)</code>|;
            if (!defined $parent) {
                # Die Angabe Parent: gibt es immer
                $self->throw;
            }
            push @arr,"Parent:"=>$parent;

            # Type:

            if ($html =~ /Type:/) {
                my ($type) = $html =~ m{Type:</em>(.*?)(<br|<p>|<ul>|$)}s;
                if (!defined $type) {
                    # Wenn Angabe Type: vorkommt, müssen wir sie
                    # extrahieren können
                    $self->throw(
                         'PLOTYJS-00001: Can\'t extract Type: from HTML',
                         Html => $html,
                    );
                }
                $type =~ s|</?code>||g;
                $type =~ s|&quot;|"|g;
                push @arr,"Type:"=>$type;
            }

            # Default:

            if ($html =~ /Default:/) {
                my ($default) = $html =~ m|Default:.*?<code>(.*?)</code>|;
                if (!defined $default) {
                    # Wenn Angabe Default: vorkommt, müssen wir sie
                    # extrahieren können
                    $self->throw(
                         'PLOTYJS-00001: Can\'t extract Default: from HTML',
                         Html => $html,
                    );
                }
                $default =~ s|</?code>||g;
                $default =~ s|&quot;|"|g;
                push @arr,"Default:"=>$default;
            }

            $str .= $sdoc->definitionList(\@arr);

            # Description

            my $p = $li->look_down(_tag=>'p');
            if ($p) {
                my $descr = $p->as_text;
                $descr =~ s|M~|\\M~|g;
                $str .= $sdoc->paragraph($descr);
            }

            $str .= $self->attributesAsSdoc($sdoc,$level+1,$li);
        }
    }

    return $str;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.169

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
