# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

R1::Misc - Klassenbibliothek

=head1 SYNOPSIS

  #!/usr/bin/env perl
  
  use strict;
  use warnings;
  
  use R1::Misc;
  
  # und dann Methoden der Klassenbibliothek verwenden

=head1 DESCRIPTION

Das Modul macht die Klassenbibliothek innerhalb eines Programms
verfügbar, ohne dass weitere Module der Klassenbibliothek vom Programm
per use explizit geladen werden müssen. Klassen (und ihre Basisklassen)
werden mit ihrem ersten Methodenaufruf automatisch geladen.

=cut

# -----------------------------------------------------------------------------

package R1::Misc;

use v5.10;
use strict;
use warnings;
use utf8;

use Quiq::Object;
use R1::Misc;
use R1::Hash1;

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Zeichenketten

=head3 strNewline() - Liefere Zeilentrenner-Zeichenkette

=head4 Synopsis

  $nlStr = $class->strNewline($nlName);

=head4 Description

Liefere die Zeilentrenner-Zeichenkette zur Zeilentrenner-Bezeichnung
('CR', 'LF' oder 'CRLF').

=cut

# -----------------------------------------------------------------------------

sub strNewline {
    my ($class,$nlName) = @_;

    if ($nlName eq 'LF') { return "\cJ" }
    elsif ($nlName eq 'CRLF') { return "\cM\cJ" }
    elsif ($nlName eq 'CR') { return "\cM" }

    Quiq::Object->throw(
        'FH-00014: Ungültiger Newline-Bezeichner (LF, CRLF oder CR)',
        Identifier=>$nlName,
    );
}

# -----------------------------------------------------------------------------

=head3 strSingleSpaced() - Mache Zeichenkette einzeilig

=head4 Synopsis

  R1::Misc->strSingleSpaced(\$str);
  $str2 = R1::Misc->strSingleSpaced($str);

=head4 Description

Wandele Zeichenkette $str in eine einzeilige Darstellung um und
liefere diese zurück. Wird eine Referenz auf die Zeichenkette
übergeben, wird die Zeichenkette "in place" manipuliert und kein Wert
zurückgegeben.

Folgende Zeichenersetzungen werden vorgenommen:

  "\\" -> '\\\\' (wandele Slash in zwei Slashes)
  "\n" -> '\n'
  "\r" -> '\r'
  "\t" -> '\t'
  "\0" -> '\0'

=cut

# -----------------------------------------------------------------------------

sub strSingleSpaced {
    my $class = shift;
    my $str = shift;

    my $ref = ref $str? $str: \$str;

    $$ref =~ s/\\/\\\\/g;
    $$ref =~ s/\n/\\n/g;
    $$ref =~ s/\r/\\r/g;
    $$ref =~ s/\t/\\t/g;
    $$ref =~ s/\0/\\0/g;

    return $str unless ref $str;
}

# -----------------------------------------------------------------------------

=head2 Exceptions

=head3 dieUsage() - Gib Usage-Text aus und beende das Programm

=head4 Synopsis

  $class->dieUsage($text,@opt);

=head4 Options

=over 4

=item -error => $str|$xcp (Default: '')

Fehlertext oder Exception-Objekt. Ist der Wert ein Exception-Objekt,
wird die Meldung der Exception als Fehlertext genommmen.
Der Fehlertext erscheint vor dem Usage-Text. Der Fehlertext
ist idealerweise eine Fehlermeldung der Art "Ungültige Option --hst" ohne
NEWLINE am Ende. Der Fehlertext kann aber auch mehrzeilig sein und
mit einem NEWLINE enden. Die Methode kann auch damit umgehen.

=item -exitCode => $n (Default: 2)

Beenende das Progamm mit Exitcode $n.

=item -toStdout => $bool (Default: 0)

Schreibe $text nach STDOUT statt nach STDERR.

=back

=head4 Description

Gib Usage-Text $text aus und beende das Programm.

Der Usage-Text ist eine lange Programmbeschreibung oder eine
Kurzbeschreibung der Aufruf-Syntax des Programms der Art:

  myprog [OPTIONS] FILE
    --quiet=0|1 : Unterdrücke Ausgabe.

Der Usage-Text darf mit oder ohne NEWLINE enden. Die Methode kann mit
beidem umgehen.

Ohne Parameter aufgerufen, wird folgende Meldung produziert:

  Fehlerhafter Programmaufruf (Exitcode: 2)

=head4 Example

siehe R1::Misc->argExtract()

=cut

# -----------------------------------------------------------------------------

sub dieUsage {
    my $class = shift;
    my $text = shift;

    my $error = '';
    my $exitCode = 2;
    my $toStdout = 0;

    if (@_) {
        R1::Misc->argExtract(\@_,
            -error=>\$error,
            -exitCode=>\$exitCode,
            -toStdout=>\$toStdout,
        );
    }

    my $str;

    if ($error) {
        if (ref $error) {
            # Exception-Objekt. Wir sind nur an der Meldung interessiert.
            $error = $error->msg;
        }
        chomp $error;
        $str .= "$error\n";
    }

    if ($text) {
        if ($str) {
            # Fehlertext mit NEWLINE von Usage-Text abheben.
            $str .= "\n";
        }
        chomp $text;
        $str .= "$text\n";
    }

    if (!defined $str) {
        $str = "Fehlerhafter Programmaufruf (Exitcode: $exitCode)\n";
    }

    if ($toStdout) {
        print $str;
        exit $exitCode;
    }

    $! = $exitCode;
    die $str;
}

# -----------------------------------------------------------------------------

=head2 Verarbeitung von Argumenten

=head3 argExtract() - Extrahiere Optionen

=head4 Synopsis

  R1::Misc->argExtract(@opt,\@arr,$key=>\$var,...);

=head4 Options

=over 4

=item -dashTo => null|'underscore'|'camel' (Default: null)

Wandele im Falle von -returnHash=>1 die Bindestriche I<in> der
Optionsbezeichnung in Unterstriche ('underscore') oder wandele
den folgenden Buchstaben in Großschreibung ('camel').

Aus

  --minimum-order-value

wird Hashkey

  minimum_order_value  ('underscore')

oder

  minimumOrderValue    ('camel')

=item -dontExtract => $bool (Default: 0)

Verändere die Argumentliste nicht.

=item -keepUndef => $bool (Default: 0)

Behalte undef bei. Per Default wird der Optionswert undef ignoriert.

=item -mode => 'strict'|'strict-dash'|'sloppy'|'stop' (Default: 'strict')

Bestimmt, was passiert, wenn die Methode auf ein unbekanntes Element stößt.

=over 4

=item 'strict'

Löse eine Exception aus, wenn ein unbekanntes Element auftritt.

=item 'strict-dash'

Löse eine Exception aus, wenn ein unbekanntes Element auftritt,
das mit einem Bindestrich beginnt. Übergehe Elemente
ohne Bindestrich.

=item 'sloppy'

Übergehe unbekannte Elemente.

=item 'stop'

Beende Verarbeitung mit dem ersten unbekannten Element.

=back

=item -noException => $bool (Default: 0)

Wirf keine Exception, sondern liefere eine Fehlermeldung zurück.
Dies ist nützlich, wenn Programmoptionen ausgewertet werden.

=item -progOpts => $bool (Default: 0)

Diese Option ist obsolet! Es ist die generelle Logik implementiert,
dass "-opt val" auch als "--opt=val" angegeben werden kann.
In der Optionsspezifikation wird "-opt=>\$var" angegeben.
Mit -progOpts=>1 kann forciert werden, dass die Variante "--opt=val"
verwendet werden B<muss>.

Option und Wert sind mit '=' getrennt, z.B.

  --logfile=/tmp/test.log

Die Schreibweise

  --logfile /tmp/test.log

ist nicht erlaubt!

Ist für eine Option kein Wert angegeben, z.B.

  --help

wird der Variablen der Wert 1 zugewiesen.

=item -returnHash => $bool (Default: 0)

Liefere Restricted Hash mit den Optionswerten zurück. In der Argumentliste
werden keine Referenzen auf Variable angegeben, sondern Defaultwerte.

Ist gleichzeitig die Option -noException gesetzt, muss der Returnwert
mit ref() geprüft werden. Liefert ref() keinen Wert,
liegt ein Fehler vor und es wurde eine Fehlermeldung zurückgegeben.

=back

=head4 Description

Extrahiere aus Array @arr die Werte zu den angegebenen Schlüsseln
$key und weise diese an die Variablen $var zu. Die Methode
liefert im Fehlerfall eine Fehlermeldung $msg zurück, wenn die
Option -noException angegeben und auf "wahr" gesetzt ist.
Andernfalls wird kein Wert geliefert.

=head4 Example

=over 2

=item *

Lasse keine anderen Methoden-Argumente zu als die Optionen -x und -y:

  sub meth {
      my $self = shift;
  
      my $x = 4711;
      my $y = 0;
      if (@_) {
          R1::Misc->argExtract(\@_,
              -x=>\$x,
              -y=>\$y,
          );
      }
      ...
  }

=item *

Verarbeite Progamm-Argumente:

  # PCR-Definition in Programmtext übernehmen
  
  my $Usage = << "__EOT__";
  %USAGE%
  __EOT__
  
  # Variablen für Optionswerte definieren
  
  my $OptHelp = undef;
  my $OptInterval = undef;
  
  # Argumente des Programmaufrufs auswerten
  
  eval {
      R1::Misc->argExtract(-progOpts=>1,-mode=>'strict-dash',\@ARGV,
          '--help'=>\$OptHelp,
          '--interval'=>\$OptInterval,
      );
  };
  
  # Ergebnis der Argument-Auswertung verarbeiten
  
  if ($OptHelp) {
      # Auf Hilfe wird als erstes getestet, da diese unabhängig von
      # der Korrektheit der anderen Argumente gewährt wird
      R1::Misc->dieUsage($Usage);
  }
  elsif ($@) {
      # Optionen sind nicht korrekt
      R1::Misc->dieUsage($Usage,-error=>'FEHLER: '.$@);
  }
  elsif (@ARGV != 1) {
      # Pflicht-Argumente sind nicht korrekt
      R1::Misc->dieUsage($Usage,-error=>'FEHLER: Argument YYYYMMDD fehlt');
  }

=back

=cut

# -----------------------------------------------------------------------------

sub argExtract {
    my $class = shift;
    # @_: @opt,\@arr,@keyVar

    my $dontExtract = 0;
    my $keepUndef = 0;
    my $mode = 'strict';
    my $noException = 0;
    my $progOpts = 0;
    my $returnHash = 0;
    my $dashTo = undef;

    while (!ref $_[0]) {
        my $key = shift;

        if ($key eq '-dontExtract') {
            $dontExtract = shift;
        }
        elsif ($key eq '-keepUndef') {
            $keepUndef = shift;
        }
        elsif ($key eq '-mode') {
            # FIXME: Optimierung: Modes durch einzelne Variable
            $mode = shift;
        }
        elsif ($key eq '-noException') {
            $noException = shift;
        }
        elsif ($key eq '-progOpts') {
            $progOpts = shift;
        }
        elsif ($key eq '-returnHash') {
            $returnHash = shift;
        }
        elsif ($key eq '-dashTo') {
            $dashTo = shift;
            if ($dashTo && $dashTo ne 'underscore' && $dashTo ne 'camel') {
                my $msg = 'OPT-00004: Ungültiger -dashTo-Wert';
                if ($noException) {
                    return "$msg: $dashTo";
                }
                Quiq::Object->throw($msg,Option=>$dashTo);
            }
        }
        else {
            my $msg = 'OPT-00004: Ungültige argExtract-Option';
            if ($noException) {
                return "$msg: $key";
            }
            Quiq::Object->throw($msg,Option=>$key);
        }
    }

    my $arr = shift;

    my (%keyVar,$hash);
    if ($returnHash) {
        # Return-Hash mit Defaultwerten initialisieren
        # und Wert-Referenz auf Options-Hash speichern

        $hash = R1::Hash1->new;
        for (my $i = 0; $i < @_; $i += 2) {
            my $optKey = $_[$i];
            $optKey =~ s/^-+//; # führende - entfernen
            if ($dashTo) {
                if ($dashTo eq 'underscore') {
                    $optKey =~ s/-/_/g;
                }
                elsif ($dashTo eq 'camel') {
                    $optKey =~ s/-(.)/\U$1/g;
                }
            }
            $keyVar{$_[$i]} = \($hash->{$optKey} = $_[$i+1]);
        }
        $hash->lockKeys;
    }
    else {
        %keyVar = @_;
    }

    for (my $i = 0; $i < @$arr;) {
        my $key = $arr->[$i];
        my $valFromKey = 0;
        if ($progOpts || substr($key,0,2) eq '--') {
            # --OPT und --OPT=VAL

            my $val = 1;
            if ($key =~ /=/) {
                ($key,$val) = split /=/,$key,2;
            }
            if (!$progOpts && !$keyVar{$key}) {
                $key =~ s/^-//; # ersten Dash entfernen
            }
            if (!$returnHash && $dashTo) {
                if ($dashTo eq 'underscore') {
                    $key =~ s/([^-])-/$1_/g;
                }
                elsif ($dashTo eq 'camel') {
                    $key =~ s/([^-])-(.)/$1\U$2/g;
                }
            }
            $valFromKey = 1;
        }
        my $ref = $keyVar{$key};
        if (!$ref) {
            if ($mode eq 'stop') {
                last;
            }
            elsif ($mode eq 'sloppy') {
                $i++;
                next;
            }
            if ($mode eq 'strict') {
                my $msg = 'OPT-00001: Ungültige Option';
                if ($noException) {
                    # return "$msg: $key";
                    return "$msg: $arr->[$i]";
                }
                # $class->throw($msg,Option=>$key);
                Quiq::Object->throw($msg,Option=>$arr->[$i]);
            }
            elsif ($mode eq 'strict-dash') {
                if (substr($key,0,1) eq '-') {
                    my $msg = 'OPT-00001: Ungültige Option';
                    if ($noException) {
                        # return "$msg: $key";
                        return "$msg: $arr->[$i]";
                    }
                    # $class->throw($msg,Option=>$key);
                    Quiq::Object->throw($msg,Option=>$arr->[$i]);
                }
                else {
                    $i++;
                    next;
                }
            }
            else {
                my $msg = 'OPT-00002: Ungültiger Modus';
                if ($noException) {
                    return "$msg: $mode";
                }
                Quiq::Object->throw($msg,Mode=>$mode);
            }
        }

        if ($valFromKey) {
            my $val = 1;
            if ($arr->[$i] =~ /=/) {
                (undef,$val) = split /=/,$arr->[$i],2;
            }
            splice @$arr,$i+1,0,$val;
        }

        if ($i+1 >= @$arr) {
            my $msg = 'OPT-00003: Option hat keinen Wert';
            if ($noException) {
                return "$msg: $key";
            }
            Quiq::Object->throw($msg,Option=>$key);
        }

        # Wert auf Variable kopieren, wenn definiert oder -keepUndef
        # angegeben wurde. Das Defaultverhalten ermöglicht, dass eine
        # Option angegeben werden kann, ohne sich auszuwirken.

        if (defined $arr->[$i+1] || $keepUndef) {
            $$ref = $arr->[$i+1];
        }

        if ($dontExtract) {
            $i += 2;
        }
        else {
            splice @$arr,$i,2;
        }
    }

    if ($returnHash) {
        # Hashobjekt zurückliefern
        return $hash;
    }

    return;
}

# -----------------------------------------------------------------------------

=head2 Perl Interna

=head2 Miscellanous

=head3 nlStr() - Liefere Zeilenumbruch-Zeichenfolge

=head4 Synopsis

  $nlString = R1::Misc->nlStr($name);

=head4 Description

Liefere die Zeilenumbruch-Zeichenfolge zu Zeilenumbruch-Bezeichner:

  $name    $nlString
  -----    ---------
  'CR'     "\cM"
  'LF'     "\cJ"
  'CRLF'   "\cMcJ"

=cut

# -----------------------------------------------------------------------------

sub nlStr {
    my ($class,$name) = @_;

    if ($name eq 'CR') { return "\cM" }
    elsif ($name eq 'LF') { return "\cJ" }
    elsif ($name eq 'CRLF') { return "\cM\cJ" }

    Quiq::Object->throw(
        'NL-00001: Ungültiger Zeilenumbruch-Bezeichner',
        Indentifier=>$name,
    );
}

# -----------------------------------------------------------------------------

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=cut

# -----------------------------------------------------------------------------

1;

# eof
