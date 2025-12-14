CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.
    METHODS accept FOR MODIFY
      IMPORTING keys FOR ACTION travel~accept RESULT result.
    METHODS default FOR MODIFY
      IMPORTING keys FOR ACTION travel~default RESULT result.
    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION travel~copy.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
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

        APPEND VALUE #( %cid = <fs_book>-%cid
                        TravelId = <fs_ent>-TravelId
                        BookingId = lv_new_bkid ) TO mapped-book.
        lv_new_bkid =  lv_new_bkid + 1.
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

    READ ENTITIES OF zsdi_travel IN LOCAL MODE
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

  METHOD default.

    MODIFY ENTITIES OF zsdi_travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR ls IN keys
                   ( %tky-TravelId = ls-%tky-TravelId
                     OverallStatus = 'O'
                   )
                ).

    result = VALUE #( FOR res IN keys
                      ( travelid = res-%tky-TravelId
                        %param = CORRESPONDING #( res )
                      )
                   ) .

  ENDMETHOD.

  METHOD copy.

    DATA(lt_keys) = keys.
    DELETE lt_keys WHERE TravelId IS INITIAL.
    "10 keys aaye
    " sare ke sare ek sath read kar liye
    READ ENTITIES OF zsdi_travel IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH CORRESPONDING #( lt_keys )
    RESULT DATA(lt_trv)

    ENTITY travel BY \_booking
    ALL FIELDS WITH CORRESPONDING #( lt_keys )
    RESULT DATA(lt_book).


    DATA: lt_trvm  TYPE TABLE FOR CREATE zsdi_travel\\travel,
          lT_bookM TYPE TABLE FOR CREATE zsdi_travel\\travel\_booking.
*
*    MODIFY ENTITIES OF zsdi_travel IN LOCAL MODE
*    ENTITY travel
*    CREATE "AUTO FILL CID
*    FIELDS ( AgencyId BeginDate BookingFee
*             CurrencyCode CustomerId Description
*             TotalPrice )
*    WITH VALUE #(
*                    FOR ls IN lt_trv
*                    ( %cid = |cid{ sy-tabix }|
*                      AgencyId = ls-AgencyId
*                      BeginDate = ls-BeginDate
*                      BookingFee = ls-BookingFee
*                      CurrencyCode =  ls-CurrencyCode
*                      CustomerId =  ls-CustomerId
*                      Description = ls-Description
*                      TotalPrice = ls-TotalPrice
*                     )
*                )
*
*    ENTITY travel
*    CREATE BY \_booking
*    FIELDS ( CarrierId ConnectionId )
*    WITH VALUE #( FOR ls1 IN lt_book
*                  (
*                    %cid_ref = ??? " need control on loop stmt
*                  )
*                )
*
*    .

    DATA: lcid TYPE string.
    DATA: lt_tempb TYPE TABLE FOR CREATE zsdi_travel\_booking.
    LOOP AT lt_trv ASSIGNING FIELD-SYMBOL(<fs>).

      CLEAR lcid.
      lcid = keys[ TravelId = <fs>-TravelId ]-%cid .  "|cid{ sy-tabix }|.
      APPEND VALUE #( %cid = lcid
                      %data = CORRESPONDING #( <fs> EXCEPT travelid ) ) TO lt_trvm.

      DATA(ind) = line_index( lt_book[ TravelId = <fs>-travelid ]  ).
      IF ind <> 0.
        APPEND VALUE #( %cid_ref = lcid ) TO lt_bookm ASSIGNING FIELD-SYMBOL(<fsb>).
        LOOP AT lt_book ASSIGNING FIELD-SYMBOL(<fsb1>) FROM ind.

          IF <fsb1>-TravelId <> <fs>-travelid.
            EXIT.
          ENDIF.
          APPEND VALUE #( %cid = |{ lcid }{ sy-tabix }|
                              %data-carrierid = <fsb1>-CarrierId
                             %data-connectionid = <fsb1>-ConnectionId
                           ) TO <fsb>-%target .
        ENDLOOP.

      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF zsdi_travel IN LOCAL MODE
    ENTITY travel
      CREATE "AUTO FILL CID
      FIELDS ( AgencyId BeginDate BookingFee
               CurrencyCode CustomerId Description
               TotalPrice )
      WITH lt_trvm

      CREATE BY \_booking
      FIELDS ( CarrierId ConnectionId )
      WITH lt_bookm
      MAPPED DATA(lt_map)
      REPORTED DATA(lt_rep)
      FAILED DATA(lt_f)
      .

    mapped = lt_map.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zsdi_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( TravelId OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_res).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs>).

      DATA(status) = lt_res[ %tky = <fs>-%tky ]-OverallStatus .

      APPEND VALUE #( %tky = <fs>-%tky
                      %features-%action-accept = COND #( WHEN status = 'A' THEN if_abap_behv=>fc-o-disabled )
                      %features-%assoc-_booking = COND #( WHEN status = 'A' THEN if_abap_behv=>fc-o-disabled )
                    )
                TO result.
    ENDLOOP.

*    result = VALUE #( FOR ls in keys
*                        (  %tky = ls-%tky
*                           %features-%action-accept = if_abap_behv=>fc-o-disabled  )
*                     ).                Same effect

  ENDMETHOD.

ENDCLASS.
