#include 'hbclass.ch'
CREATE CLASS TClase

    EXPORTED:

        DATA lMadre AS LOGIC INIT .F.
        DATA cName AS CHARACTER INIT ''
        DATA cClassName AS STRING INIT ''
        DATA aDatas AS ARRAY INIT Array(0)
        DATA aChoices AS ARRAY INIT Array(0)
        DATA cDescription AS STRING INIT ''
        DATA nMinOccurs AS NUMERIC INIT 0

ENDCLASS