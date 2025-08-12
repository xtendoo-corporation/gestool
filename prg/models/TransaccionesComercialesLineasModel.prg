#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TransaccionesComercialesLineasModel FROM ADSBaseModel

   DATA cAlmacenFieldName

   METHOD getTableName()                                                         VIRTUAL

   METHOD getExtraWhere()                                                        INLINE ( "AND nCtlStk < 2" )

   METHOD getFechaFieldName()                                                    VIRTUAL
   METHOD getHoraFieldName()                                                     VIRTUAL

   METHOD getSerieFieldName()                                                    VIRTUAL
   METHOD getNumeroFieldName()                                                   VIRTUAL
   METHOD getSufijoFieldName()                                                   VIRTUAL

   METHOD getTipoDocumento()                                                     VIRTUAL

   METHOD getArticuloFieldName()                                                 INLINE ( "cRef" )
   METHOD setAlmacenFieldName()                                                  INLINE ( ::cAlmacenFieldName  := "cAlmLin" )
   METHOD getAlmacenFieldName()                                                  INLINE ( if( Empty( ::cAlmacenFieldName ), "cAlmLin", ::cAlmacenFieldName ) )

   METHOD getBultosFieldName()                                                   INLINE ( "nBultos" )
   METHOD getBultosStatement()

   METHOD getCajasStatement()
   METHOD getCajasFieldName()                                                    INLINE ( "nCanEnt" )

   METHOD getUnidadesFieldName()                                                 INLINE ( "nUniCaja" )

   METHOD getCodigoTercero()                                                     VIRTUAL

   METHOD getLineasAgrupadas()
   
   METHOD getSQLSentenceLineasAgrupadas()

   METHOD getSentenceLinAgrSalidasCompras()

   METHOD getLineasAgrupadasUltimaConsolidacion()

   METHOD getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   

   METHOD getSntTotalUnidadesStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote, lSalida )
      METHOD getSntSalidaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )          INLINE ( ::getSntTotalUnidadesStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote, .t., .f. ) )
      METHOD getSntEntradaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )         INLINE ( ::getSntTotalUnidadesStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote, .f., .f. ) )
      METHOD getSntSalidaComprasStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )   INLINE ( ::getSntTotalUnidadesStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote, .t., .t. ) )

   METHOD getSentenceTotalSalidasCompras()
   
   METHOD totalUnidadesStock()

   METHOD TranslateCodigoTiposVentaToId( cTable )

   METHOD TranslateSATClientesLineasCodigoTiposVentaToId()                                      INLINE ( ::TranslateCodigoTiposVentaToId( "SatCliL" ) )

   METHOD TranslatePresupuestoClientesLineasCodigoTiposVentaToId()                              INLINE ( ::TranslateCodigoTiposVentaToId( "PreCliL" ) )

   METHOD TranslatePedidosClientesLineasCodigoTiposVentaToId()                                  INLINE ( ::TranslateCodigoTiposVentaToId( "PedCliL" ) )

   METHOD TranslateAlbaranesClientesLineasCodigoTiposVentaToId()                                INLINE ( ::TranslateCodigoTiposVentaToId( "AlbCliL" ) )

   METHOD TranslateFacturasClientesLineasCodigoTiposVentaToId()                                 INLINE ( ::TranslateCodigoTiposVentaToId( "FacCliL" ) )

   METHOD TranslateFacturasRectificativasLineasCodigoTiposVentaToId()                           INLINE ( ::TranslateCodigoTiposVentaToId( "FacRecL" ) )

   METHOD getInfoSqlStock( cCodigoArticulo, lSalida )
      METHOD getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )              INLINE ( ::getInfoSqlStock( cCodigoArticulo, cCodigoAlmacen, .t., .f., dFechaHasta ) )
      METHOD getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )             INLINE ( ::getInfoSqlStock( cCodigoArticulo, cCodigoAlmacen, .f., .f., dFechaHasta ) )
      METHOD getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta ) 
      METHOD getInfoSqlStockCombinado( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )           INLINE ( ::getInfoSqlStock( cCodigoArticulo, cCodigoAlmacen, .t., .t., dFechaHasta ) )

   METHOD getTotalUnidadesStatement( lSalida )

   METHOD getTotalBultosStatement( lSalida )

   METHOD getTotalCajasStatement( lSalida )

   METHOD getTotalPdtRecibirStatement()

   METHOD getTotalPdtEntregarStatement()

   METHOD ValidateLinesStock()

END CLASS

//---------------------------------------------------------------------------//

METHOD getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )

   local cSql  := "SELECT "                                                + ;
                     "cRef as cCodArt, "                                   + ;
                     "cAlmLin as cCodAlm, "                                + ;
                     "cCodPr1 as cCodPr1, "                                + ;
                     "cCodPr2 as cCodPr2, "                                + ;
                     "cValPr1 as cValPr1, "                                + ;
                     "cValPr2 as cValPr2, "                                + ;
                     "cLote as cLote "                                     + ;
                  "FROM " + ::getTableName() + " "                         + ;
                  "WHERE cRef = " + quoted( cCodigoArticulo ) + " "


   if !Empty( cCodigoAlmacen )
      cSql     +=    "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
   end if

   cSql        +=    ::getExtraWhere() + " "

   cSql        +=    "GROUP BY cRef, cAlmLin, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote "
  

Return ( cSql )

//---------------------------------------------------------------------------//

METHOD getSentenceLinAgrSalidasCompras( cCodigoArticulo, cCodigoAlmacen )

   local cSql  := "SELECT "                                                + ;
                     "cRef as cCodArt, "                                   + ;
                     "cAlmOrigen as cCodAlm, "                             + ;
                     "cCodPr1 as cCodPr1, "                                + ;
                     "cCodPr2 as cCodPr2, "                                + ;
                     "cValPr1 as cValPr1, "                                + ;
                     "cValPr2 as cValPr2, "                                + ;
                     "cLote as cLote "                                     + ;
                  "FROM " + ::getTableName() + " "                         + ;
                  "WHERE cRef = " + quoted( cCodigoArticulo ) + " "


   if !Empty( cCodigoAlmacen )
      cSql     +=    "AND ( cAlmOrigen = " + quoted( cCodigoAlmacen ) + " AND cAlmLin is not null ) "
   else
      cSql     +=    "AND ( cAlmOrigen is not null AND cAlmLin is not null ) "
   end if

   cSql        +=    ::getExtraWhere() + " "

   cSql        +=    "GROUP BY cRef, cAlmOrigen, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote "
  

Return ( cSql )

//---------------------------------------------------------------------------//

METHOD getLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   local cStm  := "ADSLineasAgrupadas"
   local cSql  := ::getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

Return ( nil )

//---------------------------------------------------------------------------//

METHOD getLineasAgrupadasUltimaConsolidacion( cCodigoArticulo, cCodigoAlmacen, cValorPropiedad1, cValorPropiedad2, cLote, hConsolidacion )

   local cStm  
   local cSql  := "SELECT nBultos, nCanEnt "                                  + ;
                     "FROM " + ::getTableName() + " "                         + ;
                     "WHERE cRef = " + quoted( cCodigoArticulo ) + " "        + ;
                        "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "     + ;
                        "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "   + ;
                        "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "   + ;
                        "AND cLote = " + quoted( cLote )                               

   cSql        +=       ::getExtraWhere() + " "

   if !empty(hConsolidacion)
      cSql     +=       "AND " + ::getFechaFieldName() + " >= " + quoted( hget( hConsolidacion, "fecha" ) ) + " "
      cSql     +=       "AND " + ::getHoraFieldName() + " >= " + quoted( hget( hConsolidacion, "hora" ) ) + " " 
   end if 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

Return ( nil )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   local cSql  := "SELECT SUM( IIF( nBultos = 0, 1, nBultos ) * IIF( nCanEnt = 0, 1, nCanEnt ) * nUniCaja ) as [totalUnidadesStock], " + quoted( ::getTableName() ) + " AS Document " + ;
                     "FROM " + ::getTableName() + " " + ;
                     "WHERE cRef = " + quoted( cCodigoArticulo ) + " "
   
   if !empty( dConsolidacion )                     
      if !empty( tConsolidacion )                     
         cSql  +=    "AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= " + quoted( dateToSQLString( dConsolidacion ) + tConsolidacion ) + " "
      else 
         cSql  +=    "AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) >= " + quoted( dateToSQLString( dConsolidacion ) ) + " "
      end if 
   end if 

   cSql        +=    "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
   cSql        +=    "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   cSql        +=    "AND cCodPr2 = " + quoted( cCodigoPropiedad2 ) + " "
   cSql        +=    "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   cSql        +=    "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   cSql        +=    "AND cLote = " + quoted( cLote ) + " "

   cSql        +=    ::getExtraWhere() + " "

RETURN ( cSql )

//---------------------------------------------------------------------------/

METHOD getSntTotalUnidadesStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote, lSalida, lCompras )

   local cSql        := ""

   DEFAULT lSalida   := .f.
   DEFAULT lCompras  := .f.

   cSql              := "SELECT "

   do case
      case lCalCaj() .and. lCalBul()
         cSql           += "( SUM( IIF( " + ::getBultosFieldName() + " = 0, 1, " + ::getBultosFieldName() + " ) * IIF( " + ::getCajasFieldName() + " = 0, 1, " + ::getCajasFieldName() + " ) * " + ::getUnidadesFieldName() + " ) " + if( lSalida, " * -1 ", "" )  + " ) as [totalUnidadesStock], "

      case lCalCaj() .and. !lCalBul()
         cSql           += "( SUM( IIF( " + ::getCajasFieldName() + " = 0, 1, " + ::getCajasFieldName() + " ) * " + ::getUnidadesFieldName() + " ) " + if( lSalida, " * -1 ", "" )  + " ) as [totalUnidadesStock], "

      case !lCalCaj() .and. lCalBul()
         cSql           += "( SUM( IIF( " + ::getBultosFieldName() + " = 0, 1, " + ::getBultosFieldName() + " ) * " + ::getUnidadesFieldName() + " ) " + if( lSalida, " * -1 ", "" )  + " ) as [totalUnidadesStock], "

      case !lCalCaj() .and. !lCalBul()
         cSql           += "( SUM( " + ::getUnidadesFieldName() + " ) " + if( lSalida, " * -1 ", "" )  + " ) as [totalUnidadesStock], "

    end case

   cSql              += quoted( ::getTableName() ) + " AS Document "
   cSql              += "FROM " + ::getTableName() + " AS cTable "
   cSql              += "WHERE " + ::getArticuloFieldName() + " = " + quoted( cCodigoArticulo ) + " "                     
   
   if lSalida .and. lCompras
      cSql           += "AND ( cAlmOrigen = " + quoted( cCodigoAlmacen ) + " AND " + ::getAlmacenFieldName() + " is not null ) "
   else
      cSql           += "AND " + ::getAlmacenFieldName() + " = " + quoted( cCodigoAlmacen ) + " "
   end if

   cSql              += "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   cSql              += "AND cCodPr2 = " + quoted( cCodigoPropiedad2 ) + " "
   cSql              += "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   cSql              += "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   cSql              += "AND cLote = " + quoted( cLote ) + " "
   cSql              += "AND iif( (" + MovimientosAlmacenLineasModel():getSentenceConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) + ") IS NOT NULL, "
   cSql              += "( CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= (" + MovimientosAlmacenLineasModel():getSentenceConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) + ") ), TRUE ) "

   cSql              += ::getExtraWhere() + " "

RETURN ( cSql )

//---------------------------------------------------------------------------/

METHOD getSentenceTotalSalidasCompras( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   local cSql  := "SELECT SUM( IIF( nBultos = 0, 1, nBultos ) * IIF( nCanEnt = 0, 1, nCanEnt ) * nUniCaja ) as [totalUnidadesStock], " + quoted( ::getTableName() ) + " AS Document " + ;
                     "FROM " + ::getTableName() + " " + ;
                     "WHERE cRef = " + quoted( cCodigoArticulo ) + " "
   
   if !empty( dConsolidacion )                     
      if !empty( tConsolidacion )                     
         cSql  +=    "AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= " + quoted( dateToSQLString( dConsolidacion ) + tConsolidacion ) + " "
      else 
         cSql  +=    "AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) >= " + quoted( dateToSQLString( dConsolidacion ) ) + " "
      end if 
   end if 

   cSql        +=    "AND ( cAlmOrigen = " + quoted( cCodigoAlmacen ) + " AND cAlmLin is not null ) "
   cSql        +=    "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   cSql        +=    "AND cCodPr2 = " + quoted( cCodigoPropiedad2 ) + " "
   cSql        +=    "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   cSql        +=    "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   cSql        +=    "AND cLote = " + quoted( cLote ) + " "

   cSql        +=    ::getExtraWhere() + " "

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

METHOD TranslateCodigoTiposVentaToId( cTable )

   local cSentence
   local hIdTipoVenta
   local aIdTiposVentas    := {}

   RETURN ( Self )

   for each hIdTipoVenta in aIdTiposVentas

      cSentence            := "UPDATE " + ::getEmpresaTableName( cTable )                       + space( 1 ) + ;
                                 "SET id_tipo_v = " + toSqlString( hIdTipoVenta[ "id" ] ) + "," + space( 1 ) + ;
                                    "cTipMov = ''"                                              + space( 1 ) + ;
                                 "WHERE cTipMov = " + toSqlString( hIdTipoVenta[ "codigo" ] )
      
      ADSBaseModel():ExecuteSqlStatement( cSentence )

   next 

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getBultosStatement()

   if Empty( ::getBultosFieldName() )
      Return "1"
   end if

RETURN ( "IIF( " + ::getBultosFieldName() + " = 0, 1, " + ::getBultosFieldName() + " )" )

//---------------------------------------------------------------------------//

METHOD getCajasStatement()

   if Empty( ::getCajasFieldName() )
      Return "1"
   end if

RETURN ( "IIF( " + ::getCajasFieldName() + " = 0, 1, " + ::getCajasFieldName() + " )" )

//---------------------------------------------------------------------------//

METHOD getTotalUnidadesStatement( lSalida )

   local cSql        := ""

   do case
      case lCalCaj() .and. lCalBul()
         cSql         += "( ( " + ::getBultosStatement() + " * " + ::getCajasStatement() + " * " + ::getUnidadesFieldName() + " ) " + if( lSalida, "* - 1", "" ) + " ) as unidades, "

      case lCalCaj() .and. !lCalBul()
         cSql         += "( ( " + ::getCajasStatement() + " * " + ::getUnidadesFieldName() + " ) " + if( lSalida, "* - 1", "" ) + " ) as unidades, "

      case !lCalCaj() .and. lCalBul()
         cSql         += "( ( " + ::getBultosStatement() + " * " + ::getUnidadesFieldName() + " ) " + if( lSalida, "* - 1", "" ) + " ) as unidades, "

      case !lCalCaj() .and. !lCalBul()
         cSql         += "(" + ::getUnidadesFieldName() + " ) " + if( lSalida, "* - 1", "" ) + " as unidades, "

    end case

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getTotalBultosStatement( lSalida )

   local cSql        := ""

   cSql              += "( " + if( !Empty( ::getBultosFieldName() ), ::getBultosFieldName(), "0" ) + " ) " + if( lSalida, "* - 1", "" ) + " as bultos, "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getTotalCajasStatement( lSalida )

   local cSql        := ""

   cSql              += "( " + if( !Empty( ::getCajasFieldName() ), ::getCajasFieldName(), "0" ) + " ) " + if( lSalida, "* - 1", "" ) + " as cajas, "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getTotalPdtRecibirStatement()

   local cSql        := ""

   cSql              += "0 as pdtrecibir, "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getTotalPdtEntregarStatement()

   local cSql        := ""

   cSql              += "0 as pdtentrega, "

RETURN ( cSql )

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

   Logwrite( "Sentencia" )
   Logwrite( cSql )

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

   local cSql        := ""

   /*
   Seleccionamos el almacen, ya que en movimientos de almacen tenemos dos------
   */

   if Empty( ::cAlmacenFieldName )
      ::setAlmacenFieldName()
   end if

   cSql              := "SELECT "
   cSql              += ::getTotalBultosStatement( .t. )
   cSql              += ::getTotalCajasStatement( .t. )
   cSql              += ::getTotalUnidadesStatement( .t. )
   cSql              += ::getTotalPdtRecibirStatement()
   cSql              += ::getTotalPdtEntregarStatement()
   cSql              += quoted( ::getTipoDocumento() ) + " AS Document, "
   cSql              += ::getFechaFieldName() + " AS Fecha, "
   cSql              += ::getHoraFieldName() + " AS Hora, "
   cSql              += ::getSerieFieldName() + " AS Serie, "
   cSql              += "CAST( " + ::getNumeroFieldName() + " AS SQL_INTEGER ) AS Numero, "
   cSql              += ::getSufijoFieldName() + " AS Sufijo, "
   cSql              += "CAST( nNumLin AS SQL_INTEGER ) AS Numero, "
   cSql              += ::getArticuloFieldName() + " AS Articulo, "
   cSql              += "cLote AS Lote, "
   cSql              += "cCodPr1 AS Propiedad1, "
   cSql              += "cCodPr2 AS Propiedad2, "
   cSql              += "cValPr1 AS Valor1, "
   cSql              += "cValPr2 AS Valor2, "
   cSql              += "cAlmOrigen AS Almacen "
   cSql              += "FROM " + ::getTableName() + " TablaLineas "
   cSql              += "WHERE " + ::getArticuloFieldName() + " = " + quoted( cCodigoArticulo ) + " " 

   if !empty( cCodigoAlmacen )
      cSql           += "AND ( cAlmOrigen = " + quoted( cCodigoAlmacen ) + " AND cAlmLin is not null ) "
   else
      cSql           += "AND ( cAlmOrigen is not null AND cAlmLin is not null )"
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

   cSql              += "AND HisMov.cRefMov = TablaLineas." + ::getArticuloFieldName() + " "
   cSql              += "AND HisMov.cAliMov = TablaLineas." + ::getAlmacenFieldName() + " "
   cSql              += "AND HisMov.cLote = TablaLineas.cLote "
   cSql              += "ORDER BY HisMov.dFecMov DESC, HisMov.cTimMov DESC ), "
   cSql              += "'' ) "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD ValidateLinesStock( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion ) CLASS TransaccionesComercialesLineasModel

   local cSql

   if Empty( ::cAlmacenFieldName )
      ::setAlmacenFieldName()
   end if

   cSql  := "UPDATE " + ::getTableName() + Space( 1 )
   cSql  += "SET lValidado = .T. WHERE "
   cSql  += ::getArticuloFieldName() + " = " + quoted( cCodArt ) + " AND "
   cSql  += ::getAlmacenFieldName() + " = " + quoted( cCodAlm ) + " AND "
   cSql  += "cCodPr1 = " + quoted( cCodPr1 ) + " AND "
   cSql  += "cCodPr2 = " + quoted( cCodPr2 ) + " AND "
   cSql  += "cValPr1 = " + quoted( cValPr1 ) + " AND "
   cSql  += "cValPr2 = " + quoted( cValPr2 ) + " AND "
   cSql  += "cLote = " + quoted( cLote ) + " AND "
   cSql  += "( CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " ) < " + quoted( Trans( hb_ttos( dConsolidacion ), "@R 9999-99-99999999" ) )

   ADSBaseModel():ExecuteSqlStatement( cSql )

RETURN ( .t. )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

Function ValidateLinesTransaccionesComercialesLineas( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion )

   /*
   Compras---------------------------------------------------------------------
   */

   AlbaranesProveedoresLineasModel():ValidateLinesStock( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion )
   FacturasProveedoresLineasModel():ValidateLinesStock( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion )
   RectificativasProveedoresLineasModel():ValidateLinesStock( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion )

   /*
   Ventas----------------------------------------------------------------------
   */

   AlbaranesClientesLineasModel():ValidateLinesStock( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion )
   FacturasClientesLineasModel():ValidateLinesStock( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion )
   RectificativasClientesLineasModel():ValidateLinesStock( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion )
   TicketsClientesLineasModel():ValidateLinesStock( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion )

   /*
   Producción----------------------------------------------------------------------
   */

   MaterialesProducidosLineasModel():ValidateLinesStock( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion )
   MaterialesConsumidosLineasModel():ValidateLinesStock( cCodArt, cCodAlm, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, dConsolidacion )

Return( nil )

//---------------------------------------------------------------------------//