#!/usr/bin/env perl

package R1::Misc::Test;
use base qw/Quiq::Test::Class/;

use v5.10;
use strict;
use warnings;
use utf8;

use Test::More;
use R1::Array;

# -----------------------------------------------------------------------------

sub test_loadClass : Init(1) {
    shift->useOk('R1::Misc');
}

# -----------------------------------------------------------------------------

sub test_strNewline : Test(4) {
    my $self = shift;

    my $val = R1::Misc->strNewline('CR');
    is $val,"\cM",'strNewline: CR';

    $val = R1::Misc->strNewline('CRLF');
    is $val,"\cM\cJ",'strNewline: CRLF';

    $val = R1::Misc->strNewline('LF');
    is $val,"\cJ",'strNewline: LF';

    eval { R1::Misc->strNewline('XX') };
    like $@,qr/FH-00014/,'strNewline: Exception';
}

# -----------------------------------------------------------------------------

sub test_strSingleSpaced : Test(1) {
    my $self = shift;

    my $str = R1::Misc->strSingleSpaced("a\nb\tc\t\\\r\n");
    is $str,'a\\nb\\tc\\t\\\\\\r\\n','strSingleSpaced';
}

# -----------------------------------------------------------------------------

sub test_dieUsage : Test(4) {
    my $self = shift;

    # Kein Argument

    eval { R1::Misc->dieUsage };
    like $@,qr/^Fehlerhafter Programmaufruf.*: 2/,'dieUsage: kein Argument';

    # -exitCode

    eval { R1::Misc->dieUsage('',-exitCode=>5) };
    like $@,qr/^Fehlerhafter Programmaufruf.*: 5/,'dieUsage: -exitCode';

    # -error

    eval { R1::Misc->dieUsage('',-error=>'FEHLER: Argument fehlt') };
    like $@,qr/^FEHLER: Argument fehlt/,'dieUsage: -error';

    # usage

    my $usage = Quiq::String->removeIndentation(<<'    __EOT__');
    Usage: myprog [OPTIONS] FILE
      --quiet=0|1 : Erzeuge keine Ausgabe.
    __EOT__

    eval { R1::Misc->dieUsage($usage) };
    like $@,qr/^\Q$usage\E$/,'dieUsage: -usage';
}

# -----------------------------------------------------------------------------

sub test_argExtract_strict : Test(7) {
    my $self = shift;

    my $mode = 'strict';
    my ($x,$y);

    # Alle Optionen ok

    my $test = "$mode test1";
    my $arr = R1::Array->new(-x=>'z',-y=>3);
    R1::Misc->argExtract($arr,-x=>\$x,-y=>\$y);
    is $x,'z',"argExtract: $test - -x";
    is $y,3,"argExtract: $test - -y";
    is $arr->size,0,"argExtract: $test - 0 Elemente";

    # Unerlaubte Option (-y)

    $test = "$mode test2";
    $arr = R1::Array->new(-x=>'z',-y=>3);
    eval { R1::Misc->argExtract($arr,-x=>\$x) };
    like $@,qr/OPT-00001/,"argExtract: $test - Exception";
    like $@,qr/-y/,"argExtract: $test - Option";

    # Unerlaubtes Argument ('aaa')

    $test = "$mode test2";
    $arr = R1::Array->new(-x=>'z','aaa');
    eval { R1::Misc->argExtract($arr,-x=>\$x) };
    like $@,qr/OPT-00001/,"argExtract: $test - Exception";
    like $@,qr/aaa/,"argExtract: $test - Option";
}

sub test_argExtract_strictDash : Test(5) {
    my $self = shift;

    my $mode = 'strict-dash';
    my ($x,$y);

    # Alle Optionen ok

    my $test = "$mode test1";
    my $arr = R1::Array->new('a',-x=>'z','b',-y=>3,'c');
    R1::Misc->argExtract(-mode=>$mode,$arr,-x=>\$x,-y=>\$y);
    is $x,'z',"argExtract: $test - -x";
    is $y,3,"argExtract: $test - -y";
    is_deeply $arr,['a','b','c'],"argExtract: $test - Restliste";

    # Unerlaubte Option (-y)

    $test = "$mode test2";
    $arr = R1::Array->new('a',-x=>'z','b',-y=>3,'c');
    eval { R1::Misc->argExtract(-mode=>$mode,$arr,-x=>\$x) };
    like $@,qr/OPT-00001/,"argExtract: $test - Exception";
    like $@,qr/-y/,"argExtract: $test - Option";
}

sub test_argExtract_sloppy : Test(3) {
    my $self = shift;

    my $mode = 'sloppy';
    my ($x,$y);

    # -x und -y werden extrahiert, der Rest bleibt

    my $test = "$mode test1";
    my $arr = R1::Array->new('a',-x=>'z','b',-y=>3,'c');
    R1::Misc->argExtract(-mode=>$mode,$arr,-x=>\$x,-y=>\$y);
    is $x,'z',"argExtract: $test - -x";
    is $y,3,"argExtract: $test - -y";
    is_deeply $arr,['a','b','c'],"argExtract: $test - Restliste";
}

sub test_argExtract_stop : Test(3) {
    my $self = shift;

    my $mode = 'stop';
    my ($x,$y);

    # -x und -y werden extrahiert, auf 'a' wird gestoppt

    my $test = "$mode test1";
    my $arr = R1::Array->new(-x=>'z',-y=>3,'a','b','c');
    R1::Misc->argExtract(-mode=>$mode,$arr,-x=>\$x,-y=>\$y);
    is $x,'z',"argExtract: $test - -x";
    is $y,3,"argExtract: $test - -y";
    is_deeply $arr,['a','b','c'],"argExtract: $test - Restliste";
}

sub test_argExtract_noValue : Test(2) {
    my $self = shift;

    my $mode = 'strict';
    my ($x,$y);

    # Option -y hat keinen Wert

    my $test = "Option -y hat keinen Wert";
    my $arr = R1::Array->new(-x=>'z','-y');
    eval { R1::Misc->argExtract($arr,-x=>\$x,-y=>\$y) };
    like $@,qr/OPT-00003/,"argExtract: $test - Exception";
    like $@,qr/-y/,"argExtract: $test - Option";
}

sub test_argExtract_progOpts : Test(3) {
    my $self = shift;

    my ($x,$y);

    # -progOpts=>1: Optionen können Strings mit '=' als Trennzeichen sein

    my $test = "-progOpts";
    my $arr = R1::Array->new('--x=z','--y=3');
    R1::Misc->argExtract(-progOpts=>1,$arr,'--x'=>\$x,'--y'=>\$y);
    is $x,'z',"argExtract: $test - --x";
    is $y,3,"argExtract: $test - --y";
    is $arr->size,0,"argExtract: $test - 0 Elemente";
}

sub test_argExtract_doubleDashOpts : Test(3) {
    my $self = shift;

    my ($x,$y);

    my $arr = R1::Array->new('--x=z','--y=3');
    R1::Misc->argExtract($arr,'-x'=>\$x,'-y'=>\$y);
    is $x,'z';
    is $y,3;
    is $arr->size,0;
}

sub test_argExtract_returnHash : Test(3) {
    my $self = shift;

    my $arr = R1::Array->new('--x=z','--y=3');
    my $opt = R1::Misc->argExtract(-progOpts=>1,-returnHash=>1,$arr,
        '--x'=>'a',
        '--y'=>0,
        '--z'=>'x',
    );
    is $opt->get('x'),'z';
    is $opt->get('y'),'3';
    is $opt->get('z'),'x';
}

sub test_argExtract_returnHash_toDash : Test(3) {
    my $self = shift;

    my $arr = R1::Array->new('--opt-one=z','--opt-two=3');
    my $opt = R1::Misc->argExtract(-progOpts=>1,-returnHash=>1,-dashTo=>'camel',$arr,
        '--opt-one'=>'a',
        '--opt-two'=>0,
        '--opt-three'=>'x',
    );
    is $opt->get('optOne'),'z';
    is $opt->get('optTwo'),'3';
    is $opt->get('optThree'),'x';
}

sub test_argExtract_toDash : Test(3) {
    my $self = shift;

    my $optOne = 'a';
    my $optTwo = 0;
    my $optThree = 'x';

    my $arr = 
    my $opt = R1::Misc->argExtract(-dashTo=>'camel',
        R1::Array->new(
            '--opt-one=z',
            '--opt-two=3',
        ),
        -optOne=>\$optOne,
        -optTwo=>\$optTwo,
        -optThree=>\$optThree,
    );
    is $optOne,'z';
    is $optTwo,'3';
    is $optThree,'x';
}

# -----------------------------------------------------------------------------

sub test_nlStr : Test(4) {
    my $self = shift;

    my $val = R1::Misc->nlStr('CR');
    is $val,"\cM",'nlStr: CR';

    $val = R1::Misc->nlStr('LF');
    is $val,"\cJ",'nlStr: LF';

    $val = R1::Misc->nlStr('CRLF');
    is $val,"\cM\cJ",'nlStr: CRLF';

    eval { R1::Misc->nlStr('XX') };
    like $@,qr/NL-00001/,'nlStr: ungültiger Bezeichner';
}

# -----------------------------------------------------------------------------

package main;
R1::Misc::Test->runTests;

# eof
