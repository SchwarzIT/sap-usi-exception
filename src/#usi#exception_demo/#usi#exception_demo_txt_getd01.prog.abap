*&---------------------------------------------------------------------*
*& Include          /USI/EXCEPTION_DEMO_TXT_GETD01
*&---------------------------------------------------------------------*
CLASS lcl_exception_factory DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    DATA the_exception TYPE REF TO cx_root READ-ONLY.

    METHODS add_t100_exception
      IMPORTING
        i_msgid  TYPE symsgid
        i_msgno  TYPE symsgno
        i_param1 TYPE symsgv OPTIONAL
        i_param2 TYPE symsgv OPTIONAL
        i_param3 TYPE symsgv OPTIONAL
        i_param4 TYPE symsgv OPTIONAL.

    METHODS add_otr_conversion_no_number
      IMPORTING
        i_value TYPE string.

    METHODS add_otr_unknown_type
      IMPORTING
        i_type_name TYPE string.
ENDCLASS.
