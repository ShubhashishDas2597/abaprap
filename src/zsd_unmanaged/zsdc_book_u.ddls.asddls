@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Projection View'
@Metadata.ignorePropagatedAnnotations: true
define view entity zsdc_book_u
  as projection on zsdi_book_u
{
  key TravelId,
      @UI.lineItem: [{ position: 10 }]
  key BookingId,
      @UI.lineItem: [{ position: 20 }]
      BookingDate,
      @UI.lineItem: [{ position: 30 }]
      CustomerId,
      @UI.lineItem: [{ position: 40 }]
      CarrierId,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _travel : redirected to parent zsdc_travel_u
}
