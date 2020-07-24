package Quiq::PlotlyJs::DiagramGroup;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;
use utf8;

our $VERSION = '1.186';

use Quiq::Json;
use Quiq::JavaScript;
use Quiq::JQuery::Function;
use Quiq::Html::Table::Simple;
use Quiq::Html::Widget::CheckBox;
use Quiq::Html::Widget::SelectMenu;
use Quiq::Html::Widget::Button;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::PlotlyJs::DiagramGroup - Erzeuge eine Gruppe von XY-Plots

=head1 BASE CLASS

L<Quiq::Hash>

=head1 DESCRIPTION

Diese Klasse ist ein Perl-Wrapper für die Erzeugung einer Gruppe
von XY-Plots auf Basis von Plotly.js, Beispiel siehe
L<Plotly.js: Plotten und analysieren einer Gruppe von Zeitreihen|http://fseitz.de/blog/index.php?/archives/157-Plotly.js-Plotten-und-analysieren-einer-Gruppe-von-Zeitreihen.html>.

Die Diagrammgruppe zeichnet sich dadurch aus, dass durch alle
Plots der Gruppe synchron gescrollt werden kann. In dem Diagramm,
dessen Rangeslider aktiviert ist, kann mit der linken Maustaste im
Plot ein Zeitbereich ausgewählt und anschließend mit dem
Rangeslider durch den Gesamtbereich gescrollt werden. Das Zoomen
und Scrollen findet dabei über allen Diagrammen synchron
statt. Bei Doppelklick in den Plot-Breich wird der ursprüngliche
Zustand wieder hergestellt. Beim Überfahren der Plots mit der Maus
wird das Koordinatenpaar des nächstgelegenen Punktes
angezeigt. Über das Menü "Shape" kann die Kurvenform eingestellt
und mittels des Buttons "Download as PNG" der aktuelle
Diagramm-Zustand als Grafik heruntergeladen werden.

Es gibt zwei Möglichkeiten, die Plot-Daten in die Diagramme zu
übertragen:

=over 4

=item 1.

Die Arrays x, x (und ggf. z) werden dem Parameter-Objekt mitgegeben.

=item 2.

Per Ajax-Aufruf, wenn beim Parameter-Objekt ein URL definiert ist.
In diesem Fall sind die Daten sind nicht Teil der Seite,
sondern werden per asynchronem Ajax-Request (ggf. via
L<Cross-Origin Resource Sharing|http://fseitz.de/blog/index.php?/archives/159-Ajax-Cross-Origin-Resource-Sharing-CORS-implementieren.html>) geladen.

=back

Das  Laden per Ajax-Request hat den Vorteil, dass das Holen der
Daten parallel geschieht - während die Diagramme auf der Seite
bereits (leer) angezeigt werden.

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $dgr = $class->new(@attVal);

=head4 Attributes

=over 4

=item height => $n (Default: 300)

Höhe eines Diagramms in Pixeln.

=item name => $name (Default: 'dgr')

Name der Diagramm-Gruppe. Der Name wird als CSS-Id für den
äußeren Container der Diagramm-Gruppe genutzt.

=item parameters => \@parameters

Liste der Parameter-Objekte. Die Paramater-Objekte sind vom Typ
Quiq::PlotlyJs::Parameter.

=item strict => $bool (Default: 1)

Melde Fehler mittels alert(), nicht nur via console.log().

=item xAxisType => 'date'|'linear' (Default: 'date')

Art der X-Achsen: date=Zeit, linear=numerisch

=back

=head4 Returns

Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere eine Referenz auf
dieses Objekt zurück.

=cut

# -----------------------------------------------------------------------------

sub new {
    my $class = shift;
    # @_: @attVal

    my $self = $class->SUPER::new(
        height => 300,
        name => 'dgr',
        parameters => [],
        strict => 1,
        xAxisType => 'date',
    );
    $self->set(@_);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 html() - Generiere HTML

=head4 Synopsis

  $html = $dgr->html($h);

=head4 Returns

HTML-Code (String)

=head4 Description

Liefere den HTML-Code der Diagramm-Gruppe.

B<Leere Diagrammgruppe>

Wenn die Liste der Parameter leer ist, liefert die Methode html()
einen Leerstring.

B<Leeres Diagramm>

Besitzt ein Parameter keine Daten (die Arrays x und y sind leer),
wird der Plot-Bereich des betreffenden Diagramms leer dargestellt.
Die Achsen werden gemäß xMin, xMax, yMin, yMax skaliert. Fehlen
auch diese Angaben, nimmt Plotly.js eine Default-Achsen-Skalierung
vor (Zeitbereich: C<2000-01-01 00:00:00> bis C<2001-01-01 00:00:00>,
Y-Wertebereich: C<-1> bis C<4>).

=cut

# -----------------------------------------------------------------------------

sub html {
    my ($self,$h) = @_;

    # Objektattribute
    my ($height,$name,$parameterA,$strict,$xAxisType) =
        $self->get(qw/height name parameters strict xAxisType/);

    # Kein Code, wenn keine Parameter

    if (!@$parameterA) {
        return '';
    }

    # Multi-Attribute (betreffen mehrere Plotly-Attribute)

    my $color = '#ff0000';
    # ---
    my $axisBox = 1; # Zeichne eine Box um den Plotbereich. Die Box hat
        # die Farbe der Achsen (siehe axisColor).

    # Einzel-Attribute (betreffen einzelnes Plotly-Attribut)

    # Maße für die Ränder

    my $topMargin = 45;

    # date: 250->100,300->110,350->120,400->130,450->140,...
    # linear: ?
    # FIXME: $xAxisLabelHeight in Berechnung einbeziehen
    my $bottomMargin = ($height-300)/50*10+($xAxisType eq 'date'? 100: 90);

    my $axisColor = '#d0d0d0'; # Farbe der Achsenlinien
    my $fillColor = '#e0e0e0'; # Farbe zwischen Kurve und X-Achse
    my $gridColor = '#e8e8e8'; # Farbe des Gitters
    my $lineColor = $color;
    my $lineShape = 'spline'; # Linienform: 'spline'|'linear'|'hv'|
        # 'vh'|'hvh'|'vhv'
    my $lineWidth = 1;
    my $margin = [$topMargin,undef,$bottomMargin,undef];
    my $markerColor = $color;
    my $markerSize = 3;
    my $markerSymbol = 'circle';
    my $mode = 'lines'; # Kurvendarstellung: 'lines', 'markers',
        # 'text', 'none'. Die ersteren drei können auch mit '+' verbunden
        # werden.
    my $paperBackground = '#f8f8f8'; # Hintergrund Diagrammbereich
    my $plotBackground = '#ffffff'; # Hintergrund Plotbereich
    my $rangeSliderBorderColor = '#e0e0e0';

    my ($xAxisHoverFormat,$xAxisTickFormat,$xAxisLabelHeight);
    if ($xAxisType eq 'date') {
        $xAxisHoverFormat = '%Y-%m-%d %H:%M:%S'; # Format der
            # Spike-Beschriftung für die X-Koordinate. Siehe:
            # https://github.com/d3/d3-3.x-api-reference/blob/master/\
            # Time-Formatting.md#format
        $xAxisTickFormat = '%Y-%m-%d %H:%M'; # Format der
            # Zeitachsen-Beschriftung
        $xAxisLabelHeight = 55;
    }
    else { # 'linear'
        $xAxisLabelHeight = 40;
    }

    my $xTickLen = 5;
    my $ySide = 'left'; # Seite, auf der die Y-Achse gezeichnet wird
    my $yTickLen = 4;
    my $zeroLineColor = '#d0d0d0';

    my $height1 = $height-($bottomMargin-$xAxisLabelHeight);
    my $bottomMargin1 = $bottomMargin-($bottomMargin-$xAxisLabelHeight);

    my $titleY = 1-(15/$height); # Faktor für Titel-Position
    my $titleY1 = 1-($height*(1-$titleY)/$height1);

    my $title = undef;
    my $yTitle = undef;
    my $xMin = undef;
    my $xMax = undef;
    my $yMin = -1;
    my $yMax = 1;

    # HTML-Code

    my $html = '';

    my $i = 0;
    for my $par (@$parameterA) {
        $html .= $self->htmlDiagram($h,++$i,$par,$paperBackground);
    }

    my $j = Quiq::Json->new;

    my $js = Quiq::JavaScript->code(
        __NAME__ => $name,
        __TRACE__ => scalar $j->o(
            type => 'scatter',
            mode => $mode, # lines, markers, lines+markers, none,
            fill => 'tozeroy',
            fillcolor => $fillColor,
            line => $j->o(
                width => $lineWidth,
                color => $lineColor,
                shape => $lineShape,
            ),
            marker => $j->o(
                size => $markerSize,
                color => $color, # [....] Einzelfarben
                symbol => $markerSymbol,
                colorscale => undef,
            ),
            x => [],
            y => [],
        ),
        __LAYOUT__ => scalar $j->o(
            plot_bgcolor => $plotBackground,
            paper_bgcolor => $paperBackground,
            title => $j->o(
                text => $title,
                font => $j->o(
                    color => $color,
                ),
                yref => 'container', # container, paper
                yanchor => 'top',
                y => $titleY,
            ),
            spikedistance => -1,
            height => $height,
            margin => $j->o(
                l => $margin->[3],
                r => $margin->[1],
                t => $margin->[0],
                b => $margin->[2],
                autoexpand => \'false',
            ),
            xaxis => $j->o(
                type => $xAxisType, # 'date', 'linear',
                fixedrange => \'false', # Zoom erlauben
                mirror => $axisBox? \'true': undef,
                linecolor => $axisColor,
                #defined($xMin) && defined($xMax)? (range => [$xMin,$xMax]):
                #    (autorange => \'true'),
                # autorange => \'true',
                gridcolor => $gridColor,
                hoverformat => $xAxisHoverFormat,
                # tickformat => $xAxisTickFormat,
                # tickangle => 30,
                ticklen => $xTickLen,
                tickcolor => $axisColor,
                #tickformatstops => [
                #],
                showspikes => \'true',
                spikethickness => 1,
                spikesnap => 'data',
                spikecolor => '#000000',
                spikedash => 'dot',
                rangeslider => $j->o(
                    autorange => \'true',
                    bordercolor => $rangeSliderBorderColor,
                    borderwidth => 1,
                    thickness => 0.20,
                    # visible => \'false',
                    visible => \'true',
                ),
                zeroline => \'true',
                zerolinecolor => $zeroLineColor,
            ),
            yaxis => $j->o(
                type => 'linear',
                fixedrange => \'true', # Zoom verbieten
                automargin => \'true',
                mirror => $axisBox? \'true': undef,
                linecolor => $axisColor,
                defined($yMin) && defined($yMax)? (range => [$yMin,$yMax]):
                    (autorange => \'true'),
                # autorange => \'true',
                ticklen => $yTickLen,
                tickcolor => $axisColor,
                gridcolor => $gridColor,
                showspikes => \'true',
                side => $ySide,
                spikethickness => 1,
                spikesnap => 'data',
                spikecolor => '#000000',
                spikedash => 'dot',
                title => $j->o(
                    text => $yTitle,
                    font => $j->o(
                        color => $color,
                    ),
                ),
                zeroline => \'true',
                zerolinecolor => $zeroLineColor,
            ),
        ),
        __CONFIG__ => scalar $j->o(
            displayModeBar => \'false',
            doubleClickDelay => 1000, # 1000ms
            responsive => \'true',
        ),
        __VARS__ => scalar $j->o(
            height => [$height,$height1],
            bottomMargin => [$bottomMargin,$bottomMargin1],
            titleY => [$titleY,$titleY1],
            strict => $strict? \'true': \'false',
        ),q°
        var __NAME__ = (function() {
            // Datenstrukturen
            
            let trace = __TRACE__;
            let layout = __LAYOUT__;
            let config = __CONFIG__;
            let vars = __VARS__;

            // Methoden

            let setRangeSlider = function (groupId,i,bool) {
                let dId = groupId+'-d'+i;
                if (bool) {
                    Plotly.relayout(dId,{
                        'xaxis.rangeslider.visible': true,
                        'xaxis.fixedrange': false,
                        'height': vars.height[0],
                        'margin.b': vars.bottomMargin[0],
                        'title.y': vars.titleY[0],
                    });
                    $('#'+dId).height(vars.height[0]);
                }
                else {
                    Plotly.relayout(dId,{
                        'xaxis.rangeslider.visible': false,
                        'xaxis.fixedrange': true,
                        'height': vars.height[1],
                        'margin.b': vars.bottomMargin[1],
                        'title.y': vars.titleY[1],
                    });
                    $('#'+dId).height(vars.height[1]);
                }
                let cbId = groupId+'-r'+i;
                $('#'+cbId).prop('checked',bool);
                let div = $('#'+dId)[0];
                if (bool) {
                    // Event-Listener auf das aktive (es sollte nur
                    // eins geben) Diagramm setzen. Der Event-Handler
                    // überträgt die Änderungen am xrange auf alle
                    // anderen Diagramme. Probleme hierbei: 1) Der Event wird
                    // nicht nur bei der Bereichsauswahl und beim
                    // Scrollen ausgelöst. 2) Die Erkennung des richtigen
                    // Events am Eventdata-Objekt ed ist schwierig, da
                    // der xrange auf verschiedene Weisen dargestellt wird
                    // (siehe console.log()). Daher nutzen wir
                    // ed['height'] === undefined zur Erkennung.
                    div.on('plotly_relayout',function(ed) {
                        // console.log(JSON.stringify(ed,null,4));
                        $('#'+groupId+' '+'.diagram').each(function(j) {
                            if (j+1 != i && ed['height'] === undefined) {
                                Plotly.relayout(this,ed);
                            }
                        });
                    });
                }
            };

            let toggleRangeSliders = function (groupId,e) {
                // Event-Listener von allen Diagrammen entfernen
                $('#'+groupId+' .diagram').each(function(i) {
                    this.removeAllListeners('plotly_relayout');
                });
                $('#'+groupId+' .checkbox-rangeslider').each(function(i) {
                    i++;
                    // Beim angeklickten Rangeslider stellen wir den
                    // gewählten Zustand ein, die anderen schalten wir weg
                    let state = this == e? this.checked: false;
                    setRangeSlider(groupId,i,state);
                });
            };

            let loadData = function (dId,trace,url) {
                // Daten per Ajax besorgen
                console.log(url);
                $.ajax({
                    type: 'GET',
                    url: url,
                    async: true,
                    beforeSend: function () {
                        $('body').css('cursor','wait');
                    },
                    complete: function () {
                        $('body').css('cursor','default');
                    },
                    error: function () {
                        let msg = 'ERROR: Ajax request failed: '+url;
                        if (vars.strict) 
                            alert(msg);
                        else
                            console.log(msg);
                    },
                    success: function (data,textStatus,jqXHR) {
                        trace.x = [];
                        trace.y = [];
                        let colors = [];
                        let rows = data.split('\n');
                        for (var i = 0; i < rows.length-1; i++) {
                            let arr = rows[i].split('\t');
                            trace.x.push(arr[0]);
                            trace.y.push(parseFloat(arr[1]));
                            if (arr.length > 2)
                                colors.push(arr[2]);
                        }
                        if (colors.length)
                            trace.marker.color = colors;
                        Plotly.deleteTraces(dId,0);
                        Plotly.addTraces(dId,trace);
                    },
                });
            };

            let generatePlot = function (name,i,title,yTitle,color,~
                    xMin,xMax,yMin,yMax,rangeSlider,url,x,y,z) {

                let t = $.extend(true,{},trace);
                t.line.color = color;
                // Direkt übergebene Daten (kann leer sein)
                t.x = x;
                t.y = y;
                t.marker.color =
                    typeof z !== 'undefined' && z.length? z: color;

                let l = $.extend(true,{},layout);
                l.title.text = title;
                l.title.font.color = color;
                l.xaxis.range = [xMin,xMax];
                l.yaxis.title.text = yTitle;
                l.yaxis.title.font.color = color;
                l.yaxis.range = [yMin,yMax];

                let dId = name+'-d'+i;
                Plotly.newPlot(dId,[t],l,config).then(
                    function() {
                        if (url) {
                            loadData(dId,t,url);
                        }
                    },
                    function() {
                        alert('ERROR: plot creation failed: '+title);
                    }
                );
                setRangeSlider(name,i,rangeSlider);
            };

            return {
                generatePlot: generatePlot,
                setRangeSlider: setRangeSlider,
                toggleRangeSliders: toggleRangeSliders,
            };
        })();
    °);
    # Ready-Handler

    my $tmp = '';
    $i = 0;
    for my $par (@$parameterA) {
        $tmp .= $self->jsDiagram($j,++$i,$par);
    }
    $js .= Quiq::JQuery::Function->ready($tmp);

    return $h->cat(
        $h->tag('div',
            id => $name,
            class => 'diagramGroup',
            '-',
            $html,
        ),
        $h->tag('script',
            $js,
        ),
    );
}

# -----------------------------------------------------------------------------

=head2 Private Methoden

=head3 htmlDiagram() - Generiere HTML für ein Diagramm

=head4 Synopsis

  $html = $dgr->htmlDiagram($h,$i);

=head4 Arguments

=over 4

=item $h

Generator für HTML-Code.

=item $i

Nummer des Diagramms.

=back

=head4 Returns

HTML-Code (String)

=head4 Description

Genererie den HTML-Code für ein Diagramm und liefere diesen zurück.

=cut

# -----------------------------------------------------------------------------

sub htmlDiagram {
    my ($self,$h,$i,$par,$paperBackground) = @_;

    # Objektattribute

    my ($height,$name) = $self->get(qw/height name/);

    # HTML erzeugen

    my $parameterName = $par->name;
    return Quiq::Html::Table::Simple->html($h,
        width => '100%',
        style => [
            border => '1px dotted #b0b0b0',
           'margin-top' => '0.6em',
           'background-color' => $paperBackground,
           
        ],
        rows => [
            [[
                id => "$name-d$i",
                class => 'diagram',
                style => [
                    height => "${height}px",
                ],
            ]],
            [[
                $h->tag('span',style=>'margin-left: 0.5em','Rangeslider:').
                Quiq::Html::Widget::CheckBox->html($h,
                     id =>  "$name-r$i",
                     class => 'checkbox-rangeslider',
                     option => 1,
                     value => 0,
                     style => 'vertical-align: middle',
                     title => 'Toggle visibility of range slider',
                     onClick => "$name.toggleRangeSliders('$name',this)",
                ).
                ' | Shape: '.Quiq::Html::Widget::SelectMenu->html($h,
                    id => "$name-s$i",
                    options => [
                        'Spline',
                        'Linear',
                        'Marker',
                    ],
                    onChange => Quiq::JavaScript->line(qq~
                        var shape = \$('#$name-s$i').val();
                        if (shape == 'Spline') {
                            Plotly.restyle('$name-d$i',{
                                'mode': 'lines',
                                'line.shape': 'spline',
                            });
                        }
                        else if (shape == 'Marker') {
                            Plotly.restyle('$name-d$i',{
                                'mode': 'markers',
                            });
                        }
                        else { // Linear
                            Plotly.restyle('$name-d$i',{
                                'mode': 'lines',
                                'line.shape': 'linear',
                            });
                        }
                    ~),
                    title => 'Connect data points with straight lines,'.
                        ' splines or show markers',
                ).
                ' | '.Quiq::Html::Widget::Button->html($h,
                    content => 'Download as PNG',
                    onClick => qq~
                        let plot = \$('#$name-d$i');
                        Plotly.downloadImage(plot[0],{
                            format: 'png',
                            width: plot.width(),
                            height: plot.height(),
                            filename: '$parameterName',
                        });
                    ~,
                    title => 'Download plot graphic as PNG',
                ),
           ]]
        ],
    );
}

# -----------------------------------------------------------------------------

=head3 jsDiagram() - Generiere JavaScript für ein Diagramm

=head4 Synopsis

  $js = $dgr->jsDiagram($j,$i,$par);

=head4 Arguments

=over 4

=item $j

JSON-Generator

=item $i

Nummer des Diagramms.

=item $par

Zeitreihen-Objekt.

=back

=head4 Returns

JavaScript-Code (String)

=head4 Description

Genererie den JavaScript-Code für ein Diagramm und liefere diesen zurück.

=cut

# -----------------------------------------------------------------------------

sub jsDiagram {
    my ($self,$j,$i,$par) = @_;

    # Objektattribute

    my $name = $self->get('name');

    # JavaScript erzeugen

    my $xMin = $par->xMin // 'undefined';
    my $xMax = $par->xMax // 'undefined';
    my $yMin = $par->yMin // 'undefined';
    my $yMax = $par->yMax // 'undefined';
    my $rangeSlider = $i == 1? 'true': 'false';

    my $url = $par->url;
    if ($url) {
        return sprintf("$name.generatePlot('%s',%s,'%s','%s','%s','%s'".
                ",'%s',%s,%s,%s,'%s');\n",
            $name,$i,$par->name,$par->unit,$par->color,
            $xMin,$xMax,$yMin,$yMax,$rangeSlider,$url);
    }
    else {
        # mit x,y,z
        return sprintf("$name.generatePlot('%s',%s,'%s','%s','%s','%s'".
                ",'%s',%s,%s,%s,'',%s,%s,%s);\n",
            $name,$i,$par->name,$par->unit,$par->color,
            $xMin,$xMax,$yMin,$yMax,$rangeSlider,
            scalar($j->encode($par->x)),scalar($j->encode($par->y)),
            scalar($j->encode($par->z)));
    }
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.186

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