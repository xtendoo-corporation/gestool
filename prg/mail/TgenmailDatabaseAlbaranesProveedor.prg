#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingDatabaseAlbaranesProveedor FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD getAdjunto()

   METHOD CreateIndicencia()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingDatabaseAlbaranesProveedor

   ::Create()

   ::Super:New( nView )

   ::setItems( aItmAlbPrv() )

   ::setWorkArea( D():AlbaranesProveedores( nView ) )

   ::setIncidenciaWorkArea( D():AlbaranesProveedoresIncidencias( nView ) )

   ::setTypeDocument( "nAlbPrv" )

   ::setTypeFormat( "AP" )

   ::setFormatoDocumento( cFirstDoc( "AP", D():Documentos( nView ) ) )

   ::setBmpDatabase( "gc_mail_earth_48" )

   ::setAsunto( "Envio de nuestro albarán {Serie del albarán}/{Número del albarán}" )

   ::setBlockRecipients( {|| alltrim( retFld( ( D():AlbaranesProveedores( nView ) )->cCodPrv, D():Proveedores( nView ), "cMeiInt" ) ) } )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD CreateIndicencia()

   ( ::getIncidenciaWorkArea() )->( dbAppend() )
   ( ::getIncidenciaWorkArea() )->cSerAlb    := ( ::getWorkArea() )->cSerAlb
   ( ::getIncidenciaWorkArea() )->nNumAlb    := ( ::getWorkArea() )->nNumAlb
   ( ::getIncidenciaWorkArea() )->cSufAlb    := ( ::getWorkArea() )->cSufAlb
   ( ::getIncidenciaWorkArea() )->dFecInc    := GetSysDate()
   ( ::getIncidenciaWorkArea() )->mDesInc    := "Albarán " + ( ::getWorkArea() )->cSerAlb + "/" + AllTrim( Str( ( ::getWorkArea() )->nNumAlb ) ) + "/" + ( ::getWorkArea() )->cSufAlb + " enviado por correo." +;
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
      Return ( AllTrim( ::cGetAdjunto ) + ";" + AllTrim( mailReportAlbPrv( ::cFormatoDocumento ) ) )
   end if

Return ( mailReportAlbPrv( ::cFormatoDocumento ) )

//--------------------------------------------------------------------------//
