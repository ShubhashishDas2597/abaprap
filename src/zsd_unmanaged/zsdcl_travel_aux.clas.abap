CLASS zsdcl_travel_aux DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_ent_cr      TYPE TABLE FOR CREATE zsdi_travel_u\\travel,
           tt_mapped_cr   TYPE RESPONSE FOR MAPPED EARLY zsdi_travel_u,
           tt_failed_cr   TYPE RESPONSE FOR FAILED EARLY zsdi_travel_u,
           tt_reported_cr TYPE RESPONSE FOR REPORTED EARLY zsdi_travel_u.

    TYPES: tt_mapped_ad   TYPE RESPONSE FOR MAPPED LATE zsdi_travel_u,
           tt_reported_ad TYPE RESPONSE FOR REPORTED LATE zsdi_travel_u.

    CLASS-METHODS: get_instance RETURNING VALUE(ro_instance) TYPE REF TO zsdcl_travel_aux.
    METHODS: create
      IMPORTING
        entities TYPE tt_ent_cr
      CHANGING
        mapped   TYPE tt_mapped_cr
        failed   TYPE tt_failed_cr
        reported TYPE tt_reported_cr.


    METHODS: savedata.

    METHODS:
      adjust_nr
        CHANGING
          mapped   TYPE tt_mapped_ad
          reported TYPE tt_reported_ad.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: go_instance TYPE REF TO zsdcl_travel_aux.
    CLASS-DATA: gt_travel TYPE TABLE OF zsd_travell.
ENDCLASS.



CLASS zsdcl_travel_aux IMPLEMENTATION.
  METHOD get_instance.
    ro_instance = COND #( WHEN go_instance IS BOUND THEN go_instance ELSE NEW #(  ) ).
  ENDMETHOD.

  METHOD create.
    DATA(lt_ent) = entities.

    IF lt_ent IS NOT INITIAL..
      gt_travel = CORRESPONDING #( lt_ent MAPPING FROM ENTITY ).
      LOOP AT lt_ent ASSIGNING FIELD-SYMBOL(<fs_ent>)..
        mapped-travel = VALUE #( ( %cid = <fs_ent>-%cid TravelId = <fs_ent>-TravelId ) ).
      ENDLOOP..
    ENDIF.

  ENDMETHOD.

  METHOD savedata.
    MODIFY zsd_travell FROM TABLE @gt_travel.
  ENDMETHOD.

  METHOD adjust_nr.
    DATA: lt_mappedtrv TYPE TABLE FOR MAPPED LATE zsdi_travel_u\\travel .
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

    mapped-travel = lt_mappedtrv.

  ENDMETHOD.

ENDCLASS.
