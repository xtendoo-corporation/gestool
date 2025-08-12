#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingDatabaseSATClientes FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD getAdjunto()

   METHOD CreateIndicencia()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingDatabaseSATClientes

   ::Create()

   ::Super:New( nView )

   ::setItems( aItmSatCli() )

   ::setWorkArea( D():SATClientes( nView ) )

   ::setIncidenciaWorkArea( D():SatClientesIncidencias( nView ) )

   ::setTypeDocument( "nSatCli" )

   ::setTypeFormat( "SC" )

   ::setFormatoDocumento( cFirstDoc( "SC", D():Documentos( nView ) ) )

   ::setBmpDatabase( "gc_power_drill_sat_user_48" )

   ::setAsunto( "Envio de nuestro S.A.T. número {Serie de S.A.T.}/{Número de S.A.T.}" )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD CreateIndicencia()

   ( ::getIncidenciaWorkArea() )->( dbAppend() )
   ( ::getIncidenciaWorkArea() )->cSerSat    := ( ::getWorkArea() )->cSerSat
   ( ::getIncidenciaWorkArea() )->nNumSat    := ( ::getWorkArea() )->nNumSat
   ( ::getIncidenciaWorkArea() )->cSufSat    := ( ::getWorkArea() )->cSufSat
   ( ::getIncidenciaWorkArea() )->dFecInc    := GetSysDate()
   ( ::getIncidenciaWorkArea() )->mDesInc    := "Parte " + ( ::getWorkArea() )->cSerSat + "/" + AllTrim( Str( ( ::getWorkArea() )->nNumSat ) ) + "/" + ( ::getWorkArea() )->cSufSat + " enviado por correo." +;
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
      Return ( AllTrim( ::cGetAdjunto ) + ";" + AllTrim( mailReportSATCli( ::cFormatoDocumento ) ) )
   end if

Return ( mailReportSATCli( ::cFormatoDocumento ) )

//--------------------------------------------------------------------------//
