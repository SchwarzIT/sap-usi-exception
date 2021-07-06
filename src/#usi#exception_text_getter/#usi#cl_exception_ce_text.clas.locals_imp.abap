*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

*--------------------------------------------------------------------*
* RTTI-Helper class
*--------------------------------------------------------------------*
CLASS lcl_rtti_helper DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS get_object_description
      IMPORTING
        i_classname     TYPE seoclsname
      RETURNING
        VALUE(r_result) TYPE REF TO cl_abap_objectdescr
      RAISING
        /usi/cx_exception.

    CLASS-METHODS get_class_description
      IMPORTING
        i_classname     TYPE seoclsname
      RETURNING
        VALUE(r_result) TYPE REF TO cl_abap_classdescr
      RAISING
        /usi/cx_exception.

  PRIVATE SECTION.
    CLASS-METHODS get_type_description
      IMPORTING
        i_type_name     TYPE csequence
      RETURNING
        VALUE(r_result) TYPE REF TO cl_abap_typedescr
      RAISING
        /usi/cx_exception.
ENDCLASS.

CLASS lcl_rtti_helper IMPLEMENTATION.
  METHOD get_object_description.
    TRY.
        r_result ?= get_type_description( i_classname ).
      CATCH cx_sy_move_cast_error.
        RAISE EXCEPTION TYPE /usi/cx_exception.
    ENDTRY.
  ENDMETHOD.

  METHOD get_class_description.
    TRY.
        r_result ?= get_type_description( i_classname ).
      CATCH cx_sy_move_cast_error.
        RAISE EXCEPTION TYPE /usi/cx_exception.
    ENDTRY.
  ENDMETHOD.

  METHOD get_type_description.
    cl_abap_typedescr=>describe_by_name(
      EXPORTING
        p_name         = i_type_name
      RECEIVING
        p_descr_ref    = r_result
      EXCEPTIONS
        OTHERS         = 1
    ).
    IF sy-subrc NE 0 OR
       r_result IS NOT BOUND.
      RAISE EXCEPTION TYPE /usi/cx_exception.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

*--------------------------------------------------------------------*
* Validator for text getter plugins
*--------------------------------------------------------------------*
CLASS lcl_text_getter_validator DEFINITION FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING
        VALUE(r_result) TYPE REF TO lcl_text_getter_validator.

    METHODS is_valid
      IMPORTING
        i_classname     TYPE /usi/exception_text_getter
      RETURNING
        VALUE(r_result) TYPE abap_bool.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_buffer_line,
             classname TYPE /usi/exception_text_getter,
             valid     TYPE abap_bool,
           END    OF ty_buffer_line,
           ty_buffer TYPE HASHED TABLE OF ty_buffer_line WITH UNIQUE KEY classname.

    CLASS-DATA singleton TYPE REF TO lcl_text_getter_validator.
    DATA buffer TYPE ty_buffer.

    METHODS is_classname_valid
      IMPORTING
        i_classname     TYPE /usi/exception_text_getter
      RETURNING
        VALUE(r_result) TYPE abap_bool.

    METHODS implements_text_getter_intf
      IMPORTING
        i_class_description TYPE REF TO cl_abap_classdescr
      RETURNING
        VALUE(r_result)     TYPE abap_bool.

    METHODS has_supported_constructor
      IMPORTING
        i_class_description TYPE REF TO cl_abap_classdescr
      RETURNING
        VALUE(r_result)     TYPE abap_bool.

ENDCLASS.

CLASS lcl_text_getter_validator IMPLEMENTATION.
  METHOD get_instance.
    IF singleton IS NOT BOUND.
      CREATE OBJECT singleton.
    ENDIF.
    r_result = singleton.
  ENDMETHOD.

  METHOD is_valid.
    DATA buffer_line       TYPE REF TO ty_buffer_line.

    READ TABLE buffer
      REFERENCE INTO buffer_line
      WITH TABLE KEY classname = i_classname.
    IF sy-subrc NE 0.
      CREATE DATA buffer_line.
      buffer_line->classname = i_classname.
      buffer_line->valid     = is_classname_valid( i_classname ).
      INSERT buffer_line->* INTO TABLE buffer.
    ENDIF.

    r_result = buffer_line->valid.
  ENDMETHOD.

  METHOD is_classname_valid.
    DATA class_description TYPE REF TO cl_abap_classdescr.

    TRY.
        class_description = lcl_rtti_helper=>get_class_description( i_classname ).
        IF class_description->is_instantiatable( ) EQ abap_true AND
           implements_text_getter_intf( class_description ) EQ abap_true AND
           has_supported_constructor( class_description ) EQ abap_true.
          r_result = abap_true.
        ENDIF.
      CATCH /usi/cx_exception.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD implements_text_getter_intf.
    CONSTANTS: text_getter_interface TYPE abap_intfname VALUE '/USI/IF_EXCEPTION_TEXT'.

    READ TABLE i_class_description->interfaces
      TRANSPORTING NO FIELDS
      WITH KEY name = text_getter_interface.
    IF sy-subrc EQ 0.
      r_result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD has_supported_constructor.
    CONSTANTS: BEGIN OF needed,
                 method    TYPE abap_methname VALUE 'CONSTRUCTOR',
                 parameter TYPE abap_parmname VALUE 'I_EXCEPTION',
                 type      TYPE seoclsname    VALUE 'CX_ROOT',
               END OF needed.

    DATA: BEGIN OF parameter_description,
            data  TYPE REF TO cl_abap_datadescr,
            ref   TYPE REF TO cl_abap_refdescr,
            class TYPE REF TO cl_abap_classdescr,
          END   OF parameter_description.

    FIELD-SYMBOLS: <method_description> TYPE abap_methdescr.

    " Constructor must have one parameter
    READ TABLE  i_class_description->methods
      ASSIGNING <method_description>
      WITH KEY  name       = needed-method
                visibility = cl_abap_classdescr=>public.
    IF sy-subrc NE 0 OR
       lines( <method_description>-parameters ) NE 1.
      RETURN.
    ENDIF.

    " Parameter must be importing and named I_EXCEPTION
    READ TABLE <method_description>-parameters
      TRANSPORTING NO FIELDS
      WITH KEY parm_kind    = cl_abap_classdescr=>importing
               name         = needed-parameter
               is_optional  = abap_false.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    " Parameter must be TYPE REF TO cx_root
    i_class_description->get_method_parameter_type(
      EXPORTING
        p_method_name       = needed-method
        p_parameter_name    = needed-parameter
      RECEIVING
        p_descr_ref         = parameter_description-data
      EXCEPTIONS
        parameter_not_found = 1
        method_not_found    = 2
        OTHERS              = 3
    ).
    IF sy-subrc NE 0 OR
       parameter_description-data IS NOT BOUND.
      RETURN.
    ELSE.
      TRY.
          parameter_description-ref   ?= parameter_description-data.
          parameter_description-class ?= parameter_description-ref->get_referenced_type( ).

          IF parameter_description-class->get_relative_name( ) EQ needed-type.
            r_result = abap_true.
          ENDIF.
        CATCH cx_sy_move_cast_error.
          RETURN.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

*--------------------------------------------------------------------*
* Validator for exception class names
*--------------------------------------------------------------------*
CLASS lcl_exception_validator DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF class_type,
        class     TYPE seoclstype VALUE 0,
        interface TYPE seoclstype VALUE 1,
      END   OF class_type .

    METHODS constructor
      IMPORTING
        i_classname TYPE /usi/exception_classname
      RAISING
        /usi/cx_exception.

    METHODS get_class_type
      RETURNING
        VALUE(r_result) TYPE seoclstype.

    METHODS is_valid
      RETURNING
        VALUE(r_result) TYPE abap_bool.

    METHODS get_name
      RETURNING
        VALUE(r_result) TYPE abap_abstypename.

  PRIVATE SECTION.
    DATA: classname          TYPE /usi/exception_classname,
          object_description TYPE REF TO cl_abap_objectdescr.

ENDCLASS.

CLASS lcl_exception_validator IMPLEMENTATION.
  METHOD constructor.
    classname          = i_classname.
    object_description = lcl_rtti_helper=>get_object_description( classname ).
  ENDMETHOD.

  METHOD get_class_type.
    IF object_description->type_kind EQ cl_abap_typedescr=>typekind_class.
      r_result = class_type-class.
    ELSE.
      r_result = class_type-interface.
    ENDIF.
  ENDMETHOD.

  METHOD is_valid.
    DATA: cx_root_description TYPE REF TO cl_abap_classdescr.

    IF object_description->type_kind EQ cl_abap_typedescr=>typekind_class.
      " Class => Must inherit from CX_ROOT!
      TRY.
          cx_root_description = lcl_rtti_helper=>get_class_description( 'CX_ROOT' ).
          IF cx_root_description->applies_to_class( classname ) EQ abap_true.
            r_result = abap_true.
          ENDIF.
        CATCH /usi/cx_exception.
          RETURN. " Can never happen
      ENDTRY.

    ELSE.
      " Interface => OK!
      r_result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_name.
    IF get_class_type( ) EQ class_type-class.
      r_result = object_description->absolute_name.
    ELSE.
      r_result = object_description->get_relative_name( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
