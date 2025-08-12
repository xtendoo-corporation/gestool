#include "FiveWin.Ch"
#include "Factu.ch" 
#include "MesDbf.ch"
#include "Xbrowse.ch"

//----------------------------------------------------------------------------//

CLASS GenPedProv

   Method Activate( cNumDoc )

END CLASS

//----------------------------------------------------------------------------//

METHOD Activate()

   local oDlg

      oDlg              := TDialog():New( , , , , , "BiTrazaDocumentos" )

      oDlg:Activate( , , , .t., , , {|| ::TrazaDocumento( cTypeDoc, cNumDoc ) } )

      ::CloseFiles()

   end if

RETURN ( Self )

//----------------------------------------------------------------------------//