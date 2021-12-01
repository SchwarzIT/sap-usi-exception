*&---------------------------------------------------------------------*
*& Include          /USI/EXCEPTION_DEMO_TXT_GETTOP
*&---------------------------------------------------------------------*
INCLUDE: /usi/exception_demo_txt_getd01,
         /usi/exception_demo_txt_getd02.

" Output format
SELECTION-SCREEN BEGIN OF BLOCK output_format WITH FRAME TITLE TEXT-f02.
PARAMETERS: bapiret2 TYPE xfeld RADIOBUTTON GROUP form DEFAULT 'X',
            symsg    TYPE xfeld RADIOBUTTON GROUP form.
SELECTION-SCREEN END OF BLOCK output_format.
