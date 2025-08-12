#include "FiveWin.Ch"
#include "Report.ch"
#include "Xbrowse.ch"
#include "MesDbf.ch"
#include "Factu.ch" 
#include "FastRepH.ch"

//---------------------------------------------------------------------------//

CLASS VerificaProduct

   DATA oCodeBar
   DATA cCodeBar
   DATA oCodeBar2
   DATA cCodeBar2

   DATA oTextoArticulo
   DATA cTextoArticulo

   DATA oTextoPrecio
   DATA cTextoPrecio

   DATA cCodigoArticulo

   DATA nView

   METHOD New()

   METHOD Resource()

   METHOD validAndSeek()

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS VerificaProduct

   ::cCodeBar                 := Space( 18 )
   ::cCodeBar2                := Space( 18 )
   ::cTextoArticulo           := "Pase el código de barras"
   ::cTextoPrecio             := ""
   ::cCodigoArticulo          := ""

   ::nView    := D():CreateView()

   ::Resource()

   D():DeleteView( ::nView )

Return( Self )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS VerificaProduct

   local oDlg
   local nRow           := 0           
   local cTitle         := "gestool Verifica Producto : " + uFieldEmpresa( "CodEmp" ) + "-" + uFieldEmpresa( "cNombre" )
   local oGridTree

   oDlg                 := TDialog():New( 1, 5, 40, 100, cTitle,,, .f., nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_SYSMENU, WS_MINIMIZEBOX, WS_MAXIMIZEBOX ),, rgb( 255, 255, 255 ),,, .F.,, oGridFont(),,,, .f.,, "oDlg" )  

   ::oCodeBar           := TGridGet():Build(    {  "nRow"      => 45,;
                                                   "nCol"      => {|| GridWidth( 0.5, oDlg ) },;
                                                   "bSetGet"   => {|u| if( PCount() == 0, ::cCodeBar, ::cCodeBar := u ) },;
                                                   "oWnd"      => oDlg,;
                                                   "nWidth"    => {|| GridWidth( 9, oDlg ) },;
                                                   "nHeight"   => 25,;
                                                   "lPixels"   => .t.,;
                                                   "bValid"    => {|| ::validAndSeek() } } )

   ::oCodeBar2          := TGridGet():Build(    {  "nRow"      => 45,;
                                                   "nCol"      => {|| GridWidth( 0.5, oDlg ) },;
                                                   "bSetGet"   => {|u| if( PCount() == 0, ::cCodeBar2, ::cCodeBar2 := u ) },;
                                                   "oWnd"      => oDlg,;
                                                   "nWidth"    => {|| GridWidth( 9, oDlg ) },;
                                                   "nHeight"   => 0,;
                                                   "lPixels"   => .t.,;
                                                   "bValid"    => {|| .t. } } )

   ::oTextoArticulo     := TGridSay():Build(    {  "nRow"      => 75,;
                                                   "nCol"      => {|| GridWidth( 0.5, oDlg ) },;
                                                   "bText"     => {|| ::cTextoArticulo },;
                                                   "oWnd"      => oDlg,;
                                                   "oFont"     => oGridFontBold(),;
                                                   "lPixels"   => .t.,;
                                                   "nClrText"  => Rgb( 0, 0, 0 ),;
                                                   "nClrBack"  => Rgb( 255, 255, 255 ),;
                                                   "nWidth"    => {|| GridWidth( 8, oDlg ) },;
                                                   "nHeight"   => 32,;
                                                   "lDesign"   => .f. } )

   ::oTextoPrecio       := TGridSay():Build(    {  "nRow"      => 105,;
                                                   "nCol"      => {|| GridWidth( 0.5, oDlg ) },;
                                                   "bText"     => {|| ::cTextoPrecio },;
                                                   "oWnd"      => oDlg,;
                                                   "oFont"     => oGridFontBold(),;
                                                   "lPixels"   => .t.,;
                                                   "nClrText"  => Rgb( 0, 0, 0 ),;
                                                   "nClrBack"  => Rgb( 255, 255, 255 ),;
                                                   "nWidth"    => {|| GridWidth( 8, oDlg ) },;
                                                   "nHeight"   => 32,;
                                                   "lDesign"   => .f. } )

   //----------------Salir-----------------------------------------------------

   TGridImage():Build(  {  "nTop"      => {|| GridRow( 3 ) },;
                           "nLeft"     => {|| GridWidth( 11.5, oDlg ) - 64 },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "",;
                           "bLClicked" => {|| oDlg:End() },;
                           "oWnd"      => oDlg } )
   
   

   // Redimensionamos y activamos el diálogo----------------------------------- 

   oDlg:bResized        := {|| GridResize( oDlg ) }

   ACTIVATE DIALOG oDlg CENTER ON INIT ( GridMaximize( oDlg ) )

Return( .t. )

//---------------------------------------------------------------------------//

METHOD validAndSeek()

   ::cCodigoArticulo    := cSeekCodebar( ::cCodeBar, D():ArticulosCodigosBarras( ::nView ), D():Articulos( ::nView ) )
   
   ::oTextoArticulo:setText( ArticulosModel():getField( 'Nombre', 'Codigo', ::cCodigoArticulo ) )
   ::oTextoPrecio:setText( "PVP: " + Trans( ArticulosModel():getField( 'pVtaIva1', 'Codigo', ::cCodigoArticulo ), cPorDiv() ) + "€" )

   ::oCodeBar:cText( Space( 18 ) )
   ::oCodeBar:SetFocus()

   WaitSeconds( 5 )

   ::oTextoArticulo:setText( "Pase el código de barras" )
   ::oTextoPrecio:setText( "" )

Return( .t. )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//