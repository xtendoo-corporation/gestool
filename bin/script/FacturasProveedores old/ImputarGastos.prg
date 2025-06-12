#include "FiveWin.Ch"

#include "Hbxml.ch"
#include "Hbclass.ch"
#include "Fileio.ch"
#include "Factu.ch" 
      
//---------------------------------------------------------------------------//

Function ImputarGastos( nView )

   local oImputaGastos
   
   oImputaGastos     := ImputaGastos():New( nView )
   oImputaGastos:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS ImputaGastos

   DATA nView

   DATA cNumeroFactura

   DATA cFamiliaGastos
   DATA cIdExtraFieldCosto
   DATA nPorcentajeGastos
   DATA nTotalNeto

   METHOD New()

   METHOD Run()

   METHOD RecalculaTotales()

   METHOD CalculoPorcentajeGasto()

   METHOD GuardaCostoExtraField()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView, oStock ) CLASS ImputaGastos

   ::nView                    := nView

   ::cFamiliaGastos           := Padr( "001", 16 )
   ::cIdExtraFieldCosto       := "001"

   ::nPorcentajeGastos        := 0

   ::cNumeroFactura           := ( D():FacturasProveedores( nView ) )->cSerFac + Str( ( D():FacturasProveedores( nView ) )->nNumFac ) + ( D():FacturasProveedores( nView ) )->cSufFac
   ::nTotalNeto               := ( D():FacturasProveedores( nView ) )->nTotNet

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run() CLASS ImputaGastos

   local oError
   local oBlock
   local nCosto

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

   ::CalculoPorcentajeGasto()

   if ::nPorcentajeGastos != 0

   ( D():FacturasProveedoresLineas( ::nView ) )->( dbGoTop() )

      if ( D():FacturasProveedoresLineas( ::nView ) )->( dbSeek( ::cNumeroFactura ) )

         while ( D():FacturasProveedoresLineas( ::nView ) )->cSerFac + Str( ( D():FacturasProveedoresLineas( ::nView ) )->nNumFac ) + ( D():FacturasProveedoresLineas( ::nView ) )->cSufFac == ::cNumeroFactura .and.;
               !( D():FacturasProveedoresLineas( ::nView ) )->( Eof() )

               if ( D():FacturasProveedoresLineas( ::nView ) )->cCodFam != ::cFamiliaGastos .and.;
                  ( D():FacturasProveedoresLineas( ::nView ) )->nUniCaja != 0

                  ::GuardaCostoExtraField()

                  /*if dbLock( ( D():FacturasProveedoresLineas( ::nView ) ) )
                     ( ( D():FacturasProveedoresLineas( ::nView ) ) )->nPreUnit := ( ( D():FacturasProveedoresLineas( ::nView ) ) )->nPreUnit + ( 1 + ( ::nPorcentajeGastos / 100 ) )
                     ( ( D():FacturasProveedoresLineas( ::nView ) ) )->( dbUnLock() )
                  end if*/

                  nCosto := ( ( D():FacturasProveedoresLineas( ::nView ) ) )->nPreUnit * ( 1 + ( ::nPorcentajeGastos / 100 ) )

                  ArticulosModel():updateCosto( ( D():FacturasProveedoresLineas( ::nView ) )->cRef, nCosto )

               end if

            ( D():FacturasProveedoresLineas( ::nView ) )->( dbSkip() )

         end while

      end if

   end if

   //::RecalculaTotales()

   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Error en el script"  )

   END SEQUENCE
   ErrorBlock( oBlock )

   MsgInfo( "Proceso finalizado con éxito" )

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD CalculoPorcentajeGasto() CLASS ImputaGastos

   local nTotalGastos   := 0

   ( D():FacturasProveedoresLineas( ::nView ) )->( dbGoTop() )

   if ( D():FacturasProveedoresLineas( ::nView ) )->( dbSeek( ::cNumeroFactura ) )

      while ( D():FacturasProveedoresLineas( ::nView ) )->cSerFac + Str( ( D():FacturasProveedoresLineas( ::nView ) )->nNumFac ) + ( D():FacturasProveedoresLineas( ::nView ) )->cSufFac == ::cNumeroFactura .and.;
            !( D():FacturasProveedoresLineas( ::nView ) )->( Eof() )

            if ( D():FacturasProveedoresLineas( ::nView ) )->cCodFam == ::cFamiliaGastos .and.;
               ( D():FacturasProveedoresLineas( ::nView ) )->nUniCaja == 0

               nTotalGastos   += ( D():FacturasProveedoresLineas( ::nView ) )->nPreUnit

            end if

         ( D():FacturasProveedoresLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ::nPorcentajeGastos  := ( ( nTotalGastos * 100 ) / ::nTotalNeto )

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD GuardaCostoExtraField() CLASS ImputaGastos

   if Empty( getCustomExtraField( ::cIdExtraFieldCosto, "Lineas facturas a proveedores", ::cNumeroFactura + Str( ( D():FacturasProveedoresLineas( ::nView ) )->nNumLin ) ) )

      if dbSeekInOrd( "38" + ::cIdExtraFieldCosto + ::cNumeroFactura + Str( ( D():FacturasProveedoresLineas( ::nView ) )->nNumLin ) , "cTotClave", D():DetCamposExtras( ::nView ) )

         if dbLock( D():DetCamposExtras( ::nView ) )
            ( D():DetCamposExtras( ::nView ) )->cValor     := Str( ( D():FacturasProveedoresLineas( ::nView ) )->nPreUnit )
            ( D():DetCamposExtras( ::nView ) )->( dbUnlock() )
         end if

      else

         ( D():DetCamposExtras( ::nView ) )->( dbAppend() )

         ( D():DetCamposExtras( ::nView ) )->cTipDoc    := "38"
         ( D():DetCamposExtras( ::nView ) )->cCodTipo   := ::cIdExtraFieldCosto
         ( D():DetCamposExtras( ::nView ) )->cClave     := ::cNumeroFactura + Str( ( D():FacturasProveedoresLineas( ::nView ) )->nNumLin )
         ( D():DetCamposExtras( ::nView ) )->cValor     := Str( ( D():FacturasProveedoresLineas( ::nView ) )->nPreUnit )
         ( D():DetCamposExtras( ::nView ) )->uuid       := win_uuidcreatestring()

         ( D():DetCamposExtras( ::nView ) )->( dbUnlock() )

      end if

   end if

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD RecalculaTotales() CLASS ImputaGastos

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