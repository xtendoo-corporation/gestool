#include 'hbclass.ch'

CREATE CLASS TData

    DATA cName AS STRING INIT ''
    DATA cType AS STRING INIT ''
    DATA nminOccurs AS INTEGER INIT 0
    DATA nmaxOccurs AS INTEGER INIT 0
    DATA lRequired AS LOGICAL INIT .T.
    DATA lComplex AS LOGICAL INIT .F.
    DATA lSimple AS LOGICAL INIT .F.
    DATA oRestriction AS OBJECT INIT Nil

ENDCLASS