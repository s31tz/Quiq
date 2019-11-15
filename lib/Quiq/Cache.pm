package Quiq::Cache;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.165';

use Quiq::Digest;
use Quiq::Path;
use Quiq::Storable;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Cache - Cache Daten in Datei

=head1 BASE CLASS

L<Quiq::Hash>

=head1 SYNOPSIS

  use Quiq::Cache;
  
  my $c = Quiq::Cache->new($cacheDir,$duration,\@key)
      -inactive => $condition,
  );
  if ($c->isValid) {
      return $c->read; # liefere Datenstruktur aus Cache
  }
  
  # ... berechne Daten ...
  
  if ($c->isInvalid) {
      $c->write($ref); # schreibe Datenstuktur auf Cache
  }
  
  return $ref;

=head1 DESCRIPTION

Ein Objekt der Klasse verwaltet einen Cache. Der Cache ist ein Verzeichnis
(C<$cacheDir>) im Dateisystem. Eine Cachedatei speichert eine beliebige
Datenstruktur. Die Datenstruktur kann ein Objekt (d.h. geblesst) sein.
Es ist auch kein Problem, wenn die Datenstruktur zirkulär ist.
Zur Speicherung nutzt die Klasse das Modul C<Storable>.

Die Cachdatei ist $duration Sekunden gültig (valid). Danach ist sie
ungültig (invalid), die Datenstruktur wird neu berechnet und
auf die Cachedatei geschrieben.

Kein Caching findet statt, d.h. es wird weder aus dem Cache gelesen
noch wird dieser geschrieben, wenn C<$condition> wahr ist.

Das Array @key besteht aus ein oder mehr einzelnen Werten, die zusammen
den Schlüssel für die Cachdatei bilden. Der interne Schüssel ist der
MD5-Hash über diesen Werten. Dieser bildet den Namen der Cachedatei.

=head1 EXAMPLE

Cachen einer HTML-Seite, die von einem einzigen Parameter $day abhängt:

  my $day = $self->param('day') // $today;
  
  my $c = Quiq::Cache->new('~/var/html-cache',43_200,[$day],
      -inactive => $day eq $today? 1: 0,
  );
  if ($c->isValid) {
      $self->render(text=>${$c->read});
      return;
  }
  
  my $html = ...
  
  if ($c->isInvalid) {
      $c->write(\$html);
  }

=head1 METHODS

=head2 Klassenmethoden

=head3 new() - Konstruktor

=head4 Synopsis

  $c = $class->new($dir,$duration,\@key,@opt);

=head4 Arguments

=over 4

=item $dir

Verzeichnis, in dem die Cachdatei gespeichert wird.

=item $duration

Zeitdauer in Sekunden, die die Cachdatei ab ihrer Erzeugung
gültig ist.

=item @key

Die zur Bildung des Hash herangezogenen Werte.

=back

=head4 Options

=over 4

=item -inactive => $bool (default: 0)

Wenn wahr, ist der Cache inaktiv, d.h. beide Testmethoden
$c->L<isValid|"isValid() - Prüfe, ob Cache-Inhalt gelesen werden kann">() und $c->L<isInvalid|"isInvalid() - Prüfe, ob Cache-Datei geschrieben werden muss">() liefern I<false>.

=item -prefix => $str (Default: '')

Prefix, der der Cachedatei vorangestellt wird.

=back

=head4 Returns

Cache-Objekt

=head4 Description

Instantiiere ein Cache-Objekt und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my ($class,$dir,$duration,$keyA) = splice @_,0,4;

    # Optionen und Argumente

    my $inactive = 0;
    my $prefix = '';

    $class->parameters(\@_,
        -inactive => \$inactive,
        -prefix => \$prefix,
    );

    return $class->SUPER::new(
         duration => $duration,
         file => sprintf('%s/%s%s',$dir,$prefix,Quiq::Digest->md5(@$keyA)),
         inactive => $inactive,
    );
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 isValid() - Prüfe, ob Cache-Inhalt gelesen werden kann

=head4 Synopsis

  $bool = $c->isValid;

=head4 Returns

Boolean

=head4 Description

Prüfe, ob die Cachdatei gelesen werden kann. Dies ist der Fall,
wenn der Cache aktiv ist und die Datei existiert und entweder ewig
gültig ist ($duration == 0) oder seit dem letzten Schreiben weniger
als $duration Sekunden vergangen sind.

=cut

# -----------------------------------------------------------------------------

sub isValid {
    my $self = shift;

    if ($self->{'inactive'}) {
        # Wenn der Cache inaktiv ist, liefern wir immer 0
        return 0;
    }

    my ($file,$duration) = @$self{qw/file duration/};
    my $p = Quiq::Path->new;

    return $p->exists($file) && ($duration == 0 || $p->age($file) < $duration);
}

# -----------------------------------------------------------------------------

=head3 isInvalid() - Prüfe, ob Cache-Datei geschrieben werden muss

=head4 Synopsis

  $bool = $c->isInvalid;

=head4 Returns

Boolean

=head4 Description

Prüfe, ob die Cachdatei geschrieben werden muss. Dies ist der Fall,
wenn der Cache aktiv ist und die Cachdatei nicht .

=cut

# -----------------------------------------------------------------------------

sub isInvalid {
    my $self = shift;

    if ($self->{'inactive'}) {
        # Wenn der Cache inaktiv ist, liefern wir immer 0
        return 0;
    }

    return !$self->isValid;
}

# -----------------------------------------------------------------------------

=head3 read() - Lies Daten aus Cachdatei

=head4 Synopsis

  $ref = $c->read;

=head4 Returns

Referenz auf Datenstruktur

=head4 Description

Lies den Inhalt aus der Cachdatei

=cut

# -----------------------------------------------------------------------------

sub read {
    my $self = shift;

    if ($self->{'inactive'}) {
        $self->throw;
    }

    return Quiq::Storable->thaw(Quiq::Path->read($self->{'file'}));
}

# -----------------------------------------------------------------------------

=head3 write() - Schreibe Daten auf Cachdatei

=head4 Synopsis

  $c->write($ref);

=head4 Arguments

=over 4

=item $ref

Referenz auf Datenstruktur.

=back

=head4 Description

Schreibe Datenstruktur $ref auf die Cachedatei.

=cut

# -----------------------------------------------------------------------------

sub write {
    my ($self,$ref) = @_;

    if ($self->{'inactive'}) {
        $self->throw;
    }

    my $file = $self->{'file'};
    my $data = Quiq::Storable->freeze($ref);
    Quiq::Path->write($file,$data);

    return;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.165

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
