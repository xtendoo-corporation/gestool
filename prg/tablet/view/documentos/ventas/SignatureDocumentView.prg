#include "FiveWin.Ch"
#include "Factu.ch" 
#include "Xbrowse.ch"

CLASS SignatureDocumentView FROM ViewBase

   DATA oCheckConfirm
   DATA lCheckConfirm
   
   DATA oSaySignature

   DATA hDC
   DATA lPaint

   DATA oBtnClear
   DATA oBtnSave

   DATA cFile

   DATA oPenSig

   METHOD New()

   METHOD insertControls()

   METHOD defineAceptarCancelar()

   METHOD isEndOk()                    INLINE ( ::oDlg:nResult == IDOK )

   METHOD initDialog()

   METHOD validDialog()

   METHOD endView()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( oSender ) CLASS SignatureDocumentView

   ::oSender         := oSender

   ::lPaint          := .f.

    ::cFile          := cPatBmp() + "signature.bmp"  

Return ( self )

//---------------------------------------------------------------------------//

METHOD insertControls() CLASS SignatureDocumentView

   DEFINE PEN ::oPenSig WIDTH 4 COLOR CLR_BLACK

   ::oCheckConfirm      := TGridCheckBox():Build(  {  "nRow"      => ::getRow(),;       
                                                      "nCol"      => {|| GridWidth( 0.5, ::oDlg ) },;
                                                      "cCaption"  => "He leído y acepto las condiciones.",;
                                                      "bSetGet"   => {|u| iif(  isNil( u ),;
                                                                        hGet( ::oSender:oParent():hDictionaryMaster, "ConfirmaFirma" ),;
                                                                        hSet( ::oSender:oParent():hDictionaryMaster, "ConfirmaFirma", u ) ) },;
                                                      "oWnd"      => ::oDlg,;
                                                      "nWidth"    => {|| GridWidth( 8.5, ::oDlg ) },;
                                                      "nHeight"   => 23,;
                                                      "bWhen"     => {|| ::oSender:oParent():lNotZoomMode() },;
                                                      "oFont"     => oGridFont(),;
                                                      "lPixels"   => .t. } )
   ::nextRow()

   ::oSaySignature      := TGridSay():Build(    {     "nRow"      => ::getRow(),;       
                                                      "nCol"      => {|| GridWidth( 0.5, ::oDlg ) },;
                                                      "bText"     => {|| "" },;
                                                      "oWnd"      => ::oDlg,;
                                                      "lPixels"   => .t.,;
                                                      "nClrText"  => Rgb( 0, 0, 0 ),;
                                                      "nClrBack"  => Rgb( 250, 250, 250 ),;
                                                      "nWidth"    => {|| GridWidth( 11, ::oDlg ) },;
                                                      "nHeight"   => {|| 500 },;
                                                      "bWhen"     => {|| ::oSender:oParent():lNotZoomMode() },;
                                                      "lDesign"   => .f. } )

   ::oSaySignature:lWantClick := .t.
   ::oSaySignature:bLButtonUp := { | x, y, z | DoDraw( ::hDC, y+1, x+1, ::lPaint := .f., ::oPenSig ) } 
   ::oSaySignature:bMMoved    := { | x, y, z | DoDraw( ::hDC, y, x , ::lPaint, ::oPenSig ) } 
   ::oSaySignature:bLClicked  := { | x, y, z | DoDraw( ::hDC, y, x, ::lPaint := .t., ::oPenSig ) }

Return ( Self )

//---------------------------------------------------------------------------//

METHOD initDialog() CLASS SignatureDocumentView

   ::super:initDialog()

   if ::oSender:oParent():lNotZoomMode()
      ::hDC := GetDC( ::oSaySignature:hWnd )
   end if

Return ( Self )

//---------------------------------------------------------------------------//

METHOD validDialog() CLASS SignatureDocumentView

   if ::oSender:oParent():lNotZoomMode()
      ReleaseDC( ::oSaySignature:hWnd, ::hDC )
   end if

Return ( .t. )

//---------------------------------------------------------------------------//


METHOD defineAceptarCancelar() CLASS SignatureDocumentView
   
   ::oBtnClear          := TGridImage():Build(  {     "nTop"      => 5,;
                                                      "nLeft"     => {|| GridWidth( 9, ::oDlg ) },;
                                                      "nWidth"    => 64,;
                                                      "nHeight"   => 64,;
                                                      "cResName"  => "gc_broom_64",;
                                                      "bLClicked" => {|| ::oSaySignature:refresh( .t. ) },;
                                                      "bWhen"     => {|| ::oSender:oParent():lNotZoomMode() },;
                                                      "oWnd"      => ::oDlg } )

   ::oBtnSave           := TGridImage():Build(  {     "nTop"      => 5,;
                                                      "nLeft"     => {|| GridWidth( 10.5, ::oDlg ) },;
                                                      "nWidth"    => 64,;
                                                      "nHeight"   => 64,;
                                                      "cResName"  => "gc_floppy_disk_64",;
                                                      "bLClicked" => {|| ( ::oSaySignature:SaveToBmp( ::cFile ), ::endView() ) },;
                                                      "bWhen"     => {|| ::oSender:oParent():lNotZoomMode() },;
                                                      "oWnd"      => ::oDlg } )

Return ( self )

//---------------------------------------------------------------------------//

METHOD endView()

   ::super:endView()

   RELEASE PEN ::oPenSig

   ::oPenSig   := nil

Return ( self )

//---------------------------------------------------------------------------//

static function DoDraw( hDc, x, y, lPaint, oPenSig ) 

   if ! lPaint
      MoveTo( hDC, x, y ) 
   else 
      LineTo( hDc, x, y, if( !Empty( oPenSig ), oPenSig:hPen, ) )
   endIf 

return nil

//---------------------------------------------------------------------------//