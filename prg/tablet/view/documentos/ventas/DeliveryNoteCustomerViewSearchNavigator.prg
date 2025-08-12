#include "FiveWin.Ch"
#include "Factu.ch" 

CLASS DeliveryNoteCustomerViewSearchNavigator FROM DocumentSalesViewSearchNavigator

   METHOD BotonesAcciones()

   METHOD setColumns()
   
END CLASS

//---------------------------------------------------------------------------//

METHOD BotonesAcciones() CLASS DeliveryNoteCustomerViewSearchNavigator

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
                           "bLClicked" => {|| ::oSender:genInvoiceCustomer() },;
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
                           "bLClicked" => {|| ::oSender:genInvoiceCustomer() },;
                           "oWnd"      => ::oDlg } )

   end if 

Return ( self )

//---------------------------------------------------------------------------//

METHOD setColumns() CLASS DeliveryNoteCustomerViewSearchNavigator

   ::setBrowseConfigurationName( "grid_ventas" )

   with object ( ::addColumn() )
         :cHeader          := "Facturado"
         :nHeadBmpNo       := 4
         :bStrData         := {|| "" }
         :bBmpData         := {|| ::getField( "Estado" ) }
         :nWidth           := 20
         :AddResource( "gc_delete_12" )
         :AddResource( "gc_shape_square_12" )
         :AddResource( "gc_check_12" )
         :AddResource( "gc_trafficlight_on_16" )
   end with

   with object ( ::addColumn() )
      :cHeader          := "Envio"
      :nHeadBmpNo       := 3
      :bStrData         := {|| "" }
      :bEditValue       := {|| ::getField( "Envio" ) }
      :nWidth           := 33
      :lHide            := .t.
      :SetCheck( { "gc_mail2_24", "Nil16" } )
      :AddResource( "gc_mail2_24" )
   end with

   with object ( ::addColumn() )
      :cHeader           := "Id"
      :bEditValue        := {|| ::getField( "Serie" ) + "/" + alltrim( str( ::getField( "Numero" ) ) ) + CRLF + dtoc( ::getField( "Fecha" ) ) }
      :nWidth            := 165
   end with

   with object ( ::addColumn() )
      :cHeader           := "Cliente"
      :bEditValue        := {|| alltrim( ::getField( "Cliente" ) ) + CRLF + alltrim( ::getField( "NombreCliente" ) ) }
      :nWidth            := 310
   end with

   with object ( ::addColumn() )
      :cHeader           := "Agente"
      :bEditValue        := {|| ::getField( "Agente" ) }
      :nWidth            := 100
      :lHide             := .t.
   end with

   with object ( ::addColumn() )
      :cHeader           := "Base"
      :bEditValue        := {|| ::getField( "TotalNeto" ) }
      :cEditPicture      := cPorDiv()
      :nWidth            := 100
      :nDataStrAlign     := 1
      :nHeadStrAlign     := 1
      :lHide             := .t.
   end with

   with object ( ::addColumn() )
      :cHeader           := cImp()
      :bEditValue        := {|| ::getField( "TotalImpuesto" ) }
      :cEditPicture      := cPorDiv()
      :nWidth            := 100
      :nDataStrAlign     := 1
      :nHeadStrAlign     := 1
      :lHide             := .t.
   end with

   with object ( ::addColumn() )
      :cHeader           := "R.E."
      :bEditValue        := {|| ::getField( "TotalRecargo" ) }
      :cEditPicture      := cPorDiv()
      :nWidth            := 100
      :nDataStrAlign     := 1
      :nHeadStrAlign     := 1
      :lHide             := .t.
   end with

   with object ( ::addColumn() )
      :cHeader           := "Total"
      :bEditValue        := {|| ::getField( "TotalDocumento" ) }
      :cEditPicture      := cPorDiv()
      :nWidth            := 155
      :nDataStrAlign     := 1
      :nHeadStrAlign     := 1
   end with

Return ( self )

//---------------------------------------------------------------------------//