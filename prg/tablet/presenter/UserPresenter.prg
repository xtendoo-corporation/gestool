#include "FiveWin.Ch"
#include "Factu.ch"

CLASS UserPresenter FROM DocumentsSales

   DATA oUserView

   DATA cSelectUser

   METHOD New()

   METHOD runNavigator()

   METHOD onPreRunNavigator()    INLINE ( .t. )

   METHOD play()

   METHOD run()

END CLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS UserPresenter

   ::oUserView    := UserView():New( self )
   ::oUserView:setTitleDocumento( "Seleccione usuario" )

   ::cSelectUser  := ""

Return( self )

//---------------------------------------------------------------------------//

METHOD runNavigator() CLASS UserPresenter 

   if !empty( ::oUserView )
      ::oUserView:Resource()
   end if

Return( self )

//---------------------------------------------------------------------------//

METHOD play() CLASS UserPresenter

   if ::onPreRunNavigator()
      ::runNavigator()
   end if 

return ( self )

//---------------------------------------------------------------------------//

METHOD run() CLASS UserPresenter
 
   ::cSelectUser  := ::oUserView:cCbxUsuario

Return ( self )

//---------------------------------------------------------------------------//