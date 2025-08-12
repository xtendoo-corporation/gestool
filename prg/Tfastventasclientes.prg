#include "FiveWin.Ch"
#include "Factu.ch" 
#include "Report.ch"
#include "MesDbf.ch"
// #include "FastRepH.ch"
 
//---------------------------------------------------------------------------//

CLASS TFastVentasClientes FROM TFastreportTerceros

   DATA  cType                            INIT "Clientes"

   DATA  oStock
 
   DATA  cExpresionHeader

   DATA  lApplyFilters                    INIT .t.

   DATA oCamposExtra
   DATA aExtraFields                      INIT {}

   DATA  aTypeDocs                        INIT { "C", "N", "D", "L", "C" } 

   METHOD Create

   METHOD lResource()

   METHOD lGenerate()
   METHOD lValidRegister()

   METHOD OpenFiles()
   METHOD CloseFiles()

   METHOD DataReport()
   METHOD AddVariable()

   METHOD StartDialog()
   METHOD BuildTree( oTree )

   METHOD AddRecibosCliente( cFieldOrder )
   METHOD AddRecibosClienteCobro()        INLINE ( ::addRecibosCliente( 'dEntrada' ) )
   METHOD AddRecibosClienteVencimiento()  INLINE ( ::addRecibosCliente( 'dFecVto' ) )

   METHOD AddCobrosTickets()

   METHOD AddEntregas()

   METHOD insertFacturaCliente()
   METHOD insertRectificativa()
   METHOD insertTicketCliente()

   METHOD AddClientes()

   METHOD idDocumento()                   INLINE ( ::oDbf:cClsDoc + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc )
   METHOD idDocumentoLinea()              INLINE ( ::idDocumento() )

   METHOD setMeterText( cText )           INLINE ( if ( !empty( ::oMtrInf ), ::oMtrInf:cText := cText, ) )
   METHOD setMeterTotal( nTotal )         INLINE ( if ( !empty( ::oMtrInf ), ::oMtrInf:SetTotal( nTotal ), ) )
   METHOD setMeterAutoIncremental()       INLINE ( if ( !empty( ::oMtrInf ), ::oMtrInf:AutoInc(), ) )

   METHOD RiesgoAlcanzado()               INLINE ( ClientesModel():Riesgo( ::oDbf:cCodCli ) )
   METHOD TotalFacturado()                INLINE ( ::oStock:nFacturado( ::oDbf:cCodCli ) )
   METHOD nFacturacionCliente()           INLINE ( ::oStock:nFacturacionCliente( ::oDbf:cCodCli ) )
   METHOD TotalPendiente()                INLINE ( ::oStock:nFacturacionPendiente( ::oDbf:cCodCli ) )
   METHOD nPedidoCliente()                INLINE ( ::oStock:nPedidoCliente( ::oDbf:cCodCli ) )
   METHOD nPagadoCliente()                INLINE ( ::oStock:nPagadoCliente( ::oDbf:cCodCli ) )

   METHOD lClienteSinVentas()             INLINE ( ClientesModel():lClienteSinVentas( ::oDbf:cCodCli, ::dIniInf, ::dFinInf ) )
   
   METHOD setFilterClientIdHeader()       INLINE ( if( ::lApplyFilters,;
                                                   ::cExpresionHeader   += ' .and. ( alltrim( Field->cCodCli ) >= "' + alltrim( ::oGrupoCliente:Cargo:Desde ) + '" .and. alltrim( Field->cCodCli ) <= "' + alltrim( ::oGrupoCliente:Cargo:Hasta ) + '" )', ) )
   
   METHOD setFilterPaymentId()            INLINE ( if( ::lApplyFilters,;
                                                   ::cExpresionHeader  += ' .and. ( Field->cCodPgo >= "' + ::oGrupoFpago:Cargo:Desde + '" .and. Field->cCodPgo <= "' + ::oGrupoFpago:Cargo:Hasta + '" )', ) )

   METHOD setFilterPaymentInvoiceId()     INLINE ( if( ::lApplyFilters,;
                                                   ::cExpresionHeader  += ' .and. ( Field->cCodPago >= "' + ::oGrupoFpago:Cargo:Desde + '" .and. Field->cCodPago <= "' + ::oGrupoFpago:Cargo:Hasta + '" )', ) )
   
   METHOD setFilterRouteId()              INLINE ( if( ::lApplyFilters,;
                                                   ::cExpresionHeader  += ' .and. ( Field->cCodRut >= "' + ::oGrupoRuta:Cargo:Desde + '" .and. Field->cCodRut <= "' + ::oGrupoRuta:Cargo:Hasta + '" )', ) )

   METHOD setFilterAgentId()              INLINE ( if( ::lApplyFilters,;
                                                   ::cExpresionHeader  += ' .and. ( Field->cCodAge >= "' + ::oGrupoAgente:Cargo:Desde + '" .and. Field->cCodAge <= "' + ::oGrupoAgente:Cargo:Hasta + '" )', ) )

   METHOD setFilterAlmacenId()            INLINE ( if( ::lApplyFilters,;
                                                   ::cExpresionHeader  += ' .and. ( Field->cCodAlm >= "' + ::oGrupoAlmacen:Cargo:Desde + '" .and. Field->cCodAlm <= "' + ::oGrupoAlmacen:Cargo:Hasta + '" )', ) )

   METHOD setFilterAlmacenTicketId()      INLINE ( if( ::lApplyFilters,;
                                                   ::cExpresionHeader  += ' .and. ( Field->cAlmTik >= "' + ::oGrupoAlmacen:Cargo:Desde + '" .and. Field->cAlmTik <= "' + ::oGrupoAlmacen:Cargo:Hasta + '" )', ) )

   METHOD AddFieldCamposExtra()
   METHOD loadValuesExtraFields()

   METHOD nTotalVentasCliente()

END CLASS

//----------------------------------------------------------------------------//

METHOD Create( uParam ) CLASS TFastVentasClientes

   ::AddField( "cCodCli",  "C", 12, 0, {|| "@!" }, "Código cliente"                          )
   ::AddField( "cNomCli",  "C",100, 0, {|| ""   }, "Nombre cliente"                          )
   ::AddField( "cDniCli",  "C", 30, 0, {|| "@!" }, "NIF cliente"                             )

   ::AddField( "cCodTip",  "C", 12, 0, {|| "@!" }, "Código del tipo de cliente"              )
   ::AddField( "cCodGrp",  "C", 12, 0, {|| "@!" }, "Código grupo de cliente"                 )
   ::AddField( "cCodPgo",  "C",  2, 0, {|| "@!" }, "Código de forma de pago"                 )
   ::AddField( "cCodRut",  "C", 12, 0, {|| "@!" }, "Código de la ruta"                       )
   ::AddField( "cCodAge",  "C", 12, 0, {|| "@!" }, "Código del agente"                       )
   ::AddField( "cCodUsr",  "C",  3, 0, {|| "@!" }, "Código usuario"                          )
   ::AddField( "cNomUsr",  "C",100, 0, {|| "@!" }, "Nombre usuario"                          )
   ::AddField( "cCodObr",  "C", 10, 0, {|| "@!" }, "Código dirección"                        )
   ::AddField( "cCodAlm",  "C", 16, 0, {|| "@!" }, "Código almacén"                          )

   ::AddField( "cTipDoc",  "C", 30, 0, {|| "" },   "Tipo de documento"                       )

   ::AddField( "cClsDoc",  "C",  2, 0, {|| "" },   "Clase de documento"                      )
   ::AddField( "cIdeDoc",  "C", 27, 0, {|| "" },   "Identificador del documento"             )
   ::AddField( "cSerDoc",  "C",  1, 0, {|| "" },   "Serie del documento"                     )
   ::AddField( "cNumDoc",  "C", 10, 0, {|| "" },   "Número del documento"                    )
   ::AddField( "cSufDoc",  "C",  2, 0, {|| "" },   "Delegación del documento"                )
   ::AddField( "cNumRec",  "C",  2, 0, {|| "" },   "Número del recibo"                       )
   ::AddField( "cCodPos",  "C", 15, 0, {|| "@!" }, "Código postal del documento"             )
   ::AddField( "cTipRec",  "C",  1, 0, {|| "@!" }, "Tipo de recibo"                          )
   ::AddField( "cTurno",   "C",  6, 0, {|| "" },   "Sesión"                                  )

   ::AddField( "nAnoDoc",  "N",  4, 0, {|| "" },   "Año del documento"                       )
   ::AddField( "nMesDoc",  "N",  2, 0, {|| "" },   "Mes del documento"                       )
   ::AddField( "dFecDoc",  "D",  8, 0, {|| "" },   "Fecha del documento"                     )
   ::AddField( "cHorDoc",  "C",  2, 0, {|| "" },   "Hora del documento"                      )
   ::AddField( "cMinDoc",  "C",  2, 0, {|| "" },   "Minutos del documento"                   )

   ::AddField( "nTotNet",  "N", 16, 6, {|| "" },   "Total neto"                              )
   ::AddField( "nTotIva",  "N", 16, 6, {|| "" },   "Total " + cImp()                         )
   ::AddField( "nTotReq",  "N", 16, 6, {|| "" },   "Total RE"                                )
   ::AddField( "nTotDoc",  "N", 16, 6, {|| "" },   "Total documento"                         )
   ::AddField( "nTotPnt",  "N", 16, 6, {|| "" },   "Total punto verde"                       )
   ::AddField( "nTotTrn",  "N", 16, 6, {|| "" },   "Total transporte"                        )
   ::AddField( "nTotAge",  "N", 16, 6, {|| "" },   "Total agente"                            )
   ::AddField( "nTotCos",  "N", 16, 6, {|| "" },   "Total costo"                             )
   ::AddField( "nDtoLin",  "N", 16, 6, {|| "" },   "Total descuento lineal"                  )
   ::AddField( "nTotIvm",  "N", 16, 6, {|| "" },   "Total impuestos especiales"              )
   ::AddField( "nTotRnt",  "N", 16, 6, {|| "" },   "Total rentabilidad"                      )
   ::AddField( "nTotRet",  "N", 16, 6, {|| "" },   "Total retenciones"                       )
   ::AddField( "nTotCob",  "N", 16, 6, {|| "" },   "Total cobros"                            )
   ::AddField( "nIva",     "N",  6, 2, {|| "" },   "Porcentaje impuesto"                     )
   ::AddField( "nReq",     "N", 16, 6, {|| "" },   "Porcentaje recargo"                      )
   ::AddField( "lCobRec",  "L",  1, 0, {|| "" },   "Lógico recibo cobrado"                   )
   ::AddField( "nComAge",  "N",  6, 2, {|| "" },   "Comisión agente"                         )

   ::AddField( "cSrlTot",  "M", 10, 0, {|| "" },   "Total serializado"                       )

   ::AddField( "uCargo",   "C", 20, 0, {|| "" },   "Cargo"                                   )

   ::AddField( "nNumRem",  "N",  9, 0, {|| "999999999" },   "Número de la remesa"            )
   ::AddField( "cSufRem",  "C",  2, 0, {|| "@!" },          "Sufijo de la remesa"            )
   ::AddField( "cEstado",  "C", 20, 0, {|| "" },            "Estado del documento"           )

   ::AddField( "nRieCli",  "N", 16, 0, {|| "" },            "Riesgo del cliente"             )
   ::AddField( "dFecVto",  "D",  8, 0, {|| "" },            "Vencimiento del recibo"         )

   ::AddField( "nTotVta",  "N", 16, 6, {|| "" },            "Total ventas cliente"           )

   ::AddFieldCamposExtra()

   ::AddTmpIndex( "cCodCli", "cCodCli" )
   ::AddTmpIndex( "cDniCli", "cDniCli" )

RETURN ( self )

//----------------------------------------------------------------------------//

METHOD lResource() CLASS TFastVentasClientes

   ::lNewInforme     := .t.
   ::lDefCondiciones := .f.

   ::cTipoInforme    := "Clientes"
   ::cBmpInforme     := "gc_user_64"
     
   ::cSubTitle       := "Informe de ventas" 

   if !::lTabletVersion
      if !::NewResource()
         return .f.
      end if
   end if

   /*
   Carga controles-------------------------------------------------------------
   */

   if !::lGrupoCliente( .t. )
      return .f.
   end if

   if !::lGrupoGrupoCliente( .t. )
      return .f.
   end if

   if !::lGrupoAlmacen( .t. )
      return .f.
   end if

   if !::lGrupoFpago( .t. )
      return .f.
   end if

   if !::lGrupoRuta( .t. )
      return .f.
   end if

   if !::lGrupoAgente( .t. )
      return .f.
   end if

   if !::lGrupoSerie( .t. )
      return .f.
   end if

   if !::lGrupoSufijo( .t. )
      return .f.
   end if

   if !::lGrupoIva( .t. )
      return .t.
   end if

   ::oFilter      := TFilterCreator():Init()
   if !Empty( ::oFilter )
      ::oFilter:SetDatabase( ::oDbf )
      ::oFilter:SetFilterType( CLI_TBL )
   end if 

RETURN .t.

//---------------------------------------------------------------------------//

METHOD OpenFiles() CLASS TFastVentasClientes

   local lOpen    := .t.
   local oError
   local oBlock

   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      ::cDriver         := cDriver()

      ::nView           := D():CreateView( ::cDriver )

      ::lApplyFilters   := lAIS()

      D():SatClientes( ::nView )
      ( D():SatClientes( ::nView ) )->( OrdSetFocus( "cCodCli" ) )

      D():SatClientesLineas( ::nView )

      D():PresupuestosClientes( ::nView )
      ( D():PresupuestosClientes( ::nView ) )->( OrdSetFocus( "cCodCli" ) )

      D():PresupuestosClientesLineas( ::nView )

      D():PedidosClientes( ::nView )
      ( D():PedidosClientes( ::nView ) )->( OrdSetFocus( "cCodCli" ) )

      D():PedidosClientesLineas( ::nView )

      D():AlbaranesClientes( ::nView )
      ( D():AlbaranesClientes( ::nView ) )->( OrdSetFocus( "cCodCli" ) )

      D():AlbaranesClientesLineas( ::nView )

      D():FacturasClientes( ::nView ) 
      ( D():FacturasClientes( ::nView ) )->( OrdSetFocus( "cCodCli" ) )

      D():FacturasClientesLineas( ::nView )

      D():FacturasClientesCobros( ::nView )

      D():AnticiposClientes( ::nView )

      D():FacturasRectificativas( ::nView )

      D():FacturasRectificativasLineas( ::nView )

      D():TiketsClientes( ::nView )

      D():TiketsLineas( ::nView )

      D():TiketsCobros( ::nView )      

      D():ClientesDirecciones( ::nView )

      D():ClientesBancos( ::nView )

      D():Atipicas( ::nView )

      D():ClientesDocumentos( ::nView )

      D():ClientesIncidencias( ::nView )

      D():Clientes( ::nView )

      D():Agentes( ::nView )

      D():Ruta( ::nView )

      D():FormasPago( ::nView )

      D():TiposIva( ::nView )

      D():Divisas( ::nView )

      D():objectGruposClientes( ::nView )

      /*
      Stocks de articulos------------------------------------------------------
      */

      ::oStock                := TStock():Create( cPatEmp() )
      if !::oStock:lOpenFiles()
         lOpen                := .f.
      end if

      ::oCamposExtra          := TDetCamposExtra():New( cPatEmp(), ::cDriver )
      if !::oCamposExtra:OpenFiles()
         lOpen                := .f.
      else 
         ::oCamposExtra:setTipoDocumento( "Facturas a clientes" )
         ::aExtraFields       := ::oCamposExtra:aExtraFields()
      end if

   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible abrir las bases de datos de clientes" )

      ::CloseFiles()

      lOpen       := .f.

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( lOpen )

//---------------------------------------------------------------------------//

METHOD CloseFiles() CLASS TFastVentasClientes

   if !Empty( ::oStock )
      ::oStock:End()
   end if

   if !Empty( ::oCamposExtra )
      ::oCamposExtra:CloseFiles()
      ::oCamposExtra:End()
   end if

   if !Empty( ::nView )
      D():DeleteView( ::nView )
   end if

   ::nView     := nil

RETURN .t.

//---------------------------------------------------------------------------//

METHOD AddFieldCamposExtra() CLASS TFastVentasClientes

   local cField
   
   if isArray( ::aExtraFields ) .and. Len( ::aExtraFields ) != 0

      for each cField in ::aExtraFields

         ::AddField( "fld" + cField[ "código" ],;
                     ::aTypeDocs[ cField[ "tipo" ] ] ,;
                     cField[ "longitud" ],;
                     cField[ "decimales" ],;
                     {|| ::oCamposExtra:cPictData( cField ) },;
                     Capitalize( cField[ "descripción" ] ) )

      next

   end if

Return ( Self )

//---------------------------------------------------------------------------//

METHOD StartDialog() CLASS TFastVentasClientes

   /*
   Imagenes--------------------------------------------------------------------
   */

   ::CreateTreeImageList()

   ::BuildTree( ::oTreeReporting, .t. )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD BuildTree( oTree, lLoadFile ) CLASS TFastVentasClientes

   local aReports

   DEFAULT oTree     := ::oTreeReporting
   DEFAULT lLoadFile := .t.

   aReports := {  {  "Title" => "Listado",                                                "Image" => 0, "Type" => "Listado",                            "Directory" => "Clientes\Listado",                             "File" => "Listado.fr3"  },;
                  {  "Title" => "Operaciones de clientes",                                "Image" => 11, "Subnode" =>;
                  { ;
                     { "Title" => "SAT de clientes",                                      "Image" =>20, "Type" => "SAT de clientes",                     "Directory" => "Clientes\Ventas\SAT de clientes",              "File" => "SAT de clientes.fr3" },;
                     { "Title" => "Presupuestos de clientes",                             "Image" => 5, "Type" => "Presupuestos de clientes",            "Directory" => "Clientes\Ventas\Presupuestos de clientes",     "File" => "Presupuestos de clientes.fr3" },;
                     { "Title" => "Pedidos de clientes",                                  "Image" => 6, "Type" => "Pedidos de clientes",                 "Directory" => "Clientes\Ventas\Pedidos de clientes",          "File" => "Pedidos de clientes.fr3" },;
                     { "Title" => "Albaranes de clientes",                                "Image" => 7, "Type" => "Albaranes de clientes",               "Directory" => "Clientes\Ventas\Albaranes de clientes",        "File" => "Albaranes de clientes.fr3" },;
                     { "Title" => "Facturas de clientes",                                 "Image" => 8, "Type" => "Facturas de clientes",                "Directory" => "Clientes\Ventas\Facturas de clientes",         "File" => "Diario de facturas de clientes.fr3" },;
                     { "Title" => "Rectificativas de clientes",                           "Image" => 9, "Type" => "Rectificativas de clientes",          "Directory" => "Clientes\Ventas\Rectificativas de clientes",   "File" => "Rectificativas de clientes.fr3" },;
                     { "Title" => "Facturas simplificadas de clientes",                   "Image" =>10, "Type" => "Facturas simplificadas",              "Directory" => "Clientes\Ventas\Facturas simplificadas",       "File" => "Facturas simplificadas.fr3" },;
                     { "Title" => "Facturas, rectificativas y simplificadas",             "Image" => 8, "Type" => "Facturación de clientes",             "Directory" => "Clientes\Ventas\Facturación de clientes",      "File" => "Facturación de clientes.fr3" },;
                     { "Title" => "Albaranes, facturas, rectificativas y simplificadas",  "Image" =>11, "Type" => "Ventas",                              "Directory" => "Clientes\Ventas\Ventas",                       "File" => "Ventas.fr3" },;
                     { "Title" => "Recibos fecha de emisión",                             "Image" =>21, "Type" => "Recibos emisión",                     "Directory" => "Clientes\Ventas\Recibos",                      "File" => "Recibos de clientes.fr3" },;
                     { "Title" => "Recibos fecha de cobro",                               "Image" =>21, "Type" => "Recibos cobro",                       "Directory" => "Clientes\Ventas\RecibosCobro",                 "File" => "Recibos de clientes fecha de cobro.fr3" },;
                     { "Title" => "Recibos fecha de vencimiento",                         "Image" =>21, "Type" => "Recibos vencimiento",                 "Directory" => "Clientes\Ventas\RecibosVencimiento",           "File" => "Recibos de clientes fecha de vencimiento.fr3" },;
                     { "Title" => "Cobros de simplificadas",                              "Image" =>10, "Type" => "Cobros simplificadas",                "Directory" => "Clientes\Ventas\CobrosSimplificadas",          "File" => "Cobros de simplificadas.fr3" },;
                     { "Title" => "Cobros clientes",                                      "Image" =>27, "Type" => "Cobros clientes",                     "Directory" => "Clientes\Ventas\Cobros",                       "File" => "Cobros.fr3" },;
                  } } }

   ::BuildNode( aReports, oTree, lLoadFile ) 

   //oTree:ExpandAll()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD DataReport() CLASS TFastVentasClientes
   
   /*
   Zona de detalle-------------------------------------------------------------
   */

   ::oFastReport:SetWorkArea(       "Informe", ::oDbf:nArea )
   ::oFastReport:SetFieldAliases(   "Informe", cObjectsToReport( ::oDbf ) )

   /*
   Zona de datos---------------------------------------------------------------
   */

   ::oFastReport:SetWorkArea(       "Empresa",                          ::oDbfEmp:nArea )
   ::oFastReport:SetFieldAliases(   "Empresa",                          cItemsToReport( aItmEmp() ) )

   ::oFastReport:SetWorkArea(       "Clientes",                         ( D():Clientes( ::nView ) )->( select() ) )
   ::oFastReport:SetFieldAliases(   "Clientes",                         cItemsToReport( aItmCli() ) )

   ::oFastReport:SetWorkArea(       "Agentes",                          ( D():Agentes( ::nView ) )->( select() ) )
   ::oFastReport:SetFieldAliases(   "Agentes",                          cItemsToReport( aItmAge() ) )

   ::oFastReport:SetWorkArea(       "Rutas",                            ( D():Ruta( ::nView ) )->( select() ) )
   ::oFastReport:SetFieldAliases(   "Rutas",                            cItemsToReport( aItmRut() ) )

   ::oFastReport:SetWorkArea(       "Formas de pago",                   ( D():FormasPago( ::nView ) )->( select() ) )
   ::oFastReport:SetFieldAliases(   "Formas de pago",                   cItemsToReport( aItmFPago() ) )

   ::oFastReport:SetWorkArea(       "Grupos de cliente",                D():objectGruposClientes( ::nView ):Select() )
   ::oFastReport:SetFieldAliases(   "Grupos de cliente",                cObjectsToReport( D():objectGruposClientes( ::nView ):oDbf ) )

   ::oFastReport:SetWorkArea(       "Direcciones",                      ( D():ClientesDirecciones( ::nView ) )->( select() ) )
   ::oFastReport:SetFieldAliases(   "Direcciones",                      cItemsToReport( aItmObr() ) )

   ::oFastReport:SetWorkArea(       "Bancos",                           ( D():ClientesBancos( ::nView ) )->( select() ) )
   ::oFastReport:SetFieldAliases(   "Bancos",                           cItemsToReport( aCliBnc() ) )

   ::oFastReport:SetWorkArea(       "Tarifas de cliente",               ( D():Atipicas( ::nView ) )->( select() ) )
   ::oFastReport:SetFieldAliases(   "Tarifas de cliente",               cItemsToReport( aItmAtp() ) )

   ::oFastReport:SetWorkArea(       "Documentos",                       ( D():ClientesDocumentos( ::nView ) )->( select() ) )
   ::oFastReport:SetFieldAliases(   "Documentos",                       cItemsToReport( aCliDoc() ) )

   ::oFastReport:SetWorkArea(       "Incidencias",                      ( D():ClientesIncidencias( ::nView ) )->( select() ) )
   ::oFastReport:SetFieldAliases(   "Incidencias",                      cItemsToReport( aCliInc() ) )

   /*
   Relaciones------------------------------------------------------------------
   */

   ::oFastReport:SetMasterDetail(   "Informe", "Empresa",               {|| cCodEmp() } )
   ::oFastReport:SetMasterDetail(   "Informe", "Bancos",                {|| ::oDbf:cCodCli } )
   ::oFastReport:SetMasterDetail(   "Informe", "Clientes",              {|| ::oDbf:cCodCli } )
   ::oFastReport:SetMasterDetail(   "Informe", "Tarifas de cliente",    {|| ::oDbf:cCodCli } )
   ::oFastReport:SetMasterDetail(   "Informe", "Documentos",            {|| ::oDbf:cCodCli } )
   ::oFastReport:SetMasterDetail(   "Informe", "Incidencias",           {|| ::oDbf:cCodCli } )
   ::oFastReport:SetMasterDetail(   "Informe", "Agentes",               {|| ::oDbf:cCodAge } )
   ::oFastReport:SetMasterDetail(   "Informe", "Rutas",                 {|| ::oDbf:cCodRut } )
   ::oFastReport:SetMasterDetail(   "Informe", "Formas de pago",        {|| ::oDbf:cCodPgo } )

   ::oFastReport:SetMasterDetail(   "Clientes", "Grupos de cliente",    {|| ( D():Clientes( ::nView ) )->cCodGrp } )
   ::oFastReport:SetMasterDetail(   "Clientes", "País",                 {|| ( D():Clientes( ::nView ) )->cCodPai } )

   /*
   Relación con la tabla de direcciones en funcion del tipo de informe
   */

   if ::cReportType == "Listado" 
      ::oFastReport:SetMasterDetail(   "Informe", "Direcciones",           {|| ::oDbf:cCodCli } )      
   else
      ::oFastReport:SetMasterDetail(   "Informe", "Direcciones",           {|| ::oDbf:cCodCli + ::oDbf:cCodObr } )
   end if

   ::oFastReport:SetResyncPair(     "Informe", "Empresa" )
   ::oFastReport:SetResyncPair(     "Informe", "Facturas" )
   ::oFastReport:SetResyncPair(     "Informe", "Agentes" )
   ::oFastReport:SetResyncPair(     "Informe", "Bancos" )
   ::oFastReport:SetResyncPair(     "Informe", "Clientes" )
   ::oFastReport:SetResyncPair(     "Informe", "Tarifas de cliente" )
   ::oFastReport:SetResyncPair(     "Informe", "Documentos" )
   ::oFastReport:SetResyncPair(     "Informe", "Incidencias" )
   ::oFastReport:SetResyncPair(     "Informe", "Rutas" )
   ::oFastReport:SetResyncPair(     "Informe", "Formas de pago" )

   ::oFastReport:SetResyncPair(     "Clientes", "Grupos de cliente" )
   ::oFastReport:SetResyncPair(     "Clientes", "País" )

   do case
      case ::cReportType == "SAT de clientes"

         ::FastReportSATCliente()

      case ::cReportType == "Presupuestos de clientes"

         ::FastReportPresupuestoCliente()

      case ::cReportType == getConfigTraslation("Pedidos de clientes")
      
         ::FastReportPedidoCliente()

      case ::cReportType == "Albaranes de clientes"
      
         ::FastReportAlbaranCliente()

      case ::cReportType == "Facturas de clientes"
      
         ::FastReportFacturaCliente()
         
      case ::cReportType == "Rectificativas de clientes"

         ::FastReportFacturaRectificativa()

      case ::cReportType == "Facturas simplificadas"

         ::FastReportTicket( .t. )

      case ::cReportType == "Facturación de clientes"

         ::FastReportFacturaCliente()
         
         ::FastReportFacturaRectificativa()

         ::FastReportTicket( .t. )

      case ::cReportType == "Ventas"

         ::FastReportAlbaranCliente()

         ::FastReportFacturaCliente()

         ::FastReportFacturaRectificativa()

         ::FastReportTicket( .t. )

      case ( "Recibos" $ ::cReportType )

         ::FastReportRecibosCliente() 

      case ( "Cobros" $ ::cReportType )

         ::FastReportCobrosTickets()

   end case

   ::AddVariable()

Return ( Self )

//---------------------------------------------------------------------------//

METHOD AddVariable() CLASS TFastVentasClientes

   /*
   Tablas en funcion del tipo de informe---------------------------------------
   */

   do case
      case ::cReportType == "SAT de clientes"

         ::AddVariableSATCliente()

         ::AddVariableLineasSATCliente()         

      case ::cReportType == "Presupuestos de clientes"

         ::AddVariablePresupuestoCliente()

         ::AddVariableLineasPresupuestoCliente()         

      case ::cReportType == getConfigTraslation("Pedidos de clientes")
      
         ::AddVariablePedidoCliente()

         ::AddVariableLineasPedidoCliente()         

      case ::cReportType == "Albaranes de clientes"
      
         ::AddVariableAlbaranCliente()

         ::AddVariableLineasAlbaranCliente()         

      case ::cReportType == "Facturas de clientes"
      
         ::AddVariableFacturaCliente()

         ::AddVariableLineasFacturaCliente()
         
      case ::cReportType == "Rectificativas de clientes"

         ::AddVariableRectificativaCliente()
         
         ::AddVariableLineasRectificativaCliente()

      case ::cReportType == "Facturas simplificadas"

         ::AddVariableTicketCliente()

         ::AddVariableLineasTicketCliente()

      case ::cReportType == "Facturación de clientes"
      
         ::AddVariableFacturaCliente()

         ::AddVariableLineasFacturaCliente()
         
         ::AddVariableRectificativaCliente()

         ::AddVariableLineasRectificativaCliente()

         ::AddVariableTicketCliente()

         ::AddVariableLineasTicketCliente()

      case ::cReportType == "Ventas"

         ::AddVariableAlbaranCliente()

         ::AddVariableFacturaCliente()
         
         ::AddVariableRectificativaCliente()

         ::AddVariableTicketCliente()   

         ::AddVariableLineasAlbaranCliente()  

         ::AddVariableLineasFacturaCliente()
         
         ::AddVariableLineasRectificativaCliente() 

         ::AddVariableLineasTicketCliente()

      case ( "Recibos" $ ::cReportType )

         ::AddVariableRecibosCliente()

      case ( "Cobros" $ ::cReportType )

         ::AddVariableCobrosTickets()

   end case

   ::oFastReport:AddVariable(    "Clientes",    "Riesgo alcanzado",   "CallHbFunc( 'oTinfGen', ['RiesgoAlcanzado'])" )
   ::oFastReport:AddVariable(    "Clientes",    "Total movimientos",  "CallHbFunc( 'oTinfGen', ['TotalFacturado'])" )
   ::oFastReport:AddVariable(    "Clientes",    "Total pendiente",    "CallHbFunc( 'oTinfGen', ['TotalPendiente'])" )
   ::oFastReport:AddVariable(    "Clientes",    "Total pagado",       "CallHbFunc( 'oTinfGen', ['nPagadoCliente'])" )
   ::oFastReport:AddVariable(    "Clientes",    "Total pedido",       "CallHbFunc( 'oTinfGen', ['nPedidoCliente'])" )
   ::oFastReport:AddVariable(    "Clientes",    "Total facturado",    "CallHbFunc( 'oTinfGen', ['nFacturacionCliente'])" )
   ::oFastReport:AddVariable(    "Clientes",    "Cliente sin ventas", "CallHbFunc( 'oTinfGen', ['lClienteSinVentas'])" )

Return ( ::Super:AddVariable() )

//---------------------------------------------------------------------------//

METHOD lGenerate() CLASS TFastVentasClientes
   
   ::oDbf:Zap()

   /*
   Recorremos clientes---------------------------------------------------------
   */

   do case
      case ::cReportType == "SAT de clientes"

         ::AddSATCliente()

      case ::cReportType == "Presupuestos de clientes"

         ::AddPresupuestoCliente()

      case ::cReportType == getConfigTraslation("Pedidos de clientes")

         ::AddPedidoCliente()
         
      case ::cReportType == "Albaranes de clientes"

         ::AddAlbaranCliente()

      case ::cReportType == "Facturas de clientes"

         ::AddFacturaCliente()   

      case ::cReportType == "Rectificativas de clientes"

         ::AddRectificativaCliente()

      case ::cReportType == "Facturas simplificadas"

         ::AddTicket( .t. )

      case ::cReportType == "Facturación de clientes"   

         ::AddFacturaCliente()

         ::AddRectificativaCliente()

         ::AddTicket()

      case ::cReportType == "Ventas"

         ::AddAlbaranCliente( .t. )

         ::AddFacturaCliente()

         ::AddRectificativaCliente()

         ::AddTicket()      

      case ::cReportType == "Listado"

         ::AddClientes()

      case ::cReportType == "Recibos emisión"

         ::AddRecibosCliente()   

      case ::cReportType == "Recibos cobro"

         ::AddRecibosClienteCobro()   

      case ::cReportType == "Recibos vencimiento"

         ::AddRecibosClienteVencimiento()   

      case ::cReportType == "Cobros simplificadas"

         ::AddCobrosTickets()   

      case ::cReportType == "Cobros clientes"

         ::AddEntregas()

   end case

   if !empty(::oFilter)
      ::oDbf:SetFilter( ::oFilter:cExpresionFilter )
   end if 

   ::oDbf:GoTop()

RETURN ( ::oDbf:LastRec() > 0 )

//---------------------------------------------------------------------------//

Method lValidRegister( cCodigoCliente ) CLASS TFastVentasClientes

   if !empty( ::oGrupoCliente ) .and. !( ::oDbf:cCodCli >= ::oGrupoCliente:Cargo:Desde .and. ::oDbf:cCodCli <= ::oGrupoCliente:Cargo:Hasta )
      Return .f.
   end if 

   if !empty( ::oGrupoFpago ) .and. !( ::oDbf:cCodPgo >= ::oGrupoFpago:Cargo:Desde .and. ::oDbf:cCodPgo <= ::oGrupoFpago:Cargo:Hasta )
      Return .f.
   end if 

   if !empty( ::oGrupoRuta ) .and. !( ::oDbf:cCodRut >= ::oGrupoRuta:Cargo:Desde .and. ::oDbf:cCodRut  <= ::oGrupoRuta:Cargo:Hasta )
      Return .f.
   end if 
      
   if !empty( ::oGrupoAgente ) .and. !( ::oDbf:cCodAge  >= ::oGrupoAgente:Cargo:Desde .and. ::oDbf:cCodAge <= ::oGrupoAgente:Cargo:Hasta )
      Return .f.
   end if 

   if !empty( ::oGrupoGCliente ) .and. !( ::oGrupoGCliente:Cargo:ValidMayorIgual( ::oDbf:cCodGrp, ::oGrupoGCliente:Cargo:Desde ) .and. ::oGrupoGCliente:Cargo:ValidMenorIgual( ::oDbf:cCodGrp, ::oGrupoGcliente:Cargo:Hasta ) )
      return .f.
   end if

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD AddRecibosCliente( cFieldOrder ) CLASS TFastVentasClientes

   local sTot
   local oError
   local oBlock
   
   DEFAULT cFieldOrder  := 'dPreCob'

   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
   
      ( D():FacturasClientesCobros( ::nView ) )->( OrdSetFocus( cFieldOrder ) )

      // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := 'Field->' + cFieldOrder + ' >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->' + cFieldOrder + ' <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
      
      if !Empty( ::oGrupoSerie )
         ::cExpresionHeader       += ' .and. Field->cSerie >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerie <= "' + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '"'
      end if

      if !Empty( ::oGrupoSufijo )
         ::cExpresionHeader       += ' .and. ( Field->cSufFac >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufFac <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'
      end if

      ::setFilterClientIdHeader()

      ::setFilterPaymentId()

      ::setFilterAgentId()
      
      // Procesando recibos------------------------------------------------------

      ::setMeterText( "Procesando recibos" )

      ( D():FacturasClientesCobros( ::nView ) )->( setCustomFilter( ::cExpresionHeader ))

      ::setMeterTotal( ( D():FacturasClientesCobros( ::nView ) )->( dbcustomkeycount() ) )

      ( D():FacturasClientesCobros( ::nView ) )->( dbgotop() )
      while !::lBreak .and. !( D():FacturasClientesCobros( ::nView ) )->( eof() )

         ::oDbf:Blank()

         ::oDbf:cCodCli    := ( D():FacturasClientesCobros( ::nView ) )->cCodCli
         ::oDbf:cNomCli    := ( D():FacturasClientesCobros( ::nView ) )->cNomCli
         ::oDbf:cCodAge    := ( D():FacturasClientesCobros( ::nView ) )->cCodAge
         ::oDbf:cCodPgo    := ( D():FacturasClientesCobros( ::nView ) )->cCodPgo
         ::oDbf:cCodUsr    := ( D():FacturasClientesCobros( ::nView ) )->cCodUsr
         ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( ( D():FacturasClientesCobros( ::nView ) )->cCodUsr )

         ::oDbf:cCodRut    := RetFld( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), 'cCodRut' )
         ::oDbf:cCodPos    := RetFld( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), 'cCodPos' )
         ::oDbf:cCodGrp    := RetFld( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod")

         ::oDbf:cTipDoc    := "Recibos clientes"
         ::oDbf:cClsDoc    := REC_CLI          
         ::oDbf:cSerDoc    := ( D():FacturasClientesCobros( ::nView ) )->cSerie
         ::oDbf:cNumDoc    := Str( ( D():FacturasClientesCobros( ::nView ) )->nNumFac )
         ::oDbf:cSufDoc    := ( D():FacturasClientesCobros( ::nView ) )->cSufFac
         ::oDbf:cNumRec    := Str( ( D():FacturasClientesCobros( ::nView ) )->nNumRec )
         ::oDbf:cIdeDoc    := Upper( ::oDbf:cClsDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc
         ::oDbf:cTipRec    := ( D():FacturasClientesCobros( ::nView ) )->cTipRec

         ::oDbf:lCobRec    := ( D():FacturasClientesCobros( ::nView ) )->lCobrado

         ::oDbf:nAnoDoc    := Year( ( D():FacturasClientesCobros( ::nView ) )->dPreCob )
         ::oDbf:nMesDoc    := Month( ( D():FacturasClientesCobros( ::nView ) )->dPreCob )
         ::oDbf:dFecDoc    := ( D():FacturasClientesCobros( ::nView ) )->dPreCob
         ::oDbf:cHorDoc    := SubStr( ( D():FacturasClientesCobros( ::nView ) )->cHorCre, 1, 2 )
         ::oDbf:cMinDoc    := SubStr( ( D():FacturasClientesCobros( ::nView ) )->cHorCre, 4, 2 )

         ::oDbf:nTotNet    := nTotRecCli( D():FacturasClientesCobros( ::nView ) )
         ::oDbf:nTotCob    := nTotCobCli( D():FacturasClientesCobros( ::nView ) )

         ::oDbf:nNumRem    := ( D():FacturasClientesCobros( ::nView ) )->nNumRem
         ::oDbf:cSufRem    := ( D():FacturasClientesCobros( ::nView ) )->cSufRem

         ::oDbf:dFecVto    := ( D():FacturasClientesCobros( ::nView ) )->dFecVto

         ::oDbf:cEstado    := cEstadoRecibo( D():FacturasClientesCobros( ::nView ) )

         ::oDbf:nRieCli    := RetFld( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
         ::oDbf:cDniCli    := RetFld( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

         // Añadimos un nuevo registro--------------------------------------------

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ( D():FacturasClientesCobros( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while
   
   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir recibos de clientes" )

   END SEQUENCE

   ErrorBlock( oBlock )
   
RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddCobrosTickets() CLASS TFastVentasClientes

   local sTot
   local oError
   local oBlock
   
   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      ( D():TiketsCobros( ::nView ) )->( OrdSetFocus( "iNumTik" ) )

      // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := '( Field->dPgoTik >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dPgoTik <= Ctod( "' + Dtoc( ::dFinInf ) + '" ) )'
      
      if !Empty( ::oGrupoSerie )
         ::cExpresionHeader       += ' .and. ( Field->cSerTik >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerTik <= "' + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '" )'
      end if

      if !Empty( ::oGrupoSufijo )
         ::cExpresionHeader       += ' .and. ( Field->cSufTik >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufTik <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'
      end if
      
      ::cExpresionHeader          += ' .and. ( Field->cFpgPgo >= "' + ::oGrupoFpago:Cargo:Desde + '" .and. Field->cFpgPgo <= "' + ::oGrupoFpago:Cargo:Hasta + '" )'

      // Procesando recibos------------------------------------------------------

      ::setMeterText( "Procesando cobros" )

      ( D():TiketsCobros( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():TiketsCobros( ::nView ) )->( dbcustomkeycount() ) )

      ( D():TiketsCobros( ::nView ) )->( dbgotop() )
      while !::lBreak .and. !( D():TiketsCobros( ::nView ) )->( eof() )

         ::oDbf:Blank()

         ::oDbf:cTipDoc    := "Cobros de tickets"
         ::oDbf:cClsDoc    := COB_TIK
         ::oDbf:cSerDoc    := ( D():TiketsCobros( ::nView ) )->cSerTik
         ::oDbf:cNumDoc    := ( D():TiketsCobros( ::nView ) )->cNumTik
         ::oDbf:cSufDoc    := ( D():TiketsCobros( ::nView ) )->cSufTik
         ::oDbf:cNumRec    := Str( ( D():TiketsCobros( ::nView ) )->nNumRec )
         ::oDbf:cIdeDoc    := Upper( ::oDbf:cClsDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc

         ::oDbf:nAnoDoc    := Year( ( D():TiketsCobros( ::nView ) )->dPgoTik )
         ::oDbf:nMesDoc    := Month( ( D():TiketsCobros( ::nView ) )->dPgoTik )
         ::oDbf:dFecDoc    := ( D():TiketsCobros( ::nView ) )->dPgoTik
         ::oDbf:cHorDoc    := SubStr( ( D():TiketsCobros( ::nView ) )->cTimTik, 1, 2 )
         ::oDbf:cMinDoc    := SubStr( ( D():TiketsCobros( ::nView ) )->cTimTik, 4, 2 )

         ::oDbf:cCodPgo    := ( D():TiketsCobros( ::nView ) )->cFpgPgo

         ::oDbf:cCodCli    := RetFld( ( D():TiketsCobros( ::nView ) )->cSerTik + ( D():TiketsCobros( ::nView ) )->cNumTik + ( D():TiketsCobros( ::nView ) )->cSufTik, ( D():TiketsClientes( ::nView ) ), "cCliTik", "CNUMTIK" )
         ::oDbf:cNomCli    := RetFld( ( D():TiketsCobros( ::nView ) )->cSerTik + ( D():TiketsCobros( ::nView ) )->cNumTik + ( D():TiketsCobros( ::nView ) )->cSufTik, ( D():TiketsClientes( ::nView ) ), "cNomTik", "CNUMTIK" )
         ::oDbf:cDniCli    := RetFld( ( D():TiketsCobros( ::nView ) )->cSerTik + ( D():TiketsCobros( ::nView ) )->cNumTik + ( D():TiketsCobros( ::nView ) )->cSufTik, ( D():TiketsClientes( ::nView ) ), "cDniCli", "CNUMTIK" )
         
         ::oDbf:cCodUsr    := RetFld( ( D():TiketsCobros( ::nView ) )->cSerTik + ( D():TiketsCobros( ::nView ) )->cNumTik + ( D():TiketsCobros( ::nView ) )->cSufTik, ( D():TiketsClientes( ::nView ) ), "cCcjTik", "CNUMTIK" )
         ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( RetFld( ( D():TiketsCobros( ::nView ) )->cSerTik + ( D():TiketsCobros( ::nView ) )->cNumTik + ( D():TiketsCobros( ::nView ) )->cSufTik, ( D():TiketsClientes( ::nView ) ), "cCcjTik", "CNUMTIK" ) )
         
         ::oDbf:cCodAlm    := RetFld( ( D():TiketsCobros( ::nView ) )->cSerTik + ( D():TiketsCobros( ::nView ) )->cNumTik + ( D():TiketsCobros( ::nView ) )->cSufTik, ( D():TiketsClientes( ::nView ) ), "cAlmTik", "CNUMTIK" )

         ::oDbf:nTotNet    := ( D():TiketsCobros( ::nView ) )->nImpTik - ( D():TiketsCobros( ::nView ) )->nDevTik

         ::oDbf:cTurno     := ( D():TiketsCobros( ::nView ) )->cTurPgo

         // Añadimos un nuevo registro--------------------------------------------

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ( D():TiketsCobros( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while
   
   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir cobros de tickets" )

   END SEQUENCE

   ErrorBlock( oBlock )
   
RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddEntregas()

   local oError
   local oBlock

   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      /*
      Entregas a cuentas de pedidos de clientes
      */

      ( D():PedidosClientesPagos( ::nView ) )->( OrdSetFocus( "nNumPed" ) )

      // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := '!Field->lPasado .and. ( Field->dEntrega >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dEntrega <= Ctod( "' + Dtoc( ::dFinInf ) + '" ) )'
      
      if !Empty( ::oGrupoSerie )
         ::cExpresionHeader       += ' .and. ( Field->cSerPed >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerPed <= "' + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '" )'
      end if

      if !Empty( ::oGrupoSufijo )
         ::cExpresionHeader       += ' .and. ( Field->cSufPed >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufPed <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'
      end if
      
      ::cExpresionHeader          += ' .and. ( Field->cCodPgo >= "' + ::oGrupoFpago:Cargo:Desde + '" .and. Field->cCodPgo <= "' + ::oGrupoFpago:Cargo:Hasta + '" )'

      // Procesando entregas de pedidos------------------------------------------------------

      ::setMeterText( "Procesando entregas en pedidos" )

      ( D():PedidosClientesPagos( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():TiketsCobros( ::nView ) )->( dbcustomkeycount() ) )

      ( D():PedidosClientesPagos( ::nView ) )->( dbgotop() )
      while !::lBreak .and. !( D():PedidosClientesPagos( ::nView ) )->( eof() )

         ::oDbf:Blank()

         ::oDbf:cTipDoc    := "Entrega pedido"
         ::oDbf:cClsDoc    := ENT_PED
         ::oDbf:cSerDoc    := ( D():PedidosClientesPagos( ::nView ) )->cSerPed
         ::oDbf:cNumDoc    := Str( ( D():PedidosClientesPagos( ::nView ) )->nNumPed )
         ::oDbf:cSufDoc    := ( D():PedidosClientesPagos( ::nView ) )->cSufPed
         ::oDbf:cNumRec    := Str( ( D():PedidosClientesPagos( ::nView ) )->nNumRec )
         ::oDbf:cIdeDoc    := Upper( ::oDbf:cClsDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc

         ::oDbf:nAnoDoc    := Year( ( D():PedidosClientesPagos( ::nView ) )->dEntrega )
         ::oDbf:nMesDoc    := Month( ( D():PedidosClientesPagos( ::nView ) )->dEntrega )
         ::oDbf:dFecDoc    := ( D():PedidosClientesPagos( ::nView ) )->dEntrega
         ::oDbf:cHorDoc    := ""
         ::oDbf:cMinDoc    := ""

         ::oDbf:cCodPgo    := ( D():PedidosClientesPagos( ::nView ) )->cCodPgo

         ::oDbf:cCodCli    := ( D():PedidosClientesPagos( ::nView ) )->cCodCli
         ::oDbf:cNomCli    := RetFld( ( D():PedidosClientesPagos( ::nView ) )->cSerPed + Str( ( D():PedidosClientesPagos( ::nView ) )->nNumPed ) + ( D():PedidosClientesPagos( ::nView ) )->cSufPed, ( D():PedidosClientes( ::nView ) ), "cNomCli", "NNUMPED" )

         ::oDbf:cCodAge    := ( D():PedidosClientesPagos( ::nView ) )->cCodAge
         
         ::oDbf:nTotNet    := ( D():PedidosClientesPagos( ::nView ) )->nImporte
         ::oDbf:cTurno     := ( D():PedidosClientesPagos( ::nView ) )->cTurRec
         ::oDbf:lCobRec    := .t.

         // Añadimos un nuevo registro--------------------------------------------

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ( D():PedidosClientesPagos( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while

      /*
      Entregas a cuentas de albaranes de clientes
      */

      ( D():PedidosClientesPagos( ::nView ) )->( OrdSetFocus( "nNumPed" ) )

      // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := '!Field->lPasado .and. ( Field->dEntrega >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dEntrega <= Ctod( "' + Dtoc( ::dFinInf ) + '" ) )'
      
      if !Empty( ::oGrupoSerie )
         ::cExpresionHeader       += ' .and. ( Field->cSerAlb >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerAlb <= "' + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '" )'
      end if

      if !Empty( ::oGrupoSufijo )
         ::cExpresionHeader       += ' .and. ( Field->cSufAlb >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufAlb <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'
      end if
      
      ::cExpresionHeader          += ' .and. ( Field->cCodPgo >= "' + ::oGrupoFpago:Cargo:Desde + '" .and. Field->cCodPgo <= "' + ::oGrupoFpago:Cargo:Hasta + '" )'

      // Procesando entregas de pedidos------------------------------------------------------

      ::setMeterText( "Procesando entregas en albaranes" )

      ( D():AlbaranesClientesCobros( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():TiketsCobros( ::nView ) )->( dbcustomkeycount() ) )

      ( D():AlbaranesClientesCobros( ::nView ) )->( dbgotop() )
      while !::lBreak .and. !( D():AlbaranesClientesCobros( ::nView ) )->( eof() )

         ::oDbf:Blank()

         ::oDbf:cTipDoc    := "Entrega albarán"
         ::oDbf:cClsDoc    := ENT_ALB
         ::oDbf:cSerDoc    := ( D():AlbaranesClientesCobros( ::nView ) )->cSerAlb
         ::oDbf:cNumDoc    := Str( ( D():AlbaranesClientesCobros( ::nView ) )->nNumAlb )
         ::oDbf:cSufDoc    := ( D():AlbaranesClientesCobros( ::nView ) )->cSufAlb
         ::oDbf:cNumRec    := Str( ( D():AlbaranesClientesCobros( ::nView ) )->nNumRec )
         ::oDbf:cIdeDoc    := Upper( ::oDbf:cClsDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc

         ::oDbf:nAnoDoc    := Year( ( D():AlbaranesClientesCobros( ::nView ) )->dEntrega )
         ::oDbf:nMesDoc    := Month( ( D():AlbaranesClientesCobros( ::nView ) )->dEntrega )
         ::oDbf:dFecDoc    := ( D():AlbaranesClientesCobros( ::nView ) )->dEntrega
         ::oDbf:cHorDoc    := ""
         ::oDbf:cMinDoc    := ""

         ::oDbf:cCodPgo    := ( D():AlbaranesClientesCobros( ::nView ) )->cCodPgo

         ::oDbf:cCodCli    := ( D():AlbaranesClientesCobros( ::nView ) )->cCodCli
         ::oDbf:cNomCli    := RetFld( ( D():AlbaranesClientesCobros( ::nView ) )->cSerAlb + Str( ( D():AlbaranesClientesCobros( ::nView ) )->nNumAlb ) + ( D():AlbaranesClientesCobros( ::nView ) )->cSufAlb, ( D():AlbaranesClientes( ::nView ) ), "cNomCli", "NNUMALB" )

         ::oDbf:cCodAge    := ( D():AlbaranesClientesCobros( ::nView ) )->cCodAge
         
         ::oDbf:nTotNet    := ( D():AlbaranesClientesCobros( ::nView ) )->nImporte
         ::oDbf:cTurno     := ( D():AlbaranesClientesCobros( ::nView ) )->cTurRec
         ::oDbf:lCobRec    := .t.

         // Añadimos un nuevo registro--------------------------------------------

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ( D():AlbaranesClientesCobros( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while

      /*
      Recibos de facturas de clientes
      */

      ( D():FacturasClientesCobros( ::nView ) )->( OrdSetFocus( "dEntrada" ) )

      // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := 'Field->lCobrado .and. ( Field->dEntrada >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dEntrada <= Ctod( "' + Dtoc( ::dFinInf ) + '" ) )'
      
      if !Empty( ::oGrupoSerie )
         ::cExpresionHeader       += ' .and. Field->cSerie >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerie <= "' + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '"'
      end if

      if !Empty( ::oGrupoSufijo )
         ::cExpresionHeader       += ' .and. ( Field->cSufFac >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufFac <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'
      end if

      ::setFilterClientIdHeader()

      ::setFilterPaymentId()

      ::setFilterAgentId()
      
      // Procesando recibos------------------------------------------------------

      ::setMeterText( "Procesando recibos" )

      ( D():FacturasClientesCobros( ::nView ) )->( setCustomFilter( ::cExpresionHeader ))

      ::setMeterTotal( ( D():FacturasClientesCobros( ::nView ) )->( dbcustomkeycount() ) )

      ( D():FacturasClientesCobros( ::nView ) )->( dbgotop() )
      while !::lBreak .and. !( D():FacturasClientesCobros( ::nView ) )->( eof() )

         ::oDbf:Blank()

         ::oDbf:cCodCli    := ( D():FacturasClientesCobros( ::nView ) )->cCodCli
         ::oDbf:cNomCli    := ( D():FacturasClientesCobros( ::nView ) )->cNomCli
         ::oDbf:cCodAge    := ( D():FacturasClientesCobros( ::nView ) )->cCodAge
         ::oDbf:cCodPgo    := ( D():FacturasClientesCobros( ::nView ) )->cCodPgo
         ::oDbf:cCodUsr    := ( D():FacturasClientesCobros( ::nView ) )->cCodUsr
         ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( ( D():FacturasClientesCobros( ::nView ) )->cCodUsr )

         ::oDbf:cCodRut    := RetFld( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), 'cCodRut' )
         ::oDbf:cCodPos    := RetFld( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), 'cCodPos' )
         ::oDbf:cCodGrp    := RetFld( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod")

         ::oDbf:cTipDoc    := "Recibos clientes"
         ::oDbf:cClsDoc    := REC_CLI          
         ::oDbf:cSerDoc    := ( D():FacturasClientesCobros( ::nView ) )->cSerie
         ::oDbf:cNumDoc    := Str( ( D():FacturasClientesCobros( ::nView ) )->nNumFac )
         ::oDbf:cSufDoc    := ( D():FacturasClientesCobros( ::nView ) )->cSufFac
         ::oDbf:cNumRec    := Str( ( D():FacturasClientesCobros( ::nView ) )->nNumRec )
         ::oDbf:cIdeDoc    := Upper( ::oDbf:cClsDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc
         ::oDbf:cTipRec    := ( D():FacturasClientesCobros( ::nView ) )->cTipRec

         ::oDbf:lCobRec    := ( D():FacturasClientesCobros( ::nView ) )->lCobrado

         ::oDbf:nAnoDoc    := Year( ( D():FacturasClientesCobros( ::nView ) )->dPreCob )
         ::oDbf:nMesDoc    := Month( ( D():FacturasClientesCobros( ::nView ) )->dPreCob )
         ::oDbf:dFecDoc    := ( D():FacturasClientesCobros( ::nView ) )->dPreCob
         ::oDbf:cHorDoc    := SubStr( ( D():FacturasClientesCobros( ::nView ) )->cHorCre, 1, 2 )
         ::oDbf:cMinDoc    := SubStr( ( D():FacturasClientesCobros( ::nView ) )->cHorCre, 4, 2 )

         ::oDbf:nTotNet    := nTotRecCli( D():FacturasClientesCobros( ::nView ) )
         ::oDbf:nTotCob    := nTotCobCli( D():FacturasClientesCobros( ::nView ) )

         ::oDbf:nNumRem    := ( D():FacturasClientesCobros( ::nView ) )->nNumRem
         ::oDbf:cSufRem    := ( D():FacturasClientesCobros( ::nView ) )->cSufRem

         ::oDbf:dFecVto    := ( D():FacturasClientesCobros( ::nView ) )->dFecVto

         ::oDbf:cEstado    := cEstadoRecibo( D():FacturasClientesCobros( ::nView ) )

         ::oDbf:nRieCli    := RetFld( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
         ::oDbf:cDniCli    := RetFld( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

         // Añadimos un nuevo registro--------------------------------------------

         if ::lValidRegister()
            ::oDbf:Insert()
         else
            ::oDbf:Cancel()
         end if

         ( D():FacturasClientesCobros( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while

   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir entregas a cuenta" )

   END SEQUENCE

   ErrorBlock( oBlock )


RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD insertFacturaCliente()

   local sTot
   local oError
   local oBlock
   local aTotIva

   oBlock                        := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
   
      ( D():FacturasClientesFecha( ::nView ) )->( OrdSetFocus( "dFecFac" ) )
      ( D():FacturasClientesLineas( ::nView ) )->( OrdSetFocus( "nNumFac" ) )

   // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := 'Field->dFecFac >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecFac <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
      ::cExpresionHeader          += ' .and. Field->cSerie >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerie <= "'    + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '"'
      ::cExpresionHeader          += ' .and. ( Field->cSufFac >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufFac <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'

      ::setFilterClientIdHeader()

      ::setFilterPaymentId()

      ::setFilterRouteId()

      ::setFilterAgentId()
      
      ::setFilterAlmacenId()

      // Procesando facturas-----------------------------------------------------

      ::setMeterText( "Procesando facturas" )

      ( D():FacturasClientesFecha( ::nView ) )->( setCustomFilter ( ::cExpresionHeader))

      ::setMeterTotal( ( D():FacturasClientesFecha( ::nView ) )->( dbcustomkeycount() ) )

      ( D():FacturasClientesFecha( ::nView ) )->( dbgotop() )

      while !::lBreak .and. !( D():FacturasClientesFecha( ::nView ) )-> ( eof() )

         sTot                    := sTotFacCli( ( D():FacturasClientesFecha( ::nView ) )->cSerie + Str( ( D():FacturasClientesFecha( ::nView ) )->nNumFac ) + ( D():FacturasClientesFecha( ::nView ) )->cSufFac, D():FacturasClientesFecha( ::nView ), D():FacturasClientesLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ), D():FacturasClientesCobros( ::nView ), D():AnticiposClientes( ::nView ) )

         for each aTotIva in sTot:aTotalIva 

            if aTotIva[ 8 ] != 0       .and.;
               ( cCodigoIva( D():TiposIva( ::nView ), aTotIva[ 3 ] ) >= ::oGrupoIva:Cargo:Desde .and. cCodigoIva( D():TiposIva( ::nView ), aTotIva[ 3 ] ) <= ::oGrupoIva:Cargo:Hasta )

               ::oDbf:Blank()

               ::oDbf:cCodCli    := ( D():FacturasClientesFecha( ::nView ) )->cCodCli
               ::oDbf:cNomCli    := ( D():FacturasClientesFecha( ::nView ) )->cNomCli
               ::oDbf:cCodAge    := ( D():FacturasClientesFecha( ::nView ) )->cCodAge
               ::oDbf:cCodPgo    := ( D():FacturasClientesFecha( ::nView ) )->cCodPago
               ::oDbf:cCodRut    := ( D():FacturasClientesFecha( ::nView ) )->cCodRut
               ::oDbf:cCodUsr    := ( D():FacturasClientesFecha( ::nView ) )->cCodUsr
               ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( ( D():FacturasClientesFecha( ::nView ) )->cCodUsr )
               ::oDbf:cCodObr    := ( D():FacturasClientesFecha( ::nView ) )->cCodObr
               ::oDbf:nComAge    := ( D():FacturasClientesFecha( ::nView ) )->nPctComAge

               ::oDbf:cCodAlm    := ( D():FacturasClientesFecha( ::nView ) )->cCodAlm

               ::oDbf:cCodPos    := ( D():FacturasClientesFecha( ::nView ) )->cPosCli

               ::oDbf:cCodGrp    := RetFld( ( D():FacturasClientesFecha( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod")

               ::oDbf:cTipDoc    := "Factura clientes"
               ::oDbf:cClsDoc    := FAC_CLI          
               ::oDbf:cSerDoc    := ( D():FacturasClientesFecha( ::nView ) )->cSerie
               ::oDbf:cNumDoc    := Str( ( D():FacturasClientesFecha( ::nView ) )->nNumFac )
               ::oDbf:cSufDoc    := ( D():FacturasClientesFecha( ::nView ) )->cSufFac
               ::oDbf:cIdeDoc    := Upper( ::oDbf:cTipDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc

               ::oDbf:nAnoDoc    := Year( ( D():FacturasClientesFecha( ::nView ) )->dFecFac )
               ::oDbf:nMesDoc    := Month( ( D():FacturasClientesFecha( ::nView ) )->dFecFac )
               ::oDbf:dFecDoc    := ( D():FacturasClientesFecha( ::nView ) )->dFecFac
               ::oDbf:cHorDoc    := SubStr( ( D():FacturasClientesFecha( ::nView ) )->cTimCre, 1, 2 )
               ::oDbf:cMinDoc    := SubStr( ( D():FacturasClientesFecha( ::nView ) )->cTimCre, 4, 2 )

               ::oDbf:nIva       := aTotIva[ 3 ]
               ::oDbf:nReq       := aTotIva[ 4 ]
               ::oDbf:nTotNet    := aTotIva[ 2 ]
               ::oDbf:nTotIva    := aTotIva[ 8 ]
               ::oDbf:nTotReq    := aTotIva[ 9 ]
               ::oDbf:nTotDoc    := sTot:nTotalDocumento
               ::oDbf:nTotPnt    := aTotIva[ 5 ]
               ::oDbf:nTotTrn    := aTotIva[ 7 ]
               ::oDbf:nTotCos    := sTot:nTotalCosto
               ::oDbf:nTotIvm    := aTotIva[ 6 ]
               ::oDbf:nTotRnt    := sTot:nTotalRentabilidad
               ::oDbf:nTotRet    := sTot:nTotalRetencion
               ::oDbf:nTotCob    := sTot:nTotalCobrado
               
               ::oDbf:nRieCli    := RetFld( ( D():FacturasClientesFecha( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
               ::oDbf:cDniCli    := RetFld( ( D():FacturasClientesFecha( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

               /*
               Aóadimos un nuevo registro--------------------------------------------
               */

               if ::lValidRegister()
                  ::oDbf:Insert()
               else
                  ::oDbf:Cancel()
               end if

            end if

         next

         ( D():FacturasClientesFecha( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while
   
   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir facturas de clientes" )

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD insertRectificativa()

   local sTot
   local oError
   local oBlock
   local aTotIva
   
   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
   
      ( D():FacturasRectificativas( ::nView ) )->( OrdSetFocus( "dFecFac" ) )
      ( D():FacturasRectificativasLineas( ::nView ) )->( OrdSetFocus( "nNumFac" ) )

      // filtros para la cabecera------------------------------------------------

      ::cExpresionHeader          := 'Field->dFecFac >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecFac <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
      ::cExpresionHeader          += ' .and. Field->cSerie >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerie <= "'    + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '"'
      ::cExpresionHeader          += ' .and. ( Field->cSufFac >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufFac <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'
      
      ::setFilterClientIdHeader()

      ::setFilterPaymentId()

      ::setFilterRouteId()

      ::setFilterAgentId()
      
      ::setFilterAlmacenId()

      // Procesando facturas rectificativas--------------------------------------

      ::setMeterText( "Procesando facturas rectificativas" )
      
      ( D():FacturasRectificativas( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():FacturasRectificativas( ::nView ) )->( dbcustomkeycount() ) )

      ( D():FacturasRectificativas( ::nView ) )->( dbgotop() )
      
      while !::lBreak .and. !( D():FacturasRectificativas( ::nView ) )->( Eof() )

         sTot              := sTotFacRec( ( D():FacturasRectificativas( ::nView ) )->cSerie + Str( ( D():FacturasRectificativas( ::nView ) )->nNumFac ) + ( D():FacturasRectificativas( ::nView ) )->cSufFac, D():FacturasRectificativas( ::nView ), D():FacturasRectificativasLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ), D():FacturasClientesCobros( ::nView ) )

         for each aTotIva in sTot:aTotalIva 

            if aTotIva[ 8 ] != 0       .and.;
               ( cCodigoIva( D():TiposIva( ::nView ), aTotIva[ 3 ] ) >= ::oGrupoIva:Cargo:Desde .and. cCodigoIva( D():TiposIva( ::nView ), aTotIva[ 3 ] ) <= ::oGrupoIva:Cargo:Hasta )

               ::oDbf:Blank()

               ::oDbf:cCodCli    := ( D():FacturasRectificativas( ::nView ) )->cCodCli            
               ::oDbf:cNomCli    := ( D():FacturasRectificativas( ::nView ) )->cNomCli
               ::oDbf:cCodAge    := ( D():FacturasRectificativas( ::nView ) )->cCodAge
               ::oDbf:cCodPgo    := ( D():FacturasRectificativas( ::nView ) )->cCodPago
               ::oDbf:cCodRut    := ( D():FacturasRectificativas( ::nView ) )->cCodRut
               ::oDbf:cCodUsr    := ( D():FacturasRectificativas( ::nView ) )->cCodUsr
               ::oDbf:cNomUsr    := UsuariosModel():getNombreWhereCodigo( ( D():FacturasRectificativas( ::nView ) )->cCodUsr )
               ::oDbf:cCodObr    := ( D():FacturasRectificativas( ::nView ) )->cCodObr
               ::oDbf:nComAge    := ( D():FacturasRectificativas( ::nView ) )->nPctComAge
               ::oDbf:cCodAlm    := ( D():FacturasRectificativas( ::nView ) )->cCodAlm

               ::oDbf:cCodPos    := ( D():FacturasRectificativas( ::nView ) )->cPosCli

               ::oDbf:cCodGrp    := RetFld( ( D():FacturasRectificativas( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "cCodGrp", "Cod" )

               ::oDbf:cTipDoc    := "Factura rectificativa"
               ::oDbf:cClsDoc    := FAC_REC
               ::oDbf:cSerDoc    := ( D():FacturasRectificativas( ::nView ) )->cSerie
               ::oDbf:cNumDoc    := Str( ( D():FacturasRectificativas( ::nView ) )->cNumFac )
               ::oDbf:cSufDoc    := ( D():FacturasRectificativas( ::nView ) )->cSufFac
               ::oDbf:cIdeDoc    := Upper( ::oDbf:cTipDoc ) + ::oDbf:cSerDoc + ::oDbf:cNumDoc + ::oDbf:cSufDoc

               ::oDbf:nAnoDoc    := Year( ( D():FacturasRectificativas( ::nView ) )->dFecFac )
               ::oDbf:nMesDoc    := Month( ( D():FacturasRectificativas( ::nView ) )->dFecFac )
               ::oDbf:dFecDoc    := ( D():FacturasRectificativas( ::nView ) )->cFecFac
               ::oDbf:cHorDoc    := SubStr( ( D():FacturasRectificativas( ::nView ) )->cTimCre, 1, 2 )
               ::oDbf:cMinDoc    := SubStr( ( D():FacturasRectificativas( ::nView ) )->cTimCre, 4, 2 )

               ::oDbf:nIva       := aTotIva[ 3 ]
               ::oDbf:nReq       := aTotIva[ 4 ]
               ::oDbf:nTotNet    := aTotIva[ 2 ]
               ::oDbf:nTotIva    := aTotIva[ 8 ]
               ::oDbf:nTotReq    := aTotIva[ 9 ]
               ::oDbf:nTotDoc    := sTot:nTotalDocumento
               ::oDbf:nTotPnt    := aTotIva[ 5 ]
               ::oDbf:nTotTrn    := aTotIva[ 7 ]
               ::oDbf:nTotCos    := sTot:nTotalCosto
               ::oDbf:nTotIvm    := aTotIva[ 6 ]
               ::oDbf:nTotRnt    := sTot:nTotalRentabilidad
               ::oDbf:nTotRet    := sTot:nTotalRetencion
               ::oDbf:nTotCob    := sTot:nTotalCobrado

               ::oDbf:nRieCli    := RetFld( ( D():FacturasRectificativas( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
               ::oDbf:cDniCli    := RetFld( ( D():FacturasRectificativas( ::nView ) )->cCodCli, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

               /*
               Aóadimos un nuevo registro--------------------------------------------
               */

               if ::lValidRegister()
                  ::oDbf:Insert()
               else
                  ::oDbf:Cancel()
               end if

               ::addFacturasRectificativasClientes()

            end if

         next

         ( D():FacturasRectificativas( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while
   
   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir facturas rectificativa" )

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD insertTicketCliente()

   local sTot
   local oError
   local oBlock
   local nPosIva        := 1

   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE
      
      ( D():TiketsClientes( ::nView ) )->( OrdSetFocus( "dFecTik" ) )
      ( D():TiketsLineas( ::nView ) )->( OrdSetFocus( "cNumTik" ) )
   
   // filtros para la cabecera------------------------------------------------
   
      ::cExpresionHeader          := 'Field->dFecTik >= Ctod( "' + Dtoc( ::dIniInf ) + '" ) .and. Field->dFecTik <= Ctod( "' + Dtoc( ::dFinInf ) + '" )'
      ::cExpresionHeader          += ' .and. Rtrim( cCliTik ) >= "' + Rtrim( ::oGrupoCliente:Cargo:Desde )   + '" .and. Rtrim( cCliTik ) <= "' + Rtrim( ::oGrupoCliente:Cargo:Hasta ) + '"'
      ::cExpresionHeader          += ' .and. Field->cSerTik >= "' + Rtrim( ::oGrupoSerie:Cargo:Desde ) + '" .and. Field->cSerTik <= "'    + Rtrim( ::oGrupoSerie:Cargo:Hasta ) + '"'
      ::cExpresionHeader          += ' .and. ( Field->cSufTik >= "' + Rtrim( ::oGrupoSufijo:Cargo:Desde ) + '" .and. Field->cSufTik <= "' + Rtrim( ::oGrupoSufijo:Cargo:Hasta ) + '" )'

      ::setFilterRouteId()

      ::setFilterAgentId()

      ::setFilterAlmacenId()

   // Procesando tickets------------------------------------------------

      ::setMeterText( "Procesando tickets" )
      
      ( D():TiketsClientes( ::nView ) )->( setCustomFilter( ::cExpresionHeader ) )

      ::setMeterTotal( ( D():TiketsClientes( ::nView ) )->( dbcustomkeycount() ) )

      ( D():TiketsClientes( ::nView ) )->( dbgotop() )
      
      while !::lBreak .and. !( D():TiketsClientes( ::nView ) )->( eof() )

         sTot              := sTotTikCli( ( D():TiketsClientes( ::nView ) )->cSerTik + ( D():TiketsClientes( ::nView ) )->cNumTik + ( D():TiketsClientes( ::nView ) )->cSufTik, D():TiketsClientes( ::nView ), D():TiketsLineas( ::nView ), D():Divisas( ::nView ) )

         for nPosIva := 1 to 3

            if sTot:aIvaTik[ nPosIva ] != nil
               
               if ( cCodigoIva( D():TiposIva( ::nView ), sTot:aIvaTik[ nPosIva ] ) >= ::oGrupoIva:Cargo:Desde .and. cCodigoIva( D():TiposIva( ::nView ), sTot:aIvaTik[ nPosIva ] ) <= ::oGrupoIva:Cargo:Hasta )

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

                  ::oDbf:nIva       := sTot:aIvaTik[ nPosIva ]
                  ::oDbf:nReq       := 0
                  ::oDbf:nTotNet    := sTot:aBasTik[ nPosIva ]
                  ::oDbf:nTotIva    := sTot:nTotalIva
                  ::oDbf:nTotDoc    := sTot:nTotalDocumento
                  ::oDbf:nTotAge    := sTot:nTotalAgente
                  ::oDbf:nTotCos    := sTot:nTotalCosto
                  ::oDbf:nTotIvm    := sTot:aIvmTik[ nPosIva ]
                  ::oDbf:nTotRnt    := sTot:nTotalRentabilidad
                  ::oDbf:nTotCob    := sTot:nTotalCobrado

                  ::oDbf:nRieCli    := RetFld( ( D():TiketsClientes( ::nView ) )->cCliTik, ( D():Clientes( ::nView ) ), "Riesgo", "Cod" )
                  ::oDbf:cDniCli    := RetFld( ( D():TiketsClientes( ::nView ) )->cCliTik, ( D():Clientes( ::nView ) ), "Nif", "Cod" )

                  /*
                  Aóadimos un nuevo registro--------------------------------------------
                  */

                  if ::lValidRegister()
                     ::oDbf:Insert()
                  else
                     ::oDbf:Cancel()
                  end if

                  ::addTicketsClientes()

               end if

            end if

         next

         ( D():TiketsClientes( ::nView ) )->( dbskip() )

         ::setMeterAutoIncremental()

      end while
   
   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible añadir facturas de clientes" )

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddClientes() CLASS TFastVentasClientes

   ::setMeterTotal( ( D():Clientes( ::nView ) )->( dbcustomkeycount() ) )

   ::setMeterText( "Procesando clientes" )

   /*
   Recorremos clientes---------------------------------------------------------
   */

   ( D():Clientes( ::nView ) )->( dbgotop() )

   while !( D():Clientes( ::nView ) )->( Eof() ) .and. !::lBreak

      ::oDbf:Blank()

      ::oDbf:cCodCli := ( D():Clientes( ::nView ) )->Cod
      ::oDbf:cNomCli := ( D():Clientes( ::nView ) )->Titulo
      ::oDbf:cCodGrp := ( D():Clientes( ::nView ) )->cCodGrp
      ::oDbf:cCodPgo := ( D():Clientes( ::nView ) )->CodPago
      ::oDbf:cCodRut := ( D():Clientes( ::nView ) )->cCodRut
      ::oDbf:cCodAge := ( D():Clientes( ::nView ) )->cAgente
      ::oDbf:cCodPos := ( D():Clientes( ::nView ) )->CodPostal
      ::oDbf:nRieCli := ( D():Clientes( ::nView ) )->Riesgo
      ::oDbf:cDniCli := ( D():Clientes( ::nView ) )->Nif
      ::oDbf:nTotVta := ::nTotalVentasCliente()

      if ::lValidRegister()
         ::oDbf:Insert()
      else
         ::oDbf:Cancel()
      end if

      ( D():Clientes( ::nView ) )->( dbskip() )

      ::setMeterAutoIncremental()

   end while

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD loadValuesExtraFields() CLASS TFastVentasClientes

   local cField
   local uValor

   if isArray( ::aExtraFields ) .and. len( ::aExtraFields ) != 0

      for each cField in ::aExtraFields

         uValor             := ::oCamposExtra:valueExtraField( cField[ "código" ], ::oDbf:cSerDoc + Padr( ::oDbf:cNumDoc, 9 ) + ::oDbf:cSufDoc, cField )

         ::oDbf:fieldPutByName( "fld" + cField[ "código" ], uValor )

      next

   end if

Return nil

//---------------------------------------------------------------------------//

METHOD nTotalVentasCliente() CLASS TFastVentasClientes

local nTotalVentas   := 0

   nTotalVentas         += nVtaAlbCli( ::oDbf:cCodCli, ::dIniInf, ::dFinInf, D():AlbaranesClientes( ::nView ), D():AlbaranesClientesLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ), .t. )
   nTotalVentas         += nVtaFacCli( ::oDbf:cCodCli, ::dIniInf, ::dFinInf, D():FacturasClientes( ::nView ), D():FacturasClientesLineas( ::nView ), D():FacturasClientesCobros( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ) )
   nTotalVentas         += nVtaFacRec( ::oDbf:cCodCli, ::dIniInf, ::dFinInf, D():FacturasRectificativas( ::nView ), D():FacturasRectificativasLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ) )
   nTotalVentas         += nVtaTik( ::oDbf:cCodCli, ::dIniInf, ::dFinInf, D():TiketsClientes( ::nView ), D():TiketsLineas( ::nView ), D():TiposIva( ::nView ), D():Divisas( ::nView ) )

Return ( nTotalVentas ) 

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TFastVentasRecibos FROM TFastVentasClientes

   METHOD BuildTree( oTree, lLoadFile ) 

   METHOD lResource() 

   METHOD lResource()
   
   METHOD Create( uParam )

END CLASS

//----------------------------------------------------------------------------//

METHOD BuildTree( oTree, lLoadFile ) CLASS TFastVentasRecibos

   local aReports

   DEFAULT oTree     := ::oTreeReporting
   DEFAULT lLoadFile := .t.

   aReports          := {  {  "Title" => "Recibos fecha de emisión",;                
                                 "Image" =>21,; 
                                 "Type" => "Recibos emisión",;              
                                 "Directory" => "Clientes\Ventas\Recibos",;                      
                                 "File" => "Recibos de clientes.fr3" },;
                           {  "Title" => "Recibos fecha de cobro",; 
                                 "Image" =>21,; 
                                 "Type" => "Recibos cobro",;        
                                 "Directory" => "Clientes\Ventas\RecibosCobro",;      
                                 "File" => "Recibos de clientes fecha de cobro.fr3" },;
                           { "Title" => "Recibos fecha de vencimiento",;
                                 "Image" =>21,; 
                                 "Type" => "Recibos vencimiento",;  
                                 "Directory" => "Clientes\Ventas\RecibosVencimiento",; 
                                 "File" => "Recibos de clientes fecha de vencimiento.fr3" } }

   ::BuildNode( aReports, oTree, lLoadFile ) 

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD lResource() CLASS TFastVentasRecibos

   ::Super:lResource()

   if !::lGrupoRemesas( .t. )
      return .t.
   end if 

   if !::lGrupoSufijo( .t. )
      return .t.
   end if 

RETURN .t.

//---------------------------------------------------------------------------//

METHOD Create( uParam ) CLASS TFastVentasRecibos

   ::Super:Create( uParam )

RETURN ( self )

//---------------------------------------------------------------------------//

