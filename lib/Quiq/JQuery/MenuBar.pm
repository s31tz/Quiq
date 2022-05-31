# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::JQuery::MenuBar - Erzeuge den Code einer jQuery Menüleiste

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Die Klasse erzeugt den HTML-Code einer jQuery UI menüleiste.
Dem Konstruktor werden die Menüpunktdefintionen mit dem Attribut
C<items> übergeben. Die Methode L<html|"html() - Generiere HTML">() generiert den HTML-Code.

=head1 ATTRIBUTES

=over 4

=item id => $id (Default: 'menubar')

(String) CSS-Id der Menüleiste

=item items => \@arr (Default: [])

(Array of Hashes) Definition der Menüpunkte.

=back

=cut

# -----------------------------------------------------------------------------

package Quiq::JQuery::MenuBar;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.203';

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $obj = $class->new(@keyVal);

=head4 Description

Instantiiere ein Menüleisten-Objekt und liefere eine
Referenz auf dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @keyVal

    my $self = $class->SUPER::new(
        id => 'menubar',
        items => [],
    );
    $self->set(@_);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 html() - Generiere HTML

=head4 Synopsis

  $html = $obj->html($h);
  $html = $class->html($h,@keyVal);

=head4 Description

Generiere den HTML-Code eines Menüleisten-Objekts und liefere
diesen zurück. Als Klassenmethode gerufen, wird das Objekt intern
mit den Attributen @keyVal instantiiert.

=cut

# -----------------------------------------------------------------------------

sub html {
    my $this = shift;
    my $h = shift;

    my $self = ref $this? $this: $this->new(@_);

    my ($id,$itemA) = $self->get(qw/id items/);

    if (!@$itemA) {
        return '';
    }

    # Menüstruktur rekursiv erzeugen

    my $sub;
    $sub = sub {
        my $itemA = shift;
        my $i = shift // 1;

        my $html = '';
        for my $itm (@$itemA) {
            my $name = $itm->{'name'};
            my $url = $itm->{'url'};
            my $icon = $itm->{'icon'};
            if ($icon) {
                $name = $h->tag('span',
                    -ignoreIfNull => 0,
                    class => "ui-icon $icon"
                ).$name;
            }
            my $tag = $url? $h->tag('a',href=>$url,$name): $name;
            if (my $itemA = $itm->{'childs'}) {
                $tag .= "\n".$sub->($itemA,$i+1);
            }
            $html .= $h->tag('li',$tag);
        }
        $html = $h->tag('ul',$i == 1? (id=>$id): (),$html);

        return $html;
    };

    return $sub->($itemA);
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.203

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2022 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
