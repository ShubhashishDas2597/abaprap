@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View Travel Object Page'
@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels'
}
@Search.searchable: true
define view entity Zsdc30_Travel
  as projection on ZSDi30_TRAVEL
{

      @UI.facet: [
            {
            id: 'Travel',
                position: 10,
                label: 'Single Travel',
                type: #IDENTIFICATION_REFERENCE
            }]

      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{position: 10 }]
      @UI.identification: [{position: 10 }]
      @Search.defaultSearchElement: true
  key TravelId,
      @UI.hidden: true
      SingletonEntry,
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{position: 20 }]
      @UI.identification: [{position: 20 }]
      AgencyId,
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{position: 30 }]
      @UI.identification: [{position: 30 }]
      CustomerId,
      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{position: 40 }]
      BeginDate,
      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{position: 50 }]
      EndDate,
      @UI.lineItem: [{ position: 60 }]
      @UI.identification: [{position: 60 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @UI.lineItem: [{ position: 70 }]
      @UI.identification: [{position: 70 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @UI.lineItem: [{ position: 80 }]
      @UI.identification: [{position: 80 }]
      CurrencyCode,
      @UI.lineItem: [{ position: 90 }]
      @UI.identification: [{position: 90 }]
      Description,
      @UI.lineItem: [{ position: 100 }]
      @UI.identification: [{position: 100 }]
      OverallStatus,
      @UI.lineItem: [{ position: 110 }]
      @UI.identification: [{position: 110 }]
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _strv : redirected to parent zsdc30_trv_singleton
}
