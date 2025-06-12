#include "FiveWin.Ch"
#include "HbXml.ch"
#include "TDbfDbf.ch"
#include "Struct.ch"
#include "Factu.ch" 
#include "Ini.ch"
#include "MesDbf.ch"
#include "Report.ch"
#include "Print.ch"

//---------------------------------------------------------------------------//

Function FacturarEntrega( nView, nMode, dbfTmpPgo, aTmp, dbfTmpLin )

   if nMode != EDIT_MODE
      MsgStop( "No puede generar la factura añadiendo el pedido" )
      return ( nil )
   end if

   if ( dbfTmpPgo )->lPasado
      MsgStop( "El pago ya ha sido facturado" )
      return ( nil )
   end if

   CreaFacturaCliente():Run( nView, dbfTmpPgo, aTmp, dbfTmpLin )

Return ( nil )

//---------------------------------------------------------------------------//

CLASS CreaFacturaCliente

   DATA nView
   DATA dbfTmpPgo
   DATA aTmp
   DATA dbfTmpLin

   DATA cSerieFactura
   DATA nNumeroFactura
   DATA cSufijoFactura

   METHOD Run( nView, dbfTmpPgo, aTmp, dbfTmpLin )

   METHOD AddCabeceraFactura()

   METHOD AddLineasFactura()

   METHOD AddPagosFactura()

   METHOD AddTotalesFactura()

   METHOD MarcaPasadoPago()

   METHOD getTipoIva()
   
ENDCLASS

//---------------------------------------------------------------------------//

METHOD Run( nView, dbfTmpPgo, aTmp, dbfTmpLin ) CLASS CreaFacturaCliente 

   ::nView           := nView
   ::dbfTmpPgo       := dbfTmpPgo
   ::aTmp            := aTmp
   ::dbfTmpLin       := dbfTmpLin

   ::cSerieFactura   := ""
   ::nNumeroFactura  := 0
   ::cSufijoFactura  := ""

   ::AddCabeceraFactura()
   ::AddLineasFactura()
   ::AddPagosFactura()
   ::AddTotalesFactura()

   ::MarcaPasadoPago()

   Msginfo( "Factura generada " + ::cSerieFactura + "/" + AllTrim( Str( ::nNumeroFactura ) ) + "/" + ::cSufijoFactura, "Proceso finalizado" )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddCabeceraFactura() CLASS CreaFacturaCliente 

   ::cSerieFactura   := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cSerPed" ) ) ]
   ::cSufijoFactura  := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cSufPed" ) ) ]
   ::nNumeroFactura  := nNewDoc( ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cSerPed" ) ) ], D():FacturasClientes( ::nView ), "nFacCli", 9, D():Contadores( ::nView ) )

   ( D():FacturasClientes( ::nView ) )->( dbAppend() )

   ( D():FacturasClientes( ::nView ) )->cSerie     := ::cSerieFactura
   ( D():FacturasClientes( ::nView ) )->nNumFac    := ::nNumeroFactura
   ( D():FacturasClientes( ::nView ) )->cSufFac    := ::cSufijoFactura
   ( D():FacturasClientes( ::nView ) )->cGuid      := win_uuidcreatestring()
   ( D():FacturasClientes( ::nView ) )->dFecFac    := GetSysDate()
   ( D():FacturasClientes( ::nView ) )->cTurFac    := cCurSesion( nil, .f.)
   ( D():FacturasClientes( ::nView ) )->cCodCli    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodCli" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cNomCli    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cNomCli" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cDirCli    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cDirCli" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cPobCli    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cPobCli" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cPrvCli    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cPrvCli" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cPosCli    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cPosCli" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cDniCli    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cDniCli" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCodAlm    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodAlm" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCodCaj    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodCaj" ) ) ]
   ( D():FacturasClientes( ::nView ) )->lModCli    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "lModCli" ) ) ]
   ( D():FacturasClientes( ::nView ) )->lMayor     := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "lMayor" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nTarifa    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nTarifa" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCodAge    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodAge" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCodRut    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodRut" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCodTar    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodTar" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCodObr    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodObr" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nPctComAge := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nPctComAge" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCondent   := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCondent" ) ) ]
   ( D():FacturasClientes( ::nView ) )->mComEnt    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "mComEnt" ) ) ]
   ( D():FacturasClientes( ::nView ) )->mObserv    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "mObserv" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCodPago   := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodPgo" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nBultos    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nBultos" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nManObr    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nManObr" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nIvaMan    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nIvaMan" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cManObr    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cManObr" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cDtoEsp    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cDtoEsp" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nDtoEsp    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nDtoEsp" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cDpp       := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cDpp" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nDpp       := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nDpp" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cDtoUno    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cDtoUno" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nDtoUno    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nDtoUno" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cDtoDos    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cDtoDos" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nDtoDos    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nDtoDos" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nDtoCnt    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nDtoCnt" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nDtoRap    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nDtoRap" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nDtoPub    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nDtoPub" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nDtoPgo    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nDtoPgo" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nDtoPtf    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nDtoPtf" ) ) ]
   ( D():FacturasClientes( ::nView ) )->lIvaInc    := .t.
   ( D():FacturasClientes( ::nView ) )->cDivFac    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cDivPed" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nVdvFac    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nVdvPed" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cRetPor    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cRetPor" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nRegIva    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nRegIva" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCodTrn    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodTrn" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nKgsTrn    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nKgsTrn" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCodUsr    := Auth():Codigo()
   ( D():FacturasClientes( ::nView ) )->dFecCre    := Date()
   ( D():FacturasClientes( ::nView ) )->cTimCre    := Time()
   ( D():FacturasClientes( ::nView ) )->cCodGrp    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodGrp" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCodDlg    := Application():CodigoDelegacion()
   ( D():FacturasClientes( ::nView ) )->nDtoAtp    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nDtoAtp" ) ) ]
   ( D():FacturasClientes( ::nView ) )->nSbrAtp    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nSbrAtp" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cBanco     := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cBanco" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cPaisIBAN  := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cPaisIBAN" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCtrlIBAN  := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCtrlIBAN" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cEntBnc    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cEntBnc" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cSucBnc    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cSucBnc" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cDigBnc    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cDigBnc" ) ) ]
   ( D():FacturasClientes( ::nView ) )->cCtaBnc    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCtaBnc" ) ) ]
   ( D():FacturasClientes( ::nView ) )->tFecFac    := Time()
   ( D():FacturasClientes( ::nView ) )->cCtrCoste  := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCtrCoste" ) ) ]

   ( D():FacturasClientes( ::nView ) )->( dbUnLock() )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddLineasFactura() CLASS CreaFacturaCliente 

   local nRec
   local nNumLin     := 1

   ( D():FacturasClientesLineas( ::nView ) )->( dbAppend() )
   
   ( D():FacturasClientesLineas( ::nView ) )->cSerie     := ::cSerieFactura
   ( D():FacturasClientesLineas( ::nView ) )->nNumFac    := ::nNumeroFactura
   ( D():FacturasClientesLineas( ::nView ) )->cSufFac    := ::cSufijoFactura
   ( D():FacturasClientesLineas( ::nView ) )->cDetalle   := ( ::dbfTmpPgo )->cDescrip
   ( D():FacturasClientesLineas( ::nView ) )->nPreUnit   := ( ::dbfTmpPgo )->nImporte
   ( D():FacturasClientesLineas( ::nView ) )->nCanEnt    := 1
   ( D():FacturasClientesLineas( ::nView ) )->nUniCaja   := 1
   ( D():FacturasClientesLineas( ::nView ) )->dFecha     := GetSysDate()
   ( D():FacturasClientesLineas( ::nView ) )->mLngDes    := ( ::dbfTmpPgo )->cDescrip
   ( D():FacturasClientesLineas( ::nView ) )->cAlmLin    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodAlm" ) ) ]
   ( D():FacturasClientesLineas( ::nView ) )->lIvaLin    := .t.
   ( D():FacturasClientesLineas( ::nView ) )->nIva       := ::getTipoIva()
   ( D():FacturasClientesLineas( ::nView ) )->mObsLin    := "Entrega a cuenta número " + Str( ( ::dbfTmpPgo )->nNumRec ) + " del pedido " + ( ::dbfTmpPgo )->cSerPed + "/" + AllTrim( Str( ( ::dbfTmpPgo )->nNumPed ) ) + "/" + ( ::dbfTmpPgo )->cSufPed
   ( D():FacturasClientesLineas( ::nView ) )->cCtrCoste  := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCtrCoste" ) ) ]
   ( D():FacturasClientesLineas( ::nView ) )->cFormato   := "Entrega a cuenta número " + Str( ( ::dbfTmpPgo )->nNumRec ) + " del pedido " + ( ::dbfTmpPgo )->cSerPed + "/" + AllTrim( Str( ( ::dbfTmpPgo )->nNumPed ) ) + "/" + ( ::dbfTmpPgo )->cSufPed
   ( D():FacturasClientesLineas( ::nView ) )->nNumLin    := nNumLin
   ( D():FacturasClientesLineas( ::nView ) )->nPosPrint  := nNumLin

   ( D():FacturasClientesLineas( ::nView ) )->( dbUnLock() )

   nNumLin++

   /*
   Dejamos una linea en blanco de separación-----------------------------------
   */

   ( D():FacturasClientesLineas( ::nView ) )->( dbAppend() )
   
   ( D():FacturasClientesLineas( ::nView ) )->cSerie     := ::cSerieFactura
   ( D():FacturasClientesLineas( ::nView ) )->nNumFac    := ::nNumeroFactura
   ( D():FacturasClientesLineas( ::nView ) )->cSufFac    := ::cSufijoFactura
   ( D():FacturasClientesLineas( ::nView ) )->nPreUnit   := 0
   ( D():FacturasClientesLineas( ::nView ) )->nCanEnt    := 0
   ( D():FacturasClientesLineas( ::nView ) )->nUniCaja   := 0
   ( D():FacturasClientesLineas( ::nView ) )->dFecha     := GetSysDate()
   ( D():FacturasClientesLineas( ::nView ) )->mLngDes    := "" //Pedido número " + ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cSerPed" ) ) ] + "/" + AllTrim( Str( ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "nNumPed" ) ) ] ) ) + "/" + ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cSufPed" ) ) ] + "----------------------------"
   ( D():FacturasClientesLineas( ::nView ) )->cAlmLin    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodAlm" ) ) ]
   ( D():FacturasClientesLineas( ::nView ) )->lIvaLin    := .t.
   ( D():FacturasClientesLineas( ::nView ) )->nIva       := 0
   ( D():FacturasClientesLineas( ::nView ) )->cCtrCoste  := ( ::dbfTmpLin )->cCtrCoste
   ( D():FacturasClientesLineas( ::nView ) )->nNumLin    := nNumLin
   ( D():FacturasClientesLineas( ::nView ) )->nPosPrint  := nNumLin

   ( D():FacturasClientesLineas( ::nView ) )->( dbUnLock() )

   nNumLin++

   /*
   Pasamos las lineas del pedido con valores 0---------------------------------
   */

   nRec     := ( ::dbfTmpLin )->( Recno() )

   ( ::dbfTmpLin )->( dbGoTop() )

   while !( ::dbfTmpLin )->( Eof() )

      ( D():FacturasClientesLineas( ::nView ) )->( dbAppend() )
   
      ( D():FacturasClientesLineas( ::nView ) )->cSerie     := ::cSerieFactura
      ( D():FacturasClientesLineas( ::nView ) )->nNumFac    := ::nNumeroFactura
      ( D():FacturasClientesLineas( ::nView ) )->cSufFac    := ::cSufijoFactura
      ( D():FacturasClientesLineas( ::nView ) )->cRef       := ( ::dbfTmpLin )->cRef
      ( D():FacturasClientesLineas( ::nView ) )->cDetalle   := ( ::dbfTmpLin )->cDetalle
      ( D():FacturasClientesLineas( ::nView ) )->nPreUnit   := ( ::dbfTmpLin )->nPreDiv
      ( D():FacturasClientesLineas( ::nView ) )->nCanEnt    := ( ::dbfTmpLin )->nCanPed
      ( D():FacturasClientesLineas( ::nView ) )->nUniCaja   := ( ::dbfTmpLin )->nUniCaja
      ( D():FacturasClientesLineas( ::nView ) )->nDto       := 100
      ( D():FacturasClientesLineas( ::nView ) )->dFecha     := GetSysDate()
      ( D():FacturasClientesLineas( ::nView ) )->mLngDes    := ( ::dbfTmpLin )->mLngDes
      ( D():FacturasClientesLineas( ::nView ) )->cAlmLin    := ::aTmp[ ( D():PedidosClientes( ::nView ) )->( FieldPos( "cCodAlm" ) ) ]
      ( D():FacturasClientesLineas( ::nView ) )->lIvaLin    := .t.
      ( D():FacturasClientesLineas( ::nView ) )->nIva       := 0
      ( D():FacturasClientesLineas( ::nView ) )->cCtrCoste  := ( ::dbfTmpLin )->cCtrCoste
      ( D():FacturasClientesLineas( ::nView ) )->nNumLin    := nNumLin
      ( D():FacturasClientesLineas( ::nView ) )->nPosPrint  := nNumLin

      ( D():FacturasClientesLineas( ::nView ) )->( dbUnLock() )

      nNumLin++

      ( ::dbfTmpLin )->( dbSkip() )

   end while

   ( ::dbfTmpLin )->( dbGoTo( nRec ) )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddPagosFactura() CLASS CreaFacturaCliente

   genPgoFacCli(  ::cSerieFactura + str( ::nNumeroFactura, 9 ) + ::cSufijoFactura,;
                  D():FacturasClientes( ::nView ),;
                  D():FacturasClientesLineas( ::nView ),;
                  D():FacturasClientesCobros( ::nView ),;
                  D():AnticiposClientes( ::nView ),;
                  D():Clientes( ::nView ),;
                  D():FormasPago( ::nView ),;
                  D():Divisas( ::nView ),;
                  D():TiposIva( ::nView ),;
                  APPD_MODE )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddTotalesFactura() CLASS CreaFacturaCliente

   local aTotales    := aTotFacCli( ::cSerieFactura + str( ::nNumeroFactura, 9 ) + ::cSufijoFactura,;
                                    D():FacturasClientes( ::nView ),;
                                    D():FacturasClientesLineas( ::nView ),;
                                    D():TiposIva( ::nView ),;
                                    D():Divisas( ::nView ),;
                                    D():FacturasClientesCobros( ::nView ),;
                                    D():AnticiposClientes( ::nView ) )

   if ( D():FacturasClientes( ::nView ) )->( dbSeek( ::cSerieFactura + str( ::nNumeroFactura, 9 ) + ::cSufijoFactura ) )

      if dbLock( D():FacturasClientes( ::nView ) )

         ( D():FacturasClientes( ::nView ) )->nTotNet       := aTotales[ 1 ]
         ( D():FacturasClientes( ::nView ) )->nTotIva       := aTotales[ 2 ]
         ( D():FacturasClientes( ::nView ) )->nTotReq       := aTotales[ 3 ]
         ( D():FacturasClientes( ::nView ) )->nTotFac       := aTotales[ 4 ]

         ( D():FacturasClientes( ::nView ) )->( dbUnLock() )

      end if

      ChkLqdFacCli(  nil,; 
                     D():FacturasClientes( ::nView ),; 
                     D():FacturasClientesLineas( ::nView ),; 
                     D():FacturasClientesCobros( ::nView ),; 
                     D():AnticiposClientes( ::nView ),; 
                     D():TiposIva( ::nView ),; 
                     D():Divisas( ::nView ) )

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD MarcaPasadoPago() CLASS CreaFacturaCliente

   if dbLock( ::dbfTmpPgo )
      ( ::dbfTmpPgo )->lPasado      := .t.
      ( ::dbfTmpPgo )->( dbUnLock() )
   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD getTipoIva() CLASS CreaFacturaCliente

   local nRec     := ( ::dbfTmpLin )->( Recno() )
   local nIva     := 0
   local lBreak   := .f.

   ( ::dbfTmpLin )->( dbGoTop() )
   
   while !lBreak .and. !( ::dbfTmpLin )->( Eof() )

      if ( ::dbfTmpLin )->nIva  != 0
         nIva     := ( ::dbfTmpLin )->nIva
         lBreak   := .t.
      end if

      ( ::dbfTmpLin )->( dbSkip() )

   end while

   ( ::dbfTmpLin )->( dbGoTo( nRec ) )

Return ( nIva )

//---------------------------------------------------------------------------//