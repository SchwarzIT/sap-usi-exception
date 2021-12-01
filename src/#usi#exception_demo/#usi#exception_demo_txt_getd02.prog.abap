*&---------------------------------------------------------------------*
*& Include          /USI/EXCEPTION_DEMO_TXT_GETD02
*&---------------------------------------------------------------------*
CLASS lcl_demo_report DEFINITION FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS run_bapiret2_demo.
    CLASS-METHODS run_symsg_demo.

  PRIVATE SECTION.
    CLASS-METHODS get_nested_exception
      RETURNING
        VALUE(r_result) TYPE REF TO cx_root.

    CLASS-METHODS display_messages
      CHANGING
        c_messages TYPE STANDARD TABLE.
ENDCLASS.
