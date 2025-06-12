#include "FiveWin.Ch"
#include "Factu.ch" 
#include "Xbrowse.ch"

CLASS RecStockView FROM ViewBase

   DATA oMeterStock
   DATA nMeterStock
   DATA oSayInformacion

   METHOD New()

   METHOD insertControls()

   METHOD defineAceptarCancelar()   INLINE ( self )

   METHOD defineMeter

   METHOD getTitleTipoDocumento()   INLINE ( ::getTextoTipoDocumento() )

   METHOD startDialog()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( oSender ) CLASS RecStockView

   ::oSender               := oSender

   ::nMeterStock           := 0
   
Return ( self )

//---------------------------------------------------------------------------//

METHOD insertControls() CLASS RecStockView

   ::defineMeter()

Return ( Self )

//---------------------------------------------------------------------------//

METHOD defineMeter() CLASS RecStockView

   TGridSay():Build(    {  "nRow"      => 55,;
                           "nCol"      => {|| GridWidth( 0.5, ::oDlg ) },;
                           "bText"     => {|| "Proceso..." },;
                           "oWnd"      => ::oDlg,;
                           "oFont"     => oGridFont(),;
                           "lPixels"   => .t.,;
                           "nClrText"  => Rgb( 0, 0, 0 ),;
                           "nClrBack"  => Rgb( 255, 255, 255 ),;
                           "nWidth"    => {|| GridWidth( 2.5, ::oDlg ) },;
                           "nHeight"   => 23,;
                           "lDesign"   => .f. } )

   ::oMeterStock        := TGridMeter():Build( {   "nRow"            => 55,;
                                                   "nCol"            => {|| GridWidth( 3.5, ::oDlg ) },;
                                                   "bSetGet"         => {|u| if( PCount() == 0, ::nMeterStock, ::nMeterStock := u ) },;
                                                   "oWnd"            => ::oDlg,;
                                                   "nWidth"          => {|| GridWidth( 8.5, ::oDlg ) },;
                                                   "nHeight"         => 20,;
                                                   "lPixel"          => .t.,;
                                                   "lUpdate"         => .t.,;
                                                   "lNoPercentage"   => .t.,;
                                                   "nClrPane"        => rgb( 255,255,255 ),;
                                                   "nClrBar"         => rgb( 128,255,0 ) } )

   ::oSayInformacion    := TGridSay():Build(    {  "nRow"            => 90,;
                                                   "nCol"            => {|| GridWidth( 0.5, ::oDlg ) },;
                                                   "bText"           => {|| "" },;
                                                   "oWnd"            => ::oDlg,;
                                                   "oFont"           => oGridFont(),;
                                                   "lPixels"         => .t.,;
                                                   "nClrText"        => Rgb( 0, 0, 0 ),;
                                                   "nClrBack"        => Rgb( 255, 255, 255 ),;
                                                   "nWidth"          => {|| GridWidth( 11.5, ::oDlg ) },;
                                                   "nHeight"         => 23,;
                                                   "lDesign"         => .f.,;
                                                   "lCentered"       => .t. } )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD startDialog() CLASS RecStockView

   ::oSender:runRecStock()

   ::oDlg:End()

Return ( self )

//---------------------------------------------------------------------------//
