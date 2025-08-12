#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingDatabaseAlbaranesClientes FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD columnPageDatabase( oDlg )   VIRTUAL

   METHOD getAdjunto()

   METHOD CreateIndicencia()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingDatabaseAlbaranesClientes

   ::Create()

   ::Super:New( nView )

   ::setItems( aItmAlbCli() )

   ::setWorkArea( D():AlbaranesClientes( nView ) )

   ::setIncidenciaWorkArea( D():AlbaranesClientesIncidencias( nView ) )

   ::setTypeDocument( "nAlbCli" )

   ::setTypeFormat( "AC" )

   ::setFormatoDocumento( cFirstDoc( "AC", D():Documentos( nView ) ) )

   ::setBmpDatabase( "gc_document_empty_user_48" )

   ::setAsunto( "Envio de nuestro albarán de cliente {Serie del albarán}/{Número del albarán}" )

   ::setBlockRecipients( {|| alltrim( retFld( ( D():AlbaranesClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ), "cMeiInt" ) ) } )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD CreateIndicencia()

   ( ::getIncidenciaWorkArea() )->( dbAppend() )
   ( ::getIncidenciaWorkArea() )->cSerAlb    := ( ::getWorkArea() )->cSerAlb
   ( ::getIncidenciaWorkArea() )->nNumAlb    := ( ::getWorkArea() )->nNumAlb
   ( ::getIncidenciaWorkArea() )->cSufAlb    := ( ::getWorkArea() )->cSufAlb
   ( ::getIncidenciaWorkArea() )->dFecInc    := GetSysDate()
   ( ::getIncidenciaWorkArea() )->mDesInc    := "Albarán " + ( ::getWorkArea() )->cSerAlb + "/" +  AllTrim( Str( ( ::getWorkArea() )->nNumAlb ) ) + "/" + ( ::getWorkArea() )->cSufAlb + " enviado por correo." +;
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
      Return ( AllTrim( ::cGetAdjunto ) + ";" + AllTrim( mailReportAlbCli( ::cFormatoDocumento ) ) )
   end if

Return ( mailReportAlbCli( ::cFormatoDocumento ) )

//--------------------------------------------------------------------------//