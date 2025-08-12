#include "FiveWin.Ch"
#include "Factu.ch" 

CLASS InvoiceCustomerViewSearchNavigator FROM DocumentSalesViewSearchNavigator

   METHOD BotonesAcciones()

END CLASS

//---------------------------------------------------------------------------//

METHOD BotonesAcciones() CLASS InvoiceCustomerViewSearchNavigator

   MsgInfo("Paso por BotonesAcciones")

   TGridImage():Build(  {  "nTop"      => 75,;
                           "nLeft"     => {|| GridWidth( 0.5, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_plus_64",;
                           "bLClicked" => {|| if( ::oSender:Append(), ::refreshBrowse(), ) },;
                           "oWnd"      => ::oDlg } )

   if ::oSender:lAlowEdit

   TGridImage():Build(  {  "nTop"      => 75,;
                           "nLeft"     => {|| GridWidth( 2, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_pencil_64",;
                           "bLClicked" => {|| if( ::oSender:Edit(), ::refreshBrowse(), ) },;
                           "oWnd"      => ::oDlg } )

   TGridImage():Build(  {  "nTop"      => 75,;
                           "nLeft"     => {|| GridWidth( 3.5, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_delete_64",;
                           "bLClicked" => {|| if( ::oSender:Delete(), ::refreshBrowse(), ) },;
                           "oWnd"      => ::oDlg } )

   TGridImage():Build(  {  "nTop"      => 75,;
                           "nLeft"     => {|| GridWidth( 5, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_documents_exchange_64",;
                           "bLClicked" => {|| MsgInfo("Atipicas") },;
                           "oWnd"      => ::oDlg } )

   else

   TGridImage():Build(  {  "nTop"      => 75,;
                           "nLeft"     => {|| GridWidth( 2, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_binocular_64",;
                           "bLClicked" => {|| if( ::oSender:Zoom(), ::refreshBrowse(), ) },;
                           "oWnd"      => ::oDlg } )

   TGridImage():Build(  {  "nTop"      => 75,;
                           "nLeft"     => {|| GridWidth( 3.5, ::oDlg ) },;
                           "nWidth"    => 64,;
                           "nHeight"   => 64,;
                           "cResName"  => "gc_documents_exchange_64",;
                           "bLClicked" => {|| MsgInfo("Atipicas") },;
                           "oWnd"      => ::oDlg } )

   end if 

Return ( self )

//---------------------------------------------------------------------------//