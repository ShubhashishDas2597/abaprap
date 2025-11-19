@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection interface'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@UI.headerInfo: {
    typeName: 'Connection',
    typeNamePlural: 'Connections'
}
@Search.searchable: true
define view entity zi_conn_sd
  as select from /dmo/connection as conn
  association [1..*] to zi_flight_sd    as _flight on  $projection.CarrierId    = _flight.CarrierId
                                                   and $projection.ConnectionId = _flight.ConnectionId
  association [1..1] to /dmo/airport    as _airf   on  $projection.AirportFromId = _airf.airport_id
  association [1..1] to zi_carrier_sd_r as _carr   on  $projection.CarrierId = _carr.CarrierId
{


      @UI.facet: [{
          id: 'conn',
          purpose: #STANDARD,
          position: 10,
          label: 'Connection',
          type: #IDENTIFICATION_REFERENCE
      },
      {   id: 'flt',
          purpose: #STANDARD,
          position: 20,
          label: 'Flight',
          type: #LINEITEM_REFERENCE,
          targetElement: '_flight'
       }]


      @UI.lineItem: [{ position: 10, label: 'Carrier ID' }]
      //      @UI.selectionField: [{position: 10 }]
      @UI.identification: [{ position: 10, label: 'Airline Id' }]
      @Search.defaultSearchElement: true
      @ObjectModel.text.association: '_carr'
  key carrier_id                                                        as CarrierId,
      @UI.lineItem: [{position: 20 }]
      @UI.selectionField: [{position: 20 }]
      @UI.identification: [{ position: 20, label: 'Connection Id' }]
  key connection_id                                                     as ConnectionId,
      @UI.lineItem: [{position: 30 }]
      @UI.selectionField: [{position: 30 }]
      @ObjectModel.text.element: [ 'Airf' ]
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Airport',
          element: 'AirportID'
      } }]
      airport_from_id                                                   as AirportFromId,
      @UI.lineItem: [{position: 40 }]
      @UI.selectionField: [{position: 40 }]
      airport_to_id                                                     as AirportToId,
      @UI.lineItem: [{position: 50 }]
      departure_time                                                    as DepartureTime,
      @UI.lineItem: [{position: 60, label: 'Arrival Time' }]
      arrival_time                                                      as ArrivalTime,
      @UI.lineItem: [{position: 70 }]
      @Semantics.quantity.unitOfMeasure: 'DistanceUnit'
      distance                                                          as Distance,
      @UI.hidden: true
      @UI.lineItem: [{position: 80 }]
      distance_unit                                                     as DistanceUnit,

      @UI.hidden: true
      _airf[1:inner where airport_id = $projection.AirportFromId ].name as Airf,

      //      Associations
      _flight,
      _airf,
      @Search.defaultSearchElement: true
      _carr





}
