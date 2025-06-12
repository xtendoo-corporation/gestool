#include "hbclass.ch"

#define CRLF                        chr( 13 ) + chr( 10 )

#define __default_warranty_days__   15
#define __debug_mode__              .f.

//---------------------------------------------------------------------------//

Function beforeAppend( cCodArt )

   local nPalets        := Space(4)
   local nPiezas        := Space(4)
   local nTotalMetros   := 0
   local nMetrosPalets  := ArticulosModel():getField( 'M2Palet', 'Codigo', cCodArt )
   local nMetrosPiezas  := ArticulosModel():getField( 'M2Pieza', 'Codigo', cCodArt )

   MsgGet( "Seleccione número de palets", "Palets: ", @nPalets )
   MsgGet( "Seleccione número de piezas", "Piezas: ", @nPiezas )

   nTotalMetros := Val( nPalets ) * nMetrosPalets
   
   if nMetrosPiezas != 0
      nTotalMetros += Val( nPiezas ) / nMetrosPiezas
   end if

Return ( nTotalMetros )

//-----------------------------------------------------------------------------//