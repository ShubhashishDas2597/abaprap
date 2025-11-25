@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Book Suppl Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zsdi_booksuppl
  as select from zsd_booksupp
  association        to parent zsdi_book      as _book     on  $projection.BookingId = _book.BookingId
                                                           and $projection.TravelId  = _book.TravelId
  association [1..1] to zsdi_travel           as _travel   on  $projection.TravelId = _travel.TravelId
  association [1..1] to /DMO/I_Supplement     as _supp     on  $projection.SupplementId = _supp.SupplementID
  association [1..*] to /DMO/I_SupplementText as _supptext on  $projection.SupplementId = _supptext.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      //      exposed assoc
      _travel,
      _book,
      _supp,
      _supptext


}
