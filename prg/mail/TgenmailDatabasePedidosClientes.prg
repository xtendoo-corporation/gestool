#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingDatabasePedidosClientes FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD getAdjunto()

   METHOD CreateIndicencia()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingDatabasePedidosClientes

   ::Create()

   ::Super:New( nView )

   ::setItems( aItmPedCli() )

   ::setWorkArea( D():PedidosClientes( nView ) )

   ::setIncidenciaWorkArea( D():PedidosClientesIncidencias( nView ) )

   ::setTypeDocument( "nPedCli" )

   ::setTypeFormat( "PC" )

   ::setFormatoDocumento( cFirstDoc( "PC", D():Documentos( nView ) ) )

   ::setBmpDatabase( "gc_clipboard_empty_user_48" )

   ::setAsunto( "Envio de nuestro pedido número {Serie del pedido}/{Número del pedido}" )

   ::setBlockRecipients( {|| alltrim( retFld( ( D():PedidosClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ), "cMeiInt" ) ) } )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD CreateIndicencia()

   ( ::getIncidenciaWorkArea() )->( dbAppend() )
   ( ::getIncidenciaWorkArea() )->cSerPed    := ( ::getWorkArea() )->cSerPed
   ( ::getIncidenciaWorkArea() )->nNumPed    := ( ::getWorkArea() )->nNumPed
   ( ::getIncidenciaWorkArea() )->cSufPed    := ( ::getWorkArea() )->cSufPed
   ( ::getIncidenciaWorkArea() )->dFecInc    := GetSysDate()
   ( ::getIncidenciaWorkArea() )->mDesInc    := "Pedido " + ( ::getWorkArea() )->cSerPed + "/" + AllTrim( Str( ( ::getWorkArea() )->nNumPed ) ) + "/" + ( ::getWorkArea() )->cSufPed + " enviado por correo." +;
                                                CRLF + "Destinatario: " + AllTrim( ::cRecipients ) + ;
                                                CRLF + "Usuario: " + AllTrim( Auth():Codigo() ) + " - " + AllTrim( UsuariosModel():getNombre( Auth():Codigo() ) ) + ;
                                                CRLF + "Fecha: " + AllTrim( dToc( GetSysDate() ) ) + ;
                                                CRLF + "Hora: " + AllTrim( GetSysTime() ) + ;
                                                CRLF + "Adjuntos: " + AllTrim( ::cGetAdjunto )
   ( ::getIncidenciaWorkArea() )->lListo     := .t.
   ( ::getIncidenciaWorkArea() )->lAviso     := .f.
   ( ::getIncidenciaWorkArea() )->( dbUnlock() )

Return ( Self )

//--------------------------------------------------------------------------//

METHOD getAdjunto()

   if !Empty( ::cGetAdjunto )
      Return ( AllTrim( ::cGetAdjunto ) + ";" + AllTrim( mailReportPedCli( ::cFormatoDocumento ) ) )
   end if

Return ( mailReportPedCli( ::cFormatoDocumento ) )

//--------------------------------------------------------------------------//
