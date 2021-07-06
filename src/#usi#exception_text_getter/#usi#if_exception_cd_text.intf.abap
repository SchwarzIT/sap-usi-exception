INTERFACE /usi/if_exception_cd_text
  PUBLIC .

  TYPES:
    BEGIN OF ty_record,
      exception_class TYPE /usi/exception_classname,
      text_getter     TYPE /usi/exception_text_getter,
    END   OF ty_record .
  TYPES:
    ty_records TYPE STANDARD TABLE OF ty_record WITH NON-UNIQUE DEFAULT KEY.

  METHODS get_records
    RETURNING
      VALUE(r_result) TYPE ty_records.

ENDINTERFACE.
