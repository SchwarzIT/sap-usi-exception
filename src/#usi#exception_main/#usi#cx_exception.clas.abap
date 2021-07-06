class /USI/CX_EXCEPTION definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces /USI/IF_EXCEPTION_TEXT_GETTER .

  aliases GET_TEXTS_AS_BAPIRET1
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXTS_AS_BAPIRET1 .
  aliases GET_TEXTS_AS_BAPIRET2
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXTS_AS_BAPIRET2 .
  aliases GET_TEXTS_AS_POWL_MSG_STY
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXTS_AS_POWL_MSG_STY .
  aliases GET_TEXTS_AS_SYMSG
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXTS_AS_SYMSG .
  aliases GET_TEXT_AS_BAPIRET1
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXT_AS_BAPIRET1 .
  aliases GET_TEXT_AS_BAPIRET2
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXT_AS_BAPIRET2 .
  aliases GET_TEXT_AS_POWL_MSG_STY
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXT_AS_POWL_MSG_STY .
  aliases GET_TEXT_AS_SYMSG
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXT_AS_SYMSG .

  data PARAM1 type SYMSGV read-only .
  data PARAM2 type SYMSGV read-only .
  data PARAM3 type SYMSGV read-only .
  data PARAM4 type SYMSGV read-only .
  data DETAILS type ref to /USI/IF_EXCEPTION_DETAILS read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !PARAM1 type SYMSGV optional
      !PARAM2 type SYMSGV optional
      !PARAM3 type SYMSGV optional
      !PARAM4 type SYMSGV optional
      !DETAILS type ref to /USI/IF_EXCEPTION_DETAILS optional .
protected section.
private section.
ENDCLASS.



CLASS /USI/CX_EXCEPTION IMPLEMENTATION.


  METHOD /usi/if_exception_text_getter~get_texts_as_bapiret1.
    DATA text_getter TYPE REF TO /usi/cl_exception_text_getter.
    CREATE OBJECT text_getter
      EXPORTING
        i_exception = me.
    r_result = text_getter->get_texts_as_bapiret1( ).
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_texts_as_bapiret2.
    DATA text_getter TYPE REF TO /usi/cl_exception_text_getter.
    CREATE OBJECT text_getter
      EXPORTING
        i_exception = me.
    r_result = text_getter->get_texts_as_bapiret2( ).
  ENDMETHOD.


  method /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXTS_AS_POWL_MSG_STY.
    DATA text_getter TYPE REF TO /usi/cl_exception_text_getter.
    CREATE OBJECT text_getter
      EXPORTING
        i_exception = me.
    r_result = text_getter->get_texts_as_powl_msg_sty( ).
  endmethod.


  METHOD /usi/if_exception_text_getter~get_texts_as_string.
    DATA text_getter TYPE REF TO /usi/cl_exception_text_getter.
    CREATE OBJECT text_getter
      EXPORTING
        i_exception = me.
    r_result = text_getter->get_texts_as_string( ).
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_texts_as_symsg.
    DATA text_getter TYPE REF TO /usi/cl_exception_text_getter.
    CREATE OBJECT text_getter
      EXPORTING
        i_exception = me.
    r_result = text_getter->get_texts_as_symsg( ).
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_text_as_bapiret1.
    DATA text_getter TYPE REF TO /usi/cl_exception_text_getter.
    CREATE OBJECT text_getter
      EXPORTING
        i_exception = me.
    r_result = text_getter->get_text_as_bapiret1( ).
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_text_as_bapiret2.
    DATA text_getter TYPE REF TO /usi/cl_exception_text_getter.
    CREATE OBJECT text_getter
      EXPORTING
        i_exception = me.
    r_result = text_getter->get_text_as_bapiret2( ).
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_text_as_powl_msg_sty.
    DATA text_getter TYPE REF TO /usi/cl_exception_text_getter.
    CREATE OBJECT text_getter
      EXPORTING
        i_exception = me.
    r_result = text_getter->get_text_as_powl_msg_sty( ).
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_text_as_string.
    DATA text_getter TYPE REF TO /usi/cl_exception_text_getter.
    CREATE OBJECT text_getter
      EXPORTING
        i_exception = me.
    r_result = text_getter->get_text_as_string( ).
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_text_as_symsg.
    DATA text_getter TYPE REF TO /usi/cl_exception_text_getter.
    CREATE OBJECT text_getter
      EXPORTING
        i_exception = me.
    r_result = text_getter->get_text_as_symsg( ).
  ENDMETHOD.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->PARAM1 = PARAM1 .
me->PARAM2 = PARAM2 .
me->PARAM3 = PARAM3 .
me->PARAM4 = PARAM4 .
me->DETAILS = DETAILS .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
