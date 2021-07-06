*"* use this source file for your ABAP unit test classes
CLASS lcl_unit_tests DEFINITION FINAL CREATE PUBLIC FOR TESTING.
  "#AU Risk_Level Harmless
  "#AU Duration   Short
  PRIVATE SECTION.
    METHODS test_get_text FOR TESTING.
ENDCLASS.

CLASS lcl_unit_tests IMPLEMENTATION.
  METHOD test_get_text.
    DATA: BEGIN OF given,
            textid    TYPE scx_t100key,
            symsg     TYPE symsg,
            exception TYPE REF TO /usi/cx_exception,
          END   OF given,
          cut    TYPE REF TO /usi/cl_exception_text_t100,
          result TYPE symsg.

    given-textid-msgid = '38'.
    given-textid-msgno = '001'.
    given-textid-attr1 = 'PARAM1'.
    given-textid-attr2 = 'PARAM2'.
    given-textid-attr3 = 'PARAM3'.

    given-symsg-msgty  = 'E'.
    given-symsg-msgid  = given-textid-msgid.
    given-symsg-msgno  = given-textid-msgno.
    given-symsg-msgv1  = 'Just'.
    given-symsg-msgv2  = 'a'.
    given-symsg-msgv3  = 'test...'.

    TRY.
        RAISE EXCEPTION TYPE /usi/cx_exception
          EXPORTING
            textid = given-textid
            param1 = given-symsg-msgv1
            param2 = given-symsg-msgv2
            param3 = given-symsg-msgv3.
      CATCH /usi/cx_exception INTO given-exception.
        CREATE OBJECT cut
          EXPORTING
            i_exception = given-exception.

        result = cut->/usi/if_exception_text~get_text_as_symsg( ).

        CL_AUNIT_ASSERT=>assert_equals( exp = given-symsg
                                        act = result
                                        msg = `Wrong message` ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
