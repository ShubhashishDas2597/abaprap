CLASS lhc_zsdi_travel_u DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK travel.

    METHODS rba_Book FOR READ
      IMPORTING keys_rba FOR READ travel\_Book FULL result_requested RESULT result LINK association_links.

    METHODS cba_Book FOR MODIFY
      IMPORTING entities_cba FOR CREATE travel\_Book.

ENDCLASS.

CLASS lhc_zsdi_travel_u IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
    IF entities IS NOT INITIAL.
      zsdcl_travel_aux=>get_instance(  )->create(
        EXPORTING
          entities = entities
        CHANGING
          mapped   = mapped
          failed   = failed
          reported = reported
      ).
    ENDIF.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Book.
  ENDMETHOD.

  METHOD cba_Book.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zsdi_book_u DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zsdi_book_u.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zsdi_book_u.

    METHODS read FOR READ
      IMPORTING keys FOR READ zsdi_book_u RESULT result.

    METHODS rba_Travel FOR READ
      IMPORTING keys_rba FOR READ zsdi_book_u\_Travel FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_zsdi_book_u IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Travel.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZSDI_TRAVEL_U DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZSDI_TRAVEL_U IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD adjust_numbers.
    zsdcl_travel_aux=>get_instance( )->adjust_nr(
      CHANGING
        mapped   = mapped
        reported = reported
    ).
  ENDMETHOD.

  METHOD save.
    zsdcl_travel_aux=>get_instance( )->savedata( ).
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
