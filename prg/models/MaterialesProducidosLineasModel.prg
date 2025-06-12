#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS MaterialesProducidosLineasModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "ProLin" )

   METHOD getExtraWhere()                    INLINE ( "" )
   METHOD getFechaFieldName()                INLINE ( "dFecOrd" )
   METHOD getHoraFieldName()                 INLINE ( "cHorIni" )
   METHOD getArticuloFieldName()             INLINE ( "cCodArt" )
   METHOD setAlmacenFieldName()              INLINE ( ::cAlmacenFieldName  := "cAlmOrd" )
   METHOD getAlmacenFieldName()              INLINE ( "cAlmOrd" )
   METHOD getCajasFieldName()                INLINE ( "nCajOrd" )
   METHOD getUnidadesFieldName()             INLINE ( "nUndOrd" )

   METHOD getSerieFieldName()                INLINE ( "cSerOrd" )
   METHOD getNumeroFieldName()               INLINE ( "nNumOrd" )
   METHOD getSufijoFieldName()               INLINE ( "cSufOrd" )

   METHOD getTipoDocumento()                 INLINE ( PRO_LIN )

   METHOD getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   METHOD getLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   METHOD getLineasAgrupadasUltimaConsolidacion( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote, dConsolidacion )

   METHOD getSQLSentenceTotalUnidadesStock( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   METHOD totalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   METHOD getSQLSentenceFechaCaducidad( cCodigoArticulo, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   METHOD getCosto( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   METHOD getFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

END CLASS

//---------------------------------------------------------------------------//

METHOD getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )

   local cSql  := "SELECT "                                                + ;
                     "cCodArt as cCodArt, "                                + ;
                     "cAlmOrd as cCodAlm, "                                + ;
                     "cCodPr1 as cCodPr1, "                                + ;
                     "cCodPr2 as cCodPr2, "                                + ;
                     "cValPr1 as cValPr1, "                                + ;
                     "cValPr2 as cValPr2, "                                + ;
                     "cLote as cLote "                                     + ;
                  "FROM " + ::getTableName() + " "                         + ;
                  "WHERE cCodArt = " + quoted( cCodigoArticulo ) + " "

   if !Empty( cCodigoAlmacen )
      cSql     +=  "AND cAlmOrd = " + quoted( cCodigoAlmacen ) + " "
   end if

   cSql        +=    "GROUP BY cCodArt, cAlmOrd, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote "

Return ( cSql )

//---------------------------------------------------------------------------//

METHOD getLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   local cStm  := "ADSLineasAgrupadas"
   local cSql  := ::getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getLineasAgrupadasUltimaConsolidacion( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote, hConsolidacion )

   local cStm  
   local cSql  := "SELECT nCanEnt "                                     + ;
                  "  FROM " + ::getTableName()                          + ;
                  "  WHERE cCodArt = " + quoted( cCodigoArticulo )      + ;
                        " AND cAlmOrd = " + quoted( cCodigoAlmacen )    + ;
                        " AND cValPr1 = " + quoted( cValorPropiedad1 )  + ;
                        " AND cValPr2 = " + quoted( cValorPropiedad2 )  + ;
                        " AND cLote = " + quoted( cLote )                              

   if !empty(hConsolidacion)
      cSql     +=       " AND dFecOrd >= " + quoted( hget( hConsolidacion, "fecha" ) )
      cSql     +=       " AND cHorIni >= " + quoted( hget( hConsolidacion, "hora" ) )
   end if 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   local cSql  := "SELECT SUM( IIF( nCajOrd = 0, 1, nCajOrd ) * nUndOrd ) as [totalUnidadesStock] , " + quoted( ::getTableName() ) + " AS Document " + ;
                     "FROM " + ::getTableName() + " "                                                 + ;
                     "WHERE cCodArt = " + quoted( cCodigoArticulo ) + " "
   
   if !empty( dConsolidacion )                     
      if !empty( tConsolidacion )                     
         cSql  +=    "AND CAST( dFecOrd AS SQL_CHAR ) + cHorIni >= " + quoted( dateToSQLString( dConsolidacion ) + tConsolidacion ) + " "
      else
         cSql  +=    "AND CAST( dFecOrd AS SQL_CHAR ) >= " + quoted( dateToSQLString( dConsolidacion ) ) + " "
      end if 
   end if 

   cSql  +=    "AND cAlmOrd = " + quoted( cCodigoAlmacen ) + " "
   cSql  +=    "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   cSql  +=    "AND cCodPr2 = " + quoted( cCodigoPropiedad2 ) + " "
   cSql  +=    "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   cSql  +=    "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   cSql  +=    "AND cLote = " + quoted( cLote ) + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD totalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   local cStm
   local cSql  := ::getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->totalUnidadesStock )
   end if 

RETURN ( 0 )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   local cSql  := "SELECT "                                             + ;
                     "cCodArt as cCodigoArticulo, "                     + ;
                     "cCodPr1 as cCodigoPrimeraPropiedad, "             + ;
                     "cCodPr2 as cCodigoSegundaPropiedad, "             + ;
                     "cValPr1 as cValorPrimeraPropiedad, "              + ;
                     "cValPr2 as cValorSegundaPropiedad, "              + ;
                     "cLote as cLote, "                                 + ;
                     "dFecOrd as dFecDoc, "                             + ;
                     "dFecCad as dFecCad "                              + ;
                  "FROM " + ::getTableName() + " "                      + ;
                  "WHERE cCodArt = " + quoted( cCodigoArticulo ) + " "  + ;
                     "AND dFecCad IS NOT NULL "       

   cSql        += "AND cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " "
   cSql        += "AND cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " "
   cSql        += "AND cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " "
   cSql        += "AND cValPr2 = " + quoted( cValorSegundaPropiedad ) + " "   
   cSql        += "AND cLote = " + quoted( cLote ) + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getCosto( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote ) CLASS MaterialesProducidosLineasModel

   local cStm
   local cSql  := "SELECT TOP 1 "                                                + ;
                     "nImpOrd as nCosto "                                        + ;
                  "FROM " + ::getTableName() + " "                               + ;
                  "WHERE cCodArt = " + quoted( cCodigoArticulo ) + " "

   if !empty( cCodigoPrimeraPropiedad )
      cSql     += "AND cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " "
   end if 

   if !empty( cValorPrimeraPropiedad )
      cSql     += "AND cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " "   
   end if

   if !empty( cCodigoSegundaPropiedad )
      cSql     += "AND cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " "   
   end if 

   if !empty( cValorSegundaPropiedad )
      cSql     += "AND cValPr2 = " + quoted( cValorSegundaPropiedad ) + " "   
   end if 

   cSql        += "AND cLote = " + quoted( cLote ) + " "

   cSql        += "ORDER BY dFecOrd DESC , cHorIni DESC"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->nCosto )
   end if

RETURN ( 0 )

//---------------------------------------------------------------------------//

METHOD getFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote ) CLASS MaterialesProducidosLineasModel

   local nVal  := cTod( "" )
   local cStm
   local cSql  := "SELECT TOP 1 "                                                + ;
                     "dFecCad "                                                  + ;
                  "FROM " + ::getTableName() + " "                               + ;
                  "WHERE lLote AND cCodArt = " + quoted( cCodigoArticulo ) + " "
      cSql     +=    "AND cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " "   
      cSql     +=    "AND cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " "   
      cSql     +=    "AND cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " "   
      cSql     +=    "AND cValPr2 = " + quoted( cValorSegundaPropiedad ) + " "   
      cSql     +=    "AND cLote = " + quoted( cLote ) + " "
      cSql     +=    "ORDER BY dFecOrd DESC"

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )
      nVal     := ( ( cStm )->dFecCad )
   end if

RETURN ( nVal )

//---------------------------------------------------------------------------//