#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TicketsClientesLineasModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                  INLINE ::getEmpresaTableName( "TikeL" )

   METHOD getExtraWhere()                 INLINE ( "AND nCtlStk < 2" )

   METHOD getFechaFieldName()             INLINE ( "dFecTik" )
   METHOD getHoraFieldName()              INLINE ( "tFecTik" )
   METHOD getArticuloFieldName( lComb )   INLINE ( if( !lComb, "cCbaTil", "cComTil" ) )
   METHOD setAlmacenFieldName()           INLINE ( ::cAlmacenFieldName  := "cAlmLin" )
   METHOD getCajasFieldName()             INLINE ( "" )
   METHOD getBultosFieldName()            INLINE ( "" )
   METHOD getUnidadesFieldName()          INLINE ( "nUntTil" )

   METHOD getSerieFieldName()             INLINE ( "cSerTil" )
   METHOD getNumeroFieldName()            INLINE ( "CAST( cNumTil AS SQL_NUMERIC )" )
   METHOD getSufijoFieldName()            INLINE ( "cSufTil" )

   METHOD getTipoDocumento()              INLINE ( TIK_CLI )

   METHOD getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )

   METHOD getSQLSentenceCombAgrupadas( cCodigoArticulo, cCodigoAlmacen )

   METHOD getLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   METHOD getLineasAgrupadasUltimaConsolidacion( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote, dConsolidacion )

   METHOD getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   METHOD getSQLSentenceTotalUnidadesComb( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   METHOD getSntTotalUnidadesStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote, lSalida )
   METHOD getSntTotalUnidadesComb( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote, lSalida )

   METHOD totalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   METHOD getInfoSqlStock( cCodigoArticulo, cCodigoAlmacen, lSalida, lComb, dFechaHasta )

   METHOD updateDelete( cuuid )

   METHOD recuperar( cUuid )

   METHOD getToOdoo( cArea )

END CLASS

//---------------------------------------------------------------------------//

METHOD getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )

   local cSql  := "SELECT "                                                + ;
                     "cCbaTil as cCodArt, "                                + ;
                     "cAlmLin as cCodAlm, "                                + ;
                     "cCodPr1 as cCodPr1, "                                + ;
                     "cCodPr2 as cCodPr2, "                                + ;
                     "cValPr1 as cValPr1, "                                + ;
                     "cValPr2 as cValPr2, "                                + ;
                     "cLote as cLote "                                     + ;
                  "FROM " + ::getTableName() + " "                         + ;
                  "WHERE nCtlStk < 2 AND lDelete = .f. "                   + ;
                     "AND cCbaTil = " + quoted( cCodigoArticulo ) + " "

   if !Empty( cCodigoAlmacen )
      cSql     += "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
   end if

   cSql        += "GROUP BY cCbaTil, cAlmLin, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote "

Return ( cSql )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceCombAgrupadas( cCodigoArticulo, cCodigoAlmacen )

   local cSql  := "SELECT "                                                + ;
                     "cComTil as cCodArt, "                                + ;
                     "cAlmLin as cCodAlm, "                                + ;
                     "cCodPr1 as cCodPr1, "                                + ;
                     "cCodPr2 as cCodPr2, "                                + ;
                     "cValPr1 as cValPr1, "                                + ;
                     "cValPr2 as cValPr2, "                                + ;
                     "cLote as cLote "                                     + ;
                  "FROM " + ::getTableName() + " "                         + ;
                  "WHERE nCtlStk < 2 AND lDelete = .f."                    + ;
                     "AND cComTil = " + quoted( cCodigoArticulo ) + " "

   if !Empty( cCodigoAlmacen )
      cSql     +=  "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
   end if

   cSql        +=    "GROUP BY cComTil, cAlmLin, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote "

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
                  "  WHERE nCtlStk < 2 AND lDelete = .f."               + ;
                        " AND cCbaTil = " + quoted( cCodigoArticulo )   + ;
                        " AND cAlmLin = " + quoted( cCodigoAlmacen )    + ;
                        " AND cValPr1 = " + quoted( cValorPropiedad1 )  + ;
                        " AND cValPr2 = " + quoted( cValorPropiedad2 )  + ;
                        " AND cLote = " + quoted( cLote )                              

   if !empty(hConsolidacion)
      cSql     +=       " AND dFecFac >= " + quoted( hget( hConsolidacion, "fecha" ) )
      cSql     +=       " AND tFecFac >= " + quoted( hget( hConsolidacion, "hora" ) )
   end if 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   local cSql  := "SELECT SUM( nUntTil ) as [totalUnidadesStock] , " + quoted( ::getTableName() ) + " AS Document "  + ;
                     "FROM " + ::getTableName() + " "                                                                + ;
                     "WHERE lDelete = .f. AND cCbaTil = " + quoted( cCodigoArticulo ) + " "
   
   if !empty( dConsolidacion )                     
      if !empty( tConsolidacion )                     
         cSql  +=    "AND CAST( dFecTik AS SQL_CHAR ) + tFecTik >= " + quoted( dateToSQLString( dConsolidacion ) + tConsolidacion ) + " "
      else
         cSql  +=    "AND CAST( dFecTik AS SQL_CHAR ) >= " + quoted( dateToSQLString( dConsolidacion ) ) + " "
      end if 
   end if 

   cSql        +=    "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
   cSql        +=    "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   cSql        +=    "AND cCodPr2 = " + quoted( cCodigoPropiedad2 ) + " "
   cSql        +=    "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   cSql        +=    "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   cSql        +=    "AND cLote = " + quoted( cLote ) + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceTotalUnidadesComb( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   local cSql  := "SELECT SUM( nUntTil ) as [totalUnidadesStock] , " + quoted( ::getTableName() ) + " AS Document "  + ;
                     "FROM " + ::getTableName() + " "                                                                + ;
                     "WHERE lDelete = .f. AND cComTil = " + quoted( cCodigoArticulo ) + " "
   
   if !empty( dConsolidacion )                     
      if !empty( tConsolidacion )                     
         cSql  +=    "AND CAST( dFecTik AS SQL_CHAR ) + tFecTik >= " + quoted( dateToSQLString( dConsolidacion ) + tConsolidacion ) + " "
      else
         cSql  +=    "AND CAST( dFecTik AS SQL_CHAR ) >= " + quoted( dateToSQLString( dConsolidacion ) ) + " "
      end if 
   end if 

   cSql        +=    "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
   cSql        +=    "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   cSql        +=    "AND cCodPr2 = " + quoted( cCodigoPropiedad2 ) + " "
   cSql        +=    "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   cSql        +=    "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   cSql        +=    "AND cLote = " + quoted( cLote ) + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getSntTotalUnidadesStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote, lSalida )

   local cSql        := ""

   DEFAULT lSalida   := .f.

   cSql              := "SELECT "
   cSql              += "( SUM( nUntTil ) " + if( lSalida, " * -1 ", "" )  + " ) as [totalUnidadesStock], "
   cSql              += quoted( ::getTableName() ) + " AS Document "
   cSql              += "FROM " + ::getTableName() + " AS cTable "
   cSql              += "WHERE lDelete = .f. AND  cCbaTil = " + quoted( cCodigoArticulo ) + " "                     
   cSql              += "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
   cSql              += "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   cSql              += "AND cCodPr2 = " + quoted( cCodigoPropiedad2 ) + " "
   cSql              += "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   cSql              += "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   cSql              += "AND cLote = " + quoted( cLote ) + " "
   cSql              += "AND iif( (" + MovimientosAlmacenLineasModel():getSentenceConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) + ") IS NOT NULL, "
   cSql              += "( CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= (" + MovimientosAlmacenLineasModel():getSentenceConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) + ") ), TRUE )"
   cSql              += ::getExtraWhere() + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getSntTotalUnidadesComb( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   local cSql        := ""

   cSql              := "SELECT "
   cSql              += "( SUM( nUntTil ) * -1 ) as [totalUnidadesStock], "
   cSql              += quoted( ::getTableName() ) + " AS Document "
   cSql              += "FROM " + ::getTableName() + " AS cTable "
   cSql              += "WHERE lDelete = .f. AND cComTil = " + quoted( cCodigoArticulo ) + " "                     
   cSql              += "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
   cSql              += "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   cSql              += "AND cCodPr2 = " + quoted( cCodigoPropiedad2 ) + " "
   cSql              += "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   cSql              += "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   cSql              += "AND cLote = " + quoted( cLote ) + " "
   cSql              += "AND iif( (" + MovimientosAlmacenLineasModel():getSentenceConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) + ") IS NOT NULL, "
   cSql              += "( CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= (" + MovimientosAlmacenLineasModel():getSentenceConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) + ") ), TRUE )"
   cSql              += ::getExtraWhere() + " "

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

METHOD getInfoSqlStock( cCodigoArticulo, cCodigoAlmacen, lSalida, lComb, dFechaHasta )

   local cSql        := ""

   DEFAULT lSalida   := .f.
   DEFAULT lComb     := .f.

   /*
   Seleccionamos el almacen, ya que en movimientos de almacen tenemos dos------
   */

   if Empty( ::cAlmacenFieldName )
      ::setAlmacenFieldName()
   end if

   cSql              := "SELECT "
   cSql              += ::getTotalBultosStatement( lSalida )
   cSql              += ::getTotalCajasStatement( lSalida )
   cSql              += ::getTotalUnidadesStatement( lSalida )
   cSql              += ::getTotalPdtRecibirStatement()
   cSql              += ::getTotalPdtEntregarStatement()
   cSql              += quoted( ::getTipoDocumento() ) + " AS Document, "
   cSql              += ::getFechaFieldName() + " AS Fecha, "
   cSql              += ::getHoraFieldName() + " AS Hora, "
   cSql              += ::getSerieFieldName() + " AS Serie, "
   cSql              += "CAST( " + ::getNumeroFieldName() + " AS SQL_INTEGER ) AS Numero, "
   cSql              += ::getSufijoFieldName() + " AS Sufijo, "
   cSql              += "CAST( nNumLin AS SQL_INTEGER ) AS nNumLin, "
   cSql              += ::getArticuloFieldName( lComb ) + " AS Articulo, "
   cSql              += "cLote AS Lote, "
   cSql              += "cCodPr1 AS Propiedad1, "
   cSql              += "cCodPr2 AS Propiedad2, "
   cSql              += "cValPr1 AS Valor1, "
   cSql              += "cValPr2 AS Valor2, "
   cSql              += ::getAlmacenFieldName() + " AS Almacen "
   cSql              += "FROM " + ::getTableName() + " TablaLineas "
   cSql              += "WHERE " + ::getArticuloFieldName( lComb ) + " = " + quoted( cCodigoArticulo ) + " " 
   cSql              += "AND lDelete = .f. "

   if !empty( cCodigoAlmacen )
      cSql           += "AND "+ ::getAlmacenFieldName() + " = " + quoted( cCodigoAlmacen ) + " "
   end if

   if hb_isdate( dFechaHasta )
      cSql           += "AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) <= " + formatoFechaSql( dFechaHasta ) + " "
   end if

   if !Empty( ::getExtraWhere() )
      cSql           += ::getExtraWhere() + " "
   end if

   /*
   Comprobamos la fecha con la fecha de consolidación--------------------------
   */

   cSql              += "AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= " 
   cSql              += "COALESCE( "
   cSql              += "( SELECT TOP 1 CAST( HisMov.dFecMov AS SQL_CHAR ) + HisMov.cTimMov "
   cSql              += "FROM " + ::getEmpresaTableName( "HisMov" ) + " HisMov "
   cSql              += "WHERE HisMov.nTipMov = 4 "

   if hb_isdate( dFechaHasta )
   cSql              += "AND CAST( HisMov.dFecMov AS SQL_CHAR ) <= " + formatoFechaSql( dFechaHasta ) + " "
   end if

   cSql              += "AND HisMov.cRefMov = TablaLineas." + ::getArticuloFieldName( lComb ) + " "
   cSql              += "AND HisMov.cAliMov = TablaLineas." + ::getAlmacenFieldName() + " "
   cSql              += "AND HisMov.cLote = TablaLineas.cLote "
   cSql              += "ORDER BY HisMov.dFecMov DESC, HisMov.cTimMov DESC ), "
   cSql              += "'' ) "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD updateDelete( cuuid ) CLASS TicketsClientesLineasModel

   local cStm  := "UpdateDeleteLineas"
   local cSql  := "UPDATE " + ::getTableName() + ;
                     " SET lDelete = .t." + ;
                     " WHERE paruuid = '" + cuuid + "'"

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD recuperar( cUuid ) CLASS TicketsClientesLineasModel

   local cStm  := "recuperarLineas"
   local cSql  := "UPDATE " + ::getTableName() + ;
                     " SET lDelete = .f." + ;
                     " WHERE paruuid = '" + cUuid + "'"

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS TicketsClientesLineasModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//