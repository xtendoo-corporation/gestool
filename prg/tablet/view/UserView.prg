#include "FiveWin.Ch"
#include "Factu.ch" 
#include "Xbrowse.ch"

CLASS UserView FROM ViewBase

   DATA oCbxUsuario
   DATA aCbxUsuario
   DATA cCbxUsuario

   METHOD New()

   METHOD insertControls()

   METHOD defineAceptarCancelar()

   METHOD defineCombo()

   METHOD getTitleTipoDocumento()   INLINE ( ::getTextoTipoDocumento() )

END CLASS

//---------------------------------------------------------------------------//

METHOD New( oSender ) CLASS UserView

   ::oSender         := oSender

Return ( self )

//---------------------------------------------------------------------------//

METHOD insertControls() CLASS UserView

   ::defineCombo()

Return ( Self )

//---------------------------------------------------------------------------//

METHOD defineCombo() CLASS UserView

   ::cCbxUsuario     := Padr( UsuariosModel():getNombreUsuarioWhereNetName( Alltrim( netname() ) + AllTrim( WNetGetUser() ) ), 100 )
   ::aCbxUsuario     := UsuariosModel():getNamesUsuarios() 

   TGridSay():Build(    {  "nRow"      => 55,;
                           "nCol"      => {|| GridWidth( 0.5, ::oDlg ) },;
                           "bText"     => {|| "Usuario" },;
                           "oWnd"      => ::oDlg,;
                           "oFont"     => oGridFont(),;
                           "lPixels"   => .t.,;
                           "nClrText"  => Rgb( 0, 0, 0 ),;
                           "nClrBack"  => Rgb( 255, 255, 255 ),;
                           "nWidth"    => {|| GridWidth( 1.5, ::oDlg ) },;
                           "nHeight"   => 23,;
                           "lDesign"   => .f. } )

   ::oCbxUsuario     := TGridComboBox():Build(  {  "nRow"      => 55,;
                                                   "nCol"      => {|| GridWidth( 3, ::oDlg ) },;
                                                   "bSetGet"   => {|u| if( PCount() == 0, ::cCbxUsuario, ::cCbxUsuario := u ) },;
                                                   "oWnd"      => ::oDlg,;
                                                   "nWidth"    => {|| GridWidth( 5, ::oDlg ) },;
                                                   "nHeight"   => 25,;
                                                   "aItems"    => ::aCbxUsuario } )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD defineAceptarCancelar() CLASS UserView
   
   TGridImage():Build(  {  "nTop"      => 5,;
                           "nLeft"     => {|| GridWidth( 9.0, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_error_64",;
                           "bLClicked" => {|| ::oDlg:End() },;
                           "oWnd"      => ::oDlg } )

   TGridImage():Build(  {  "nTop"      => 5,;
                           "nLeft"     => {|| GridWidth( 10.5, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_ok_64",;
                           "bLClicked" => {|| ::oSender:run(), ::oDlg:End() },;
                           "oWnd"      => ::oDlg } )

Return ( self )

//---------------------------------------------------------------------------//