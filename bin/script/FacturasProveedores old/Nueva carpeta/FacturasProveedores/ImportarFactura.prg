#include "FiveWin.Ch"

#include "Hbxml.ch"
#include "Hbclass.ch"
#include "Fileio.ch"
#include "Factu.ch" 
      
//---------------------------------------------------------------------------//

Function ImportarExcelArguelles( nView )                	 
	      
   local oImportarExcel    := TImportarExcelArguelles():New( nView )

   oImportarExcel:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TImportarExcelArguelles FROM TImportarExcel

   DATA nFila
   DATA nFilaInicio
   DATA nFilaFinal
   DATA nContadorPagina
   DATA aLineasPedido
   DATA lFinPage

   DATA cSerieFactura
   DATA cNumeroFactura
   DATA cSufijoFactura

   DATA dFechaFactura
   DATA cHoraFactura

   DATA cSuFactura
   DATA nPuntoVerde

   DATA hLine

   DATA cCodigoProveedor

   DATA cError

   DATA nCount

   METHOD New()

   METHOD Run()

   METHOD getCampoClave()        INLINE ( alltrim( ::getExcelString( ::cColumnaCampoClave ) ) )

   METHOD procesaFicheroExcel()

   METHOD procesaHojaExcel( nContadorPagina )

   METHOD procesaLinea()

   METHOD procesaLote()

   METHOD getLotesLine()

   METHOD formatArrayLote( aLotes )

   METHOD addCabeceraFactura()

   METHOD addLineasFactura()

   METHOD addLineaPuntoVerde()

   METHOD recalculaFactura()

   METHOD addSuFactura()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

   ::cFicheroExcel            := cGetFile( "Excel ( *.Xlsx ) | " + "*.Xlsx", "Seleccione la hoja de calculo" )

   ::aLineasPedido            := {}

   ::nContadorPagina          := 1
   ::nFilaInicio              := 57
   ::nFilaFinal               := 84
   ::lFinPage                 := .f.

   ::cColumnaCampoClave       := 'A'

   ::cCodigoProveedor         := '0000001'

   ::hLine                    := {=>}

   ::cError                   := ""

   ::cSuFactura               := ""

   ::nPuntoVerde              := 0

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run()

   if !file( ::cFicheroExcel )
      msgStop( "El fichero " + ::cFicheroExcel + " no existe." )
      Return ( .f. )
   end if 

   msgrun( "Procesando fichero " + ::cFicheroExcel, "Espere por favor...",  {|| ::procesaFicheroExcel() } )

   ::addCabeceraFactura()

   ::addLineasFactura()

   ::addLineaPuntoVerde()

   ::RecalculaFactura()

   MsgInfo( ::cError, "Códigos que no existen" )

   msginfo( "Proceso finalizado" )

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD procesaFicheroExcel()

   ::oExcel                      := TOleExcel():New( "Importando hoja de excel", "Conectando...", .f. )

   ::oExcel:oExcel:Visible       := .t.
   ::oExcel:oExcel:DisplayAlerts := .f.
   ::oExcel:oExcel:WorkBooks:Open( ::cFicheroExcel )
   
   while !::lFinPage

      ::procesaHojaExcel()

      ::nContadorPagina               := ::nContadorPagina + 1

   end while

   ::oExcel:oExcel:Quit()
   ::oExcel:oExcel:DisplayAlerts := .t.
   ::oExcel:End()

Return nil

//---------------------------------------------------------------------------//

METHOD procesaHojaExcel()

   if !::lFinPage
      ::oExcel:oExcel:WorkSheets( ::nContadorPagina ):Activate()
   end if
   
   ::addSuFactura()

   if ::nContadorPagina > 2

      ::nPuntoVerde  := ::getExcelNumeric( "AJ", 95 )

   end if

   for ::nFila       := ::nFilaInicio to ::nFilaFinal

      if ::lFinPage
         Return nil      
      end if

      ::procesaLinea()

      ::procesaLote()

      ::hLine     := {=>}

   next

Return nil

//---------------------------------------------------------------------------//

METHOD procesaLinea()

   local lChangeDto  := .f.

   if Empty( ::getExcelString( "A", ::nFila ) )
      ::lFinPage     := .t.
   end if

   hSet( ::hLine, "codigoBaras", ::getExcelString( "A", ::nFila ) )
   hSet( ::hLine, "descripcion", ::getExcelString( "D", ::nFila ) )

   if !Empty( ::getExcelString( "J", ::nFila ) )
      hSet( ::hLine, "unidades", ::getExcelNumeric( "J", ::nFila ) )
   else
      hSet( ::hLine, "unidades", ::getExcelNumeric( "M", ::nFila ) )
   end if

   if !Empty( ::getExcelString( "P", ::nFila ) )
      hSet( ::hLine, "preciounitario", ::getExcelNumeric( "P", ::nFila ) )
   else
      hSet( ::hLine, "preciounitario", ::getExcelNumeric( "T", ::nFila ) )
      lChangeDto := .t.
   end if

   if !Empty( ::getExcelString( "T", ::nFila ) )
      hSet( ::hLine, "descuento", ( ( ::getExcelNumeric( "T", ::nFila ) * 100 ) / ::getExcelNumeric( "Q", ::nFila ) ) )
   else
      hSet( ::hLine, "descuento", ( ( ::getExcelNumeric( "Y", ::nFila ) * 100 ) / ::getExcelNumeric( "U", ::nFila ) ) )
   end if

   hSet( ::hLine, "lote", "" )

   hSet( ::hLine, "caducidad", "" )

   ::nFila    := ::nFila + 1

Return nil

//---------------------------------------------------------------------------//

METHOD procesaLote()

   local cString
   local hlin
   local hLote
   local aLotes      := ::getLotesLine()

   hLin              := ::hLine

   if Empty( aLotes )

      aadd( ::aLineasPedido, hLin )

   else

      for each hLote in aLotes

         hSet( hLin, "lote", hGet( hLote, "lote" ) )
         hSet( hLin, "unidades", hGet( hLote, "unidades" ) )
         hSet( hLin, "caducidad", hGet( hLote, "caducidad" ) )

         aadd( ::aLineasPedido, hLin )

      next

   end if

Return nil

//---------------------------------------------------------------------------//

METHOD getLotesLine()

   local cString
   local aLotes      := {}

   cString           := ::getExcelString( "H", ::nFila )

   if Empty( cString )
      cString        := ::getExcelString( "I", ::nFila )
   end if

   if At( ";", cString ) != 0

      aLotes   := HB_ATokens( cString, ";" )

   else

      aAdd( aLotes, cString )

   end if

Return ::formatArrayLote( aLotes )

//---------------------------------------------------------------------------//

METHOD formatArrayLote( aLotes )

   local cLote
   local hLotes      := {=>}
   local aHashLotes  := {}

   if Empty( aLotes )
      Return ( hLotes )
   end if

   for each cLote in aLotes

      hLotes      := {=>}

      hSet( hLotes, "lote", AllTrim( SubStr( cLote, 1, at( "[", cLote ) -1 ) ) )
      hSet( hLotes, "unidades", val( SubStr( cLote, at( "[", cLote ) + 1, ( at( "]", cLote ) ) - ( at( "[", cLote ) + 1 ) ) ) )
      hSet( hLotes, "caducidad", cTod( "01" + AllTrim( SubStr( cLote, at( "]", cLote ) + 1 ) ) ) )

      aAdd( aHashLotes, hLotes )

   end if

Return ( aHashLotes )

//---------------------------------------------------------------------------//

METHOD addCabeceraFactura()

   ::cSerieFactura      := cNewSer( "nFacPrv", D():Contadores( ::nView ) )
   ::cNumeroFactura     := nNewDoc( ::cSerieFactura, D():FacturasProveedores( ::nView ), "NFACPRV", , D():Contadores( ::nView ) )
   ::cSufijoFactura     := Application():CodigoDelegacion()
   ::dFechaFactura      := getSysDate()
   ::cHoraFactura       := getSysTime()

   ( D():FacturasProveedores( ::nView ) )->( dbAppend() )

   ( D():FacturasProveedores( ::nView ) )->CSERFAC       := ::cSerieFactura
   ( D():FacturasProveedores( ::nView ) )->NNUMFAC       := ::cNumeroFactura
   ( D():FacturasProveedores( ::nView ) )->CSUFFAC       := ::cSufijoFactura
   ( D():FacturasProveedores( ::nView ) )->CTURFAC       := cCurSesion()
   ( D():FacturasProveedores( ::nView ) )->DFECFAC       := ::dFechaFactura
   ( D():FacturasProveedores( ::nView ) )->tFecFac       := ::cHoraFactura
   ( D():FacturasProveedores( ::nView ) )->CCODALM       := Application():codigoAlmacen()
   ( D():FacturasProveedores( ::nView ) )->CCODCAJ       := Application():CodigoCaja()
   ( D():FacturasProveedores( ::nView ) )->CDTOESP       := "General"
   ( D():FacturasProveedores( ::nView ) )->CDPP          := "Pronto pago"
   ( D():FacturasProveedores( ::nView ) )->CDIVFAC       := cDivEmp()
   ( D():FacturasProveedores( ::nView ) )->NVDVFAC       := nChgDiv( cDivEmp(), D():Divisas( ::nView ) )
   ( D():FacturasProveedores( ::nView ) )->CCODUSR       := Auth():Codigo()
   ( D():FacturasProveedores( ::nView ) )->nTipRet       := 1
   ( D():FacturasProveedores( ::nView ) )->cCodDlg       := ::cSufijoFactura
   ( D():FacturasProveedores( ::nView ) )->nTotNet       := 0
   ( D():FacturasProveedores( ::nView ) )->nTotIva       := 0
   ( D():FacturasProveedores( ::nView ) )->nTotReq       := 0
   ( D():FacturasProveedores( ::nView ) )->nTotFac       := 0

   ( D():FacturasProveedores( ::nView ) )->CSUPED        := ::cSuFactura

   ( D():FacturasProveedores( ::nView ) )->CCODPRV       := ::cCodigoProveedor 

   if ( D():Proveedores( ::nView ) )->( dbSeek( ::cCodigoProveedor  ) )
      ( D():FacturasProveedores( ::nView ) )->CNOMPRV    := ( D():Proveedores( ::nView ) )->Titulo
      ( D():FacturasProveedores( ::nView ) )->CDIRPRV    := ( D():Proveedores( ::nView ) )->Domicilio
      ( D():FacturasProveedores( ::nView ) )->CPOBPRV    := ( D():Proveedores( ::nView ) )->Poblacion
      ( D():FacturasProveedores( ::nView ) )->CPROVPROV  := ( D():Proveedores( ::nView ) )->Poblacion
      ( D():FacturasProveedores( ::nView ) )->CPOSPRV    := ( D():Proveedores( ::nView ) )->CodPostal
      ( D():FacturasProveedores( ::nView ) )->CDNIPRV    := ( D():Proveedores( ::nView ) )->Nif
      ( D():FacturasProveedores( ::nView ) )->CCODPAGO   := ( D():Proveedores( ::nView ) )->fPago
   end if

   ( D():FacturasProveedores( ::nView ) )->( dbUnLock() )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addLineasFactura()

   local hLine
   local nRecAntCodeBar
   local nOrdAntCodeBar
   local nRecAntArticulos
   local nOrdAntArticulos
   local cCodigoArticulo

   ::nCount            := 1

   nRecAntArticulos     := ( D():Articulos( ::nView ) )->( recno() )
   nOrdAntArticulos     := ( D():Articulos( ::nView ) )->( OrdSetFocus( "Codigo" ) )

   nRecAntCodeBar       := ( D():ArticulosCodigosBarras( ::nView ) )->( recno() )
   nOrdAntCodeBar       := ( D():ArticulosCodigosBarras( ::nView ) )->( OrdSetFocus( "cCodBar" ) )

   for each hLine in ::aLineasPedido

      if ( D():ArticulosCodigosBarras( ::nView ) )->( dbSeek( hGet( hLine, "codigoBaras" ) ) )

         cCodigoArticulo      := ( D():ArticulosCodigosBarras( ::nView ) )->cCodArt

         ( D():FacturasProveedoresLineas( ::nView ) )->( dbAppend() )

         ( D():FacturasProveedoresLineas( ::nView ) )->CSERFAC       :=  ::cSerieFactura
         ( D():FacturasProveedoresLineas( ::nView ) )->NNUMFAC       :=  ::cNumeroFactura
         ( D():FacturasProveedoresLineas( ::nView ) )->CSUFFAC       :=  ::cSufijoFactura
         ( D():FacturasProveedoresLineas( ::nView ) )->dFecFac       :=  ::dFechaFactura
         ( D():FacturasProveedoresLineas( ::nView ) )->cCodPrv       :=  ::cCodigoProveedor
         ( D():FacturasProveedoresLineas( ::nView ) )->tFecFac       :=  ::cHoraFactura
         ( D():FacturasProveedoresLineas( ::nView ) )->nPosPrint     :=  ::nCount

         ( D():FacturasProveedoresLineas( ::nView ) )->CREF          := cCodigoArticulo

         if ( D():Articulos( ::nView ) )->( dbSeek( cCodigoArticulo ) )

            ( D():FacturasProveedoresLineas( ::nView ) )->CDETALLE   :=  ( D():Articulos( ::nView ) )->Nombre
            ( D():FacturasProveedoresLineas( ::nView ) )->CUNIDAD    :=  ( D():Articulos( ::nView ) )->cUnidad
            ( D():FacturasProveedoresLineas( ::nView ) )->NIVA       :=  nIva( D():TiposIva( ::nView ), ( D():Articulos( ::nView ) )->TipoIva )
            ( D():FacturasProveedoresLineas( ::nView ) )->NCTLSTK    :=  ( D():Articulos( ::nView ) )->NCTLSTOCK
            ( D():FacturasProveedoresLineas( ::nView ) )->CCODFAM    :=  ( D():Articulos( ::nView ) )->Familia

         end if

         ( D():FacturasProveedoresLineas( ::nView ) )->NPREUNIT      := hGet( hLine, "preciounitario" )
         ( D():FacturasProveedoresLineas( ::nView ) )->NUNICAJA      := hGet( hLine, "unidades" )
         ( D():FacturasProveedoresLineas( ::nView ) )->nCanEnt       := 1
         ( D():FacturasProveedoresLineas( ::nView ) )->NDTOLIN       := hGet( hLine, "descuento" )
         ( D():FacturasProveedoresLineas( ::nView ) )->CALMLIN       := Application():codigoAlmacen()
         ( D():FacturasProveedoresLineas( ::nView ) )->LLOTE         := .t.
         ( D():FacturasProveedoresLineas( ::nView ) )->cLote         := hGet( hLine, "lote" )
         ( D():FacturasProveedoresLineas( ::nView ) )->NNUMLIN       := ::nCount
         ( D():FacturasProveedoresLineas( ::nView ) )->dFecCad       := hGet( hLine, "caducidad" )

         ( D():FacturasProveedoresLineas( ::nView ) )->( dbUnLock() )

         ::nCount    := ::nCount + 1

      else

         ::cError    += hGet( hLine, "codigoBaras" ) + " - " + hGet( hLine, "descripcion" ) + CRLF 

      end if

   next

   ( D():Articulos( ::nView ) )->( OrdSetFocus( nOrdAntArticulos ) )
   ( D():Articulos( ::nView ) )->( dbGoTo( nRecAntArticulos ) )

   ( D():ArticulosCodigosBarras( ::nView ) )->( OrdSetFocus( nOrdAntCodeBar ) )
   ( D():ArticulosCodigosBarras( ::nView ) )->( dbGoTo( nRecAntCodeBar ) )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addLineaPuntoVerde()

   ( D():FacturasProveedoresLineas( ::nView ) )->( dbAppend() )

   ( D():FacturasProveedoresLineas( ::nView ) )->CSERFAC       :=  ::cSerieFactura
   ( D():FacturasProveedoresLineas( ::nView ) )->NNUMFAC       :=  ::cNumeroFactura
   ( D():FacturasProveedoresLineas( ::nView ) )->CSUFFAC       :=  ::cSufijoFactura
   ( D():FacturasProveedoresLineas( ::nView ) )->dFecFac       :=  ::dFechaFactura
   ( D():FacturasProveedoresLineas( ::nView ) )->cCodPrv       :=  ::cCodigoProveedor
   ( D():FacturasProveedoresLineas( ::nView ) )->tFecFac       :=  ::cHoraFactura
   ( D():FacturasProveedoresLineas( ::nView ) )->nPosPrint     :=  ::nCount

   ( D():FacturasProveedoresLineas( ::nView ) )->MLNGDES       := "Aporte de punto verde"

   ( D():FacturasProveedoresLineas( ::nView ) )->NPREUNIT      := ::nPuntoVerde
   ( D():FacturasProveedoresLineas( ::nView ) )->NUNICAJA      := 1
   ( D():FacturasProveedoresLineas( ::nView ) )->nCanEnt       := 1
   ( D():FacturasProveedoresLineas( ::nView ) )->CALMLIN       := Application():codigoAlmacen()
   ( D():FacturasProveedoresLineas( ::nView ) )->NNUMLIN       := ::nCount

   ( D():FacturasProveedoresLineas( ::nView ) )->( dbUnLock() )

Return ( .t. )

//---------------------------------------------------------------------------//   

METHOD recalculaFactura()

   local nRec     := ( D():FacturasProveedores( ::nView ) )->( recno() )
   local nOrdAnt  := ( D():FacturasProveedores( ::nView ) )->( OrdSetFocus( "NNUMFAC" ) )
   
   if ( D():FacturasProveedores( ::nView ) )->( dbSeek( ::cSerieFactura + Str( ::cNumeroFactura ) + ::cSufijoFactura ) )

      GenPgoFacPrv( ::cSerieFactura + Str( ::cNumeroFactura ) + ::cSufijoFactura,;
                    D():FacturasProveedores( ::nView ),;
                    D():FacturasProveedoresLineas( ::nView ),;
                    D():FacturasProveedoresPagos( ::nView ),;
                    D():Proveedores( ::nView ),;
                    D():TiposIva( ::nView ),;
                    D():FormasPago( ::nView ) )

      if dbLock( D():FacturasProveedores( ::nView ) )

         aTotFac                 := aTotFacPrv( ::cSerieFactura + Str( ::cNumeroFactura ) + ::cSufijoFactura,;
                                                D():FacturasProveedores( ::nView ),;
                                                D():FacturasProveedoresLineas( ::nView ),;
                                                D():TiposIva( ::nView ),;
                                                D():Divisas( ::nView ),;
                                                D():FacturasProveedoresPagos( ::nView ),;
                                                ( D():FacturasProveedores( ::nView ) )->cDivFac )

         ( D():FacturasProveedores( ::nView ) )->nTotNet := aTotFac[1]
         ( D():FacturasProveedores( ::nView ) )->nTotIva := aTotFac[2]
         ( D():FacturasProveedores( ::nView ) )->nTotReq := aTotFac[3]
         ( D():FacturasProveedores( ::nView ) )->nTotFac := aTotFac[4]

         ( D():FacturasProveedores( ::nView ) )->( dbUnLock() )

      end if

   end if
   
Return ( .t. )

//---------------------------------------------------------------------------//  

METHOD addSuFactura()

   local nPos

   ::cSuFactura      := ::getExcelString( "AI", 42 )

   nPos              := at( ":", ::cSuFactura )

   if nPos != 0
      ::cSuFactura      := AllTrim( SubStr( ::cSuFactura, nPos + 1 ) )
   end if

Return ( .t. )

//---------------------------------------------------------------------------//  

#include "ImportarExcel.prg"

/*
METHOD getExcelValue( columna, fila, valorPorDefecto )

METHOD getExcelString( columna, fila )
                                                 
METHOD getExcelNumeric( columna, fila )

METHOD getExcelLogic( columna, fila )

*/