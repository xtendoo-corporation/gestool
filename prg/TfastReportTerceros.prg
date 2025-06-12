#include "FiveWin.Ch"
#include "Factu.ch" 
#include "Report.ch"
#include "MesDbf.ch"
// #include "FastRepH.ch"
 
//---------------------------------------------------------------------------//

CLASS TFastreportTerceros FROM TFastReportInfGen 

   METHOD AddMovimientoAlmacen()

   METHOD AddPresupuestoCliente()
      
   METHOD AddPedidoCliente( cCodigoCliente )
         
   METHOD AddSATCliente()

   METHOD AddAlbaranCliente()

   METHOD AddFacturaCliente( cCodigoCliente )

   METHOD AddRectificativaCliente( cCodigoCliente )

   METHOD AddTicket()

   METHOD AddPedidoProveedor()

   METHOD AddAlbaranProveedor()

   METHOD AddFacturaProveedor()

   METHOD AddRectificativaProveedor()

   METHOD setFilterProviderId()        INLINE ( if( ::lApplyFilters,;
      ::cExpresionHeader  += ' .and. ( alltrim( Field->cCodPrv ) >= "' + alltrim( ::oGrupoProveedor:Cargo:Desde ) + '" .and. alltrim( Field->cCodPrv ) <= "' + alltrim( ::oGrupoProveedor:Cargo:Hasta ) + '" )', ) )

END CLASS

//---------------------------------------------------------------------------//

METHOD AddMovimientoAlmacen() CLASS TFastreportTerceros

   local oRowSet
   local cCodigoArticulo

   ::setMeterText( "Procesando movimientos de almacén" )

   oRowSet              := MovimientosAlmacenRepository():getRowSetTotalsForReport( Self )   

   if empty( oRowSet )
      RETURN ( Self )
   end if 

   ::setMeterTotal( oRowSet:reccount() )

   oRowSet:goTop()

   while !(::lBreak ) .and. !( oRowSet:Eof() )

      ::oDbf:Blank()

      ::oDbf:cCodCli    := ''
      ::oDbf:cNomCli    := ''
      ::oDbf:cCodAge    := ''
      ::oDbf:cCodPgo    := ''
      ::oDbf:cCodRut    := ''

      ::oDbf:cTipDoc    := "Movimiento almacen" 
      ::oDbf:cClsDoc    := MOV_ALM
      ::oDbf:cSerDoc    := ""
      ::oDbf:cNumDoc    :=  oRowSet:fieldget( 'numero' )
      ::oDbf:cSufDoc    := ""
      ::oDbf:cIdeDoc    := Upper( ::oDbf:cTipDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc

      ::oDbf:nAnoDoc    := Year( ( D():FacturasClientes( ::nView ) )->dFecFac )
      ::oDbf:nMesDoc    := Month( ( D():FacturasClientes( ::nView ) )->dFecFac )
      ::oDbf:dFecDoc    := ( D():FacturasClientes( ::nView ) )->dFecFac

      ::oDbf:nAnoDoc    := Year( oRowSet:fieldget( 'fecha' ) )
      ::oDbf:nMesDoc    := Month( oRowSet:fieldget( 'fecha' ) )
      ::oDbf:dFecDoc    := oRowSet:fieldget( 'fecha' )
      ::oDbf:cHorDoc    := SubStr( dtoc( oRowSet:fieldget( 'fecha' ) ), 1, 2 )
      ::oDbf:cMinDoc    := SubStr( dtoc( oRowSet:fieldget( 'fecha' ) ), 4, 2 )

      ::oDbf:cCodAlm    := oRowSet:fieldget( 'almacen_destino' )

      ::oDbf:nTotDoc    := oRowSet:fieldget( 'total_precio_venta_iva' )

      ::insertIfValid()

      ::setMeterAutoIncremental()

      oRowSet:skip()

   end while

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddFacturaCliente( cCodigoCliente ) CLASS TFastreportTerceros

   local sTot
   local oError
   local oBlock
   
   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
   
      ( D():FacturasClientes( ::nView ) )->( OrdSetFocus( "dFecFac" ) )
      ( D():FacturasClientesLineas( ::nView ) )->( OrdSetFocus( "nNumFac" ) )

      // filtros para la cabecera----------------------------------------------
   
      ::cExpresionHeader          := 'Field->dFecFac >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecFac <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
      if !empty( ::oGrupoSerie )
         ::cExpresionHeader       += ' .and. ( Field->cSerie >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerie <= "'    + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '" ) '
      end if 
      if !Empty( ::oGrupoSufijo )
         ::cExpresionHeader       += ' .and. ( Field->cSufFac >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufFac <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'
      end if

      ::setFilterClientIdHeader()

      ::setFilterPaymentInvoiceId()

      ::setFilterRouteId()

      ::setFilterAgentId()
      
      ::setFilterAlmacenId()

      // procesando facturas------------------------------------------------
   
      ::setMeterText( "Procesando facturas" )
      
      ( D():FacturasClientes( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():FacturasClientes( ::nView ) )->( dbcustomkeycount() ) )

      ( D():FacturasClientes( ::nView ) )->( dbgotop() )
      while !::lBreak .and. !( D():FacturasClientes( ::nView ) )->( eof() )

         sTot              := sTotFacCli( ( D():FacturasClientes( ::nView ) )->cSerie + Str( ( D():FacturasClientes( ::nView ) )->nNumFac ) + ( D():FacturasClientes( ::nView ) )->cSufFac, D():FacturasClientes( ::nView ), D():FacturasClientesLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ), D():FacturasClientesCobros( ::nView ), D():AnticiposClientes( ::nView ) )

         ::oDbf:Blank()

         ::oDbf:cCodCli    := ( D():FacturasClientes( ::nView ) )->cCodCli
         ::oDbf:cNomCli    := ( D():FacturasClientes( ::nView ) )->cNomCli
         ::oDbf:cCodAge    := ( D():FacturasClientes( ::nView ) )->cCodAge
         ::oDbf:cCodPgo    := ( D():FacturasClientes( ::nView ) )->cCodPago
         ::oDbf:cCodRut    := ( D():FacturasClientes( ::nView ) )->cCodRut
         ::oDbf:cCodUsr    := ( D():FacturasClientes( ::nView ) )->cCodUsr
         ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( ( D():FacturasClientes( ::nView ) )->cCodUsr )
         ::oDbf:cCodObr    := ( D():FacturasClientes( ::nView ) )->cCodObr
         ::oDbf:cCodAlm    := ( D():FacturasClientes( ::nView ) )->cCodAlm

         ::oDbf:nComAge    := ( D():FacturasClientes( ::nView ) )->nPctComAge

         ::oDbf:cCodPos    := ( D():FacturasClientes( ::nView ) )->cPosCli

         ::oDbf:cCodGrp    := RetFld( ( D():FacturasClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod")

         ::oDbf:cTipDoc    := "Factura clientes"
         ::oDbf:cClsDoc    := FAC_CLI          
         ::oDbf:cSerDoc    := ( D():FacturasClientes( ::nView ) )->cSerie
         ::oDbf:cNumDoc    := Str( ( D():FacturasClientes( ::nView ) )->nNumFac )
         ::oDbf:cSufDoc    := ( D():FacturasClientes( ::nView ) )->cSufFac
         ::oDbf:cIdeDoc    := Upper( ::oDbf:cTipDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc

         ::oDbf:nAnoDoc    := Year( ( D():FacturasClientes( ::nView ) )->dFecFac )
         ::oDbf:nMesDoc    := Month( ( D():FacturasClientes( ::nView ) )->dFecFac )
         ::oDbf:dFecDoc    := ( D():FacturasClientes( ::nView ) )->dFecFac
         ::oDbf:cHorDoc    := SubStr( ( D():FacturasClientes( ::nView ) )->cTimCre, 1, 2 )
         ::oDbf:cMinDoc    := SubStr( ( D():FacturasClientes( ::nView ) )->cTimCre, 4, 2 )

         ::oDbf:nTotNet    := sTot:nTotalNeto
         ::oDbf:nTotIva    := sTot:nTotalIva
         ::oDbf:nTotReq    := sTot:nTotalRecargoEquivalencia
         ::oDbf:nTotDoc    := sTot:nTotalDocumento
         ::oDbf:nTotPnt    := sTot:nTotalPuntoVerde
         ::oDbf:nTotTrn    := sTot:nTotalTransporte
         ::oDbf:nTotAge    := sTot:nTotalAgente
         ::oDbf:nTotCos    := sTot:nTotalCosto
         ::oDbf:nTotIvm    := sTot:nTotalImpuestoHidrocarburos
         ::oDbf:nTotRnt    := sTot:nTotalRentabilidad
         ::oDbf:nTotRet    := sTot:nTotalRetencion
         ::oDbf:nTotCob    := sTot:nTotalCobrado
         ::oDbf:nDtoLin    := sTot:nTotalDtoLineal

         ::oDbf:cSrlTot    := sTot:saveToText()
         
         ::oDbf:nRieCli    := RetFld( ( D():FacturasClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ) , "Riesgo", "Cod" )
         ::oDbf:cDniCli    := RetFld( ( D():FacturasClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

         ::oDbf:cEstado    := cChkPagFacCli( ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc, D():FacturasClientes( ::nView ), D():FacturasClientesCobros( ::nView ) )

         /*
         A�adimos un nuevo registro--------------------------------------------
         */

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ::loadValuesExtraFields()

         ( D():FacturasClientes( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while
   
   RECOVER USING oError
   
      msgStop( ErrorMessage( oError ), "Imposible añadir facturas de clientes" )
   
   END SEQUENCE

   ErrorBlock( oBlock )
   
RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddRectificativaCliente( cCodigoCliente ) CLASS TFastreportTerceros

   local sTot
   local oError
   local oBlock
   
   oBlock                        := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
   
      ( D():FacturasRectificativas( ::nView ) )->( OrdSetFocus( "dFecFac" ) )
      ( D():FacturasRectificativasLineas( ::nView ) )->( OrdSetFocus( "nNumFac" ) )

      // filtros para la cabecera------------------------------------------------
   
      ::cExpresionHeader          := '( Field->dFecFac >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecFac <= Ctod( "' + Dtoc( ::dFinInf ) + '" ) )'
      ::cExpresionHeader          += ' .and. ( Field->cSerie >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerie <= "'    + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '" )'
      ::cExpresionHeader          += ' .and. ( Field->cSufFac >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufFac <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'
      
      ::setFilterClientIdHeader()

      ::setFilterPaymentInvoiceId()

      ::setFilterRouteId()

      ::setFilterAgentId()
      
      ::setFilterAlmacenId()

      // Procesando facturas recitificativas-------------------------------------

      ::setMeterText( "Procesando facturas rectificativas" )

      ( D():FacturasRectificativas( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():FacturasRectificativas( ::nView ) )->( dbcustomkeycount() ) )

      ( D():FacturasRectificativas( ::nView ) )->( dbgotop() )

      while !::lBreak .and. !( D():FacturasRectificativas( ::nView ) )->( Eof() )

         sTot              := sTotFacRec( ( D():FacturasRectificativas( ::nView ) )->cSerie + Str( ( D():FacturasRectificativas( ::nView ) )->nNumFac ) + ( D():FacturasRectificativas( ::nView ) )->cSufFac, D():FacturasRectificativas( ::nView ), D():FacturasRectificativasLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ), D():FacturasClientesCobros( ::nView ) )

         ::oDbf:Blank()

         ::oDbf:cClsDoc    := FAC_REC
         ::oDbf:cTipDoc    := "Factura rectificativa"
         ::oDbf:cSerDoc    := ( D():FacturasRectificativas( ::nView ) )->cSerie
         ::oDbf:cNumDoc    := Str( ( D():FacturasRectificativas( ::nView ) )->nNumFac )
         ::oDbf:cSufDoc    := ( D():FacturasRectificativas( ::nView ) )->cSufFac
         ::oDbf:cIdeDoc    := Upper( ::oDbf:cTipDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc

         ::oDbf:cCodCli    := ( D():FacturasRectificativas( ::nView ) )->cCodCli            
         ::oDbf:cNomCli    := ( D():FacturasRectificativas( ::nView ) )->cNomCli
         ::oDbf:cCodAge    := ( D():FacturasRectificativas( ::nView ) )->cCodAge
         ::oDbf:cCodPgo    := ( D():FacturasRectificativas( ::nView ) )->cCodPago
         ::oDbf:cCodRut    := ( D():FacturasRectificativas( ::nView ) )->cCodRut
         ::oDbf:cCodUsr    := ( D():FacturasRectificativas( ::nView ) )->cCodUsr
         ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( ( D():FacturasRectificativas( ::nView ) )->cCodUsr )
         ::oDbf:cCodObr    := ( D():FacturasRectificativas( ::nView ) )->cCodObr
         ::oDbf:cCodAlm    := ( D():FacturasRectificativas( ::nView ) )->cCodAlm

         ::oDbf:nComAge    := ( D():FacturasRectificativas( ::nView ) )->nPctComAge

         ::oDbf:cCodPos    := ( D():FacturasRectificativas( ::nView ) )->cPosCli

         ::oDbf:cCodGrp    := RetFld( ( D():FacturasRectificativas( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod")


         ::oDbf:nAnoDoc    := Year( ( D():FacturasRectificativas( ::nView ) )->dFecFac )
         ::oDbf:nMesDoc    := Month( ( D():FacturasRectificativas( ::nView ) )->dFecFac )
         ::oDbf:dFecDoc    := ( D():FacturasRectificativas( ::nView ) )->dFecFac
         ::oDbf:cHorDoc    := SubStr( ( D():FacturasRectificativas( ::nView ) )->cTimCre, 1, 2 )
         ::oDbf:cMinDoc    := SubStr( ( D():FacturasRectificativas( ::nView ) )->cTimCre, 4, 2 )

         ::oDbf:nTotNet    := sTot:nTotalNeto
         ::oDbf:nTotIva    := sTot:nTotalIva
         ::oDbf:nTotReq    := sTot:nTotalRecargoEquivalencia
         ::oDbf:nTotDoc    := sTot:nTotalDocumento
         ::oDbf:nTotPnt    := sTot:nTotalPuntoVerde
         ::oDbf:nTotTrn    := sTot:nTotalTransporte
         ::oDbf:nTotAge    := sTot:nTotalAgente
         ::oDbf:nTotCos    := sTot:nTotalCosto
         ::oDbf:nTotIvm    := sTot:nTotalImpuestoHidrocarburos
         ::oDbf:nTotRnt    := sTot:nTotalRentabilidad
         ::oDbf:nTotRet    := sTot:nTotalRetencion
         ::oDbf:nTotCob    := sTot:nTotalCobrado

         ::oDbf:cSrlTot    := sTot:saveToText()

         ::oDbf:nRieCli    := RetFld( ( D():FacturasRectificativas( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
         ::oDbf:cDniCli    := RetFld( ( D():FacturasRectificativas( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

         ::oDbf:cEstado    := cChkPagFacRec( ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc, D():FacturasRectificativas( ::nView ), D():FacturasClientesCobros( ::nView ) )

         // A�adimos un nuevo registro--------------------------------------------

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ::addFacturasRectificativasClientes()

         ( D():FacturasRectificativas( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while
   
   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir facturas rectificativa" )

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddTicket() CLASS TFastreportTerceros

   local sTot
   local oError
   local oBlock

   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
   
      ( D():TiketsClientes( ::nView ) )->( OrdSetFocus( "dFecTik" ) )
      ( D():TiketsLineas( ::nView ) )->( OrdSetFocus( "cNumTik" ) )
   
      // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := '( Field->dFecTik >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecTik <= Ctod( "' + Dtoc( ::dFinInf ) + '" ) )'
      ::cExpresionHeader          += ' .and. ( Rtrim( cCliTik ) >= "' + Rtrim( ::oGrupoCliente:Cargo:Desde )   + '" .and. Rtrim( cCliTik ) <= "' + Rtrim( ::oGrupoCliente:Cargo:Hasta ) + '")'
      ::cExpresionHeader          += ' .and. ( Field->cSerTik >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerTik <= "'    + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '" )'
      ::cExpresionHeader          += ' .and. ( Field->cSufTik >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufTik <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'
     
      ::setFilterRouteId()

      ::setFilterAgentId()

      ::setFilterAlmacenTicketId()
      
      // filtros para la cabecera------------------------------------------------
   
      ::setMeterText( "Procesando tickets" )
      
      ( D():TiketsClientes( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) ) 

      ::setMeterTotal( ( D():TiketsClientes( ::nView ) )->( dbcustomkeycount() ) )

      ( D():TiketsClientes( ::nView ) )->( dbgotop() )

      while !::lBreak .and. !( D():TiketsClientes( ::nView ) )->( eof() )

         sTot              := sTotTikCli( ( D():TiketsClientes( ::nView ) )->cSerTik + ( D():TiketsClientes( ::nView ) )->cNumTik + ( D():TiketsClientes( ::nView ) )->cSufTik, D():TiketsClientes( ::nView ), D():TiketsLineas( ::nView ), D():Divisas( ::nView ) )

         ::oDbf:Blank()

         ::oDbf:cCodCli    := ( D():TiketsClientes( ::nView ) )->cCliTik
         ::oDbf:cNomCli    := ( D():TiketsClientes( ::nView ) )->cNomTik
         ::oDbf:cCodAge    := ( D():TiketsClientes( ::nView ) )->cCodAge
         ::oDbf:cCodPgo    := ( D():TiketsClientes( ::nView ) )->cFpgTik
         ::oDbf:cCodRut    := ( D():TiketsClientes( ::nView ) )->cCodRut
         ::oDbf:cCodUsr    := ( D():TiketsClientes( ::nView ) )->cCcjTik
         ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( ( D():TiketsClientes( ::nView ) )->cCcjTik )
         ::oDbf:cCodObr    := ( D():TiketsClientes( ::nView ) )->cCodObr
         ::oDbf:cCodAlm    := ( D():TiketsClientes( ::nView ) )->cAlmTik

         ::oDbf:cCodPos    := ( D():TiketsClientes( ::nView ) )->cPosCli

         ::oDbf:cCodGrp    := RetFld( ( D():TiketsClientes( ::nView ) )->cCliTik, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod" )

         ::oDbf:cTipDoc    := "Simplificada"
         ::oDbf:cClsDoc    := TIK_CLI          
         ::oDbf:cSerDoc    := ( D():TiketsClientes( ::nView ) )->cSerTik
         ::oDbf:cNumDoc    := ( D():TiketsClientes( ::nView ) )->cNumTik
         ::oDbf:cSufDoc    := ( D():TiketsClientes( ::nView ) )->cSufTik
         ::oDbf:cIdeDoc    := Upper( ::oDbf:cTipDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc
         
         ::oDbf:nAnoDoc    := Year( ( D():TiketsClientes( ::nView ) )->dFecTik )
         ::oDbf:nMesDoc    := Month( ( D():TiketsClientes( ::nView ) )->dFecTik )
         ::oDbf:dFecDoc    := ( D():TiketsClientes( ::nView ) )->dFecTik
         ::oDbf:cHorDoc    := SubStr( ( D():TiketsClientes( ::nView ) )->cTimCre, 1, 2 )
         ::oDbf:cMinDoc    := SubStr( ( D():TiketsClientes( ::nView ) )->cTimCre, 4, 2 )

         ::oDbf:nTotNet    := sTot:nTotalNeto
         ::oDbf:nTotIva    := sTot:nTotalIva
         ::oDbf:nTotDoc    := sTot:nTotalDocumento
         ::oDbf:nTotAge    := sTot:nTotalAgente
         ::oDbf:nTotCos    := sTot:nTotalCosto
         ::oDbf:nTotIvm    := sTot:nTotalImpuestoHidrocarburos
         ::oDbf:nTotRnt    := sTot:nTotalRentabilidad
         ::oDbf:nTotCob    := sTot:nTotalCobrado

         ::oDbf:cSrlTot    := sTot:saveToText()

         ::oDbf:nRieCli    := RetFld( ( D():TiketsClientes( ::nView ) )->cCliTik, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
         ::oDbf:cDniCli    := RetFld( ( D():TiketsClientes( ::nView ) )->cCliTik, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

         /*
         A�adimos un nuevo registro--------------------------------------------
         */

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ::addTicketsClientes()
         
         ( D():TiketsClientes( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while
   
   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir facturas de clientes" )

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddSATCliente( cCodigoCliente ) CLASS TFastreportTerceros

   local sTot
   local oError
   local oBlock
   
   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
   
      ( D():SatClientes( ::nView ) )->( OrdSetFocus( "cCodCli" ) )
      
      // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := 'Field->dFecSat >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecSat <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
      ::cExpresionHeader          += ' .and. Field->cSerSat >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerSat <= "'    + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '"'
      ::cExpresionHeader          += ' .and. Field->cSufSat >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufSat <= "'    + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '"'

      ::setFilterClientIdHeader()

      ::setFilterPaymentId()

      ::setFilterRouteId()

      ::setFilterAgentId()

      ::setFilterAlmacenId()

      // Procesando SAT----------------------------------------------------------

      ::setMeterText( "Procesando SAT" )

      ( D():SatClientes( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():SatClientes( ::nView ) )->( dbcustomkeycount() ) )

      ( D():SatClientes( ::nView ) )->( dbgotop() )

      while !::lBreak .and. !( D():SatClientes( ::nView ) )->( Eof() )

         sTot              := sTotSatCli( ( D():SatClientes( ::nView ) )->cSerSat + Str( ( D():SatClientes( ::nView ) )->nNumSat ) + ( D():SatClientes( ::nView ) )->cSufSat, D():SatClientes( ::nView ), D():SatClientesLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ) )

         ::oDbf:Blank()

         ::oDbf:cCodCli    := ( D():SatClientes( ::nView ) )->cCodCli
         ::oDbf:cNomCli    := ( D():SatClientes( ::nView ) )->cNomCli
         ::oDbf:cCodAge    := ( D():SatClientes( ::nView ) )->cCodAge
         ::oDbf:cCodPgo    := ( D():SatClientes( ::nView ) )->cCodPgo
         ::oDbf:cCodRut    := ( D():SatClientes( ::nView ) )->cCodRut
         ::oDbf:cCodUsr    := ( D():SatClientes( ::nView ) )->cCodUsr
         ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( ( D():SatClientes( ::nView ) )->cCodUsr )
         ::oDbf:cCodObr    := ( D():SatClientes( ::nView ) )->cCodObr
         ::oDbf:cCodAlm    := ( D():SatClientes( ::nView ) )->cCodAlm

         ::oDbf:nComAge    := ( D():SatClientes( ::nView ) )->nPctComAge

         ::oDbf:cCodPos    := ( D():SatClientes( ::nView ) )->cPosCli

         ::oDbf:cCodGrp    := RetFld( ( D():SatClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod" )

         ::oDbf:cTipDoc    := "SAT clientes"
         ::oDbf:cClsDoc    := SAT_CLI
         ::oDbf:cSerDoc    := ( D():SatClientes( ::nView ) )->cSerSat
         ::oDbf:cNumDoc    := Str( ( D():SatClientes( ::nView ) )->nNumSat )
         ::oDbf:cSufDoc    := ( D():SatClientes( ::nView ) )->cSufSat

         ::oDbf:cIdeDoc    :=  ::idDocumento()            

         ::oDbf:nAnoDoc    := Year( ( D():SatClientes( ::nView ) )->dFecSat )
         ::oDbf:nMesDoc    := Month( ( D():SatClientes( ::nView ) )->dFecSat )
         ::oDbf:dFecDoc    := ( D():SatClientes( ::nView ) )->dFecSat
         ::oDbf:cHorDoc    := SubStr( ( D():SatClientes( ::nView ) )->cTimCre, 1, 2 )
         ::oDbf:cMinDoc    := SubStr( ( D():SatClientes( ::nView ) )->cTimCre, 4, 2 )

         ::oDbf:nTotNet    := sTot:nTotalNeto
         ::oDbf:nTotIva    := sTot:nTotalIva
         ::oDbf:nTotReq    := sTot:nTotalRecargoEquivalencia
         ::oDbf:nTotDoc    := sTot:nTotalDocumento
         ::oDbf:nTotPnt    := sTot:nTotalPuntoVerde
         ::oDbf:nTotTrn    := sTot:nTotalTransporte
         ::oDbf:nTotAge    := sTot:nTotalAgente
         ::oDbf:nTotCos    := sTot:nTotalCosto
         ::oDbf:nTotIvm    := sTot:nTotalImpuestoHidrocarburos
         ::oDbf:nTotRnt    := sTot:nTotalRentabilidad
         ::oDbf:nTotRet    := sTot:nTotalRetencion
         ::oDbf:nTotCob    := sTot:nTotalCobrado

         ::oDbf:nRieCli    := RetFld( ( D():SatClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
         ::oDbf:cDniCli    := RetFld( ( D():SatClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

         if ( D():SatClientes( ::nView ) )->lEstado
            ::oDbf:cEstado := "Pendiente"
         else
            ::oDbf:cEstado := "Finalizado"
         end if

         /*
         A�adimos un nuevo registro--------------------------------------------
         */

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ::addSATClientes()

         ( D():SatClientes( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while

   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir SAT de clientes" )

   END SEQUENCE

   ErrorBlock( oBlock )
   
RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddPresupuestoCliente( cCodigoCliente ) CLASS TFastreportTerceros

   local sTot
   local oError
   local oBlock
   
   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
   
      ( D():PresupuestosClientesLineas( ::nView ) )->( OrdSetFocus( "nNumPre" ) )

   // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := 'Field->dFecPre >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecPre <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
      ::cExpresionHeader          += ' .and. Field->cSerPre >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerPre <= "'    + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '"'
      ::cExpresionHeader          += ' .and. Field->cSufPre >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufPre <= "'    + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '"'

      ::setFilterClientIdHeader()

      ::setFilterPaymentId()

      ::setFilterRouteId()

      ::setFilterAgentId()
      
      ::setFilterAlmacenId()

      // procesando presupuestos-------------------------------------------------

      ::setMeterText( "Procesando presupuestos" )

      ( D():PresupuestosClientes( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():PresupuestosClientes( ::nView ) )->( dbcustomkeycount() ) )

      ( D():PresupuestosClientes( ::nView ) )->( dbgotop() )

      while !::lBreak .and. !( D():PresupuestosClientes( ::nView ) )->( eof() )

         sTot              := sTotPreCli( ( D():PresupuestosClientes( ::nView ) )->cSerPre + Str( ( D():PresupuestosClientes( ::nView ) )->nNumPre ) + ( D():PresupuestosClientes( ::nView ) )->cSufPre, D():PresupuestosClientes( ::nView ), D():PresupuestosClientesLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ) )

         ::oDbf:Blank()

         ::oDbf:cCodCli    := ( D():PresupuestosClientes( ::nView ) )->cCodCli
         ::oDbf:cNomCli    := ( D():PresupuestosClientes( ::nView ) )->cNomCli
         ::oDbf:cCodAge    := ( D():PresupuestosClientes( ::nView ) )->cCodAge
         ::oDbf:cCodPgo    := ( D():PresupuestosClientes( ::nView ) )->cCodPgo
         ::oDbf:cCodRut    := ( D():PresupuestosClientes( ::nView ) )->cCodRut
         ::oDbf:cCodUsr    := ( D():PresupuestosClientes( ::nView ) )->cCodUsr
         ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( ( D():PresupuestosClientes( ::nView ) )->cCodUsr )
         ::oDbf:cCodObr    := ( D():PresupuestosClientes( ::nView ) )->cCodObr
         ::oDbf:cCodAlm    := ( D():PresupuestosClientes( ::nView ) )->cCodAlm

         ::oDbf:nComAge    := ( D():PresupuestosClientes( ::nView ) )->nPctComAge

         ::oDbf:cCodPos    := ( D():PresupuestosClientes( ::nView ) )->cPosCli

         ::oDbf:cCodGrp    := RetFld( ( D():PresupuestosClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod")

         ::oDbf:cTipDoc    := "Presupuesto clientes"
         ::oDbf:cClsDoc    := PRE_CLI
         ::oDbf:cSerDoc    := ( D():PresupuestosClientes( ::nView ) )->cSerPre
         ::oDbf:cNumDoc    := Str( ( D():PresupuestosClientes( ::nView ) )->nNumPre )
         ::oDbf:cSufDoc    := ( D():PresupuestosClientes( ::nView ) )->cSufPre

         ::oDbf:cIdeDoc    :=  ::idDocumento()

         ::oDbf:nAnoDoc    := Year( ( D():PresupuestosClientes( ::nView ) )->dFecPre )
         ::oDbf:nMesDoc    := Month( ( D():PresupuestosClientes( ::nView ) )->dFecPre )
         ::oDbf:dFecDoc    := ( D():PresupuestosClientes( ::nView ) )->dFecPre
         ::oDbf:cHorDoc    := SubStr( ( D():PresupuestosClientes( ::nView ) )->cTimCre, 1, 2 )
         ::oDbf:cMinDoc    := SubStr( ( D():PresupuestosClientes( ::nView ) )->cTimCre, 4, 2 )

         ::oDbf:nTotNet    := sTot:nTotalNeto
         ::oDbf:nTotIva    := sTot:nTotalIva
         ::oDbf:nTotReq    := sTot:nTotalRecargoEquivalencia
         ::oDbf:nTotDoc    := sTot:nTotalDocumento
         ::oDbf:nTotPnt    := sTot:nTotalPuntoVerde
         ::oDbf:nTotTrn    := sTot:nTotalTransporte
         ::oDbf:nTotAge    := sTot:nTotalAgente
         ::oDbf:nTotCos    := sTot:nTotalCosto
         ::oDbf:nTotIvm    := sTot:nTotalImpuestoHidrocarburos
         ::oDbf:nTotRnt    := sTot:nTotalRentabilidad
         ::oDbf:nTotRet    := sTot:nTotalRetencion
         ::oDbf:nTotCob    := sTot:nTotalCobrado

         ::oDbf:nRieCli    := RetFld( ( D():PresupuestosClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
         ::oDbf:cDniCli    := RetFld( ( D():PresupuestosClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

         if ( D():PresupuestosClientes( ::nView ) )->lEstado
            ::oDbf:cEstado    := "Pendiente"
         else
            ::oDbf:cEstado    := "Finalizado"
         end if

         /*
         A�adimos un nuevo registro--------------------------------------------
         */

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ::addPresupuestosClientes()

         ( D():PresupuestosClientes( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while

  RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir presupuestos de clientes" )

   END SEQUENCE

   ErrorBlock( oBlock )
   
RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddPedidoCliente( cCodigoCliente ) CLASS TFastreportTerceros

   local sTot
   local oError
   local oBlock
   
   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
   
      ( D():PedidosClientes( ::nView ) )->( OrdSetFocus( "dFecPed" ) )
      ( D():PedidosClientesLineas( ::nView ) )->( OrdSetFocus( "nNumPed" ) )

   // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := 'Field->dFecPed >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecPed <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
      ::cExpresionHeader          += ' .and. Field->cSerPed >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerPed <= "'    + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '"'
      ::cExpresionHeader          += ' .and. Field->cSufPed >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufPed <= "'    + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '"'
      
      ::setFilterClientIdHeader()

      ::setFilterPaymentId()

      ::setFilterRouteId()

      ::setFilterAgentId()
      
      ::setFilterAlmacenId()

   // Procesando pedidos------------------------------------------------
   
      ::setMeterText( "Procesando pedidos" )

      ( D():PedidosClientes( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():PedidosClientes( ::nView ) )->( dbcustomkeycount() ) )
      
      ( D():PedidosClientes( ::nView ) )->( dbgotop() )

      while !::lBreak .and. !( D():PedidosClientes( ::nView ) )->( Eof() )

         sTot              := sTotPedCli( ( D():PedidosClientes( ::nView ) )->cSerPed + Str( ( D():PedidosClientes( ::nView ) )->nNumPed ) + ( D():PedidosClientes( ::nView ) )->cSufPed, D():PedidosClientes( ::nView ), D():PedidosClientesLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ) )

         ::oDbf:Blank()

         ::oDbf:cCodCli    := ( D():PedidosClientes( ::nView ) )->cCodCli
         ::oDbf:cNomCli    := ( D():PedidosClientes( ::nView ) )->cNomCli
         ::oDbf:cCodAge    := ( D():PedidosClientes( ::nView ) )->cCodAge
         ::oDbf:cCodPgo    := ( D():PedidosClientes( ::nView ) )->cCodPgo
         ::oDbf:cCodRut    := ( D():PedidosClientes( ::nView ) )->cCodRut
         ::oDbf:cCodObr    := ( D():PedidosClientes( ::nView ) )->cCodObr
         ::oDbf:cCodAlm    := ( D():PedidosClientes( ::nView ) )->cCodAlm

         ::oDbf:nComAge    := ( D():PedidosClientes( ::nView ) )->nPctComAge

         ::oDbf:cCodPos    := ( D():PedidosClientes( ::nView ) )->cPosCli

         ::oDbf:cCodGrp    := RetFld( ( D():PedidosClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod" )

         ::oDbf:cTipDoc    := "Pedidos clientes"
         ::oDbf:cClsDoc    := PED_CLI
         ::oDbf:cSerDoc    := ( D():PedidosClientes( ::nView ) )->cSerPed
         ::oDbf:cNumDoc    := Str( ( D():PedidosClientes( ::nView ) )->nNumPed )
         ::oDbf:cSufDoc    := ( D():PedidosClientes( ::nView ) )->cSufPed
         ::oDbf:cIdeDoc    := Upper( ::oDbf:cTipDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc

         ::oDbf:nAnoDoc    := Year( ( D():PedidosClientes( ::nView ) )->dFecPed )
         ::oDbf:nMesDoc    := Month( ( D():PedidosClientes( ::nView ) )->dFecPed )
         ::oDbf:dFecDoc    := ( D():PedidosClientes( ::nView ) )->dFecPed
         ::oDbf:cHorDoc    := SubStr( ( D():PedidosClientes( ::nView ) )->cTimCre, 1, 2 )
         ::oDbf:cMinDoc    := SubStr( ( D():PedidosClientes( ::nView ) )->cTimCre, 4, 2 )

         ::oDbf:nTotNet    := sTot:nTotalNeto
         ::oDbf:nTotIva    := sTot:nTotalIva
         ::oDbf:nTotReq    := sTot:nTotalRecargoEquivalencia
         ::oDbf:nTotDoc    := sTot:nTotalDocumento
         ::oDbf:nTotPnt    := sTot:nTotalPuntoVerde
         ::oDbf:nTotTrn    := sTot:nTotalTransporte
         ::oDbf:nTotAge    := sTot:nTotalAgente
         ::oDbf:nTotCos    := sTot:nTotalCosto
         ::oDbf:nTotIvm    := sTot:nTotalImpuestoHidrocarburos
         ::oDbf:nTotRnt    := sTot:nTotalRentabilidad
         ::oDbf:nTotRet    := sTot:nTotalRetencion
         ::oDbf:nTotCob    := sTot:nTotalCobrado

         ::oDbf:nRieCli    := RetFld( ( D():PedidosClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
         ::oDbf:cDniCli    := RetFld( ( D():PedidosClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

         do case
            case ( D():PedidosClientes( ::nView ) )->nEstado <= 1
               ::oDbf:cEstado    := "Pendiente"

            case ( D():PedidosClientes( ::nView ) )->nEstado == 2
               ::oDbf:cEstado    := "Parcialmente"

            case ( D():PedidosClientes( ::nView ) )->nEstado == 3
               ::oDbf:cEstado    := "Finalizado"

         end case

         /*
         A�adimos un nuevo registro--------------------------------------------
         */

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ::addPedidosClientes()

     
         ( D():PedidosClientes( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while
   
   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir pedidos de clientes" )

   END SEQUENCE

   ErrorBlock( oBlock )
   
RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddAlbaranCliente( lNoFacturados ) CLASS TFastreportTerceros

   local sTot
   local oError
   local oBlock
   
   DEFAULT lNoFacturados   := .f.

   oBlock                  := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
   
      ( D():AlbaranesClientes( ::nView ) )->( OrdSetFocus( "dFecAlb" ) )
      ( D():AlbaranesClientesLineas( ::nView ) )->( OrdSetFocus( "nNumAlb" ) )

      // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader       := '( Field->dFecAlb >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecAlb <= Ctod( "' + Dtoc( ::dFinInf ) + '" ) )'
      
      if lNoFacturados
         ::cExpresionHeader    += ' .and. ( nFacturado < 3 ) ' 
      end if

      ::cExpresionHeader       += ' .and. ( Field->cSerAlb >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerAlb <= "' + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '" ) '
      ::cExpresionHeader       += ' .and. ( Field->cSufAlb >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufAlb <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'

      ::setFilterClientIdHeader()

      ::setFilterPaymentInvoiceId()

      ::setFilterRouteId()

      ::setFilterAgentId()
      
      ::setFilterAlmacenId()

      // Procesando albaranes-----------------------------------------------------

      ::setMeterText( "Procesando albaranes" )
      
      ( D():AlbaranesClientes( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():AlbaranesClientes( ::nView ) )->( dbcustomkeycount() ) )

      ( D():AlbaranesClientes( ::nView ) )->( dbgotop() )
      while !::lBreak .and. !( D():AlbaranesClientes( ::nView ) )->( Eof() )

         sTot              := sTotAlbCli( ( D():AlbaranesClientes( ::nView ) )->cSerAlb + Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb ) + ( D():AlbaranesClientes( ::nView ) )->cSufAlb, D():AlbaranesClientes( ::nView ), D():AlbaranesClientesLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ) )

         ::oDbf:Blank()

         ::oDbf:cCodCli    := ( D():AlbaranesClientes( ::nView ) )->cCodCli
         ::oDbf:cNomCli    := ( D():AlbaranesClientes( ::nView ) )->cNomCli
         ::oDbf:cCodAge    := ( D():AlbaranesClientes( ::nView ) )->cCodAge
         ::oDbf:cCodPgo    := ( D():AlbaranesClientes( ::nView ) )->cCodPago
         ::oDbf:cCodRut    := ( D():AlbaranesClientes( ::nView ) )->cCodRut
         ::oDbf:cCodObr    := ( D():AlbaranesClientes( ::nView ) )->cCodObr
         ::oDbf:cCodAlm    := ( D():AlbaranesClientes( ::nView ) )->cCodAlm
         
         ::oDbf:cCodUsr    := ( D():AlbaranesClientes( ::nView ) )->cCodUsr
         ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( ( D():AlbaranesClientes( ::nView ) )->cCodUsr )

         ::oDbf:nComAge    := ( D():AlbaranesClientes( ::nView ) )->nPctComAge

         ::oDbf:cCodPos    := ( D():AlbaranesClientes( ::nView ) )->cPosCli

         ::oDbf:cCodGrp    := RetFld( ( D():AlbaranesClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod" )

         ::oDbf:cTipDoc    := "Albaranes clientes"
         ::oDbf:cClsDoc    := ALB_CLI
         ::oDbf:cSerDoc    := ( D():AlbaranesClientes( ::nView ) )->cSerAlb
         ::oDbf:cNumDoc    := Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb )
         ::oDbf:cSufDoc    := ( D():AlbaranesClientes( ::nView ) )->cSufAlb
         ::oDbf:cIdeDoc    := Upper( ::oDbf:cTipDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc

         ::oDbf:nAnoDoc    := Year( ( D():AlbaranesClientes( ::nView ) )->dFecAlb )
         ::oDbf:nMesDoc    := Month( ( D():AlbaranesClientes( ::nView ) )->dFecAlb )
         ::oDbf:dFecDoc    := ( D():AlbaranesClientes( ::nView ) )->dFecAlb
         ::oDbf:cHorDoc    := SubStr( ( D():AlbaranesClientes( ::nView ) )->cTimCre, 1, 2 )
         ::oDbf:cMinDoc    := SubStr( ( D():AlbaranesClientes( ::nView ) )->cTimCre, 4, 2 )

         ::oDbf:nTotNet    := sTot:nTotalNeto
         ::oDbf:nTotIva    := sTot:nTotalIva
         ::oDbf:nTotReq    := sTot:nTotalRecargoEquivalencia
         ::oDbf:nTotDoc    := sTot:nTotalDocumento
         ::oDbf:nTotPnt    := sTot:nTotalPuntoVerde
         ::oDbf:nTotTrn    := sTot:nTotalTransporte
         ::oDbf:nTotAge    := sTot:nTotalAgente
         ::oDbf:nTotCos    := sTot:nTotalCosto
         ::oDbf:nTotIvm    := sTot:nTotalImpuestoHidrocarburos
         ::oDbf:nTotRnt    := sTot:nTotalRentabilidad
         ::oDbf:nTotRet    := sTot:nTotalRetencion
         ::oDbf:nTotCob    := sTot:nTotalCobrado

         ::oDbf:nRieCli    := RetFld( ( D():AlbaranesClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
         ::oDbf:cDniCli    := RetFld( ( D():AlbaranesClientes( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

         do case
            case ( D():AlbaranesClientes( ::nView ) )->nFacturado <= 1
               ::oDbf:cEstado    := "Pendiente"

            case ( D():AlbaranesClientes( ::nView ) )->nFacturado == 2
               ::oDbf:cEstado    := "Parcialmente"

            case ( D():AlbaranesClientes( ::nView ) )->nFacturado == 3
               ::oDbf:cEstado    := "Finalizado"

         end case

         /*
         A�adimos un nuevo registro--------------------------------------------
         */

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ::addAlbaranesClientes()

         ( D():AlbaranesClientes( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while
   
   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir albaranes de clientes" )

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddPedidoProveedor( cCodigoProveedor ) CLASS TFastreportTerceros

   local sTot

   ( D():PedidosProveedores( ::nView ) )->( OrdSetFocus( "dFecPed" ) )
   ( D():PedidosProveedoresLineas( ::nView ) )->( OrdSetFocus( "nNumPed" ) )

   // filtros para la cabecera------------------------------------------------

   ::cExpresionHeader                := 'Field->dFecPed >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecPed <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
   
   ::setFilterPaymentId()
   
   ::setFilterProviderId()

   // Procesando pedidos------------------------------------------------------

   ::setMeterText( "Procesando pedidos" )

   ( D():PedidosProveedores( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

   ::setMeterTotal( ( D():PedidosProveedores( ::nView ) )->( dbcustomkeycount() ) )

   ( D():PedidosProveedores( ::nView ) )->( dbgotop() )
   while !::lBreak .and. !( D():PedidosProveedores( ::nView ) )->( Eof() )

      sTot              := sTotPedPrv( ( D():PedidosProveedores( ::nView ) )->cSerPed + Str( ( D():PedidosProveedores( ::nView ) )->nNumPed ) + ( D():PedidosProveedores( ::nView ) )->cSufPed, D():PedidosProveedores( ::nView ), D():PedidosProveedoresLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ) )

      ::oDbf:Blank()

      ::oDbf:cTipDoc    := "Pedido proveedor"
      ::oDbf:cClsDoc    := PED_PRV

      ::oDbf:cSerDoc    := ( D():PedidosProveedores( ::nView ) )->cSerPed
      ::oDbf:cNumDoc    := Str( ( D():PedidosProveedores( ::nView ) )->nNumPed )
      ::oDbf:cSufDoc    := ( D():PedidosProveedores( ::nView ) )->cSufPed

      ::oDbf:cIdeDoc    := ::idDocumento()            

      ::oDbf:cCodPrv    := ( D():PedidosProveedores( ::nView ) )->cCodPrv
      ::oDbf:cNomPrv    := ( D():PedidosProveedores( ::nView ) )->cNomPrv
      ::oDbf:cCodGrp    := RetFld( ( D():PedidosProveedores( ::nView ) )->cCodPrv, D():Proveedores( ::nView ), "cCodGrp" )
      ::oDbf:cCodPgo    := ( D():PedidosProveedores( ::nView ) )->cCodPgo

      ::oDbf:nAnoDoc    := Year( ( D():PedidosProveedores( ::nView ) )->dFecPed )
      ::oDbf:nMesDoc    := Month( ( D():PedidosProveedores( ::nView ) )->dFecPed )
      ::oDbf:dFecDoc    := ( D():PedidosProveedores( ::nView ) )->dFecPed
      ::oDbf:cHorDoc    := SubStr( ( D():PedidosProveedores( ::nView ) )->cTimChg, 1, 2 )
      ::oDbf:cMinDoc    := SubStr( ( D():PedidosProveedores( ::nView ) )->cTimChg, 3, 2 )

      ::oDbf:nTotNet    := sTot:nTotalNeto
      ::oDbf:nTotIva    := sTot:nTotalIva
      ::oDbf:nTotReq    := sTot:nTotalRecargoEquivalencia
      ::oDbf:nTotDoc    := sTot:nTotalDocumento

      if ::lValidRegister()
         ::oDbf:Insert()
      else
         ::oDbf:Cancel()
      end if

      ::addPedidosProveedores()

      ( D():PedidosProveedores( ::nView ) )->( dbskip() )

      ::setMeterAutoIncremental()

   end while

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddAlbaranProveedor( lFacturados ) CLASS TFastreportTerceros

   local sTot

   DEFAULT lFacturados           := .f.

   ( D():AlbaranesProveedores( ::nView ) )->( OrdSetFocus( "dFecAlb" ) )
   ( D():AlbaranesProveedoresLineas( ::nView ) )->( OrdSetFocus( "nNumAlb" ) )

   // filtros para la cabecera------------------------------------------------

   if lFacturados
      ::cExpresionHeader          := '!lFacturado .and. Field->dFecAlb >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecAlb <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
   else
      ::cExpresionHeader          := 'Field->dFecAlb >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecAlb <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
   end if

   ::setFilterPaymentId()
   
   ::setFilterProviderId()

   // Procesando albaranes----------------------------------------------------

   ::setMeterText( "Procesando albaranes" )
   
   ( D():AlbaranesProveedores( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

   ::setMeterTotal( ( D():AlbaranesProveedores( ::nView ) )->( dbcustomkeycount() ) )

   ( D():AlbaranesProveedores( ::nView ) )->( dbgotop() )

   while !::lBreak .and. !( D():AlbaranesProveedores( ::nView ) )->( eof() )

      sTot           := sTotAlbPrv( D():AlbaranesProveedoresId( ::nView ), D():AlbaranesProveedores( ::nView ), D():AlbaranesProveedoresLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ) )
     
      ::oDbf:Blank()

      ::oDbf:cTipDoc := "Albaran proveedor"
      ::oDbf:cClsDoc := ALB_PRV

      ::oDbf:cSerDoc := ( D():AlbaranesProveedores( ::nView ) )->cSerAlb
      ::oDbf:cNumDoc := Str( ( D():AlbaranesProveedores( ::nView ) )->nNumAlb )
      ::oDbf:cSufDoc := ( D():AlbaranesProveedores( ::nView ) )->cSufAlb

      ::oDbf:cIdeDoc := ::idDocumento()            

      ::oDbf:cCodPrv := ( D():AlbaranesProveedores( ::nView ) )->cCodPrv
      ::oDbf:cNomPrv := ( D():AlbaranesProveedores( ::nView ) )->cNomPrv
      ::oDbf:cCodGrp := RetFld( ( D():AlbaranesProveedores( ::nView ) )->cCodPrv, D():Proveedores( ::nView ), "cCodGrp" )
      ::oDbf:cCodPgo := ( D():AlbaranesProveedores( ::nView ) )->cCodPgo

      ::oDbf:nAnoDoc := Year( ( D():AlbaranesProveedores( ::nView ) )->dFecAlb )
      ::oDbf:nMesDoc := Month( ( D():AlbaranesProveedores( ::nView ) )->dFecAlb )
      ::oDbf:dFecDoc := ( D():AlbaranesProveedores( ::nView ) )->dFecAlb
      ::oDbf:cHorDoc := SubStr( ( D():AlbaranesProveedores( ::nView ) )->cTimChg, 1, 2 )
      ::oDbf:cMinDoc := SubStr( ( D():AlbaranesProveedores( ::nView ) )->cTimChg, 3, 2 )

      ::oDbf:nTotNet := sTot:nTotalNeto
      ::oDbf:nTotIva := sTot:nTotalIva
      ::oDbf:nTotReq := sTot:nTotalRecargoEquivalencia
      ::oDbf:nTotDoc := sTot:nTotalDocumento

      if ::lValidRegister()
         ::oDbf:Insert()
      else
         ::oDbf:Cancel()
      end if                

      ::AddAlbaranesProveedores()

      ( D():AlbaranesProveedores( ::nView ) )->( dbskip() )

      ::setMeterAutoIncremental()

   end while

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddFacturaProveedor( cCodigoProveedor ) CLASS TFastreportTerceros

   local sTot
   local aTotIva

   ( D():FacturasProveedores( ::nView ) )->( OrdSetFocus( "dFecFac" ) )
   ( D():FacturasProveedoresLineas( ::nView ) )->( OrdSetFocus( "nNumFac" ) )

   // filtros para la cabecera------------------------------------------------

   ::cExpresionHeader             := 'Field->dFecFac >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecFac <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
   
   ::setFilterPaymentInvoiceId()
   
   ::setFilterProviderId()

   // Procesando facturas-----------------------------------------------------

   ::setMeterText( "Procesando facturas" )
   
   ( D():FacturasProveedores( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

   ::setMeterTotal( ( D():FacturasProveedores( ::nView ) )->(dbcustomkeycount() ) )

   ( D():FacturasProveedores( ::nView ) )->( dbgotop() )
   while !::lBreak .and. !( D():FacturasProveedores( ::nView ) )->( eof() )

      sTot           := sTotFacPrv( ( D():FacturasProveedores( ::nView ) )->cSerFac + Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ) + ( D():FacturasProveedores( ::nView ) )->cSufFac, D():FacturasProveedores( ::nView ), D():FacturasProveedoresLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ), D():FacturasProveedoresPagos( ::nView ) )
     
      ::oDbf:Blank()

      ::oDbf:cTipDoc := "Factura proveedor"
      ::oDbf:cClsDoc := FAC_PRV

      ::oDbf:cSerDoc := ( D():FacturasProveedores( ::nView ) )->cSerFac
      ::oDbf:cNumDoc := Str( ( D():FacturasProveedores( ::nView ) )->nNumFac )
      ::oDbf:cSufDoc := ( D():FacturasProveedores( ::nView ) )->cSufFac

      ::oDbf:cIdeDoc := ::idDocumento()                                

      ::oDbf:cCodPrv := ( D():FacturasProveedores( ::nView ) )->cCodPrv
      ::oDbf:cNomPrv := ( D():FacturasProveedores( ::nView ) )->cNomPrv
      ::oDbf:cCodGrp := RetFld( ( D():FacturasProveedores( ::nView ) )->cCodPrv, D():Proveedores( ::nView ), "cCodGrp" )
      ::oDbf:cCodPgo := ( D():FacturasProveedores( ::nView ) )->cCodPago

      ::oDbf:nAnoDoc := Year( ( D():FacturasProveedores( ::nView ) )->dFecFac )
      ::oDbf:nMesDoc := Month( ( D():FacturasProveedores( ::nView ) )->dFecFac )
      ::oDbf:dFecDoc := ( D():FacturasProveedores( ::nView ) )->dFecFac
      ::oDbf:cHorDoc := SubStr( ( D():FacturasProveedores( ::nView ) )->cTimChg, 1, 2 )
      ::oDbf:cMinDoc := SubStr( ( D():FacturasProveedores( ::nView ) )->cTimChg, 3, 2 )

      ::oDbf:nTotNet := sTot:nTotalNeto
      ::oDbf:nTotIva := sTot:nTotalIva
      ::oDbf:nTotReq := sTot:nTotalRecargoEquivalencia
      ::oDbf:nTotDoc := sTot:nTotalDocumento

      ::oDbf:cSrlTot := sTot:saveToText()

      if ::lValidRegister()
         ::oDbf:Insert()
      else
         ::oDbf:Cancel()
      end if                

      ( D():FacturasProveedores( ::nView ) )->( dbskip() )

      ::setMeterAutoIncremental()

   end while

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddRectificativaProveedor() CLASS TFastreportTerceros

   local sTot

   ( D():FacturasRectificativasProveedores( ::nView ) )->( OrdSetFocus( "dFecFac" ) )

   // filtros para la cabecera------------------------------------------------

   ::cExpresionHeader             := 'Field->dFecFac >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecFac <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
   
   ::setFilterPaymentInvoiceId()
   
   ::setFilterProviderId()

   // Procesando facturas rectificativas--------------------------------------

   ::setMeterText( "Procesando facturas rectificativas")
   
   ( D():FacturasRectificativasProveedores( ::nView ) )->( setCustomFilter ( ::cExpresionHeader ) )

   ::setMeterTotal( ( D():FacturasRectificativasProveedores( ::nView ) )->( dbcustomkeycount() ) )

   ( D():FacturasRectificativasProveedores( ::nView ) )->( dbgotop() )

   while !::lBreak .and. !( D():FacturasRectificativasProveedores( ::nView ) )->( eof() )

      sTot           := sTotRctPrv( ( D():FacturasRectificativasProveedores( ::nView ) )->cSerFac + Str( ( D():FacturasRectificativasProveedores( ::nView ) )->nNumFac ) + ( D():FacturasRectificativasProveedores( ::nView ) )->cSufFac, D():FacturasRectificativasProveedores( ::nView ), D():FacturasRectificativasProveedoresLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ), D():FacturasProveedoresPagos( ::nView ) )
     
      ::oDbf:Blank()

      ::oDbf:cTipDoc := "Factura rectificativa"
      ::oDbf:cClsDoc := RCT_PRV

      ::oDbf:cSerDoc := ( D():FacturasRectificativasProveedores( ::nView ) )->cSerFac
      ::oDbf:cNumDoc := Str( ( D():FacturasRectificativasProveedores( ::nView ) )->nNumFac )
      ::oDbf:cSufDoc := ( D():FacturasRectificativasProveedores( ::nView ) )->cSufFac

      ::oDbf:cIdeDoc := ::idDocumento()                                

      ::oDbf:cCodPrv := ( D():FacturasRectificativasProveedores( ::nView ) )->cCodPrv
      ::oDbf:cNomPrv := ( D():FacturasRectificativasProveedores( ::nView ) )->cNomPrv
      ::oDbf:cCodGrp := RetFld( ( D():FacturasRectificativasProveedores( ::nView ) )->cCodPrv, D():Proveedores( ::nView ), "cCodGrp" )
      ::oDbf:cCodPgo := ( D():FacturasRectificativasProveedores( ::nView ) )->cCodPago

      ::oDbf:nAnoDoc := Year( ( D():FacturasRectificativasProveedores( ::nView ) )->dFecFac )
      ::oDbf:nMesDoc := Month( ( D():FacturasRectificativasProveedores( ::nView ) )->dFecFac )
      ::oDbf:dFecDoc := ( D():FacturasRectificativasProveedores( ::nView ) )->dFecFac
      ::oDbf:cHorDoc := SubStr( ( D():FacturasRectificativasProveedores( ::nView ) )->cTimChg, 1, 2 )
      ::oDbf:cMinDoc := SubStr( ( D():FacturasRectificativasProveedores( ::nView ) )->cTimChg, 3, 2 )

      ::oDbf:nTotNet := sTot:nTotalNeto
      ::oDbf:nTotIva := sTot:nTotalIva
      ::oDbf:nTotReq := sTot:nTotalRecargoEquivalencia
      ::oDbf:nTotDoc := sTot:nTotalDocumento

      ::oDbf:cSrlTot := sTot:saveToText()

      if ::lValidRegister()
         ::oDbf:Insert()
      else
         ::oDbf:Cancel()
      end if                

      ::AddFacturasRectificativasProveedores()

      ( D():FacturasRectificativasProveedores( ::nView ) )->( dbskip() )

      ::setMeterAutoIncremental()

   end while

RETURN ( Self )

//---------------------------------------------------------------------------//
