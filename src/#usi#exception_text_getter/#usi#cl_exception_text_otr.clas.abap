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
  PRIVATE SECTION.

    DATA exception_text TYPE symsg .
ENDCLASS.



CLASS /USI/CL_EXCEPTION_TEXT_OTR IMPLEMENTATION.


  METHOD /usi/if_exception_text~get_text_as_symsg.
    r_result = exception_text.
  ENDMETHOD.


  METHOD constructor.
    DATA: the_text                  TYPE char200,
          dummy_for_where_used_list TYPE string.

    the_text = i_exception->get_text( ).

    MESSAGE e000(/usi/exception) WITH space space space space INTO dummy_for_where_used_list.
    exception_text-msgty = 'E'.
    exception_text-msgid = '/USI/EXCEPTION'.
    exception_text-msgno = '000'.
    exception_text-msgv1 = the_text+000(50).
    exception_text-msgv2 = the_text+050(50).
    exception_text-msgv3 = the_text+100(50).
    exception_text-msgv4 = the_text+150(50).
  ENDMETHOD.
ENDCLASS.
