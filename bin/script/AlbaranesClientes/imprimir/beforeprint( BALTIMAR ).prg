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
   ::cIdZonaFao                  := "018"   // Artículos C 50
   ::cIdArtePesca                := "019"   // Artículos C 50

   ::cFileName                   := "D:\Gestool\QR.bmp"

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
                  "CONSUMOPREFERENTE" + ::cConector + ; //CADUCIDAD
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
                           AllTrim( ( D():AlbaranesClientesLineas( ::nView ) )->cValPr1 ) + ::cConector + ;
                           AllTrim( ( D():AlbaranesClientesLineas( ::nView ) )->cValPr2 ) + ::cConector + ;
                           AllTrim( ( D():AlbaranesClientesLineas( ::nView ) )->cLote ) + ::cConector + ;
                           AllTrim( Trans( notCero( ( D():AlbaranesClientesLineas( ::nView ) )->nBultos ), MasUnd() ) ) + ::cConector + ;
                           AllTrim( Trans( notCero( ( D():AlbaranesClientesLineas( ::nView ) )->nCanEnt ), MasUnd() ) ) + ::cConector + ;
                           AllTrim( Trans( ( D():AlbaranesClientesLineas( ::nView ) )->nUniCaja, MasUnd() ) ) + CRLF

            nNumLin++

            if nNumLin == 26
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