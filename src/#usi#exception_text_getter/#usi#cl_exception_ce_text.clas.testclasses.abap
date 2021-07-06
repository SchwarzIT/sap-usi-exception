*"* use this source file for your ABAP unit test classes

*--------------------------------------------------------------------*
* Exception Subclass
*--------------------------------------------------------------------*
CLASS lcx_subclass DEFINITION FINAL CREATE PUBLIC INHERITING FROM /usi/cx_exception.
ENDCLASS.

*--------------------------------------------------------------------*
* Test-Double for DAO (To inject customizing)
*--------------------------------------------------------------------*
CLASS lcl_test_double_cust_dao DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES /usi/if_exception_cd_text.

    METHODS set_mock_data
      IMPORTING
        i_mock_data TYPE /usi/if_exception_cd_text=>ty_records.

  PRIVATE SECTION.
    DATA mock_data TYPE /usi/if_exception_cd_text=>ty_records.
ENDCLASS.

CLASS lcl_test_double_cust_dao IMPLEMENTATION.
  METHOD /usi/if_exception_cd_text~get_records.
    r_result = mock_data.
  ENDMETHOD.

  METHOD set_mock_data.
    mock_data = i_mock_data.
  ENDMETHOD.
ENDCLASS.

*--------------------------------------------------------------------*
* CUT-Destructor - destroys the singleton
*--------------------------------------------------------------------*
CLASS lcl_cut_destructor DEFINITION DEFERRED.
CLASS /usi/cl_exception_ce_text DEFINITION LOCAL FRIENDS lcl_cut_destructor.

CLASS lcl_cut_destructor DEFINITION FOR TESTING.
  PUBLIC SECTION.
    CLASS-METHODS destroy_cut.
ENDCLASS.

CLASS lcl_cut_destructor IMPLEMENTATION.
  METHOD destroy_cut.
    CLEAR /usi/cl_exception_ce_text=>singleton.
  ENDMETHOD.
ENDCLASS.

*--------------------------------------------------------------------*
* Class description
*--------------------------------------------------------------------*
CLASS lcl_class_description DEFINITION FOR TESTING.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_classname TYPE seoclsname.

    METHODS is_implementing
      IMPORTING
        i_interface_name TYPE seoclsname
      RETURNING
        VALUE(r_result)  TYPE abap_bool.

    METHODS is_instantiatable
      RETURNING
        VALUE(r_result) TYPE abap_bool.

  PRIVATE SECTION.
    DATA class_description TYPE REF TO cl_abap_classdescr.
ENDCLASS.

CLASS lcl_class_description IMPLEMENTATION.
  METHOD constructor.
    DATA type_description TYPE REF TO cl_abap_typedescr.

    cl_abap_typedescr=>describe_by_name(
      EXPORTING
        p_name         = i_classname
      RECEIVING
        p_descr_ref    = type_description
      EXCEPTIONS
        type_not_found = 1
        OTHERS         = 2
    ).
    IF sy-subrc NE 0 OR
       type_description IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.
        class_description ?= type_description.
      CATCH cx_sy_move_cast_error.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD is_implementing.
    IF class_description IS NOT BOUND.
      RETURN.
    ENDIF.

    READ TABLE class_description->interfaces
      TRANSPORTING NO FIELDS
      WITH KEY name = i_interface_name.
    IF sy-subrc EQ 0.
      r_result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_instantiatable.
    IF class_description IS NOT BOUND.
      RETURN.
    ENDIF.

    r_result  = class_description->is_instantiatable( ).
  ENDMETHOD.
ENDCLASS.

*--------------------------------------------------------------------*
* Unit tests
*--------------------------------------------------------------------*
CLASS lcl_unit_tests DEFINITION FINAL FOR TESTING.
  "#AU Risk_Level Harmless
  "#AU Duration   Short
  PRIVATE SECTION.
    DATA: test_double_cust_dao TYPE REF TO lcl_test_double_cust_dao.

    METHODS setup.
    METHODS reset_cut.
    METHODS get_fallback_class_name
      RETURNING
        VALUE(r_result) TYPE /usi/exception_text_getter.

    METHODS test_ignore_invalid_exceptions FOR TESTING.
    METHODS test_ignore_invalid_mappers    FOR TESTING.
    METHODS test_match_class               FOR TESTING.
    METHODS test_match_new_interface       FOR TESTING.
    METHODS test_match_superclass          FOR TESTING.
    METHODS test_validate_fallback         FOR TESTING.
    METHODS test_instance_creation         FOR TESTING.

    METHODS assert_expected_result
      IMPORTING
        i_customizing     TYPE /usi/if_exception_cd_text=>ty_records
        i_exception       TYPE REF TO cx_root
        i_expected_result TYPE /usi/exception_text_getter
        i_message         TYPE csequence.
ENDCLASS.

CLASS lcl_unit_tests IMPLEMENTATION.
  METHOD setup.
    reset_cut( ).
  ENDMETHOD.

  METHOD reset_cut.
    lcl_cut_destructor=>destroy_cut( ).
    CREATE OBJECT test_double_cust_dao TYPE lcl_test_double_cust_dao.
  ENDMETHOD.

  METHOD get_fallback_class_name.
    DATA cut TYPE REF TO /usi/if_exception_ce_text.
    cut      = /usi/cl_exception_ce_text=>get_instance( ).
    r_result = cut->get_fallback_classname( ).
  ENDMETHOD.

  METHOD test_ignore_invalid_exceptions.
    DATA: cust_records   TYPE /usi/if_exception_cd_text=>ty_records,
          cust_record    TYPE /usi/if_exception_cd_text=>ty_record,
          expected_value TYPE /usi/exception_text_getter,
          input          TYPE REF TO /usi/cx_exception.

    TRY.
        RAISE EXCEPTION TYPE /usi/cx_exception.
      CATCH /usi/cx_exception INTO input.
        cust_record-text_getter     = get_fallback_class_name( ).
        cust_record-exception_class = 'CL_GUI_ALV_GRID'.
        INSERT cust_record INTO TABLE cust_records.
        cust_record-exception_class = 'UNKNOWN_TYPE'.
        INSERT cust_record INTO TABLE cust_records.
        cust_record-exception_class = 'XFELD'.
        INSERT cust_record INTO TABLE cust_records.

        expected_value = get_fallback_class_name( ).

        assert_expected_result(
          i_customizing     = cust_records
          i_exception       = input
          i_expected_result = expected_value
          i_message         = 'Invalid mapper classes must be ignored!'
        ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_ignore_invalid_mappers.
    DATA: cust_records   TYPE /usi/if_exception_cd_text=>ty_records,
          cust_record    TYPE /usi/if_exception_cd_text=>ty_record,
          expected_value TYPE /usi/exception_text_getter,
          input          TYPE REF TO /usi/cx_exception.

    TRY.
        RAISE EXCEPTION TYPE /usi/cx_exception.
      CATCH /usi/cx_exception INTO input.
        cust_record-exception_class = 'IF_T100_MESSAGE'.
        cust_record-text_getter     = 'CL_GUI_ALV_GRID'.
        INSERT cust_record INTO TABLE cust_records.
        cust_record-text_getter     = 'UNKNOWN_TYPE'.
        INSERT cust_record INTO TABLE cust_records.
        cust_record-text_getter     = 'XFELD'.
        INSERT cust_record INTO TABLE cust_records.

        expected_value = get_fallback_class_name( ).

        assert_expected_result(
          i_customizing     = cust_records
          i_exception       = input
          i_expected_result = expected_value
          i_message         = 'Invalid mapper classes must be ignored!'
        ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_match_class.
    DATA: cust_records   TYPE /usi/if_exception_cd_text=>ty_records,
          cust_record    TYPE /usi/if_exception_cd_text=>ty_record,
          expected_value TYPE /usi/exception_text_getter,
          input          TYPE REF TO /usi/cx_exception.

    TRY.
        RAISE EXCEPTION TYPE /usi/cx_exception.
      CATCH /usi/cx_exception INTO input.
        DO 2 TIMES.
          IF sy-index EQ 1.
            expected_value = '/USI/CL_EXCEPTION_TEXT_T100'.
          ELSE.
            expected_value = '/USI/CL_EXCEPTION_TEXT_OTR'.
          ENDIF.

          CLEAR: cust_records, cust_record.
          cust_record-exception_class = '/USI/CX_EXCEPTION'.
          cust_record-text_getter     = expected_value.
          INSERT cust_record INTO TABLE cust_records.

          assert_expected_result(
            i_customizing     = cust_records
            i_exception       = input
            i_expected_result = expected_value
            i_message         = 'Unexpected text getter class!'
          ).
        ENDDO.
    ENDTRY.
  ENDMETHOD.

  METHOD test_match_new_interface.
    CONSTANTS: expected_value TYPE /usi/exception_text_getter VALUE '/USI/CL_EXCEPTION_TEXT_T100'.

    DATA: cust_records TYPE /usi/if_exception_cd_text=>ty_records,
          cust_record  TYPE /usi/if_exception_cd_text=>ty_record,
          input        TYPE REF TO /usi/cx_exception.

    TRY.
        RAISE EXCEPTION TYPE /usi/cx_exception.
      CATCH /usi/cx_exception INTO input.
        cust_record-exception_class = 'CX_ROOT'.
        cust_record-text_getter     = '/USI/CL_EXCEPTION_TEXT_OTR'.
        INSERT cust_record INTO TABLE cust_records.
        cust_record-exception_class = 'IF_T100_MESSAGE'.
        cust_record-text_getter     = expected_value.
        INSERT cust_record INTO TABLE cust_records.

        assert_expected_result(
          i_customizing     = cust_records
          i_exception       = input
          i_expected_result = expected_value
          i_message         = 'Unexpected text getter class!'
        ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_match_superclass.
    CONSTANTS: expected_value TYPE /usi/exception_text_getter VALUE '/USI/CL_EXCEPTION_TEXT_T100'.

    DATA: cust_records TYPE /usi/if_exception_cd_text=>ty_records,
          cust_record  TYPE /usi/if_exception_cd_text=>ty_record,
          input        TYPE REF TO cx_root.

    TRY.
        RAISE EXCEPTION TYPE lcx_subclass.
      CATCH /usi/cx_exception INTO input.
        cust_record-exception_class = '/USI/CX_EXCEPTION'.
        cust_record-text_getter     = expected_value.
        INSERT cust_record INTO TABLE cust_records.

        assert_expected_result(
          i_customizing     = cust_records
          i_exception       = input
          i_expected_result = expected_value
          i_message         = 'Unexpected text getter class!'
        ).
    ENDTRY.
  ENDMETHOD.

  METHOD assert_expected_result.
    DATA: actual_value TYPE /usi/exception_text_getter,
          cut          TYPE REF TO /usi/if_exception_ce_text.

    reset_cut( ).
    test_double_cust_dao->set_mock_data( i_customizing ).
    cut = /usi/cl_exception_ce_text=>get_instance( test_double_cust_dao ).

    actual_value = cut->get_text_getter_classname( i_exception ).

    cl_aunit_assert=>assert_equals(
      exp = i_expected_result
      act = actual_value
      msg = 'Unexpected text getter class!'
    ).
  ENDMETHOD.

  METHOD test_validate_fallback.
    CONSTANTS text_getter_interface_name TYPE seoclsname VALUE '/USI/IF_EXCEPTION_TEXT'.

    DATA: fallback_class_name TYPE /usi/exception_text_getter,
          class_description   TYPE REF TO lcl_class_description.

    fallback_class_name = get_fallback_class_name( ).

    CREATE OBJECT class_description
      EXPORTING
        i_classname = fallback_class_name.

    IF class_description->is_implementing( text_getter_interface_name ) NE abap_true OR
       class_description->is_instantiatable( ) NE abap_true.
      cl_aunit_assert=>fail( msg    = 'Invalid fallback for text getter class!'
                             detail = fallback_class_name ).
    ENDIF.
  ENDMETHOD.

  METHOD test_instance_creation.
    DATA: actual_result     TYPE REF TO /usi/if_exception_text,
          cust_records      TYPE /usi/if_exception_cd_text=>ty_records,
          cust_record       TYPE /usi/if_exception_cd_text=>ty_record,
          cut               TYPE REF TO /usi/if_exception_ce_text,
          input             TYPE REF TO /usi/cx_exception.

    TRY.
        RAISE EXCEPTION TYPE /usi/cx_exception.
      CATCH /usi/cx_exception INTO input.
        reset_cut( ).
        cust_record-exception_class = '/USI/CX_EXCEPTION'.
        cust_record-text_getter     = '/USI/CL_EXCEPTION_TEXT_OTR'.
        INSERT cust_record INTO TABLE cust_records.
        test_double_cust_dao->set_mock_data( cust_records ).
        cut = /usi/cl_exception_ce_text=>get_instance( test_double_cust_dao ).

        actual_result = cut->get_text_getter( input ).

        cl_aunit_assert=>assert_bound(
          act = actual_result
          msg = 'Method _MUST NOT_ return null!'
        ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
