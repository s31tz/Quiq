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
use XML::Compile::Schema ();
use Quiq::Template;

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

my $NsPrefix = 'urn:un:unece:uncefact:data:standard';

my %Template;

$Template{'Main'} = Quiq::Unindent->string(qq~
<?xml version='1.0' encoding='UTF-8' ?>

<rsm:CrossIndustryInvoice
    xmlns:rsm="$NsPrefix:CrossIndustryInvoice:100"
    xmlns:qdt="$NsPrefix:QualifiedDataType:100"
    xmlns:ram="$NsPrefix:ReusableAggregateBusinessInformationEntity:100"
    xmlns:udt="$NsPrefix:UnqualifiedDataType:100">

  <rsm:ExchangedDocumentContext> <!-- 1..1 PROZESSSTEUERUNG -->
    <ram:BusinessProcessSpecifiedDocumentContextParameter> <!-- 0..1 Gruppierung der Geschäftsprozessinformationen -->
      <ram:ID>???</ram:ID> <!-- Geschäftsprozesstyp -->
    </ram:BusinessProcessSpecifiedDocumentContextParameter>
    <ram:GuidelineSpecifiedDocumentContextParameter> <!-- 1..1 Gruppierung der Anwendungsempfehlungsinformationen -->
      <ram:ID>urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic</ram:ID> <!-- 1..1 Spezifikationskennung -->
    </ram:GuidelineSpecifiedDocumentContextParameter>
  </rsm:ExchangedDocumentContext>

  <rsm:ExchangedDocument> <!-- 1..1 Gruppierung der Eigenschaften, die das gesamte Dokument betreffen -->
    <ram:ID>__INVOICE_NUMBER__</ram:ID>  <!-- 1..1 Rechnungsnummer -->
    <ram:TypeCode>__INVOICE_TYPECODE__</ram:TypeCode> <!-- 1..1 Code für den Rechnungstyp -->
    <ram:IssueDateTime> <!-- 1..1 Rechnungsdatum -->
      <udt:DateTimeString format="102">__INVOICE_ISSUED__</udt:DateTimeString> <!-- 1..1 Datum -->
    </ram:IssueDateTime>
    __INVOICE_NOTE_LIST__
  </rsm:ExchangedDocument>

  <rsm:SupplyChainTradeTransaction> <!-- 1..1 Gruppierung der Informationen zum Geschäftsvorfall -->
    __LINE_ITEMS__
    <ram:ApplicableHeaderTradeAgreement> <!-- 1..1 Gruppierung der Vertragsangaben -->
      <ram:BuyerReference>???</ram:BuyerReference> <!-- 0..1 Referenz des Käufers -->
      <ram:SellerTradeParty> <!-- 1..1 VERKÄUFER -->
        <ram:ID>???</ram:ID> <!-- 0..N Kennung des Verkäufers -->
        <ram:GlobalID schemeID="???">???</ram:GlobalID> <!-- 0..N Globale Kennung des Verkäufers -->
        <ram:Name>__SELLER_NAME__</ram:Name> <!-- 1..1 Name des Verkäufers -->
        <ram:SpecifiedLegalOrganization> <!-- 0..1 Details zur Organisation -->
          <ram:ID schemeID="??">???</ram:ID> <!-- 0..N Kennung der rechtlichen Registrierung des Verkäufers, Kennung des Schemas -->
          <ram:TradingBusinessName>???</ram:TradingBusinessName> <!-- 0..1 Handelsname des Verkäufers -->
        </ram:SpecifiedLegalOrganization>
        <ram:PostalTradeAddress> <!-- 1..1 POSTANSCHRIFT DES VERKÄUFERS -->
          <ram:PostcodeCode>__SELLER_POSTCODE__</ram:PostcodeCode> <!-- 0..1 Postleitzahl der Verkäuferanschrift -->
          <ram:LineOne>__SELLER_LINEONE__</ram:LineOne> <!-- 0..1 Zeile 1 der Verkäuferanschrift -->
          <ram:LineTwo>???</ram:LineTwo> <!-- 0..1 Zeile 2 der Verkäuferanschrift -->
          <ram:LineThree>???</ram:LineThree> <!-- 0..1 Zeile 3 der Verkäuferanschrift -->
          <ram:CityName>__SELLER_CITY__</ram:CityName> <!-- 0..1 Stadt der Verkäuferanschrift -->
          <ram:CountryID>__SELLER_COUNTRY__</ram:CountryID> <!-- 1..1 Ländercode der Verkäuferanschrift -->
          <ram:CountrySubDivisionName>???</ram:CountrySubDivisionName> <!-- 0..1 Region oder Bundesland der Verkäuferanschrift -->
        </ram:PostalTradeAddress>
        <ram:URIUniversalCommunication> <!-- 0..1 Details zur elektronischen Adresse -->
          <ram:URIID schemeID="???">???</ram:URIID> <!-- 1..1 Elektronische Adresse des Verkäufers -->
        </ram:URIUniversalCommunication>
        __SELLER_TAX_REGISTRATIONS__
      </ram:SellerTradeParty>
      <ram:BuyerTradeParty> <!-- 1..1 KÄUFER -->
        <ram:ID>__BUYER_ID__</ram:ID> <! 0..1 Kennung des Käufers -->
        <ram:GlobalID schemeID="???">???</ram:GlobalID> <!-- 0..1 Globale Kennung des Käufers -->
        <ram:Name>__BUYER_NAME__</ram:Name> <!-- 1..1 Name des Käufers -->
        <ram:SpecifiedLegalOrganization> <!-- 0..1 Details zur Organisation -->
          <ram:ID schemeID="??">???</ram:ID> <!-- 0..1 Kennung der rechtlichen Registrierung des Käufers, Kennung des Schemas -->
        </ram:SpecifiedLegalOrganization>
        <ram:PostalTradeAddress> <!-- 1..1 POSTANSCHRIFT DES KÄUFERS -->
          <ram:PostcodeCode>__BUYER_POSTCODE__</ram:PostcodeCode> <!-- 0..1 Postleitzahl der Käuferanschrift -->
          <ram:LineOne>__BUYER_LINEONE__</ram:LineOne> <!-- 0..1 Zeile 1 der Käuferanschrift -->
          <ram:LineTwo>__BUYER_LINETWO__</ram:LineTwo> <!-- 0..1 Zeile 2 der Käuferanschrift -->
          <ram:LineThree>???</ram:LineThree> <!-- 0..1 Zeile 3 der Käuferanschrift -->
          <ram:CityName>__BUYER_CITY__</ram:CityName> <!-- 0..1 Stadt der Käuferanschrift -->
          <ram:CountryID>__BUYER_COUNTRY__</ram:CountryID> <!-- 1..1 Ländercode der Käuferanschrift -->
          <ram:CountrySubDivisionName>???</ram:CountrySubDivisionName> <!-- 0..1 Region oder Bundesland der Käuferanschrift -->
        </ram:PostalTradeAddress>
        <ram:URIUniversalCommunication> <!-- 0..1 Details zur elektronischen Adresse -->
          <ram:URIID schemeID="???">???</ram:URIID> <!-- 1..1 Elektronische Adresse des Käufers -->
        </ram:URIUniversalCommunication>
        <ram:SpecifiedTaxRegistration> <!-- 0..1 Detailinformationen zu Steuerangaben des Käufers -->
          <ram:ID schemeID="???">???</ram:ID> <!-- 1..1 Umsatzsteuer-Identifikationsnummer/Steuernummer des Käufers, Art der Steuernummer -->
        </ram:SpecifiedTaxRegistration>
      </ram:BuyerTradeParty>
      <ram:SellerTaxRepresentativeTradeParty> <!-- 0.11 STEUERBEVOLLMÄCHTIGTER DES VERKÄUFERS -->
        <ram:Name>???</ram:Name> <!-- 1..1 Name des Steuerbevollmächtigten des Verkäufers -->
        <ram:PostalTradeAddress> <!-- 1..1 POSTANSCHRIFT DES STEUERBEVOLLMÄCHTIGTEN DES KÄUFERS -->
          <ram:PostcodeCode>???</ram:PostcodeCode> <!-- 0..1 Postleitzahl der Steuerbevollmächtigtenanschrift -->
          <ram:LineOne>???</ram:LineOne> <!-- 0..1 Zeile 1 der Steuerbevollmächtigtenanschrift -->
          <ram:LineTwo>???</ram:LineTwo> <!-- 0..1 Zeile 2 der Steuerbevollmächtigtenanschrift -->
          <ram:LineThree>???</ram:LineThree> <!-- 0..1 Zeile 3 der KSteuerbevollmächtigtenanschrift -->
          <ram:CityName>???</ram:CityName> <!-- 0..1 Stadt der Steuerbevollmächtigtenanschrift -->
          <ram:CountryID>???</ram:CountryID> <!-- 1..1 Ländercode der Steuerbevollmächtigtenanschrift -->
          <ram:CountrySubDivisionName>???</ram:CountrySubDivisionName> <!-- 0..1 Region oder Bundesland der Steuerbevollmächtigtenanschrift -->
        </ram:PostalTradeAddress>
        <ram:SpecifiedTaxRegistration> <!-- 1..1 Detailinformationen zu Steuerangaben -->
          <ram:ID schemeID="???">???</ram:ID> <!-- 1..1 Umsatzsteuer-Identifikationsnummer des Steuerbevollmächtigten des Verkäufers, Art der Steuernummer -->
        </ram:SpecifiedTaxRegistration>
      </ram:SellerTaxRepresentativeTradeParty>
      <ram:BuyerOrderReferencedDocument> <!-- 0..1 Detailangaben zur zugehörigen Bestellung -->
        <ram:IssuerAssignedID>???</ram:IssuerAssignedID> <!-- 1..1 Bestellreferenz -->
      </ram:BuyerOrderReferencedDocument>
      <ram:ContractReferencedDocument> <!-- 0..1 Detailangaben zum zugehörigen Vertrag -->
        <ram:IssuerAssignedID>???</ram:IssuerAssignedID> <!-- 1..1 Vertragsreferenz -->
      </ram:ContractReferencedDocument>
    </ram:ApplicableHeaderTradeAgreement>

    <ram:ApplicableHeaderTradeDelivery> <!-- 1..1 Gruppierung von Lieferangaben -->
      <ram:ShipToTradeParty> <!-- 0..1 LIEFERINFORMATIONEN -->
        <ram:ID>???</ram:ID> <!-- 0..1 Kennung des Lieferorts -->
        <ram:GlobalID schemeID="???">???</ram:GlobalID> <!-- 0..1 Globale Kennung des Käufers -->
        <ram:Name>???</ram:Name> <!-- 0..1 Name des Waren- oder Dienstleistungsempfängers -->
        <ram:PostalTradeAddress> <!-- 0..1 LIEFERANSCHRIFT -->
          <ram:PostcodeCode>???</ram:PostcodeCode> <!-- 0..1 Postleitzahl der Lieferanschrift -->
          <ram:LineOne>???</ram:LineOne> <!-- 0..1 Zeile 1 der Lieferanschrift -->
          <ram:LineTwo>???</ram:LineTwo> <!-- 0..1 Zeile 2 der Lieferanschrift -->
          <ram:LineThree>???</ram:LineThree> <!-- 0..1 Zeile 3 der Lieferanschrift -->
          <ram:CityName>???</ram:CityName> <!-- 0..1 Stadt der Lieferanschrift -->
          <ram:CountryID>???</ram:CountryID> <!-- 1..1 Ländercode der Lieferanschrift -->
          <ram:CountrySubDivisionName>???</ram:CountrySubDivisionName> <!-- 0..1 Region oder Bundesland der Lieferanschrift -->
        </ram:PostalTradeAddress>
      </ram:ShipToTradeParty>
      <ram:ActualDeliverySupplyChainEvent> <!-- 0..1 Detailinformationen zur tatsächlichen Lieferung -->
        <ram:OccurrenceDateTime> <!-- 1..1 Tatsächlicher Lieferungszeitpunkt -->
          <udt:DateTimeString format="102">20241114</udt:DateTimeString> <!-- 1..1 Tatsächliches Lieferdatum, Format -->
        </ram:OccurrenceDateTime>
      </ram:ActualDeliverySupplyChainEvent>
      <ram:DespatchAdviceReferencedDocument> <!-- 0..1 Detailinformationen zum zugehörigen Lieferavis -->
        <ram:IssuerAssignedID>???</ram:IssuerAssignedID> <!-- 1..1 Lieferavisreferenz -->
      </ram:DespatchAdviceReferencedDocument>
    </ram:ApplicableHeaderTradeDelivery>

    <ram:ApplicableHeaderTradeSettlement> <!-- 1..1 LASTSCHRIFTVERFAHREN -->
      <ram:CreditorReferenceID>???</ram:CreditorReferenceID> <!-- 0..1 Kennung des Gläubigers -->
      <ram:PaymentReference>???<ram:PaymentReference> <!-- 0..1 Verwendungszweck -->
      <ram:TaxCurrencyCode>???</ram:TaxCurrencyCode> <!-- 0..1 Code für die Währung der Umsatzsteuerbuchung -->
      <ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode> <!-- 1..1 Code für die Rechnungswährung -->
      <ram:PayeeTradeParty> <!-- 0..1 ZAHLUNGSEMPFÄNGER -->
        <ram:ID>???</ram:ID> <!-- 0..1 Kennung des Zahlungsempfängers -->
        <ram:GlobalID schemeID="???">???</ram:GlobalID> <!-- 0..1 Globale Kennung des Zahlungsempfängers -->
        <ram:Name>???</ram:Name> <!-- 0..1 Firmierung/Name des Zahlungsempfängers -->
        <ram:SpecifiedLegalOrganization> <!-- 0..1 Details zur Organisation -->
          <ram:ID schemeID="??">???</ram:ID> <!-- 0..1 Kennung der rechtlichen Registrierung des Zahlungsempfängers, Kennung des Schemas -->
        </ram:SpecifiedLegalOrganization>
      </ram:PayeeTradeParty>
      <ram:SpecifiedTradeSettlementPaymentMeans> <!-- 0..N ZAHLUNGSANWEISUNGEN -->
        <ram:TypeCode>???</ram:TypeCode> <!-- 1..1 Code für die Zahlungsart -->
        <ram:PayerPartyDebtorFinancialAccount> <!-- 0..1 Bankinstitut des Käufers -->
          <ram:IBANID>???</ram:IBANID> <!-- 1..1 Kennung des zu belastenden Kontos -->
        </ram:PayerPartyDebtorFinancialAccount>
        <ram:PayeePartyCreditorFinancialAccount> <!-- 0..1 ÜBERWEISUNG -->
          <ram:IBANID>???</ram:IBANID> <!-- 1..1 Kennung des Zahlungskontos -->
          <ram:ProprietaryID>???</ram:ProprietaryID> <!-- 0..1 Nationale Kontonummer (nicht für SEPA) -->
        </ram:PayeePartyCreditorFinancialAccount>
      </ram:SpecifiedTradeSettlementPaymentMeans>
      <ram:ApplicableTradeTax> <!-- 1..N UMSATZSTEUERAUFSCHLÜSSELUNG -->
        <ram:CalculatedAmount>???</ram:CalculatedAmount> <!-- 1..1 Kategoriespezifischer Steuerbetrag -->
        <ram:TypeCode>???</ram:TypeCode> <!-- 1..1 Art der Steuer (Code) -->
        <ram:ExemptionReason>???</ram:ExemptionReason> <!-- 0..1 Umsatzsteuerbefreiungsgrund -->
        <ram:BasisAmount>???</ram:BasisAmount> <!-- 1..1 Kategoriespezifischer Steuerbasisbetrag -->
        <ram:CategoryCode>???</ram:CategoryCode> <!-- 1..1 Code der Umsatzsteuerkategorie -->
        <ram:ExemptionReasonCode>???</ram:ExemptionReasonCode> <!-- 0..1 Code für den Umsatzsteuerbefreiungsgrund -->
        <ram:DueDateTypeCode>???</ram:DueDateTypeCode> <!-- 0..1 Code für das Datum der Steuerfälligkeit -->
        <ram:RateApplicablePercent>???</ram:RateApplicablePercent> <!-- 0..1 Kategoriespezifischer Umsatzsteuersatz -->
      </ram:ApplicableTradeTax>
      <ram:BillingSpecifiedPeriod> <!-- 0..1 RECHNUNGSZEITRAUM -->
        <ram:StartDateTime> <!-- 0..1 Beginn der Rechnungsperiode -->
          <ram:DateTimeString format="???">???</ram:DateTimeString> <!-- 1..1 Anfangsdatum des Rechnungszeitraums, Format -->
        </ram:StartDateTime>
        <ram:EndDateTime> <!-- 0..1 Ende der Rechnungsperiode -->
          <ram:DateTimeString format="???">???</ram:DateTimeString> <!-- 1..1 Enddatum des Rechnungszeitraums, Format -->
        </ram:EndDateTime>
      </ram:BillingSpecifiedPeriod>
***
      <ram:SpecifiedTradePaymentTerms>
        <ram:DueDateDateTime>
          <udt:DateTimeString format="102">20241215</udt:DateTimeString>
        </ram:DueDateDateTime>
      </ram:SpecifiedTradePaymentTerms>

      <ram:SpecifiedTradeSettlementHeaderMonetarySummation>
        <ram:LineTotalAmount>__SUMMATION_LINE_TOTAL__</ram:LineTotalAmount>
        <ram:ChargeTotalAmount>__SUMMATION_CHARGE_TOTAL__</ram:ChargeTotalAmount>
        <ram:AllowanceTotalAmount>__SUMMATION_ALLOWANCE_TOTAL__</ram:AllowanceTotalAmount>
        <ram:TaxBasisTotalAmount>__SUMMATION_TAX_BASIS_TOTAL__</ram:TaxBasisTotalAmount>
        <ram:TaxTotalAmount currencyID="__SUMMATION_TAX_CURRENCY__">__SUMMATION_TAX_TOTAL__</ram:TaxTotalAmount>
        <ram:GrandTotalAmount>__SUMMATION_GRAND_TOTAL__</ram:GrandTotalAmount>
        <ram:DuePayableAmount>__SUMMATION_DUE_PAYABLE__</ram:DuePayableAmount>
      </ram:SpecifiedTradeSettlementHeaderMonetarySummation>

    </ram:ApplicableHeaderTradeSettlement>
  </rsm:SupplyChainTradeTransaction>
</rsm:CrossIndustryInvoice>
~);

$Template{'Note'} = Quiq::Unindent->string(q~
<ram:IncludedNote> <!-- 0..N FREITEXT ZUR RECHNUNG -->
  <ram:Content>__TEXT__</ram:Content> <!-- 1..1 Freitext zur Rechnung -->
  <ram:SubjectCode>__CODE__</ram:SubjectCode> <!-- 0..1 Code zur Qualifizierung des Freitextes zur Rechnung -->
</ram:IncludedNote>
~);

$Template{'TaxRegistration'} = Quiq::Unindent->string(q~
<ram:SpecifiedTaxRegistration> <!-- 0..1 Detailinformationen zu Steuerangaben des Verkäufers -->
  <ram:ID schemeID="__ID__">__NUMBER__</ram:ID> <!-- 1..1 Umsatzsteuer-Identifikationsnummer/Steuernummer des Verkäufers -->
</ram:SpecifiedTaxRegistration>
~);

$Template{'LineItem'} = Quiq::Unindent->string(q~
<ram:IncludedSupplyChainTradeLineItem> <!-- 1..N RECHNUNGSPOSITION -->
  <ram:AssociatedDocumentLineDocument> <!-- 1..1 Gruppierung von allgemeinen Positionsangaben -->
    <ram:LineID>__LINE_ID__</ram:LineID> <!-- 1..1 Kennung der Rechnungsposition -->
    <!--optional-->
    <ram:IncludedNote> <!-- 0..1 Detailinformationen zum Freitext zur Position -->
      <ram:Content>__LINE_NOTE__</ram:Content> <!-- Freitext zur Rechnungsposition -->
    </ram:IncludedNote>
    <!--/optional-->
  </ram:AssociatedDocumentLineDocument>

  <ram:SpecifiedTradeProduct> <!-- 1..1 ARTIKELINFORMATIONEN -->
    <ram:GlobalID schemaID="???">???</ram:GlobalID> <!-- 0..1 Kennung eines Artikels nach registriertem Schema -->
    <ram:Name>__LINE_PRODUCT_NAME__</ram:Name> <!-- 1..1 Artikelname -->
  </ram:SpecifiedTradeProduct>

  <ram:SpecifiedLineTradeAgreement> <!-- 1..1 DETAILINFORMATIONEN ZUM PREIS -->
    <ram:GrossPriceProductTradePrice>
      <ram:ChargeAmount>???</ram:ChargeAmount> <!-- 1..1 Bruttopreis des Artikels -->
      <ram:BasisQuantity unitCode="???">???</ram:BasisQuantity> <!-- 0..1 Basismenge zum Artikelpreis -->
      <ram:AppliedTradeAllowanceCharge> <!-- 0..1 Preisbezogene Abschläge -->
        <ram:ChargeIndicator> <!-- 1..1 Indikator für Preisabschlag -->
          <ram:Indicator>???</ram:Indicator> <!-- 1..1 Indikator für Preisabschlag, Wert -->
        </ram:ChargeIndicator>
        <ram:ActualAmount>???</ram:ActualAmount> <!-- 1..1 Nachlass auf den Artikelpreis -->
      </ram:AppliedTradeAllowanceCharge>
    </ram:GrossPriceProductTradePrice>
    <ram:NetPriceProductTradePrice> <!-- 1..1 Detailinformationen zum Nettopreis des Artikels -->
      <ram:ChargeAmount>3.90</ram:ChargeAmount> <!-- 1..1 Nettopreis des Artikels -->
      <ram:BasisQuantity unitCode="???"></ram:BasisQuantity> <!-- 0..1 Basismenge zum Artikelpreis -->
    </ram:NetPriceProductTradePrice>
  </ram:SpecifiedLineTradeAgreement>

  <ram:SpecifiedLineTradeDelivery> <!-- 1..1 Gruppierung von Lieferangaben aus Positionsebene -->
    <ram:BilledQuantity unitCode="C62">1</ram:BilledQuantity> <!-- 1..1 In Rechnung gestellte Menge -->
  </ram:SpecifiedLineTradeDelivery>

  <ram:SpecifiedLineTradeSettlement> <!-- 1..1 Gruppierung von Angaben zur Abrechnung auf Positionsebene -->
    <ram:ApplicableTradeTax> <!-- 1..1 UMSATZSTEUERINFORMATIONEN AUF DER EBENE DER RECHNUNGSPOSITION -->
      <ram:TypeCode>__LINE_TAX_CODE__</ram:TypeCode> <!-- 1..1 Steuerart (Code) -->
      <ram:CategoryCode>__LINE_TAX_CATEGORY__</ram:CategoryCode> <!-- 1..1 Code der Umsatzsteuerkategorie des in Rechnung gestellten Artikels -->
      <ram:RateApplicablePercent>__LINE_TAX_PERCENT__</ram:RateApplicablePercent> <!-- 0..1 Umsatzsteuersatz für den in Rechnung gestellten Artikel -->
    </ram:ApplicableTradeTax>
    <ram:BillingSpecifiedPeriod> <!-- 0..1 RECHNUNGSPOSITIONSZEITRAUM -->
      <ram:StartDateTime> <!-- 0..1 Beginn der Rechnungsperiode -->
        <ram:DateTimeString format="???">???</ram:DateTimeString> <!-- 1..1 Datum, Format -->
      </ram:StartDateTime>
      <ram:EndDateTime> <!-- 0..1 Ende der Rechnungsperiode -->
        <ram:DateTimeString format="???">???</ram:DateTimeString> <!-- 1..1 Datum, Format -->
      </ram:EndDateTime>
    </ram:BillingSpecifiedPeriod>
    <ram:SpecifiedTradeAllowanceCharge> <!-- <Allowance/Charge> 0..N ABSCHLÄGE/ZUSCLÄGE AUF EBENE DER RECHNUNGSPOSITION -->
      <ram:ChargeIndicator> <!-- 1..1 Indikator für Abschlag -->
        <ram:Indicator>???</ram:Indicator> <!-- 1..1 Indikator für Abschlag/Zuschlag, Wert -->
      </ram:ChargeIndicator>
      <ram:ActualAmount>???</ram:ActualAmount> <!-- 1..1 Betrag des Abschlags/Zuschlags auf Ebene der Rechnungsposition -->
      <ram:ReasonCode>???</ram:ReasonCode> <!-- 0..1 Code für den Grund für den Abschlag/Zuschlag auf Ebene der Rechnungsposition -->
      <ram:Reason>???</ram:Reason> <!-- 0..1 Grund für den Abschlag/Zuschlag auf Ebene der Rechnungsposition -->
    </ram:SpecifiedTradeAllowanceCharge>
    <ram:SpecifiedTradeSettlementLineMonetarySummation> <!-- 1..1 Detailinformationen zu Positionssummen -->
      <ram:LineTotalAmount>3.90</ram:LineTotalAmount> <!-- 1..1 Nettobetrag der Rechnungsposition -->
    </ram:SpecifiedTradeSettlementLineMonetarySummation>
  </ram:SpecifiedLineTradeSettlement>
</ram:IncludedSupplyChainTradeLineItem>
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
        templateH => \%Template,
    },$class;
}

# -----------------------------------------------------------------------------

=head2 Objektmethoden

=head3 getTemplate() - Liefere ein ZUGFeRD-Fragment als Template

=head4 Synopsis

  $tpl = $zug->getTemplate($name);

=head4 Returns

Quiq::Template-Objekt

=head4 Description

Liefere ein ZUGFeRD-Template mit dem Namen $name.

=cut

# -----------------------------------------------------------------------------

sub getTemplate {
    my ($self,$name) = @_;

    my $template = $self->{'templateH'}->{$name};
    if (!$template) {
        $self->throw(
            'ZUGF-00099: Template does not exist',
            Template => $name,
        );
    }

    return Quiq::Template->new('xml',\$template),
}

# -----------------------------------------------------------------------------

=head3 templateNames() - Liefere die Liste aller Template-Namen

=head4 Synopsis

  @names | $nameA = $zug->templateNames;

=head4 Returns

(Array of Strings) Im Skalarkontext wird eine Referenz auf die Liste
geliefert.

=cut

# -----------------------------------------------------------------------------

sub templateNames {
    my $self = shift;
    my @arr = sort keys %{$self->{'templateH'}};
    return wantarray? @arr: \@arr;
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
