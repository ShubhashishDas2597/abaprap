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

  ENDMETHOD.

ENDCLASS.
