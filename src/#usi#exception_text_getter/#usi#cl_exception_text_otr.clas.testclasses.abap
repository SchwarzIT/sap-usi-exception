*"* use this source file for your ABAP unit test classes
CLASS lcl_unit_tests DEFINITION FINAL CREATE PUBLIC FOR TESTING.
  "#AU Risk_Level Harmless
  "#AU Duration   Short
  PRIVATE SECTION.
    METHODS test_get_text FOR TESTING.
ENDCLASS.

CLASS lcl_unit_tests IMPLEMENTATION.
  METHOD test_get_text.
    DATA: exception      TYPE REF TO cx_root,
          exception_text TYPE string,
          cut            TYPE REF TO /usi/cl_exception_text_otr,
          result         TYPE symsg,
          result_text    TYPE string.

    TRY.
        sy-subrc = 1 + 'A'.
      CATCH cx_sy_conversion_no_number INTO exception.
        exception_text = exception->get_text( ).
    ENDTRY.

    CREATE OBJECT cut
      EXPORTING
        i_exception = exception.
    result = cut->/usi/if_exception_text~get_text_as_symsg( ).

    MESSAGE ID result-msgid TYPE 'S' NUMBER result-msgno
       WITH result-msgv1 result-msgv2 result-msgv3 result-msgv4
       INTO result_text.
    cl_aunit_assert=>assert_equals( exp = exception_text
                                    act = result_text
                                    msg = `Wrong message` ).
  ENDMETHOD.
ENDCLASS.
