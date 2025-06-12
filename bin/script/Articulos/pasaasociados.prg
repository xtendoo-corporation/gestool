#include "FiveWin.Ch"
#include "Factu.ch"

/*
Hay que crear los campos extra necesarios para este script---------------------
*/

STATIC nVista

Function PasaAsociados( nView )                  

   nVista   := nView
         
   MsgRun( "Pasando artículos asociados", "Espere por favor...", {|| pasar( nView ) } )

Return nil

//---------------------------------------------------------------------------//  

Function pasar( nView )

   ( D():Kit( nView ) )->( dbGoTop() )

   while !( D():Kit( nView ) )->( Eof() )

      ( D():Asociado( nView ) )->( dbAppend() )

      ( D():Asociado( nView ) )->cCodArt  := ( D():Kit( nView ) )->cCodKit
      ( D():Asociado( nView ) )->cRefAsc  := ( D():Kit( nView ) )->cRefKit
      ( D():Asociado( nView ) )->cDesAsc  := ( D():Kit( nView ) )->cDesKit
      ( D():Asociado( nView ) )->nundAsc  := ( D():Kit( nView ) )->nUndKit

      ( D():Asociado( nView ) )->( dbUnlock() )

      ( D():Kit( nView ) )->( dbSkip() )

   end while

   MsgInfo( "Proceso finalizado." )

Return nil

//---------------------------------------------------------------------------//  