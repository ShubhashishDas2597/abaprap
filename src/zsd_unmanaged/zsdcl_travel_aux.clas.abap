CLASS zsdcl_travel_aux DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_ent_cr      TYPE TABLE FOR CREATE zsdi_travel_u\\travel,
           tt_mapped_cr   TYPE RESPONSE FOR MAPPED EARLY zsdi_travel_u,
           tt_failed_cr   TYPE RESPONSE FOR FAILED EARLY zsdi_travel_u,
           tt_reported_cr TYPE RESPONSE FOR REPORTED EARLY zsdi_travel_u,

           tt_ent_cba     TYPE TABLE FOR CREATE zsdi_travel_u\\travel\_book.

    TYPES: tt_mapped_ad   TYPE RESPONSE FOR MAPPED LATE zsdi_travel_u,
           tt_reported_ad TYPE RESPONSE FOR REPORTED LATE zsdi_travel_u.

    TYPES: tt_ent_upd     TYPE TABLE FOR UPDATE zsdi_travel_u\\travel.

    TYPES: tt_keys TYPE TABLE FOR DELETE zsdi_travel_u\\travel.

    CLASS-METHODS: get_instance RETURNING VALUE(ro_instance) TYPE REF TO zsdcl_travel_aux.
    METHODS: create
      IMPORTING
        entities TYPE tt_ent_cr
      CHANGING
        mapped   TYPE tt_mapped_cr
        failed   TYPE tt_failed_cr
        reported TYPE tt_reported_cr.

    METHODS: create_cba
      IMPORTING
        entities_cba TYPE tt_ent_cba
      CHANGING
        mapped       TYPE tt_mapped_cr
        failed       TYPE tt_failed_cr
        reported     TYPE tt_reported_cr.


    METHODS: savedata.

    METHODS:
      adjust_nr
        CHANGING
          mapped   TYPE tt_mapped_ad
          reported TYPE tt_reported_ad.

    METHODS:
      update
        IMPORTING
          entities TYPE tt_ent_upd
        CHANGING
          mapped   TYPE tt_mapped_cr
          failed   TYPE tt_failed_cr
          reported TYPE tt_reported_cr.

    METHODS: delete
      IMPORTING
        keys TYPE tt_keys.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: go_instance TYPE REF TO zsdcl_travel_aux.
    CLASS-DATA: gt_travel TYPE TABLE OF zsd_travell.
    CLASS-DATA: gt_book TYPE TABLE OF zsd_bookk.
    CLASS-DATA: gt_travel_upd TYPE TABLE OF zsd_travell.
    CLASS-DATA: gt_travel_del TYPE TABLE OF zsd_travell.
ENDCLASS.



CLASS zsdcl_travel_aux IMPLEMENTATION.
  METHOD get_instance.
    ro_instance = go_instance = COND #( WHEN go_instance IS BOUND THEN go_instance ELSE NEW #(  ) ).
  ENDMETHOD.

  METHOD create.
    DATA(lt_ent) = entities.

    IF lt_ent IS NOT INITIAL..
      gt_travel = CORRESPONDING #( lt_ent MAPPING FROM ENTITY ).
*      LOOP AT lt_ent ASSIGNING FIELD-SYMBOL(<fs_ent>)..
*        mapped-travel = VALUE #( ( %cid = <fs_ent>-%cid travelid = <fs_ent>-travelid ) ).
*      ENDLOOP..

**Another way of writing loop

      mapped = VALUE #(
        travel = VALUE #(
                          FOR <fs_ent> IN lt_ent
                          (
                          %cid      = <fs_ent>-%cid
                          %is_draft = <fs_ent>-%is_draft
                          travelid  = <fs_ent>-travelid
                          )
                          )
      ).

    ENDIF.

  ENDMETHOD.

  METHOD savedata.
    IF gt_travel[] IS NOT INITIAL.
      MODIFY zsd_travell FROM TABLE @gt_travel.
    ENDIF.
    IF gt_book[] IS NOT INITIAL.
      MODIFY zsd_bookk FROM TABLE @gt_book.
    ENDIF.
    IF gt_travel_upd[] IS NOT INITIAL..
      MODIFY zsd_travell FROM TABLE @gt_travel_upd.
    ENDIF.
    IF gt_travel_del[] IS NOT INITIAL..
      DELETE zsd_travell FROM TABLE @gt_travel_del.
    ENDIF.
  ENDMETHOD.

  METHOD adjust_nr.
    DATA: lt_mappedtrv  TYPE TABLE FOR MAPPED LATE zsdi_travel_u\\travel,
          lt_mappedbook TYPE TABLE FOR MAPPED LATE zsdi_book_u.

    DATA: lv_bookid TYPE i VALUE 1.

    IF gt_travel[] IS NOT INITIAL.
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = '/DMO/TRAVL'
              quantity          = CONV #( lines( gt_travel ) )
            IMPORTING
              number            = DATA(lv_key)
              returncode        = DATA(lv_return_code)
              returned_quantity = DATA(lv_returned_quantity)
          ).
        CATCH cx_number_ranges INTO DATA(lx_number_ranges).
          ASSERT 1 = 2.
      ENDTRY.
      ASSERT lv_returned_quantity = lines( gt_travel ).

      LOOP AT gt_travel ASSIGNING FIELD-SYMBOL(<fs_trv>).

        DATA(lv_exist) = CONV i( lv_key ) - CONV i( lv_returned_quantity ).
        DATA(l_id) = ( lv_exist ) + 1.
*        1 2 3                   4000            4003-3 = 4000
        <fs_trv>-travel_id = l_id.

        APPEND VALUE #( travelid = l_id ) TO lt_mappedtrv.

      ENDLOOP.

    ENDIF.

    IF gt_book[] IS NOT INITIAL.
      LOOP AT gt_book ASSIGNING FIELD-SYMBOL(<fs_book>).

        IF <fs_book>-travel_id IS INITIAL.
          <fs_book>-travel_id  = l_id.
        ENDIF.
        <fs_book>-booking_id = lv_bookid.

        APPEND VALUE #( travelid  = <fs_book>-travel_id
                        bookingid = <fs_book>-booking_id ) TO lt_mappedbook.
        lv_bookid += 1.

      ENDLOOP.

    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "filling of mapped
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    IF lt_mappedtrv[] IS NOT INITIAL.

      mapped-travel = lt_mappedtrv.

    ENDIF.
    IF lt_mappedbook[] IS NOT INITIAL.

      mapped-zsdi_book_u = lt_mappedbook.

    ENDIF.

  ENDMETHOD.

  METHOD update.

    DATA(lt_ent) = entities.

    SELECT * FROM zsd_travell
    FOR ALL ENTRIES IN @lt_ent
    WHERE travel_id = @lt_ent-%key-travelid
    INTO TABLE @DATA(lt_trv).

    LOOP AT lt_ent ASSIGNING FIELD-SYMBOL(<fs_ent>).

      "fill gt_travel will updated values to get it saved thru save method
      APPEND VALUE #( travel_id = <fs_ent>-%key-travelid

                      agency_id = COND #( WHEN <fs_ent>-%control-agencyid = if_abap_behv=>mk-off
                                          THEN lt_trv[ travel_id = <fs_ent>-travelid ]-agency_id
                                          ELSE <fs_ent>-agencyid )

                      customer_id = COND #( WHEN <fs_ent>-%control-customerid = if_abap_behv=>mk-off
                                          THEN lt_trv[ travel_id = <fs_ent>-travelid ]-customer_id
                                          ELSE <fs_ent>-customerid )

                      begin_date = COND #( WHEN <fs_ent>-%control-begindate = if_abap_behv=>mk-off
                                          THEN lt_trv[ travel_id = <fs_ent>-travelid ]-begin_date
                                          ELSE <fs_ent>-begindate )

                      end_date = COND #( WHEN <fs_ent>-%control-enddate = if_abap_behv=>mk-off
                                          THEN lt_trv[ travel_id = <fs_ent>-travelid ]-end_date
                                          ELSE <fs_ent>-enddate )

                      booking_fee = COND #( WHEN <fs_ent>-%control-bookingfee = if_abap_behv=>mk-off
                                          THEN lt_trv[ travel_id = <fs_ent>-travelid ]-booking_fee
                                          ELSE <fs_ent>-bookingfee )

                      total_price = COND #( WHEN <fs_ent>-%control-totalprice = if_abap_behv=>mk-off
                                          THEN lt_trv[ travel_id = <fs_ent>-travelid ]-total_price
                                          ELSE <fs_ent>-totalprice )

                      currency_code = COND #( WHEN <fs_ent>-%control-currencycode = if_abap_behv=>mk-off
                                          THEN lt_trv[ travel_id = <fs_ent>-travelid ]-currency_code
                                          ELSE <fs_ent>-currencycode )
                      description = COND #( WHEN <fs_ent>-%control-description = if_abap_behv=>mk-off
                                          THEN lt_trv[ travel_id = <fs_ent>-travelid ]-description
                                          ELSE <fs_ent>-description )

                      overall_status = COND #( WHEN <fs_ent>-%control-overallstatus = if_abap_behv=>mk-off
                                          THEN lt_trv[ travel_id = <fs_ent>-travelid ]-overall_status
                                          ELSE <fs_ent>-overallstatus )

                      ) TO gt_travel_upd.

      APPEND VALUE #( %key-travelid = <fs_ent>-%key-travelid ) TO mapped-travel.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    DATA(lt_keys) = keys.

    gt_travel_del = VALUE #( FOR ls IN lt_keys (
                             travel_id = ls-%key-travelid
                             ) ).

  ENDMETHOD.

  METHOD create_cba.

    DATA(lt_ent) = entities_cba.

    IF lt_ent[] IS NOT INITIAL.

      LOOP AT lt_ent ASSIGNING FIELD-SYMBOL(<fs_cba>).

        "gt_book = CORRESPONDING #( <fs_cba>-%target MAPPING FROM ENTITY ).
        LOOP AT <fs_cba>-%target ASSIGNING FIELD-SYMBOL(<fs_res>).
          APPEND VALUE #( travel_id      = <fs_cba>-travelid
                          booking_id     = <fs_res>-bookingid
                          booking_date   = <fs_res>-bookingdate
                          customer_id    = <fs_res>-customerid
                          carrier_id     = <fs_res>-carrierid
                          connection_id  = <fs_res>-connectionid
                          flight_date    = <fs_res>-flightdate
                          flight_price   = <fs_res>-flightprice
                          currency_code  = <fs_res>-currencycode
                          booking_status = <fs_res>-bookingdate
          ) TO gt_book.

*          mapped = VALUE #(
*            zsdi_book_u = VALUE #(
*                                   %cid      = <fs_res>-%cid
*                                   %is_draft = <fs_res>-%is_draft
*                                   %key      = <fs_res>-%key
*                                   )
*                          ).

          APPEND VALUE #( %cid      = <fs_res>-%cid
                          %is_draft = <fs_res>-%is_draft
                          %key      = <fs_res>-%key )
                 TO mapped-zsdi_book_u.

        ENDLOOP.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
