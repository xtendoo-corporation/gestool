#include "FiveWin.Ch"
#include "HbXml.ch"
#include "TDbfDbf.ch"
#include "Struct.ch"
#include "Factu.ch" 
#include "Ini.ch"
#include "MesDbf.ch"
#include "Report.ch"
#include "Print.ch"
#include "Xbrowse.ch"

//---------------------------------------------------------------------------//

function InicioHRB( nView, aGet )

   local cCodArt

   cCodArt  :=  fastAddArticulo():run( nView )

   if !Empty( aGet[ ( D():PedidosProveedoresLineas( nView ) )->( fieldpos( "cRef" ) ) ] )
      aGet[ ( D():PedidosProveedoresLineas( nView ) )->( fieldpos( "cRef" ) ) ]:cText( cCodArt )
      aGet[ ( D():PedidosProveedoresLineas( nView ) )->( fieldpos( "cRef" ) ) ]:lValid()
   end if

return ( nil )

//---------------------------------------------------------------------------//

CLASS fastAddArticulo

   DATA nView

   DATA oDlg
   DATA oBrw
   DATA oCol

   DATA cCodigoArticulo

   DATA aCampos               INIT {}
   DATA hFamilias             INIT {=>}
   DATA hTiposArticulos       INIT {=>}

   DATA hFormatoColumnas

   METHOD run( nView )

   METHOD setCampos()

   METHOD Resource()

   METHOD addArticulo()

   METHOD getCodigoArticulo()

   Method setColType( uValue )         INLINE ( ::oCol:nEditType := uValue )
   Method setColPicture( uValue )      INLINE ( ::oCol:cEditPicture := uValue )
   Method setColListTxt( aValue )      INLINE ( ::oCol:aEditListTxt := aValue )

   METHOD startDialog()

   METHOD addCampoExtra( Codigo, Clave, Valor )

   METHOD getArrayFamilias()

   METHOD ChangeBrowse()

   METHOD lPresave()

   METHOD getArrayTiposArticulos()

ENDCLASS

//---------------------------------------------------------------------------//

METHOD run( nView ) CLASS fastAddArticulo

   ::nView     := nView

   ::hFormatoColumnas      := {  "get"    => {||   ::setColType( EDIT_GET ) ,;
                                                   ::setColPicture( hGet( ::aCampos[ ::oBrw:nArrayAt ], "picture" ) ) } ,;
                                 "combo"  => {||   ::setColType( EDIT_LISTBOX ) ,;
                                                   ::setColListTxt( hGet( ::aCampos[ ::oBrw:nArrayAt ], "valores" ) ) ,;
                                                   ::setColPicture( hGet( ::aCampos[ ::oBrw:nArrayAt ], "picture" ) ) } }


   ::getArrayFamilias()
   ::getArrayTiposArticulos()
   ::setCampos()

   if ::Resource()
      ::addArticulo()
   end if

Return ( ::cCodigoArticulo )

//---------------------------------------------------------------------------//

METHOD setCampos() CLASS fastAddArticulo

   if isArray( ::aCampos )

      aAdd( ::aCampos, { 'clave' => 'C�digo', 'valor' => ::getCodigoArticulo(), "picture" => "", 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Nombre', 'valor' => Space( 100 ), "picture" => "", 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Familia', 'valor' => Space( 16 ), "picture" => "", 'tipo' => "combo", 'valores' => hGetValues( ::hFamilias ) } )
      aAdd( ::aCampos, { 'clave' => 'Tipo', 'valor' => Space( 4 ), "picture" => "", 'tipo' => "combo", 'valores' => hGetValues( ::hTiposArticulos ) } )
      aAdd( ::aCampos, { 'clave' => 'Costo', 'valor' => 0, "picture" => cPinDiv(), 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'N�mero cajas (palets)', 'valor' => 0, "picture" => MasUnd(), 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Fecha de compra', 'valor' => GetSysDate(), "picture" => "", 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Barco', 'valor' => Space( 50 ), "picture" => "", 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Marea', 'valor' => Space( 15 ), "picture" => "", 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Lote', 'valor' => Space( 50 ),  "picture" => "", 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Observaciones Fto.', 'valor' => Space( 50 ),  "picture" => "", 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Unidad embalaje', 'valor' => 0, "picture" => cPinDiv(), 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Tara', 'valor' => 0, "picture" => cPinDiv(), 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Fecha entrada', 'valor' => GetSysDate(), "picture" => "", 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Fecha final', 'valor' => GetSysDate(), "picture" => "", 'tipo' => "get", 'valores' => {=>} } )
      aAdd( ::aCampos, { 'clave' => 'Fecha caducidad', 'valor' => GetSysDate(), "picture" => "", 'tipo' => "get", 'valores' => {=>} } )

   end if

Return ( self )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS fastAddArticulo
   
   local oBmp
   local oTxt
   local oBtnAceptar

   DEFINE DIALOG ::oDlg RESOURCE "EXTRADET" TITLE "A�adir art�culo"

   REDEFINE BITMAP oBmp ;
      ID          600 ;
      RESOURCE    "Cube_Yellow_Alpha_48" ;
      TRANSPARENT ;
      OF          ::oDlg

      REDEFINE SAY oTxt ;
         VAR      "A�adiendo art�culos" ;
         ID       610 ;
         OF       ::oDlg

      ::oBrw                        := IXBrowse():New( ::oDlg )

      ::oBrw:bClrSel                := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrw:bClrSelFocus           := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrw:SetArray( ::aCampos, , , .f. )

      ::oBrw:nMarqueeStyle          := MARQSTYLE_HIGHLCELL
      ::oBrw:lRecordSelector        := .f.
      ::oBrw:lHScroll               := .f.
      ::oBrw:lFastEdit              := .t.

      ::oBrw:CreateFromResource( 100 )

      with object ( ::oBrw:AddCol() )
         :cHeader          := "Campo"
         :bStrData         := {|| AllTrim( hGet( ::aCampos[ ::oBrw:nArrayAt ], "clave" ) ) }
         :nWidth           := 250
      end with

      with object ( ::oCol := ::oBrw:AddCol() )
         :cHeader          := "Valor"
         :bEditValue       := {|| hGet( ::aCampos[ ::oBrw:nArrayAt ], "valor" ) }
         :bStrData         := {|| hGet( ::aCampos[ ::oBrw:nArrayAt ], "valor" ) }
         :nWidth           := 300
      end with

      ::oBrw:bChange       := {|| ::ChangeBrowse() }

   REDEFINE BUTTON oBtnAceptar ;
      ID          IDOK ;
      OF          ::oDlg ;
      ACTION      ( if( ::lPreSave(), ::oDlg:End( IDOK ), ) )

   REDEFINE BUTTON  ;
      ID          IDCANCEL ;
      OF          ::oDlg ;
      CANCEL ;
      ACTION      ( ::oDlg:End( IDCANCEL ) )

      ::oDlg:AddFastKey( VK_F5, {|| oBtnAceptar:Click() } )

      ::oDlg:bStart  := {|| ::startDialog }

   ACTIVATE DIALOG ::oDlg CENTER

   oBmp:End()

Return ( ::oDlg:nResult == IDOK )

//---------------------------------------------------------------------------//

METHOD ChangeBrowse() CLASS fastAddArticulo

   Eval( hGet( ::hFormatoColumnas, AllTrim( hGet( ::aCampos[ ::oBrw:nArrayAt ], "tipo" ) ) ) )

   ::oCol:bOnPostEdit            := {|o,x,n| hSet( ::aCampos[ ::oBrw:nArrayAt ], "valor", x ) }

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lPresave() CLASS fastAddArticulo

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD StartDialog() CLASS fastAddArticulo

   ::oBrw:GoDown()
   ::oBrw:GoToCol( ::oCol )

   ::oBrw:LDblClick( ::oBrw:nColSel, ::oBrw:nRowSel )

   ::ChangeBrowse()

Return ( self )

//---------------------------------------------------------------------------//

METHOD addArticulo() CLASS fastAddArticulo

   local nKey

   if !isArray( ::aCampos ) .or. Empty( ::aCampos )
      Return nil
   end if

   /*
   Art�culo--------------------------------------------------------------------
   */

   ( D():Articulos( ::nView ) )->( dbAppend() )

   ( D():Articulos( ::nView ) )->Codigo       := AllTrim( hGet( ::aCampos[ 1 ], "valor" ) )
   ( D():Articulos( ::nView ) )->Nombre       := AllTrim( hGet( ::aCampos[ 2 ], "valor" ) )
   ( D():Articulos( ::nView ) )->pCosto       := hGet( ::aCampos[ 5 ], "valor" )
   ( D():Articulos( ::nView ) )->LastChg      := GetSysDate()
   ( D():Articulos( ::nView ) )->Familia      := if( !Empty( hGet( ::aCampos[ 3 ], "valor" ) ), Padr( hGetKeyAt( ::hFamilias, HScan( ::hFamilias, {|k,v,i| v == hGet( ::aCampos[ 3 ], "valor" ) } ) ), 16 ), Space( 16 ) )
   ( D():Articulos( ::nView ) )->cCodTip      := if( !Empty( hGet( ::aCampos[ 4 ], "valor" ) ), Padr( hGetKeyAt( ::hTiposArticulos, HScan( ::hTiposArticulos, {|k,v,i| v == hGet( ::aCampos[ 4 ], "valor" ) } ) ), 4 ), Space( 4 ) )
   ( D():Articulos( ::nView ) )->nLabel       := 1
   ( D():Articulos( ::nView ) )->nCtlStock    := 1
   ( D():Articulos( ::nView ) )->lIvaInc      := uFieldEmpresa( "lIvaInc" )
   ( D():Articulos( ::nView ) )->TipoIva      := cDefIva()
   ( D():Articulos( ::nView ) )->nCajPlt      := hGet( ::aCampos[ 6 ], "valor" )
   ( D():Articulos( ::nView ) )->dFecLgt      := hGet( ::aCampos[ 7 ], "valor" )

   ( D():Articulos( ::nView ) )->( dbUnLock() )

   ::addCampoExtra( "004", AllTrim( hGet( ::aCampos[ 1 ], "valor" ) ), AllTrim( hGet( ::aCampos[ 8 ], "valor" ) ) )           // Barco
   ::addCampoExtra( "018", AllTrim( hGet( ::aCampos[ 1 ], "valor" ) ), AllTrim( hGet( ::aCampos[ 9 ], "valor" ) ) )           // Marea
   ::addCampoExtra( "010", AllTrim( hGet( ::aCampos[ 1 ], "valor" ) ), AllTrim( hGet( ::aCampos[ 10 ], "valor" ) ) )          // Lote
   ::addCampoExtra( "016", AllTrim( hGet( ::aCampos[ 1 ], "valor" ) ), AllTrim( hGet( ::aCampos[ 11 ], "valor" ) ) )          // Observaciones Fto
   ::addCampoExtra( "022", AllTrim( hGet( ::aCampos[ 1 ], "valor" ) ), AllTrim( Str( hGet( ::aCampos[ 12 ], "valor" ) ) ) )   // Unidad embalaje
   ::addCampoExtra( "023", AllTrim( hGet( ::aCampos[ 1 ], "valor" ) ), AllTrim( Str( hGet( ::aCampos[ 13 ], "valor" ) ) ) )   // Tara
   ::addCampoExtra( "019", AllTrim( hGet( ::aCampos[ 1 ], "valor" ) ), dtoc( hGet( ::aCampos[ 14 ], "valor" ) ) )             // fecha entrada
   ::addCampoExtra( "038", AllTrim( hGet( ::aCampos[ 1 ], "valor" ) ), dtoc( hGet( ::aCampos[ 15 ], "valor" ) ) )             // fecha final
   ::addCampoExtra( "039", AllTrim( hGet( ::aCampos[ 1 ], "valor" ) ), dtoc( hGet( ::aCampos[ 16 ], "valor" ) ) )             // fecha caducidad

Return ( self )

//---------------------------------------------------------------------------//

METHOD addCampoExtra( Codigo, Clave, Valor ) CLASS fastAddArticulo

   local nOrdAnt  := ( D():DetCamposExtras( ::nView ) )->( OrdSetFocus( "cTotClave" ) )

   /*
   Campos Extra----------------------------------------------------------------
   */

   if !( D():DetCamposExtras( ::nView ) )->( dbSeek( "20" + Codigo + Clave ) )

      ( D():DetCamposExtras( ::nView ) )->( dbAppend() )

      ( D():DetCamposExtras( ::nView ) )->cTipDoc     :=  "20"
      ( D():DetCamposExtras( ::nView ) )->cCodTipo    :=  Codigo
      ( D():DetCamposExtras( ::nView ) )->cClave      :=  Clave
      ( D():DetCamposExtras( ::nView ) )->cValor      :=  Valor

      ( D():DetCamposExtras( ::nView ) )->( dbUnLock() )

   else

      if dbLock( D():DetCamposExtras( ::nView ) )
         ( D():DetCamposExtras( ::nView ) )->cValor   :=  Valor
         ( D():DetCamposExtras( ::nView ) )->( dbUnLock() )
      end if

   end if

Return ( self )

//---------------------------------------------------------------------------//

METHOD getCodigoArticulo() CLASS fastAddArticulo

   local cCodArt        := ""
   local nOrdAnt        := ( D():Articulos( ::nView ) )->( OrdSetFocus( "Codigo" ) )

   ( D():Articulos( ::nView ) )->( dbSeek( "999999", .t. ) )

   ( D():Articulos( ::nView ) )->( dbSkip( -1 ) )

   cCodArt              := ( D():Articulos( ::nView ) )->Codigo
   cCodArt              := AllTrim( str( val( ( D():Articulos( ::nView ) )->Codigo ) + 1 ) )

   ( D():Articulos( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

   ::cCodigoArticulo    := padr( cCodArt, 18 )

Return ( ::cCodigoArticulo )

//---------------------------------------------------------------------------//

METHOD getArrayFamilias() CLASS fastAddArticulo

   ::hFamilias       := {=>}
   
   ( D():Familias( ::nView ) )->( dbGoTop() )

   while !( D():Familias( ::nView ) )->( Eof() )

      hSet( ::hFamilias, ( D():Familias( ::nView ) )->cCodFam, ( D():Familias( ::nView ) )->cNomFam )

      ( D():Familias( ::nView ) )->( dbSkip() )

   end while

Return ( nil )

//---------------------------------------------------------------------------//

METHOD getArrayTiposArticulos() CLASS fastAddArticulo

   ::hTiposArticulos       := {=>}
   
   ( D():TipoArticulos( ::nView ) )->( dbGoTop() )

   while !( D():TipoArticulos( ::nView ) )->( Eof() )

      hSet( ::hTiposArticulos, ( D():TipoArticulos( ::nView ) )->cCodTip, ( D():TipoArticulos( ::nView ) )->cNomTip )

      ( D():TipoArticulos( ::nView ) )->( dbSkip() )

   end while

Return ( nil )

//---------------------------------------------------------------------------//