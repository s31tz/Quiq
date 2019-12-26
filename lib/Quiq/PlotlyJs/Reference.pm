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
    my $file = Quiq::Path->expandTilde('~/tmp/plotly-reference.html');

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

    print $sdoc->document(
        title => 'Plotly.js Reference',
    );

    my $i = 0;
    my $root = $self->root;
    for my $sec ($root->look_down(_tag=>'div',class=>'row')) {
        if (!$i++) {
            # Die Einleitung übergehen wir
            next;
        }
        my $title = ucfirst $sec->look_down(_tag=>'h4')->as_text;
        print $sdoc->section(1,$title);

        my $e = $sec->look_down(_tag=>'div',class=>'description');
        if ($e) {
            my $descr = $e->as_text;
            print $sdoc->paragraph($descr);
        }

        for my $li ($sec->look_down(_tag=>'ul')->content_list) {
            my $attribute = $li->look_down(class=>'attribute-name')->as_text;
            print $sdoc->section(2,$attribute);
        }
# last;
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
