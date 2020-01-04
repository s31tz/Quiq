package Quiq::PlotlyJs::Reference;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.169';

use Quiq::Path;
use Quiq::Hash;
use HTML::TreeBuilder ();
use Quiq::Html::Page;
use Quiq::Html::List;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::PlotlyJs::Reference - Erzeuge Plotly.js Reference Manual

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
    # my $hRoot = HTML::TreeBuilder->new_from_url($url)->elementify;

    my $file = Quiq::Path->expandTilde('~/tmp/plotlyjs-reference.html');
    my $hRoot = HTML::TreeBuilder->new_from_file($file)->elementify;

    my $i = 0;
    my @sections;
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
            attributeA => $class->attributes($hSec),
        );
    }

    # Abschnitt Layout an den Anfang
    unshift @sections,pop @sections;

    return $class->SUPER::new(
        title => 'Plotly.js Reference',
        sectionA => \@sections,
    );
}

# -----------------------------------------------------------------------------

=head2 HTML-Repräsentation

=head3 asHtml() - Erzeuge HTML-Repräsentation

=head4 Synopsis

  $html = $obj->asHtml($h);

=head4 Arguments

=over 4

=item $h

Quiq::Html::Tag Objekt.

=back

=head4 Options

=over 4

=item -document => $bool (Default: 0)

Erzeuge ein vollständiges HTML-Dokument.

=back

=head4 Returns

HTML-Code (String)

=head4 Description

Liefere die plotly.js Dokumentation in HTML.

=cut

# -----------------------------------------------------------------------------

sub asHtml {
    my ($self,$h) = splice @_,0,2;

    # Optionen

    my $document = 0;

    $self->parameters(\@_,
        document => \$document,
    );

    my $html = '';
    my $i = 0;
    for my $sec (@{$self->get('sectionA')}) {
        $html .= $h->tag('details',
            '-',
            $h->tag('summary',
                "$i. ".$sec->get('title')
            ),
            $h->tag('div',
                style => 'margin-left: 22px',
                '-',
                $h->tag('p',
                    -text => 1,
                    $sec->get('description')
                ),
                $h->tag('p',
                    $self->attributesAsHtml($sec,$h)
                ),
            ),
        );
        $i++;
    }

    if ($document) {
        my $title = $self->get('title');
        $html = Quiq::Html::Page->html($h,
            title => $title,
            styleSheet => q~
                body {
                    font-family: sans-serif;
                    font-size: 11pt;
                }
            ~,
            body => $h->cat(
                $h->tag('h1',$title),
                $html,
            ),
        );
    }

    return $html;
}

# -----------------------------------------------------------------------------

=head3 attributesAsHtml() - HTML-Repräsentation der Attribute

=head4 Synopsis

  $html = $self->attributesAsHtml($h);

=head4 Returns

Attribut-Knoten (Object)

=cut

# -----------------------------------------------------------------------------

sub attributesAsHtml {
    my ($self,$node,$h) = @_;

    my $html = '';

    my @attributes = sort {$a->get('name') cmp $b->get('name')}
        @{$node->get('attributeA')};

    for my $att (@attributes) {
        $html .= $h->tag('details',
            '-',
            $h->tag('summary',
                $att->get('name')
            ),
            $h->tag('div',
                style => 'margin-left: 22px',
                '-',
                Quiq::Html::List->html($h,
                    type => 'description',
                    isText => 1,
                    items => [
                        Parent => $att->get('parent'),
                        Type => $att->get('type'),
                        Default => $att->get('default'),
                    ],
                ),
                $h->tag('p',
                    -text => 1,
                    $att->get('description')
                ),
            ),
        );
        $html .= $h->tag('div',
            style => 'margin-left: 22px',
            $self->attributesAsHtml($att,$h)
        );
    }

    return $html;
}

# -----------------------------------------------------------------------------

=head2 Hilfsmethoden

=head3 attributes() - Attribut-Knoten

=head4 Synopsis

  $node = $class->attributes($h);

=head4 Returns

Attribut-Knoten (Object)

=cut

# -----------------------------------------------------------------------------

sub attributes {
    my ($class,$h) = @_;

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
                $class->throw;
            }

            # Type

            my $type;
            if ($html =~ /Type:/) {
                ($type) = $html =~ m{Type:</em>(.*?)(<br|<p>|<ul>|$)}s;
                if (!defined $type) {
                    # Wenn Angabe Type: vorkommt, müssen wir sie
                    # extrahieren können
                    $class->throw(
                         'PLOTYJS-00001: Can\'t extract Type: from HTML',
                         Html => $html,
                    );
                }
                $type =~ s/^\s+//;
                $type =~ s/\s+$//;
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
                    $class->throw(
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
                attributeA => $class->attributes($li),
            );
        }
    }

    return \@attributes;
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
