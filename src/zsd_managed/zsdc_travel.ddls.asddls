@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Consumpution View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travel Details'
}
@Search.searchable: true

define root view entity zsdc_travel
  provider contract transactional_query
  as projection on zsdi_travel
{

      @UI.facet: [{
          id: 'Travel',
          position: 10,
          importance: #HIGH,
          label: 'Travel',
          type: #IDENTIFICATION_REFERENCE
      },{
          id: 'Booking',
          position: 20,
          label: 'Booking',
          type: #LINEITEM_REFERENCE,
          targetElement: '_booking'
      }]

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
  key TravelId,
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Search.defaultSearchElement: true
      AgencyId,
      _agency.Name       as AgencyName,
      @ObjectModel.text.element: [ 'Name' ]
      CustomerId,
      _cust.FirstName    as Name,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      @ObjectModel.text.element: [ 'Text' ]
      OverallStatus,
      _status._Text.Text as Text : localized,
      //      CreatedBy,
      //      CreatedAt,
      //      LastChangedBy,
      LastChangedAt,
      /* Associations */
      @Search.defaultSearchElement: true
      _agency,
      @Search.defaultSearchElement: true
      _booking : redirected to composition child zsdc_book,
      @Search.defaultSearchElement: true
      _curr,
      _cust,
      _status
}
