package Quiq::ChartJs::TimeSeries;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.166';

use Quiq::Unindent;
use Quiq::Template;

# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::ChartJs::TimeSeries - Erzeuge Zeitreihen-Plot auf Basis von Chart.js

=head1 BASE CLASS

L<Quiq::Hash>

=head1 SYNOPSIS

Modul laden:

  use Quiq::ChartJs::TimeSeries;

Objekt instantiieren (@rows: Zeit/Wert mit TAB getrennt):

  my $ch = Quiq::ChartJs::TimeSeries->new(
      parameter => 'Windspeed',
      unit => 'm/s',
      aspectRatio => 8/2.2,
      points => \@rows,
      pointCallback => sub {
           my ($point,$i) = @_;
           my ($iso,$val) = split /\t/,$point,2;
           return [Quiq::Epoch->new($iso)->epoch*1000,$val];
      },
  );

Code generieren:

  my $h = Quiq::Html::Producer->new;
  my $html = Quiq::Html::Fragment->html($h,
      html => $h->cat(
          $h->tag('script',
              src => $ch->cdnUrl('2.8.0'),
          ),
          $h->tag('canvas',
              id => $ch->name,
          ),
          $ch->html($h),
      ),
  );

Diagramm:

=format html

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.8.0/Chart.bundle.min.js" type="text/javascript"></script>
<canvas id="plot"></canvas>
<script type="text/javascript">
  Chart.defaults.global.defaultFontSize = 12;
  Chart.defaults.global.animation.duration = 1000;
  var plotCtx = document.getElementById('plot').getContext('2d');
  plotCtx.canvas.width = 1000;
  plotCtx.canvas.height = 275;
  var plot = new Chart(plotCtx,{
      type: 'line',
      data: {
        datasets: [{
          type: 'line',
          fill: true,
          borderColor: 'rgb(255,0,0,1)',
          borderWidth: 1,
          pointRadius: 0,
          data: [{t:1573167600000,y:11.142},{t:1573168200000,y:11.524},{t:1573168800000,y:10.343},{t:1573169400000,y:10.604},{t:1573170000000,y:11.824},{t:1573170600000,y:11.266},{t:1573171200000,y:10.642},{t:1573171800000,y:10.093},{t:1573172400000,y:9.1365},{t:1573173000000,y:8.6981},{t:1573173600000,y:8.5784},{t:1573174200000,y:8.83},{t:1573174800000,y:8.9365},{t:1573175400000,y:8.6053},{t:1573176000000,y:8.0124},{t:1573176600000,y:9.2907},{t:1573177200000,y:8.8921},{t:1573177800000,y:8.4226},{t:1573178400000,y:8.361},{t:1573179000000,y:8.3603},{t:1573179600000,y:9.092},{t:1573180200000,y:8.8321},{t:1573180800000,y:9.0572},{t:1573181400000,y:8.076},{t:1573182000000,y:8.0475},{t:1573182600000,y:8.5653},{t:1573183200000,y:8.5676},{t:1573183800000,y:7.909},{t:1573184400000,y:8.3279},{t:1573185000000,y:8.9462},{t:1573185600000,y:8.2227},{t:1573186200000,y:7.4135},{t:1573186800000,y:7.1417},{t:1573187400000,y:6.1413},{t:1573188000000,y:6.1684},{t:1573188600000,y:6.2048},{t:1573189200000,y:6.0224},{t:1573189800000,y:5.8958},{t:1573190400000,y:6.21},{t:1573191000000,y:6.0992},{t:1573191600000,y:6.102},{t:1573192200000,y:5.7212},{t:1573192800000,y:5.757},{t:1573193400000,y:5.6007},{t:1573194000000,y:5.2626},{t:1573194600000,y:6.162},{t:1573195200000,y:6.5931},{t:1573195800000,y:7.0725},{t:1573196400000,y:7.9139},{t:1573197000000,y:7.9366},{t:1573197600000,y:7.7247},{t:1573198200000,y:8.1006},{t:1573198800000,y:8.5755},{t:1573199400000,y:8.3681},{t:1573200000000,y:8.9414},{t:1573200600000,y:8.9655},{t:1573201200000,y:8.6273},{t:1573201800000,y:8.8311},{t:1573202400000,y:8.5993},{t:1573203000000,y:8.4938},{t:1573203600000,y:9.0882},{t:1573204200000,y:8.9791},{t:1573204800000,y:9.151},{t:1573205400000,y:8.9804},{t:1573206000000,y:9.9322},{t:1573206600000,y:10.229},{t:1573207200000,y:10.446},{t:1573207800000,y:9.6706},{t:1573208400000,y:9.3077},{t:1573209000000,y:9.2482},{t:1573209600000,y:9.4737},{t:1573210200000,y:9.4784},{t:1573210800000,y:9.4391},{t:1573211400000,y:10.082},{t:1573212000000,y:9.593},{t:1573212600000,y:10.762},{t:1573213200000,y:12.304},{t:1573213800000,y:12.765},{t:1573214400000,y:12.355},{t:1573215000000,y:12.684},{t:1573215600000,y:12.551},{t:1573216200000,y:13.121},{t:1573216800000,y:12.812},{t:1573217400000,y:12.482},{t:1573218000000,y:11.992},{t:1573218600000,y:12.023},{t:1573219200000,y:11.725},{t:1573219800000,y:11.585},{t:1573220400000,y:10.989},{t:1573221000000,y:11.135},{t:1573221600000,y:10.723},{t:1573222200000,y:11.035},{t:1573222800000,y:10.564},{t:1573223400000,y:11.13},{t:1573224000000,y:11.677},{t:1573224600000,y:12.908},{t:1573225200000,y:12.973},{t:1573225800000,y:12.511},{t:1573226400000,y:11.842},{t:1573227000000,y:11.4},{t:1573227600000,y:11.058},{t:1573228200000,y:11.949},{t:1573228800000,y:12.081},{t:1573229400000,y:12.505},{t:1573230000000,y:13.937},{t:1573230600000,y:12.72},{t:1573231200000,y:13.891},{t:1573231800000,y:11.878},{t:1573232400000,y:9.9409},{t:1573233000000,y:8.8398},{t:1573233600000,y:8.2837},{t:1573234200000,y:7.7194},{t:1573234800000,y:8.6815},{t:1573235400000,y:9.6036},{t:1573236000000,y:11.517},{t:1573236600000,y:14.246},{t:1573237200000,y:14.132},{t:1573237800000,y:15.098},{t:1573238400000,y:13.865},{t:1573239000000,y:14.74},{t:1573239600000,y:12.647},{t:1573240200000,y:12.552},{t:1573240800000,y:15.178},{t:1573241400000,y:14.983},{t:1573242000000,y:13.649},{t:1573242600000,y:13.731},{t:1573243200000,y:12.781},{t:1573243800000,y:15.184},{t:1573244400000,y:12.77},{t:1573245000000,y:13.275},{t:1573245600000,y:13.662},{t:1573246200000,y:16.822},{t:1573246800000,y:12.808},{t:1573247400000,y:12.394},{t:1573248000000,y:10.968},{t:1573248600000,y:12.761},{t:1573249200000,y:17.678},{t:1573249800000,y:11.119},{t:1573250400000,y:15.816},{t:1573251000000,y:15.469},{t:1573251600000,y:12.171},{t:1573252200000,y:13.475},{t:1573252800000,y:14.389},{t:1573253400000,y:12.486},{t:1573254000000,y:13.798},{t:1573254600000,y:15.288},{t:1573255200000,y:14.633},{t:1573255800000,y:13.796},{t:1573256400000,y:14.099},{t:1573257000000,y:16.695},{t:1573257600000,y:16.372},{t:1573258200000,y:13.929},{t:1573258800000,y:12.818},{t:1573259400000,y:14.77},{t:1573260000000,y:14.347},{t:1573260600000,y:11.71},{t:1573261200000,y:14.4},{t:1573261800000,y:14.35},{t:1573262400000,y:14.865},{t:1573263000000,y:13.146},{t:1573263600000,y:13.731},{t:1573264200000,y:13.54},{t:1573264800000,y:17.228},{t:1573265400000,y:13.228},{t:1573266000000,y:14.566},{t:1573266600000,y:16.707},{t:1573267200000,y:13.462},{t:1573267800000,y:12.916},{t:1573268400000,y:16.215},{t:1573269000000,y:15.192},{t:1573269600000,y:14.956},{t:1573270200000,y:17.472},{t:1573270800000,y:17.036},{t:1573271400000,y:17.063},{t:1573272000000,y:17.796},{t:1573272600000,y:18.718},{t:1573273200000,y:17.825},{t:1573273800000,y:17.535},{t:1573274400000,y:17.69},{t:1573275000000,y:15.962},{t:1573275600000,y:16.488},{t:1573276200000,y:17.399},{t:1573276800000,y:18.279},{t:1573277400000,y:18.915},{t:1573278000000,y:17.873},{t:1573278600000,y:16.229},{t:1573279200000,y:16.082},{t:1573279800000,y:19.299},{t:1573280400000,y:19.502},{t:1573281000000,y:19.92},{t:1573281600000,y:19.444},{t:1573282200000,y:17.233},{t:1573282800000,y:19.616},{t:1573283400000,y:19.508},{t:1573284000000,y:17.576},{t:1573284600000,y:18.238},{t:1573285200000,y:18.105},{t:1573285800000,y:18.993},{t:1573286400000,y:18.873},{t:1573287000000,y:17.888}],
        }],
      },
      options: {
        title: {
          display: true,
          text: 'Windspeed',
          fontSize: 16,
          fontStyle: 'normal',
        },
        tooltips: {
          intersect: false,
          displayColors: false,
          backgroundColor: 'rgb(0,0,0,0.6)',
          titleMarginBottom: 2,
          callbacks: {
            label: function(tooltipItem,data) {
              return 'Windspeed: ' + tooltipItem.value
                + ' m/s';
            },
          },
        },
        legend: {
          display: false,
        },
        scales: {
          xAxes: [{
            type: 'time',
            time: {
              min: undefined,
              max: undefined,
              minUnit: 'second',
              displayFormats: {
                second: 'YYYY-MM-DD HH:mm:ss',
                minute: 'YYYY-MM-DD HH:mm',
                hour: 'YYYY-MM-DD HH',
                day: 'YYYY-MM-DD',
                week: 'YYYY-MM-DD',
                month: 'YYYY-MM',
                quarter: 'YYYY [Q]Q',
                year: 'YYYY',
              },
              tooltipFormat: 'YYYY-MM-DD HH:mm:ss',
            },
          }],
          yAxes: [{
            ticks: {
              min: undefined,
              max: undefined,
            },
            scaleLabel: {
              display: true,
              labelString: 'm/s',
            },
          }],
        }
      }
    }
  );
</script>

=end html

=head1 DESCRIPTION

Erzeuge einen Zeitreihen-Plot auf Basis von Chart.js. Chart.js ist
eine JavaScript-Bibliothek zum Plotten von Diagrammen auf einen
HTML5 <canvas>.

=head1 SEE ALSO

=over 2

=item *

L<https://www.chartjs.org>

=item *

L<https://github.com/chartjs/Chart.js>

=back

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $ch = $class->new(@attVal);

=head4 Attributes

=over 4

=item aspectRatio => $ratio (Default: 8/1.5)

Die Größe der Zeichenfläche des Diagramms wird nicht durch Angabe
von Breite und Höhe festgelegt, sondern durch das Seitenverhältnis.
Die absolute Größe ergibt sich aus dem verfügbaren Raum auf der Seite.

=item lineColor => $color (Default: 'rgb(255,0,0,1)')

Die Linienfarbe.

=item name => $name (Default: 'plot')

Name des Plot. Der Name wird als CSS-Id für die Zeichenfläche
(Canvas) und als Variablenname für die Instanz verwendet.

=item parameter => $name

Der Name des dargestellten Parameters.

=item points => \@points (Default: [])

Liste der Datenpunkte oder - alternativ - der Elemente, aus denen
die Datenpunkte mittels der Methode pointCallback (s.u.) gewonnen
werden.  Ein Datenpunkt ist ein Array mit zwei numerischen Werten
[$x, $y], wobei $x ein JavaScript Epoch-Wert (Unix Epoch in
Millisekunden) ist und $y ein beliebiger Y-Wert.

=item pointCallback => $sub (Default: undef)

Referenz auf eine Subroutine, die fr jedes Element der Liste @points
einen Datenpunkt liefert, wie ihn die Klasse erwartet (s.o.). Ist kein
rowCallback definiert, werden die Elemente aus @points unverändert
verwendet.

=item pointRadius => $n (Default: 0)

Kennzeichne die Datenpunkte mit einem Kreis des Radius $n. 0 bedeutet,
dass die Datenpunkte nicht gekennzeichnet werden.

=item title => $str (Default: I<Name des Parameters>)

Titel, der über das Diagramm geschrieben wird.

=item tMin => $jsEpoch (Default: 'undefined')

Kleinster Wert auf der Zeitachse. Der Default 'undefined' bedeutet,
dass der Wert aus den Daten ermittelt wird.

=item tMax => $jsEpoch (Default: 'undefined')

Größter Wert auf der Zeitachse. Der Default 'undefined' bedeutet,
dass der Wert aus den Daten ermittelt wird.

=item unit => $str

Einheit des Parameters. Mit der Einheit wird die Y-Achse beschriftet und
sie erscheint im Tooltip.

=item yMin => $val (Default: 'undefined')

Kleinster Wert auf der Y-Achse. Der Default 'undefined' bedeutet,
dass der Wert aus den Daten ermittelt wird.

=item yMax => $val (Default: 'undefined')

Größter Wert auf der Y-Achse. Der Default 'undefined' bedeutet,
dass der Wert aus den Daten ermittelt wird.

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
        aspectRatio => 8/1.5,
        lineColor => 'rgb(255,0,0,1)',
        name => 'plot',
        parameter => undef,
        points => [],
        pointCallback => undef,
        pointRadius => 0,
        title => undef,
        tMin => 'undefined',
        tMax => 'undefined',
        unit => undef,
        yMin => 'undefined',
        yMax => 'undefined',
    );
    $self->set(@_);

    return $self;
}

# -----------------------------------------------------------------------------

=head2 Klassenmethoden

=head3 cdnUrl() - Liefere CDN URL

=head4 Synopsis

  $url = $ch->cdnUrl($version);

=head4 Returns

URL (String)

=head4 Description

Liefere einen CDN URL für Chart.js in der Version $version.

=cut

# -----------------------------------------------------------------------------

sub cdnUrl {
    my ($this,$version) = @_;

    return "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/$version".
        '/Chart.bundle.min.js';
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 html() - Generiere HTML

=head4 Synopsis

  $html = $ch->html($h);
  $html = $class->html($h,@keyVal);

=head4 Returns

JavaScript-Code (String)

=head4 Description

Liefere den HTML-Code der Chart-Instanz.

=cut

# -----------------------------------------------------------------------------

sub html {
    my ($this,$h) = splice @_,0,2;

    my $self = ref $this? $this: $this->new(@_);

    my ($aspectRatio,$lineColor,$name,$parameter,$pointA,
        $pointCallback,$pointRadius,$title,$tMin,$tMax,$unit,$yMin,$yMax) =
        $self->get(qw/aspectRatio lineColor name parameter points
        pointCallback pointRadius title tMin tMax unit yMin yMax/);

    # Datenpunkte in ChartJs-Datenstruktur wandeln

    my $points = '';
    for (my $i = 0; $i < @$pointA; $i++) {
         my $point = $pointA->[$i];
         if ($pointCallback) {
              $point = $pointCallback->($point,$i);
         }
         if ($i) {
             $points .= ',';
         }
         $points .= sprintf '{t:%s,y:%s}',@$point;
    }

    my $template = Quiq::Unindent->string(q~
        Chart.defaults.global.defaultFontSize = 12;
        Chart.defaults.global.animation.duration = 1000;

        var __NAME__Ctx = document.getElementById('__NAME__').getContext('2d');
        __NAME__Ctx.canvas.width = __WIDTH__;
        __NAME__Ctx.canvas.height = __HEIGHT__;

        var __NAME__ = new Chart(__NAME__Ctx,{
                type: 'line',
                data: {
                    datasets: [{
                        type: 'line',
                        fill: true,
                        borderColor: '__LINE_COLOR__',
                        borderWidth: 1,
                        pointRadius: __POINT_RADIUS__,
                        data: [__POINTS__],
                    }],
                },
                options: {
                    title: {
                        display: true,
                        text: '__TITLE__',
                        fontSize: 16,
                        fontStyle: 'normal',
                    },
                    tooltips: {
                        intersect: false,
                        displayColors: false,
                        backgroundColor: 'rgb(0,0,0,0.6)',
                        titleMarginBottom: 2,
                        callbacks: {
                            label: function(tooltipItem,data) {
                                return '__PARAMETER__: ' + tooltipItem.value
                                    + ' __UNIT__';
                            },
                        },
                    },
                    legend: {
                        display: false,
                    },
                    scales: {
                        xAxes: [{
                            type: 'time',
                            time: {
                                min: __T_MIN__,
                                max: __T_MAX__,
                                minUnit: 'second',
                                displayFormats: {
                                    second: 'YYYY-MM-DD HH:mm:ss',
                                    minute: 'YYYY-MM-DD HH:mm',
                                    hour: 'YYYY-MM-DD HH',
                                    day: 'YYYY-MM-DD',
                                    week: 'YYYY-MM-DD',
                                    month: 'YYYY-MM',
                                    quarter: 'YYYY [Q]Q',
                                    year: 'YYYY',
                                },
                                tooltipFormat: 'YYYY-MM-DD HH:mm:ss',
                            },
                        }],
                        yAxes: [{
                            ticks: {
                                min: __Y_MIN__,
                                max: __Y_MAX__,
                            },
                            scaleLabel: {
                                display: true,
                                labelString: '__UNIT__',
                            },
                        }],
                    }
                }
            }
        );
    ~);

    my $tpl = Quiq::Template->new('text',\$template);
    $tpl->replace(
        __NAME__ => $name,
        __WIDTH__ => 1000,
        __HEIGHT__ => int(1000/$aspectRatio),
        __TITLE__ => $title // $parameter,
        __PARAMETER__ => $parameter,
        __UNIT__ => $unit,
        __POINTS__ => $points,
        __T_MIN__ => $tMin,
        __T_MAX__ => $tMax,
        __Y_MIN__ => $yMin,
        __Y_MAX__ => $yMax,
        __LINE_COLOR__ => $lineColor,
        __POINT_RADIUS__ => $pointRadius,
    );

    return $h->tag('script',$tpl->asString);
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.166

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
