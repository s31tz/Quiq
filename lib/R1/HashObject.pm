package R1::HashObject;
use base qw/R1::RestrictedHash/;

use strict;
use warnings;
use v5.10.0;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

R1::HashObject - Zugiffssicherer Hash mit generierten Akzessor-Methoden

=head1 BASE CLASS

L<R1::RestrictedHash>

=head1 DESCRIPTION

Die Klasse erweitert ihre Basisklasse um automatisch
generierte Akzessor-Methoden. D.h. für jede Komponente des Hash
wird bei Bedarf eine Methode erzeugt, durch die der Wert der
Komponente manipuliert werden kann. Dadurch ist es möglich, die
Manipulation von Attributen ohne Programmieraufwand nahtlos
in die Methodenschnittstelle einer Klasse zu integrieren.

Gegenüberstellung:

    Hash-Zugriff           get()/set()               Methoden-Zugriff
    --------------------   -----------------------   --------------------
    $name = $h->{'name'}   $name = $h->get('name')   $name = $h->name;
    $h->{'name'} = $name   $h->set(name=>$name)      $h->name($name)

In der letzten Spalte ("Methoden-Zugriff") steht die Syntax der
automatisch generierten Akzessor-Methoden.

Die Erzeugung einer Akzessor-Methode erfolgt (vom Aufrufer unbemerkt)
beim ersten Aufruf. Danach wird die Methode unmittelbar aufgerufen.

=head1 METHODS

=head2 Autoload-Methode

=head3 AUTOLOAD() - Erzeuge Akzessor-Methode

=head4 Synopsis

    $val = $h->AUTOLOAD;
    $val = $h->AUTOLOAD($val);

=head4 Description

Erzeuge eine Akzessor-Methode für eine Hash-Komponente. Die Methode
AUTOLOAD() wird für jede Hash-Komponente nur einmal aufgerufen.
Danach gehen alle Aufrufe für die Komponente direkt an die erzeugte
Akzessor-Methode.

=cut

# -----------------------------------------------------------------------------

sub AUTOLOAD {
    my $this = shift;
    # @_: Methodenargumente

    my ($key) = our $AUTOLOAD =~ /::(\w+)$/;
    return if $key !~ /[^A-Z]/;

    # Klassenmethoden generieren wir nicht

    if (!ref $this) {
        $this->throw(
            q~OBJ-00001: Methode existiert nicht~,
            Method=>$key,
        );
    }

    # Methode nur generieren, wenn Attribut existiert

    if (!exists $this->{$key}) {
        $this->throw(
            q~OBJ-00002: Objektattribut existiert nicht~,
            Attribute=>$key,
            Class=>ref($this)? ref($this): $this,
        );
    }

    # Attribut-Methode generieren. Da $self ein Restricted Hash ist,
    # brauchen wir die Existenz des Attributs nicht selbst prüfen.

    no strict 'refs';
    *{$AUTOLOAD} = sub {
        my $self = shift;
        # @_: $val

        if (@_) {
            $self->{$key} = shift;
        }

        return $self->{$key};
    };

    # Methode aufrufen
    return $this->$key(@_);
}

# -----------------------------------------------------------------------------

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=cut

# -----------------------------------------------------------------------------

1;

# eof
