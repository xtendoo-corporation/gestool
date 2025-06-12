#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TGenMailingClientes FROM TGenMailingDatabase 

   METHOD New( nView )

   METHOD getPara()        INLINE ( ( ::getWorkArea() )->cMeiInt )

   METHOD CreateIndicencia()
   
END CLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS TGenMailingClientes

   ::Create()

   ::setItems( aItmCli() )

   ::setWorkArea( D():Clientes( nView ) )

   ::setIncidenciaWorkArea( D():ClientesIncidencias( nView ) )

   ::setBlockRecipients( {|| ( D():Clientes( nView ) )->cMeiInt } )

   ::oSendMail       := TSendMail():New( Self )

   ::oTemplateHtml   := TTemplatesHtml():New( Self )

   ::oFilter         := TFilterCreator():Init( Self )   
   ::oFilter:SetFields( aItmCli() )

   ::cBmpDatabase    := "gc_businessman_48"

Return ( Self )

//---------------------------------------------------------------------------//

METHOD CreateIndicencia() CLASS TGenMailingClientes

   ( ::getIncidenciaWorkArea() )->( dbAppend() )
   ( ::getIncidenciaWorkArea() )->cCodCli    := ( ::getWorkArea() )->Cod
   ( ::getIncidenciaWorkArea() )->dFecInc    := GetSysDate()
   ( ::getIncidenciaWorkArea() )->tTimInc    := getSysTime()
   ( ::getIncidenciaWorkArea() )->mDesInc    := "Correo mandado a " + ( ::getWorkArea() )->Cod + " - " +  AllTrim( ( ::getWorkArea() )->Titulo )
   ( ::getIncidenciaWorkArea() )->lListo     := .t.
   ( ::getIncidenciaWorkArea() )->lAviso     := .f.
   ( ::getIncidenciaWorkArea() )->( dbUnlock() )

Return ( Self )

//--------------------------------------------------------------------------//