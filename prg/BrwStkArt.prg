#include "FiveWin.Ch"
#include "Folder.ch"
#include "Report.ch"
#include "Label.ch"
#include "Factu.ch" 
#include "MesDbf.ch"
#include "TGraph.ch"

static oDlg

static oBmpStock
static oBmpImage

static oBrwStk
static oBrwPdt

static oText

static oMeter
static nMeter

static nView

static cTmpStock

static oTreeInfo
static oImageListInfo

//---------------------------------------------------------------------------//

function BrwStkArt( nVista )

   nView       := nVista

   if Empty( ( D():Articulos( nView ) )->Codigo )
      Return nil
   end if

   CursorWait()

   /*
   Montamos el dialogo
   */

   DEFINE DIALOG oDlg RESOURCE "ArtInfoStock" TITLE "Información stock artículo."


   REDEFINE BITMAP oBmpStock;
      ID          500 ;
      RESOURCE    "gc_package_48" ;
      TRANSPARENT ;
      OF          oDlg

   REDEFINE SAY oText VAR "Información stock artículo: " + Rtrim( ( D():Articulos( nView ) )->Codigo ) + " - " + Rtrim( ( D():Articulos( nView ) )->Nombre ) ;
      ID          400 ;
      OF          oDlg

   /*
   Imagen del artículo---------------------------------------------------------
   */

   REDEFINE IMAGE oBmpImage ;
         ID       110 ;
         OF       oDlg ;
         FILE     cFileBmpName( ( D():Articulos( nView ) )->cImagen, .t. )

      oBmpImage:SetColor( , GetSysColor( 15 ) )

      oBmpImage:bLClicked              := {|| ShowImage( oBmpImage ) }
      oBmpImage:bRClicked              := {|| ShowImage( oBmpImage ) }

   /*
   Arbol con información del producto------------------------------------------
   */

   oTreeInfo                        := TTreeView():Redefine( 120, oDlg )

   oImageListInfo                   := TImageList():New( 16, 16 )

   oImageListInfo:AddMasked( TBitmap():Define( "gc_object_cube_16" ),   Rgb( 255, 0, 255 ) )
   oImageListInfo:AddMasked( TBitmap():Define( "gc_star2_16" ),         Rgb( 255, 0, 255 ) )
   oImageListInfo:AddMasked( TBitmap():Define( "gc_calendar_16" ),      Rgb( 255, 0, 255 ) )

   /*
   Browse de stock-------------------------------------------------------------
   */

   oBrwStk                       := IXBrowse():New( oDlg )

   oBrwStk:bClrSel               := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
   oBrwStk:bClrSelFocus          := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

   oBrwStk:CreateFromResource( 300 )

   oBrwStk:lFooter               := .t.
   oBrwStk:lVScroll              := .t.
   oBrwStk:lHScroll              := .t.
   oBrwStk:nMarqueeStyle         := 6
   oBrwStk:cName                 := "Stocks en informe de articulos"

   with object ( oBrwStk:AddCol() )
      :cHeader                   := "Lote"
      :nWidth                    := 70
      :bEditValue                := {|| getTreeStkValue( oBrwStk, "lote" ) }
   end with

   with object ( oBrwStk:AddCol() )
      :cHeader                   := "Código propiedad 1"
      :nWidth                    := 50
      :bStrData                  := {|| getTreeStkValue( oBrwStk, "propiedad1" ) }
      :lHide                     := .t.
   end with

   with object ( oBrwStk:AddCol() )
      :cHeader                   := "Código propiedad 2"
      :nWidth                    := 50
      :bStrData                  := {|| getTreeStkValue( oBrwStk, "propiedad2", .f. ) }
      :lHide                     := .t.
   end with

   with object ( oBrwStk:AddCol() )
      :cHeader                   := "Valor propiedad 1"
      :nWidth                    := 50
      :bStrData                  := {|| getTreeStkValue( oBrwStk, "valor1", .f. ) }
      :lHide                     := .t.
   end with

   with object ( oBrwStk:AddCol() )
      :cHeader                   := "Valor propiedad 2"
      :nWidth                    := 50
      :bStrData                  := {|| getTreeStkValue( oBrwStk, "valor2", .f. ) }
      :lHide                     := .t.
   end with

   with object ( oBrwStk:AddCol() )
      :cHeader                   := "Nombre propiedad 1"
      :bEditValue                := {|| nombrePropiedad( getTreeStkValue( oBrwStk, "propiedad1" ), getTreeStkValue( oBrwStk, "Valor1", .f. ), nView ) }
      :nWidth                    := 60
      :lHide                     := .t.
   end with

   with object ( oBrwStk:AddCol() )
      :cHeader                   := "Nombre propiedad 2"
      :bEditValue                := {|| nombrePropiedad( getTreeStkValue( oBrwStk, "propiedad2" ), getTreeStkValue( oBrwStk, "Valor2", .f. ), nView ) }
      :nWidth                    := 60
      :lHide                     := .t.
   end with

   with object ( oBrwStk:AddCol() )
      :cHeader                   := "Unidades"
      :nWidth                    := 70
      :bEditValue                := {|| getTreeStkValue( oBrwStk, "unidades" ) }
      :cEditPicture              := MasUnd()
      :bFooter                   := {|| nFooterTree( oBrwStk, "unidades" ) }
   end with

   /*
   Browse de lo pendiente de recibir y entregar--------------------------------
   */

   oBrwPdt                       := IXBrowse():New( oDlg )

   oBrwPdt:bClrSel               := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
   oBrwPdt:bClrSelFocus          := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

   oBrwPdt:CreateFromResource( 310 )

   oBrwPdt:lFooter               := .t.
   oBrwPdt:lVScroll              := .t.
   oBrwPdt:lHScroll              := .t.
   oBrwPdt:nMarqueeStyle         := 6
   oBrwPdt:cName                 := "Pendiente en informe de articulos"

   with object ( oBrwPdt:AddCol() )
      :cHeader                   := "Recibir"
      :nWidth                    := 70
      :bEditValue                := {|| getTreeStkValue( oBrwPdt, "pdtrecibir", , .t. ) }
      :cEditPicture              := MasUnd()
      :bFooter                   := {|| nFooterTree( oBrwPdt, "pdtrecibir" ) }
   end with

   with object ( oBrwPdt:AddCol() )
      :cHeader                   := "Entregar"
      :nWidth                    := 70
      :bEditValue                := {|| getTreeStkValue( oBrwPdt, "pdtentrega", , .t. ) }
      :cEditPicture              := MasUnd()
      :bFooter                   := {|| nFooterTree( oBrwPdt, "pdtentrega" ) }
   end with
   
   /*
   Fin browse de lo pendiente de recibir y entregar--------------------------------
   */

   oMeter      := TApoloMeter():ReDefine( 200, { | u | if( pCount() == 0, nMeter, nMeter := u ) }, 10, oDlg, .f., , , .t., Rgb( 255,255,255 ), , Rgb( 128,255,0 ) )

   REDEFINE BUTTON ;
      ID       501 ;
      OF       oDlg ;
      ACTION   ( oDlg:End() )

   oDlg:bStart := {|| LoadDatos() }

   ACTIVATE DIALOG oDlg CENTER ;

   if !Empty( oBmpStock )
      oBmpStock:end()
   end if

   if !Empty( oBmpImage )
      oBmpImage:end()
   end if

return nil

//---------------------------------------------------------------------------//

Static Function LoadDatos()

   local oError
   local oBlock
   local oTree
   local oTreePdt

   oDlg:Disable()

   CursorWait()
   
   oBlock                        := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

   /*
   Información del tree--------------------------------------------------------
   */

   oTreeInfo:SetImageList( oImageListInfo )

   oTreeInfo:Add( "Fecha de creación " + Dtoc( ( D():Articulos( nView ) )->LastChg ), 2 )

   if !empty( ( D():Articulos( nView ) )->dFecChg )
      oTreeInfo:Add( "Última modificación " + Dtoc( ( D():Articulos( nView ) )->dFecChg ), 2 )
   end if

   /*
   Calculamos el stock---------------------------------------------------------
   */

   oTree                         := StocksModel():oTreeStocks( ( D():Articulos( nView ) )->Codigo, , oMeter )

   if oTree != nil

      if empty( oBrwStk:oTree )
         oBrwStk:SetTree( oTree, { "gc_navigate_minus_16", "gc_navigate_plus_16", "Nil16" } ) 
      else 
         oBrwStk:oTree           := oTree
         oBrwStk:oTreeItem       := oTree:oFirst
      end if 

   end if

   if Len( oBrwStk:aCols() ) > 0
      oBrwStk:aCols[1]:cHeader   := "Información stock"
      oBrwStk:aCols[1]:nWidth    := 700
   end if

   oBrwStk:bLDblClick            := {|| if( oBrwStk:oTreeItem != nil, ZoomDocument( oBrwStk:oTreeItem:Cargo ), ) }

   oBrwStk:Refresh()

   /*
   Cargamos el tree de pendientes----------------------------------------------
   */

   oTreePdt                      := StocksModel():oTreePendiente( ( D():Articulos( nView ) )->Codigo, , oMeter )

   if oTreePdt != nil

      if empty( oBrwPdt:oTree )
         oBrwPdt:SetTree( oTreePdt, { "gc_navigate_minus_16", "gc_navigate_plus_16", "Nil16" } ) 
      else 
         oBrwPdt:oTree           := oTreePdt
         oBrwPdt:oTreeItem       := oTreePdt:oFirst
      end if 
 
   end if

   if Len( oBrwPdt:aCols() ) > 0
      oBrwPdt:aCols[1]:cHeader   := "Pendientes"
      oBrwPdt:aCols[1]:nWidth    := 700
   end if

   oBrwPdt:bLDblClick            := {|| if( oBrwStk:oTreeItem != nil, ZoomDocument( oBrwPdt:oTreeItem:Cargo ), ) }

   oBrwPdt:Refresh()

   RECOVER USING oError
      msgStop( "Imposible cargar datos" + CRLF + ErrorMessage( oError ) )
   END SEQUENCE
   ErrorBlock( oBlock )

   CursorWE()

   oBrwStk:Load()
   oBrwStk:SetFocus()

   oBrwPdt:Load()

   if !Empty( oMeter )
      oMeter:Set( 0 )
   end if

   oDlg:Enable()

return nil

//---------------------------------------------------------------------------//

Static Function getTreeStkValue( oBrwStk, cData, lTit, lRec )

   local oItem
   local uValue
   local nUnidades            := 0

   DEFAULT cData              := "nUnidades"
   DEFAULT lTit               := .t.
   DEFAULT lRec               := .f.

   if !empty( oBrwStk:oTreeItem ) 

      if !isnil( oBrwStk:oTreeItem:oTree )

         oItem                := oBrwStk:oTreeItem:oTree:oFirst 

         while !isnil( oItem )

            if !empty( oItem:Cargo )

               uValue         := hGet( oItem:Cargo, cData ) 
               
               if isNum( uValue )
                  nUnidades   += uValue
               else
                  nUnidades   := if( lTit, uValue, "" )
               end if

            end if 
 
            if ( oItem:oNext != nil .and. oItem:oNext:nLevel == oItem:nLevel )
               oItem          := oItem:oNext
            else
               oItem          := nil 
            end if 

         end while

         if isNum( nUnidades )
            if ( nUnidades < 0 ) .and. lRec
               nUnidades         := 0
            end if
         end if

      else 

         if !Empty( oBrwStk:oTreeItem:Cargo )
            nUnidades         := hGet( oBrwStk:oTreeItem:Cargo, cData )
         end if 

      end if

   end if 

Return ( nUnidades )

//---------------------------------------------------------------------------//

Static Function nFooterTree( oBrwStk, cData )

   local oItem
   local oNode
   local nUnidades            := 0

   DEFAULT cData              := "nUnidades"

   if !Empty( oBrwStk:oTree ) 

      oItem                   := oBrwStk:oTree:oFirst 
      
      while !IsNil( oItem )

         if !IsNil( oItem:oTree )   

            oNode             := oItem:oTree:oFirst 

            while !IsNil( oNode )

               if !Empty( oNode:Cargo )
                  nUnidades   += hGet( oNode:Cargo, cData ) 
               end if 

               if ( oNode:oNext != nil .and. oNode:oNext:nLevel == oNode:nLevel )
                  oNode       := oNode:oNext
               else
                  oNode       := nil 
               end if 

            end while

         end if

         oItem                := oItem:GetNext()

      end while 

   end if 

   /*if nUnidades < 0
      nUnidades               := 0
   end if*/

Return ( nUnidades )

//---------------------------------------------------------------------------//

static function ZoomDocument( hHash )

   if Empty( hHash )
      Return ( .t. )
   end if

   if !isChar( hGet( hHash, "document" ) )
      Return ( .t. )
   end if

   do case
      case hGet( hHash, "document" ) == PED_PRV
         ZooPedPrv( hGet( hHash, "serie" ) + Padl( AllTrim( Str( hGet( hHash, "numero" ) ) ), 9 ) + hGet( hHash, "sufijo" ) )

      case hGet( hHash, "document" ) == ALB_PRV
         ZooAlbPrv( hGet( hHash, "serie" ) + Padl( AllTrim( Str( hGet( hHash, "numero" ) ) ), 9 ) + hGet( hHash, "sufijo" ) )

      case hGet( hHash, "document" ) == FAC_PRV
         ZooFacPrv( hGet( hHash, "serie" ) + Padl( AllTrim( Str( hGet( hHash, "numero" ) ) ), 9 ) + hGet( hHash, "sufijo" ) )

      case hGet( hHash, "document" ) == RCT_PRV
         ZooRctPrv( hGet( hHash, "serie" ) + Padl( AllTrim( Str( hGet( hHash, "numero" ) ) ), 9 ) + hGet( hHash, "sufijo" ) )

      case hGet( hHash, "document" ) == PED_CLI
         ZooPedCli( hGet( hHash, "serie" ) + Padl( AllTrim( Str( hGet( hHash, "numero" ) ) ), 9 ) + hGet( hHash, "sufijo" ) )

      case hGet( hHash, "document" ) == ALB_CLI
         ZooAlbCli( hGet( hHash, "serie" ) + Padl( AllTrim( Str( hGet( hHash, "numero" ) ) ), 9 ) + hGet( hHash, "sufijo" ) )

      case hGet( hHash, "document" ) == FAC_CLI
         ZooFacCli( hGet( hHash, "serie" ) + Padl( AllTrim( Str( hGet( hHash, "numero" ) ) ), 9 ) + hGet( hHash, "sufijo" ) )

      case hGet( hHash, "document" ) == FAC_REC
         ZooFacRec( hGet( hHash, "serie" ) + Padl( AllTrim( Str( hGet( hHash, "numero" ) ) ), 9 ) + hGet( hHash, "sufijo" ) )

      case hGet( hHash, "document" ) == TIK_CLI
         ZooTikCli( hGet( hHash, "serie" ) + Str( hGet( hHash, "numero" ), 10 ) + hGet( hHash, "sufijo" ) )

      case SubStr( hGet( hHash, "document" ), 1, 2 ) == MOV_ALM
         ZoomMovimientosAlmacen( Padl( AllTrim( Str( hGet( hHash, "numero" ) ) ), 9 ) + hGet( hHash, "sufijo" ) )

      case hGet( hHash, "document" ) == PRO_LIN .or. hGet( hHash, "document" ) == PRO_MAT
         ZoomProduccion( hGet( hHash, "serie" ) + Padl( AllTrim( Str( hGet( hHash, "numero" ) ) ), 9 ) + hGet( hHash, "sufijo" ) )

   end case

Return ( .t. )

//---------------------------------------------------------------------------//