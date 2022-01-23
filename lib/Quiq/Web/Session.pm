# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Web::Session - Aufrufverfolgung, Zustandsspeicherung und Navigation

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Ein Objekt der Klasse repräsentiert die Sitzung eines Benutzers.

=head2 Sitzungsdatenbank

Die Sitzungsdatenbank wird in einem ausgezeichneten Verzeichnis,
das beim Konstruktoraufruf optional angegeben wird (Option -dir),
gehalten. Das Verzeichnis hat folgende Substruktur:

  DIR/SID/            Verzeichnis zur Sitzung
  DIR/SID/rid         aktuelle Request-Id zur Sitzung
  DIR/SID/call.db     Seitenaufrufe der Sitzung
  DIR/SID/frame.db    Request-Ids zu Frames der Sitzung
  DIR/SID/referer.db  Request-Ids zu URLs der Sitzung
  DIR/SID/global.db   Persistente Schlüssel/Wert-Paare
  DIR/nosession.log   Log der sitzungslosen Zugriffe

=over 4

=item DIR

Verzeichnis, das mittels der Konstruktoroption -dir
definiert wurde (Default: aktuelles Verzeichnis).

=item SID

Sitzungs-Id, die beim Konstruktoraufruf angegeben
wurde. Typischerweise ist dies der Wert des Session-Cookie.

=back

Folgende Datenbankdateien werden von der Klasse sitzungsbezogen
geschrieben und gelesen. Alle Dateien werden von der Klasse
automatisch angelegt, wenn sie benötigt werden.

=over 4

=item rid

Datei mit einer einzigen Zeile, die die aktuelle Request-Id
enthält. Die Datei stellt den Request-Zähler für die Sitzung
dar. Die Zählung beginnt mit 1. Ferner findet über dieser
Datei die Synchronisation von parallel verlaufenden Schreib-
und Leseoperationen statt. Sie wird vor Schreiboperationen auf
einer oder mehreren Datenbankdateien mit einem Exklusiv-Lock
belegt und bei Leseoperationen mit einem Shared-Lock.

=item call.db

Berkeley-Db HASH Datei, in der die Aufrufe protokolliert
werden. Schlüssel ist die Request-Id des Aufrufs.

  rid | rid \0 time \0 rrid \0 drid \0 brid \0 frid \0 frame \0
      args \0 post \0 anchor \0 xy
  
  rid     : Request-Id des aktuellen Aufrufs
  -------
  rid     : Request-Id des aktuellen Aufrufs
  time    : Zeitpunkt des Aufrufs in Unix-Epoch
  rrid    : Request-Id der rufenden Seite
  drid    : Request-Id des Aufrufs, der die Defaults für
            brid und frame geliefert hat
  brid    : Request-Id der Rückkehrseite
  frid    : Request-Id der Vorwärtsseite
  crid    : Request-Id der Abbruchseite
  cid     : Kontext-Id des Aufrufs. Diese Id wird von Aufruf zu
            Aufruf weitergegeben. Mit kontext=* kann eine
            Neugenerierung forciert werden. Anfänglich wird sie
            mit dem ersten Seitenaufruf gesetzt.
  frame   : Frame/Window in dem das Resultat des Aufrufs
            erschienen ist
  args    : CGI-Parameter des Aufrufs in Querystring-Kodierung
  post    : CGI-Parameter, die die Seite gepostet hat (wird von
            der Folgeseite gesetzt)
  anchor  : Anker, auf den bei Wiederaufruf positioniert werden
            soll (wird von der Folgeseite gesetzt)
  xy      : Scrollposition, auf die bei Wiederaufruf gescrollt
            werden soll (wird von der Folgeseite gesetzt)

=item referer.db

=back

Berkeley-DB HASH Datei, die Request-Ids zu Referer-URLs
speichert. Über diese Zuordnung stellt die Klasse ohne weitere
Information von außen die Aufrufreihenfolge her. Schlüssel der Datei
ist die Referer-URL des Aufrufs.

  referer | rid
  
  referer : Referer-URL des Aufrufs
  -------
  rid     : Request-Id des jüngsten Aufrufs mit dem
            betreffenden Referer-URL

=over 4

=item frame.db

=back

Berkeley-DB HASH Datei, die für jeden Frame die Request-Id
des letzten Aufrufs speichert.

  frame | rid
  
  frame   : Name des Frame
  ---
  rid     : Request-Id des jüngsten Aufrufs in dem
            betreffenden Frame

=head2 Direktiven

Die Klasse definiert sechs CGI-Parameternamen, die vom Konstruktor
der Klasse als Direktiven zur Verwaltung der Sitzungsdaten
interpretiert werden. Diese werden bei einem Seitenübergang dem
URL der Zielseite optional hinzugefügt.

=over 4

=item frame=frame

Teilt dem Session-Konstruktor der Folgeseite mit, dass das
Resultat des Aufrufs in Frame frame erscheint. Diese Angabe
wird von der Klasse automatisch von Aufruf zu Aufruf
weitergereicht, bis sie durch eine neue Setzung überschrieben
wird. Die Direktive "frame" braucht also nur beim initialen
Aufruf einer Seite in einem Frame angegeben werden, oder wenn
ein Aufruf aus einem Frame A heraus erfolgt, die Darstellung
aber in Frame B erscheint. In letzerem Fall ist "frame=B"
anzugeben.

=item rrid=rid

Teilt dem Session-Konstruktor der Folgeseite die
Vorgängerseite mit.  Diese Angabe ist normalerweise nicht
nötig, da die Vorgängerseite automatisch durch Auswertung von
HTTP_REFERER ermittelt wird.  Es gibt aber exotische
Situtionen, in denen dies nicht oder nicht portabel
funktioniert. Dies ist z.B. beim Übergang von einer Seite zu
einem Popup-Menü (positionierbares DHTML-Objekt) und beim
Übergang vom Popup-Menü zur Folgeseite der Fall.

=item zurueck=rid

Teilt dem Session-Konstruktor der Folgeseite mit, dass die
Seite mit der Request-Id rid als Rückkehrseite gespeichert
werden soll. Die Request-Id wird von der Klasse automatisch
von Aufruf zu Aufruf weitergereicht, bis sie durch eine neue
Setzung überschrieben wird.  Anstelle einer numerischen
Request-Id können folgende symbolischen Werte angegeben
werden:

=over 4

=item -1

Als Rückkehrseite wird die Vorgängerseite, also die
rufende Seite, eingetragen. Diese Direktive wird
angegeben, wenn die aktuelle Seite für die Folgeseite(n)
die Rückkehrseite darstellt.

=item x

Als Rückkehrseite wird die letzte Seite, die im selben
Frame dargestellt wurde, eingetragen. Diese Direktive wird
bei einem Seitenaufruf aus einem Menü, welches sich in
einem anderen Frame befindet, angegeben. Eine registierte
Abbruchseite wird nicht übernommen.

=item *

Der Eintrag für die Rückkehrseite wird gelöscht. Diese
Direktive wird angegeben, wenn der Aufruf eine Framegrenze
überschreitet und via "zurueck=x" keine sinnvolle
Vorgängerseite angegeben werden kann. Beispiel:
Warenkorbaktualisierung.

=back

=back

Eine numerische Request-Id wird normalerweise nicht manuall
vergeben, sondern bei der Zurück- oder Vornavigation von den
betreffenden Methoden automatisch gesetzt.

=over 4

=item vorwaerts=rid

Teilt dem Session-Konstruktor der Folgeseite mit, dass die
Seite mit der Request-Id rid als Vorwärtsseite gespeichert
werden soll. Diese Direktive wird normalerweise nicht manuell
angegeben, sondern bei der Zurücknavigation von den
betreffenden Methoden automatisch gesetzt.

=item verdeckt=0|1

Teilt dem Session-Konstruktor der Folgeseite mit, dass der
Aufruf nicht in der Frame-Db registriert werden soll. Damit
wird verhindert, dass die Folgeseite im Zuge einer
Quernavigation (zurueck=x) zu einer Rückkehrseite werden
kann. Diese Direktive sollte beim Aufruf von Seiten angewendet
werden, die kein sichtbares Resultat besitzen,
z.B. JavaScript- und Stylesheet-Dateien oder Seiten mit Status
"204 No Response".

=item postignorieren=0|1

Teilt dem Session-Konstruktor der Folgeseite mit, dass die
geposteten Parameter nicht im Datenbankeintrag der
Vorgängerseite gespeichert werden sollen. Per Default werden
sie dort gespeichert. Diese Direktive wird angegeben, wenn ein
Formular sich selbst als Action eingetragen hat und die
Aufrufabfolge via "zurueck=-1" gesichert werden soll.  In dem
Fall ist ein Zurückspeichern der geposteten Daten unerwünscht,
da bei Rückkehr der vormalige Formularzustand bei IL<lt>Aufruf>
des Formulars wiederhergestellt werden soll und nicht der
letzte Zustand vor dem Posten, denn dieser findet sich in der
nächsten Instanz.

=item anker=anker

Teilt dem Session-Konstruktor der Folgeseite mit, dass der
Anker anker im Eintrag der Vorgängerseite gespeichert werden
soll. Wird die Vorgängerseite erneut annavigiert, sorgen die
Navigationsmethoden dafür, dass der Suchsting "#anker" zum URL
hinzugefügt wird, was bewirkt, dass der Browser beim Laden der
Seite auf den entsprechenden Anker positioniert. Dies ist der
portabelste Weg, eine Positionierung innerhalb einer Seite
wiederherzustellen.

=item xy=x.y

Teilt dem Session-Konstruktor der Folgeseite mit, dass die
Scrollposition x.y im Eintrag der Vorgängerseite gespeichert
werden soll. Wird die Vorgängerseite erneut annavigiert,
sorgen die Navigationsmethoden dafür, dass der CGI-Parameter
"scroll=x.y" zum URL hinzugefügt wird. Das CGI-Programm kann
diesen Parameter auswerten und die exakte Positionierung mit
JavaScript-Mitteln wiederherstellen.

=item kontext=*

Generiere eine neue Kontext-Id. Dieser Parameter wird
angegeben, wenn eine Substruktur an Seiten unter einem eigenen
Kontext operiert.

=item swidget=name

Diese Direktive wird von den Checkbox- und
Selectlist-Widgetklassen generiert. Sie wirkt sowohl in der
Cgi-Klasse als auch in der Session-Klasse. Sie dient dazu,
Anomalien zu vermeiden, die entstehen können, wenn in Widgets
dieser Klassen IL<lt>keine> Auswahl getroffen wird. In dem Fall
wird per HTML-Standard leider IL<lt>nichts> über die Widgets an
die Folgeseite kommuniziert. Es ist also nichtmal bekannt,
dass sie existieren. Die Direktive sorgt dafür, dass den
betreffenden Stellen die Existenz der Widgets trotzdem
angezeigt wird.

In der Cgi-Klasse zeigt die Direktive an, dass das betreffende
Widget formularseitig vorhanden ist, auch wenn es keinen Wert
geschickt hat (dies ist bei Checkboxen und
Multiselect-Elemeten der Fall, wenn nichts ausgewählt
wird). Die Cgi-Klasse erzeugt den Cgi-Parameter daraufhin
intern und ordnet ihm eine leere Liste von Werten zu. Bei der
Reinitialisierung eines Formulars durch Rückkehr bewirkt dies,
dass eine etwaig beim Widget definierte
Default-Initialisierung bei fehlender Auswahl unterbleibt.

In der Session-Klasse bewirkt die Direktive, dass im Falle
einer POST-Operation, die betreffenden CGI-Parameter aus dem
args-Slot (ursprüngliche Aufrufparameter) entfernt werden.
Wenn keine keine Daten gepostet werden, weil keine Auswahl
erfolgt ist, können die ehemaligen Aufrufparameter bei
Rückkehr nicht plötzlich in Erscheinung treten.

=back

=head2 Navigation

$url = $sess->backurl;

Diese Methode liefert den URL der Rückkehrseite. Dieser Aufruf wird
verwendet, um den URL für den Zurücklink der Navigationsleiste zu
generieren.

$url = $sess->forwardurl;

Diese Methode liefert den URL der Vorwärtsseite. Dieser Aufruf wird
verwendet, um den URL für den Vorwärts-Link der Navigationsleiste zu
generieren.

$url = $sess->prevurl;

Diese Methode liefert den URL der Vorgängerseite, also derjenigen
Seite, die die aktuelle Seite gerufen hat. Dieser Aufruf wird
verwendet, um (z.B. im Fehlerfall) von einer Aktionsseite auf die
korrespondierende Formularseite zurückzupositionieren.

$url = $sess->cancelurl;

Diese Methode liefert den URL der Abbruchseite, ohne dass ein
Vorwärtslink auf die aktuelle Seite generiert wird. Dieser Aufruf wird
verwendet, um von einer Aktionsseite auf die Abbruchseite zu
positionieren bzw. um einen Arbeitsablauf, also eine Folge von Seiten
zur Abwicklung eines Anwendungsfalls, an irgendeiner Stelle zu
beenden.

=head3 Bekannte Probleme mit HTTP_REFERER

Eine Seite, die eine Redirection ausführt, erscheint in der
Seitenhistorie nicht als Vorgängerseite ihrer Folgeseite. Als
Vorgängerseite erscheint vielmehr die Seite, die die Redirectionseite
gerufen hat. Das liegt daran, dass bei einer Redirection HTTP_REFERER
vom Browser nicht umgesetzt wird (worauf auch?), sondern auf der
ursprünglich rufenden Seite stehen bleibt. Dies hat zur Konsequenz,
dass ein "zurueck=..." auf dem Link zu einer Aktionsseite
(redirectenden Seite) keinen Effekt hat. Die Setzung kommt auf der
Zielseite nicht an.

=cut

# -----------------------------------------------------------------------------

package Quiq::Web::Session;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.198';

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head1 VERSION

1.198

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
