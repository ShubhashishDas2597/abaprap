@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Projection View'
@Metadata.ignorePropagatedAnnotations: true
define view entity zsdc_book_u
  as projection on zsdi_book_u
{
      @UI.facet: [ { position: 10, label: 'Booking', type: #IDENTIFICATION_REFERENCE } ]

  key TravelId,
      @UI.lineItem: [{ position: 10, inline: true }]
      @UI.identification: [{ position: 10 }]
  key BookingId,
      @UI.identification: [{ position: 20 }]
      @UI.lineItem: [{ position: 20, inline: true}]
      BookingDate,
      @UI.lineItem: [{ position: 30, inline: true }]
      @UI.identification: [{ position: 30 }]
      CustomerId,
      @UI.lineItem: [{ position: 40, inline: true }]
      @UI.identification: [{ position: 50 }]
      CarrierId,
      @UI.identification: [{ position: 60 }]
      ConnectionId,
      @UI.identification: [{ position: 70 }]
      FlightDate,
      @UI.identification: [{ position: 80 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      @UI.identification: [{ position: 90 }]
      CurrencyCode,
      @UI.identification: [{ position: 100 }]
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _travel : redirected to parent zsdc_travel_u
}
