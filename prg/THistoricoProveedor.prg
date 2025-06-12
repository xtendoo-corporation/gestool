#include "FiveWin.Ch"
#include "Factu.ch" 
#include "Menu.ch"
#include "Report.ch"
#include "MesDbf.ch"

//--------------------------------------------------------------------------//

CLASS THistoricoProveedor

   DATA oDialog
   DATA oBmpGeneral
   DATA cSayArticulo

   DATA oCosto
   DATA oProvee
   DATA oIdDocCom

   DATA aBrowse
   DATA oBrowse

   DATA cCodigoArticulo

   METHOD Run()

   METHOD setDatos()

   METHOD Resource()

   METHOD Import()

END CLASS

//--------------------------------------------------------------------------//

METHOD Run( cCodArt, oCosto, oProvee, oIdDocCom )

   ::cCodigoArticulo    := cCodArt
   ::oCosto             := oCosto
   ::oProvee            := oProvee
   ::oIdDocCom          := oIdDocCom

   if Empty( ::cCodigoArticulo )
      Return .f.
   end if

   ::cSayArticulo       := "Artículo: " + AllTrim( ::cCodigoArticulo ) + " - " + AllTrim( ArticulosModel():getNombre( ::cCodigoArticulo ) )

   ::aBrowse            := {}

   ::setDatos()

   ::Resource()

RETURN ( .t. )

//--------------------------------------------------------------------------//

METHOD setDatos()

   local aCompras
   local hBrowse

   CursorWait()

   aCompras := AlbaranesProveedoresLineasModel():getComprasArticulo( ::cCodigoArticulo )

   if hb_isArray( aCompras ) .and. len( aCompras ) > 0
      aEval( aCompras, {|a| aAdd( ::aBrowse, a ) } )
   end if

   aCompras := FacturasProveedoresLineasModel():getComprasArticulo( ::cCodigoArticulo )

   if hb_isArray( aCompras ) .and. len( aCompras ) > 0
      aEval( aCompras, {|a| aAdd( ::aBrowse, a ) } )
   end if
   
   aSort( ::aBrowse, , , {|x,y| hGet( x, "fecha" ) > hGet( y, "fecha" ) } )

   for each hBrowse in ::aBrowse
      hSet( hBrowse, "und_vendidas", AlbaranesClientesLineasModel():getUndVendidasFromDocument( ::cCodigoArticulo, hget( hBrowse, "idDoc" ) ) )
   next

   CursorWe()

RETURN ( .t. )

//--------------------------------------------------------------------------//

METHOD Resource()

   DEFINE DIALOG ::oDialog RESOURCE "HIS_PROVEEDOR" TITLE "Histotico precios proveedor"

      REDEFINE BITMAP ::oBmpGeneral;
         ID       500 ;
         RESOURCE "gc_symbol_euro_48" ;
         TRANSPARENT ;
         OF       ::oDialog

      REDEFINE SAY PROMPT ::cSayArticulo ;
         ID       50 ;
         OF       ::oDialog

      ::oBrowse                        := IXBrowse():New( ::oDialog )

      ::oBrowse:bClrSel                := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrowse:bClrSelFocus           := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrowse:SetArray( ::aBrowse, , , .f. )

      ::oBrowse:nMarqueeStyle          := 6
      ::oBrowse:lRecordSelector        := .f.
      ::oBrowse:lHScroll               := .f.

      ::oBrowse:CreateFromResource( 100 )

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Tipo"
         :bStrData         := {|| hget( ::aBrowse[ ::oBrowse:nArrayAt ], "tipo" ) }
         :nWidth           := 110
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Documento"
         :bStrData         := {|| hget( ::aBrowse[ ::oBrowse:nArrayAt ], "numero" ) }
         :nWidth           := 75
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Fecha"
         :bStrData         := {|| hget( ::aBrowse[ ::oBrowse:nArrayAt ], "fecha" ) }
         :nWidth           := 80
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Proveedor"
         :bStrData         := {|| AllTrim( hget( ::aBrowse[ ::oBrowse:nArrayAt ], "proveedor" ) ) + " - " + ProveedoresModel():getField( 'Titulo', 'Cod', hget( ::aBrowse[ ::oBrowse:nArrayAt ], "proveedor" ) ) }
         :nWidth           := 200
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Unidades"
         :bStrData         := {|| Trans( hget( ::aBrowse[ ::oBrowse:nArrayAt ], "unidades" ), MasUnd() ) }
         :nWidth           := 60
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Precio"
         :bStrData         := {|| Trans( hget( ::aBrowse[ ::oBrowse:nArrayAt ], "precio" ), cPorDiv() ) }
         :nWidth           := 60
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Und vendidas"
         :bStrData         := {|| Trans( hget( ::aBrowse[ ::oBrowse:nArrayAt ], "und_vendidas" ), MasUnd() ) }
         :nWidth           := 80
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Restante"
         :bStrData         := {|| Trans( hget( ::aBrowse[ ::oBrowse:nArrayAt ], "unidades" ) - hget( ::aBrowse[ ::oBrowse:nArrayAt ], "und_vendidas" ), MasUnd() ) }
         :nWidth           := 80
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      REDEFINE BUTTON ;
         ID       IDOK ;
         OF       ::oDialog ;
         CANCEL ;
         ACTION   ( ::Import() )

      REDEFINE BUTTON ;
         ID       IDCANCEL ;
         OF       ::oDialog ;
         CANCEL ;
         ACTION   ( ::oDialog:end() )

      ACTIVATE DIALOG ::oDialog CENTER

   ::oBmpGeneral:End()

RETURN ( .t. )

//--------------------------------------------------------------------------//

METHOD Import()

   if !Empty( ::oCosto )
      ::oCosto:cText( hGet( ::oBrowse:aArrayData[ ::oBrowse:nArrayAt ], "precio" ) )
   end if

   if !Empty( ::oProvee )
      ::oProvee:cText( hGet( ::oBrowse:aArrayData[ ::oBrowse:nArrayAt ], "proveedor" ) )
      ::oProvee:lValid()
   end if

   if !Empty( ::oIdDocCom )
      ::oIdDocCom:cText( hGet( ::oBrowse:aArrayData[ ::oBrowse:nArrayAt ], "idDoc" ) )
   end if

RETURN ( ::oDialog:end( IDOK ) )

//--------------------------------------------------------------------------//