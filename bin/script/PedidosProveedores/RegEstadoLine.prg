#include "FiveWin.Ch"
#include "Factu.ch"

/*
Hay que crear los campos extra necesarios para este script---------------------
*/

Function RegeneraEstadoLinea( nView )                  
         
   local oRegeneraEstadoLinea    := TRegeneraEstadoLinea():New( nView )

   msgRun( "Recalculando estado de lineas", "Espere por favor...", {|| oRegeneraEstadoLinea:Run() } )

   MsgInfo( "Proceso finalizado" )

Return nil

//---------------------------------------------------------------------------//  

CLASS TRegeneraEstadoLinea

   DATA nView

   DATA nRecAnt

   METHOD New()

   METHOD Run()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView ) CLASS TRegeneraEstadoLinea

   ::nView                    := nView

   ::nRecAnt                  := ( D():PedidosProveedores( ::nView ) )->( Recno() )

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run() CLASS TRegeneraEstadoLinea

   ( D():PedidosProveedores( ::nView ) )->( dbGoTop() )

   while !( D():PedidosProveedores( ::nView ) )->( Eof() )

      SetEstadoLinePedProv( ( D():PedidosProveedores( ::nView ) )->cSerPed + Str( ( D():PedidosProveedores( ::nView ) )->nNumPed ) + ( D():PedidosProveedores( ::nView ) )->cSufPed, ::nView )

      ( D():PedidosProveedores( ::nView ) )->( dbSkip() )

   end while

   ( D():PedidosProveedores( ::nView ) )->( dbGoTo( ::nRecAnt ) )

Return ( .t. )

//---------------------------------------------------------------------------//