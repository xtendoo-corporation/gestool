#include "FiveWin.Ch"
#include "Factu.ch"
#include "hbclass.ch"

#define CRLF chr( 13 ) + chr( 10 )

//---------------------------------------------------------------------------//

Function Inicio( nView )

   local oAlbarenesFacturados

   oAlbarenesFacturados    := AlbarenesFacturados():New( nView )

   oAlbarenesFacturados:Run()

Return ( nil )

//---------------------------------------------------------------------------//

CLASS AlbarenesFacturados

   DATA nView

   DATA oDialog

   DATA oBrowse

   DATA aAlbaranes
   DATA aHuerfanos

   METHOD New()

   METHOD Run()

   METHOD SearchHuerfanos() 

   METHOD Resource()

   METHOD SetResources()      INLINE ( SetResources( fullcurdir() + "Script\AlbaranesClientes\Facturados.dll" ) )

   METHOD FreeResources()     INLINE ( FreeResources() )

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New( nView ) CLASS AlbarenesFacturados

   ::nView                       := nView
   ::aAlbaranes                  := AlbaranesClientesModel():ListFacturados()
   ::aHuerfanos                  := {}

Return ( Self )

//---------------------------------------------------------------------------//

METHOD Run() CLASS AlbarenesFacturados

   local hAlbaran
   local nOrdAnt

   ::SetResources()

   nOrdAnt                 := ( D():FacturasClientesLineas( ::nView ) )->( OrdSetFocus( "CCODALB" ) )

   if hb_isArray( ::aAlbaranes ) .and. Len( ::aAlbaranes ) > 0
      aEval( ::aAlbaranes, {|h| ::SearchHuerfanos( hGet( h, "CSERALB" ) + Padr( Str( hGet( h, "NNUMALB" ) ), 9 ) + hGet( h, "CSUFALB" ) ) } )
   end if

   ( D():FacturasClientesLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

   if Len( ::aHuerfanos ) == 0
      MsgInfo( "No se ha encontrado ningun albarán" )
   else
      ::Resource()
   end if

   ::FreeResources()

Return ( Self )

//---------------------------------------------------------------------------//

METHOD SearchHuerfanos( cNumAlb ) CLASS AlbarenesFacturados

   if !( D():FacturasClientesLineas( ::nView ) )->( dbSeek( cNumAlb ) )
      aAdd( ::aHuerfanos, cNumAlb )
   end if

Return ( Self )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS AlbarenesFacturados

   DEFINE DIALOG ::oDialog RESOURCE "INFORME" 

      ::oBrowse                        := IXBrowse():New( ::oDialog )

      ::oBrowse:bClrSel                := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrowse:bClrSelFocus           := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrowse:SetArray( ::aHuerfanos, , , .f. )

      ::oBrowse:nMarqueeStyle          := 5
      ::oBrowse:lRecordSelector        := .f.
      ::oBrowse:lHScroll               := .f.

      ::oBrowse:CreateFromResource( 100 )

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Albarán"
         :bStrData         := {|| if( len( ::aHuerfanos ) > 0, ::aHuerfanos[ ::oBrowse:nArrayAt ], "" ) }
         :nWidth           := 120
      end with

   REDEFINE BUTTON ;
      ID          IDCANCEL ;
      OF          ::oDialog ;
      ACTION      ( ::oDialog:End( IDCANCEL ) )

   ACTIVATE DIALOG ::oDialog CENTER

Return ( Self )

//---------------------------------------------------------------------------//