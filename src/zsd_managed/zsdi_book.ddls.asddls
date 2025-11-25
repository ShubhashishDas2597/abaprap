@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Book Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zsdi_book
  as select from zsd_book
  composition [0..*] of zsdi_booksuppl           as _booksupp
  association        to parent zsdi_travel       as _travel     on  $projection.TravelId = _travel.TravelId
  association [1..1] to /DMO/I_Carrier           as _carrier    on  $projection.CarrierId = _carrier.AirlineID
  association [0..1] to /DMO/I_Customer          as _cust       on  $projection.CustomerId = _cust.CustomerID
  association [1..1] to /DMO/I_Connection        as _conn       on  $projection.ConnectionId = _conn.ConnectionID
                                                                and $projection.CarrierId    = _conn.AirlineID
  association [1..1] to /DMO/I_Booking_Status_VH as _bookstatus on  $projection.BookingStatus = _bookstatus.BookingStatus
{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
       @semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,
      // exposed association

      _travel,
      _booksupp,
      _carrier,
      _cust,
      _conn,
      _bookstatus

}
