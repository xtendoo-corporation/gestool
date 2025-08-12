#include "FiveWin.Ch"
#include "Factu.ch" 
#include "MesDbf.ch"
#include "Xbrowse.ch"

//----------------------------------------------------------------------------//

CLASS GenPedProvFromMinimo

   DATA nView
   
   DATA oCodigoProveedor
   DATA cCodigoProveedor
   DATA oNombreProveedor
   DATA cNombreProveedor

   DATA oSayNombreProveedor

   DATA oMetMsg
   DATA nMetMsg

   DATA aAlmacenes

   DATA aLines

   DATA oDlg
   DATA oFld
   DATA oBmp

   DATA oBrowse

   DATA oFontTitle

   DATA oDbfTemporal

   METHOD New()

   METHOD Activate()

   METHOD cNomProveedor()     INLINE ( "Proveedor: " + AllTrim( ::cCodigoProveedor ) + " - " + AllTrim( ::cNombreProveedor ) )

   METHOD Load()

   METHOD loadRegister( cCodArt, hAlmacen )

   METHOD Save()

   METHOD nSumUnidades()

   METHOD nTotalImporte()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView, oCodigoProveedor, oNombreProveedor, dbfTmpLin ) CLASS GenPedProvFromMinimo

   ::nView              := nView

   ::oFontTitle         := TFont():New( "Arial", 8, 16, .f., .t. )

   ::nMetMsg            := 0

   ::aAlmacenes         := {}

   ::aLines             := {}

   ::oCodigoProveedor   := oCodigoProveedor
   ::cCodigoProveedor   := oCodigoProveedor:VarGet()
   ::oNombreProveedor   := oNombreProveedor
   ::cNombreProveedor   := oNombreProveedor:VarGet()

   ::oDbfTemporal       := dbfTmpLin

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD Activate() CLASS GenPedProvFromMinimo

   if Empty( ::cCodigoProveedor )
      MsgStop( "Tiene que seleccionar un proveedor para ejecutar éste asistente." )
      ::oCodigoProveedor:SetFocus()
      return .f.
   end if

   DEFINE DIALOG  ::oDlg ;
      RESOURCE    "ASS_IMPORTAR_MINIMO"

      REDEFINE BITMAP ::oBmp ;
         ID          500 ;
         RESOURCE    "gc_hand_touch_48" ;
         TRANSPARENT ;
         OF          ::oDlg

      REDEFINE SAY ::oSayNombreProveedor PROMPT ::cNomProveedor() ;
         ID          100 ;
         FONT        ::oFontTitle() ;
         OF          ::oDlg

      ::oBrowse                        := IXBrowse():New( ::oDlg )

      ::oBrowse:bClrSel                := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrowse:bClrSelFocus           := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrowse:SetArray( ::aLines, , , .f. )

      ::oBrowse:nMarqueeStyle          := 6
      ::oBrowse:lRecordSelector        := .f.
      ::oBrowse:lHScroll               := .f.
      ::oBrowse:lFooter                := .t.
      ::oBrowse:lAutoSort              := .t.

      ::oBrowse:CreateFromResource( 200 )

      ::oBrowse:bLDblClick             := {|| hSet( ::aLines[ ::oBrowse:nArrayAt ], "lSelect", !hGet( ::aLines[ ::oBrowse:nArrayAt ], "lSelect" ) ), ::oBrowse:Refresh() }

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Sel.Seleccionado"
         :bStrData         := {|| "" }
         :bEditValue       := {|| hGet( ::aLines[ ::oBrowse:nArrayAt ], "lSelect" ) }
         :nWidth           := 20
         :SetCheck( { "Sel16", "Nil16" } )
         :bLClickHeader    := {| nMRow, nMCol, nFlags, oCol | aeval( ::aLines, {|h| hSet( h, "lSelect", !hGet( h, "lSelect" ) ) } ), ::oBrowse:Refresh() }
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Artículo"
         :bEditValue       := {|| AllTrim( hGet( ::aLines[ ::oBrowse:nArrayAt ], "cCodArt" ) ) + " - " + AllTrim( hGet( ::aLines[ ::oBrowse:nArrayAt ], "cNomArt" ) ) }
         :nWidth           := 240
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Almacén"
         :bEditValue       := {|| AllTrim( hGet( ::aLines[ ::oBrowse:nArrayAt ], "cCodAlm" ) ) + " - " + AllTrim( hGet( ::aLines[ ::oBrowse:nArrayAt ], "cNomAlm" ) ) }
         :nWidth           := 240
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Stock"
         :bEditValue       := {|| hGet( ::aLines[ ::oBrowse:nArrayAt ],"nStock" ) }
         :nWidth           := 80
         :cEditPicture     := MasUnd()
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Mínimo"
         :bEditValue       := {|| hGet( ::aLines[ ::oBrowse:nArrayAt ],"nMinimo" ) }
         :nWidth           := 80
         :cEditPicture     := MasUnd()
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Unidades"
         :bEditValue       := {|| hGet( ::aLines[ ::oBrowse:nArrayAt ],"nUnidades" ) }
         :cEditPicture     := MasUnd()
         :nWidth           := 80
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
         :nEditType        := 1
         :bOnPostEdit      := {|o,x,n| hSet( ::aLines[ ::oBrowse:nArrayAt ],"nUnidades", x ) }
         :nFootStyle       := :nDataStrAlign               
         //:nFooterType      := AGGR_SUM
         :bFooter          := {|| ::nSumUnidades() }
         :cFooterPicture   := :cEditPicture
         :oFooterFont      := getBoldFont()
         :cDataType        := "N"
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Costo"
         :bEditValue       := {|| hGet( ::aLines[ ::oBrowse:nArrayAt ],"nCosto" ) }
         :cEditPicture     := MasUnd()
         :nWidth           := 80
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader          := "Total"
         :bEditValue       := {|| ( hGet( ::aLines[ ::oBrowse:nArrayAt ],"nUnidades" ) * hGet( ::aLines[ ::oBrowse:nArrayAt ],"nCosto" ) ) }
         :cEditPicture     := MasUnd()
         :nWidth           := 80
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
         :nFootStyle       := :nDataStrAlign               
         :bFooter          := {|| ::nTotalImporte() }
         //:nFooterType      := AGGR_SUM
         :cFooterPicture   := :cEditPicture
         :oFooterFont      := getBoldFont()
         :cDataType        := "N"
      end with

      REDEFINE APOLOMETER ::oMetMsg VAR ::nMetMsg ;
         ID          300 ;
         NOPERCENTAGE;
         TOTAL       100 ;
         OF          ::oDlg

      ::oMetMsg:nClrText   := rgb( 128,255,0 )
      ::oMetMsg:nClrBar    := rgb( 128,255,0 )
      ::oMetMsg:nClrBText  := rgb( 128,255,0 )

      REDEFINE BUTTON ;
         ID          IDOK ;
         OF          ::oDlg ;
         ACTION      ( ::save(), ::oDlg:End( IDOK ) )

      REDEFINE BUTTON ;
         ID          IDCANCEL ;
         OF          ::oDlg ;
         CANCEL ;
         ACTION      ( ::oDlg:end() )

      ::oDlg:bStart  := {|| ::Load(), ::oBrowse:MakeTotals(), ::oBrowse:RefreshFooters() }

   ACTIVATE DIALOG ::oDlg CENTER

   ::oBmp:End()
   ::oFontTitle:End()

RETURN ( ::oDlg:nResult == IDOK )

//----------------------------------------------------------------------------//

METHOD Load() CLASS GenPedProvFromMinimo

   local nRec        := ( D():ProveedorArticulo( ::nView ) )->( Recno() )
   local nOrdAnt     := ( D():ProveedorArticulo( ::nView ) )->( OrdSetFocus( "cCodPrv" ) )
   local hAlmacen

   ::aLines          := {}

   /*
   Cargamos los almacenes------------------------------------------------------
   */

   ::aAlmacenes      := AlmacenesModel():aAlmacenes()

   ::oMetMsg:SetTotal( ( D():ProveedorArticulo( ::nView ) )->( ordkeycount() ) )

   if ( D():ProveedorArticulo( ::nView ) )->( dbSeek( ::cCodigoProveedor ) )

      while ( D():ProveedorArticulo( ::nView ) )->cCodPrv == ::cCodigoProveedor .and.;
         !( D():ProveedorArticulo( ::nView ) )->( Eof() )

            for each hAlmacen in ::aAlmacenes

               ::loadRegister( ( D():ProveedorArticulo( ::nView ) )->cCodArt, hAlmacen )

            next

         ( D():ProveedorArticulo( ::nView ) )->( dbSkip() )

         ::oMetMsg:Set( ( D():ProveedorArticulo( ::nView ) )->( OrdKeyNo() ) )

      end while

   end if

   ::oMetMsg:SetTotal( ( D():ProveedorArticulo( ::nView ) )->( ordkeycount() ) )

   /*
   Ocultamos el meter----------------------------------------------------------
   */

   ::oMetMsg:Hide()

   /*
   devolvemos las tablas a su estado original----------------------------------
   */

   ( D():ProveedorArticulo( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():ProveedorArticulo( ::nView ) )->( dbGoTo( nRec ) )

   ::oBrowse:SetArray( ::aLines, , , .f. )
   ::oBrowse:Refresh()

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD loadRegister( cCodArt, hAlmacen ) CLASS GenPedProvFromMinimo

   local nStockAlmacen
   local nStockMinimo

   nStockMinimo         := ArticulosModel():getField( 'nMinimo', 'Codigo', ( D():ProveedorArticulo( ::nView ) )->cCodArt )

   if nStockMinimo != 0

      nStockAlmacen     := StocksModel():nStockArticulo( cCodArt, hGet( hAlmacen, "cCodAlm" ) )

      if nStockAlmacen < nStockMinimo

         aAdd( ::aLines, { "cCodArt" => cCodArt ,;
                           "cNomArt" => ArticulosModel():getNombre( cCodArt ) ,;
                           "cCodAlm" => hGet( hAlmacen, "cCodAlm" ),;
                           "cNomAlm" => hGet( hAlmacen, "cNomAlm" ),;
                           "nStock"  => nStockAlmacen,;
                           "nMinimo" => nStockMinimo,;
                           "nUnidades" => ( nStockMinimo - nStockAlmacen ),;
                           "cRefPrv" => ( D():ProveedorArticulo( ::nView ) )->cRefPrv,;
                           "nCosto" => ArticulosModel():getField( 'pCosto', 'Codigo', cCodArt ),;
                           "lSelect" => .t. } )

      end if

   end if

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD Save() CLASS GenPedProvFromMinimo

   local hLine
   local n     := 1

   ::oMetMsg:Show()
   ::oMetMsg:SetTotal( Len( ::aLines ) )

   for each hLine in ::aLines

      if hGet( hLine, "lSelect" ) .and. ( hGet( hLine, "nUnidades" ) > 0 )

         ( ::oDbfTemporal )->( dbappend() )

         ( ::oDbfTemporal )->cRef         := hGet( hLine, "cCodArt" )
         ( ::oDbfTemporal )->cRefPrv      := hGet( hLine, "cRefPrv" )
         ( ::oDbfTemporal )->cDetalle     := hGet( hLine, "cNomArt" )
         ( ::oDbfTemporal )->nIva         := nIva( D():TiposIva( ::nView ), ArticulosModel():getField( 'TipoIva', 'Codigo', hGet( hLine, "cCodArt" ) ) )
         ( ::oDbfTemporal )->nReq         := nReq( D():TiposIva( ::nView ), ArticulosModel():getField( 'TipoIva', 'Codigo', hGet( hLine, "cCodArt" ) ) )
         ( ::oDbfTemporal )->cAlmLin      := hGet( hLine, "cCodAlm" )
         ( ::oDbfTemporal )->nStkAct      := hGet( hLine, "nStock" )
         ( ::oDbfTemporal )->nStkMin      := hGet( hLine, "nMinimo" )
         ( ::oDbfTemporal )->nCanEnt      := 1
         ( ::oDbfTemporal )->nUniCaja     := hGet( hLine, "nUnidades" )
         ( ::oDbfTemporal )->nPreDiv      := hGet( hLine, "nCosto" )
         ( ::oDbfTemporal )->nCtlStk      := 1
         ( ::oDbfTemporal )->nNumLin      := n
         ( ::oDbfTemporal )->nPosPrint    := n
         ( ::oDbfTemporal )->cCodFam      := ArticulosModel():getField( 'Familia', 'Codigo', hGet( hLine, "cCodArt" ) )
         ( ::oDbfTemporal )->cGrpFam      := FamiliasModel():getField( 'cCodGrp', 'cCodFam', ArticulosModel():getField( 'Familia', 'Codigo', hGet( hLine, "cCodArt" ) ) )
         ( ::oDbfTemporal )->nEstado      := 1

         n++   

      end if

      ::oMetMsg:AutoInc()

   next

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD nSumUnidades() CLASS GenPedProvFromMinimo

   local nTotal   := 0

   aeval( ::aLines, {|h| if( hget( h, "lSelect" ), nTotal += hget( h, "nUnidades" ), ) } )

RETURN ( nTotal )

//----------------------------------------------------------------------------//

METHOD nTotalImporte() CLASS GenPedProvFromMinimo

   local nTotal   := 0

   aeval( ::aLines, {|h| if( hget( h, "lSelect" ), nTotal += ( hget( h, "nUnidades" ) * hget( h, "nCosto" ) ), ) } )

RETURN ( nTotal )

//----------------------------------------------------------------------------//