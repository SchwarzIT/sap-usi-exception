interface /USI/IF_EXCEPTION_TEXT_GETTER
  public .


  types:
    ty_bapiret1_tab     TYPE STANDARD TABLE OF bapiret1     WITH NON-UNIQUE DEFAULT KEY .
  types:
    ty_bapiret2_tab     TYPE STANDARD TABLE OF bapiret2     WITH NON-UNIQUE DEFAULT KEY .
  types:
    ty_powl_msg_sty_tab TYPE STANDARD TABLE OF powl_msg_sty WITH NON-UNIQUE DEFAULT KEY .
  types:
    ty_string_tab       TYPE STANDARD TABLE OF string       WITH NON-UNIQUE DEFAULT KEY .
  types:
    ty_symsg_tab        TYPE STANDARD TABLE OF symsg        WITH NON-UNIQUE DEFAULT KEY .

  methods GET_TEXTS_AS_BAPIRET1
    returning
      value(R_RESULT) type TY_BAPIRET1_TAB .
  methods GET_TEXTS_AS_BAPIRET2
    returning
      value(R_RESULT) type TY_BAPIRET2_TAB .
  methods GET_TEXTS_AS_POWL_MSG_STY
    returning
      value(R_RESULT) type TY_POWL_MSG_STY_TAB .
  methods GET_TEXTS_AS_STRING
    returning
      value(R_RESULT) type TY_STRING_TAB .
  methods GET_TEXTS_AS_SYMSG
    returning
      value(R_RESULT) type TY_SYMSG_TAB .
  methods GET_TEXT_AS_BAPIRET1
    returning
      value(R_RESULT) type BAPIRET1 .
  methods GET_TEXT_AS_BAPIRET2
    returning
      value(R_RESULT) type BAPIRET2 .
  methods GET_TEXT_AS_POWL_MSG_STY
    returning
      value(R_RESULT) type POWL_MSG_STY .
  methods GET_TEXT_AS_STRING
    returning
      value(R_RESULT) type STRING .
  methods GET_TEXT_AS_SYMSG
    returning
      value(R_RESULT) type SYMSG .
endinterface.
