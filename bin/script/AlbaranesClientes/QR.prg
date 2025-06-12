#include "hbclass.ch"

#define CRLF chr( 13 ) + chr( 10 )

//---------------------------------------------------------------------------//

Function Inicio( nView )

   local oAlbarenesClientesQR

   oAlbarenesClientesQR    := AlbarenesClientesQR():New( nView )

   oAlbarenesClientesQR:Run()

Return ( nil )

//---------------------------------------------------------------------------//

CLASS AlbarenesClientesQR

   DATA nView

   DATA cNumAlbaran
   DATA cFormatNumAlbaran
   DATA dFechaAlbaran

   DATA cTextoQR

   DATA cConector

   DATA cFileName

   METHOD New()

   METHOD Run()

   METHOD GeneraContenidoCabeceraQR()

   METHOD GeneraContenidoLineasQR()

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS AlbarenesClientesQR

   ::cTextoQR                    := ""
   ::cConector                   := "|"
   ::nView                       := nView
   ::cFileName                   := "c:\fwh1801\Gestool\bin\QR.bmp"
   ::cNumAlbaran                 := ( D():AlbaranesClientes( ::nView ) )->cSerAlb + Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb ) + ( D():AlbaranesClientes( ::nView ) )->cSufAlb
   ::cFormatNumAlbaran           := ( D():AlbaranesClientes( ::nView ) )->cSerAlb + "/" + AllTrim( Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb ) ) + "/" + ( D():AlbaranesClientes( ::nView ) )->cSufAlb
   ::dFechaAlbaran               := dToc( ( D():AlbaranesClientes( ::nView ) )->dFecAlb )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD Run() CLASS AlbarenesClientesQR

   ::GeneraContenidoCabeceraQR()

   ::GeneraContenidoLineasQR()

   QrCodeToHBmp( 20, 20, AllTrim( ::cTextoQR ), ::cFileName )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD GeneraContenidoCabeceraQR() CLASS AlbarenesClientesQR

   ::cTextoQR  += "NUM_ALBARAN=" + ::cFormatNumAlbaran + CRLF
   ::cTextoQR  += "FECHA=" + ::dFechaAlbaran + CRLF 
   ::cTextoQR  += "METODOPRODUCCION=" + AllTrim( getCustomExtraField( "001", "Albaranes a clientes", ::cNumAlbaran ) ) + CRLF 
   ::cTextoQR  += "CONSERVACION=" + AllTrim( getCustomExtraField( "002", "Albaranes a clientes", ::cNumAlbaran ) ) + CRLF 
   ::cTextoQR  += "NUMLINEA" + ::cConector + ; 
                  "NOMCOMERCIAL" + ::cConector + ;
                  "NOMCIENTIFICO" + ::cConector + ;
                  "ZONAFAO" + ::cConector + ;
                  "ARTEPESCA" + ::cConector + ;
                  "CONSUMOPREFERENTE" + ::cConector + ;
                  "BARCO" + ::cConector + ;
                  "MAREA" + ::cConector + ;
                  "LOTE" + ::cConector + ;
                  "BULTOS" + ::cConector + ;
                  "CAJAS" + ::cConector + ;
                  "KILOS" + CRLF

Return ( Self )

//---------------------------------------------------------------------------//

METHOD GeneraContenidoLineasQR() CLASS AlbarenesClientesQR

   local nRec     := ( D():AlbaranesClientesLineas( ::nView ) )->( Recno() )
   local nOrdAnt  := ( D():AlbaranesClientesLineas( ::nView ) )->( OrdSetFocus( "nNumAlb" ) )
   local nNumLin  := 1

   if ( D():AlbaranesClientesLineas( ::nView ) )->( dbSeek( ::cNumAlbaran ) )

      while ( D():AlbaranesClientesLineas( ::nView ) )->cSerAlb + Str( ( D():AlbaranesClientesLineas( ::nView ) )->nNumAlb ) + ( D():AlbaranesClientesLineas( ::nView ) )->cSufAlb == ::cNumAlbaran .and.;
         !( D():AlbaranesClientesLineas( ::nView ) )->( Eof() )

         if !Empty( ( D():AlbaranesClientesLineas( ::nView ) )->cRef )

            ::cTextoQR  += AllTrim( Str( nNumLin ) ) + ::cConector + ; 
                           AllTrim( ( D():AlbaranesClientesLineas( ::nView ) )->cDetalle ) + ::cConector + ;
                           "NOMCIENTIFICO" + ::cConector + ;
                           "ZONAFAO" + ::cConector + ;
                           "ARTEPESCA" + ::cConector + ;
                           "CONSUMOPREFERENTE" + ::cConector + ;
                           AllTrim( ( D():AlbaranesClientesLineas( ::nView ) )->cValPr1 ) + ::cConector + ;
                           AllTrim( ( D():AlbaranesClientesLineas( ::nView ) )->cValPr2 ) + ::cConector + ;
                           AllTrim( ( D():AlbaranesClientesLineas( ::nView ) )->cLote ) + ::cConector + ;
                           AllTrim( Trans( notCero( ( D():AlbaranesClientesLineas( ::nView ) )->nBultos ), MasUnd() ) ) + ::cConector + ;
                           AllTrim( Trans( notCero( ( D():AlbaranesClientesLineas( ::nView ) )->nCanEnt ), MasUnd() ) ) + ::cConector + ;
                           AllTrim( Trans( ( D():AlbaranesClientesLineas( ::nView ) )->nUniCaja, MasUnd() ) ) + CRLF

            nNumLin++

         end if

         ( D():AlbaranesClientesLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ( D():AlbaranesClientesLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():AlbaranesClientesLineas( ::nView ) )->( dbGoTo( nRec ) )

Return ( Self )

//---------------------------------------------------------------------------//