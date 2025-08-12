#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS InfoCompras

   DATA cCodigoProveedor
   DATA cCodigoArticulo

   DATA oDialog
   DATA oBmpGeneral

   DATA oBrowse

   DATA aCompras

   DATA cSayArticulo
   DATA cSayProveedor

   METHOD run( cCodPrv, cCodArt )

   METHOD initSay()

   METHOD initArrayCompras()

   METHOD Resource()

END CLASS

//---------------------------------------------------------------------------//

METHOD run( cCodPrv, cCodArt )

   if empty( cCodPrv ) .or. empty( cCodArt )
      Return .t.
   end if

   ::cCodigoProveedor   := cCodPrv
   ::cCodigoArticulo    := cCodArt

   ::initSay()

   ::initArrayCompras()

   if Len( ::aCompras ) == 0
      MsgStop( "No hay compras del artículo y proveedor seleccionado" )
      Return .t.
   end if

   ::Resource()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD initSay()

   ::cSayArticulo       := "Artículo: " + AllTrim( ::cCodigoArticulo ) + " - " + AllTrim( retArticulo( ::cCodigoArticulo ) )
   ::cSayProveedor      := "Proveedor: " + AllTrim( ::cCodigoProveedor ) + " - " + AllTrim( retProvee( ::cCodigoProveedor ) )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD initArrayCompras()

   ::aCompras           := {}

   aEval( AlbaranesProveedoresLineasModel():getUltimasCompras( ::cCodigoArticulo, ::cCodigoProveedor ), { |a| aAdd( ::aCompras, a ) } )
   aEval( FacturasProveedoresLineasModel():getUltimasCompras( ::cCodigoArticulo, ::cCodigoProveedor ), { |a| aAdd( ::aCompras, a ) } )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD Resource()

   DEFINE DIALOG ::oDialog RESOURCE "ARTPRVINFO" TITLE "Informe de compras"

      REDEFINE BITMAP ::oBmpGeneral;
         ID       500 ;
         RESOURCE "gc_cabinet_open_48" ;
         TRANSPARENT ;
         OF       ::oDialog

      REDEFINE SAY PROMPT ::cSayArticulo ;
         ID       110 ;
         OF       ::oDialog

      REDEFINE SAY PROMPT ::cSayProveedor ;
         ID       120 ;
         OF       ::oDialog

      ::oBrowse                  := IXBrowse():New( ::oDialog )

      ::oBrowse:bClrSel          := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrowse:bClrSelFocus     := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrowse:SetArray( ::aCompras, , , .f. )

      ::oBrowse:nMarqueeStyle    := 6
      ::oBrowse:lRecordSelector  := .f.
      ::oBrowse:lHScroll         := .f.

      ::oBrowse:CreateFromResource( 100 )

      with object ( ::oBrowse:AddCol() )
         :cHeader                := "Tipo doc."
         :bStrData               := {|| hget( ::aCompras[ ::oBrowse:nArrayAt ], "tipo" ) }
         :nWidth                 := 280
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader                := "N. Doc"
         :bStrData               := {|| hget( ::aCompras[ ::oBrowse:nArrayAt ], "numero" ) }
         :nWidth                 := 150
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader                := "Fecha"
         :bStrData               := {|| hget( ::aCompras[ ::oBrowse:nArrayAt ], "fecha" ) }
         :nWidth                 := 120
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader                := "Precio"
         :bStrData               := {|| hget( ::aCompras[ ::oBrowse:nArrayAt ], "precio" ) }
         :cEditPicture           := cPorDiv()
         :nWidth                 := 150
         :nDataStrAlign          := 1
         :nHeadStrAlign          := 1
      end with

      REDEFINE BUTTON ;
         ID       IDCANCEL ;
         OF       ::oDialog ;
         CANCEL ;
         ACTION   ( ::oDialog:end() )

      ACTIVATE DIALOG ::oDialog CENTER

   ::oBmpGeneral:End()

Return ( .t. )

//---------------------------------------------------------------------------//