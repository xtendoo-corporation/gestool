#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS RectificativasProveedoresLineasModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                           	INLINE ::getEmpresaTableName( "RctPrvL" )

   METHOD getExtraWhere()                          	INLINE ( "AND nCtlStk < 2" )

   METHOD getFechaFieldName()                      	INLINE ( "dFecFac" )
   METHOD getHoraFieldName()                       	INLINE ( "tFecFac" )

   METHOD getSerieFieldName()                		INLINE ( "cSerFac" )
   METHOD getNumeroFieldName()               		INLINE ( "nNumFac" )
   METHOD getSufijoFieldName()               		INLINE ( "cSufFac" )

   METHOD getTipoDocumento()              			INLINE ( RCT_PRV )

   METHOD getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

END CLASS

//---------------------------------------------------------------------------//

METHOD getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   local cSql  := "SELECT "                                          + ;
                     "cRef as cCodigoArticulo, "                     + ;
                     "cCodPr1 as cCodigoPrimeraPropiedad, "          + ;
                     "cCodPr2 as cCodigoSegundaPropiedad, "          + ;
                     "cValPr1 as cValorPrimeraPropiedad, "           + ;
                     "cValPr2 as cValorSegundaPropiedad, "           + ;
                     "cLote as cLote, "                              + ;
                     "dFecFac as dFecDoc, "                          + ;
                     "dFecCad as dFecCad "                           + ;
                  "FROM " + ::getTableName() + " "                   + ;
                  "WHERE cRef = " + quoted( cCodigoArticulo ) + " "  + ;
                     "AND dFecCad IS NOT NULL "       

   cSql        += ::getExtraWhere()                                
   cSql        += "AND cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " "
   cSql        += "AND cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " "
   cSql        += "AND cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " "
   cSql        += "AND cValPr2 = " + quoted( cValorSegundaPropiedad ) + " "   
   cSql        += "AND cLote = " + quoted( cLote ) + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//