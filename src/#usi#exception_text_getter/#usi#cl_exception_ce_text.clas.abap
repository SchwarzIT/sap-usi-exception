CLASS /usi/cl_exception_ce_text DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES /usi/if_exception_ce_text .

    METHODS constructor
      IMPORTING
        !i_customizing_dao TYPE REF TO /usi/if_exception_cd_text .

    CLASS-METHODS get_instance
      IMPORTING
        !i_customizing_dao TYPE REF TO /usi/if_exception_cd_text OPTIONAL
      RETURNING
        VALUE(r_result)    TYPE REF TO /usi/if_exception_ce_text .

  PROTECTED SECTION.
private section.

  aliases GET_FALLBACK_CLASSNAME
    for /USI/IF_EXCEPTION_CE_TEXT~GET_FALLBACK_CLASSNAME .
  aliases GET_TEXT_GETTER_CLASSNAME
    for /USI/IF_EXCEPTION_CE_TEXT~GET_TEXT_GETTER_CLASSNAME .

  types:
    BEGIN OF ty_customizing_entry,
      exception_class_type   TYPE seoclstype,
      exception_class_name   TYPE abap_abstypename,
      text_getter_class_name TYPE /usi/exception_text_getter,
    END   OF ty_customizing_entry .
  types:
    ty_customizing_entries TYPE HASHED TABLE OF ty_customizing_entry WITH UNIQUE KEY exception_class_type
                                                                                     exception_class_name .

  data CUSTOMIZING type TY_CUSTOMIZING_ENTRIES .
  class-data SINGLETON type ref to /USI/CL_EXCEPTION_CE_TEXT .

  methods GET_TEXT_GETTER_CLASSNAME_INT
    importing
      !I_EXCEPTION_CLASS_DESCRIPTION type ref to CL_ABAP_CLASSDESCR
    returning
      value(R_RESULT) type /USI/EXCEPTION_TEXT_GETTER .
ENDCLASS.



CLASS /USI/CL_EXCEPTION_CE_TEXT IMPLEMENTATION.


  METHOD /usi/if_exception_ce_text~get_fallback_classname.
    r_result = '/USI/CL_EXCEPTION_TEXT_OTR'.
  ENDMETHOD.


  METHOD /usi/if_exception_ce_text~get_text_getter.
    DATA mapper_classname TYPE /usi/exception_text_getter.

    mapper_classname = get_text_getter_classname( i_exception ).
    CREATE OBJECT r_result TYPE (mapper_classname)
      EXPORTING
        i_exception = i_exception.
  ENDMETHOD.


  METHOD /usi/if_exception_ce_text~get_text_getter_classname.
    DATA class_description TYPE REF TO cl_abap_classdescr.
    class_description ?= cl_abap_typedescr=>describe_by_object_ref( i_exception ).

    r_result = get_text_getter_classname_int( class_description ).
  ENDMETHOD.


  METHOD constructor.
    DATA: raw_customizing       TYPE /usi/if_exception_cd_text=>ty_records,
          customizing_entry     TYPE ty_customizing_entry,
          text_getter_validator TYPE REF TO lcl_text_getter_validator,
          exception_validator   TYPE REF TO lcl_exception_validator.

    FIELD-SYMBOLS: <raw_customizing_record> TYPE /usi/if_exception_cd_text=>ty_record.

    raw_customizing = i_customizing_dao->get_records( ).
    text_getter_validator = lcl_text_getter_validator=>get_instance( ).

    LOOP AT raw_customizing ASSIGNING <raw_customizing_record>.
      TRY.
          CREATE OBJECT exception_validator
            EXPORTING
              i_classname = <raw_customizing_record>-exception_class.
          CHECK exception_validator->is_valid( ) EQ abap_true.
        CATCH /usi/cx_exception.
          CONTINUE.
      ENDTRY.

      CHECK text_getter_validator->is_valid( <raw_customizing_record>-text_getter ) EQ abap_true.

      CLEAR customizing_entry.
      customizing_entry-exception_class_type   = exception_validator->get_class_type( ).
      customizing_entry-exception_class_name   = exception_validator->get_name( ).
      customizing_entry-text_getter_class_name = <raw_customizing_record>-text_getter.
      INSERT customizing_entry INTO TABLE customizing.
    ENDLOOP.

    IF customizing IS INITIAL.
      CLEAR customizing_entry.
      customizing_entry-exception_class_name    = 'CX_ROOT'.
      customizing_entry-text_getter_class_name  = get_fallback_classname( ).
      customizing_entry-exception_class_type    = lcl_exception_validator=>class_type-class.
      INSERT customizing_entry INTO TABLE customizing.
    ENDIF.
  ENDMETHOD.


  METHOD get_instance.
    DATA customizing_dao TYPE REF TO /usi/if_exception_cd_text.

    IF singleton IS NOT BOUND.
      IF i_customizing_dao IS BOUND.
        customizing_dao = i_customizing_dao.
      ELSE.
        CREATE OBJECT customizing_dao TYPE /usi/cl_exception_cd_text.
      ENDIF.

      CREATE OBJECT singleton
        EXPORTING
          i_customizing_dao = customizing_dao.
    ENDIF.

    r_result = singleton.
  ENDMETHOD.


  METHOD get_text_getter_classname_int.
    DATA: customizing_entry      TYPE ty_customizing_entry,
          exception_classname    TYPE /usi/exception_classname,
          superclass_description TYPE REF TO cl_abap_classdescr.

    FIELD-SYMBOLS: <customizing_entry> TYPE ty_customizing_entry,
                   <interface>         TYPE abap_intfdescr.

    " Check customizing for the class itself
    exception_classname = i_exception_class_description->absolute_name.
    READ TABLE  customizing
      ASSIGNING <customizing_entry>
      WITH KEY  exception_class_type = lcl_exception_validator=>class_type-class
                exception_class_name = exception_classname.
    IF sy-subrc EQ 0.
      r_result = <customizing_entry>-text_getter_class_name.
      RETURN.
    ENDIF.

    " Check customizing for non-inherited interfaces
    LOOP AT i_exception_class_description->interfaces ASSIGNING <interface> WHERE is_inherited EQ abap_false.
      READ TABLE  customizing
        ASSIGNING <customizing_entry>
        WITH KEY  exception_class_type = lcl_exception_validator=>class_type-interface
                  exception_class_name = <interface>-name.
      IF sy-subrc EQ 0.
        r_result = <customizing_entry>-text_getter_class_name.
        EXIT.
      ENDIF.
    ENDLOOP.

    " Check superclass
    IF r_result IS INITIAL.
      i_exception_class_description->get_super_class_type(
        RECEIVING
          p_descr_ref           = superclass_description
        EXCEPTIONS
          super_class_not_found = 1
          OTHERS                = 2
      ).
      IF sy-subrc EQ 0.
        r_result = get_text_getter_classname_int( superclass_description ).
      ELSE.
        r_result = get_fallback_classname( ).
      ENDIF.
    ENDIF.

    " Extend customizing to speed up subsequent calls
    customizing_entry-exception_class_type    = lcl_exception_validator=>class_type-class.
    customizing_entry-exception_class_name    = i_exception_class_description->absolute_name.
    customizing_entry-text_getter_class_name  = r_result.
    INSERT customizing_entry INTO TABLE customizing.
  ENDMETHOD.
ENDCLASS.
