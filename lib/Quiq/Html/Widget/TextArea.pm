package Quiq::Html::Widget::TextArea;
use base qw/Quiq::Html::Widget/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.171';

use Quiq::Html::Tag;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Html::Widget::TextArea - Mehrzeiliges Textfeld

=head1 BASE CLASS

L<Quiq::Html::Widget>

=head1 ATTRIBUTES

=over 4

=item id => $id (Default: undef)

Id des Textfelds.

=item class => $class (Default: undef)

CSS Klasse des Textfelds.

=item disabled => $bool (Default: 0)

Widget kann nicht editiert werden.

=item hidden => $bool (Default: 0)

Widget ist (aktuell) unsichtbar.

=item cols => $n (Default: undef)

Sichtbare Breite des Texteingabefeldes in Zeichen.

=item name => $name (Default: undef)

Name des Feldes.

=item onKeyUp => $js (Default: undef)

JavaScript-Handler.

=item rows => $n (Default: undef)

Sichtbare Höhe des Texteingabefeldes in Zeilen.

=item style => $style (Default: undef)

CSS Definition (inline).

=item undefIf => $bool (Default: 0)

Wenn wahr, liefere C<undef> als Widget-Code.

=item value => $str (Default: undef)

Anfänglicher Wert des Felds.

=back

=head1 METHODS

=head2 Konstruktor

=head3 new() - Konstruktor

=head4 Synopsis

  $e = $class->new(@keyVal);

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @keyVal

    # Defaultwerte

    my $self = $class->SUPER::new(
        class => undef,
        cols => undef,
        disabled => 0,
        hidden => 0,
        id => undef,
        name => undef,
        onKeyUp => undef,
        rows => undef,
        style => undef,
        undefIf => 0,
        value => undef,
    );

    # Werte Konstruktoraufruf
    $self->set(@_);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 html() - Generiere HTML-Code

=head4 Synopsis

  $html = $e->html;
  $html = $class->html(@keyVal);

=cut

# -----------------------------------------------------------------------------

sub html {
    my $this = shift;

    my $self = ref $this? $this: $this->new(@_);

    # Attribute

    my ($class,$cols,$disabled,$id,$name,$onKeyUp,$rows,$style,$undefIf,
        $value) = $self->get(qw/class cols disabled id name onKeyUp rows
        style undefIf value/);

    # Generierung

    my $h = Quiq::Html::Tag->new;

    if ($undefIf) {
        return undef;
    }

    return $h->tag('textarea',
        id => $id,
        name => $name,
        class => $class,
        style => $style,
        disabled => $disabled,
        onkeyup => $onKeyUp,
        cols => $cols,
        rows => $rows,
        $value
    );    
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.171

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
