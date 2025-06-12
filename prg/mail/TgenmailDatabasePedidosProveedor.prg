#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingDatabasePedidosProveedor FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD getAdjunto()

   METHOD CreateIndicencia()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingDatabasePedidosProveedor

   ::Create()

   ::Super:New( nView )

   ::setItems( aItmPedPrv() )

   ::setWorkArea( D():PedidosProveedores( nView ) )

   ::setIncidenciaWorkArea( D():PedidosProveedoresIncidencias( nView ) )

   ::setTypeDocument( "nPedPrv" )

   ::setTypeFormat( "PP" )

   ::setFormatoDocumento( cFirstDoc( "PP", D():Documentos( nView ) ) )

   ::setBmpDatabase( "gc_businessman_48" )

   ::setAsunto( "Envio de nuestro pedido número {Serie del pedido}/{Número del pedido}" )

   ::setBlockRecipients( {|| alltrim( retFld( ( D():PedidosProveedores( nView ) )->cCodPrv, D():Proveedores( nView ), "cMeiInt" ) ) } )

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
                                                CRLF + "Adjuntos: " + AllTrim( if( ( hb_ischar( ::cGetAdjunto ) .and. !Empty( ::cGetAdjunto ) ), ::cGetAdjunto, "" ) )
   ( ::getIncidenciaWorkArea() )->lListo     := .t.
   ( ::getIncidenciaWorkArea() )->lAviso     := .f.
   ( ::getIncidenciaWorkArea() )->( dbUnlock() )

Return ( Self )

//--------------------------------------------------------------------------//

METHOD getAdjunto()

   if !Empty( ::cGetAdjunto )
      Return ( AllTrim( ::cGetAdjunto ) + ";" + AllTrim( mailReportPedPrv( ::cFormatoDocumento ) ) )
   end if

Return ( mailReportPedPrv( ::cFormatoDocumento ) )

//--------------------------------------------------------------------------//