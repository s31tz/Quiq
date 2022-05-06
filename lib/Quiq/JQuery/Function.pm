# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::JQuery::Function - Nützliche Funktionen für jQuery

=head1 BASE CLASS

L<Quiq::Object>

=head1 DESCRIPTION

Diese Klasse erweitert das jQuery-Objekt um nützliche Funktionen.

=cut

# -----------------------------------------------------------------------------

package Quiq::JQuery::Function;
use base qw/Quiq::Object/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.203';

use Quiq::Unindent;

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $jq = $class->new;

=head4 Returns

Path-Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück. Da die Klasse nur Klassenmethoden enthält,
hat das Objekt lediglich die Aufgabe, eine abkürzende
Aufrufschreibweise zu ermöglichen.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    return bless \(my $dummy),$class;
}

# -----------------------------------------------------------------------------

=head2 Klassenmethoden

=head3 formatDate() - JavaScript-Code der Funktion

=head4 Synopsis

  $javaScript = $this->formatDate;

=head4 Description

Die JavaScript-Funktion formatiert ein JavaScript Datums-Objekt
gemäß dem angegebenen Muster:

  str = $.formatDate(d,fmt);

=over 4

=item YYYY

Jahreszahl, vierstellig.

=item YY

Jahreszahl, zweistellig,

=item MMMM

Monatsname, voll ausgeschrieben.

=item MMM

Monatsname, die ersten drei Buchstaben.

=item MM

Monatsnummer, zweistellig.

=item M

Monatsnummer.

=item DDDD

Wochentag, voll ausgeschrieben.

=item DDD

Wochentag, die ersten drei Buchstaben.

=item DD

Tag des Monats, zweistellig.

=item D

Tag des Monats.

=item hh

Stunde, zweistellig.

=item h

Stunde.

=item mm

Minute, zweistellig.

=item m

Minute

=item ss

Sekunde, zweistellig.

=item s

Sekunde.

=item xxx

Millisekunden, dreistellig.

=back

Die Implementierung basiert auf der Funktion formatDate() im
Buch L<jQuery in Action, Third Edition|https://www.manning.com/books/jquery-in-action-third-edition>, S. 352 ff.

=cut

# -----------------------------------------------------------------------------

sub formatDate {
    my $this = shift;

    return Quiq::Unindent->hereDoc(<<'    __JS__');
    (function($) {
        var patternParts =
            /^(YY(YY)?|M(M(M(M)?)?)?|D(D)?|EEE(E)?|h(h)?|m(m)?|s(s)?|xxx)/;

        var patternValue = {
            YY: function(date) {
                return toFixedWidth(date.getFullYear(), 2);
            },
            YYYY: function(date) {
                return date.getFullYear().toString();
            },
            MMMM: function(date) {
                return $.FormatDate.monthNames[date.getMonth()];
            },
            MMM: function(date) {
                return $.FormatDate.monthNames[date.getMonth()]
                    .substr(0, 3);
            },
            MM: function(date) {
                return toFixedWidth(date.getMonth() + 1, 2);
            },
            M: function(date) {
                return date.getMonth() + 1;
            },
            DD: function(date) {
                return toFixedWidth(date.getDate(), 2);
            },
            D: function(date) {
                return date.getDate();
            },
            EEEE: function(date) {
                return $.FormatDate.dayNames[date.getDay()];
            },
            EEE: function(date) {
                return $.FormatDate.dayNames[date.getDay()].substr(0, 3);
            },
            hh: function(date) {
                return toFixedWidth(date.getHours(), 2);
            },
            h: function(date) {
                return date.getHours();
            },
            mm: function(date) {
                return toFixedWidth(date.getMinutes(), 2);
            },
            m: function(date) {
                return date.getMinutes();
            },
            ss: function(date) {
                return toFixedWidth(date.getSeconds(), 2);
            },
            s: function(date) {
                return date.getSeconds();
            },
            xxx: function(date) {
                return toFixedWidth(date.getMilliseconds(), 3);
            },
        };

        function toFixedWidth(value, length, fill) {
            var result = (value || '').toString();
            fill = fill || '0';
            var padding = length - result.length;
            if (padding < 0) {
                result = result.substr(-padding);
            } else {
                for (var n = 0; n < padding; n++) {
                    result = fill + result;
                }
            }
            return result;
        }

        $.formatDate = function(date, pattern) {
            var result = [];
            while (pattern.length > 0) {
               patternParts.lastIndex = 0;
                var matched = patternParts.exec(pattern);
                if (matched) {
                    result.push(patternValue[matched[0]].call(this, date));
                    pattern = pattern.slice(matched[0].length);
                } else {
                    result.push(pattern.charAt(0));
                    pattern = pattern.slice(1);
                }
            }
            return result.join('');
        };

        $.formatDate.monthNames = [
            'January','February','March','April','May','June','July',
            'August','September','October','November','December'
        ];

        $.formatDate.dayNames = [
            'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday',
            'Saturday'
        ];
    })(jQuery);
    __JS__
}

# -----------------------------------------------------------------------------

=head3 ready() - Erzeuge JQuery Ready-Handler

=head4 Synopsis

  $handler = $this->ready($js);

=head4 Arguments

=over 4

=item $js

JavaScript-Code (String).

=back

=head4 Returns

JQuery Ready-Handler (String)

=head4 Description

Fasse JavaScript-Code $js in einen JQuery Ready-Handler ein und liefere
den resultierenden JavaScript-Code zurück. Der Ready-Handler hat
den Aufbau

  $(function() {
      <JAVASCRIPT>
  });

=head4 See Also

L<https://api.jquery.com/ready/>

=cut

# -----------------------------------------------------------------------------

sub ready {
    my $this = shift;
    my $js = shift // '';

    if ($js) {
        $js = Quiq::Unindent->trim($js);
        $js =~ s/^/    /mg;
        $js = "\$(function() {\n$js\n});";
    }

    return $js;
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
