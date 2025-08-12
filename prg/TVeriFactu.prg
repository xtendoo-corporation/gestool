#include "FiveWin.Ch"
#include "Font.ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//*PRUEBAS

//---------------------------------------------------------------------------//

CLASS TVeriFactu

   METHOD Create ()

   METHOD OpenFiles()

   METHOD CloseFiles()

   METHOD lResource( cFld )

   METHOD lGenerate()

END CLASS

//---------------------------------------------------------------------------//

METHOD Create()


RETURN ( self )

//---------------------------------------------------------------------------//

METHOD OpenFiles()

   local lOpen    := .t.

RETURN ( lOpen )

//---------------------------------------------------------------------------//

METHOD CloseFiles()


RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD lResource( cFld )


RETURN .t.

//---------------------------------------------------------------------------//

METHOD lGenerate()

RETURN ( nil )

//---------------------------------------------------------------------------//