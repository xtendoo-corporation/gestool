#include "FiveWin.Ch" 
#include "Struct.ch"
#include "Factu.ch" 
#include "Ini.ch"
#include "MesDbf.ch" 

//---------------------------------------------------------------------------//

CLASS TSFTP

   DATA UserLogin
   DATA UserPass
   DATA cUrl
   DATA cUploadFolder
   DATA nPort

   METHOD New()                           CONSTRUCTOR

   METHOD End() 

   METHOD setUserLogin( UserLogin )       INLINE ( ::UserLogin  := UserLogin )
   METHOD setUserLogin( UserPass )        INLINE ( ::UserPass  := UserPass 
   METHOD setUserLogin( cUrl )            INLINE ( ::cUrl  := cUrl 
   METHOD setUserLogin( cUploadFolder )   INLINE ( ::cUploadFolder  := cUploadFolder 
   METHOD setUserLogin( nPort )           INLINE ( ::nPort  := nPort 
 


//---------------------------------------------------------------------------//

METHOD New() CLASS TSFTP

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD End() CLASS TSFTP

RETURN ( Self )

//---------------------------------------------------------------------------//