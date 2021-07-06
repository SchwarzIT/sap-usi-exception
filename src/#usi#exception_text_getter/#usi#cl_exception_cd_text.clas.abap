CLASS /usi/cl_exception_cd_text DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /usi/if_exception_cd_text .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /usi/cl_exception_cd_text IMPLEMENTATION.
  METHOD /usi/if_exception_cd_text~get_records.
    SELECT exception_class
           text_getter
      FROM /usi/except_text
      INTO CORRESPONDING FIELDS OF TABLE r_result.
  ENDMETHOD.
ENDCLASS.
