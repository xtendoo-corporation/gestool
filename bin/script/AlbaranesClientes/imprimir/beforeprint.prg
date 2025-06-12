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

   DATA cIdMetodoProduccion
   DATA cIdConServacion
   DATA cIdNomCientifico
   DATA cIdZonaFao
   DATA cIdArtePesca
   DATA cIdFechaCongelacion

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

   ::cIdMetodoProduccion         := "015"   // Artículos C 50
   ::cIdConServacion             := "016"   // Artículos C 50
   ::cIdNomCientifico            := "017"   // Artículos C 50
   ::cIdZonaFao                  := "018"   // Lineas de albaranes C 50
   ::cIdArtePesca                := "019"   // Artículos C 50
   ::cIdFechaCongelacion         := "020"   // Lineas de albaranes  D  8 

   ::cFileName                   := "C:\Gestion\Gestool\QR.bmp"

   ::cNumAlbaran                 := ( D():AlbaranesClientes( ::nView ) )->cSerAlb + Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb ) + ( D():AlbaranesClientes( ::nView ) )->cSufAlb
   ::cFormatNumAlbaran           := ( D():AlbaranesClientes( ::nView ) )->cSerAlb + "/" + AllTrim( Str( ( D():AlbaranesClientes( ::nView ) )->nNumAlb ) ) + "/" + ( D():AlbaranesClientes( ::nView ) )->cSufAlb
   ::dFechaAlbaran               := dToc( ( D():AlbaranesClientes( ::nView ) )->dFecAlb )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD Run() CLASS AlbarenesClientesQR

   ::GeneraContenidoCabeceraQR()

   ::GeneraContenidoLineasQR()

   //MsgInfo( ::cTextoQR, len( ::cTextoQR ) )

   QrCodeToHBmp( 20, 20, AllTrim( ::cTextoQR ), ::cFileName )

Return ( Self )

//---------------------------------------------------------------------------//

METHOD GeneraContenidoCabeceraQR() CLASS AlbarenesClientesQR

   ::cTextoQR  += "NUM_ALBARAN=" + ::cFormatNumAlbaran + CRLF
   ::cTextoQR  += "FECHA=" + ::dFechaAlbaran + CRLF 
   ::cTextoQR  += "NUMLINEA" + ::cConector + ; 
                  "NOMCOMERCIAL" + ::cConector + ;
                  "NOMCIENTIFICO" + ::cConector + ;
                  "METODOPRODUCCION" + ::cConector + ;
                  "CONSERVACION" + ::cConector + ;
                  "ZONAFAO" + ::cConector + ;
                  "ARTEPESCA" + ::cConector + ;
                  "CONSUMOPREFERENTE/CADUCIDAD" + ::cConector + ;
                  "FECHACONGELACION" + ::cConector + ;
                  "LOTE" + CRLF

Return ( Self )

//---------------------------------------------------------------------------//

METHOD GeneraContenidoLineasQR() CLASS AlbarenesClientesQR

   local nRec     := ( D():AlbaranesClientesLineas( ::nView ) )->( Recno() )
   local nOrdAnt  := ( D():AlbaranesClientesLineas( ::nView ) )->( OrdSetFocus( "nNumAlb" ) )
   local nNumLin  := 1
   local lBreak   := .f.

   if ( D():AlbaranesClientesLineas( ::nView ) )->( dbSeek( ::cNumAlbaran ) )

      while ( D():AlbaranesClientesLineas( ::nView ) )->cSerAlb + Str( ( D():AlbaranesClientesLineas( ::nView ) )->nNumAlb ) + ( D():AlbaranesClientesLineas( ::nView ) )->cSufAlb == ::cNumAlbaran .and.;
         !( D():AlbaranesClientesLineas( ::nView ) )->( Eof() ) .and. ;
         !lBreak

         if !Empty( ( D():AlbaranesClientesLineas( ::nView ) )->cRef )

            ::cTextoQR  += AllTrim( Str( nNumLin ) ) + ::cConector + ; 
                           AllTrim( ( D():AlbaranesClientesLineas( ::nView ) )->cDetalle ) + ::cConector + ;
                           AllTrim( getCustomExtraField( ::cIdNomCientifico, "Artículos", ( D():AlbaranesClientesLineas( ::nView ) )->cRef ) ) + ::cConector + ;
                           AllTrim( getCustomExtraField( ::cIdMetodoProduccion, "Artículos", ( D():AlbaranesClientesLineas( ::nView ) )->cRef ) ) + ::cConector + ;
                           AllTrim( getCustomExtraField( ::cIdConServacion, "Artículos", ( D():AlbaranesClientesLineas( ::nView ) )->cRef ) ) + ::cConector + ;
                           AllTrim( getCustomExtraField( ::cIdZonaFao, "Lineas de albaranes a clientes", ::cNumAlbaran + Str( ( D():AlbaranesClientesLineas( ::nView ) )->nNumLin ) ) ) + ::cConector + ;
                           AllTrim( getCustomExtraField( ::cIdArtePesca, "Artículos", ( D():AlbaranesClientesLineas( ::nView ) )->cRef ) ) + ::cConector + ;
                           AllTrim( dToc( ( D():AlbaranesClientesLineas( ::nView ) )->dFecCad ) ) + ::cConector + ;
                           if( !Empty( getCustomExtraField( ::cIdFechaCongelacion, "Lineas de albaranes a clientes", ::cNumAlbaran + Str( ( D():AlbaranesClientesLineas( ::nView ) )->nNumLin ) ) ), AllTrim( dToc( getCustomExtraField( ::cIdFechaCongelacion, "Lineas de albaranes a clientes", ::cNumAlbaran + Str( ( D():AlbaranesClientesLineas( ::nView ) )->nNumLin ) ) ) ), "" ) + ::cConector + ;
                           AllTrim( ( D():AlbaranesClientesLineas( ::nView ) )->cLote ) + ::cConector + CRLF

            nNumLin++

            if nNumLin == 30
               lBreak := .t.
            end if

         end if

         ( D():AlbaranesClientesLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ( D():AlbaranesClientesLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():AlbaranesClientesLineas( ::nView ) )->( dbGoTo( nRec ) )

Return ( Self )

//---------------------------------------------------------------------------//