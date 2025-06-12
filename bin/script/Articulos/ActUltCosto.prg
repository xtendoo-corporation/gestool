#include "FiveWin.Ch"

#include "Hbxml.ch"
#include "Hbclass.ch"
#include "Fileio.ch"
#include "Factu.ch" 
      
//---------------------------------------------------------------------------//

Function ActUltCosto( nView )                	 
	      
   local oActUltCost    := TActUltCost():New( nView )

   oActUltCost:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TActUltCost

   DATA nView

   METHOD New()

   METHOD Run()

   METHOD procesa()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run()

   msgrun( "Procesando ", "Espere por favor...",  {|| ::procesa() } )

   msginfo( "Proceso finalizado" )

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD procesa()

   local nUltCos  := 0
   local nRec     := ( D():Articulos( ::nView ) )->( Recno() )
   local nRecAlb  := ( D():AlbaranesProveedoresLineas( ::nView ) )->( Recno() )
   local nRecFac  := ( D():FacturasProveedoresLineas( ::nView ) )->( Recno() )
   local nOrdAlb  := ( D():AlbaranesProveedoresLineas( ::nView ) )->( OrdSetFocus( "cRefFec" ) )
   local nOrdFac  := ( D():FacturasProveedoresLineas( ::nView ) )->( OrdSetFocus( "cRefFec" ) )


   ( D():Articulos( ::nView ) )->( dbGoTop() )

   while !( D():Articulos( ::nView ) )->( Eof() )

      if ( D():Articulos( ::nView ) )->pCosto <= 0

         nUltCos  := nCostoUltimaCompra( ( D():Articulos( ::nView ) )->Codigo, D():AlbaranesProveedoresLineas( ::nView ), D():FacturasProveedoresLineas( ::nView ) )

         if nUltCos > 0

            if dbLock( D():Articulos( ::nView ) )
               ( D():Articulos( ::nView ) )->pCosto := nUltCos
               ( D():Articulos( ::nView ) )->( dbUnLock() )
            end if

         end if 

      end if

      ( D():Articulos( ::nView ) )->( dbSkip() )

   end while

   ( D():AlbaranesProveedoresLineas( ::nView ) )->( OrdSetFocus( nOrdAlb ) )
   ( D():FacturasProveedoresLineas( ::nView ) )->( OrdSetFocus( nOrdFac ) )

   ( D():Articulos( ::nView ) )->( dbGoTo( nRec ) )

   ( D():AlbaranesProveedoresLineas( ::nView ) )->( dbGoTo( nRecAlb ) )
   ( D():FacturasProveedoresLineas( ::nView ) )->( dbGoTo( nRecFac ) )

Return nil

//----------------------------------------------------------------------------//