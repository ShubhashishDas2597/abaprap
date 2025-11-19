@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Book Consumpution View'
@Metadata.ignorePropagatedAnnotations: true
define view entity zsdc_book
  as projection on zsdi_book
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _bookstatus,
      _booksupp : redirected to composition child zsdc_booksuppl,
      _carrier,
      _conn,
      _cust,
      _travel   : redirected to parent zsdc_travel
}
