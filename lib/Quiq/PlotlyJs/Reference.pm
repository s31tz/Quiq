package Quiq::PlotlyJs::Reference;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.169';

use Quiq::Path;
use HTML::TreeBuilder ();
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
        sectionNumberLevel => 4,
    );

    $str .= $sdoc->tableOfContents(
        maxLevel => 4,
    );

    my $i = 0;
    my $root = $self->root;
    for my $sec ($root->look_down(_tag=>'div',class=>'row')) {
        if (!$i++) {
            # Die Einleitung übergehen wir
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

        my $li = $sec->look_down(_tag=>'ul')->content_list;
        $str .= $self->attributes($sdoc,0,$sec);
last;
    }

    return $str;
}

# -----------------------------------------------------------------------------

=head2 Hilfsmethoden

=head3 attributes() - Beschreibung der Attribute

=head4 Synopsis

  $sdoc = $obj->attributes($e);

=head4 Returns

Sdoc-Code (String)

=cut

# -----------------------------------------------------------------------------

sub attributes {
    my ($self,$sdoc,$level,$e) = @_;

    my $str = '';

    my $ul = $e->look_down(_tag=>'ul');
    if ($ul) {
        for my $li ($ul->content_list) {
            my $attribute = $li->look_down(class=>'attribute-name')->as_text;
            $str .= $sdoc->section($level,$attribute);

            my $html = $sdoc->paragraph($li->as_HTML);

            my ($parent) = $html =~ m|Parent:.*?<code>(.*?)</code>|s;
            $str .= $sdoc->paragraph("Parent: $parent");

            my $p = $li->look_down(_tag=>'p');
            if ($p) {
                $str .= $sdoc->paragraph($p->as_text);
            }

            $str .= $self->attributes($sdoc,$level+1,$li);
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

Copyright (C) 2019 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
