#include "hbclass.ch"

#define CRLF chr( 13 ) + chr( 10 )

//---------------------------------------------------------------------------//

Function Inicio()

   local oImportador

   oImportador    := Importador():New()

   oImportador:Run()

Return ( nil )

//---------------------------------------------------------------------------//

CLASS Importador

   DATA nView

   DATA hParentBuffer

   DATA hLineBuffer

   METHOD New()

   METHOD Run()

   METHOD AddRegistroCabecera()

   METHOD AddRegistroLinea()

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS Importador

   ::nView              := D():CreateView()

Return ( Self )

//---------------------------------------------------------------------------//

METHOD Run() CLASS Importador

   ( D():AlbaranesClientes( ::nView ) )->( dbGoTop() )

   while !( D():AlbaranesClientes( ::nView ) )->( Eof() )

      MsgWait( "Documento: " + ( D():AlbaranesClientes( ::nView ) )->cSerAlb + Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb ) + ( D():AlbaranesClientes( ::nView ) )->cSufAlb, "Importando", 0.05 )

      ::AddRegistroCabecera()

      if ( D():AlbaranesClientesLineas( ::nView ) )->( dbSeek( ( D():AlbaranesClientes( ::nView ) )->cSerAlb + Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb ) + ( D():AlbaranesClientes( ::nView ) )->cSufAlb ) )

         while ( D():AlbaranesClientes( ::nView ) )->cSerAlb + Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb ) + ( D():AlbaranesClientes( ::nView ) )->cSufAlb == ( D():AlbaranesClientesLineas( ::nView ) )->cSerAlb + Str( ( D():AlbaranesClientesLineas( ::nView ) )->nNumAlb ) + ( D():AlbaranesClientesLineas( ::nView ) )->cSufAlb .and.;
            !( D():AlbaranesClientesLineas( ::nView ) )->( Eof() )
               
               MsgWait( "Articulo: " + ( D():AlbaranesClientesLineas( ::nView ) )->cRef, "Artículos", 0.05 )

               ::AddRegistroLinea()
            
            ( D():AlbaranesClientesLineas( ::nView ) )->( dbSkip() )

         end while

      end if

      ( D():AlbaranesClientes( ::nView ) )->( dbSkip() )

   end while

   /*
   Matamos la vista------------------------------------------------------------
   */

   D():DeleteView( ::nView )

   MsgStop( "Proceso realizado con éxito" )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD AddRegistroCabecera() CLASS Importador

   ::hParentBuffer        := SQLMovimientosAlmacenModel():loadBlankBuffer()

   hSet( ::hParentBuffer, "numero", Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb ) )
   hSet( ::hParentBuffer, "fecha_hora", dateTimeToTimeStamp( ( D():AlbaranesClientes( ::nView ) )->dFecAlb, ( D():AlbaranesClientes( ::nView ) )->tFecAlb ) )
   hSet( ::hParentBuffer, "tipo_movimiento", 1 )
   hSet( ::hParentBuffer, "almacen_origen", "000" )
   hSet( ::hParentBuffer, "almacen_destino", right( AllTrim( ( D():AlbaranesClientes( ::nView ) )->cCodCli ), 3 ) )
   hSet( ::hParentBuffer, "comentarios", "Importado desde albarán: " + ( D():AlbaranesClientes( ::nView ) )->cSerAlb + "/" + AllTrim( Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb ) ) + "/" + ( D():AlbaranesClientes( ::nView ) )->cSufAlb )

   SQLMovimientosAlmacenModel():insertBuffer( ::hParentBuffer )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD AddRegistroLinea() CLASS Importador

   ::hLineBuffer           := SQLMovimientosAlmacenLineasModel():loadBlankBuffer()

   hSet( ::hLineBuffer, "parent_uuid", hGet( ::hParentBuffer, "uuid" ) )

   hSet( ::hLineBuffer, "codigo_articulo", ( D():AlbaranesClientesLineas( ::nView ) )->cRef )
   hSet( ::hLineBuffer, "nombre_articulo", ( D():AlbaranesClientesLineas( ::nView ) )->cDetalle )
   hSet( ::hLineBuffer, "cajas_articulo", ( D():AlbaranesClientesLineas( ::nView ) )->nCanEnt )
   hSet( ::hLineBuffer, "unidades_articulo", ( D():AlbaranesClientesLineas( ::nView ) )->nUniCaja )
   hSet( ::hLineBuffer, "precio_articulo", ( D():AlbaranesClientesLineas( ::nView ) )->nCosDiv )
   hSet( ::hLineBuffer, "precio_venta", ( D():AlbaranesClientesLineas( ::nView ) )->nPreUnit )
   hSet( ::hLineBuffer, "tipo_iva", ( D():AlbaranesClientesLineas( ::nView ) )->nIva )

   SQLMovimientosAlmacenLineasModel():insertBuffer( ::hLineBuffer )

Return ( Self )

//---------------------------------------------------------------------------//