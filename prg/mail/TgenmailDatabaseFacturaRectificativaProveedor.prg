#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingDatabaseFacturaRectificativaProveedor FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD getAdjunto()

   METHOD CreateIndicencia()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingDatabaseFacturaRectificativaProveedor

   ::Create()

   ::Super:New( nView )

   ::setItems( aItmRctPrv() )

   ::setWorkArea( D():FacturasRectificativasProveedores( nView ) )

   ::setIncidenciaWorkArea( D():FacturasRectificativasProveedoresIncidencias( nView ) )

   ::setTypeDocument( "nFacRec" )

   ::setTypeFormat( "TP" )

   ::setFormatoDocumento( cFirstDoc( "TP", D():Documentos( nView ) ) )

   ::setBmpDatabase( "gc_document_text_user2_48" )

   ::setAsunto( "Envio de nuestra factura {Serie de factura}/{Número de factura}" )

   ::setBlockRecipients( {|| alltrim( retFld( ( D():FacturasRectificativasProveedores( nView ) )->cCodPrv, D():Proveedores( nView ), "cMeiInt" ) ) } )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD CreateIndicencia()

   ( ::getIncidenciaWorkArea() )->( dbAppend() )
   ( ::getIncidenciaWorkArea() )->cSerFac    := ( ::getWorkArea() )->cSerFac
   ( ::getIncidenciaWorkArea() )->nNumFac    := ( ::getWorkArea() )->nNumFac
   ( ::getIncidenciaWorkArea() )->cSufFac    := ( ::getWorkArea() )->cSufFac
   ( ::getIncidenciaWorkArea() )->dFecInc    := GetSysDate()
   ( ::getIncidenciaWorkArea() )->mDesInc    := "Rectificativa " + ( ::getWorkArea() )->cSerFac + "/" + AllTrim( Str( ( ::getWorkArea() )->nNumFac ) ) + "/" + ( ::getWorkArea() )->cSufFac + " enviada por correo." +;
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
      Return ( AllTrim( ::cGetAdjunto ) + ";" + AllTrim( mailReportRctPrv( ::cFormatoDocumento ) ) )
   end if

Return ( mailReportRctPrv( ::cFormatoDocumento ) )

//--------------------------------------------------------------------------//
