#include "FiveWin.Ch"
#include "Factu.ch" 

CLASS Impuestos FROM Editable

   DATA oGridTipoImpuesto

   METHOD New()

   METHOD Init( oSender )

   METHOD OpenFiles()
   METHOD CloseFiles()                 INLINE ( D():DeleteView( ::nView ) )

   METHOD setEnviroment()              INLINE ( ::setDataTable( "TIva" ) ) 

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS Impuestos

   if ::OpenFiles()
      ::setEnviroment()
   end if   

Return ( self )

//---------------------------------------------------------------------------//

METHOD Init( oSender ) CLASS Impuestos

   ::nView                                   := oSender:nView

   ::oGridTipoImpuesto                       := ImpuestosViewSearchNavigator():New( self )
   ::oGridTipoImpuesto:setSelectorMode()
   ::oGridTipoImpuesto:setTitleDocumento( "Seleccione tipo de impuesto" )
   ::oGridTipoImpuesto:setDblClickBrowseGeneral( {|| ::oGridTipoImpuesto:endView() } )

   ::setEnviroment()

Return ( self )

//---------------------------------------------------------------------------//

METHOD OpenFiles() CLASS Impuestos

   local oError
   local oBlock
   local lOpenFiles     := .t.

   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      ::nView           := D():CreateView()

      D():TiposIva( ::nView )

   RECOVER USING oError

      lOpenFiles        := .f.

      ApoloMsgStop( "Imposible abrir todas las bases de datos" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

   if !lOpenFiles
      ::CloseFiles( "" )
   end if

Return ( lOpenFiles )

//---------------------------------------------------------------------------//