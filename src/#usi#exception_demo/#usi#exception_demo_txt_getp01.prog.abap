*&---------------------------------------------------------------------*
*& Include          /USI/EXCEPTION_DEMO_TXT_GETP01
*&---------------------------------------------------------------------*
CLASS lcl_exception_factory IMPLEMENTATION.
  METHOD add_t100_exception.
    DATA textid TYPE scx_t100key.

    textid-msgid = i_msgid.
    textid-msgno = i_msgno.
    textid-attr1 = 'PARAM1'.
    textid-attr2 = 'PARAM2'.
    textid-attr3 = 'PARAM3'.
    textid-attr4 = 'PARAM4'.

    TRY.
        RAISE EXCEPTION TYPE /usi/cx_exception
          EXPORTING
            previous = the_exception
            textid   = textid
            param1   = i_param1
            param2   = i_param2
            param3   = i_param3
            param4   = i_param4.
      CATCH /usi/cx_exception INTO the_exception.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD add_otr_conversion_no_number.
    TRY.
        RAISE EXCEPTION TYPE cx_sy_conversion_no_number
          EXPORTING
            previous = the_exception
            textid   = cx_sy_conversion_no_number=>cx_sy_conversion_no_number
            value    = i_value.
      CATCH cx_sy_conversion_no_number INTO the_exception.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD add_otr_unknown_type.
    TRY.
        RAISE EXCEPTION TYPE cx_sy_unknown_type
          EXPORTING
            previous  = the_exception
            textid    = cx_sy_unknown_type=>cx_sy_unknown_type
            type_name = i_type_name.
      CATCH cx_sy_unknown_type INTO the_exception.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
