*"* use this source file for your ABAP unit test classes

*--------------------------------------------------------------------*
* Test-Doubles
*--------------------------------------------------------------------*
CLASS lcx_exception DEFINITION FINAL INHERITING FROM cx_static_check CREATE PUBLIC FOR TESTING.
  PUBLIC SECTION.
    DATA: message TYPE symsg READ-ONLY.

    METHODS constructor
      IMPORTING
        i_textid   LIKE textid OPTIONAL
        i_previous LIKE previous OPTIONAL
        i_message  TYPE symsg OPTIONAL.
ENDCLASS.
CLASS lcx_exception IMPLEMENTATION.
  METHOD constructor.
    super->constructor( textid   = i_textid
                        previous = i_previous ).
    me->message = i_message.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_test_double_exception_text DEFINITION FINAL CREATE PUBLIC FOR TESTING.
  PUBLIC SECTION.
    INTERFACES /usi/if_exception_text.

    METHODS constructor
      IMPORTING
        i_exception TYPE REF TO cx_root.

  PRIVATE SECTION.
    DATA exception TYPE REF TO lcx_exception.
ENDCLASS.
CLASS lcl_test_double_exception_text IMPLEMENTATION.
  METHOD constructor.
    TRY.
        exception ?= i_exception.
      CATCH cx_sy_move_cast_error.
        cl_aunit_assert=>fail( msg = 'Unsupported exception type' ).
    ENDTRY.
  ENDMETHOD.

  METHOD /usi/if_exception_text~get_text_as_symsg.
    r_result = exception->message.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_test_double_cust_evaluator DEFINITION CREATE PUBLIC FOR TESTING.
  PUBLIC SECTION.
    INTERFACES /usi/if_exception_ce_text.
ENDCLASS.
CLASS lcl_test_double_cust_evaluator IMPLEMENTATION.
  METHOD /usi/if_exception_ce_text~get_fallback_classname.
    cl_aunit_assert=>fail( msg = `Unexpected method call` ).
  ENDMETHOD.

  METHOD /usi/if_exception_ce_text~get_text_getter.
    CREATE OBJECT r_result TYPE lcl_test_double_exception_text
      EXPORTING
        i_exception = i_exception.
  ENDMETHOD.

  METHOD /usi/if_exception_ce_text~get_text_getter_classname.
    cl_aunit_assert=>fail( msg = `Unexpected method call` ).
  ENDMETHOD.
ENDCLASS.

*--------------------------------------------------------------------*
* Test-Double injector
*--------------------------------------------------------------------*
CLASS lcl_test_double_injector DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_cut TYPE REF TO /usi/cl_exception_text_getter.

    METHODS inject_test_double
      IMPORTING
        i_test_double TYPE REF TO /usi/if_exception_ce_text.
  PRIVATE SECTION.
    DATA cut TYPE REF TO /usi/cl_exception_text_getter.
ENDCLASS.
CLASS /usi/cl_exception_text_getter DEFINITION LOCAL FRIENDS lcl_test_double_injector.

CLASS lcl_test_double_injector IMPLEMENTATION.
  METHOD constructor.
    cut = i_cut.
  ENDMETHOD.

  METHOD inject_test_double.
    cut->cust_evaluator = i_test_double.
  ENDMETHOD.
ENDCLASS.

*--------------------------------------------------------------------*
* Unit test
*--------------------------------------------------------------------*
CLASS lcl_unit_test_happy_path DEFINITION FINAL FOR TESTING.
  "#AU Risk_Level Harmless
  "#AU Duration   Short
  PRIVATE SECTION.
    DATA: cut             TYPE REF TO /usi/cl_exception_text_getter,
          exception       TYPE REF TO lcx_exception,
          exception_texts TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    METHODS setup.

    METHODS get_dummy_exception
      RETURNING
        VALUE(r_result) TYPE REF TO lcx_exception.

    METHODS test_get_texts_as_bapiret1     FOR TESTING.
    METHODS test_get_texts_as_bapiret2     FOR TESTING.
    METHODS test_get_texts_as_powl_msg_sty FOR TESTING.
    METHODS test_get_texts_as_symsg        FOR TESTING.
    METHODS test_get_text_as_bapiret1      FOR TESTING.
    METHODS test_get_text_as_bapiret2      FOR TESTING.
    METHODS test_get_text_as_powl_msg_sty  FOR TESTING.
    METHODS test_get_text_as_symsg         FOR TESTING.

    METHODS convert_bapiret1_to_symsg
      IMPORTING
        i_messages      TYPE /usi/if_exception_text_getter=>ty_bapiret1_tab
      RETURNING
        VALUE(r_result) TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    METHODS convert_bapiret2_to_symsg
      IMPORTING
        i_messages      TYPE /usi/if_exception_text_getter=>ty_bapiret2_tab
      RETURNING
        VALUE(r_result) TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    METHODS convert_powl_to_symsg
      IMPORTING
        i_messages      TYPE /usi/if_exception_text_getter=>ty_powl_msg_sty_tab
      RETURNING
        VALUE(r_result) TYPE /usi/if_exception_text_getter=>ty_symsg_tab.
ENDCLASS.

CLASS lcl_unit_test_happy_path IMPLEMENTATION.
  METHOD setup.
    DATA: test_double_cust_evaluator TYPE REF TO lcl_test_double_cust_evaluator,
          test_double_injector       TYPE REF TO lcl_test_double_injector.

    exception = get_dummy_exception( ).
    CREATE OBJECT cut
      EXPORTING
        i_exception = exception.

    CREATE OBJECT test_double_cust_evaluator.
    CREATE OBJECT test_double_injector
      EXPORTING
        i_cut = cut.
    test_double_injector->inject_test_double( test_double_cust_evaluator ).
  ENDMETHOD.

  METHOD get_dummy_exception.
    DATA: message          TYPE symsg,
          previous         TYPE REF TO lcx_exception,
          previous_message TYPE symsg.

    message-msgty           = 'E'.
    message-msgid           = '38'.
    message-msgno           = '000'.
    message-msgv1           = 'This'.
    message-msgv1           = 'is'.
    message-msgv1           = 'a'.
    message-msgv1           = 'test'.
    INSERT message INTO TABLE exception_texts.

    previous_message-msgty  = 'W'.
    previous_message-msgid  = '38'.
    previous_message-msgno  = '001'.
    previous_message-msgv1  = 'This'.
    previous_message-msgv1  = 'is'.
    previous_message-msgv1  = 'another'.
    previous_message-msgv1  = 'test'.
    INSERT previous_message INTO TABLE exception_texts.

    TRY.
        TRY.
            RAISE EXCEPTION TYPE lcx_exception
              EXPORTING
                i_message = previous_message.
          CATCH lcx_exception INTO previous.
            RAISE EXCEPTION TYPE lcx_exception
              EXPORTING
                i_message  = message
                i_previous = previous.
        ENDTRY.
      CATCH lcx_exception INTO r_result.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD test_get_texts_as_bapiret1.
    DATA: actual_bapiret1 TYPE /usi/if_exception_text_getter=>ty_bapiret1_tab,
          actual_symsg    TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    actual_bapiret1 = cut->get_texts_as_bapiret1( ).
    actual_symsg    = convert_bapiret1_to_symsg( actual_bapiret1 ).
    cl_aunit_assert=>assert_equals(
      exp = exception_texts
      act = actual_symsg
      msg = 'Messages are not equal'
    ).
  ENDMETHOD.

  METHOD test_get_texts_as_bapiret2.
    DATA: actual_bapiret2 TYPE /usi/if_exception_text_getter=>ty_bapiret2_tab,
          actual_symsg    TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    actual_bapiret2 = cut->get_texts_as_bapiret2( ).
    actual_symsg    = convert_bapiret2_to_symsg( actual_bapiret2 ).
    cl_aunit_assert=>assert_equals(
      exp = exception_texts
      act = actual_symsg
      msg = 'Messages are not equal'
    ).
  ENDMETHOD.

  METHOD test_get_texts_as_powl_msg_sty.
    DATA: actual_powl  TYPE /usi/if_exception_text_getter=>ty_powl_msg_sty_tab,
          actual_symsg TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    actual_powl   = cut->get_texts_as_powl_msg_sty( ).
    actual_symsg  = convert_powl_to_symsg( actual_powl ).
    cl_aunit_assert=>assert_equals(
      exp = exception_texts
      act = actual_symsg
      msg = 'Messages are not equal'
    ).
  ENDMETHOD.

  METHOD test_get_texts_as_symsg.
    DATA: actual_symsg TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    actual_symsg = cut->get_texts_as_symsg( ).
    cl_aunit_assert=>assert_equals(
      exp = exception_texts
      act = actual_symsg
      msg = 'Messages are not equal'
    ).
  ENDMETHOD.

  METHOD test_get_text_as_bapiret1.
    DATA: bapiret1_message  TYPE bapiret1,
          bapiret1_messages TYPE /usi/if_exception_text_getter=>ty_bapiret1_tab,
          actual_messages   TYPE /usi/if_exception_text_getter=>ty_symsg_tab,
          expected_messages TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    bapiret1_message = cut->get_text_as_bapiret1( ).
    INSERT bapiret1_message INTO TABLE bapiret1_messages.
    actual_messages = convert_bapiret1_to_symsg( bapiret1_messages ).

    expected_messages = exception_texts.
    DELETE expected_messages FROM 2.

    cl_aunit_assert=>assert_equals(
      exp = expected_messages
      act = actual_messages
      msg = 'Messages are not equal'
    ).
  ENDMETHOD.

  METHOD test_get_text_as_bapiret2.
    DATA: bapiret2_message  TYPE bapiret2,
          bapiret2_messages TYPE /usi/if_exception_text_getter=>ty_bapiret2_tab,
          actual_messages   TYPE /usi/if_exception_text_getter=>ty_symsg_tab,
          expected_messages TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    bapiret2_message = cut->get_text_as_bapiret2( ).
    INSERT bapiret2_message INTO TABLE bapiret2_messages.
    actual_messages = convert_bapiret2_to_symsg( bapiret2_messages ).

    expected_messages = exception_texts.
    DELETE expected_messages FROM 2.

    cl_aunit_assert=>assert_equals(
      exp = expected_messages
      act = actual_messages
      msg = 'Messages are not equal'
    ).
  ENDMETHOD.

  METHOD test_get_text_as_powl_msg_sty.
    DATA: powl_message      TYPE powl_msg_sty,
          powl_messages     TYPE /usi/if_exception_text_getter=>ty_powl_msg_sty_tab,
          actual_messages   TYPE /usi/if_exception_text_getter=>ty_symsg_tab,
          expected_messages TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    powl_message = cut->get_text_as_powl_msg_sty( ).
    INSERT powl_message INTO TABLE powl_messages.
    actual_messages = convert_powl_to_symsg( powl_messages ).

    expected_messages = exception_texts.
    DELETE expected_messages FROM 2.

    cl_aunit_assert=>assert_equals(
      exp = expected_messages
      act = actual_messages
      msg = 'Messages are not equal'
    ).
  ENDMETHOD.

  METHOD test_get_text_as_symsg.
    DATA: actual_message    TYPE symsg,
          actual_messages   TYPE /usi/if_exception_text_getter=>ty_symsg_tab,
          expected_messages TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    actual_message = cut->get_text_as_symsg( ).
    INSERT actual_message INTO TABLE actual_messages.

    expected_messages = exception_texts.
    DELETE expected_messages FROM 2.

    cl_aunit_assert=>assert_equals(
      exp = expected_messages
      act = actual_messages
      msg = 'Messages are not equal'
    ).
  ENDMETHOD.

  METHOD convert_bapiret1_to_symsg.
    DATA symsg_message TYPE symsg.
    FIELD-SYMBOLS <bapiret1_message> TYPE bapiret1.

    LOOP AT i_messages ASSIGNING <bapiret1_message>.
      CLEAR symsg_message.
      symsg_message-msgty = <bapiret1_message>-type.
      symsg_message-msgno = <bapiret1_message>-number.
      symsg_message-msgid = <bapiret1_message>-id.
      symsg_message-msgv1 = <bapiret1_message>-message_v1.
      symsg_message-msgv2 = <bapiret1_message>-message_v2.
      symsg_message-msgv3 = <bapiret1_message>-message_v3.
      symsg_message-msgv4 = <bapiret1_message>-message_v4.
      INSERT symsg_message INTO TABLE r_result.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_bapiret2_to_symsg.
    DATA symsg_message TYPE symsg.
    FIELD-SYMBOLS <bapiret2_message> TYPE bapiret2.

    LOOP AT i_messages ASSIGNING <bapiret2_message>.
      CLEAR symsg_message.
      symsg_message-msgty = <bapiret2_message>-type.
      symsg_message-msgno = <bapiret2_message>-number.
      symsg_message-msgid = <bapiret2_message>-id.
      symsg_message-msgv1 = <bapiret2_message>-message_v1.
      symsg_message-msgv2 = <bapiret2_message>-message_v2.
      symsg_message-msgv3 = <bapiret2_message>-message_v3.
      symsg_message-msgv4 = <bapiret2_message>-message_v4.
      INSERT symsg_message INTO TABLE r_result.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_powl_to_symsg.
    DATA symsg_message TYPE symsg.
    FIELD-SYMBOLS <powl_message> TYPE powl_msg_sty .

    LOOP AT i_messages ASSIGNING <powl_message>.
      CLEAR symsg_message.
      symsg_message-msgty = <powl_message>-msgtype.
      symsg_message-msgno = <powl_message>-msgnumber.
      symsg_message-msgid = <powl_message>-msgid.
      symsg_message-msgv1 = <powl_message>-message_v1.
      symsg_message-msgv2 = <powl_message>-message_v2.
      symsg_message-msgv3 = <powl_message>-message_v3.
      symsg_message-msgv4 = <powl_message>-message_v4.
      INSERT symsg_message INTO TABLE r_result.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_unit_test_null DEFINITION FINAL FOR TESTING.
  "#AU Risk_Level Harmless
  "#AU Duration   Short
  PRIVATE SECTION.
    DATA: cut TYPE REF TO /usi/cl_exception_text_getter.

    METHODS setup.

    METHODS test_get_texts_as_bapiret1     FOR TESTING.
    METHODS test_get_texts_as_bapiret2     FOR TESTING.
    METHODS test_get_texts_as_powl_msg_sty FOR TESTING.
    METHODS test_get_texts_as_symsg        FOR TESTING.
ENDCLASS.

CLASS lcl_unit_test_null IMPLEMENTATION.
  METHOD setup.
    DATA: unbound_exception          TYPE REF TO lcx_exception,
          test_double_cust_evaluator TYPE REF TO lcl_test_double_cust_evaluator,
          test_double_injector       TYPE REF TO lcl_test_double_injector.

    CREATE OBJECT cut
      EXPORTING
        i_exception = unbound_exception.

    CREATE OBJECT test_double_cust_evaluator.
    CREATE OBJECT test_double_injector
      EXPORTING
        i_cut = cut.
    test_double_injector->inject_test_double( test_double_cust_evaluator ).
  ENDMETHOD.

  METHOD test_get_texts_as_bapiret1.
    DATA: bapiret1_messages TYPE /usi/if_exception_text_getter=>ty_bapiret1_tab.

    bapiret1_messages = cut->get_texts_as_bapiret1( ).
    cl_aunit_assert=>assert_initial( act = bapiret1_messages
                                     msg = `Result should be initial` ).
  ENDMETHOD.

  METHOD test_get_texts_as_bapiret2.
    DATA: bapiret2_messages TYPE /usi/if_exception_text_getter=>ty_bapiret2_tab.

    bapiret2_messages = cut->get_texts_as_bapiret2( ).
    cl_aunit_assert=>assert_initial( act = bapiret2_messages
                                     msg = `Result should be initial` ).
  ENDMETHOD.

  METHOD test_get_texts_as_powl_msg_sty.
    DATA: powl_messages TYPE /usi/if_exception_text_getter=>ty_powl_msg_sty_tab.

    powl_messages = cut->get_texts_as_powl_msg_sty( ).
    cl_aunit_assert=>assert_initial( act = powl_messages
                                     msg = `Result should be initial` ).
  ENDMETHOD.

  METHOD test_get_texts_as_symsg.
    DATA: symsg_messages TYPE /usi/if_exception_text_getter=>ty_symsg_tab.

    symsg_messages = cut->get_texts_as_symsg( ).
    cl_aunit_assert=>assert_initial( act = symsg_messages
                                     msg = `Result should be initial` ).
  ENDMETHOD.
ENDCLASS.
