# -----------------------------------------------------------------------------

=encoding utf8

=head1 NAME

Quiq::Zugferd - Generiere das XML für eine ZUGFeRD-Rechnung

=head1 BASE CLASS

L<Quiq::Hash>

=cut

# -----------------------------------------------------------------------------

package Quiq::Zugferd;
use base qw/Quiq::Hash/;

use v5.10;
use strict;
use warnings;
use utf8;

our $VERSION = '1.222';

use Quiq::Unindent;
use Quiq::Path;
use Quiq::Template;
use XML::Compile::Schema ();
use XML::LibXML ();
use XML::Compile::Util ();

# -----------------------------------------------------------------------------

=head1 METHODS

=head2 Konstruktor

=head3 new() - Instantiiere Objekt

=head4 Synopsis

  $zug = $class->new($xsdDir);

=head4 Arguments

=over 4

=item $xsdDir

Verzeichnis mit den ZUGFeRD Schema-Dateien

=back

=head4 Returns

Objekt

=head4 Description

Instantiiere ein Objekt der Klasse und liefere dieses zurück.

=cut

# -----------------------------------------------------------------------------

# __INVOICE_NUMBER__ 008989239
# __INVOICE_TYPECODE__ 380
# __INVOICE_ISSUED__ 20240918
# __INVOICE_TITLE__ Servicerechnung

my $TemplateNote = Quiq::Unindent->string(q~
<ram:IncludedNote>
  <ram:Content>__TEXT__</ram:Content>
</ram:IncludedNote>
~);

my $Prefix = 'urn:un:unece:uncefact:data:standard';
my $Template = Quiq::Unindent->string(qq~
<?xml version='1.0' encoding='UTF-8' ?>

<rsm:CrossIndustryInvoice
    xmlns:rsm="$Prefix:CrossIndustryInvoice:100"
    xmlns:qdt="$Prefix:QualifiedDataType:100"
    xmlns:ram="$Prefix:ReusableAggregateBusinessInformationEntity:100"
    xmlns:udt="$Prefix:UnqualifiedDataType:100">

  <rsm:ExchangedDocumentContext>
    <ram:GuidelineSpecifiedDocumentContextParameter>
      <ram:ID>urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic</ram:ID>
    </ram:GuidelineSpecifiedDocumentContextParameter>
  </rsm:ExchangedDocumentContext>

  <rsm:ExchangedDocument>
    <ram:ID>__INVOICE_NUMBER__</ram:ID>
    <ram:TypeCode>__INVOICE_TYPECODE__</ram:TypeCode>
    <ram:IssueDateTime>
      <udt:DateTimeString format="102">__INVOICE_ISSUED__</udt:DateTimeString>
    </ram:IssueDateTime>
    <!-- 0 .. N -->
    __INVOICE_NOTE_LIST__
    <!-- END -->
  </rsm:ExchangedDocument>

  <rsm:SupplyChainTradeTransaction>
    <ram:IncludedSupplyChainTradeLineItem>
      <ram:AssociatedDocumentLineDocument>
        <ram:LineID>1</ram:LineID>
      </ram:AssociatedDocumentLineDocument>
      <ram:SpecifiedTradeProduct>
        <ram:Name>Grundpreis (Pauschale)</ram:Name>
      </ram:SpecifiedTradeProduct>
      <ram:SpecifiedLineTradeAgreement>
        <ram:NetPriceProductTradePrice>
          <ram:ChargeAmount>3.90</ram:ChargeAmount>
        </ram:NetPriceProductTradePrice>
      </ram:SpecifiedLineTradeAgreement>
      <ram:SpecifiedLineTradeDelivery>
        <ram:BilledQuantity unitCode="C62">1</ram:BilledQuantity>
      </ram:SpecifiedLineTradeDelivery>
      <ram:SpecifiedLineTradeSettlement>
           <ram:ApplicableTradeTax>
       <ram:TypeCode>VAT</ram:TypeCode>
       <ram:CategoryCode>S</ram:CategoryCode>
          <ram:RateApplicablePercent>7</ram:RateApplicablePercent>
        </ram:ApplicableTradeTax>
        <ram:SpecifiedTradeSettlementLineMonetarySummation>
          <ram:LineTotalAmount>3.90</ram:LineTotalAmount>
        </ram:SpecifiedTradeSettlementLineMonetarySummation>
      </ram:SpecifiedLineTradeSettlement>
    </ram:IncludedSupplyChainTradeLineItem>
            <ram:IncludedSupplyChainTradeLineItem>
      <ram:AssociatedDocumentLineDocument>
        <ram:LineID>2</ram:LineID>
      </ram:AssociatedDocumentLineDocument>
      <ram:SpecifiedTradeProduct>
        <ram:Name>Stadtfahrt - 2,00 Euro je gefahrene Kilometer</ram:Name>
      </ram:SpecifiedTradeProduct>
                <ram:SpecifiedLineTradeAgreement>
        <ram:NetPriceProductTradePrice>
          <ram:ChargeAmount>2.00</ram:ChargeAmount>
        </ram:NetPriceProductTradePrice>
      </ram:SpecifiedLineTradeAgreement>
      <ram:SpecifiedLineTradeDelivery>
        <ram:BilledQuantity unitCode="KMT">6.50</ram:BilledQuantity>
      </ram:SpecifiedLineTradeDelivery>
      <ram:SpecifiedLineTradeSettlement>
        <ram:ApplicableTradeTax>
          <ram:TypeCode>VAT</ram:TypeCode>
          <ram:CategoryCode>S</ram:CategoryCode>
          <ram:RateApplicablePercent>7</ram:RateApplicablePercent>
        </ram:ApplicableTradeTax>
        <ram:SpecifiedTradeSettlementLineMonetarySummation>
          <ram:LineTotalAmount>13</ram:LineTotalAmount>
        </ram:SpecifiedTradeSettlementLineMonetarySummation>
      </ram:SpecifiedLineTradeSettlement>
    </ram:IncludedSupplyChainTradeLineItem>
    <ram:ApplicableHeaderTradeAgreement>
      <ram:SellerTradeParty>
        <ram:Name>Taxiunternehmen TX GmbH</ram:Name>
        <ram:PostalTradeAddress>
          <ram:PostcodeCode>10369</ram:PostcodeCode>
          <ram:LineOne>Lieferantenstraße 20</ram:LineOne>
          <ram:CityName>Berlin</ram:CityName>
          <ram:CountryID>DE</ram:CountryID>
        </ram:PostalTradeAddress>
        <ram:SpecifiedTaxRegistration>
          <ram:ID schemeID="VA">DE123456789</ram:ID>
        </ram:SpecifiedTaxRegistration>
      </ram:SellerTradeParty>
      <ram:BuyerTradeParty>
        <ram:Name>Taxi-Gast AG Mitte</ram:Name>
        <ram:PostalTradeAddress>
          <ram:PostcodeCode>13351</ram:PostcodeCode>
          <ram:LineOne>Hans Mustermann</ram:LineOne>
          <ram:LineTwo>Kundenstraße 15</ram:LineTwo>
          <ram:CityName>Berlin</ram:CityName>
          <ram:CountryID>DE</ram:CountryID>
        </ram:PostalTradeAddress>
      </ram:BuyerTradeParty>
    </ram:ApplicableHeaderTradeAgreement>
    <ram:ApplicableHeaderTradeDelivery>
      <ram:ActualDeliverySupplyChainEvent>
        <ram:OccurrenceDateTime>
          <udt:DateTimeString format="102">20241114</udt:DateTimeString>
        </ram:OccurrenceDateTime>
      </ram:ActualDeliverySupplyChainEvent>
    </ram:ApplicableHeaderTradeDelivery>
    <ram:ApplicableHeaderTradeSettlement>
      <ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>
      <ram:ApplicableTradeTax>
        <ram:CalculatedAmount>1.18</ram:CalculatedAmount>
        <ram:TypeCode>VAT</ram:TypeCode>
        <ram:BasisAmount>16.90</ram:BasisAmount>
        <ram:CategoryCode>S</ram:CategoryCode>
        <ram:RateApplicablePercent>7</ram:RateApplicablePercent>
      </ram:ApplicableTradeTax>
      <ram:SpecifiedTradePaymentTerms>
        <ram:DueDateDateTime>
          <udt:DateTimeString format="102">20241215</udt:DateTimeString>
        </ram:DueDateDateTime>
      </ram:SpecifiedTradePaymentTerms>
      <ram:SpecifiedTradeSettlementHeaderMonetarySummation>
        <ram:LineTotalAmount>16.90</ram:LineTotalAmount>
        <ram:ChargeTotalAmount>0.00</ram:ChargeTotalAmount>
        <ram:AllowanceTotalAmount>0.00</ram:AllowanceTotalAmount>
        <ram:TaxBasisTotalAmount>16.90</ram:TaxBasisTotalAmount>
        <ram:TaxTotalAmount currencyID="EUR">1.18</ram:TaxTotalAmount>
        <ram:GrandTotalAmount>18.08</ram:GrandTotalAmount>
        <ram:DuePayableAmount>18.08</ram:DuePayableAmount>
      </ram:SpecifiedTradeSettlementHeaderMonetarySummation>
    </ram:ApplicableHeaderTradeSettlement>
  </rsm:SupplyChainTradeTransaction>
</rsm:CrossIndustryInvoice>
~);

sub new {
    my $class = shift;
    my $xsdDir = shift;

    my $p = Quiq::Path->new;
    if (!$p->exists($xsdDir)) {
        $class->throw(
            'ZUGFERD-00099: XSD directory does not exist',
            Dir => $xsdDir,
        );
    }

    # Ermittele .xsd-Dateien
    my @xsdFiles = Quiq::Path->find($xsdDir,-pattern=>'\.xsd$');

    # Instantiiere Schema-Objekt

    my $sch = XML::Compile::Schema->new;
    for my $file (@xsdFiles) {
        $sch->importDefinitions($file);
    }

    return bless {
        sch => $sch,
        tpl => Quiq::Template->new('xml',\$Template),
    },$class;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 asHash() - Wandele ZUGFeRD XML in Hash

=head4 Synopsis

  $h = $zug->asHash;

=head4 Alias

check()

=head4 Returns

Hash

=head4 Description

Wandele das ZUGFeRD XML in einen Hash und liefere eine Referenz auf diesen
zurück. Im Zuge dessen wird das XML gegen das ZUGFeRD Schema von
XML::Compile geprüft. Dies ist der eigentliche Sinn der Methode.

=head4 Example

  $ perl -MQuiq::Zugferd -E 'Quiq::Zugferd->new("~/doc/2024-09-19_0054_ZUGFeRD/example_basic")->asHash'

=cut

# -----------------------------------------------------------------------------

sub asHash {
    my $self = shift;

    my ($sch,$tpl) = $self->get(qw/sch tpl/);

    # Das ZUGFeRD XML
    my $xml = $tpl->asString;

    # Ermittele den Typ des Wurzelelements

    my $doc = XML::LibXML->load_xml(
        string => $xml,
        no_blanks => 1,
    );
    my $top = $doc->documentElement;
    my $rootType = XML::Compile::Util::type_of_node($top);

    # Instantiiere XML-Reader

    my $rdr = $sch->compile(READER=>$rootType,
        sloppy_floats => 1, # Wir wollen keine BigFloat-Elemente
        sloppy_integers => 1, # Wir wollen keine BigInt-Elemente
    );

    # Erzeuge und liefere Hash
    return $rdr->($doc);
}

{
    no warnings 'once';
    *check = \&asHash;
}

# -----------------------------------------------------------------------------

=head3 asString() - Liefere das ZUGFeRD XML als Zeichenkette

=head4 Synopsis

  $xml = $zug->asString;

=head4 Alias

xml()

=head4 Returns

String (XML Text)

=head4 Description

Liefere den XML-Code der ZUGFeRD-Rechnung

=cut

# -----------------------------------------------------------------------------

sub asString {
    my $self = shift;
    return $self->get('tpl')->asString;
}

{
    no warnings 'once';
    *xml = \&asString;
}

# -----------------------------------------------------------------------------

=head1 VERSION

1.222

=head1 AUTHOR

Frank Seitz, L<http://fseitz.de/>

=head1 COPYRIGHT

Copyright (C) 2024 Frank Seitz

=head1 LICENSE

This code is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# -----------------------------------------------------------------------------

1;

# eof
