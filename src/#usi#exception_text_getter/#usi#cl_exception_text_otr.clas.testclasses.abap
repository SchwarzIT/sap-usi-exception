*"* use this source file for your ABAP unit test classes
CLASS lcx_otr_exception DEFINITION FOR TESTING INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_text     TYPE string
        i_previous TYPE REF TO cx_root OPTIONAL.

    METHODS if_message~get_text REDEFINITION.

  PRIVATE SECTION.
    DATA my_text TYPE string.
ENDCLASS.

CLASS lcx_otr_exception IMPLEMENTATION.
  METHOD constructor.
    super->constructor( previous = i_previous ).
    my_text = i_text.
  ENDMETHOD.

  METHOD if_message~get_text.
    result = my_text.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_unit_tests DEFINITION FINAL CREATE PUBLIC FOR TESTING.
  "#AU Risk_Level Harmless
  "#AU Duration   Short
  PRIVATE SECTION.
    METHODS test_get_text FOR TESTING.
    METHODS test_trailing_spaces FOR TESTING.
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

  METHOD test_trailing_spaces.
    DATA: cut TYPE REF TO /usi/cl_exception_text_otr,
          BEGIN OF texts,
            char50_with_trailing_space TYPE symsgv,
            given                      TYPE string,
            as_symsg                   TYPE symsg,
            reassembled                TYPE string,
          END   OF texts,
          the_exception TYPE REF TO lcx_otr_exception.

    CONCATENATE sy-abcde
                sy-abcde
           INTO texts-char50_with_trailing_space
           IN CHARACTER MODE.
    texts-char50_with_trailing_space+49(1) = space.

    CONCATENATE texts-char50_with_trailing_space
                texts-char50_with_trailing_space
                texts-char50_with_trailing_space
           INTO texts-given
           IN CHARACTER MODE
           RESPECTING BLANKS.
    CONDENSE texts-given.

    TRY.
        RAISE EXCEPTION TYPE lcx_otr_exception
          EXPORTING
            i_text = texts-given.
      CATCH lcx_otr_exception INTO the_exception.
        CREATE OBJECT cut
          EXPORTING
            i_exception = the_exception.

        texts-as_symsg = cut->/usi/if_exception_text~get_text_as_symsg( ).

        MESSAGE ID     texts-as_symsg-msgid
                TYPE   'S'
                NUMBER texts-as_symsg-msgno
                WITH   texts-as_symsg-msgv1
                       texts-as_symsg-msgv2
                       texts-as_symsg-msgv3
                       texts-as_symsg-msgv4
                INTO   texts-reassembled.

        cl_aunit_assert=>assert_equals( exp = texts-given
                                        act = texts-reassembled ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
