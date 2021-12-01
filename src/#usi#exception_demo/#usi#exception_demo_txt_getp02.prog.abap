*&---------------------------------------------------------------------*
*& Include          /USI/EXCEPTION_DEMO_TXT_GETP02
*&---------------------------------------------------------------------*
CLASS lcl_demo_report IMPLEMENTATION.
  METHOD run_bapiret2_demo.
    DATA: the_exception TYPE REF TO cx_root,
          text_getter   TYPE REF TO /usi/cl_exception_text_getter,
          messages      TYPE /usi/if_exception_text_getter=>ty_bapiret2_tab.

    the_exception = get_nested_exception( ).

    CREATE OBJECT text_getter
      EXPORTING
        i_exception = the_exception.
    messages = text_getter->get_texts_as_bapiret2( ).

    display_messages(
      CHANGING
        c_messages = messages
    ).
  ENDMETHOD.

  METHOD run_symsg_demo.
    DATA: the_exception TYPE REF TO cx_root,
          text_getter   TYPE REF TO /usi/cl_exception_text_getter,
          messages      TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    the_exception = get_nested_exception( ).

    CREATE OBJECT text_getter
      EXPORTING
        i_exception = the_exception.
    messages = text_getter->get_texts_as_symsg( ).

    display_messages(
      CHANGING
        c_messages = messages
    ).
  ENDMETHOD.

  METHOD get_nested_exception.
    DATA: exception_factory TYPE REF TO lcl_exception_factory.

    CREATE OBJECT exception_factory.

    exception_factory->add_otr_conversion_no_number( `OTR_TEST1` ).
    exception_factory->add_t100_exception( i_msgid  = 'H2'
                                           i_msgno  = 103
                                           i_param1 = 'This'
                                           i_param2 = 'is'
                                           i_param3 = 'a'
                                           i_param4 = 'T100-Message' ).
    exception_factory->add_otr_unknown_type( `OTR_TEST2` ).
    exception_factory->add_t100_exception( i_msgid  = 'HH'
                                           i_msgno  = 101
                                           i_param1 = 'Another'
                                           i_param2 = 'T100-Message' ).

    r_result = exception_factory->the_exception.
  ENDMETHOD.

  METHOD display_messages.
    DATA: alv     TYPE REF TO cl_salv_table,
          columns TYPE REF TO cl_salv_columns_table.

    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = alv
          CHANGING
            t_table      = c_messages.

        columns = alv->get_columns( ).
        columns->set_optimize( ).

        alv->display( ).
      CATCH cx_salv_msg.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
