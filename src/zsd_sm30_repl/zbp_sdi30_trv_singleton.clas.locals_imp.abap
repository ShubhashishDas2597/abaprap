CLASS lhc_zsdi30_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS checkcust FOR VALIDATE ON SAVE
       keys FOR zsdi30_travel~checkcust.

ENDCLASS.

CLASS lhc_zsdi30_travel IMPLEMENTATION.

  METHOD checkcust.

    READ ENTITIES OF zsdi30_trv_singleton
    ENTITY zsdi30_travel
    FIELDS ( travelid customerid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_rcust).

    DELETE lt_rcust WHERE %data-customerid IS INITIAL.

    IF lt_rcust[] IS NOT INITIAL.

      SELECT customer_id FROM /dmo/customer
      FOR ALL ENTRIES IN @lt_rcust
      WHERE customer_id = @lt_rcust-customerid INTO TABLE @DATA(lt_cust1).

      LOOP AT lt_rcust ASSIGNING FIELD-SYMBOL(<fs>).

        IF NOT line_exists( lt_cust1[ customer_id = <fs>-customerid ] ).

          APPEND VALUE #( %tky = <fs>-%tky ) TO failed-zsdi30_travel.
          APPEND VALUE #( %tky                = <fs>-%tky
                          %msg                = new_message(
                          id       = 'ZSHUBH_MSG'
                          number   = '001'
                          severity = if_abap_behv_message=>severity-error
*                                   v1       =
*                                   v2       =
*                                   v3       =
*                                   v4       =
                          )
                          %element-customerid = if_abap_behv=>mk-on
                        ) TO reported-zsdi30_travel.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

**************************************************************************
*Singleton class
***************************************************************************

CLASS lhc_zsdi30_trv_singleton DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zsdi30_trv_singleton RESULT result.

ENDCLASS.

CLASS lhc_zsdi30_trv_singleton IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zsdi30_trv_singleton DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zsdi30_trv_singleton IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
