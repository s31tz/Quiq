package Quiq::Database::DataAnalysis;
use base qw/Quiq::Hash/;

use strict;
use warnings;
use v5.10.0;

our $VERSION = 1.140;

use Quiq::Option;
use Quiq::Unindent;
use List::Util ();
use POSIX ();
use Quiq::Formatter;
use Quiq::Database::Row::Array;
use Quiq::Database::ResultSet::Array;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Database::DataAnalysis - Führe Datenanalyse durch

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Führe eine Analyse auf den Daten einer Relation (Tabelle oder View) oder
eines SQL-Statements durch, das Daten liefert (üblicherweise ein
SELECT-Statement). Das Analyseergebnis kann mit den Methoden der Klasse
ausgegeben werden.

=head1 METHODS

=head2 Konstruktor

=head3 new() - Führe Datenanalyse durch

=head4 Synopsis

    $obj = $class->new($db,@select,@opt);

=head4 Arguments

=over 4

=item $db

Datenbankverbindung

=item @select

Name einer Relation oder Komponenten eines SELECT-Statements. Siehe
Quiq::Sql->select().

=back

=head4 Options

=over 4

=item -cache => $n

Siehe Quiq::Database::Connection/sql().

=back

=head4 Returns

=over 4

=item $obj

Objekt mit dem Ergebnis der Datenanalyse.

=back

=head4 Description

Führe eine Datenanalyse für Datenquelle @select (Tabelle, View, Statement)
durch und liefere ein Objekt, das das Analyseergebnis repräsentiert,
zurück. Folgende Information wird für alle Kolumnen der Datenquelle
ermittelt:

    COUNT(DISTINCT <column>) - Anzahl der verschiedenen Werte
    COUNT(<column>)          - Anzahl der Werte, die nicht NULL sind
    MIN(LENGTH(<column>))    - Länge des kürzesten Werts
    MAX(LENGTH(<column>))    - Länge des längsten Werts
    MIN(<column>)            - Kleinster Wert (gemäß Datentyp)
    MAX(<column>)            - Größter Wert (gemäß Datentyp)

Ferner wird ermittelt:

    COUNT(1)                 - Anzahl aller Zeilen der Datenquelle

Das Ergebnis der Analyse kann mit der Methode $obj->asTable() ausgegeben
werden.

=head4 Example

Datenanalyse einer Tabelle q06i001, die Ergebnismenge wird einen Tag gecacht:

    print Quiq::Database::DataAnalysis->new($db,'q06i001',-cache=>86400)->asTable;
    __END__
    q06i001
    
    30.088.616
    
    1 <column>
    2 COUNT(DISTINCT <column>)
    3 COUNT(<column>)
    4 MIN(LENGTH(<column>))
    5 MAX(LENGTH(<column>))
    6 MIN(<column>)
    7 MAX(<column>)
    
    1                2            3            4    5    6                          7
    | fid            |        101 | 30.088.616 |  1 |  3 | 0                        | 808                       |
    | ag             |          5 | 30.088.616 |  2 |  2 | 25                       | 29                        |
    | kdnr           |  2.805.719 | 30.088.616 |  9 |  9 | 111111200                | 900002009                 |
    | vsnr           |  2.971.673 | 30.088.616 |  6 |  9 | 230243                   | 999999999                 |
    | lfd_nr         |        439 | 30.088.616 |  1 |  3 | 1                        | 439                       |
    | com_dat        |          1 | 30.088.616 |  1 |  1 | 0                        | 0                         |
    | wirk_dat       |     12.553 | 30.088.616 |  7 |  7 | 1000101                  | 2190731                   |
    | vwnd_kz        |          1 | 30.088.616 |  1 |  1 | 0                        | 0                         |
    | cur_dat        |      8.408 | 30.088.616 |  1 |  7 | 0                        | 2190418                   |
    | va             |         18 | 30.088.616 |  1 |  2 | 0                        | 99                        |
    | nf             |     11.855 | 30.088.616 |  1 |  7 | 0                        | 2990101                   |
    | sost_kz        |          3 | 30.088.616 |  1 |  1 | 0                        | 2                         |
    | stor_dat       |     12.762 | 30.088.616 |  1 |  7 | 0                        | 2990101                   |
    | berech_ab      |     11.950 | 30.088.616 |  1 |  7 | 0                        | 2190630                   |
    | ges_beitr_brt  |    543.939 | 30.088.616 |  4 | 11 | -1717145.01              | 9944894.74                |
    | fpr_stop_kz    |          4 | 30.088.616 |  0 |  1 |                          | 3                         |
    | umstlg_kz      |          3 | 30.088.616 |  1 |  1 | 0                        | 2                         |
    | masch_aend_grd |         25 | 30.088.616 |  1 |  2 | 0                        | 99                        |
    | nnr            |      1.093 | 30.088.616 |  1 |  4 | 0                        | 9998                      |
    | lfd_tp_nr      |        277 | 30.088.616 |  1 |  3 | 1                        | 277                       |
    | lg_zt          | 30.088.616 | 30.088.616 | 24 | 24 | 060508000100001000000033 | 190418160157999000007760  |
    | tech_ab        |     12.553 | 30.088.616 | 10 | 10 | 1900-01-01               | 2019-07-31                |
    | tech_bis       |     12.293 | 30.088.616 | 10 | 10 | 1900-01-01               | 9999-12-31                |
    | upd_dat        |      5.572 | 30.088.616 | 19 | 26 | 2006-05-10 08:13:11      | 2019-04-19 00:02:05.66096 |
    
    24 rows

=cut

# -----------------------------------------------------------------------------

# Die Analysewerte und die Ausdrücke zu ihrer Berechnung

my $ValLenLimit = 30;
my @Suffixes = qw/distinct notnull minlen maxlen minval maxval/;
my %Expr = (
    distinct => 'COUNT(DISTINCT %s)',
    notnull => 'COUNT(%s)',
    minlen => 'MIN(LENGTH(%s))',
    maxlen => 'MAX(LENGTH(%s))',
    minval => 'MIN(%s)',
    maxval => 'MAX(%s)',
);

sub new {
    my $class = shift;
    my $db = shift;
    # @_: @select

    # Optionen

    my $cache = undef;

    Quiq::Option->extract(\@_,
        -cache => \$cache,
    );

    # Gegenstand der Analyse (Datenquelle)
    my $subject = @_ == 1? $_[0]: $db->stmt->select(@_);

    # Die Kolumnen der Datenquelle
    my $titleA = $db->titles(@_);

    # Objekt instantiieren

    my $self = $class->SUPER::new(
        subject => $subject,
        suffixA => \@Suffixes,
        exprH => \%Expr,
        rowCount => 0,
        titleA => $titleA,
        maxTitleLen => List::Util::max(map {length} @$titleA),
        valLenLimit => $ValLenLimit,
        titleH => {}, # {$title}->{$suffix} = $val
        maxLenH => {map {$_ => 0} @Suffixes}, # max. Längen der Analysewerte
    );
    my $suffixA = $self->{'suffixA'};
    my $valLenLimit = $self->{'valLenLimit'};

    # Selectliste erstellen

    my @columns = ('COUNT(1) AS rowcount');
    for my $title (@$titleA) {
        for my $suffix (@$suffixA) {
            push @columns,sprintf "$Expr{$suffix} AS %s_%s",$title,
                $title,$suffix;
        }
    }

    # Lange Selectlisten müssen wir auf mehrere Selektionen aufteilen.
    # Wert 300 ist hier recht willkürlich gewählt, unter PostgreSQL
    # klappt es damit, sonst entstehen teilweise zu große Executionpläne.

    my $splitFactor = 1;
    my $size = @columns;
    while ($size > 300) {
       $size /= 2;
       $splitFactor++;
    }
    my $chunkSize = POSIX::ceil(@columns/$splitFactor);

    my @selects;
    for (my $i = 0; $i < $splitFactor; $i++) {
        $selects[$i] = [splice @columns,0,$chunkSize];
    }

    # Statement-Muster erstellen

    my $stmtPattern;
    if (@_ == 1) {
        $stmtPattern = "
            SELECT
                %SELECT%
            FROM
                $_[0]
        ";
    }
    else {
        my $stmt = $db->stmt->select(-from,@_);
        $stmt =~ s/^/' ' x 16/mge;
        $stmt =~ s/^\s+//;

        $stmtPattern = "
            SELECT
                %SELECT%
            FROM (
                $stmt
            ) AS x
        ";
    }
    $stmtPattern = Quiq::Unindent->string($stmtPattern);

    # Selektionen ausführen

    for my $columnA (@selects) {
        my ($row) = $db->select(
            -stmt => $stmtPattern,
            -select => @$columnA,
            -cache => $cache,
        );

        for ($row->titles) {
            if ($_ eq 'rowcount') {
                $self->set(rowCount=>$row->$_);
            }
            else {
                my ($title,$suffix) = $_ =~ /^(.*)_([^_]+)$/;
                $self->{'titleH'}->{$title}->{$suffix} = $row->$_;
            }
        }
    }

    # Maximallängen der Analysewerte bestimmen

    for my $suffix (@$suffixA) {
        my $maxLen = $self->{'maxLenH'}->{$suffix};
        for my $title (@$titleA) {
            my $l = length $self->{'titleH'}->{$title}->{$suffix};
            if ($l > $maxLen) {
                $maxLen = $l;
            }
        }
        $self->{'maxLenH'}->{$suffix} = $maxLen;
    }

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 asTable() - Analyseergebnis als Tabelle

=head4 Synopsis

    $str = $obj->asTable;

=cut

# -----------------------------------------------------------------------------

sub asTable {
    my $self = shift;

    # Objektattribute

    my $suffixA = $self->{'suffixA'};
    my $exprH = $self->{'exprH'};
    my $titleA = $self->{'titleA'};
    my $valLenLimit = $self->{'valLenLimit'};

    # Titelliste erstellen

    my @titles = ('<column>');
    for my $suffix (@$suffixA) {
        push @titles,sprintf $exprH->{$suffix},'<column>';
    }

    # Datensätze erstellen

    my @rows;
    for my $title (@$titleA) {
        my @row = ($title);
        for my $suffix (@$suffixA) {
            my $val = $self->{'titleH'}->{$title}->{$suffix};
            if ($suffix !~ /^m(in|ax)val$/) {
                $val = Quiq::Formatter->readableNumber($val);
            }
            if (length($val) > $valLenLimit) {
                $val = substr($val,0,$valLenLimit).'...';
            }
            push @row,$val;
        }
        push @rows,Quiq::Database::Row::Array->new(\@row);
    }

    # Tabelle instantiieren und Kolumnenausrichtung anpassen

    my $tab = Quiq::Database::ResultSet::Array->new(\@titles,\@rows);
    my $formatA = $tab->formats;
    for (my $i = 0; $i < @$suffixA; $i++) {
        if ($formatA->[$i+1]->[0] eq 's' &&
                $suffixA->[$i] !~ /^m(in|ax)val$/) {
            $formatA->[$i+1]->[1] = -$formatA->[$i+1]->[1];
        }
    }

    # Stringrepräsentation erzeugen

    my $str = "$self->{'subject'}\n\n";
    $str .= Quiq::Formatter->readableNumber($self->{'rowCount'})."\n\n";
    $str .= $tab->asTable;

    return $str;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.140

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
