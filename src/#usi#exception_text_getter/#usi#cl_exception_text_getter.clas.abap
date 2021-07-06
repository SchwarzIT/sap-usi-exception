class /USI/CL_EXCEPTION_TEXT_GETTER definition
  public
  final
  create public .

public section.

  interfaces /USI/IF_EXCEPTION_TEXT_GETTER .

  aliases GET_TEXTS_AS_BAPIRET1
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXTS_AS_BAPIRET1 .
  aliases GET_TEXTS_AS_BAPIRET2
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXTS_AS_BAPIRET2 .
  aliases GET_TEXTS_AS_POWL_MSG_STY
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXTS_AS_POWL_MSG_STY .
  aliases GET_TEXTS_AS_STRING
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXTS_AS_STRING .
  aliases GET_TEXTS_AS_SYMSG
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXTS_AS_SYMSG .
  aliases GET_TEXT_AS_BAPIRET1
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXT_AS_BAPIRET1 .
  aliases GET_TEXT_AS_BAPIRET2
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXT_AS_BAPIRET2 .
  aliases GET_TEXT_AS_POWL_MSG_STY
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXT_AS_POWL_MSG_STY .
  aliases GET_TEXT_AS_STRING
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXT_AS_STRING .
  aliases GET_TEXT_AS_SYMSG
    for /USI/IF_EXCEPTION_TEXT_GETTER~GET_TEXT_AS_SYMSG .

  methods CONSTRUCTOR
    importing
      !I_EXCEPTION type ref to CX_ROOT .
  PROTECTED SECTION.

  PRIVATE SECTION.
    ALIASES ty_symsg_tab FOR /usi/if_exception_text_getter~ty_symsg_tab.

    DATA: exception      TYPE REF TO cx_root,
          cust_evaluator TYPE REF TO /usi/if_exception_ce_text.

    METHODS convert_symsg_to_bapiret1
      IMPORTING
        !i_symsg        TYPE symsg
      RETURNING
        VALUE(r_result) TYPE bapiret1 .

    METHODS convert_symsg_to_bapiret2
      IMPORTING
        !i_symsg        TYPE symsg
      RETURNING
        VALUE(r_result) TYPE bapiret2 .

    METHODS convert_symsg_to_powl_msg_sty
      IMPORTING
        !i_symsg        TYPE symsg
      RETURNING
        VALUE(r_result) TYPE powl_msg_sty .
ENDCLASS.



CLASS /USI/CL_EXCEPTION_TEXT_GETTER IMPLEMENTATION.


  METHOD /usi/if_exception_text_getter~get_texts_as_bapiret1.
    DATA: symsg_texts   TYPE ty_symsg_tab,
          bapiret1_text TYPE bapiret1.

    FIELD-SYMBOLS <symsg_text> TYPE symsg.

    symsg_texts = get_texts_as_symsg( ).
    LOOP AT symsg_texts ASSIGNING <symsg_text>.
      bapiret1_text = convert_symsg_to_bapiret1( <symsg_text> ).
      INSERT bapiret1_text INTO TABLE r_result.
    ENDLOOP.
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_texts_as_bapiret2.
    DATA: symsg_texts   TYPE ty_symsg_tab,
          bapiret2_text TYPE bapiret2.

    FIELD-SYMBOLS <symsg_text> TYPE symsg.

    symsg_texts = get_texts_as_symsg( ).
    LOOP AT symsg_texts ASSIGNING <symsg_text>.
      bapiret2_text = convert_symsg_to_bapiret2( <symsg_text> ).
      INSERT bapiret2_text INTO TABLE r_result.
    ENDLOOP.
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_texts_as_powl_msg_sty.
    DATA: symsg_texts       TYPE ty_symsg_tab,
          powl_msg_sty_text TYPE powl_msg_sty.

    FIELD-SYMBOLS <symsg_text> TYPE symsg.

    symsg_texts = get_texts_as_symsg( ).
    LOOP AT symsg_texts ASSIGNING <symsg_text>.
      powl_msg_sty_text = convert_symsg_to_powl_msg_sty( <symsg_text> ).
      INSERT powl_msg_sty_text INTO TABLE r_result.
    ENDLOOP.
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_texts_as_string.
    DATA: current_exception TYPE REF TO cx_root,
          text              TYPE string.

    current_exception = exception.
    WHILE current_exception IS BOUND.
      text = current_exception->get_text( ).
      INSERT text INTO TABLE r_result.

      current_exception = current_exception->previous.
    ENDWHILE.
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_texts_as_symsg.
    DATA: current_exception TYPE REF TO cx_root,
          text_getter       TYPE REF TO /usi/if_exception_text,
          text              TYPE symsg.

    current_exception = exception.
    WHILE current_exception IS BOUND.
      text_getter = cust_evaluator->get_text_getter( current_exception ).
      text        = text_getter->get_text_as_symsg( ).
      INSERT text INTO TABLE r_result.

      current_exception = current_exception->previous.
    ENDWHILE.
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_text_as_bapiret1.
    DATA exception_text TYPE symsg.
    exception_text = get_text_as_symsg( ).
    r_result       = convert_symsg_to_bapiret1( exception_text ).
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_text_as_bapiret2.
    DATA exception_text TYPE symsg.
    exception_text = get_text_as_symsg( ).
    r_result       = convert_symsg_to_bapiret2( exception_text ).
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_text_as_powl_msg_sty.
    DATA exception_text TYPE bapiret1.
    exception_text      = get_text_as_bapiret1( ).

    r_result-msgtype    = exception_text-type.
    r_result-msgid      = exception_text-id.
    r_result-msgnumber  = exception_text-number.
    r_result-message    = exception_text-message.
    r_result-message_v1 = exception_text-message_v1.
    r_result-message_v2 = exception_text-message_v2.
    r_result-message_v3 = exception_text-message_v3.
    r_result-message_v4 = exception_text-message_v4.
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_text_as_string.
    r_result = exception->get_text( ).
  ENDMETHOD.


  METHOD /usi/if_exception_text_getter~get_text_as_symsg.
    DATA text_getter TYPE REF TO /usi/if_exception_text.
    text_getter = cust_evaluator->get_text_getter( exception ).
    r_result    = text_getter->get_text_as_symsg( ).
  ENDMETHOD.


  METHOD constructor.
    exception      = i_exception.
    cust_evaluator = /usi/cl_exception_ce_text=>get_instance( ).
  ENDMETHOD.


  METHOD convert_symsg_to_bapiret1.
    CALL FUNCTION 'BALW_BAPIRETURN_GET1'
      EXPORTING
        type       = i_symsg-msgty
        cl         = i_symsg-msgid
        number     = i_symsg-msgno
        par1       = i_symsg-msgv1
        par2       = i_symsg-msgv2
        par3       = i_symsg-msgv3
        par4       = i_symsg-msgv4
      IMPORTING
        bapireturn = r_result.
  ENDMETHOD.


  METHOD convert_symsg_to_bapiret2.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = i_symsg-msgty
        cl     = i_symsg-msgid
        number = i_symsg-msgno
        par1   = i_symsg-msgv1
        par2   = i_symsg-msgv2
        par3   = i_symsg-msgv3
        par4   = i_symsg-msgv4
      IMPORTING
        return = r_result.
  ENDMETHOD.


  METHOD convert_symsg_to_powl_msg_sty.
    DATA exception_text TYPE bapiret1.

    exception_text      = convert_symsg_to_bapiret1( i_symsg ).
    r_result-msgtype    = exception_text-type.
    r_result-msgid      = exception_text-id.
    r_result-msgnumber  = exception_text-number.
    r_result-message    = exception_text-message.
    r_result-message_v1 = exception_text-message_v1.
    r_result-message_v2 = exception_text-message_v2.
    r_result-message_v3 = exception_text-message_v3.
    r_result-message_v4 = exception_text-message_v4.
  ENDMETHOD.
ENDCLASS.
