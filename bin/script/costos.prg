#include "FiveWin.Ch"

#include "Hbxml.ch"
#include "Hbclass.ch"
#include "Fileio.ch"
#include "Factu.ch" 
      
//---------------------------------------------------------------------------//

Function afterSave( nView, oStock )

   if ( D():FacturasProveedores( nView ) )->lContab
      MsgStop( "El script ya ha sido ejecutado para ésta factura." )
      Return nil
   end if
	      
   oActualizaCostos   := tActualizaCostos():New( nView, oStock )
   oActualizaCostos:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS tActualizaCostos

   DATA nView

   DATA oStock

   DATA cNumeroFactura

   DATA aLinesFacturaProveedor

   METHOD New()

   METHOD Run()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView, oStock ) CLASS tActualizaCostos

   ::nView                    := nView

   ::oStock                   := oStock

   ::cNumeroFactura           := ( D():FacturasProveedores( nView ) )->cSerFac + Str( ( D():FacturasProveedores( nView ) )->nNumFac ) + ( D():FacturasProveedores( nView ) )->cSufFac

   ::aLinesFacturaProveedor   := {}

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run()

   local oError
   local oBlock
   local nRec
   local nOrdAnt
   local nAt
   local hLine
   local nStockAct
   local nImporte
   local nUnidades
   local nCostoMedio

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

   /*
   Capturo de las lineas de facturas de proveedor------------------------------
   */

   nRec        := ( D():FacturasProveedoresLineas( ::nView ) )->( Recno() )
   nOrdAnt     := ( D():FacturasProveedoresLineas( ::nView ) )->( OrdSetFocus( "NNUMFAC" ) )

   if ( D():FacturasProveedoresLineas( ::nView ) )->( dbSeek( ::cNumeroFactura ) )

      while ( D():FacturasProveedoresLineas( ::nView ) )->cSerFac + Str( ( D():FacturasProveedoresLineas( ::nView ) )->nNumFac ) + ( D():FacturasProveedoresLineas( ::nView ) )->cSufFac == ::cNumeroFactura .and.;
            !( D():FacturasProveedoresLineas( ::nView ) )->( Eof() )

            if ( StocksModel():nGlobalStockArticulo( ( D():Articulos( ::nView ) )->Codigo ) - nTotNFacPrv( D():FacturasProveedoresLineas( ::nView ) ) ) < 0
               MsgStop( "El artículo: " + AllTrim( ( D():FacturasProveedoresLineas( ::nView ) )->cRef ) + " tiene stock negativo", "Abortando Script" )
               Return ( .t. )
            end if

            nAt := AScan( ::aLinesFacturaProveedor, { | hLine | hGet( hLine, "codigo" ) == ( D():FacturasProveedoresLineas( ::nView ) )->cRef } )

            if nAt == 0

               aAdd( ::aLinesFacturaProveedor, {   "codigo" => ( D():FacturasProveedoresLineas( ::nView ) )->cRef,;
                                                   "unidades" => nTotNFacPrv( D():FacturasProveedoresLineas( ::nView ) ),;
                                                   "importe" => nTotLFacPrv( D():FacturasProveedoresLineas( ::nView ) ),;
                                                   "costomedio" => ( nTotLFacPrv( D():FacturasProveedoresLineas( ::nView ) ) / nTotNFacPrv( D():FacturasProveedoresLineas( ::nView ) ) ) } )
            else

               hSet( ::aLinesFacturaProveedor[ nAt ], "unidades", ( hGet( ::aLinesFacturaProveedor[ nAt ], "unidades" ) + nTotNFacPrv( D():FacturasProveedoresLineas( ::nView ) ) ) )
               hSet( ::aLinesFacturaProveedor[ nAt ], "importe", ( hGet( ::aLinesFacturaProveedor[ nAt ], "importe" ) + nTotLFacPrv( D():FacturasProveedoresLineas( ::nView ) ) ) )
               hSet( ::aLinesFacturaProveedor[ nAt ], "costomedio", ( hGet( ::aLinesFacturaProveedor[ nAt ], "importe" ) / hGet( ::aLinesFacturaProveedor[ nAt ], "unidades" ) ) )

            end if

         ( D():FacturasProveedoresLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ( D():FacturasProveedoresLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():FacturasProveedoresLineas( ::nView ) )->( dbGoTo( nRec ) )

   /*
   Nos vamos posicionando en el artículo calculamos y actualizamos-------------
   */

   nRec        := ( D():Articulos( ::nView ) )->( Recno() )
   nOrdAnt     := ( D():Articulos( ::nView ) )->( OrdSetFocus( "Codigo" ) )

   for each hLine in ::aLinesFacturaProveedor

      if ( D():Articulos( ::nView ) )->( dbSeek( hGet( hLine, "codigo" ) ) )

         //nStockAct   := ::oStock:nStockArticulo( ( D():Articulos( ::nView ) )->Codigo )
         nStockAct   := StocksModel():nGlobalStockArticulo( ( D():Articulos( ::nView ) )->Codigo )

         nUnidades   := nStockAct

         nStockAct   -= hGet( hLine, "unidades" )

         nImporte    := ( nStockAct * ( D():Articulos( ::nView ) )->pCosto ) + ( hGet( hLine, "unidades" ) * hGet( hLine, "costomedio" ) )

         nCostoMedio := nImporte / nUnidades

         if dbLock( D():Articulos( ::nView ) )
            ( D():Articulos( ::nView ) )->pCosto := nCostoMedio
            ( D():Articulos( ::nView ) )->( dbUnLock() )
         end if

      end if

   next

   ( D():Articulos( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():Articulos( ::nView ) )->( dbGoTo( nRec ) )

   /*
   Marcamos la factura para que no ejecute de nuevo el script------------------
   */

   if dbLock( D():FacturasProveedores( ::nView ) )
      ( D():FacturasProveedores( ::nView ) )->lContab := .t.
      ( D():FacturasProveedores( ::nView ) )->( dbUnLock() )
   end if

   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Error en el script"  )

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( .t. )

//----------------------------------------------------------------------------//