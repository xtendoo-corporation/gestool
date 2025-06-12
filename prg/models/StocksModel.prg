#include "FiveWin.ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS StocksModel FROM ADSBaseModel

   DATA cGroupByStatement               INIT ""

   METHOD getFechaCaducidad()

   //METHOD nStockArticulo( cCodArt, cCodAlm, cCodPrp1, cCodPrp2, cValPr1, cValPr2, cLote )
      //METHOD getTotalUnidadesStockSalidas()
      //METHOD getTotalUnidadesStockEntradas()

   METHOD nStockArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )

   METHOD nGlobalStockArticulo( cCodArt, cCodAlm )
      METHOD getLineasAgrupadas()
      METHOD closeAreaLineasAgrupadas()                     INLINE ( ::closeArea( "ADSLineasAgrupadas" ) )

   METHOD getSqlBrwStock( cCodigoArticulo, cCodigoAlmacen )
   METHOD getSqlBrwArtStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

   METHOD aStockArticulo( cCodigoArticulo, cCodigoAlmacen ) INLINE ( DBHScatter( ::getSqlBrwStock( cCodigoArticulo, cCodigoAlmacen ) ) )

   METHOD getInfoSqlStockDocument( cCodigoArticulo, cCodigoAlmacen )
   METHOD oTreeStocks( cCodigoArticulo, cCodigoAlmacen )
      METHOD infoDocumento( cStm )
      METHOD cTextDocument( cStm )

   METHOD getInfoStockPendiente( cCodigoArticulo, cCodigoAlmacen )
   METHOD oTreePendiente( cCodigoArticulo, cCodigoAlmacen )
   METHOD nTotStockPendiente( cCodigoArticulo, cCodigoAlmacen )

   METHOD lPutStockActual( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote, oGet )

   METHOD StockInit( cPath, cPathOld, oMsg, cCodEmpOld, cCodEmpNew )

END CLASS

//---------------------------------------------------------------------------//

METHOD getFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote ) CLASS StocksModel

   local cStm  
   local cSql  := "SELECT TOP 1 dFecDoc, dFecCad "
   cSql        += "FROM ( "
   cSql        += AlbaranesProveedoresLineasModel():getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )
   cSql        += "UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )
   cSql        += "UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )
   cSql        += "UNION ALL "
   cSql        += MaterialesProducidosLineasModel():getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )
   cSql        += "UNION ALL "
   cSql        += MovimientosAlmacenLineasModel():getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )
   cSql        += ") FecCad "
   cSql        += "ORDER BY dFecDoc DESC"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->dFecCad )
   end if 

RETURN ( ctod( "" ) )

//---------------------------------------------------------------------------//

/*METHOD nStockArticulo( cCodArt, cCodAlm, cCodPrp1, cCodPrp2, cValPr1, cValPr2, cLote ) CLASS StocksModel

   local nStockArticulo         := 0
   local tHoraConsolidacion
   local dFechaConsolidacion
   local hFechaHoraConsolidacion

   if empty( cCodArt ) .and. !Empty( cCodAlm )
      RETURN ( nStockArticulo )
   end if 

   cCodArt                       := padr( cCodArt, 18 )

   // Obtenermos el dato de la consolidacion--------------------------------

   hFechaHoraConsolidacion    := MovimientosAlmacenLineasModel():getFechaHoraConsolidacion( cCodArt, cCodAlm, cCodPrp1, cCodPrp2, cValPr1, cValPr2, cLote )

   if !empty( hFechaHoraConsolidacion )
      
      dFechaConsolidacion     := hGet( hFechaHoraConsolidacion, "fecha" )
      tHoraConsolidacion      := hGet( hFechaHoraConsolidacion, "hora" )
      
   else

      dFechaConsolidacion     := nil
      tHoraConsolidacion      := nil

   end if 

   // Entradas--------------------------------------------------------------

   nStockArticulo             += ::getTotalUnidadesStockEntradas( cCodArt, dFechaConsolidacion, tHoraConsolidacion, cCodAlm, cCodPrp1, cCodPrp2, cValPr1, cValPr2, cLote )

   // Salidas----------------------------------------------------------------

   nStockArticulo             -= ::getTotalUnidadesStockSalidas( cCodArt, dFechaConsolidacion, tHoraConsolidacion, cCodAlm, cCodPrp1, cCodPrp2, cValPr1, cValPr2, cLote )

RETURN ( nStockArticulo )*/

//---------------------------------------------------------------------------//

METHOD nStockArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) CLASS StocksModel

   local nStockArticulo         := 0
   local cStm  := "getTotalUnidadesStockSalidas"  
   local cSql  := ""

   if empty( cCodigoArticulo ) .and. !Empty( cCodigoAlmacen )
      RETURN ( nStockArticulo )
   end if 

   cCodigoArticulo                       := padr( cCodigoArticulo, 18 )

   cSql        += "SELECT SUM( totalUnidadesStock ) as [total] "   
   cSql        += "FROM ( "
   cSql        += MovimientosAlmacenLineasModel():getSntSalidaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += AlbaranesClientesLineasModel():getSntSalidaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += FacturasClientesLineasModel():getSntSalidaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += RectificativasClientesLineasModel():getSntSalidaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += TicketsClientesLineasModel():getSntSalidaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += TicketsClientesLineasModel():getSntTotalUnidadesComb( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += MaterialesConsumidosLineasModel():getSntSalidaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += AlbaranesProveedoresLineasModel():getSntSalidaComprasStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getSntSalidaComprasStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getSntSalidaComprasStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += MovimientosAlmacenLineasModel():getSntEntradaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += MaterialesProducidosLineasModel():getSntEntradaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += AlbaranesProveedoresLineasModel():getSntEntradaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getSntEntradaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getSntEntradaStock( cCodigoArticulo, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += " ) StockSalidas"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->total )
   end if 

RETURN ( nStockArticulo )

//---------------------------------------------------------------------------//

/*METHOD getTotalUnidadesStockSalidas( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) CLASS StocksModel

   local cStm  := "getTotalUnidadesStockSalidas"  
   local cSql  := "SELECT SUM( totalUnidadesStock ) as [total] "
   cSql        += "FROM ( "
   cSql        += MovimientosAlmacenLineasModel():getSQLSentenceTotalUnidadesSalidasStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += AlbaranesClientesLineasModel():getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += FacturasClientesLineasModel():getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += RectificativasClientesLineasModel():getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += TicketsClientesLineasModel():getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += TicketsClientesLineasModel():getSQLSentenceTotalUnidadesComb( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += MaterialesConsumidosLineasModel():getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += AlbaranesProveedoresLineasModel():getSentenceTotalSalidasCompras( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getSentenceTotalSalidasCompras( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getSentenceTotalSalidasCompras( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += " ) StockSalidas"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->total )
   end if 

RETURN ( 0 )*/

//---------------------------------------------------------------------------//

/*METHOD getTotalUnidadesStockEntradas( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote ) CLASS StocksModel

   local cStm  := "getTotalUnidadesStockEntradas"  
   local cSql  := "SELECT SUM( totalUnidadesStock ) as [total] "
   cSql        += "FROM ( "
   cSql        += MovimientosAlmacenLineasModel():getSQLSentenceTotalUnidadesEntradasStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += MaterialesProducidosLineasModel():getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += AlbaranesProveedoresLineasModel():getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += "UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getSQLSentenceTotalUnidadesStock( cCodigoArticulo, dConsolidacion, tConsolidacion, cCodigoAlmacen, cCodigoPropiedad1, cCodigoPropiedad2, cValorPropiedad1, cValorPropiedad2, cLote )
   cSql        += " ) StockEntradas"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->total )
   end if 

RETURN ( 0 )*/

//---------------------------------------------------------------------------//

METHOD nGlobalStockArticulo( cCodigoArticulo, cCodigoAlmacen, dFechaHasta ) CLASS StocksModel

   local cStm                 := "nGlobalStockArticulo"
   local cSql

   if !Empty( cCodigoAlmacen )
   cSql        := "SELECT TOP 1 articulo, almacen, SUM( unidades ) AS unidades "
   else
   cSql        := "SELECT TOP 1 articulo, SUM( unidades ) AS unidades "
   end if

   cSql        += "FROM ( "
   cSql        += AlbaranesProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += AlbaranesProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += AlbaranesClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += FacturasClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += RectificativasClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += TicketsClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += TicketsClientesLineasModel():getInfoSqlStockCombinado( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += MaterialesProducidosLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += MaterialesConsumidosLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL " 
   cSql        += MovimientosAlmacenLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += MovimientosAlmacenLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

   if !Empty( cCodigoAlmacen )
   cSql        += " ) StockDocumentos GROUP BY articulo, almacen"
   else
   cSql        += " ) StockDocumentos GROUP BY articulo"
   end if

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )->unidades
   end if

   /*local cStm
   local nStockArticulo          := 0
   local aAlmacenes              := AlmacenesModel():aAlmacenes()
   local nSec                    := seconds()
   
   if empty( cCodArt )
      RETURN ( nStockArticulo )
   end if 

   cCodArt                       := padr( cCodArt, 18 )

   cStm                          := ::getLineasAgrupadas( cCodArt, cCodAlm )

   msginfo( seconds() - nSec, "Lineas agrupadas" )

   ( cStm )->( dbgotop() )
   ( cStm )->( browse() )

   nSec                    := seconds()
   
   while !( cStm )->( eof() )

      if !Empty( ( cStm )->cCodArt ) .and. !Empty( ( cStm )->cCodAlm )

         if aScan( aAlmacenes, {|hAlmacen| AllTrim( hGet( hAlmacen, "cCodAlm" ) ) == AllTrim( ( cStm )->cCodAlm ) } ) != 0

            nStockArticulo         += ::nStockArticulo(     ( cStm )->cCodArt,;
                                                            ( cStm )->cCodAlm,;
                                                            ( cStm )->cCodPr1,;
                                                            ( cStm )->cCodPr2,;
                                                            ( cStm )->cValPr1,;
                                                            ( cStm )->cValPr2,;
                                                            ( cStm )->cLote )
         end if

      end if

      ( cStm )->( dbskip() )

   end while

   msginfo( seconds() - nSec, "stock" )

   ::closeAreaLineasAgrupadas()*/

RETURN ( 0 )

//---------------------------------------------------------------------------//

METHOD getLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen ) CLASS StocksModel

   local cStm              := "ADSLineasAgrupadas"
   local cSql              := ""
   cSql                    += MovimientosAlmacenLineasModel():getSQLSentenceLineasEntradasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += MovimientosAlmacenLineasModel():getSQLSentenceLineasSalidasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += AlbaranesClientesLineasModel():getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += FacturasClientesLineasModel():getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += TicketsClientesLineasModel():getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += TicketsClientesLineasModel():getSQLSentenceCombAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += MaterialesConsumidosLineasModel():getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += MaterialesProducidosLineasModel():getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += AlbaranesProveedoresLineasModel():getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += AlbaranesProveedoresLineasModel():getSentenceLinAgrSalidasCompras( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += FacturasProveedoresLineasModel():getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += FacturasProveedoresLineasModel():getSentenceLinAgrSalidasCompras( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += RectificativasProveedoresLineasModel():getSQLSentenceLineasAgrupadas( cCodigoArticulo, cCodigoAlmacen )
   cSql                    += "UNION ALL "
   cSql                    += RectificativasProveedoresLineasModel():getSentenceLinAgrSalidasCompras( cCodigoArticulo, cCodigoAlmacen )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getSqlBrwStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta ) CLASS StocksModel

   local n
   local aAlmacenes     := AlmacenesModel():aAlmacenes()
   local cStm           := "getSqlBrwStock"
   local cSql

   if Len( aAlmacenes ) == 0
      Return ( nil )
   end if

   cSql        := "SELECT articulo, almacen, lote, propiedad1, propiedad2, valor1, valor2, SUM( bultos ) AS bultos, SUM( cajas ) AS cajas, SUM( unidades ) AS unidades "
   cSql        += "FROM ( "
   cSql        += AlbaranesProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += AlbaranesProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += AlbaranesClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += FacturasClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += RectificativasClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += TicketsClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += TicketsClientesLineasModel():getInfoSqlStockCombinado( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += MaterialesProducidosLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += MaterialesConsumidosLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL " 
   cSql        += MovimientosAlmacenLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += MovimientosAlmacenLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " ) StockDocumentos WHERE (" 
   
   for n := 1 to len( aAlmacenes )
      cSql     += " almacen = " + quoted( hGet( aAlmacenes[n], "cCodAlm" ) )
      if n != len( aAlmacenes ) 
         cSql  += " OR " 
      end if
   next

   cSql        += " ) GROUP BY articulo, almacen, lote, propiedad1, propiedad2, valor1, valor2"

   if ::ExecuteSqlStatement( cSql, @cStm )
      ( cStm )->( dbSetFilter( {|| Field->unidades != 0 }, "unidades != 0" ) )
      ( cStm )->( dbGoTop() )
      RETURN ( cStm )
   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getSqlBrwArtStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta ) CLASS StocksModel

   local n
   local aAlmacenes  := AlmacenesModel():aAlmacenes()
   local cStm        := "getSqlBrwArtStock"
   local cSql

   if Len( aAlmacenes ) == 0
      Return ( nil )
   end if

   cSql        := "SELECT articulo, almacen, lote, propiedad1, propiedad2, valor1, valor2, SUM( bultos ) AS bultos, SUM( cajas ) AS cajas, SUM( unidades ) AS unidades "
   cSql        += "FROM ( "
   cSql        += AlbaranesProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += AlbaranesProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += FacturasProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += RectificativasProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += AlbaranesClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += FacturasClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += RectificativasClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += TicketsClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += TicketsClientesLineasModel():getInfoSqlStockCombinado( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += MaterialesProducidosLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += MaterialesConsumidosLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL " 
   cSql        += MovimientosAlmacenLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " UNION ALL "
   cSql        += MovimientosAlmacenLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )
   cSql        += " ) StockDocumentos WHERE (" 
   
   for n := 1 to len( aAlmacenes )
      cSql     += " almacen = " + quoted( hGet( aAlmacenes[n], "cCodAlm" ) )
      if n != len( aAlmacenes ) 
         cSql  += " OR " 
      end if
   next

   cSql        += " ) GROUP BY articulo, almacen, lote, propiedad1, propiedad2, valor1, valor2"

   if ::ExecuteSqlStatement( cSql, @cStm )
      ( cStm )->( dbSetFilter( {|| Field->unidades != 0 }, "unidades != 0" ) )
      ( cStm )->( dbGoTop() )
      RETURN ( cStm )
   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getInfoSqlStockDocument( cCodigoArticulo, cCodigoAlmacen ) CLASS StocksModel

   local n
   local aAlmacenes  := AlmacenesModel():aAlmacenes()
   local cStm        := "getInfoSqlStockDocument"
   local cSql

   cSql              := "SELECT articulo, almacen, lote, propiedad1, propiedad2, valor1, valor2, fecha, hora, document, serie, numero, sufijo, nnumlin, bultos, cajas, unidades "
   cSql              += "FROM ( "
   cSql              += AlbaranesProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += AlbaranesProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += FacturasProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += FacturasProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += RectificativasProveedoresLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += RectificativasProveedoresLineasModel():getInfoSalidasComprasStock( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += AlbaranesClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += FacturasClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += RectificativasClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += TicketsClientesLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += TicketsClientesLineasModel():getInfoSqlStockCombinado( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += MaterialesProducidosLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += MaterialesConsumidosLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL " 
   cSql              += MovimientosAlmacenLineasModel():getInfoSqlStockEntrada( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += MovimientosAlmacenLineasModel():getInfoSqlStockSalida( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " ) StockDocumentos WHERE ( " 
   
   for n := 1 to len( aAlmacenes )
      cSql           += " almacen = " + quoted( hGet( aAlmacenes[n], "cCodAlm" ) )
      if n != len( aAlmacenes ) 
         cSql        += " OR " 
      end if
   next

   cSql              += " ) ORDER BY articulo, almacen, lote, propiedad1, propiedad2, valor1, valor2, fecha, hora ASC"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getInfoStockPendiente( cCodigoArticulo, cCodigoAlmacen ) CLASS StocksModel

   local n
   local aAlmacenes  := AlmacenesModel():aAlmacenes()
   local cStm        := "getInfoStockPendiente"
   local cSql

   cSql              := "SELECT articulo, almacen, fecha, hora, document, serie, numero, sufijo, nnumlin, pdtrecibir, pdtentrega "
   cSql              += "FROM ( "
   cSql              += PedidosProveedoresLineasModel():getInfoPdtRecibir( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += AlbaranesProveedoresLineasModel():getInfoPdtRecibir( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += PedidosClientesLineasModel():getInfoPdtEntregar( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += AlbaranesClientesLineasModel():getInfoPdtEntregar( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " UNION ALL "
   cSql              += FacturasClientesLineasModel():getInfoPdtEntregar( cCodigoArticulo, cCodigoAlmacen )
   cSql              += " ) StockDocumentos WHERE ( " 
   
   for n := 1 to len( aAlmacenes )
      cSql           += " almacen = " + quoted( hGet( aAlmacenes[n], "cCodAlm" ) )
      if n != len( aAlmacenes ) 

         cSql        += " OR " 
      end if
   next

   cSql              += " ) ORDER BY articulo, almacen, fecha, hora ASC"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD nTotStockPendiente( cCodigoArticulo, cCodigoAlmacen ) CLASS StocksModel

   local nTotPdtRecibir       := 0
   local nTotPdtentregar      := 0
   local cStm                 := ::getInfoStockPendiente( cCodigoArticulo, cCodigoAlmacen )

   if ( cStm )->( OrdKeyCount() ) > 0

      while !( cStm )->( Eof() )

         nTotPdtRecibir       += ( cStm )->pdtrecibir
         nTotPdtentregar      += ( cStm )->pdtentrega

         ( cStm )->( dbSkip() )

      end while

   end if

RETURN ( { "nTotPdtRec" => nTotPdtRecibir, "nTotPdtEnt" => nTotPdtentregar} )

//---------------------------------------------------------------------------//

METHOD oTreeStocks( cCodigoArticulo, cCodigoAlmacen, oMeter ) CLASS StocksModel

   local oTree
   local cValue
   local cStm

   SysRefresh()

   cStm                    := ::getInfoSqlStockDocument( cCodigoArticulo, cCodigoAlmacen )

   if ( cStm )->( OrdKeyCount() ) == 0
      Return oTree
   end if

   oTree          := TreeBegin()

   if !Empty( oMeter )
      oMeter:SetTotal( ( cStm )->( OrdKeyCount() ) )
   end if

   ( cStm )->( dbGoTop() )

   while !( cStm )->( eof() )

      if cValue != ( cStm )->articulo + ( cStm )->almacen + ( cStm )->lote

         if cValue != nil
            TreeEnd()
         end if 

         TreeAddItem( alltrim( ( cStm )->almacen ) + Space(1) + retAlmacen( ( cStm )->almacen ) )

         TreeBegin()

      end if 

      TreeAddItem( ::infoDocumento( cStm ) ):Cargo := dbHash( cStm )

      cValue      := ( cStm )->Articulo + ( cStm )->Almacen + ( cStm )->Lote

      if !Empty( oMeter )
         oMeter:AutoInc()
      end if
   
      ( cStm )->( dbSkip() )

   end while

   if cValue != nil
      TreeEnd()
   end if 

   TreeEnd()

   if !Empty( oMeter )
      oMeter:Set( ( cStm )->( LastRec() ) )
   end if

   SysRefresh()

RETURN ( oTree )

//---------------------------------------------------------------------------//

METHOD oTreePendiente( cCodigoArticulo, cCodigoAlmacen, oMeter ) CLASS StocksModel

   local oTree
   local cValue
   local cStm

   SysRefresh()

   cStm           := ::getInfoStockPendiente( cCodigoArticulo, cCodigoAlmacen )

   if ( cStm )->( OrdKeyCount() ) == 0
      Return oTree
   end if

   oTree          := TreeBegin()

   if !Empty( oMeter )
      oMeter:SetTotal( ( cStm )->( OrdKeyCount() ) )
   end if

   ( cStm )->( dbGoTop() )

   while !( cStm )->( eof() )

      if cValue != ( cStm )->articulo + ( cStm )->almacen

         if cValue != nil
            TreeEnd()
         end if 

         TreeAddItem( alltrim( ( cStm )->almacen ) + Space(1) + retAlmacen( ( cStm )->almacen ) )

         TreeBegin()

      end if 

      TreeAddItem( ::infoDocumento( cStm ) ):Cargo := dbHash( cStm )

      cValue      := ( cStm )->Articulo + ( cStm )->Almacen

      if !Empty( oMeter )
         oMeter:AutoInc()
      end if
   
      ( cStm )->( dbSkip() )

   end while

   if cValue != nil
      TreeEnd()
   end if 

   TreeEnd()

   if !Empty( oMeter )
      oMeter:Set( ( cStm )->( LastRec() ) )
   end if

   SysRefresh()

RETURN ( oTree )

//---------------------------------------------------------------------------//

METHOD infoDocumento( cStm ) CLASS StocksModel

   local cDocumento     := ""

   cDocumento           += ::cTextDocument( cStm ) + space( 1 )

   if !Empty( ( cStm )->Serie )
      cDocumento        += ( cStm )->serie + "/" + AllTrim( Str( ( cStm )->numero ) ) + "/" + ( cStm )->sufijo + space( 1 )
   else 
      cDocumento        += AllTrim( Str( ( cStm )->numero ) ) + "/" + ( cStm )->sufijo + space( 1 )
   end if

   cDocumento           += "de fecha " + dtoc( ( cStm )->fecha )
   cDocumento           += if( empty( ( cStm )->hora ), "", " a las " + trans( ( cStm )->hora, "@R 99:99:99" ) )

RETURN ( cDocumento )

//---------------------------------------------------------------------------//

METHOD cTextDocument( cStm ) CLASS StocksModel

   local cTextDocument  := ""

   if !isChar( ( cStm )->document )
      Return ( cTextDocument )
   end if

   do case
      case ( cStm )->document == PED_PRV
         cTextDocument  := "Pedido proveedor"

      case ( cStm )->document == ALB_PRV
         cTextDocument  := "Albarán proveedor"

      case ( cStm )->document == FAC_PRV
         cTextDocument  := "Factura proveedor"

      case ( cStm )->document == RCT_PRV
         cTextDocument  := "Rectificativa proveedor"

      case ( cStm )->document == PED_CLI
         cTextDocument  := "Pedido cliente"

      case ( cStm )->document == ALB_CLI
         cTextDocument  := "Albarán cliente"

      case ( cStm )->document == FAC_CLI
         cTextDocument  := "Factura cliente"

      case ( cStm )->document == FAC_REC
         cTextDocument  := "Rectificativa cliente"

      case ( cStm )->document == TIK_CLI
         cTextDocument  := "Simplificada cliente"

      case SubStr( ( cStm )->document, 1, 2 ) == MOV_ALM

         do case
            case val( SubStr( ( cStm )->document, 3 ) ) == 1
               cTextDocument  := "Mov. entre almacenes"

            case val( SubStr( ( cStm )->document, 3 ) ) == 2
               cTextDocument  := "Mov. regularización"

            case val( SubStr( ( cStm )->document, 3 ) ) == 3
               cTextDocument  := "Mov. objetivo"

            case val( SubStr( ( cStm )->document, 3 ) ) == 4
               cTextDocument  := "Mov. consolidación"

         end case

      case ( cStm )->document == PRO_LIN
         cTextDocument  := "Material producido"

      case ( cStm )->document == PRO_MAT
         cTextDocument  := "Materia prima"

   end case

Return ( cTextDocument )

//---------------------------------------------------------------------------//

METHOD lPutStockActual( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote, oGet ) CLASS StocksModel

   local nStock   := 0
   local cClass   := ""

   if !uFieldEmpresa( "lNStkAct" )
      nStock      := ::nStockArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )
   end if

   if !empty( oGet )

      cClass      := oGet:ClassName()

      do case
         case cClass == "TGET" .or. cClass == "TGETHLP" .or. cClass == "TGRIDGET"
            oGet:cText( nStock )
         case cClass == "TSAY"
            oGet:SetText( nStock )
      end case

   end if

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD StockInit( cCodEmpOld, cCodEmpNew ) CLASS StocksModel

   local hAlmacen
   local aAlmacenes  := {}
   local listArt     := "listart"
   local alisStk     := {}
   local aTotalStock := {}
   local nCount      := 202400001
   local cSql        := ""
   local cStm
   local cSqlLin     := ""
   local cStmLin
   local hLin
   local nCountLin   := 1

   ArticulosModel():getListArticulos( listArt )
   
   /*( listArt )->( dbGoTop() )

   while !( listArt )->( eof() )

      Msgwait( ( listArt )->Codigo, "Artículo", 0.0001 )

      alisStk  := DBHScatter( ::getSqlBrwArtStock( ( listArt )->Codigo ) )

      if len( alisStk ) > 0
         aeval(alisStk, {|a| aAdd( aTotalStock, a ) } )
      end if

      ( listArt )->( dbSkip() )

   end while*/

   aAlmacenes := AlmacenesModel():aAlmacenes()

   for each hAlmacen in aAlmacenes

      /*
      Inserto la cabecera------------------------------------------------------
      */

      cSql         := "INSERT INTO " + MovimientosAlmacenModel():getEmpresaTableName( "RemMovT" ) 
      cSql         += " ( lSelDoc, nNumRem, cSufRem, nTipMov, cCodUsr, cCodDlg, dFecRem, cTimRem, cAlmOrg, cAlmDes, cCodDiv, nVdvDiv, cComMov, cGuid ) VALUES "
      cSql         += " ( .t., " + allTrim( Str( nCount ) )
      cSql         += ", " + quoted( "00" )
      cSql         += ", " + "4"
      cSql         += ", " + quoted( Auth():Codigo() )
      cSql         += ", " + quoted( "00" )
      cSql         += ", " + quoted( "01/01/2024" )
      cSql         += ", " + quoted( "030000" )
      cSql         += ", " + quoted( "" )
      cSql         += ", " + quoted( hGet( hAlmacen, "cCodAlm" ) )
      cSql         += ", " + quoted( "EUR" )
      cSql         += ", " + "1"
      cSql         += ", " + quoted( "Apertura de empresa" )
      cSql         += ", " + quoted( Str( nCount ) ) + " )"

      MovimientosAlmacenModel():ExecuteSqlStatement( cSql, @cStm )

      /*
      Inserto las lineas------------------------------------------------------
      */

      /*For each hLin in aTotalStock

         if AllTrim( hGet( hLin, "almacen" ) ) == AllTrim( hGet( hAlmacen, "cCodAlm" ) )

            Msgwait( hGet( hAlmacen, "cCodAlm" ) + hGet( hLin, "articulo" ), "Artículo", 0.0001 )

            cSqlLin      := "INSERT INTO " + MovimientosAlmacenLineasModel():getEmpresaTableName( "HisMov" )
            cSqlLin      += " ( dFecMov, cTimMov, nTipMov, cAliMov, cAloMov, cRefMov, cNomMov, cCodPr1, cCodPr2, cValPr1, cValPr2,"
            cSqlLin      += " cCodUsr, cCodDlg, lLote, cLote, nCajMov, nUndMov, nPreDiv, lSndDoc, nNumRem,"
            cSqlLin      += " cSufRem, lSelDoc, nNumLin, nBultos, cGuid, cGuidPar ) VALUES "
            cSqlLin      += "( " + quoted( "01/01/2024" )
            cSqlLin      += ", " + quoted( "030000" )
            cSqlLin      += ", " + "4"
            cSqlLin      += ", " + quoted( hGet( hAlmacen, "cCodAlm" ) )
            cSqlLin      += ", " + quoted( "" )
            cSqlLin      += ", " + quoted( hGet( hLin, "articulo" ) )
            cSqlLin      += ", " + quoted( Left( StrTran( ArticulosModel():getNombre( hGet( hLin, "articulo" ) ), "'", "" ), 50 ) )
            cSqlLin      += ", " + quoted( hGet( hLin, "propiedad1" ) )
            cSqlLin      += ", " + quoted( hGet( hLin, "propiedad2" ) )
            cSqlLin      += ", " + quoted( hGet( hLin, "valor1" ) )
            cSqlLin      += ", " + quoted( hGet( hLin, "valor2" ) )
            cSqlLin      += ", " + quoted( Auth():Codigo() )
            cSqlLin      += ", " + quoted( "00" )
            cSqlLin      += ", " + if( !Empty( quoted( hGet( hLin, "lote" ) ) ), ".t. ", ".f. " )
            cSqlLin      += ", " + quoted( Left( strTran( hGet( hLin, "lote" ),"'", "" ), 14 ) )
            cSqlLin      += ", 1"
            cSqlLin      += ", " + AllTrim( Str( hGet( hLin, "unidades" ) ) )
            cSqlLin      += ", " + "0"
            cSqlLin      += ", .t. "
            cSqlLin      += ", " + allTrim( Str( nCount ) )
            cSqlLin      += ", " + quoted( "00" )
            cSqlLin      += ", .t. "
            cSqlLin      += ", " + allTrim( Str( nCountLin ) )
            cSqlLin      += ", " + "0"
            cSqlLin      += ", " + quoted( win_uuidcreatestring() )
            cSqlLin      += ", " + quoted( Str( nCount ) ) + " )"

            MovimientosAlmacenLineasModel():ExecuteSqlStatement( cSqlLin, @cStmLin )

            nCountLin++
         
         end if

         SysRefresh()

      next*/

      ( listArt )->( dbGoTop() )

      while !( listArt )->( eof() )

         Msgwait( ( listArt )->Codigo, "Artículo", 0.0001 )

         alisStk  := DBHScatter( ::getSqlBrwArtStock( ( listArt )->Codigo, AllTrim( hGet( hAlmacen, "cCodAlm" ) ) ) )

         if len( alisStk ) > 0

            cSqlLin      := "INSERT INTO " + MovimientosAlmacenLineasModel():getEmpresaTableName( "HisMov" )
            cSqlLin      += " ( dFecMov, cTimMov, nTipMov, cAliMov, cAloMov, cRefMov, cNomMov, cCodPr1, cCodPr2, cValPr1, cValPr2,"
            cSqlLin      += " cCodUsr, cCodDlg, lLote, cLote, nCajMov, nUndMov, nPreDiv, lSndDoc, nNumRem,"
            cSqlLin      += " cSufRem, lSelDoc, nNumLin, nBultos, cGuid, cGuidPar ) VALUES "
            cSqlLin      += "( " + quoted( "01/01/2024" )
            cSqlLin      += ", " + quoted( "030000" )
            cSqlLin      += ", " + "4"
            cSqlLin      += ", " + quoted( hGet( hAlmacen, "cCodAlm" ) )
            cSqlLin      += ", " + quoted( "" )
            cSqlLin      += ", " + quoted( hGet( alisStk[1], "articulo" ) )
            cSqlLin      += ", " + quoted( Left( StrTran( ArticulosModel():getNombre( hGet( alisStk[1], "articulo" ) ), "'", "" ), 50 ) )
            cSqlLin      += ", " + quoted( hGet( alisStk[1], "propiedad1" ) )
            cSqlLin      += ", " + quoted( hGet( alisStk[1], "propiedad2" ) )
            cSqlLin      += ", " + quoted( hGet( alisStk[1], "valor1" ) )
            cSqlLin      += ", " + quoted( hGet( alisStk[1], "valor2" ) )
            cSqlLin      += ", " + quoted( Auth():Codigo() )
            cSqlLin      += ", " + quoted( "00" )
            cSqlLin      += ", " + if( !Empty( quoted( hGet( alisStk[1], "lote" ) ) ), ".t. ", ".f. " )
            cSqlLin      += ", " + quoted( Left( strTran( hGet( alisStk[1], "lote" ),"'", "" ), 14 ) )
            cSqlLin      += ", 1"
            cSqlLin      += ", " + AllTrim( Str( hGet( alisStk[1], "unidades" ) ) )
            cSqlLin      += ", " + "0"
            cSqlLin      += ", .t. "
            cSqlLin      += ", " + allTrim( Str( nCount ) )
            cSqlLin      += ", " + quoted( "00" )
            cSqlLin      += ", .t. "
            cSqlLin      += ", " + allTrim( Str( nCountLin ) )
            cSqlLin      += ", " + "0"
            cSqlLin      += ", " + quoted( win_uuidcreatestring() )
            cSqlLin      += ", " + quoted( Str( nCount ) ) + " )"

            MovimientosAlmacenLineasModel():ExecuteSqlStatement( cSqlLin, @cStmLin )

            nCountLin++

         end if

         ( listArt )->( dbSkip() )

      end while

      nCountLin := 1

      nCount++

   next

   Msginfo( "Proceso terminado" )

RETURN ( .t. )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

Function loteForCaducidad( cCodArt, cCodAlm )

   local cLote    := ""
   local aStocks  := {}
   local aPuente  := {}
   local hStock

   /*Calculo stocks*/

   aStocks        := StocksModel():aStockArticulo( cCodArt, cCodAlm )

   if !hb_isarray( aStocks ) .or. len( aStocks ) == 0
      Return ( { "lote" => Space(64), "caducidad" => cTod( "" ) } )
   end if

   /*meto caducidad*/

   for each hStock in aStocks

      hSet( hStock, "caducidad", StocksModel():getFechaCaducidad( cCodArt,;
                                                hGet( hStock, "propiedad1" ),;
                                                hGet( hStock, "propiedad2" ),;
                                                hGet( hStock, "valor1" ),;
                                                hGet( hStock, "valor2" ),;
                                                hGet( hStock, "lote" ) ) )      

   next

   /*Quito valores 0*/

   for each hStock in aStocks

      if Round( hGet( hStock, "unidades" ), 6 ) > 0.000000
         aAdd( aPuente, hStock )
      end if

   next

   aStocks  := aPuente

   /*ordeno array*/

   aSort( aStocks, , , {|x,y| hGet( x, "caducidad" ) < hGet( y, "caducidad" ) } )

   if len( aStocks ) >= 1
      RETURN ( { "lote" => hGet( aStocks[1], "lote" ), "caducidad" => hGet( aStocks[1], "caducidad" ) } )
   end if

RETURN ( { "lote" => Space(64), "caducidad" => cTod( "" ) } )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//