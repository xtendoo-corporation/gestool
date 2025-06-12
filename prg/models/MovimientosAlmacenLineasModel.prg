#include "fivewin.ch"
#include "factu.ch" 

//---------------------------------------------------------------------------//

CLASS MovimientosAlmacenLineasModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                     	 	 INLINE ::getEmpresaTableName( "HisMov" )

   METHOD updateGUID()

   METHOD getExtraWhere()                           INLINE ( " " )

   METHOD getFechaFieldName()                       INLINE ( "dFecMov" )
   METHOD getHoraFieldName()                        INLINE ( "cTimMov" )

   METHOD getSerieFieldName()                       INLINE ( "''" )
   METHOD getNumeroFieldName()                      INLINE ( "nNumRem" )
   METHOD getSufijoFieldName()                      INLINE ( "cSufRem" )

   METHOD getArticuloFieldName()                    INLINE ( "cRefMov" )
   METHOD getBultosFieldName()                      INLINE ( "0" )
   METHOD getCajasFieldName()                       INLINE ( "nCajMov" )
   METHOD getUnidadesFieldName()                    INLINE ( "nUndMov" )
   METHOD getTipoDocumento()                        INLINE ( MOV_ALM )

   METHOD getFechaHoraConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   METHOD getSentenceConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   METHOD getSQLSentenceTotalUnidadesEntradasStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   METHOD getSQLSentenceTotalUnidadesSalidasStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   METHOD getSQLSentenceLineasEntradasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   METHOD getSQLSentenceLineasSalidasAgrupadas( cCodigoArticulo, cCodigoAlmacen )

   METHOD getInfoSqlStock( cCodigoArticulo, cCodigoAlmacen, lSalida )
      METHOD getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen )
      METHOD getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen )

   METHOD getRowSetMovimientosForArticulo( cCodigoArticulo, nYear )

   METHOD getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   METHOD getInfoForReport( oReporting )

   METHOD InsertFromHashSql()

   METHOD lExisteUuid( uuid )

   METHOD getSntSalidaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   METHOD getSntEntradaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

END CLASS

//---------------------------------------------------------------------------//

METHOD updateGUID()

   local cStm
   local cSql  := "UPDATE " + ::getHeaderTableName() + ;
                     " SET cGuid = " + quoted( win_uuidcreatestring() ) + ;
                     " WHERE cGuid = ''"

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceTotalUnidadesEntradasStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   	local cSql  := "SELECT SUM( IIF( nCajMov = 0, 1, nCajMov ) * nUndMov ) as [totalUnidadesStock], " + quoted( ::getTableName() ) + " AS Document " + ;
                     	"FROM " + ::getTableName() + " " + ;
                     	"WHERE cRefMov = " + quoted( cCodigoArticulo ) + " "
   
   	if !empty( dConsolidacion )                     
      	if !empty( tConsolidacion )                     
         	cSql  	+=    "AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= " + quoted( dateToSQLString( dConsolidacion ) + tConsolidacion ) + " "
      	else 
         	cSql  	+=    "AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) >= " + quoted( dateToSQLString( dConsolidacion ) ) + " "
      	end if 
   	end if 

    cSql     		+=    "AND cAliMov = " + quoted( cCodigoAlmacen ) + " "
   	cSql        	+=    "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   	cSql        	+=    "AND cCodPr1 = " + quoted( cCodigoPropiedad2 ) + " "
   	cSql        	+=    "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   	cSql        	+=    "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   	cSql        	+=    "AND cLote = " + quoted( cLote ) + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getSntSalidaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   local cSql        := ""

   cSql              := "SELECT "
   cSql              += "( SUM( IIF( nCajMov = 0, 1, nCajMov ) * nUndMov ) * -1 ) as [totalUnidadesStock], "
   cSql              += quoted( ::getTableName() ) + " AS Document "
   cSql              += "FROM " + ::getTableName() + " AS cTable "
   cSql              += "WHERE cRefMov = " + quoted( cCodigoArticulo ) + " "                     
   cSql              += "AND cAloMov = " + quoted( cCodigoAlmacen ) + " "

   //cSql              += "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   //cSql              += "AND cCodPr2 = " + quoted( cCodigoPropiedad2 ) + " "
   //cSql              += "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   //cSql              += "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   //cSql              += "AND cLote = " + quoted( cLote ) + " "
   
   if !hb_isnil( cCodigoPropiedad1 )
      cSql           += "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   end if

   if !hb_isnil( cCodigoPropiedad2 )
      cSql           += "AND cCodPr2 = " + quoted( cCodigoPropiedad2 ) + " "
   end if

   if !hb_isnil( cValorPropiedad1 )
      cSql           += "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   end if

   if !hb_isnil( cValorPropiedad2 )
      cSql           += "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   end if
   
   if !hb_isnil( cLote )
      cSql           += "AND cLote = " + quoted( cLote ) + " "
   end if

   //cSql              += "AND iif( (" + MovimientosAlmacenLineasModel():getSentenceConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) + ") IS NOT NULL, "
   //cSql              += "( CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= (" + MovimientosAlmacenLineasModel():getSentenceConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) + ") ), TRUE )"
   cSql              += "AND iif( ( SELECT TOP 1 CAST( dFecMov AS SQL_CHAR ) + cTimMov FROM " + ::getEmpresaTableName( "HisMov" ) + " WHERE nTipMov = 4 AND cRefMov = cTable.cRefMov"
   cSql              += " AND cAliMov = cTable.cAloMov"
   cSql              += " AND cCodPr1 = cTable.cCodPr1 AND cCodPr2 = cTable.cCodPr2 AND cValPr1 = cTable.cValPr1 AND cValPr2 = cTable.cValPr2 AND cLote = cTable.cLote ORDER BY dFecMov DESC, cTimMov DESC ) IS NOT NULL, "
   cSql              += "( CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= "
   cSql              += "( SELECT TOP 1 CAST( dFecMov AS SQL_CHAR ) + cTimMov FROM " + ::getEmpresaTableName( "HisMov" ) + " WHERE nTipMov = 4 AND cRefMov = cTable.cRefMov"
   cSql              += " AND cAliMov = cTable.cAloMov"
   cSql              += " AND cCodPr1 = cTable.cCodPr1 AND cCodPr2 = cTable.cCodPr2 AND cValPr1 = cTable.cValPr1 AND cValPr2 = cTable.cValPr2 AND cLote = cTable.cLote ORDER BY dFecMov DESC, cTimMov DESC ) ), TRUE )"
   cSql              += ::getExtraWhere() + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getSntEntradaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   local cSql        := ""

   cSql              := "SELECT "
   
   do case
      case lCalCaj() .and. lCalBul()
         cSql         += "( SUM( IIF( nBultos = 0, 1, nBultos ) * IIF( nCajMov = 0, 1, nCajMov ) * nUndMov ) ) as [totalUnidadesStock], "

      case lCalCaj() .and. !lCalBul()
         cSql         += "( SUM( IIF( nCajMov = 0, 1, nCajMov ) * nUndMov ) ) as [totalUnidadesStock], "

      case !lCalCaj() .and. lCalBul()
         cSql         += "( SUM( IIF( nBultos = 0, 1, nBultos ) * nUndMov ) ) as [totalUnidadesStock], "

      case !lCalCaj() .and. !lCalBul()
         cSql            += "( SUM( nUndMov ) ) as [totalUnidadesStock], "

    end case

   cSql              += quoted( ::getTableName() ) + " AS Document "
   cSql              += "FROM " + ::getTableName() + " AS cTable "
   cSql              += "WHERE cRefMov = " + quoted( cCodigoArticulo ) + " "                     
   cSql              += "AND cAliMov = " + quoted( cCodigoAlmacen ) + " "
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

METHOD getSQLSentenceTotalUnidadesSalidasStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   	local cSql  := "SELECT SUM( IIF( nCajMov = 0, 1, nCajMov ) * nUndMov ) as [totalUnidadesStock], " + quoted( ::getTableName() ) + " AS Document " + ;
                     	"FROM " + ::getTableName() + " " + ;
                     	"WHERE cRefMov = " + quoted( cCodigoArticulo ) + " "
   
   	if !empty( dConsolidacion )                     
      	if !empty( tConsolidacion )                     
         	cSql  	+=    "AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= " + quoted( dateToSQLString( dConsolidacion ) + tConsolidacion ) + " "
      	else 
         	cSql  	+=    "AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) >= " + quoted( dateToSQLString( dConsolidacion ) ) + " "
      	end if 
   	end if 

   cSql     		+=    "AND cAloMov = " + quoted( cCodigoAlmacen ) + " "
   	cSql        	+=    "AND cCodPr1 = " + quoted( cCodigoPropiedad1 ) + " "
   	cSql        	+=    "AND cCodPr1 = " + quoted( cCodigoPropiedad2 ) + " "
   	cSql        	+=    "AND cValPr1 = " + quoted( cValorPropiedad1 ) + " "
   	cSql        	+=    "AND cValPr2 = " + quoted( cValorPropiedad2 ) + " "
   	cSql        	+=    "AND cLote = " + quoted( cLote ) + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getFechaHoraConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   local cStm
   local cSql  	:= 	"SELECT TOP 1 dFecMov, cTimMov FROM " + ::getTableName()    + ;
                  	"  WHERE nTipMov = 4"                                       + ;
                        " AND cRefMov = " + quoted( cCodigoArticulo )         	+ ;
                        " AND cAliMov = " + quoted( cCodigoAlmacen )          

    cSql  		+=  " AND cCodPr1 = " + quoted( cCodigoPropiedad1 )        
    cSql  		+=  " AND cCodPr2 = " + quoted( cCodigoPropiedad2 )        
    cSql  		+=  " AND cValPr1 = " + quoted( cValorPropiedad1 )        
    cSql  		+=  " AND cValPr2 = " + quoted( cValorPropiedad2 )        
    cSql  		+=  " AND cLote = " + quoted( cLote )        
   	cSql       	+=  " ORDER BY dFecMov DESC, cTimMov DESC"

   	if ::ExecuteSqlStatement( cSql, @cStm )
      	if !empty( ( cStm )->dFecMov ) 
         	RETURN ( { "fecha" => ( cStm )->dFecMov, "hora" => ( cStm )->cTimMov } )
      	end if 
   	end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getSentenceConsolidacion( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   local cSql  := ""

   cSql  := "SELECT TOP 1 CAST( dFecMov AS SQL_CHAR ) + cTimMov FROM " + ::getTableName()
   cSql  += " WHERE nTipMov = 4"
   cSql  += " AND cRefMov = " + quoted( cCodigoArticulo )
   cSql  += " AND cAliMov = " + quoted( cCodigoAlmacen )                                  
   cSql  += " AND cCodPr1 = " + quoted( cCodigoPropiedad1 )        
   cSql  += " AND cCodPr2 = " + quoted( cCodigoPropiedad2 )        
   cSql  += " AND cValPr1 = " + quoted( cValorPropiedad1 )        
   cSql  += " AND cValPr2 = " + quoted( cValorPropiedad2 )        
   cSql  += " AND cLote = " + quoted( cLote )        
   cSql  += " ORDER BY dFecMov DESC, cTimMov DESC"

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceLineasEntradasAgrupadas( cCodigoArticulo, cCodigoAlmacen )

   local cSql  := "SELECT "                                                + ;
                     "cRefMov as cCodArt, "                                + ;
                     "cAliMov as cCodAlm, "                                + ;
                     "cCodPr1 as cCodPr1, "                                + ;
                     "cCodPr2 as cCodPr2, "                                + ;
                     "cValPr1 as cValPr1, "                                + ;
                     "cValPr2 as cValPr2, "                                + ;
                     "cLote as cLote "                                     + ;
                  "FROM " + ::getTableName() + " "                         + ;
                  "WHERE cRefMov = " + quoted( cCodigoArticulo ) + " "

   if !Empty( cCodigoAlmacen )
    	cSql    += 	"AND cAliMov = " + quoted( cCodigoAlmacen ) + " "
   end if

   cSql     	+=    "GROUP BY cRefMov, cAliMov, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote "

Return ( cSql )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceLineasSalidasAgrupadas( cCodigoArticulo, cCodigoAlmacen )

   local cSql  := "SELECT "                                                + ;
                     "cRefMov as cCodArt, "                                + ;
                     "cAloMov as cCodAlm, "                                + ;
                     "cCodPr1 as cCodPr1, "                                + ;
                     "cCodPr2 as cCodPr2, "                                + ;
                     "cValPr1 as cValPr1, "                                + ;
                     "cValPr2 as cValPr2, "                                + ;
                     "cLote as cLote "                                     + ;
                  "FROM " + ::getTableName() + " "                         + ;
                  "WHERE cRefMov = " + quoted( cCodigoArticulo ) + " "

    if !Empty( cCodigoAlmacen )
      	cSql    += 	"AND cAloMov = " + quoted( cCodigoAlmacen ) + " "
   	end if

  	cSql     	+=    "GROUP BY cRefMov, cAloMov, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote "

Return ( cSql )

//---------------------------------------------------------------------------//

METHOD getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

    ::cAlmacenFieldName   := "cAliMov"

Return ( ::getInfoSqlStock( cCodigoArticulo, cCodigoAlmacen, .f., dFechaHasta ) )

//---------------------------------------------------------------------------//

METHOD getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

    ::cAlmacenFieldName   := "cAloMov"

Return ( ::getInfoSqlStock( cCodigoArticulo, cCodigoAlmacen, .t., dFechaHasta ) )

//---------------------------------------------------------------------------//

METHOD getInfoSqlStock( cCodigoArticulo, cCodigoAlmacen, lSalida, dFechaHasta )

   local cStm
   local cSql        := ""

   DEFAULT lSalida   := .f.

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
   cSql              += quoted( ::getTipoDocumento() ) + " + CAST( nTipMov AS SQL_CHAR ) AS Document, "
   cSql              += ::getFechaFieldName() + " AS Fecha, "
   cSql              += ::getHoraFieldName() + " AS Hora, "
   cSql              += ::getSerieFieldName() + " AS Serie, "
   cSql              += "CAST( " + ::getNumeroFieldName() + " AS SQL_INTEGER ) AS Numero, "
   cSql              += ::getSufijoFieldName() + " AS Sufijo, "
   cSql              += "CAST( nNumLin AS SQL_INTEGER ) AS Numero, "
   cSql              += ::getArticuloFieldName() + " AS Articulo, "
   cSql              += "cLote AS Lote, "
   cSql              += "cCodPr1 AS propiedad1, "
   cSql              += "cCodPr2 AS propiedad2, "
   cSql              += "cValPr1 AS valor1, "
   cSql              += "cValPr2 AS valor2, "
   cSql              += ::getAlmacenFieldName() + " AS Almacen  "
   cSql              += "FROM " + ::getTableName() + " TablaLineas "
   cSql              += "WHERE " + ::getArticuloFieldName() + " = " + quoted( cCodigoArticulo ) + " " 

   if !empty( cCodigoAlmacen )
      cSql           += "AND " + ::getAlmacenFieldName() + " = " + quoted( cCodigoAlmacen ) + " "
   else
      cSql           += "AND " + ::getAlmacenFieldName() + " is not null "
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

   cSql              += " AND CAST( " + ::getFechaFieldName() + " AS SQL_CHAR ) + " + ::getHoraFieldName() + " >= " 
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

METHOD getRowSetMovimientosForArticulo( cCodigoArticulo, nYear )

   local cStm  := "getRowSetMovimientosForArticulo"
   local cSql  := "SELECT * FROM " + ::getTableName()    + ;
                  "  WHERE cRefMov = " + quoted( cCodigoArticulo )

   if !Empty( nYear )
      cSql     += " AND YEAR( dFecMov ) = " + quoted( nYear )  
   end if

   cSql        += " ORDER BY dFecMov ASC"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   local cSql  := "SELECT "                                             + ;
                     "cRefMov as cCodigoArticulo, "                     + ;
                     "cCodPr1 as cCodigoPrimeraPropiedad, "             + ;
                     "cCodPr2 as cCodigoSegundaPropiedad, "             + ;
                     "cValPr1 as cValorPrimeraPropiedad, "              + ;
                     "cValPr2 as cValorSegundaPropiedad, "              + ;
                     "cLote as cLote, "                                 + ;
                     "dFecMov as dFecDoc, "                             + ;
                     "dFecCad as dFecCad "                              + ;
                  "FROM " + ::getTableName() + " "                      + ;
                  "WHERE cRefMov = " + quoted( cCodigoArticulo ) + " "  + ;
                     "AND dFecCad IS NOT NULL "       

   cSql        += ::getExtraWhere()                                
   cSql        += "AND cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " "
   cSql        += "AND cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " "
   cSql        += "AND cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " "
   cSql        += "AND cValPr2 = " + quoted( cValorSegundaPropiedad ) + " "   
   cSql        += "AND cLote = " + quoted( cLote ) + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getInfoForReport( oReporting )

   local cStm        := "reporting_mov_alm"
   local cSentence  :=  "SELECT * FROM " + ::getTableName()                                                          + ;
                        " WHERE CAST( dFecMov AS SQL_CHAR ) >= " + quoted( dateToSQLString( oReporting:dIniInf ) )   + ;
                        " AND CAST( dFecMov AS SQL_CHAR ) <= " + quoted( dateToSQLString( oReporting:dFinInf ) )

   if ::ExecuteSqlStatement( cSentence, @cStm )
      RETURN ( cStm )
   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD InsertFromHashSql( hHashHead, hHashLine )

   local cStm     := "InsertFromHashSqlLin"
   local cSql     := ""

   if !Empty( hHashHead ) .and. !Empty( hHashLine ) .and. !::lExisteUuid( hGet( hHashLine, "uuid" ) ) 

      cSql         := "INSERT INTO " + ::getTableName() 
      cSql         += " ( dFecMov, cTimMov, nTipMov, cAliMov, cAloMov, cRefMov, cNomMov, cCodPr1, cCodPr2, cValPr1, cValPr2,"

      if !Empty( hGet( hHashLine, "fecha_caducidad" ) )
         cSql      += " dFecCad,"
      end if

      cSql         += " cCodUsr, cCodDlg, lLote, cLote, nCajMov, nUndMov, nPreDiv, lSndDoc, nNumRem,"
      cSql         += " cSufRem, lSelDoc, nBultos, cGuid, cGuidPar ) VALUES "
      cSql         += "( " + quoted( dToc( hb_ttod( hGet( hHashHead, "fecha_hora" ) ) ) )
      cSql         += ", " + quoted( StrTran( substr( hb_tstostr( hGet( hHashHead, "fecha_hora" ) ), 12, 8 ), ":", "" ) )
      cSql         += ", " + AllTrim( Str( hGet( hHashHead, "tipo_movimiento" ) ) )
      cSql         += ", " + quoted( hGet( hHashHead, "almacen_destino" ) )
      cSql         += ", " + quoted( hGet( hHashHead, "almacen_origen" ) )
      cSql         += ", " + quoted( hGet( hHashLine, "codigo_articulo" ) )
      cSql         += ", " + quoted( Left( StrTran( hGet( hHashLine, "nombre_articulo" ), "'", "" ), 50 ) )
      cSql         += ", " + quoted( hGet( hHashLine, "codigo_primera_propiedad" ) )
      cSql         += ", " + quoted( hGet( hHashLine, "codigo_segunda_propiedad" ) )
      cSql         += ", " + quoted( hGet( hHashLine, "valor_primera_propiedad" ) )
      cSql         += ", " + quoted( hGet( hHashLine, "valor_segunda_propiedad" ) )
      
      if !Empty( hGet( hHashLine, "fecha_caducidad" ) )
         cSql      += ", " + quoted( dToc( hb_ttod( hGet( hHashLine, "fecha_caducidad" ) ) ) )
      end if
      
      cSql         += ", " + quoted( Auth():Codigo() )
      cSql         += ", " + quoted( RetSufEmp() )
      cSql         += ", " + if( !Empty( quoted( hGet( hHashLine, "lote" ) ) ), ".t. ", ".f. " )
      cSql         += ", " + quoted( Left( strTran( hGet( hHashLine, "lote" ),"'", "" ), 14 ) )
      cSql         += ", " + AllTrim( Str( hGet( hHashLine, "cajas_articulo" ) ) )
      cSql         += ", " + AllTrim( Str( hGet( hHashLine, "unidades_articulo" ) ) )
      cSql         += ", " + AllTrim( Str( hGet( hHashLine, "precio_articulo" ) ) )
      cSql         += ", .t. "
      cSql         += ", " + AllTrim( hGet( hHashHead, "numero" ) )      
      cSql         += ", " + quoted( RetSufEmp() )
      cSql         += ", .t. "
      cSql         += ", " + AllTrim( Str( hGet( hHashLine, "bultos_articulo" ) ) )
      cSql         += ", " + quoted( hGet( hHashLine, "uuid" ) )
      cSql         += ", " + quoted( hGet( hHashLine, "parent_uuid" ) ) + " )"

      ::ExecuteSqlStatement( cSql, @cStm )

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lExisteUuid( uuid )

   local cStm     := "lExisteUuid"
   local cSql     := ""

   cSql     := "SELECT * FROM " + ::getTableName() + " WHERE cGuid = " + quoted( uuid )

      if ::ExecuteSqlStatement( cSql, @cStm )

         if ( cStm )->( RecCount() ) > 0
            Return ( .t. )
         end if

      end if

Return ( .f. )

//---------------------------------------------------------------------------//