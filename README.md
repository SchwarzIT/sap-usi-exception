<!-- Links used on this page (Declaration) -->
[CONTRIBUTING]:   ./docs/CONTRIBUTING.md



[![SIT](https://img.shields.io/badge/SIT-About%20us-%236e1e6e)](https://it.schwarz)
[![USI](https://img.shields.io/badge/USI-More%20Software-blue)](https://github.com/SchwarzIT/sap-usi)

# USI Exception
## Purpose
The component offers an extensible text getter API that can be used to convert exception texts into various common formats such as BAPIRET2 or SYMSG.

It additionally contains our root exception class, that will be reused by all USI developments.

## Exception text getter
There are quite some cases, in which you have to convert an exception into a bapiret2 structure or into another well-known message structure. A typical example would be an RFC function, that is using an object oriented API and will return a BAPIRETTAB for error messages. As exceptions might be T100-based or OTR-based and as they can have previous exceptions of different types, converting every relevant exception correctly can be a tedious task.

That's why the logic was encapsulated in one central class.

### How to use the text getter
The text getter /USI/CL_EXCEPTION_TEXT_GETTER is compatible with CX_ROOT and can extract the text of every exception - no matter, if it is a T100-based or an OTR-based exception.

Just create an instance of the class and use the instance methods to get the texts in the desired format.
```ABAP
FUNCTION do_something.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_USER_NAME) TYPE  XUBNAME
*"  EXPORTING
*"     VALUE(E_RETURN)  TYPE BAPIRETTAB
*"----------------------------------------------------------------------
  TRY.
      DATA(user) = zcl_user=>get( i_user_name ).
      " [...]
 
    CATCH zcx_root INTO DATA(exception).
      e_return = NEW /usi/cl_exception_text_getter( exception )->get_texts_as_bapiret2( ).
 
  ENDTRY.
ENDFUNCTION.
```
The get_texts*-methods will return an internal table containing the text of the passed exception and its previous exceptions.

The get_text*-methods will return the text of the passed exception. Previous exceptions will be ignored. The result type will be the line type of the corresponding get_texts*-method.

### Extensibility
The text getter can handle OTR-based and T100-based exceptions, which should be enough for most cases. If you should ever have to deal with an exception, that can not be handled by the default implementations, you can enhance the solution by additional text extractors.

#### Creating a new text extractor
The class definition of a new text extractor should look like this:
```ABAP
CLASS zcl_my_text_extractor DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES: /usi/if_exception_text.
 
    METHODS constructor
      IMPORTING
        !i_exception TYPE REF TO cx_root.
 
  PRIVATE SECTION.
    DATA: exception_text TYPE symsg.
 
ENDCLASS.
```

The implementation part should look like this:
```ABAP
CLASS zcl_my_text_extractor IMPLEMENTATION.
  METHOD constructor.
    " It is recommended to fill a private attribute (e.g. exception_text)
    " here and to make get_text_as_symsg return that private attribute.
    "
    " This avoids extracting the text multiple times if somebody should
    " call get_text_as_symsg( ) more than once.
  ENDMETHOD.
 
  METHOD /usi/if_exception_text~get_text_as_symsg.
    r_result = exception_text.
  ENDMETHOD.
ENDCLASS.
```
**IMPORTANT**: The instance creation must be public and the declaration of the constructor must look **exactly** like in the example. Otherwise the class will be ignored!

#### Customizing
The text extractors need to be maintained in table /USI/EXCEPT_TEXT via SM30.

When searching for the most appropriate text extractor class, the customizing will be evaluated, as follows:
1. A dedicated entry for the exception class to be processed has the highest priority
2. Entries for non-inherited interfaces have the second highest priority (if your exception class inherits from CX_STATIC_CHECK and implements IF_T100_MESSAGE, then the new interface would be more important than the superclass)
3. If number 1 and 2 do not apply, the text extractor will be inherited from the superclass
4. Invalid text extractors will be ignored (Entering CL_GUI_ALV_GRID as a text getter will have no effect)

## USI Root Exception
As per an internal policy, all USI exceptions must inherit from the common root class /USI/CX_EXCEPTION. The class itself is not too interesting - it's just a technical dependency that you will need to make our code work.

## Installation Guide
This component has no dependencies and no special authorizations are required.

## How to contribute
Please check our [contribution guidelines][CONTRIBUTING] to learn more about this topic.
