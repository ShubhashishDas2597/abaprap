CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.
    METHODS accept FOR MODIFY
      IMPORTING keys FOR ACTION travel~accept RESULT result.
    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE travel\_booking.
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

  METHOD earlynumbering_cba_Booking.

    DATA(lt_ent) = entities.
    DATA: lv_max      TYPE /dmo/booking_id,
          lv_new_bkid LIKE lv_max...

    READ ENTITIES OF zsdi_travel IN LOCAL MODE
      ENTITY travel BY \_booking
      FROM CORRESPONDING #( entities )
*      VALUE #( ( %key-TravelId = <fs_ent>-TravelId
*                      %control = VALUE #( BookingId = if_abap_behv=>mk-on ) ) )
      RESULT DATA(lt_bkid)
      FAILED DATA(lt_fail).

    LOOP AT lt_ent ASSIGNING FIELD-SYMBOL(<fs_ent>) USING KEY entity. "multiple travel

*      READ ENTITIES OF zsdi_travel
*      ENTITY travel BY \_booking
*      FROM VALUE #( ( %key-TravelId = <fs_ent>-TravelId
*                      %control = VALUE #( BookingId = if_abap_behv=>mk-on ) ) )
*      RESULT DATA(lt_bkid)
*      FAILED DATA(lt_fail).

      SORT lt_bkid DESCENDING BY TravelId BookingId.

      IF line_exists( lt_bkid[ TravelId = <fs_ent>-TravelId ] ).
        lv_max = lt_bkid[ TravelId = <fs_ent>-TravelId ]-BookingId.
      ENDIF.

      lv_new_bkid = lv_max + 1.

      LOOP AT <fs_ent>-%target ASSIGNING FIELD-SYMBOL(<fs_book>).

        mapped-book = VALUE #( ( %cid = <fs_book>-%cid
                                 TravelId = <fs_ent>-TravelId
                                 BookingId = lv_new_bkid ) ).
      ENDLOOP.

*      mapped-book = cid traveldid bookingid

    ENDLOOP.

  ENDMETHOD.

  METHOD accept.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_keys>) WHERE TravelId IS NOT INITIAL.

      MODIFY ENTITIES OF zsdi_travel IN LOCAL MODE
        ENTITY travel
        UPDATE FIELDS ( OverallStatus )
*        FROM
        WITH VALUE #( ( %tky-TravelId = <fs_keys>-%tky-TravelId
                        OverallStatus = 'A'
*                               %control = VALUE #( OverallStatus = IF_abap_behv=>mk-on )
                            ) ).
    ENDLOOP.

    READ ENTITIES OF zsdi_travel
    ENTITY travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_final).

*    result = VALUE #( FOR ls IN keys
*                      ( TravelId = ls-TravelId
*                        %param = CORRESPONDING #( ls )
*                       )
*                    ).


    result = VALUE #( FOR ls IN lt_final
                        ( TravelId = ls-TravelId
                          %param = CORRESPONDING #( ls )
                         )
                      ).

  ENDMETHOD.

ENDCLASS.
