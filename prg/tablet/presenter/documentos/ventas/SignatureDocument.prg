#include "FiveWin.Ch"
#include "Factu.ch"

CLASS SignatureDocument FROM DocumentsSales

   DATA oSignatureView

   METHOD New()

   METHOD runNavigator()

   METHOD onPreRunNavigator()    INLINE ( .t. )

   METHOD isEndOk()              INLINE ( ::oDlg:nResult == IDOK )

   METHOD play()

   METHOD oParent()              INLINE ( ::oSender )

END CLASS

//---------------------------------------------------------------------------//

METHOD New( oSender ) CLASS SignatureDocument

   ::oSender            := oSender

   ::oSignatureView     := SignatureDocumentView():New( self )
   ::oSignatureView:setTitleDocumento( "Firma del documento" )

Return( self )

//---------------------------------------------------------------------------//

METHOD runNavigator() CLASS SignatureDocument

   if !empty( ::oSignatureView )
      ::oSignatureView:Resource()
   end if

Return( self )

//---------------------------------------------------------------------------//

METHOD play() CLASS SignatureDocument

   if ::onPreRunNavigator()
      ::runNavigator()
   end if 

return ( self )

//---------------------------------------------------------------------------//