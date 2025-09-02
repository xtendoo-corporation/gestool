#include 'hbclass.ch'

CREATE CLASS TRestrictionItem

    DATA cOperator AS STRING INIT ''
    DATA cValue AS STRING INIT ''
    DATA aEnumeration AS ARRAY INIT Array( 0 )

ENDCLASS