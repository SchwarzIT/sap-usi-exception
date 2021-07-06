*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/USI/EXCEPT_TEXT
*   generation date: 16.03.2021 at 11:25:28
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/USI/EXCEPT_TEXT   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
