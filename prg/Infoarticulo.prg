#include "FiveWin.Ch"
#include "Factu.ch" 
#include "MesDbf.ch"

Static oInfoArticulo

//---------------------------------------------------------------------------//

Function CreateInfoArticulo()

   CloseInfoArticulo()

   if Empty( oInfoArticulo )
      if ConfiguracionesEmpresaModel():getLogic( 'lBrowseSql', .f. )
         oInfoArticulo  := TInfoClienteArticulo():Run()
      else
         oInfoArticulo  := TInfoArticulo():New()
      end if

   end if

Return nil

//---------------------------------------------------------------------------//

Function CloseInfoArticulo()

   if !ConfiguracionesEmpresaModel():getLogic( 'lBrowseSql', .f. )

      if oInfoArticulo != nil
         oInfoArticulo:CloseFiles()
      end if

   end if

   oInfoArticulo     := nil

Return nil

//---------------------------------------------------------------------------//

CLASS TInfoArticulo

   DATA oDlg

   DATA oDbfArticulo
   DATA oDbfIva
   DATA oDbfKit
   DATA oDbfDivisa
   DATA oDbfArtCode

   DATA oCodigoArticulo
   DATA oNombreArticulo
   DATA oPrecioArticulo

   METHOD New()

   METHOD OpenFiles()
   METHOD CloseFiles()

   METHOD LoadArticulo()

END CLASS

//---------------------------------------------------------------------------//

METHOD OpenFiles( cPath )

   local lOpen    := .t.
   local oBlock   := ErrorBlock( {| oError | ApoloBreak( oError ) } )

   DEFAULT cPath  := cPatEmp()

   BEGIN SEQUENCE

      DATABASE NEW ::oDbfArticulo   PATH ( cPatEmp() )   FILE "Articulo.Dbf"     VIA ( cDriver() ) SHARED INDEX "Articulo.Cdx"

      DATABASE NEW ::oDbfArtCode    PATH ( cPatEmp() )   FILE "ArtCodebar.Dbf"   VIA ( cDriver() ) SHARED INDEX "ArtCodebar.Cdx"

      DATABASE NEW ::oDbfIva        PATH ( cPatDat() )   FILE "Tiva.Dbf"         VIA ( cDriver() ) SHARED INDEX "Tiva.Cdx"

      DATABASE NEW ::oDbfDivisa     PATH ( cPatDat() )   FILE "Divisas.Dbf"      VIA ( cDriver() ) SHARED INDEX "Divisas.Cdx"

      DATABASE NEW ::oDbfKit        PATH ( cPatEmp() )   FILE "ArtKit.Dbf"       VIA ( cDriver() ) SHARED INDEX "ArtKit.Cdx"

   RECOVER

      msgStop( "Imposible abrir todas las bases de datos" )

      ::CloseFiles()

      lOpen       := .f.

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( lOpen )

//---------------------------------------------------------------------------//

/*
Cerramos ficheros
*/

METHOD CloseFiles()

   if !Empty( ::oDbfArticulo )
      ::oDbfArticulo:End()
   end if

   if !Empty( ::oDbfArtCode )
      ::oDbfArtCode:End()
   end if

   if !Empty( ::oDbfIva )
      ::oDbfIva:End()
   end if

   if !Empty( ::oDbfDivisa )
      ::oDbfDivisa:End()
   end if

   if !Empty( ::oDbfKit )
      ::oDbfKit:End()
   end if

   ::oDbfArticulo    := nil
   ::oDbfArtCode     := nil
   ::oDbfIva         := nil
   ::oDbfDivisa      := nil
   ::oDbfKit         := nil

   oInfoArticulo     := nil

Return .t.

//---------------------------------------------------------------------------//

Method New()

   local cCodigoArticulo   := Space( 18 )
   local cNombreArticulo   := Space( 100 )
   local nPrecioArticulo   := 0

   if ::OpenFiles()

      DEFINE DIALOG ::oDlg NAME "SearchArticulo"

      REDEFINE GET ::oCodigoArticulo VAR cCodigoArticulo;
         ID       100 ;
         OF       ::oDlg ;
         BITMAP   "LUPA"

         ::oCodigoArticulo:bValid   := {|| ::LoadArticulo() }
         ::oCodigoArticulo:bHelp    := {|| BrwArticulo( ::oCodigoArticulo, ::oNombreArticulo ) } 

      REDEFINE GET ::oNombreArticulo VAR cNombreArticulo ;
         ID       110 ;
         OF       ::oDlg

      REDEFINE GET ::oPrecioArticulo VAR nPrecioArticulo ;
         ID       120 ;
         PICTURE  "@E 999,999.99" ;
         OF       ::oDlg

      REDEFINE BUTTON ;
         ID       130 ;
         OF       ::oDlg ;
         ACTION   ( ::oDlg:end( IDOK ) )

      ::oDlg:bStart  := {|| ::oCodigoArticulo:SetFocus() }

      ::oDlg:Activate( , , , .t., {|| ::CloseFiles() }, .f. )

   end if

Return ( Self )

//---------------------------------------------------------------------------//

METHOD LoadArticulo()

   local cCodigoArticulo   := ::oCodigoArticulo:VarGet()

   if Empty( ::oDbfArtCode ) .or. Empty( ::oDbfArticulo )
      Return .t.
   end if

   /*
   Primero buscamos por codigos de barra
   */

   cCodigoArticulo         := cSeekCodebar( cCodigoArticulo, ::oDbfArtCode:cAlias, ::oDbfArticulo:cAlias )

   /*
   Ahora buscamos por el codigo interno
   */

   if ::oDbfArticulo:Seek( cCodigoArticulo )

      ::oCodigoArticulo:cText( cCodigoArticulo )

      if !Empty( ::oDbfArticulo:cDesTik )
         ::oNombreArticulo:cText( ::oDbfArticulo:cDesTik )
      else
         ::oNombreArticulo:cText( ::oDbfArticulo:Nombre )
      end if

      ::oPrecioArticulo:cText( nRetPreArt( 1, cDivEmp(), .t., ::oDbfArticulo:cAlias, ::oDbfDivisa:cAlias, ::oDbfKit:cAlias, ::oDbfIva:cAlias ) )

   else

      MsgStop( 'Artículo no encontrado' )

   end if

Return .t.

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TInfoClienteArticulo

   DATA oDialog
   DATA oBitmap

   DATA oCliente
   DATA cCliente

   DATA nTarifa
   DATA oRiesgo
   DATA nRiesgo

   DATA oStock
   DATA nStock

   DATA oArticulo
   DATA cArticulo

   DATA aSayPrecio
   DATA aSayPrecioIva

   DATA aSayDto

   DATA cOldCodCli

   DATA cOldCodArt

   METHOD Run()

   METHOD End() 

   METHOD Resource()

   METHOD LoadCliente()
   METHOD LoadArticulo()

END CLASS

//---------------------------------------------------------------------------//

METHOD Run() CLASS TInfoClienteArticulo

   ::aSayPrecio      := Array( 6 )
   ::aSayPrecioIva   := Array( 6 )
   ::aSayDto         := Array( 5 )
   ::cCliente        := Space( 12 )
   ::cArticulo       := Space( 18 )
   ::nTarifa         := 0
   ::nRiesgo         := 0
   ::nStock          := 0

   ::cOldCodCli      := ""
   ::cOldCodArt      := ""

   ::Resource()

   ::end()

Return ( nil )

//---------------------------------------------------------------------------//

METHOD end() CLASS TInfoClienteArticulo

   if !Empty( ::oBitmap )
      ::oBitmap:End()
   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS TInfoClienteArticulo

   CursorWait()

   DEFINE DIALOG ::oDialog RESOURCE "SEARCHPRICES" TITLE ""

      REDEFINE BITMAP ::oBitmap ;
         ID          600 ;
         RESOURCE    "gc_symbol_euro_48" ;
         TRANSPARENT ;
         OF          ::oDialog

      REDEFINE GET ::oCliente VAR ::cCliente ;
         ID          110 ;
         IDTEXT      111 ;
         BITMAP      "LUPA" ;
         OF          ::oDialog

         ::oCliente:bValid    := {|| cClient( ::oCliente, , ::oCliente:oHelpText ), ::LoadCliente() }
         ::oCliente:bHelp     := {|| BrwClient( ::oCliente, ::oCliente:oHelpText ), ::LoadCliente() }

      REDEFINE GET ::oRiesgo VAR ::nRiesgo;
         ID          120 ;
         PICTURE     cPorDiv() ;
         OF          ::oDialog
      
      REDEFINE GET ::oArticulo VAR ::cArticulo ;
         ID          130 ;
         IDTEXT      131 ;
         BITMAP      "LUPA" ;
         WHEN        ( !Empty( ::oCliente:VarGet() ) ) ;
         OF          ::oDialog

      ::oArticulo:bValid      := {|| ::LoadArticulo() }
      ::oArticulo:bHelp       := {|| FastBrwArt( ::oArticulo, ::oArticulo:oHelpText ), ::oArticulo:lValid() }

      REDEFINE SAY ::aSayPrecio[1] ID 140 OF ::oDialog
      REDEFINE SAY ::aSayPrecioIva[1] ID 141 OF ::oDialog

      REDEFINE SAY ::aSayPrecio[2] ID 150 OF ::oDialog
      REDEFINE SAY ::aSayPrecioIva[2] ID 151 OF ::oDialog

      REDEFINE SAY ::aSayPrecio[3] ID 160 OF ::oDialog
      REDEFINE SAY ::aSayPrecioIva[3] ID 161 OF ::oDialog

      REDEFINE SAY ::aSayPrecio[4] ID 170 OF ::oDialog
      REDEFINE SAY ::aSayPrecioIva[4] ID 171 OF ::oDialog

      REDEFINE SAY ::aSayPrecio[5] ID 180 OF ::oDialog
      REDEFINE SAY ::aSayPrecioIva[5] ID 181 OF ::oDialog

      REDEFINE SAY ::aSayPrecio[6] ID 190 OF ::oDialog
      REDEFINE SAY ::aSayPrecioIva[6] ID 191 OF ::oDialog

      REDEFINE SAY ::aSayDto[1] ID 210 OF ::oDialog
      REDEFINE SAY ::aSayDto[2] ID 220 OF ::oDialog
      REDEFINE SAY ::aSayDto[3] ID 230 OF ::oDialog
      REDEFINE SAY ::aSayDto[4] ID 240 OF ::oDialog
      REDEFINE SAY ::aSayDto[5] ID 250 OF ::oDialog

      REDEFINE GET ::oStock VAR ::nStock;
         ID          200 ;
         PICTURE     MasUnd() ;
         OF          ::oDialog

      REDEFINE BUTTON ;
         ID          500 ;
         OF          ::oDialog ;
         CANCEL ;
         ACTION      ( if( !Empty( ::oArticulo:VarGet() ), if( RolesModel():getRolNoVerPreciosCosto( Auth():rolUuid() ), msgStop( "No tiene permiso para ver los precios de costo" ), InfArticulo( ::oArticulo:VarGet() ) ), ) )

      REDEFINE BUTTON ;
         ID          IDCANCEL ;
         OF          ::oDialog ;
         CANCEL ;
         ACTION      ( ::oDialog:end() )

   ACTIVATE DIALOG ::oDialog CENTER

   CursorWe()

Return ( nil )

//---------------------------------------------------------------------------//

METHOD LoadCliente() CLASS TInfoClienteArticulo

   local hCliente

   if !Empty( ::oCliente:VarGet() )

      hCliente          := ClientesModel():getHash( ::oCliente:VarGet() )

      if !Empty( hCliente )

         if ::cOldCodCli != hGet( hCliente, "cod" )

            if hGet( hCliente, "lmoscom" ) .and. !Empty( hGet( hCliente, "mcoment" ) )
               MsgStop( hGet( hCliente, "mcoment" ), "Comentario cliente" )
            end if

            showClienteRiesgo( hGet( hCliente, "cod" ), hGet( hCliente, "riesgo" ),::oRiesgo )

            ::nTarifa         := hGet( hCliente, "ntarifa" )

            aeval( ::aSayPrecio, {|a| a:SetFont( oWnd():oFont ) } )
            aeval( ::aSayPrecioIva, {|a| a:SetFont( oWnd():oFont ) } )
            aeval( ::aSayDto, {|a| a:SetFont( getBoldFont() ) } )

            ::aSayPrecio[ ::nTarifa ]:SetFont( getBoldFont() )
            ::aSayPrecioIva[ ::nTarifa ]:SetFont( getBoldFont() )

            ::aSayPrecio[2]:SetFont( getBoldFont() )
            ::aSayPrecioIva[2]:SetFont( getBoldFont() )

            aeval( ::aSayPrecio, {|a| a:Refresh() } )
            aeval( ::aSayPrecioIva, {|a| a:Refresh() } )
            aeval( ::aSayDto, {|a| a:Refresh() } )

            ::cOldCodCli      := hGet( hCliente, "cod" )

         end if

      end if

   else

      ::nTarifa         := 2

   end if

   if Empty( ::oArticulo:VarGet() )
      FastBrwArt( ::oArticulo, ::oArticulo:oHelpText )
   end if
   
   ::oArticulo:Refresh()
   ::oArticulo:SetFocus()
   ::oArticulo:lValid()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD LoadArticulo() CLASS TInfoClienteArticulo

   local hArticulo
   local nTarifaAtipica := ::nTarifa

   if !Empty( ::oArticulo:VarGet() )

      hArticulo         := ArticulosModel():getHash( ::oArticulo:VarGet() )

      if !Empty( hArticulo )

         if ::cOldCodArt != hGet( hArticulo, "codigo" )

            if hGet( hArticulo, "lmoscom" ) .and. !Empty( hGet( hArticulo, "mcoment" ) )
               MsgStop( hGet( hArticulo, "mcoment" ), "Comentario artículo" )
            end if
      
            ::oArticulo:oHelpText:cText( hGet( hArticulo, "nombre" ) )

            ::aSayPrecio[1]:SetText( Trans( hGet( hArticulo, "pventa1" ), cPorDiv() ) ) 
            ::aSayPrecioIva[1]:SetText( Trans( hGet( hArticulo, "pvtaiva1" ), cPorDiv() ) )

            ::aSayPrecio[2]:SetText( Trans( hGet( hArticulo, "pventa2" ), cPorDiv() ) )
            ::aSayPrecioIva[2]:SetText( Trans( hGet( hArticulo, "pvtaiva2" ), cPorDiv() ) )

            ::aSayPrecio[3]:SetText( Trans( hGet( hArticulo, "pventa3" ), cPorDiv() ) )
            ::aSayPrecioIva[3]:SetText( Trans( hGet( hArticulo, "pvtaiva3" ), cPorDiv() ) )

            ::aSayPrecio[4]:SetText( Trans( hGet( hArticulo, "pventa4" ), cPorDiv() ) )
            ::aSayPrecioIva[4]:SetText( Trans( hGet( hArticulo, "pvtaiva4" ), cPorDiv() ) )

            ::aSayPrecio[5]:SetText( Trans( hGet( hArticulo, "pventa5" ), cPorDiv() ) )
            ::aSayPrecioIva[5]:SetText( Trans( hGet( hArticulo, "pvtaiva5" ), cPorDiv() ) )

            ::aSayPrecio[6]:SetText( Trans( hGet( hArticulo, "pventa6" ), cPorDiv() ) )
            ::aSayPrecioIva[6]:SetText( Trans( hGet( hArticulo, "pvtaiva6" ), cPorDiv() ) )


            if hGet( hArticulo, "pventa1" ) == 0
               ::aSayDto[1]:SetText( "" )
               ::aSayDto[2]:SetText( "" )
               ::aSayDto[3]:SetText( "" )
               ::aSayDto[4]:SetText( "" )
               ::aSayDto[5]:SetText( "" )
            else
               ::aSayDto[1]:SetText( "Dto: " + Trans( ( 100 - ( ( hGet( hArticulo, "pventa2" ) * 100 ) / hGet( hArticulo, "pventa1" ) ) ), "999.99" ) + "%" )
               ::aSayDto[2]:SetText( "Dto: " + Trans( ( 100 - ( ( hGet( hArticulo, "pventa3" ) * 100 ) / hGet( hArticulo, "pventa1" ) ) ), "999.99" ) + "%" )
               ::aSayDto[3]:SetText( "Dto: " + Trans( ( 100 - ( ( hGet( hArticulo, "pventa4" ) * 100 ) / hGet( hArticulo, "pventa1" ) ) ), "999.99" ) + "%" )
               ::aSayDto[4]:SetText( "Dto: " + Trans( ( 100 - ( ( hGet( hArticulo, "pventa5" ) * 100 ) / hGet( hArticulo, "pventa1" ) ) ), "999.99" ) + "%" )
               ::aSayDto[5]:SetText( "Dto: " + Trans( ( 100 - ( ( hGet( hArticulo, "pventa6" ) * 100 ) / hGet( hArticulo, "pventa1" ) ) ), "999.99" ) + "%" )
            end if


            ::nStock       := StocksModel():nGlobalStockArticulo( hGet( hArticulo, "codigo" ) )

            if ::nStock <= 0
               ::oStock:setColor( Rgb( 255, 255, 255 ), Rgb( 255, 0, 0 ) )
            else
               ::oStock:setColor( Rgb( 0, 0, 0 ), Rgb( 0, 255, 0 ) )
            end if

            ::oStock:Refresh()

            if !Empty( hGet( hArticulo, "familia" ) )

               nTarifaAtipica :=  AtipicasModel():getTarifaAtipicasFromFamilia( ::oCliente:VarGet(), hGet( hArticulo, "familia" ) )

               if nTarifaAtipica > 0 .and. nTarifaAtipica != ::nTarifa

                  do case 
                     case nTarifaAtipica == 0
                        nTarifaAtipica := 1
                     case nTarifaAtipica < 0 .or. nTarifaAtipica > 6
                        nTarifaAtipica := ::nTarifa
                  end case

               end if

            end if

            if nTarifaAtipica == 0
               nTarifaAtipica := ::nTarifa
            end if

            aeval( ::aSayPrecio, {|a| a:SetFont( oWnd():oFont ) } )
            aeval( ::aSayPrecioIva, {|a| a:SetFont( oWnd():oFont ) } )

            ::aSayPrecio[ nTarifaAtipica ]:SetFont( getBoldFont() )
            ::aSayPrecioIva[ nTarifaAtipica ]:SetFont( getBoldFont() )

            ::aSayPrecio[2]:SetFont( getBoldFont() )
            ::aSayPrecioIva[2]:SetFont( getBoldFont() )

            aeval( ::aSayPrecio, {|a| a:Refresh() } )
            aeval( ::aSayPrecioIva, {|a| a:Refresh() } )

            ::cOldCodArt      := hGet( hArticulo, "codigo" )

         end if

      end if

   end if

Return ( .t. )

//---------------------------------------------------------------------------//