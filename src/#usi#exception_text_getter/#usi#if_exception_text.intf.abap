INTERFACE /usi/if_exception_text
  PUBLIC .


  METHODS get_text_as_symsg
    RETURNING
      VALUE(r_result) TYPE symsg .
ENDINTERFACE.
