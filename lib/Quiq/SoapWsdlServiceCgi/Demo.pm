# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::SoapWsdlServiceCgi::Demo - Demo für SOAP Web Service

=head1 BASE CLASS

L<Quiq::SoapWsdlServiceCgi>

=cut

# -----------------------------------------------------------------------------

package Quiq::SoapWsdlServiceCgi::Demo;
use base qw/Quiq::SoapWsdlServiceCgi/;

use v5.10;
use strict;
use warnings;

our $VERSION = '1.213';

use POSIX ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Service-Methoden

=head3 serverTime() - Liefere lokale Server-Zeit als Zeichenkette

=head4 Synopsis

  $time = $class->serverTime;

=head4 Wsdl

  _RETURN $string

=begin WSDL

  _RETURN $string

=end WSDL

=cut

# -----------------------------------------------------------------------------

sub serverTime {
    my $class = shift;
    return POSIX::strftime('%Y-%m-%d %H:%M:%S',localtime);
}
    

# -----------------------------------------------------------------------------

=head1 VERSION

1.213

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2023 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
