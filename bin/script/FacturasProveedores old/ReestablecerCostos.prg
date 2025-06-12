#include "FiveWin.Ch"

#include "Hbxml.ch"
#include "Hbclass.ch"
#include "Fileio.ch"
#include "Factu.ch" 
      
//---------------------------------------------------------------------------//

Function ReestablecerGastos( nView )

   local oReestableceGastos
   
   oReestableceGastos     := ReestableceGastos():New( nView )
   oReestableceGastos:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS ReestableceGastos

   DATA nView

   DATA cNumeroFactura

   DATA cFamiliaGastos
   DATA cIdExtraFieldCosto

   METHOD New()

   METHOD Run()

   METHOD RecalculaTotales()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView, oStock ) CLASS ReestableceGastos

   ::nView                    := nView

   ::cFamiliaGastos           := Padr( "001", 16 )
   ::cIdExtraFieldCosto       := "001"

   ::cNumeroFactura           := ( D():FacturasProveedores( nView ) )->cSerFac + Str( ( D():FacturasProveedores( nView ) )->nNumFac ) + ( D():FacturasProveedores( nView ) )->cSufFac

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run() CLASS ReestableceGastos

   local oError
   local oBlock
   local nCostoGuardado       := 0

   oBlock                     := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

   ( D():FacturasProveedoresLineas( ::nView ) )->( dbGoTop() )

   if ( D():FacturasProveedoresLineas( ::nView ) )->( dbSeek( ::cNumeroFactura ) )

      while ( D():FacturasProveedoresLineas( ::nView ) )->cSerFac + Str( ( D():FacturasProveedoresLineas( ::nView ) )->nNumFac ) + ( D():FacturasProveedoresLineas( ::nView ) )->cSufFac == ::cNumeroFactura .and.;
            !( D():FacturasProveedoresLineas( ::nView ) )->( Eof() )

            if ( D():FacturasProveedoresLineas( ::nView ) )->cCodFam != ::cFamiliaGastos .and.;
               ( D():FacturasProveedoresLineas( ::nView ) )->nUniCaja != 0

               nCostoGuardado := getCustomExtraField( ::cIdExtraFieldCosto, "Lineas facturas a proveedores", ::cNumeroFactura + Str( ( D():FacturasProveedoresLineas( ::nView ) )->nNumLin ) )

               if !Empty( nCostoGuardado ) .and. ( nCostoGuardado != ( D():FacturasProveedoresLineas( ::nView ) )->nPreUnit )

                  if dbLock( ( D():FacturasProveedoresLineas( ::nView ) ) )
                     ( ( D():FacturasProveedoresLineas( ::nView ) ) )->nPreUnit := nCostoGuardado
                     ( ( D():FacturasProveedoresLineas( ::nView ) ) )->( dbUnLock() )
                  end if

               end if

            end if

         ( D():FacturasProveedoresLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ::RecalculaTotales()

   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Error en el script"  )

   END SEQUENCE
   ErrorBlock( oBlock )

   MsgInfo( "Proceso finalizado con éxito" )

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD RecalculaTotales() CLASS ReestableceGastos

   local aTotal


   aTotal   := aTotFacPrv( ::cNumeroFactura,;
                           D():FacturasProveedores( ::nView ),;
                           D():FacturasProveedoresLineas( ::nView ),;
                           D():TiposIva( ::nView ),;
                           D():Divisas( ::nView ),;
                           D():FacturasProveedoresPagos( ::nView ) )


   if dbLock( ( D():FacturasProveedores( ::nView ) ) )
      ( ( D():FacturasProveedores( ::nView ) ) )->nTotNet := aTotal[1]
      ( ( D():FacturasProveedores( ::nView ) ) )->nTotIva := aTotal[2]
      ( ( D():FacturasProveedores( ::nView ) ) )->nTotReq := aTotal[3]
      ( ( D():FacturasProveedores( ::nView ) ) )->nTotFac := aTotal[4]
      ( ( D():FacturasProveedores( ::nView ) ) )->( dbUnLock() )
   end if

Return ( .t. )

//----------------------------------------------------------------------------//