@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Book Suppl Consumpution View'
@Metadata.ignorePropagatedAnnotations: true
define view entity zsdc_booksuppl
  as projection on zsdi_booksuppl
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _travel : redirected to zsdc_travel,
      _book   : redirected to parent zsdc_book,
      _supp,
      _supptext
}
