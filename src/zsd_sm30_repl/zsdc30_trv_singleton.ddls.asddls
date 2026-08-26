@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View Single Entry Main Page'
@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo: {
    typeName: 'Singleton Entry',
    typeNamePlural: 'Singleton Entries',
    title: {
        type: #STANDARD,
        label: 'SM30',
        value: 'SingletonEntry'
       }
}

define root view entity zsdc30_trv_singleton
  provider contract transactional_query
  as projection on zsdi30_trv_singleton
{

      @UI.facet: [
            {
            id: 'Single',
                position: 10,
                label: 'Single',
                type: #IDENTIFICATION_REFERENCE
            },
        {
          id: 'Travel',
          position: 20,
          label: 'Travel',
          type: #LINEITEM_REFERENCE,
          targetElement: '_trv'
      }]

      @UI.selectionField: [{position: 10 }]
//      @UI.identification: [{position: 10 }]
      @UI.lineItem: [{ position: 10 }]
  key SingletonEntry,
      /* Associations */
      _trv : redirected to composition child Zsdc30_Travel
}
