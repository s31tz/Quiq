package Quiq::Html::Widget::CheckBox;
use base qw/Quiq::Html::Widget/;

use strict;
use warnings;
use v5.10.0;

our $VERSION = '1.154';

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Html::Widget::CheckBox - Checkbox

=head1 BASE CLASS

L<Quiq::Html::Widget>

=head1 ATTRIBUTES

=over 4

=item class => $class (Default: undef)

CSS Klasse.

=item disabled => $bool (Default: 0)

Keine Eingabe möglich.

=item hidden => $bool (Default: 0)

Nicht sichtbar.

=item id => $id (Default: undef)

CSS-Id.

=item label => $html (Default: '')

Label rechts neben der Checkbox.

=item name => $name (Default: undef)

Name, unter dem der Button kommuniziert wird.

=item onClick => $js (Default: undef)

OnClick-Handler.

=item option => $value (Default: undef)

Wert, der gesendet wird, wenn die CheckBox aktiviert ist.

=item style => $style (Default: undef)

CSS Definition (inline).

=item title => $str (Default: undef)

Tooltip-Text.

=item value => $value (Default: undef)

Aktueller Wert. Stimmt dieser mit dem Wert des Attributs option
überein, wird die Checkbox aktiviert.

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
        disabled => 0,
        hidden => 0,
        id => undef,
        label => '',
        name => undef,
        onClick => undef,
        option => undef,
        style => undef,
        title => undef,
        value => undef,
    );
    $self->set(@_);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 html() - Generiere HTML-Code

=head4 Synopsis

    $html = $e->html($h);
    $html = $class->html($h,@keyVal);

=cut

# -----------------------------------------------------------------------------

sub html {
    my $this = shift;
    my $h = shift;

    my $self = ref $this? $this: $this->new(@_);

    # Attribute

    my ($class,$disabled,$hidden,$id,$label,$name,$onClick,$option,$style,
        $title,$value) = $self->get(qw/class disabled hidden id label name
        onClick option style title value/);

    if ($hidden) {
        return '';
    }

    my $html .= $h->tag('input',
        -nl => 0,
        type => 'checkbox',
        id => $id,
        name => $name,
        class => $class,
        style => $style,
        disabled => $disabled,
        value => $option,
        checked => defined($value) && $value eq $option? 1: 0,
        title => $title,
        onclick => $onClick,
    );
    if ($label ne '') {
        $html .= $label;
    }
    $html .= "\n";

    return $html;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.154

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
