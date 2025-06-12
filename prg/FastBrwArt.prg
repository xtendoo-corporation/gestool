#include "FiveWin.Ch"
#include "Folder.ch"
#include "Report.ch"
#include "Label.ch"
#include "Factu.ch" 
#include "MesDbf.ch"
#include "TGraph.ch"

//---------------------------------------------------------------------------//

Function FastBrwArt( oGetCodigo, oGetNombre )

   TFastBrwArt():Run( oGetCodigo, oGetNombre )

Return nil

//---------------------------------------------------------------------------//

CLASS TFastBrwArt

   DATA  oDialog
   DATA  oBitmap

   DATA  oGetCodigo
   DATA  oGetNombre

   DATA  oBusqueda
   DATA  cBusqueda

   DATA  oOrden
   DATA  cOrden
   DATA  aOrden
   DATA  aCampoOrden

   DATA  nLevel

   DATA  oBtnBusqueda

   DATA  oBrowseArticulo
   DATA  oBrowseStock

   METHOD Run( oGetCodigo, oGetNombre )

   METHOD end()

   METHOD Resource()

   METHOD Search()
      METHOD prepareSentence()
      METHOD loadStock()

   METHOD addArticulo()

END CLASS

//---------------------------------------------------------------------------//

METHOD Run( oGetCodigo, oGetNombre ) CLASS TFastBrwArt

   ::oGetCodigo      := oGetCodigo
   ::oGetNombre      := oGetNombre

   ::cBusqueda       := Space( 200 )
   ::cOrden          := "Nombre"
   ::aOrden          := { "Código", "Nombre" }
   ::aCampoOrden     := { "CODIGO", "NOMBRE" }

   ::nLevel          := Auth():Level( "articulos" )

   ::Resource()

   ::end()

Return ( nil )

//---------------------------------------------------------------------------//

METHOD end() CLASS TFastBrwArt

   if !Empty( ::oBitmap )
      ::oBitmap:End()
   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS TFastBrwArt

   CursorWait()

   DEFINE DIALOG ::oDialog RESOURCE "FastBrwStock" TITLE "Información artículo."

      REDEFINE BITMAP ::oBitmap ;
         ID          600 ;
         RESOURCE    "gc_object_cube_48" ;
         TRANSPARENT ;
         OF          ::oDialog

      REDEFINE GET ::oBusqueda VAR ::cBusqueda;
         ID          100 ;
         VALID       ( msgRun( "Ejecutando busqueda", "Espere por favor...", {|| ::Search() } ), .t. );
         OF          ::oDialog

      REDEFINE COMBOBOX ::oOrden ;
         VAR         ::cOrden ;
         ID          110 ;
         ITEMS       ::aOrden ;
         OF          ::oDialog

      ::oBrowseArticulo                   := IXBrowse():New( ::oDialog )

      ::oBrowseArticulo:bClrSel           := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrowseArticulo:bClrSelFocus      := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrowseArticulo:SetArray( {}, , , .f. )
      ::oBrowseArticulo:nMarqueeStyle     := 6
      ::oBrowseArticulo:cName             := "FastBrowse.Articulos"
      ::oBrowseArticulo:bLDblClick        := {|| ::oDialog:end( IDOK ) }

      if !uFieldEmpresa( "lNStkAct" )
         ::oBrowseArticulo:bChange        := {|| ::loadStock() }
      end if

      ::oBrowseArticulo:CreateFromResource( 200 )

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := "Código"
         :bEditValue                      := {|| if( !empty( ::oBrowseArticulo:aArrayData ), hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "Codigo" ), "" ) }
         :nWidth                          := 90
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := "Nombre"
         :bEditValue                      := {|| if( !empty( ::oBrowseArticulo:aArrayData ), hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "Nombre" ), "" ) }
         :nWidth                          := 260
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar1", "Precio 1" )
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVenta1" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar1", "Precio 1" ) + " " + cImp() + " inc."
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVtaIva1" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar2", "Precio 2" )
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVenta2" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar2", "Precio 2" ) + " " + cImp() + " inc."
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVtaIva2" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar3", "Precio 3" )
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVenta3" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar3", "Precio 3" ) + " " + cImp() + " inc."
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVtaIva3" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar4", "Precio 4" )
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVenta4" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar4", "Precio 4" ) + " " + cImp() + " inc."
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVtaIva4" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar5", "Precio 5" )
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVenta5" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar5", "Precio 5" ) + " " + cImp() + " inc."
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVtaIva5" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar6", "Precio 6" )
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVenta6" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := uFieldEmpresa( "cTxtTar6", "Precio 6" ) + " " + cImp() + " inc."
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pVtaIva6" ), cPorDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      with object ( ::oBrowseArticulo:AddCol() )
         :cHeader                         := "Costo"
         :bStrData                        := {|| if( !empty( ::oBrowseArticulo:aArrayData ), Trans( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "pCosto" ), cPirDiv() ), "" ) }
         :nWidth                          := 90
         :nDataStrAlign                   := AL_RIGHT
         :nHeadStrAlign                   := AL_RIGHT
         :lHide                           := .t.
      end with

      /*
      Browse stock-------------------------------------------------------------
      */

      ::oBrowseStock                   := IXBrowse():New( ::oDialog )

      ::oBrowseStock:SetArray( {}, , , .f. )
      ::oBrowseStock:nMarqueeStyle     := 6
      ::oBrowseStock:cName             := "FastBrowse.Stock"
      ::oBrowseStock:bClrStd           := {|| { if( (!empty( ::oBrowseStock:aArrayData ) .and. hGet( ::oBrowseStock:aArrayData[ ::oBrowseStock:nArrayAt ], "unidades" ) > 0 ), CLR_GREEN, CLR_HRED ), GetSysColor( COLOR_WINDOW ) } }
      ::oBrowseStock:bClrSel           := {|| { if( (!empty( ::oBrowseStock:aArrayData ) .and. hGet( ::oBrowseStock:aArrayData[ ::oBrowseStock:nArrayAt ], "unidades" ) > 0 ), CLR_GREEN, CLR_HRED ), CLR_WHITE } }
      ::oBrowseStock:bClrSelFocus      := {|| { if( (!empty( ::oBrowseStock:aArrayData ) .and. hGet( ::oBrowseStock:aArrayData[ ::oBrowseStock:nArrayAt ], "unidades" ) > 0 ), CLR_GREEN, CLR_HRED ), CLR_WHITE } }

      ::oBrowseStock:CreateFromResource( 210 )

      with object ( ::oBrowseStock:AddCol() )
         :cHeader             := "Código"
         :nWidth              := 90
         :bStrData            := {|| if( !empty( ::oBrowseStock:aArrayData ), hGet( ::oBrowseStock:aArrayData[ ::oBrowseStock:nArrayAt ], "almacen" ), "" ) }
      end with

      with object ( ::oBrowseStock:AddCol() )
         :cHeader             := "Almacén"
         :nWidth              := 240
         :bStrData            := {|| if( !empty( ::oBrowseStock:aArrayData ), RetAlmacen( hGet( ::oBrowseStock:aArrayData[ ::oBrowseStock:nArrayAt ], "almacen" ) ), "" ) }
      end nWidth

      with object ( ::oBrowseStock:AddCol() )
         :cHeader             := "Prop. 1"
         :nWidth              := 70
         :bStrData            := {|| if( !empty( ::oBrowseStock:aArrayData ), hGet( ::oBrowseStock:aArrayData[ ::oBrowseStock:nArrayAt ], "valor1" ), "" ) }
      end with

      with object ( ::oBrowseStock:AddCol() )
         :cHeader             := "Prop. 2"
         :nWidth              := 70
         :bStrData            := {|| if( !empty( ::oBrowseStock:aArrayData ), hGet( ::oBrowseStock:aArrayData[ ::oBrowseStock:nArrayAt ], "valor2" ), "" ) }
      end with

      with object ( ::oBrowseStock:AddCol() )
         :cHeader             := "Lote"
         :nWidth              := 90
         :bStrData            := {|| if( !empty( ::oBrowseStock:aArrayData ), hGet( ::oBrowseStock:aArrayData[ ::oBrowseStock:nArrayAt ], "lote" ), "" ) }
      end with

      with object ( ::oBrowseStock:AddCol() )
         :cHeader             := "Unidades"
         :nWidth              := 90
         :bEditValue          := {|| if( !empty( ::oBrowseStock:aArrayData ), hGet( ::oBrowseStock:aArrayData[ ::oBrowseStock:nArrayAt ], "unidades" ), 0 ) }
         :cEditPicture        := MasUnd()
         :nFooterType         := AGGR_SUM
         :nDataStrAlign       := AL_RIGHT
         :nHeadStrAlign       := AL_RIGHT
         :nFootStrAlign       := AL_RIGHT
      end with

      REDEFINE BUTTON ;
         ID       510 ;
         OF       ::oDialog ;
         WHEN     ( nAnd( ::nLevel, ACC_APPD ) != 0 );
         ACTION   ( ::addArticulo() )

      REDEFINE BUTTON ;
         ID       520 ;
         OF       ::oDialog ;
         WHEN     ( nAnd( ::nLevel, ACC_EDIT ) != 0 );
         ACTION   ( if( !empty( ::oBrowseArticulo:aArrayData ),;
                    ( EdtArticulo( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "Codigo" ) ), ::Search() ), ) )

      REDEFINE BUTTON ;
         ID       530 ;
         OF       ::oDialog ;
         WHEN     ( nAnd( ::nLevel, ACC_APPD ) != 0 );
         ACTION   ( if( !empty( ::oBrowseArticulo:aArrayData ),;
                    ( DupArticulo( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "Codigo" ) ), ::Search() ), ) )

      REDEFINE BUTTON ;
         ID          500 ;
         OF          ::oDialog ;
         ACTION      ( ::oDialog:end( IDOK ) )

      REDEFINE BUTTON ;
         ID          550 ;
         OF          ::oDialog ;
         CANCEL ;
         ACTION      ( ::oDialog:end() )

      ::oDialog:AddFastKey( VK_F2, {|| if( nAnd( ::nLevel, ACC_APPD ) != 0, ::addArticulo(), Msginfo( "No tiene permiso para añadir" ) ) } )
      ::oDialog:AddFastKey( VK_F3, {|| if( nAnd( ::nLevel, ACC_EDIT ) != 0,;
                                       ( if( !empty( ::oBrowseArticulo:aArrayData ), EdtArticulo( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "Codigo" ) ), ), ::Search() ),;
                                       Msginfo( "No tiene permiso para modificar" ) ) } )
      
      ::oDialog:AddFastKey( VK_F5, {|| ::oDialog:end( IDOK ) } )

      ::oDialog:bStart := {|| ::oBusqueda:SetFocus(), ::oBrowseArticulo:Load(), ::oBrowseStock:Load() }

   ACTIVATE DIALOG ::oDialog CENTER

   if ::oDialog:nResult == IDOK

      if !empty( ::oBrowseArticulo:aArrayData )

         if !empty( ::oGetCodigo )
            ::oGetCodigo:cText( Padr( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "Codigo" ), 200 ) )
         end if

      end if
      
      if !empty( ::oBrowseArticulo:aArrayData )

         if !empty( ::oGetNombre )
            ::oGetNombre:cText( hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "Nombre" ) )
         end if

      end if

   end if

   CursorWE()

return ( nil )

//---------------------------------------------------------------------------//

METHOD Search() CLASS TFastBrwArt

   local cStm           := "cSearchArticulo"
   local cSql           := ""

   if Empty( ::cBusqueda )

      ::oBrowseArticulo:SetArray( {}, , , .f. )
      ::oBrowseArticulo:GoTop()
      ::oBrowseArticulo:Select(0)
      ::oBrowseArticulo:Select(1)
      ::oBrowseArticulo:Refresh()

      ::oBrowseStock:SetArray( {}, , , .f. )
      ::oBrowseStock:GoTop()
      ::oBrowseStock:Select(0)
      ::oBrowseStock:Select(1)
      ::oBrowseStock:Refresh()

      ::oBusqueda:SetFocus()
      return ( nil )

   end if

   cSql                 += ::prepareSentence()
   
   if ADSBaseModel():ExecuteSqlStatement( cSql, cStm )
      
      if !empty( ::oBrowseArticulo )
         ::oBrowseArticulo:SetArray( DBHScatter( cStm ) )
         ::oBrowseArticulo:GoTop()
         ::oBrowseArticulo:Select(0)
         ::oBrowseArticulo:Select(1)
         ::oBrowseArticulo:Refresh()
         ::oBrowseArticulo:SetFocus()
      end if

   end if

return ( nil )

//---------------------------------------------------------------------------//

METHOD prepareSentence() CLASS TFastBrwArt
   
   local cSentence   := ""

   cSentence         += "SELECT Codigo, Nombre, pCosto, pVenta1, pVenta2, pVenta3, pVenta4, pVenta5, pVenta6, pVtaIva1, pVtaIva2, pVtaIva3, pVtaIva4, pVtaIva5, pVtaIva6 FROM " + ArticulosModel():getTableName() + Space( 1 )
   cSentence         += "WHERE" + Space( 1 )
   cSentence         += "UPPER( " + ::aCampoOrden[ ::oOrden:nAt ] + " )" + Space( 1 )
   cSentence         += "LIKE" + Space( 1 )
   if ConfiguracionesEmpresaModel():getLogic( 'lBusConte', .f. )
      cSentence      += quoted( "%" + AllTrim( UPPER( ::cBusqueda ) ) + "%" ) + Space( 1 )
   else 
      cSentence      += quoted( AllTrim( UPPER( ::cBusqueda ) ) + "%" ) + Space( 1 )    
   end if
   cSentence         += "ORDER BY " + ::aCampoOrden[ ::oOrden:nAt ]

return ( cSentence )

//---------------------------------------------------------------------------//

METHOD loadStock() CLASS TFastBrwArt

   local cCodArt     := ""
   local cAliasStock

   if !empty( ::oBrowseArticulo:aArrayData )
      cCodArt        := hGet( ::oBrowseArticulo:aArrayData[ ::oBrowseArticulo:nArrayAt ], "Codigo" )
   end if

   if !Empty( cCodArt )

      cAliasStock                      := StocksModel():getSqlBrwArtStock( cCodArt )

      if !empty( ::oBrowseStock )
         ::oBrowseStock:SetArray( DBHScatter( cAliasStock ) )
      end if

   else

     ::oBrowseStock:SetArray( {}, , , .f. ) 

   end if

   if !empty( ::oBrowseStock )
      ::oBrowseStock:GoTop()
      ::oBrowseStock:Select(0)
      ::oBrowseStock:Select(1)
      ::oBrowseStock:Refresh()
   end if   

return ( nil )

//---------------------------------------------------------------------------//

METHOD addArticulo() CLASS TFastBrwArt

   ::cBusqueda := AppArticulo()
   ::oBusqueda:Refresh()
   ::Search()

return ( nil )

//---------------------------------------------------------------------------//