CLASS zcl_read_ent DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_read_ent IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    READ ENTITY zsdi_travel
    FROM VALUE #( ( %key-TravelId = '00000004'
                    %control = VALUE #( AgencyId = if_abap_behv=>mk-on
                                        BookingFee = if_abap_behv=>mk-on )
                 ) )
    RESULT DATA(lt_read_short)
    FAILED DATA(lt_failed_short).

    out->write( lt_read_short ).

    CLEAR :lt_read_short.

    READ ENTITY zsdi_travel
    ALL FIELDS WITH VALUE #( ( %key-TravelId = '00000004' ) )
    RESULT lt_read_short
    FAILED lt_failed_short.

    out->write( lt_read_short ).

    READ ENTITY zsdi_travel
     BY \_booking
      FROM VALUE #( ( %key-TravelId = '00000004'
*                      %control-AgencyId = if_abap_behv=>mk-on ) )
                     %control = VALUE #( BookingDate = if_abap_behv=>mk-on ConnectionId = if_abap_behv=>mk-on )
                   ) )
      RESULT DATA(ltb_read_short)
      FAILED DATA(ltb_fail_short) .

    out->write( ltb_read_short ).


    READ ENTITIES OF zsdi_travel
    ENTITY travel
    FROM VALUE #( ( %key-TravelId = '00000004'
                    %control = VALUE #( AgencyId = if_abap_behv=>mk-on
                                        BookingFee = if_abap_behv=>mk-on ) ) )
    RESULT DATA(lt_read_long)

    ENTITY book
    ALL FIELDS WITH VALUE #( ( %key-TravelId = '00000004' ) )
    RESULT DATA(ltb_read_long)

    FAILED DATA(lt_failed_long) .

    out->write( lt_read_long ).

    out->write( ltb_read_long ).






  ENDMETHOD.
ENDCLASS.
