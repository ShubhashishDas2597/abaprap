@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true

@UI: {
    headerInfo: {
        typeName: 'Travel',
        typeNamePlural: 'Travels',
        title: {
            type: #STANDARD, value: 'TravelId'
        },
        description: {
            value: 'CustomerId'
        }
    } }

define root view entity zsdc_travel_u
  provider contract transactional_query
  as projection on zsdi_travel_u
{

      @UI.facet: [
                  { position: 10, label: 'Travel', type: #IDENTIFICATION_REFERENCE },
                  { position: 20, label: 'Booking', type: #LINEITEM_REFERENCE ,targetElement: '_book' ,
                    purpose: #STANDARD  }
                  ]

      @UI.identification: [{ position: 10 }]
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{position: 10 }]
      @Search.defaultSearchElement: true
  key TravelId,
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      AgencyId,
      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      CustomerId,
      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      BeginDate,
      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      EndDate,
      @UI.lineItem: [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @UI.lineItem: [{ position: 70 }]
      @UI.identification: [{ position: 70 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      @UI.identification: [{ position: 80 }]
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
