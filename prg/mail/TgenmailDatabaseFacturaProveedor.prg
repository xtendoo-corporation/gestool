#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingDatabaseFacturaProveedor FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD getAdjunto()

   METHOD CreateIndicencia()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingDatabaseFacturaProveedor

   ::Create()

   ::Super:New( nView )

   ::setItems( aItmFacPrv() )

   ::setWorkArea( D():FacturasProveedores( nView ) )

   ::setIncidenciaWorkArea( D():FacturasProveedoresIncidencias( nView ) )

   ::setTypeDocument( "nFacPrv" )

   ::setTypeFormat( "FP" )

   ::setFormatoDocumento( cFirstDoc( "FP", D():Documentos( nView ) ) )

   ::setBmpDatabase( "gc_businessman_48" )

   ::setAsunto( "Envio de nuestra factura {Serie de factura}/{Número de factura}" )

   ::setBlockRecipients( {|| alltrim( retFld( ( D():FacturasProveedores( nView ) )->cCodPrv, D():Proveedores( nView ), "cMeiInt" ) ) } )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD CreateIndicencia()

   ( ::getIncidenciaWorkArea() )->( dbAppend() )
   ( ::getIncidenciaWorkArea() )->cSerie     := ( ::getWorkArea() )->cSerFac
   ( ::getIncidenciaWorkArea() )->nNumFac    := ( ::getWorkArea() )->nNumFac
   ( ::getIncidenciaWorkArea() )->cSufFac    := ( ::getWorkArea() )->cSufFac
   ( ::getIncidenciaWorkArea() )->dFecInc    := GetSysDate()
   ( ::getIncidenciaWorkArea() )->mDesInc    := "Factura " + ( ::getWorkArea() )->cSerFac + "/" + AllTrim( Str( ( ::getWorkArea() )->nNumFac ) ) + "/" + ( ::getWorkArea() )->cSufFac + " enviada por correo." + ;
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
      Return ( AllTrim( ::cGetAdjunto ) + ";" + AllTrim( mailReportFacPrv( ::cFormatoDocumento ) ) )
   end if

Return ( mailReportFacPrv( ::cFormatoDocumento ) )

//--------------------------------------------------------------------------//
