INTERFACE /usi/if_exception_ce_text
  PUBLIC .


  METHODS get_text_getter
    IMPORTING
      !i_exception    TYPE REF TO cx_root
    RETURNING
      VALUE(r_result) TYPE REF TO /usi/if_exception_text .
  METHODS get_text_getter_classname
    IMPORTING
      !i_exception    TYPE REF TO cx_root
    RETURNING
      VALUE(r_result) TYPE /usi/exception_text_getter .
  METHODS get_fallback_classname
    RETURNING
      VALUE(r_result) TYPE /usi/exception_text_getter .
ENDINTERFACE.
