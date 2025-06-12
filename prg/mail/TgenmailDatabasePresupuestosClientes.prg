#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingDatabasePresupuestosClientes FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD getAdjunto()

   METHOD CreateIndicencia()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingDatabasePresupuestosClientes

   ::Create()

   ::Super:New( nView )

   ::setItems( aItmPreCli() )

   ::setWorkArea( D():PresupuestosClientes( nView ) )

   ::setIncidenciaWorkArea( D():PresupuestosClientesIncidencias( nView ) )

   ::setTypeDocument( "nPreCli" )

   ::setTypeFormat( "RC" )

   ::setFormatoDocumento( cFirstDoc( "RC", D():Documentos( nView ) ) )

   ::setBmpDatabase( "gc_notebook_user_48" )

   ::setAsunto( "Envio de nuestro presupuesto número {Serie del presupuesto}/{Número del presupuesto}" )

   ::setBlockRecipients( {|| alltrim( retFld( ( D():PresupuestosClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ), "cMeiInt" ) ) } )

Return ( Self )

//---------------------------------------------------------------------------//


METHOD CreateIndicencia()

   ( ::getIncidenciaWorkArea() )->( dbAppend() )
   ( ::getIncidenciaWorkArea() )->cSerPre    := ( ::getWorkArea() )->cSerPre
   ( ::getIncidenciaWorkArea() )->nNumPre    := ( ::getWorkArea() )->nNumPre
   ( ::getIncidenciaWorkArea() )->cSufPre    := ( ::getWorkArea() )->cSufPre
   ( ::getIncidenciaWorkArea() )->dFecInc    := GetSysDate()
   ( ::getIncidenciaWorkArea() )->mDesInc    := "Presupuesto " + ( ::getWorkArea() )->cSerPre + "/" + AllTrim( Str( ( ::getWorkArea() )->nNumPre ) ) + "/" + ( ::getWorkArea() )->cSufPre + " enviado por correo." + ;
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
      Return ( AllTrim( ::cGetAdjunto ) + ";" + AllTrim( mailReportPreCli( ::cFormatoDocumento ) ) )
   end if

Return ( mailReportPreCli( ::cFormatoDocumento ) )

//--------------------------------------------------------------------------//
