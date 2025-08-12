#include "FiveWin.Ch"
#include "Factu.ch" 
 
CLASS GenInvoiceCustomer
   
   DATA oSender

   DATA hMasterDeliveryNote
   DATA aLinesDeliveryNote

   DATA cInvoiceSerie
   DATA nInvoiceNumero
   DATA cInvoiceSufijo
   DATA dInvoiceDate

   DATA cDeliveryNoteNumber

   METHOD New( oSender )

   METHOD Run()

   METHOD setMasterDeliveryNote( hMasterDeliveryNote )   INLINE ( ::hMasterDeliveryNote   := hMasterDeliveryNote )
   METHOD setLinesDeliveryNote( aLinesDeliveryNote )     INLINE ( ::aLinesDeliveryNote    := aLinesDeliveryNote )

   METHOD SetNewDatesInvoice()

   METHOD AddInvoiceHeader()

   METHOD AddInvoiceLines()

   METHOD AddInvoiceReciver()

   METHOD SetStateDeliveryNote()

   METHOD PrintInvoice()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( oSender ) CLASS GenInvoiceCustomer

   ::oSender   := oSender

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD Run() CLASS GenInvoiceCustomer

   ::SetNewDatesInvoice()

   ::AddInvoiceHeader()
   
   ::AddInvoiceLines()

   ::AddInvoiceReciver()
   
   ::SetStateDeliveryNote()

   ::PrintInvoice()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD SetNewDatesInvoice() CLASS GenInvoiceCustomer

   ::cInvoiceSerie         := hGet( ::hMasterDeliveryNote, "Serie" )
   ::nInvoiceNumero        := nNewDoc( hGet( ::hMasterDeliveryNote, "Serie" ), D():FacturasClientes( ::oSender:nView ), "nFacCli", 9, D():Contadores( ::oSender:nView ) )
   ::cInvoiceSufijo        := hGet( ::hMasterDeliveryNote, "Sufijo" )

   ::dInvoiceDate          := GetSysDate()

   ::cDeliveryNoteNumber   := hGet( ::hMasterDeliveryNote, "Serie" ) + Str( hGet( ::hMasterDeliveryNote, "Numero" ) ) + hGet( ::hMasterDeliveryNote, "Sufijo" )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD AddInvoiceHeader() CLASS GenInvoiceCustomer

   ( D():FacturasClientes( ::oSender:nView ) )->( dbappend() )

   ( D():FacturasClientes( ::oSender:nView ) )->cSerie      := ::cInvoiceSerie
   ( D():FacturasClientes( ::oSender:nView ) )->nNumFac     := ::nInvoiceNumero
   ( D():FacturasClientes( ::oSender:nView ) )->cSufFac     := ::cInvoiceSufijo
   ( D():FacturasClientes( ::oSender:nView ) )->cGuid       := win_uuidcreatestring()
   ( D():FacturasClientes( ::oSender:nView ) )->cTurFac     := cCurSesion()
   ( D():FacturasClientes( ::oSender:nView ) )->dFecFac     := ::dInvoiceDate
   ( D():FacturasClientes( ::oSender:nView ) )->cCodCli     := hGet( ::hMasterDeliveryNote, "Cliente" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCodAlm     := hGet( ::hMasterDeliveryNote, "Almacen" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCodCaj     := hGet( ::hMasterDeliveryNote, "Caja" )
   ( D():FacturasClientes( ::oSender:nView ) )->cNomCli     := hGet( ::hMasterDeliveryNote, "NombreCliente" )
   ( D():FacturasClientes( ::oSender:nView ) )->cDirCli     := hGet( ::hMasterDeliveryNote, "DomicilioCliente" )
   ( D():FacturasClientes( ::oSender:nView ) )->cPobCli     := hGet( ::hMasterDeliveryNote, "PoblacionCliente" )
   ( D():FacturasClientes( ::oSender:nView ) )->cPrvCli     := hGet( ::hMasterDeliveryNote, "ProvinciaCliente" )
   ( D():FacturasClientes( ::oSender:nView ) )->cPosCli     := hGet( ::hMasterDeliveryNote, "CodigoPostalCliente" )
   ( D():FacturasClientes( ::oSender:nView ) )->cDniCli     := hGet( ::hMasterDeliveryNote, "DniCliente" )
   ( D():FacturasClientes( ::oSender:nView ) )->lModCli     := hGet( ::hMasterDeliveryNote, "ModificarDatosCliente" )
   ( D():FacturasClientes( ::oSender:nView ) )->nTarifa     := hGet( ::hMasterDeliveryNote, "NumeroTarifa" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCodAge     := hGet( ::hMasterDeliveryNote, "Agente" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCodRut     := hGet( ::hMasterDeliveryNote, "Ruta" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCodTar     := hGet( ::hMasterDeliveryNote, "Tarifa" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCodObr     := hGet( ::hMasterDeliveryNote, "Direccion" )
   ( D():FacturasClientes( ::oSender:nView ) )->nPctComAge  := hGet( ::hMasterDeliveryNote, "ComisionAgente" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCondent    := hGet( ::hMasterDeliveryNote, "Condiciones" )
   ( D():FacturasClientes( ::oSender:nView ) )->mComEnt     := hGet( ::hMasterDeliveryNote, "Comentarios" )
   ( D():FacturasClientes( ::oSender:nView ) )->mObserv     := hGet( ::hMasterDeliveryNote, "Observaciones" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCodPago    := hGet( ::hMasterDeliveryNote, "Pago" )
   ( D():FacturasClientes( ::oSender:nView ) )->nIvaMan     := hGet( ::hMasterDeliveryNote, "ImpuestoGastos" )
   ( D():FacturasClientes( ::oSender:nView ) )->nManObr     := hGet( ::hMasterDeliveryNote, "Gastos" )
   ( D():FacturasClientes( ::oSender:nView ) )->cNumAlb     := ::cDeliveryNoteNumber
   ( D():FacturasClientes( ::oSender:nView ) )->cDtoEsp     := hGet( ::hMasterDeliveryNote, "DescripcionDescuento1" )
   ( D():FacturasClientes( ::oSender:nView ) )->nDtoEsp     := hGet( ::hMasterDeliveryNote, "PorcentajeDescuento1" )
   ( D():FacturasClientes( ::oSender:nView ) )->cDpp        := hGet( ::hMasterDeliveryNote, "DescripcionDescuento2" )
   ( D():FacturasClientes( ::oSender:nView ) )->nDpp        := hGet( ::hMasterDeliveryNote, "PorcentajeDescuento2" )
   ( D():FacturasClientes( ::oSender:nView ) )->cDtoUno     := hGet( ::hMasterDeliveryNote, "DescripcionDescuento3" )
   ( D():FacturasClientes( ::oSender:nView ) )->nDtoUno     := hGet( ::hMasterDeliveryNote, "PorcentajeDescuento3" )
   ( D():FacturasClientes( ::oSender:nView ) )->cDtoDos     := hGet( ::hMasterDeliveryNote, "DescripcionDescuento4" )
   ( D():FacturasClientes( ::oSender:nView ) )->nDtoDos     := hGet( ::hMasterDeliveryNote, "PorcentajeDescuento4" )
   ( D():FacturasClientes( ::oSender:nView ) )->nTipoIva    := hGet( ::hMasterDeliveryNote, "TipoImpuesto" )
   ( D():FacturasClientes( ::oSender:nView ) )->lIvaInc     := hGet( ::hMasterDeliveryNote, "ImpuestosIncluidos" )
   ( D():FacturasClientes( ::oSender:nView ) )->lSndDoc     := .f.
   ( D():FacturasClientes( ::oSender:nView ) )->cDivFac     := hGet( ::hMasterDeliveryNote, "Divisa" )
   ( D():FacturasClientes( ::oSender:nView ) )->nVdvFac     := hGet( ::hMasterDeliveryNote, "ValorDivisa" )
   ( D():FacturasClientes( ::oSender:nView ) )->cRetPor     := hGet( ::hMasterDeliveryNote, "RetiradoPor" )
   ( D():FacturasClientes( ::oSender:nView ) )->cRetMat     := hGet( ::hMasterDeliveryNote, "Matricula" )
   ( D():FacturasClientes( ::oSender:nView ) )->cNumDoc     := ::cDeliveryNoteNumber
   ( D():FacturasClientes( ::oSender:nView ) )->nRegIva     := hGet( ::hMasterDeliveryNote, "TipoImpuesto" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCodTrn     := hGet( ::hMasterDeliveryNote, "Transportista" )
   ( D():FacturasClientes( ::oSender:nView ) )->nKgsTrn     := hGet( ::hMasterDeliveryNote, "TaraTransportista" )
   ( D():FacturasClientes( ::oSender:nView ) )->lCloFac     := .f.
   ( D():FacturasClientes( ::oSender:nView ) )->cCodUsr     := Auth():Codigo()
   ( D():FacturasClientes( ::oSender:nView ) )->dFecCre     := GetSysDate()
   ( D():FacturasClientes( ::oSender:nView ) )->cTimCre     := getSysTime()
   ( D():FacturasClientes( ::oSender:nView ) )->cCodGrp     := hGet( ::hMasterDeliveryNote, "GrupoCliente" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCodDlg     := hGet( ::hMasterDeliveryNote, "Delegacion" )
   ( D():FacturasClientes( ::oSender:nView ) )->nDtoAtp     := hGet( ::hMasterDeliveryNote, "DescuentoAtipico" )
   ( D():FacturasClientes( ::oSender:nView ) )->nSbrAtp     := hGet( ::hMasterDeliveryNote, "LugarAplicarDescuentoAtipico" )
   ( D():FacturasClientes( ::oSender:nView ) )->cTlfCli     := hGet( ::hMasterDeliveryNote, "TelefonoCliente" )
   ( D():FacturasClientes( ::oSender:nView ) )->nTotNet     := hGet( ::hMasterDeliveryNote, "TotalNeto" )
   ( D():FacturasClientes( ::oSender:nView ) )->nTotIva     := hGet( ::hMasterDeliveryNote, "TotalImpuesto" )
   ( D():FacturasClientes( ::oSender:nView ) )->nTotReq     := hGet( ::hMasterDeliveryNote, "TotalRecargo" )
   ( D():FacturasClientes( ::oSender:nView ) )->nTotFac     := hGet( ::hMasterDeliveryNote, "TotalDocumento" )
   ( D():FacturasClientes( ::oSender:nView ) )->cBanco      := hGet( ::hMasterDeliveryNote, "NombreBanco" )
   ( D():FacturasClientes( ::oSender:nView ) )->cPaisIBAN   := hGet( ::hMasterDeliveryNote, "CuentaIBAN" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCtrlIBAN   := hGet( ::hMasterDeliveryNote, "DigitoControlIBAN" )
   ( D():FacturasClientes( ::oSender:nView ) )->cEntBnc     := hGet( ::hMasterDeliveryNote, "EntidadCuenta" )
   ( D():FacturasClientes( ::oSender:nView ) )->cSucBnc     := hGet( ::hMasterDeliveryNote, "SucursalCuenta" )
   ( D():FacturasClientes( ::oSender:nView ) )->cDigBnc     := hGet( ::hMasterDeliveryNote, "DigitoControlCuenta" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCtaBnc     := hGet( ::hMasterDeliveryNote, "CuentaBancaria" )
   ( D():FacturasClientes( ::oSender:nView ) )->lOperPV     := hGet( ::hMasterDeliveryNote, "OperarPuntoVerde" )
   ( D():FacturasClientes( ::oSender:nView ) )->tFecFac     := hGet( ::hMasterDeliveryNote, "Hora" )
   ( D():FacturasClientes( ::oSender:nView ) )->cCtrCoste   := hGet( ::hMasterDeliveryNote, "CentroCoste" )
   ( D():FacturasClientes( ::oSender:nView ) )->mFirma      := hGet( ::hMasterDeliveryNote, "Firma" )
   ( D():FacturasClientes( ::oSender:nView ) )->lFirma      := hGet( ::hMasterDeliveryNote, "ConfirmaFirma" )

   ( D():FacturasClientes( ::oSender:nView ) )->( dbUnLock() )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD AddInvoiceLines() CLASS GenInvoiceCustomer

   local hLine

   for each hLine in ::aLinesDeliveryNote

      ( D():FacturasClientesLineas( ::oSender:nView ) )->( dbappend() )

      ( D():FacturasClientesLineas( ::oSender:nView ) )->cSerie         :=  ::cInvoiceSerie
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nNumFac        :=  ::nInvoiceNumero
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cSufFac        :=  ::cInvoiceSufijo
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cRef           :=  hGet( hLine, "Articulo" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cDetalle       :=  hGet( hLine, "DescripcionArticulo" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nPreUnit       :=  hGet( hLine, "PrecioVenta" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nPntVer        :=  hGet( hLine, "PuntoVerde" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nImpTrn        :=  hGet( hLine, "Portes" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nDto           :=  hGet( hLine, "DescuentoPorcentual" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nDtoPrm        :=  hGet( hLine, "DescuentoPromocion" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nIva           :=  hGet( hLine, "PorcentajeImpuesto" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nCanEnt        :=  hGet( hLine, "Cajas" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nPesokg        :=  hGet( hLine, "Peso" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cPesokg        :=  hGet( hLine, "UnidadMedicionPeso" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cUnidad        :=  hGet( hLine, "UnidadMedicion" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCodAge        :=  hGet( ::hMasterDeliveryNote, "Agente" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nComAge        :=  hGet( hLine, "ComisionAgente" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nUniCaja       :=  hGet( hLine, "Unidades" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nUndKit        :=  hGet( hLine, "UnidadesKit" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->dFecha         :=  ::dInvoiceDate
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cTipMov        :=  hGet( hLine, "Tipo" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->mLngDes        :=  hGet( hLine, "DescripcionAmpliada" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCodAlb        :=  ::cDeliveryNoteNumber
      ( D():FacturasClientesLineas( ::oSender:nView ) )->dFecAlb        :=  hGet( ::hMasterDeliveryNote, "Fecha" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCodPr1        :=  hGet( hLine, "CodigoPropiedad1" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCodPr2        :=  hGet( hLine, "CodigoPropiedad2" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cValPr1        :=  hGet( hLine, "ValorPropiedad1" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cValPr2        :=  hGet( hLine, "ValorPropiedad2" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nDtoDiv        :=  hGet( hLine, "DescuentoLineal" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nNumLin        :=  hGet( hLine, "NumeroLinea" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nCtlStk        :=  hGet( hLine, "TipoStock" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nCosDiv        :=  hGet( hLine, "PrecioCosto" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nPvpRec        :=  hGet( hLine, "PrecioVentaRecomendado" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cAlmLin        :=  hGet( hLine, "Almacen" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->lIvaLin        :=  hGet( hLine, "LineaImpuestoIncluido" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCodImp        :=  hGet( hLine, "ImpuestoEspecial" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nValImp        :=  hGet( hLine, "ImporteImpuestoEspecial" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->lLote          :=  hGet( hLine, "LogicoLote" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cLote          :=  hGet( hLine, "Lote" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->dFecCad        :=  hGet( hLine, "FechaCaducidad" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->lKitArt        :=  hGet( hLine, "LineaEscandallo" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->lKitChl        :=  hGet( hLine, "LineaPertenecienteEscandallo" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->lKitPrc        :=  hGet( hLine, "LineaEscandalloPrecio" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nMesGrt        :=  hGet( hLine, "MesesGarantia" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->lMsgVta        :=  hGet( hLine, "AvisarSinStock" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->lNotVta        :=  hGet( hLine, "NoPermitirSinStock" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCodTip        :=  hGet( hLine, "TipoArticulo" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCodFam        :=  hGet( hLine, "Familia" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cGrpFam        :=  hGet( hLine, "GrupoFamilia" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nReq           :=  hGet( hLine, "RecargoEquivalencia" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->mObsLin        :=  hGet( hLine, "Observaciones" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCodPrv        :=  hGet( hLine, "Proveedor" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cNomPrv        :=  hGet( hLine, "NombreProveedor" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cImagen        :=  hGet( hLine, "Imagen" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cRefPrv        :=  hGet( hLine, "ReferenciaProveedor" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nVolumen       :=  hGet( hLine, "Volumen" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cVolumen       :=  hGet( hLine, "UnidadMedicionVolumen" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nNumMed        :=  hGet( hLine, "NumeroMediciones" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nMedUno        :=  hGet( hLine, "Medicion1" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nMedDos        :=  hGet( hLine, "Medicion2" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nMedTre        :=  hGet( hLine, "Medicion3" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nTarLin        :=  hGet( hLine, "NumeroTarifa" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->Descrip        :=  hGet( hLine, "DescripcionTecnica" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->lLinOfe        :=  hGet( hLine, "LineaOferta" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->lVolImp        :=  hGet( hLine, "VolumenImpuestosEspeciales" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->dFecFac        :=  ::dInvoiceDate
      ( D():FacturasClientesLineas( ::oSender:nView ) )->dFecUltCom     :=  hGet( hLine, "FechaUltimaVenta" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCodCli        :=  hGet( hLine, "Cliente" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nUniUltCom     :=  hGet( hLine, "UnidadesUltimaVenta" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->tFecFac        :=  hGet( hLine, "Hora" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCtrCoste      :=  hGet( hLine, "CentroCoste" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cCodObr        :=  hGet( hLine, "Direccion" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cRefAux        :=  hGet( hLine, "ReferenciaAuxiliar" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->cRefAux2       :=  hGet( hLine, "ReferenciaAuxiliar2" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->id_tipo_v      :=  hGet( hLine, "IdentificadorTipoVenta" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nRegIva        :=  hGet( hLine, "TipoImpuesto" )
      ( D():FacturasClientesLineas( ::oSender:nView ) )->nPrcUltCom     :=  hGet( hLine, "PrecioUltimaVenta" )

      ( D():FacturasClientesLineas( ::oSender:nView ) )->( dbUnLock() )

   next

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD AddInvoiceReciver() CLASS GenInvoiceCustomer

   local nRec     := ( D():FacturasClientes( ::oSender:nView ) )->( Recno() )
   local nOrdAnt  := ( D():FacturasClientes( ::oSender:nView ) )->( OrdSetFocus( "nNumFac" ) )

   genPgoFacCli( ::cInvoiceSerie + str( ::nInvoiceNumero, 9 ) + ::cInvoiceSufijo, D():FacturasClientes( ::oSender:nView ), D():FacturasClientesLineas( ::oSender:nView ), D():FacturasClientesCobros( ::oSender:nView ), D():AnticiposClientes( ::oSender:nView ), D():Clientes( ::oSender:nView ), D():FormasPago( ::oSender:nView ), D():Divisas( ::oSender:nView ), D():TiposIva( ::oSender:nView ), APPD_MODE )

   if ( D():FacturasClientes( ::oSender:nView ) )->( dbSeek( ::cInvoiceSerie + str( ::nInvoiceNumero, 9 ) + ::cInvoiceSufijo ) )
      ChkLqdFacCli( nil, D():FacturasClientes( ::oSender:nView ), D():FacturasClientesLineas( ::oSender:nView ), D():FacturasClientesCobros( ::oSender:nView ), D():AnticiposClientes( ::oSender:nView ), D():TiposIva( ::oSender:nView ), D():Divisas( ::oSender:nView ) )
   end if

   ( D():FacturasClientes( ::oSender:nView ) )->( OrdSetFocus( nOrdAnt ) )   
   ( D():FacturasClientes( ::oSender:nView ) )->( dbGoTo( nRec ) )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD SetStateDeliveryNote() CLASS GenInvoiceCustomer

   local nRec     := ( D():AlbaranesClientes( ::oSender:nView ) )->( Recno() )
   local nOrdAnt  := ( D():AlbaranesClientes( ::oSender:nView ) )->( OrdSetFocus( "nNumAlb" ) )

   if ( D():AlbaranesClientes( ::oSender:nView ) )->( dbSeek( ::cDeliveryNoteNumber ) )

      if dbLock( D():AlbaranesClientes( ::oSender:nView ) )
         ( D():AlbaranesClientes( ::oSender:nView ) )->lFacturado    := .t.
         ( D():AlbaranesClientes( ::oSender:nView ) )->nFacturado    := 3
         ( D():AlbaranesClientes( ::oSender:nView ) )->( dbUnLock() )
      end if

   end if

   ( D():AlbaranesClientes( ::oSender:nView ) )->( OrdSetFocus( nOrdAnt ) )   
   ( D():AlbaranesClientes( ::oSender:nView ) )->( dbGoTo( nRec ) )

   /*
   Estado de las lineas--------------------------------------------------------
   */

   nRec           := ( D():AlbaranesClientesLineas( ::oSender:nView ) )->( Recno() )
   nOrdAnt        := ( D():AlbaranesClientesLineas( ::oSender:nView ) )->( OrdSetFocus( "nNumAlb" ) )

   if ( D():AlbaranesClientesLineas( ::oSender:nView ) )->( dbSeek( ::cDeliveryNoteNumber ) )

      while ( D():AlbaranesClientesLineas( ::oSender:nView ) )->cSerAlb + Str( ( D():AlbaranesClientesLineas( ::oSender:nView ) )->nNumAlb ) + ( D():AlbaranesClientesLineas( ::oSender:nView ) )->cSufAlb == ::cDeliveryNoteNumber .and.;
            !( D():AlbaranesClientesLineas( ::oSender:nView ) )->( Eof() )

            if dbLock( D():AlbaranesClientesLineas( ::oSender:nView ) )
               ( D():AlbaranesClientesLineas( ::oSender:nView ) )->lFacturado    := .t.
               ( D():AlbaranesClientesLineas( ::oSender:nView ) )->( dbUnLock() )
            end if

         ( D():AlbaranesClientesLineas( ::oSender:nView ) )->( dbSkip() )

      end while

   end if

   ( D():AlbaranesClientes( ::oSender:nView ) )->( OrdSetFocus( nOrdAnt ) )   
   ( D():AlbaranesClientes( ::oSender:nView ) )->( dbGoTo( nRec ) )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD PrintInvoice() CLASS GenInvoiceCustomer

   if ApoloMsgNoYes( "Factura creada: " + ::cInvoiceSerie + "/" + AllTrim( Str( ::nInvoiceNumero ) ) + "/" + ::cInvoiceSufijo, "¿Desea imprimirla?", .t. )

      imprimeFacturaCliente( ::cInvoiceSerie + Str( ::nInvoiceNumero ) + ::cInvoiceSufijo )

   end if

Return ( .t. )

//---------------------------------------------------------------------------//