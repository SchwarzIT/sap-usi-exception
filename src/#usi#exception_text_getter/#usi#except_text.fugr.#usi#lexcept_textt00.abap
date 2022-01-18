*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /USI/EXCEPT_TEXT................................*
DATA:  BEGIN OF STATUS_/USI/EXCEPT_TEXT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/USI/EXCEPT_TEXT              .
CONTROLS: TCTRL_/USI/EXCEPT_TEXT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */USI/EXCEPT_TEXT              .
TABLES: /USI/EXCEPT_TEXT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
