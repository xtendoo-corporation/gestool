#include "FiveWin.Ch"
#include "Factu.ch" 
#include "Xbrowse.ch"

CLASS InvoiceDocumentSalesViewEdit FROM DocumentSalesViewEdit  

   METHOD defineAceptarCancelar()

   METHOD defineBotonesAcciones()

END CLASS

//---------------------------------------------------------------------------//

METHOD defineAceptarCancelar() CLASS InvoiceDocumentSalesViewEdit

   if ::getMode() == EDIT_MODE

      TGridImage():Build(  {  "nTop"      => 5,;
                              "nLeft"     => {|| GridWidth( 7.5, ::oDlg ) },;
                              "nWidth"    => 64,;
                              "nHeight"   => 64,;
                              "cResName"  => "gc_briefcase2_user_64",;
                              "bLClicked" => {|| ReceiptInvoiceCustomer():New( ::oSender ):play() },;
                              "oWnd"      => ::oDlg } )

   end if

   ::buttonCancel    :=    TGridImage():Build(  {  "nTop"      => 5,;
                                                   "nLeft"     => {|| GridWidth( 9.0, ::oDlg ) },;
                                                   "nWidth"    => 64,;
                                                   "nHeight"   => 64,;
                                                   "cResName"  => "gc_error_64",;
                                                   "bLClicked" => {|| ::cancelView() },;
                                                   "oWnd"      => ::oDlg } )

   ::buttonOk        :=    TGridImage():Build(  {  "nTop"      => 5,;
                                                   "nLeft"     => {|| GridWidth( 10.5, ::oDlg ) },;
                                                   "nWidth"    => 64,;
                                                   "nHeight"   => 64,;
                                                   "cResName"  => "gc_ok_64",;
                                                   "bLClicked" => {|| ::oSender:onViewSave() },;
                                                   "oWnd"      => ::oDlg } )

Return ( self )

//---------------------------------------------------------------------------//

METHOD defineBotonesAcciones() CLASS InvoiceDocumentSalesViewEdit

   TGridImage():Build(  {  "nTop"      => 145,;
                           "nLeft"     => {|| GridWidth( 0.5, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_plus_64",;
                           "bLClicked" => {|| ::oSender:appendDetail(), ::RefreshBrowse() },;
                           "bWhen"     => {|| ::oSender:appendButtonMode() },;                           
                           "oWnd"      => ::oDlg } )

   TGridImage():Build(  {  "nTop"      => 145,;
                           "nLeft"     => {|| GridWidth( 2, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_pencil_64",;
                           "bWhen"     => {|| ::oSender:editButtonMode() },;                           
                           "bLClicked" => {|| ::oSender:EditDetail( ::oBrowse:nArrayAt ), ::RefreshBrowse() },;
                           "oWnd"      => ::oDlg } )

   TGridImage():Build(  {  "nTop"      => 145,;
                           "nLeft"     => {|| GridWidth( 3.5, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_delete_64",;
                           "bWhen"     => {|| ::oSender:deleteButtonMode() },;                           
                           "bLClicked" => {|| ::oSender:DeleteDetail( ::oBrowse:nArrayAt ), ::RefreshBrowse()},;
                           "oWnd"      => ::oDlg } )

   TGridImage():Build(  {  "nTop"      => 145,;
                           "nLeft"     => {|| GridWidth( 5, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_symbol_percent_64",;
                           "bWhen"     => {|| ::oSender:lAppendMode() },;
                           "bLClicked" => {|| ::oSender:ImportAtipicas(), ::RefreshBrowse()},;
                           "oWnd"      => ::oDlg } )

Return ( self )

//---------------------------------------------------------------------------//