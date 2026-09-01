CLASS lsc_zsdi_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zsdi_travel IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

ENDCLASS.

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
    METHODS validatecust FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecust.
    METHODS valdate FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~valdate.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.
    METHODS detprice FOR DETERMINE ON MODIFY
       keys FOR travel~detprice.
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
      "DELETE lt_ent WHERE TravelId IS NOT INITIAL. "draft sceanrio me key field alreay avl hoti hai, jb key hai to usnme nubering nhi dena hai.
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
*             ignore_buffer     =
              nr_range_nr       = '01'
              object            = '/DMO/TRV_M'
              quantity          = CONV #( lines( lt_ent ) )
*             subobject         =
*             toyear            =
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
          ls-travelid = lv_num.
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

  METHOD earlynumbering_cba_booking.

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

      SORT lt_bkid DESCENDING BY travelid bookingid.

      IF line_exists( lt_bkid[ travelid = <fs_ent>-travelid ] ).
        lv_max = lt_bkid[ travelid = <fs_ent>-travelid ]-bookingid.
      ENDIF.

      lv_new_bkid = lv_max + 1.

      LOOP AT <fs_ent>-%target ASSIGNING FIELD-SYMBOL(<fs_book>).

        APPEND VALUE #( %cid      = <fs_book>-%cid
                        travelid  = <fs_ent>-travelid
                        bookingid = lv_new_bkid ) TO mapped-book.
        lv_new_bkid =  lv_new_bkid + 1.
      ENDLOOP.

*      mapped-book = cid traveldid bookingid

    ENDLOOP.

  ENDMETHOD.

  METHOD accept.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_keys>) WHERE travelid IS NOT INITIAL.

      MODIFY ENTITIES OF zsdi_travel IN LOCAL MODE
        ENTITY travel
        UPDATE FIELDS ( overallstatus )
*        FROM
        WITH VALUE #( ( %tky-travelid = <fs_keys>-%tky-travelid
                        overallstatus = 'A'
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
                      ( travelid = ls-travelid
                        %param   = CORRESPONDING #( ls )
                    )
                    ).

  ENDMETHOD.

  METHOD default.

    MODIFY ENTITIES OF zsdi_travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( overallstatus )
    WITH VALUE #( FOR ls IN keys
                  ( %tky-travelid = ls-%tky-travelid
                    overallstatus = 'O'
                  )
                ).

    result = VALUE #( FOR res IN keys
                      ( travelid = res-%tky-travelid
                        %param   = CORRESPONDING #( res )
                    )
    ).

  ENDMETHOD.

  METHOD copy.

    DATA(lt_keys) = keys.
    DELETE lt_keys WHERE travelid IS INITIAL.
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
          lt_bookm TYPE TABLE FOR CREATE zsdi_travel\\travel\_booking.
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
      lcid = keys[ travelid = <fs>-travelid ]-%cid .  "|cid{ sy-tabix }|.
      APPEND VALUE #( %cid  = lcid
                      %data = CORRESPONDING #( <fs> EXCEPT travelid ) ) TO lt_trvm.

      DATA(ind) = line_index( lt_book[ travelid = <fs>-travelid ]  ).
      IF ind <> 0.
        APPEND VALUE #( %cid_ref = lcid ) TO lt_bookm ASSIGNING FIELD-SYMBOL(<fsb>).
        LOOP AT lt_book ASSIGNING FIELD-SYMBOL(<fsb1>) FROM ind.

          IF <fsb1>-travelid <> <fs>-travelid.
            EXIT.
          ENDIF.
          APPEND VALUE #( %cid               = |{ lcid }{ sy-tabix }|
                          %data-carrierid    = <fsb1>-carrierid
                          %data-connectionid = <fsb1>-connectionid
                        ) TO <fsb>-%target.
        ENDLOOP.

      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF zsdi_travel IN LOCAL MODE
    ENTITY travel
      CREATE "AUTO FILL CID
      FIELDS ( agencyid begindate bookingfee
               currencycode customerid description
               totalprice )
      WITH lt_trvm

      CREATE BY \_booking
      FIELDS ( carrierid connectionid )
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
    FIELDS ( travelid overallstatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_res).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs>).

      DATA(status) = lt_res[ %tky = <fs>-%tky ]-overallstatus .

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

  METHOD validatecust.

    READ ENTITIES OF zsdi_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( travelid customerid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_trv).

    IF lt_trv IS NOT INITIAL.

      DELETE lt_trv WHERE customerid IS INITIAL.

      SELECT customer_id FROM /dmo/customer
      FOR ALL ENTRIES IN @lt_trv WHERE customer_id = @lt_trv-customerid INTO TABLE @DATA(lt_data).

      LOOP AT lt_trv INTO DATA(ls).

        IF NOT line_exists( lt_data[ customer_id = ls-customerid ] ).

          APPEND VALUE #( %tky = ls-%tky ) TO failed-travel.
          APPEND VALUE #( %tky                = ls-%tky
                          %msg                = NEW /dmo/cm_flight_messages(
                          customer_id = ls-customerid
                          textid      = /dmo/cm_flight_messages=>customer_unkown
                          severity    = if_abap_behv_message=>severity-error )
                          %element-customerid = if_abap_behv=>mk-on
          ) TO reported-travel.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD valdate.

    READ ENTITIES OF zsdi_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( travelid begindate enddate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_trv).

    DELETE lt_trv WHERE begindate IS INITIAL AND enddate IS INITIAL.

    LOOP AT lt_trv INTO DATA(ls).

      IF ls-begindate > ls-enddate.

        APPEND VALUE #( %tky = ls-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                        begin_date = ls-begindate
                        textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                        severity   = if_abap_behv_message=>severity-error )
                      ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD detprice.

    READ ENTITIES OF zsdi_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( travelid bookingfee )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_trv)

    ENTITY travel BY \_booking
    FIELDS ( travelid bookingid flightprice )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_trvbook).

    DATA: final_price TYPE p VALUE IS INITIAL.

    LOOP AT lt_trv ASSIGNING FIELD-SYMBOL(<fs_trv>).

      final_price += <fs_trv>-bookingfee.

      LOOP AT lt_trvbook ASSIGNING FIELD-SYMBOL(<fs_trvbook>) WHERE travelid = <fs_trv>-travelid.

        IF <fs_trvbook>-travelid <> <fs_trv>-travelid.
          EXIT.
        ENDIF.

        final_price += <fs_trvbook>-flightprice.

      ENDLOOP.

      MODIFY ENTITIES OF zsdi_travel IN LOCAL MODE
         ENTITY travel
         UPDATE
         FIELDS ( totalprice )
         WITH VALUE #( ( %tky       = <fs_trv>-%tky
                         totalprice = final_price
                       ) ).

    ENDLOOP.




*    final_price = REDUCE #(
*                            INIT s = 0
*                            FOR ls IN lt_trv NEXT
*                            FOR ls1 IN lt_trvbook
*                            NEXT s = s + ls-bookingfee + ls1-flightprice
*                             ).

  ENDMETHOD.

ENDCLASS.
