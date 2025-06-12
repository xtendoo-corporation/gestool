#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingDatabaseFacturaRectificativaCliente FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD getAdjunto()

   METHOD CreateIndicencia()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingDatabaseFacturaRectificativaCliente

   ::Create()

   ::Super:New( nView )

   ::setItems( aItmFacRec() )

   ::setWorkArea( D():FacturasRectificativas( nView ) )

   ::setIncidenciaWorkArea( D():FacturasRectificativasIncidencias( nView ) )

   ::setTypeDocument( "nFacRec" )

   ::setTypeFormat( "FR" )

   ::setFormatoDocumento( cFirstDoc( "FR", D():Documentos( nView ) ) )

   ::setBmpDatabase( "gc_document_text_user2_48" )

   ::setAsunto( "Envio de nuestra factura {Serie de la factura}/{Número de la factura}" )

   ::setBlockRecipients( {|| alltrim( retFld( ( D():FacturasRectificativas( nView ) )->cCodCli, D():Clientes( nView ), "cMeiInt" ) ) } )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD CreateIndicencia()

   ( ::getIncidenciaWorkArea() )->( dbAppend() )
   ( ::getIncidenciaWorkArea() )->cSerie     := ( ::getWorkArea() )->cSerie
   ( ::getIncidenciaWorkArea() )->nNumFac    := ( ::getWorkArea() )->nNumFac
   ( ::getIncidenciaWorkArea() )->cSufFac    := ( ::getWorkArea() )->cSufFac
   ( ::getIncidenciaWorkArea() )->dFecInc    := GetSysDate()
   ( ::getIncidenciaWorkArea() )->mDesInc    := "Rectificativa " + ( ::getWorkArea() )->cSerie + "/" + AllTrim( Str( ( ::getWorkArea() )->nNumFac ) ) + "/" + ( ::getWorkArea() )->cSufFac + " enviada por correo." +;
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
      Return ( AllTrim( ::cGetAdjunto ) + ";" + AllTrim( mailReportFacRec( ::cFormatoDocumento ) ) )
   end if

Return ( mailReportFacRec( ::cFormatoDocumento ) )

//--------------------------------------------------------------------------//
