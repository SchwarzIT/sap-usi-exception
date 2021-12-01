class /USI/CL_EXCEPTION_TEXT_OTR definition
  public
  final
  create public .

public section.

  interfaces /USI/IF_EXCEPTION_TEXT .

  methods CONSTRUCTOR
    importing
      !I_EXCEPTION type ref to CX_ROOT .
  PROTECTED SECTION.
private section.

  types TY_MESSAGE_TEXT type CHAR200 .

  data EXCEPTION_TEXT type SYMSG .

  methods PRESERVE_TRAILING_SPACES
    importing
      !I_MESSAGE_TEXT type TY_MESSAGE_TEXT
    returning
      value(R_RESULT) type TY_MESSAGE_TEXT .
ENDCLASS.



CLASS /USI/CL_EXCEPTION_TEXT_OTR IMPLEMENTATION.


  METHOD /usi/if_exception_text~get_text_as_symsg.
    r_result = exception_text.
  ENDMETHOD.


  METHOD constructor.
    DATA: the_text                  TYPE ty_message_text,
          dummy_for_where_used_list TYPE string.

    the_text = i_exception->get_text( ).
    the_text = preserve_trailing_spaces( the_text ).

    MESSAGE e000(/usi/exception) WITH space space space space INTO dummy_for_where_used_list.
    exception_text-msgty = 'E'.
    exception_text-msgid = '/USI/EXCEPTION'.
    exception_text-msgno = '000'.
    exception_text-msgv1 = the_text+000(50).
    exception_text-msgv2 = the_text+050(50).
    exception_text-msgv3 = the_text+100(50).
    exception_text-msgv4 = the_text+150(50).
  ENDMETHOD.


  METHOD preserve_trailing_spaces.
    CONSTANTS: length_of_message_variable TYPE i VALUE 50.

    DATA: current_offset  TYPE i,
          next_offset     TYPE i,
          strlen          TYPE i,
          trailing_spaces TYPE i.

    r_result = i_message_text.

    DO 3 TIMES.
      current_offset  = ( sy-index - 1 ) * length_of_message_variable.
      next_offset     = current_offset + length_of_message_variable.
      trailing_spaces = length_of_message_variable - strlen( r_result+current_offset(length_of_message_variable) ).

      CHECK trailing_spaces GT 0
        AND trailing_spaces LT length_of_message_variable.

      SHIFT r_result+next_offset RIGHT BY trailing_spaces PLACES.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
