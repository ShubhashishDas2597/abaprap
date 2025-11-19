CLASS zsdcl_data_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZSDCL_DATA_GENERATOR IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    SELECT * FROM /dmo/travel_m INTO TABLE @DATA(lt_travel).
    INSERT zsd_travel FROM ( SELECT * FROM /dmo/travel_m  ).
    INSERT zsd_book FROM ( SELECT * FROM /dmo/booking_m  ).
    INSERT zsd_booksupp FROM ( SELECT * FROM /dmo/booksuppl_m  ).
    out->write(
      EXPORTING
        data   = 'Data populated successfully'
*    name   =
*  RECEIVING
*    output =
    ).

  ENDMETHOD.
ENDCLASS.
