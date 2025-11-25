CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD get_global_authorizations.
*  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(lt_ent) = entities.

    IF lt_ent[] IS NOT INITIAL.
      DELETE lt_ent WHERE TravelId IS NOT INITIAL. "draft sceanrio me key field alreay avl hoti hai, jb key hai to usnme nubering nhi dena hai.
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
*        ignore_buffer     =
              nr_range_nr       = '01'
              object            = '/DMO/TRV_M'
              quantity          = CONV #( lines( lt_ent ) )
*        subobject         =
*        toyear            =
            IMPORTING
              number            = DATA(lv_num)
              returncode        = DATA(lv_code)
              returned_quantity = DATA(lv_return)
          ).
        CATCH cx_nr_object_not_found.
        CATCH cx_number_ranges INTO DATA(lx_nr).
          DATA(txt) = lx_nr->get_text( ).
      ENDTRY.

      IF lv_return = lines( lt_ent ).

        DATA:lt TYPE TABLE FOR MAPPED EARLY zsdi_travel\\travel,
             ls LIKE LINE OF lt.

        LOOP AT lt_ent ASSIGNING FIELD-SYMBOL(<fs>).

          ls-%cid = <fs>-%cid.
          ls-TravelId = lv_num.
          APPEND ls TO mapped-travel.

        ENDLOOP.
*        mapped-travel = VALUE #( FOR ls IN lt_ent (
*                                    %cid = ls-%cid
*                                    TravelId = lv_num
*                                    %key = ls-%key
*                                 )
*                                ).
      ENDIF.

      ENDIF.

    ENDMETHOD.

ENDCLASS.
