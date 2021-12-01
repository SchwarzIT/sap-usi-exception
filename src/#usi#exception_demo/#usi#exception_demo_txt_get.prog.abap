*----------------------------------------------------------------------*
* Title   | DEMO - How to get texts from exceptions                    *
*----------------------------------------------------------------------*
* Purpose | Sometimes texts have to be extracted from exceptions and   *
*         | provided in a specific format.                             *
*         |                                                            *
*         | A typical example would be RFC function modules that use   *
*         | an object-oriented API internally, but return errors to    *
*         | the caller as e.g. a BAPIRET2 table.                       *
*         |                                                            *
*         | Because there are different types of exceptions, the logic *
*         | for extracting the texts differs for the different types,  *
*         | and exceptions can be nested indefinitely deep via the     *
*         | "previous" attribute, this can be a tedious task.          *
*         |                                                            *
*         | That's why we encapsulated this logic in a reusable way.   *
*         |                                                            *
*         | This little demo program shows how to use this feature.    *
*----------------------------------------------------------------------*
REPORT /usi/exception_demo_txt_get.

INCLUDE: /usi/exception_demo_txt_gettop,
         /usi/exception_demo_txt_getp01,
         /usi/exception_demo_txt_getp02.

START-OF-SELECTION.
  /usi/cl_auth=>check_tcode( ).

  CASE abap_true.
    WHEN bapiret2.
      lcl_demo_report=>run_bapiret2_demo( ).

    WHEN symsg.
      lcl_demo_report=>run_symsg_demo( ).

  ENDCASE.
