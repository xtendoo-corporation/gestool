#include "FiveWin.Ch"
#include "Report.ch"
#include "Xbrowse.ch"
#include "MesDbf.ch"
#include "Factu.ch" 
#include "FastRepH.ch"

//---------------------------------------------------------------------------//

CLASS TPrepareDocumentQR

   DATA oDlg
   DATA oFld

   DATA oBmp

   DATA lOpenFiles

   DATA lBreak

   DATA cTituloVentana

   DATA oTextoNumeroDocumento
   DATA cTextoNumeroDocumento
   DATA oTextoClienteDocumento
   DATA cTextoClienteDocumento

   DATA oNumBultos
   DATA cNumBultos
   DATA oNumEstuches
   DATA cNumEstuches

   DATA oFechaSalida
   DATA cFechaSalida

   DATA oImpresora
   DATA cImpresora
   DATA oFormatoImpresion
   DATA cFormatoImpresion

   DATA oCodigoBarras
   DATA cCodigoBarras

   DATA DbfCabecera
   DATA dbfLineas

   DATA nView

   DATA lErrorOnCreate
   DATA nRecnoHead
   DATA nOrderHead
   DATA nRecnoLine
   DATA nOrderLine

   DATA oBrwOriginalLines
   DATA aOriginalLines

   DATA oBrwFinalLines
   DATA aFinalLines

   DATA aKitLines

   DATA aInfoLines
   DATA aMateriasPrimas

   DATA cSerieDocumento
   DATA nNumeroDocumento
   DATA cSufijoDocumento

   DATA cIdDocumento

   DATA cCodigoBarras         
   DATA cLote                 
   DATA dFechaCaducidad       
   DATA cCodigoArticulo
   DATA nUnidades
   DATA uuidEtiqueta

   DATA aUuidQR

   DATA nPos

   METHOD Run( nView )

   METHOD lCheckConditions()

   METHOD New()

   METHOD OpenFiles()   

   METHOD CloseFiles()

   METHOD Dialog()

   METHOD loadInitData()

   METHOD validCodigoBarras()

   METHOD setHashCodeBar()

   METHOD SetCodigoArticulo()  

   METHOD resetCodeBar()

   METHOD processCodeBar()

   METHOD AddNewLine()

   METHOD DelOriginalLine()

   METHOD end()

   METHOD StartDialog()

   METHOD loadUnprepareLinesFromDocument()      VIRTUAL
   METHOD loadPrepareLinesFromDocument()        VIRTUAL
   METHOD loadKitLinesFromDocument()            VIRTUAL

   METHOD getValueOriginalLine( cField )        INLINE ( if( len( ::aOriginalLines ) == 0, "", ::aOriginalLines[ ::oBrwOriginalLines:nArrayAt, ( ::dbfLineas )->( FieldPos( cField ) ) ] ) )

   METHOD getValueFinalLine( cField )           INLINE ( if( len( ::aFinalLines ) == 0, "", ::aFinalLines[ ::oBrwFinalLines:nArrayAt, ( ::dbfLineas )->( FieldPos( cField ) ) ] ) )

   METHOD nPosScanOriginalLines()
   METHOD nPosScanFinalLines()

   METHOD setLinesToDocument()
   METHOD setPreparated()

   METHOD printLabel()
   METHOD saveBultos()
   METHOD print()

   METHOD Info( nView, oWndBrw )
      METHOD DialogInfo()
      METHOD lPrepareInfo()
      METHOD aAddInfoLines( aField )
      METHOD addStockInfo()
      METHOD addProducir()
      METHOD addStockReal()

   METHOD Recursive()

END CLASS

//----------------------------------------------------------------------------//

METHOD OpenFiles() CLASS TPrepareDocumentQR

   local oError
   local oBlock         

   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      ::nView           := D():CreateView()
      ::lOpenFiles      := .t.

   RECOVER USING oError

      ::lOpenFiles      := .f.

      ::CloseFiles()

      msgStop( ErrorMessage( oError ), "Imposible abrir las bases" )

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( self )

//----------------------------------------------------------------------------//

METHOD CloseFiles() CLASS TPrepareDocumentQR

   D():DeleteView( ::nView )

   ::lOpenFiles     := .f.

Return self

//----------------------------------------------------------------------------//

METHOD Run( oWnd )

   if oWnd != nil
      SysRefresh(); oWnd:CloseAll(); SysRefresh()    
   end if

   ::lBreak       := .f.

   ::OpenFiles()

   ::Recursive()

   if ::lOpenFiles
      ::CloseFiles()
   end if

Return self

//----------------------------------------------------------------------------//

METHOD Recursive()

   while !::lBreak

      ::New()

      if !Empty( ::cIdDocumento )

         if ::lCheckConditions()
            ::Dialog()
         end if

      end if

      ::end()

   end while

Return self

//----------------------------------------------------------------------------//

METHOD lCheckConditions() CLASS TPrepareDocumentQR

   if ( ::DbfCabecera )->( OrdKeyNo() ) == 0
      MsgBeepStop( "No hay documento para preparar" )
      Return ( .f. )
   end if

   if !( ::DbfCabecera )->lPdtCrg
      MsgBeepStop( "Documento no está seleccionado para preparar" )
      Return ( .f. )
   end if

   if ( ::DbfCabecera )->nPrepare == 4
      MsgBeepStop( "Documento totalmente preparado" )
      Return ( .f. )
   end if

Return( .t. )

//----------------------------------------------------------------------------//

METHOD New( nView ) CLASS TPrepareDocumentQR

   local oError
   local oBlock

   if !empty( nView )
      ::nView              := nView
   end if

   if Empty( ::nView )
      ::OpenFiles()
   end if

   oBlock                  := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      ::nRecnoHead         := ( ::dbfCabecera )->( Recno() )
      ::nOrderHead         := ( ::dbfCabecera )->( OrdSetFocus( 1 ) )

      ::nRecnoLine         := ( ::dbfLineas )->( Recno() )
      ::nOrderLine         := ( ::dbfLineas )->( OrdSetFocus( 1 ) )

      ::aOriginalLines     := {}
      ::aFinalLines        := {}
      ::aKitLines          := {}

      ::aUuidQR            := {}

   RECOVER USING oError

      ::lErrorOnCreate     := .t.

      MsgBeepStop( "Error en la proparación del documento" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE
   ErrorBlock( oBlock )

Return ( Self )

//--------------------------------------------------------------------------//

METHOD Dialog() CLASS TPrepareDocumentQR

   ::loadInitData()

   DEFINE DIALOG ::oDlg RESOURCE "PREPARARDOCUMENTO" TITLE "Preparando " + ::cTituloVentana

   REDEFINE BITMAP ::oBmp ;
      ID       990 ;
      RESOURCE "GC_BARCODE_SCANNER_48" ;
      TRANSPARENT ;
      OF       ::oDlg

   REDEFINE SAY ::oTextoNumeroDocumento ;
      VAR      ::cTextoNumeroDocumento ;
      ID       100 ;
      OF       ::oDlg

   REDEFINE SAY ::oTextoClienteDocumento ;
      VAR      ::cTextoClienteDocumento ;
      ID       110 ;
      OF       ::oDlg

   REDEFINE GET ::oCodigoBarras ;
      VAR      ::cCodigoBarras ;
      ID       120 ;
      OF       ::oDlg

   ::oCodigoBarras:bValid  := {|| ::validCodigoBarras() }

   ::oBrwOriginalLines                        := IXBrowse():New( ::oDlg )

   ::oBrwOriginalLines:bClrSel                := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
   ::oBrwOriginalLines:bClrSelFocus           := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

   ::oBrwOriginalLines:SetArray( ::aOriginalLines, , , .f. )

   ::oBrwOriginalLines:nMarqueeStyle          := 6
   ::oBrwOriginalLines:lRecordSelector        := .f.
   ::oBrwOriginalLines:lHScroll               := .f.
   ::oBrwOriginalLines:lFooter                := .t.

   ::oBrwOriginalLines:CreateFromResource( 130 )

   with object ( ::oBrwOriginalLines:AddCol() )
      :cHeader          := "Código"
      :bStrData         := {|| ::getValueOriginalLine( "cRef" ) }
      :nWidth           := 100
   end with

   with object ( ::oBrwOriginalLines:AddCol() )
      :cHeader          := "Detalle"
      :bStrData         := {|| ::getValueOriginalLine( "cDetalle" ) }
      :nWidth           := 260
   end with

   with object ( ::oBrwOriginalLines:AddCol() )
      :cHeader          := "Lote"
      :bStrData         := {|| ::getValueOriginalLine( "cLote" ) }
      :nWidth           := 100
   end with

   with object ( ::oBrwOriginalLines:AddCol() )
      :cHeader          := "Unidades"
      :bEditValue       := {|| ::getValueOriginalLine( "nUniCaja" ) }
      :cEditPicture     := MasUnd()
      :nWidth           := 60
      :nDataStrAlign    := 1
      :nHeadStrAlign    := 1
      :nFooterType      := AGGR_SUM
      :cFooterPicture   := MasUnd()
      :nFootStrAlign    := AL_RIGHT
   end with

   ::oBrwFinalLines                        := IXBrowse():New( ::oDlg )

   ::oBrwFinalLines:bClrSel                := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
   ::oBrwFinalLines:bClrSelFocus           := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

   ::oBrwFinalLines:SetArray( ::aFinalLines, , , .f. )

   ::oBrwFinalLines:nMarqueeStyle          := 6
   ::oBrwFinalLines:lRecordSelector        := .f.
   ::oBrwFinalLines:lHScroll               := .f.
   ::oBrwFinalLines:lFooter                := .t.

   ::oBrwFinalLines:CreateFromResource( 140 )

   with object ( ::oBrwFinalLines:AddCol() )
      :cHeader          := "Código"
      :bStrData         := {|| ::getValueFinalLine( "cRef" ) }
      :nWidth           := 100
   end with

   with object ( ::oBrwFinalLines:AddCol() )
      :cHeader          := "Detalle"
      :bStrData         := {|| ::getValueFinalLine( "cDetalle" ) }
      :nWidth           := 260
   end with

   with object ( ::oBrwFinalLines:AddCol() )
      :cHeader          := "Lote"
      :bStrData         := {|| ::getValueFinalLine( "cLote" ) }
      :nWidth           := 100
   end with

   with object ( ::oBrwFinalLines:AddCol() )
      :cHeader          := "Unidades"
      :bEditValue       := {|| ::getValueFinalLine( "nUniCaja" ) }
      :cEditPicture     := MasUnd()
      :nWidth           := 60
      :nDataStrAlign    := 1
      :nHeadStrAlign    := 1
      :nFooterType      := AGGR_SUM
      :cFooterPicture   := MasUnd()
      :nFootStrAlign    := AL_RIGHT
   end with
   
   REDEFINE BUTTON ;
      ID       520 ;
      OF       ::oDlg ;
      CANCEL ;
      ACTION   ( ::printLabel() )

   REDEFINE BUTTON ;
      ID       510 ;
      OF       ::oDlg ;
      CANCEL ;
      ACTION   ( ::setLinesToDocument(), ::setPreparated( .t. ), ::end() )

   REDEFINE BUTTON ;
      ID       500 ;
      OF       ::oDlg ;
      CANCEL ;
      ACTION   ( ::setLinesToDocument(), ::setPreparated(), ::end() )

   REDEFINE BUTTON ;
      ID       550 ;
      OF       ::oDlg ;
      CANCEL ;
      ACTION   ( ::end() )

      ::oDlg:bStart := {|| ::StartDialog() }

   ACTIVATE DIALOG ::oDlg CENTER

Return ( Self )

//---------------------------------------------------------------------------//

METHOD StartDialog() CLASS TPrepareDocumentQR

   if !empty( ::oBrwOriginalLines )
      ::oBrwOriginalLines:MakeTotals()
      ::oBrwOriginalLines:Load()
      ::oBrwOriginalLines:GoTop()
      ::oBrwOriginalLines:Refresh()
   end if

   if !empty( ::oBrwFinalLines )
      ::oBrwFinalLines:MakeTotals()
      ::oBrwFinalLines:Load()
      ::oBrwFinalLines:GoTop()
      ::oBrwFinalLines:Refresh()
   end if

Return ( Self )

//---------------------------------------------------------------------------//

METHOD loadInitData() CLASS TPrepareDocumentQR

   ::nPos            := 0

   ::cCodigoBarras   := Space( 200 )

   ::aOriginalLines  := ::loadUnprepareLinesFromDocument()
   ::aFinalLines     := ::loadPrepareLinesFromDocument()
   ::aKitLines       := ::loadKitLinesFromDocument()

   ::cLote           := ""
   ::nUnidades       := 1
   ::dFechaCaducidad := Stod( "" )
   ::uuidEtiqueta    := ""

Return ( Self )

//---------------------------------------------------------------------------//

METHOD validCodigoBarras() CLASS TPrepareDocumentQR

   local hHas128

   if !Empty( AllTrim( ::cCodigoBarras ) )

      hHas128              := GetHashPrepareGs128( AllTrim( ::cCodigoBarras ) )

      if !empty( hHas128 )
         ::setHashCodeBar( hHas128 )
      end if

      ::SetCodigoArticulo()  

      ::processCodeBar()

   end if

   ::resetCodeBar()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD setHashCodeBar( hHas128 ) CLASS TPrepareDocumentQR

   ::cCodigoBarras         := uGetCodigo( hHas128, "01" )
   ::cLote                 := Upper( uGetCodigo( hHas128, "10" ) )
   ::nUnidades             := val( uGetCodigo( hHas128, "37" ) )
   ::uuidEtiqueta          := uGetCodigo( hHas128, "9999" )

   if ::nUnidades == 0
      ::nUnidades          := 1
   end if
 
   ::dFechaCaducidad       := uGetCodigo( hHas128, "17" )

   if ValType( uGetCodigo( hHas128, "17" ) ) == "C"
      ::dFechaCaducidad    := Stod( ::dFechaCaducidad )
   end if

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD resetCodeBar() CLASS TPrepareDocumentQR

   ::oCodigoBarras:SetFocus()
   ::cCodigoBarras   := Space( 200 ) 
   ::oCodigoBarras:Refresh()

   ::nPos            := 0
   ::cCodigoArticulo := ""
   ::cLote           := ""
   ::nUnidades       := 1
   ::dFechaCaducidad := Stod( "" )
   ::uuidEtiqueta    := ""

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD SetCodigoArticulo( cCodBar ) CLASS TPrepareDocumentQR

   ::cCodigoArticulo       := padr( cSeekCodebar( ::cCodigoBarras, D():ArticulosCodigosBarras( ::nView ), D():Articulos( ::nView ) ), 18 )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD end() CLASS TPrepareDocumentQR

   if !Empty( ::nRecnoHead )
      ( ::dbfCabecera )->( dbGoTo( ::nRecnoHead ) )
   end if
   if !Empty( ::nOrderHead )
      ( ::dbfCabecera )->( OrdSetFocus( ::nOrderHead ) )
   end if

   if !Empty( ::nRecnoLine )
      ( ::dbfLineas )->( dbGoTo( ::nRecnoLine ) )
   end if

   if !Empty( ::nOrderLine )
      ( ::dbfLineas )->( OrdSetFocus( ::nOrderLine ) )
   end if

   if !Empty( ::oBmp )
      ::oBmp:End()
   end if
   
   if !Empty( ::oDlg )
      ::oDlg:End()
   end if

Return ( Self )

//---------------------------------------------------------------------------//

METHOD processCodeBar() CLASS TPrepareDocumentQR

   if Len( ::aOriginalLines ) == 0
      MsgBeepStop( "No existen lineas por preparar." )
      Return ( self )
   end if

   if aScan( ::aUuidQR, ::uuidEtiqueta ) != 0
      MsgBeepStop( "Ésta etiqueta ya ha sido introducida" )
      ::uuidEtiqueta    := ""
      Return ( self )
   end if

   ::nPosScanOriginalLines()

   if ::nPos == 0
      MsgBeepStop( "El artículo introducido no se encuentra para preparar" )
      Return ( self )
   end if

   ::AddNewLine()

   ::DelOriginalLine()
   
Return ( Self )

//---------------------------------------------------------------------------//

METHOD AddNewLine() CLASS TPrepareDocumentQR

   local nPos
   local aOriginalLine       := aClone( ::aOriginalLines[ ::nPos ] )

   if len( ::aFinalLines ) == 0

      aadd( ::aFinalLines, aOriginalLine )

      if Empty( ::aFinalLines[ 1, ( ::dbfLineas )->( FieldPos( "cLote" ) ) ] ) .and. !Empty( ::cLote )
         ::aFinalLines[ 1, ( ::dbfLineas )->( FieldPos( "cLote" ) ) ]   := ::cLote
      end if

      if Empty( dTos( ::aFinalLines[ 1, ( ::dbfLineas )->( FieldPos( "dFecCad" ) ) ] ) ) .and. !Empty( dTos( ::dFechaCaducidad ) )
         ::aFinalLines[ 1, ( ::dbfLineas )->( FieldPos( "dFecCad" ) ) ]   := ::dFechaCaducidad
      end if

      ::aFinalLines[ 1, ( ::dbfLineas )->( FieldPos( "nCanEnt" ) ) ]    := 1
      ::aFinalLines[ 1, ( ::dbfLineas )->( FieldPos( "nUniCaja" ) ) ]   := ::nUnidades
      ::aFinalLines[ 1, ( ::dbfLineas )->( FieldPos( "lPreparado" ) ) ] := .t.

   else

      nPos        := ::nPosScanFinalLines()

      if nPos != 0

         if !Empty( dTos( ::dFechaCaducidad ) )
            ::aFinalLines[ nPos, ( ::dbfLineas )->( FieldPos( "dFecCad" ) ) ] := ::dFechaCaducidad
         end if

         ::aFinalLines[ nPos, ( ::dbfLineas )->( FieldPos( "nUniCaja" ) ) ]   := ::aFinalLines[ nPos, ( ::dbfLineas )->( FieldPos( "nUniCaja" ) ) ] + ::nUnidades

      else

         if Empty( aOriginalLine[ ( ::dbfLineas )->( FieldPos( "cLote" ) ) ] ) .and. !Empty( ::cLote )
            aOriginalLine[ ( ::dbfLineas )->( FieldPos( "cLote" ) ) ]   := ::cLote
         end if

         if Empty( dTos( aOriginalLine[ ( ::dbfLineas )->( FieldPos( "dFecCad" ) ) ] ) ) .and. !Empty( dTos( ::dFechaCaducidad ) )
            aOriginalLine[ ( ::dbfLineas )->( FieldPos( "dFecCad" ) ) ]   := ::dFechaCaducidad
         end if

         aOriginalLine[ ( ::dbfLineas )->( FieldPos( "nCanEnt" ) ) ]    := 1
         aOriginalLine[ ( ::dbfLineas )->( FieldPos( "nUniCaja" ) ) ]   := ::nUnidades
         aOriginalLine[ ( ::dbfLineas )->( FieldPos( "lPreparado" ) ) ] := .t.

         aadd( ::aFinalLines, aOriginalLine )

      end if

   end if

   aAdd( ::aUuidQR, ::uuidEtiqueta )

   ::oBrwOriginalLines:MakeTotals()
   ::oBrwOriginalLines:Refresh()
   ::oBrwFinalLines:MakeTotals()
   ::oBrwFinalLines:Refresh()

Return ( Self )

//---------------------------------------------------------------------------//
   
METHOD DelOriginalLine() CLASS TPrepareDocumentQR

   local nResult

   nResult        := ::aOriginalLines[ ::nPos, ( ::dbfLineas )->( FieldPos( "nUniCaja" ) ) ] - ::nUnidades

   if nResult == 0
      aDel( ::aOriginalLines, ::nPos, .t. )
      ::oBrwOriginalLines:Refresh()
   else
      ::aOriginalLines[ ::nPos, ( ::dbfLineas )->( FieldPos( "nUniCaja" ) ) ]   := ::aOriginalLines[ ::nPos, ( ::dbfLineas )->( FieldPos( "nUniCaja" ) ) ] - ::nUnidades
   end if

   ::oBrwOriginalLines:MakeTotals()
   ::oBrwOriginalLines:Refresh()
   ::oBrwFinalLines:MakeTotals()
   ::oBrwFinalLines:Refresh()

Return ( Self )

//---------------------------------------------------------------------------//

METHOD nPosScanOriginalLines() CLASS TPrepareDocumentQR

   ::nPos      :=  aScan( ::aOriginalLines, { | aLine |  aLine[ ( ::dbfLineas )->( FieldPos( "cRef" ) ) ] == Padr( ::cCodigoArticulo, 18 ) } )

Return ( Self )

//---------------------------------------------------------------------------//
   
METHOD nPosScanFinalLines() CLASS TPrepareDocumentQR

   local nPos        :=  aScan( ::aFinalLines, { | aLine |  aLine[ ( ::dbfLineas )->( FieldPos( "cRef" ) ) ] == Padr( ::cCodigoArticulo, 18 )   .and.;
                                                      upper( Padr( aLine[ ( ::dbfLineas )->( FieldPos( "cLote" ) ) ], 14 ) ) == upper( Padr( ::cLote, 14 ) ) } )

Return ( nPos )

//---------------------------------------------------------------------------//

METHOD setLinesToDocument() CLASS TPrepareDocumentQR

   /*
   Eliminamos las lineas anteriores--------------------------------------------
   */

   while ( ::dbfLineas )->( dbSeek( ::cIdDocumento ) )
            
      if dbLock( ::dbfLineas )
         ( ::dbfLineas )->( dbDelete() )
         ( ::dbfLineas )->( dbUnLock() )
      end if

   end while

   /*
   Seteamos las lineas originales----------------------------------------------
   */

   if Len( ::aOriginalLines ) != 0
      aEval( ::aOriginalLines, {|aTmp| WinGather( aTmp, , ::dbfLineas, , APPD_MODE ) } )
   end if

   /*
   Seteamos las lineas Finales-------------------------------------------------
   */

   if Len( ::aFinalLines ) != 0
      aEval( ::aFinalLines, {|aTmp| WinGather( aTmp, , ::dbfLineas, , APPD_MODE ) } )
   end if

   /*
   Seteamos las lineas kits---------------------------------------------------
   */

   if Len( ::aKitLines ) != 0
      aEval( ::aKitLines, {|aTmp| WinGather( aTmp, , ::dbfLineas, , APPD_MODE ) } )
   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD setPreparated( lAbaranar ) CLASS TPrepareDocumentQR

   local nPrepare       := 0

   DEFAULT  lAbaranar   := .f.

   do case
      case len( ::aOriginalLines ) == 0 .and. len( ::aFinalLines ) != 0
         nPrepare := 4

      case len( ::aOriginalLines ) != 0 .and. len( ::aFinalLines ) != 0
         
         if lAbaranar
            nPrepare := 3
         else
            nPrepare := 2
         end if

      case len( ::aOriginalLines ) != 0 .and. len( ::aFinalLines ) == 0
         nPrepare := 1

   end case

   if dbDialogLock( ::DbfCabecera )
      ( ::DbfCabecera )->nPrepare   := nPrepare
      ( ::DbfCabecera )->( dbUnLock() )
   end if

Return ( nil )

//----------------------------------------------------------------------------//

METHOD printLabel() CLASS TPrepareDocumentQR

   local oDialog
   local oBmp

   ::cFormatoImpresion  := ConfiguracionesEmpresaModel():getValue( "formatoPreparado", Space( 20 ) )
   ::cImpresora         := ConfiguracionesEmpresaModel():getValue( "impresoraPreparado", Space( 20 ) )

   DEFINE DIALOG oDialog RESOURCE "PREPARARPRINT" TITLE "Imprimiendo pedido"

   REDEFINE BITMAP oBmp ;
      ID       990 ;
      RESOURCE "GC_BARCODE_SCANNER_48" ;
      TRANSPARENT ;
      OF       oDialog

   REDEFINE GET ::oNumBultos ;
      VAR      ::cNumBultos ;
      ID       110 ;
      SPINNER;
      OF       oDialog

   REDEFINE GET ::oNumEstuches ;
      VAR      ::cNumEstuches ;
      ID       120 ;
      SPINNER;
      OF       oDialog

   REDEFINE GET ::oFechaSalida ;
      VAR      ::cFechaSalida ;
      ID       150 ;
      SPINNER;
      OF       oDialog

   REDEFINE GET ::oFormatoImpresion ;
      VAR      ::cFormatoImpresion ;
      ID       130 ;
      IDTEXT   131 ;
      BITMAP   "LUPA" ;
      OF       oDialog

      ::oFormatoImpresion:bHelp := {|| BrwDocumento( ::oFormatoImpresion, ::oFormatoImpresion:oHelpText, "PC" ) }
      ::oFormatoImpresion:bValid := {|| cDocumento( ::oFormatoImpresion, ::oFormatoImpresion:oHelpText ) }

   REDEFINE GET ::oImpresora ;
      VAR      ::cImpresora ;
      ID       140 ;
      OF       oDialog

   TBtnBmp():ReDefine( 141, "gc_printer2_check_16",,,,,{|| PrinterPreferences( ::oImpresora ) }, oDialog, .f., , .f.,  )

   REDEFINE BUTTON ;
      ID       510 ;
      OF       oDialog ;
      CANCEL ;
      ACTION   ( oDialog:End( IDOK ) )

   REDEFINE BUTTON ;
      ID       550 ;
      OF       oDialog ;
      CANCEL ;
      ACTION   ( oDialog:End() )

      oDialog:bStart    := {|| ::oFormatoImpresion:lValid() }

   ACTIVATE DIALOG oDialog CENTER

   if oDialog:nResult == IDOK
   
      ::saveBultos()

      ::Print()

      ConfiguracionesEmpresaModel():setValue( "formatoPreparado", ::cFormatoImpresion )
      ConfiguracionesEmpresaModel():setValue( "impresoraPreparado", ::cImpresora )

   end if

   oBmp:End()

Return ( nil )

//----------------------------------------------------------------------------//

METHOD saveBultos() CLASS TPrepareDocumentQR

   if dbDialogLock( ::DbfCabecera )
      ( ::DbfCabecera )->nBultos   := ::cNumBultos
      ( ::DbfCabecera )->cRetMat   := AllTrim( Str( ::cNumEstuches ) )
      ( ::DbfCabecera )->dFecEnt   := ::cFechaSalida
      ( ::DbfCabecera )->( dbUnLock() )
   end if

Return ( nil )

//----------------------------------------------------------------------------//

METHOD Print() CLASS TPrepareDocumentQR

//   GenPedCli( IS_PRINTER, "Imprimiendo pedido de cliente", ::cFormatoImpresion, ::cImpresora, ::cNumBultos )

   imprimePedidoCliente( ::cIdDocumento, ::cFormatoImpresion, ::cImpresora, ::cNumBultos )

Return ( nil )

//----------------------------------------------------------------------------//

METHOD Info( nView, oWndBrw ) CLASS TPrepareDocumentQR

   ::New( nView )

   ::lPrepareInfo( oWndBrw )

   ::addStockInfo()
   ::addProducir()
   ::addStockReal()

   ::DialogInfo()

Return self

//----------------------------------------------------------------------------//

METHOD DialogInfo() CLASS TPrepareDocumentQR

   DEFINE DIALOG ::oDlg RESOURCE "PREPARARINFODOC" TITLE "Informe de preparación"

   REDEFINE BITMAP ::oBmp ;
      ID       990 ;
      RESOURCE "GC_BARCODE_SCANNER_48" ;
      TRANSPARENT ;
      OF       ::oDlg

   ::oBrwOriginalLines                        := IXBrowse():New( ::oDlg )

   ::oBrwOriginalLines:bClrSel                := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
   ::oBrwOriginalLines:bClrSelFocus           := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

   ::oBrwOriginalLines:SetArray( ::aInfoLines, , , .f. )

   ::oBrwOriginalLines:nMarqueeStyle          := 5
   ::oBrwOriginalLines:lRecordSelector        := .f.
   ::oBrwOriginalLines:lHScroll               := .f.

   ::oBrwOriginalLines:CreateFromResource( 130 )

   with object ( ::oBrwOriginalLines:AddCol() )
      :cHeader          := "Código"
      :bStrData         := {|| if( len( ::aInfoLines ) == 0, "", hGet( ::aInfoLines[ ::oBrwOriginalLines:nArrayAt ], "Codigo" ) ) }
      :nWidth           := 100
   end with

   with object ( ::oBrwOriginalLines:AddCol() )
      :cHeader          := "Detalle"
      :bStrData         := {|| if( len( ::aInfoLines ) == 0, "", hGet( ::aInfoLines[ ::oBrwOriginalLines:nArrayAt ], "Nombre" ) ) }
      :nWidth           := 300
   end with

   with object ( ::oBrwOriginalLines:AddCol() )
      :cHeader          := "Unidades"
      :bStrData         := {|| if( len( ::aInfoLines ) == 0, "", Trans( hGet( ::aInfoLines[ ::oBrwOriginalLines:nArrayAt ], "Unidades" ), MasUnd() ) ) }
      :nWidth           := 70
      :nDataStrAlign    := 1
      :nHeadStrAlign    := 1
   end with

   with object ( ::oBrwOriginalLines:AddCol() )
      :cHeader          := "Stock"
      :bStrData         := {|| if( len( ::aInfoLines ) == 0, "", Trans( hGet( ::aInfoLines[ ::oBrwOriginalLines:nArrayAt ], "Stock" ), MasUnd() ) ) }
      :nWidth           := 70
      :nDataStrAlign    := 1
      :nHeadStrAlign    := 1
   end with

   with object ( ::oBrwOriginalLines:AddCol() )
      :cHeader          := "Stock real"
      :bStrData         := {|| if( len( ::aInfoLines ) == 0, "", Trans( hGet( ::aInfoLines[ ::oBrwOriginalLines:nArrayAt ], "Stockreal" ), MasUnd() ) ) }
      :nWidth           := 70
      :nDataStrAlign    := 1
      :nHeadStrAlign    := 1
   end with

   with object ( ::oBrwOriginalLines:AddCol() )
      :cHeader          := "A producir"
      :bStrData         := {|| if( len( ::aInfoLines ) == 0, "", Trans( hGet( ::aInfoLines[ ::oBrwOriginalLines:nArrayAt ], "Producir" ), MasUnd() ) ) }
      :nWidth           := 70
      :nDataStrAlign    := 1
      :nHeadStrAlign    := 1
   end with

   REDEFINE BUTTON ;
      ID       550 ;
      OF       ::oDlg ;
      CANCEL ;
      ACTION   ( ::End() )

   ACTIVATE DIALOG ::oDlg CENTER

Return self

//---------------------------------------------------------------------------//

METHOD lPrepareInfo( oWndBrw ) CLASS TPrepareDocumentQR

   local aResult
   local nRecAct
   local nRecAnt        := ( ::DbfCabecera )->( Recno() )

   ::aInfoLines         := {}
   ::aMateriasPrimas    := {}

   for each nRecAct in ( oWndBrw:oBrw:aSelected )

      ( ::DbfCabecera )->( dbGoTo( nRecAct ) )

      aResult           := PedidosClientesLineasModel():getLinesFromDocument( ( ::DbfCabecera )->cSerPed, ( ::DbfCabecera )->nNumPed, ( ::DbfCabecera )->cSufPed )

      aEval( aResult, {|a| ::aAddInfoLines( a ) } )

   next

   ( ::DbfCabecera )->( dbGoTo( nRecAnt ) )

Return self

//---------------------------------------------------------------------------//

METHOD aAddInfoLines( aField ) CLASS TPrepareDocumentQR

   local nPos  := 0

   if Len( ::aInfoLines ) == 0

      aAdd( ::aInfoLines, {   "Codigo"          => aField[ ( ::dbfLineas )->( FieldPos( "cRef" ) ) ],;
                              "Nombre"          => aField[ ( ::dbfLineas )->( FieldPos( "cDetalle" ) ) ],;
                              "Unidades"        => aField[ ( ::dbfLineas )->( FieldPos( "nUniCaja" ) ) ],;
                              "Stock"           => 0,;
                              "Stockreal"       => 0,;
                              "Producir"        => 0 } )

   else

      nPos     := aScan( ::aInfoLines, {|h| hGet( h, "Codigo" ) == aField[ ( ::dbfLineas )->( FieldPos( "cRef" ) ) ] } )

      if nPos == 0
         
         aAdd( ::aInfoLines, {   "Codigo"       => aField[ ( ::dbfLineas )->( FieldPos( "cRef" ) ) ],;
                                 "Nombre"       => aField[ ( ::dbfLineas )->( FieldPos( "cDetalle" ) ) ],;
                                 "Unidades"     => aField[ ( ::dbfLineas )->( FieldPos( "nUniCaja" ) ) ],;
                                 "Stock"        => 0,;
                                 "Stockreal"    => 0,;
                                 "Producir"     => 0 } )         
      else

         hSet( ::aInfoLines[ nPos ], "Unidades", ( hGet( ::aInfoLines[ nPos ], "Unidades" ) + aField[ ( ::dbfLineas )->( FieldPos( "nUniCaja" ) ) ] ) )

      end if

   end if

Return self

//---------------------------------------------------------------------------//

METHOD addStockInfo() CLASS TPrepareDocumentQR

   if len( ::aInfoLines() ) == 0
      Return self
   end if

   aEval( ::aInfoLines, {|h| hSet( h, "Stock", StocksModel():nGlobalStockArticulo( hGet( h, "Codigo" ) ) ) } )

Return self   

//---------------------------------------------------------------------------//   

METHOD addProducir() CLASS TPrepareDocumentQR

   local hLine
   local nProducir      := 0
   local nStock         := 0

   for each hLine in ::aInfoLines

      nStock            := hGet( hLine, "Stock" )

      if nStock < 0
         nProducir      := hGet( hLine, "Unidades" ) + ( nStock * - 1 )
      else
         
         if nStock < hGet( hLine, "Unidades" )
            nProducir   := hGet( hLine, "Unidades" ) - nStock
         end if 

      end if

      hSet( hLine, "Producir", nProducir )

   next

Return self

//---------------------------------------------------------------------------//

METHOD addStockReal() CLASS TPrepareDocumentQR

   local hLine

   for each hLine in ::aInfoLines
      hSet( hLine, "Stockreal", ( hGet( hLine, "Stock" ) - hGet( hLine, "Unidades" ) ) )
   next

Return self

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TPrepareOrderQR FROM TPrepareDocumentQR

   DATA cGetDoc

   METHOD New()

   METHOD lGetDoc()

   METHOD loadUnprepareLinesFromDocument()
   METHOD loadPrepareLinesFromDocument()
   METHOD loadKitLinesFromDocument()

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS TPrepareOrderQR

   if ::lGetDoc()

      ::cTituloVentana           := "pedido de cliente"

      ::cTextoNumeroDocumento    := "Documento : " + ( D():PedidosClientes( ::nView ) )->cSerPed + "/" + Alltrim( str( ( D():PedidosClientes( ::nView ) )->nNumPed ) ) + "/" + ( D():PedidosClientes( ::nView ) )->cSufPed
      ::cTextoClienteDocumento   := "Cliente : " + AllTrim( ( D():PedidosClientes( ::nView ) )->cCodCli ) + " - " + AllTrim( ( D():PedidosClientes( ::nView ) )->cNomCli )

      ::cNumBultos               := ( D():PedidosClientes( ::nView ) )->nBultos
      ::cNumEstuches             := Val( ( D():PedidosClientes( ::nView ) )->cRetMat )
      ::cFechaSalida             := ( D():PedidosClientes( ::nView ) )->dFecEnt

      ::cSerieDocumento          := ( D():PedidosClientes( ::nView ) )->cSerPed
      ::nNumeroDocumento         := ( D():PedidosClientes( ::nView ) )->nNumPed
      ::cSufijoDocumento         := ( D():PedidosClientes( ::nView ) )->cSufPed

      ::cIdDocumento             := ( D():PedidosClientes( ::nView ) )->cSerPed + str( ( D():PedidosClientes( ::nView ) )->nNumPed ) + ( D():PedidosClientes( ::nView ) )->cSufPed

      ::DbfCabecera              := ( D():PedidosClientes( ::nView ) )
      ::dbfLineas                := ( D():PedidosClientesLineas( ::nView ) )

      ::Super:New() 

   else 
      ::cIdDocumento             := ""
   end if

Return( Self )

//---------------------------------------------------------------------------//

METHOD lGetDoc() CLASS TPrepareOrderQR

   ::cGetDoc                  := Space( 12 )

   MsgGet( "Seleccione pedido", "Pedido: ", @::cGetDoc )

   if Empty( ::cGetDoc )
      ::lBreak                := .t.
      Return .f.         
   end if

   if !( D():PedidosClientes( ::nView ) )->( dbSeek( Padr( ::cGetDoc, 12 ) ) )
      ::lBreak                := .t.
      MsgBeepStop( "No ha seleccionado un documento válido" )
      Return .f.
   end if

Return( .t. )

//---------------------------------------------------------------------------//

METHOD loadUnprepareLinesFromDocument() CLASS TPrepareOrderQR

Return( PedidosClientesLineasModel():getLinesFromDocument( ::cSerieDocumento, ::nNumeroDocumento, ::cSufijoDocumento ) )
 
//---------------------------------------------------------------------------//

METHOD loadPrepareLinesFromDocument() CLASS TPrepareOrderQR

Return( PedidosClientesLineasModel():getLinesFromDocument( ::cSerieDocumento, ::nNumeroDocumento, ::cSufijoDocumento, .t. ) )

//---------------------------------------------------------------------------//

METHOD loadKitLinesFromDocument() CLASS TPrepareOrderQR

Return( PedidosClientesLineasModel():getLinesKitsFromDocument( ::cSerieDocumento, ::nNumeroDocumento, ::cSufijoDocumento, .t. ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//