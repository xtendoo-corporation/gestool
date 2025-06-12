#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS RectificativasClientesLineasModel   FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                  INLINE ::getEmpresaTableName( "FacRecL" )

   METHOD getExtraWhere()                 INLINE ( "AND nCtlStk < 2" )

   METHOD getFechaFieldName()             INLINE ( "dFecFac" )
   METHOD getHoraFieldName()              INLINE ( "tFecFac" )

   METHOD getSerieFieldName()             INLINE ( "cSerie" )
   METHOD getNumeroFieldName()            INLINE ( "nNumFac" )
   METHOD getSufijoFieldName()            INLINE ( "cSufFac" )

   METHOD getTipoDocumento()              INLINE ( FAC_REC )

END CLASS

//---------------------------------------------------------------------------//

