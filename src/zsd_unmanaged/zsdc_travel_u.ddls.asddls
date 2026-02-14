@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity zsdc_travel_u
  provider contract transactional_query
  as projection on zsdi_travel_u
{

      @UI.facet: [{ id: 'trv', position: 10, label: 'Travel', type: #IDENTIFICATION_REFERENCE }]

      @UI.identification: [{ position: 10 }]
      @UI.lineItem: [{ position: 10 }]
  key TravelId,
      @UI.lineItem: [{ position: 20 }]
      AgencyId,
      @UI.lineItem: [{ position: 30 }]
      CustomerId,
      @UI.lineItem: [{ position: 40 }]
      BeginDate,
      @UI.lineItem: [{ position: 50 }]
      EndDate,
      @UI.lineItem: [{ position: 60 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @UI.lineItem: [{ position: 70 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _book : redirected to composition child zsdc_book_u
}
