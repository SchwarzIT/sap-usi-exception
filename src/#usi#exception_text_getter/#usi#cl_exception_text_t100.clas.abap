class /USI/CL_EXCEPTION_TEXT_T100 definition
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



CLASS /USI/CL_EXCEPTION_TEXT_T100 IMPLEMENTATION.


  METHOD /usi/if_exception_text~get_text_as_symsg.
    r_result = exception_text.
  ENDMETHOD.


  METHOD constructor.
    DATA: t100_message TYPE REF TO if_t100_message.

    t100_message ?= i_exception.
    cl_message_helper=>set_msg_vars_for_if_t100_msg( t100_message ).

    exception_text-msgty = 'E'.
    exception_text-msgid = sy-msgid.
    exception_text-msgno = sy-msgno.
    exception_text-msgv1 = sy-msgv1.
    exception_text-msgv2 = sy-msgv2.
    exception_text-msgv3 = sy-msgv3.
    exception_text-msgv4 = sy-msgv4.
  ENDMETHOD.
ENDCLASS.
