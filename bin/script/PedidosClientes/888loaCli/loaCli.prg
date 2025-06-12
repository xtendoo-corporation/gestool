#include ".\Include\Factu.ch"

//---------------------------------------------------------------------------//

function InicioHRB( aGet, aTmp, nView, dbfTmpLin )

   local lReturn     := .t.
   local cAgente     := ""
   
   cAgente           := SubStr( Auth():Codigo(), 1, 3 )

   if ( ( D():Clientes( nView ) )->cAgente != cAgente )
      MsgStop( "El cliente seleccionado no pertenece al agente seleccionado" )
      aGet[ ( D():PedidosClientes( nView ) )->( fieldpos( "cCodCli" ) ) ]:SetFocus()
      Return .f.
   end if

return lReturn

//---------------------------------------------------------------------------//