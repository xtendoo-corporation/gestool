#include "FiveWin.Ch"
#include "Factu.ch"
#include "Fastreph.ch"

memvar cNombreTarifa
memvar cNombreCliente

//---------------------------------------------------------------------------//  

Function InformeTefesa( nView )                  
         
   local oInforme    := TInformeTefesa():New( nView )

   oInforme:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TInformeTefesa

   DATA oDialog
   DATA nView

   DATA cNameFr

   DATA oFastReport

   DATA cCodCliente
   DATA cNomCliente
   DATA oCliente
   DATA cCliente

   DATA cCodTarifa
   DATA cNomTarifa
   DATA oTarifa
   DATA cTarifa

   DATA cDirectorio
   DATA oDirectorio

   DATA oBrowseArticulos
   DATA aArticulos

   DATA cTmpLin
   DATA dbfTmpLin

   METHOD New()

   METHOD Run()

   METHOD SetResources()      INLINE ( SetResources( fullcurdir() + "Script\Clientes\InformeTefesa.dll" ) )

   METHOD FreeResources()     INLINE ( FreeResources() )

   METHOD Resource() 

   METHOD Process()

   METHOD LoadArticulos()

   METHOD printReport()
      METHOD createReport()
      METHOD designReport()
      METHOD DataReport()
      METHOD VariableReport()

   METHOD Sel()

   METHOD SelAll( lSel )

   METHOD SaveConfig()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView ) CLASS TInformeTefesa

   ::nView                 := nView

   ::cCodCliente           := ( D():Clientes( nView ) )->Cod
   ::cNomCliente           := ( D():Clientes( nView ) )->Titulo
   ::cCliente              := AllTrim( ::cCodCliente ) + " - " + AllTrim( ::cNomCliente )
   ::cCodTarifa            := ( D():Clientes( nView ) )->cCodTar
   ::cNomTarifa            := TarifasModel():getName( ( D():Clientes( nView ) )->cCodTar )
   ::cTarifa               := AllTrim( ::cCodTarifa ) + " - " + AllTrim( ::cNomTarifa )

   ::aArticulos            := {}

   ::cNameFr               := fullcurdir() + "Script\Clientes\InformeTefesa.fr3"

   ::cDirectorio           := fullcurdir() + "Script\Clientes\PDF\"

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run() CLASS TInformeTefesa

   local cDbfLin  := "TemporalScript"

   if Empty( ::cCodCliente )
      MsgStop( "Tiene que seleccionar un cliente." )
      Return .t.
   end if

   if Empty( ::cCodTarifa )
      MsgStop( "El cliente seleccionado no tiene tarifa aplicada." )
      Return .t.
   end if

   /*Creamos una dbfTemporal*/

   ::cTmpLin        := cGetNewFileName( cPatTmp() + cDbfLin )

   dbCreate( ::cTmpLin, aSqlStruct( aItmTemporal() ), cLocalDriver() )
   dbUseArea( .t., cLocalDriver(), ::cTmpLin, cCheckArea( cDbfLin, @::dbfTmpLin ), .f. )

   if !NetErr() .and. ( ::dbfTmpLin )->( Used() )
      ( ::dbfTmpLin )->( OrdCondSet( "!Deleted()", {|| !Deleted() } ) )
      ( ::dbfTmpLin )->( OrdCreate( ::cTmpLin, "nPosPrint", "nPosPrint", {|| Field->nPosPrint } ) )
   end if

   ::LoadArticulos()

   if ( ::dbfTmpLin )->( RecCount() ) <= 0
      MsgStop( "La tarifa seleccionada no tiene articulos incluidos." )
      Return .t.
   end if

   ::SetResources()

   ::Resource()

   ::FreeResources()

   /*Eliminamos la tabla temporal*/

   if !empty( ::dbfTmpLin ) .and. ( ::dbfTmpLin )->( Used() )
      ( ::dbfTmpLin )->( dbCloseArea() )
   end if
   
   ::dbfTmpLin      := nil
   
   dbfErase( ::cTmpLin )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD LoadArticulos()

   local nOrdAnt  := ( D():TarifaPreciosLineas( ::nView ) )->( OrdSetFocus( "CCODTAR" ) )
   local aImages  := {}
   local cImagen1 := "" 
   local cImagen2 := ""
   local cImagen3 := ""
   local cImagen4 := ""
   local cImagen5 := ""
   local nDtoAtp  := 0
   local nCount   := 1
    
   ::aArticulos   := {}

   ( D():TarifaPreciosLineas( ::nView ) )->( dbGoTop() )

   if ( D():TarifaPreciosLineas( ::nView ) )->( dbSeek( ::cCodTarifa ) )

      while ( D():TarifaPreciosLineas( ::nView ) )->cCodTar == ::cCodTarifa .and. !( D():TarifaPreciosLineas( ::nView ) )->( Eof() )

         /*Cargo las imagenes*/

         aImages      := ArticulosImagenesModel():getList( ( D():TarifaPreciosLineas( ::nView ) )->cCodArt )

         if len( aImages ) > 0

            for n := 1 to len( aImages )

               do case 
                  case n == 1
                     cImagen1 := AllTrim( hGet( aImages[n], "CIMGART" ) )
                  case n == 2
                     cImagen2 := AllTrim( hGet( aImages[n], "CIMGART" ) )
                  case n == 3
                     cImagen3 := AllTrim( hGet( aImages[n], "CIMGART" ) )
                  case n == 4
                     cImagen4 := AllTrim( hGet( aImages[n], "CIMGART" ) )
                  case n == 5
                     cImagen5 := AllTrim( hGet( aImages[n], "CIMGART" ) )
               end case

            next

         end if

         /*Descuento atipico*/

         nDtoAtp := AtipicasModel():getDtoFromClienteArticulo( ::cCodCliente, ( D():TarifaPreciosLineas( ::nView ) )->cCodArt )

         /*Cargo las datos de articulos*/

         if ( ::dbfTmpLin )->( Used() )

            ( ::dbfTmpLin )->( dbAppend() )

            if ( D():TarifaPreciosLineas( ::nView ) )->nPosPrint == 0
               ( ::dbfTmpLin )->nPosPrint := nCount
            else
               ( ::dbfTmpLin )->nPosPrint := ( D():TarifaPreciosLineas( ::nView ) )->nPosPrint
            end if
            
            ( ::dbfTmpLin )->lSel      := ( D():TarifaPreciosLineas( ::nView ) )->lSel
            ( ::dbfTmpLin )->cCodArt   := ( D():TarifaPreciosLineas( ::nView ) )->cCodArt
            ( ::dbfTmpLin )->cNomArt   := ( D():TarifaPreciosLineas( ::nView ) )->cNomArt
            ( ::dbfTmpLin )->nPrcTar1  := ( D():TarifaPreciosLineas( ::nView ) )->nPrcTar1
            ( ::dbfTmpLin )->nPrcTar2  := ( D():TarifaPreciosLineas( ::nView ) )->nPrcTar2
            ( ::dbfTmpLin )->cCodFam   := ArticulosModel():getField( 'Familia', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt )
            ( ::dbfTmpLin )->cNomFam   := FamiliasModel():getField( 'cNomFam', 'cCodFam', ArticulosModel():getField( 'Familia', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt ) )
            ( ::dbfTmpLin )->cCodFab   := ArticulosModel():getField( 'cCodFab', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt )
            ( ::dbfTmpLin )->cNomFab   := FabricantesModel():getField( 'cNomFab', 'cCodFab', ArticulosModel():getField( 'cCodFab', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt ) )
            ( ::dbfTmpLin )->nPesoKg   := ArticulosModel():getField( 'nPesoKg', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt )
            ( ::dbfTmpLin )->cUnidad   := ArticulosModel():getField( 'cUnidad', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt )
            ( ::dbfTmpLin )->nIncPrc1  := ArticulosModel():getField( 'nIncPrc1', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt )
            ( ::dbfTmpLin )->nIncPrc2  := ArticulosModel():getField( 'nIncPrc2', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt )
            ( ::dbfTmpLin )->nIncPrc3  := ArticulosModel():getField( 'nIncPrc3', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt )
            ( ::dbfTmpLin )->nUndPal   := ArticulosModel():getField( 'nUndPal', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt )
            ( ::dbfTmpLin )->cImagen1  := cImagen1 
            ( ::dbfTmpLin )->cImagen2  := cImagen2 
            ( ::dbfTmpLin )->cImagen3  := cImagen3 
            ( ::dbfTmpLin )->cImagen4  := cImagen4 
            ( ::dbfTmpLin )->cImagen5  := cImagen5 
            ( ::dbfTmpLin )->nDtoAtp   := nDtoAtp

         end if

         cImagen1 := "" 
         cImagen2 := ""
         cImagen3 := ""
         cImagen4 := ""
         cImagen5 := ""
         nCount++

         ( D():TarifaPreciosLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ( D():TarifaPreciosLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

   ( ::dbfTmpLin )->( dbGoTop() )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS TInformeTefesa

   DEFINE DIALOG ::oDialog RESOURCE "INFORME" 

   REDEFINE GET ::oCliente VAR ::cCliente ;
      ID       100 ;
      WHEN     ( .f. ) ;
      OF       ::oDialog

   REDEFINE GET ::oTarifa VAR ::cTarifa ;
      ID       110 ;
      WHEN     ( .f. ) ;
      OF       ::oDialog

   REDEFINE GET ::oDirectorio VAR ::cDirectorio ;
      ID       120 ;
      WHEN     ( .f. ) ;
      OF       ::oDialog

   ::oBrowseArticulos                        := IXBrowse():New( ::oDialog )

   ::oBrowseArticulos:bClrSel                := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
   ::oBrowseArticulos:bClrSelFocus           := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

   //::oBrowseArticulos:SetArray( ::aArticulos, , , .f. )

   ::oBrowseArticulos:cAlias                 := ::dbfTmpLin

   ::oBrowseArticulos:nMarqueeStyle          := 5
   ::oBrowseArticulos:lRecordSelector        := .f.
   ::oBrowseArticulos:lHScroll               := .f.

   ::oBrowseArticulos:bLDblClick             := {|| ::Sel() }

   ::oBrowseArticulos:CreateFromResource( 200 )

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "S."
      :bEditValue       := {|| ( ::dbfTmpLin )->lSel }
      :nWidth           := 20
      :SetCheck( { "Sel16", "Nil16" } )
   end with

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "Pos"
      :bEditValue       := {|| ( ::dbfTmpLin )->nPosPrint }
      :nWidth           := 40
   end with

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "Codigo"
      :bEditValue       := {|| ( ::dbfTmpLin )->cCodArt }
      :nWidth           := 150
   end with

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "Articulo"
      :bEditValue       := {|| ( ::dbfTmpLin )->cNomArt }
      :nWidth           := 250
   end with

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "Fabrica"
      :bEditValue       := {|| ( ::dbfTmpLin )->nPrcTar1 }
      :cEditPicture     := cPouDiv()
      :nWidth           := 80
   end with

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "Destino"
      :bEditValue       := {|| ( ::dbfTmpLin )->nPrcTar2 }
      :cEditPicture     := cPouDiv()
      :nWidth           := 80
   end with

   REDEFINE BUTTON ;
      ID          500 ;
      OF          ::oDialog ;
      ACTION      ( ::designReport() )

   REDEFINE BUTTON ;
      ID          510 ;
      OF          ::oDialog ;
      ACTION      ( ::SelAll( .t. ) )

   REDEFINE BUTTON ;
      ID          520 ;
      OF          ::oDialog ;
      ACTION      ( ::SelAll( .f. ) )

   REDEFINE BUTTON ;
      ID          530 ;
      OF          ::oDialog ;
      ACTION      ( ::SaveConfig(), MsgInfo( "Configuracion guardada con exito" ) )

   REDEFINE BUTTON ;
      ID          540 ;
      OF          ::oDialog ;
      ACTION      ( lineUp( ::dbfTmpLin, ::oBrowseArticulos ) )

   REDEFINE BUTTON ;
      ID          550 ;
      OF          ::oDialog ;
      ACTION      ( LineDown( ::dbfTmpLin, ::oBrowseArticulos ) )

   REDEFINE BUTTON ;
      ID          IDOK ;
      OF          ::oDialog ;
      ACTION      ( ::Process(), ::SaveConfig() )

   REDEFINE BUTTON ;
      ID          IDCANCEL ;
      OF          ::oDialog ;
      ACTION      ( ::SaveConfig(), ::oDialog:End( IDCANCEL ) )

   ::oDialog:AddFastKey( VK_F5, {|| ::Process() } )

   ACTIVATE DIALOG ::oDialog CENTER

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD Sel() CLASS TInformeTefesa

   if dbLock( ::dbfTmpLin )
      ( ::dbfTmpLin )->lSel := !( ::dbfTmpLin )->lSel
      ( ::dbfTmpLin )->( dbUnLock() )
   end if

   ::oBrowseArticulos:Refresh()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD SelAll( lSel ) CLASS TInformeTefesa

   DEFAULT lSel   := .t.

   nRec           := ( ::dbfTmpLin )->( Recno() )

   ( ::dbfTmpLin )->( dbGoTop() )
   
   while !( ::dbfTmpLin )->( Eof() )

      if dbLock( ::dbfTmpLin )
         ( ::dbfTmpLin )->lSel := lSel
         ( ::dbfTmpLin )->( dbUnLock() )
      end if

      ( ::dbfTmpLin )->( dbSkip() )

   end while

   ( ::dbfTmpLin )->( dbGoTo( nRec ) )

   ::oBrowseArticulos:Refresh()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD Process() CLASS TInformeTefesa

   //::CreateReport()

   ::printReport()

   ::oDialog:End( IDOK )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD printReport() CLASS TInformeTefesa

   ::oFastReport := frReportManager():New()
   
   ::oFastReport:ClearDataSets()
   
   ::oFastReport:LoadLangRes( "Spanish.Xml" )
   
   ::oFastReport:SetProperty( "Designer.DefaultFont", "Name", "Verdana")

   ::oFastReport:SetProperty( "Designer.DefaultFont", "Size", 10)
   
   ::oFastReport:SetIcon( 1 )
   
   ::VariableReport()

   ::oFastReport:SetTitle( "Diseñador de documentos" ) 
   
   ::DataReport()

   ::oFastReport:loadFromFile( ::cNameFr )

   ::oFastReport:PrepareReport()

   ::oFastReport:SetProperty(  "PDFExport", "ShowDialog",       .f. )
   ::oFastReport:SetProperty(  "PDFExport", "DefaultPath",      AllTrim( ::cDirectorio ) )
   ::oFastReport:SetProperty(  "PDFExport", "FileName",         'TARIFA ' + AllTrim( ::cCodCliente ) + " - " + AllTrim( ::cNomCliente ) + trimedSeconds() + '.pdf' )
   ::oFastReport:SetProperty(  "PDFExport", "EmbeddedFonts",    .t. )
   ::oFastReport:SetProperty(  "PDFExport", "PrintOptimized",   .t. )
   ::oFastReport:SetProperty(  "PDFExport", "Outline",          .t. )
   ::oFastReport:SetProperty(  "PDFExport", "OpenAfterExport",  .f. )
   ::oFastReport:DoExport(     "PDFExport" )

   ::oFastReport:destroyFr()

   ::oFastReport := nil

   shellExecute( 0, "open", ( AllTrim( ::cDirectorio ) ), , , 1 )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD designReport() CLASS TInformeTefesa

   ::oFastReport := frReportManager():New()
   
   ::oFastReport:ClearDataSets()
   
   ::oFastReport:LoadLangRes( "Spanish.Xml" )
   
   ::oFastReport:SetProperty( "Designer.DefaultFont", "Name", "Verdana")

   ::oFastReport:SetProperty( "Designer.DefaultFont", "Size", 10)
   
   ::oFastReport:SetIcon( 1 )

   ::VariableReport()
   
   ::oFastReport:SetTitle( "Diseñador de documentos" ) 
   
   ::DataReport()

   ::oFastReport:loadFromFile( ::cNameFr )

   ::oFastReport:DesignReport()

   ::oFastReport:destroyFr()

   ::oFastReport := nil

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD CreateReport() CLASS TInformeTefesa

   ::oFastReport := frReportManager():New()
   
   ::oFastReport:ClearDataSets()
   
   ::oFastReport:LoadLangRes( "Spanish.Xml" )
   
   ::oFastReport:SetProperty( "Designer.DefaultFont", "Name", "Verdana")

   ::oFastReport:SetProperty( "Designer.DefaultFont", "Size", 10)
   
   ::oFastReport:SetIcon( 1 )
   
   ::oFastReport:SetTitle( "Diseñador de documentos" ) 

   ::oFastReport:SetProperty(     "Report",            "ScriptLanguage",   "PascalScript" )

   ::oFastReport:AddPage(         "MainPage" )

   ::oFastReport:AddBand(         "CabeceraDocumento", "MainPage",         frxPageHeader )
   ::oFastReport:SetProperty(     "CabeceraDocumento", "Top",              0 )
   ::oFastReport:SetProperty(     "CabeceraDocumento", "Height",           100 )

   ::oFastReport:AddBand(         "MasterData",        "MainPage",         frxMasterData )
   ::oFastReport:SetProperty(     "MasterData",        "Top",              100 )
   ::oFastReport:SetProperty(     "MasterData",        "Height",           100 )
   ::oFastReport:SetProperty(     "MasterData",        "StartNewPage",     .t. )

   ::oFastReport:AddBand(         "DetalleColumnas",   "MainPage",         frxDetailData  )
   ::oFastReport:SetProperty(     "DetalleColumnas",   "Top",              230 )
   ::oFastReport:SetProperty(     "DetalleColumnas",   "Height",           28 )
   ::oFastReport:SetProperty(     "DetalleColumnas",   "OnMasterDetail",   "DetalleOnMasterDetail" )

   ::oFastReport:AddBand(         "PieDocumento",      "MainPage",         frxPageFooter )
   ::oFastReport:SetProperty(     "PieDocumento",      "Top",              930 )
   ::oFastReport:SetProperty(     "PieDocumento",      "Height",           100 )

   ::oFastReport:SaveToFile( ::cNameFr )

   ::oFastReport:destroyFr()

   ::oFastReport := nil

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD DataReport() CLASS TInformeTefesa

   local np

   ::oFastReport:SetWorkArea(     "Informe", ( ::dbfTmpLin )->( Select() ) )
   ::oFastReport:SetFieldAliases( "Informe", cItemsToReport( aItmTemporal() ) )

   /*::oFastReport:setUserDataSet( "Informe",;
                                 "lSel;cCodArt;cNomArt;nPrcTar1;nPrcTar2;cCodFam;cNomFam;cCodFab;cNomFab;nPesoKg;cUnidad;nIncPrc1;nIncPrc2;nIncPrc3;nUndPal;cImagen1;cImagen2;cImagen3;cImagen4;cImagen5;nDtoAtp",;
                                 {||np := 1},;
                                 {||np := np + 1},;
                                 {||np := np - 1},;
                                 {||np > Len( ::aArticulos )},;
                                 {|key| hGet( ::aArticulos[np], key ) } )*/

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD VariableReport() CLASS TInformeTefesa

   public cNombreCliente                := ::cNomCliente
   public cNombreTarifa                 := ::cNomTarifa

   ::oFastReport:AddVariable(     "Informe", "Nombre tarifa",                "GetHbVar('cNombreTarifa')" ) 
   ::oFastReport:AddVariable(     "Informe", "Nombre cliente",               "GetHbVar('cNombreCliente')" )     

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD SaveConfig() CLASS TInformeTefesa

   local nRec           := ( ::dbfTmpLin )->( Recno() )

   ( ::dbfTmpLin )->( dbGoTop() )
   
   while !( ::dbfTmpLin )->( Eof() )

      TarifasLineasModel():SaveSelTar( ::cCodTarifa, ( ::dbfTmpLin )->cCodArt, ( ::dbfTmpLin )->lSel, ( ::dbfTmpLin )->nPosPrint )

      ( ::dbfTmpLin )->( dbSkip() )

   end while

   ( ::dbfTmpLin )->( dbGoTo( nRec ) )


Return ( .t. )

//---------------------------------------------------------------------------//

function aItmTemporal()

   local aItmTemporal  := {}

   aAdd( aItmTemporal, {"nPosPrint"    ,"N", 16, 6, "Posición impresion" ,    "", "( cDbf )" } )
   aAdd( aItmTemporal, {"lSel"         ,"L",  1, 0, "Selecionado" ,           "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cCodArt"      ,"C", 18, 0, "Código articulo" ,       "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cNomArt"      ,"C",150, 0, "Nombre articulo" ,       "", "( cDbf )" } )
   aAdd( aItmTemporal, {"nPrcTar1"     ,"N", 16, 6, "Precio 1" ,              "", "( cDbf )" } )
   aAdd( aItmTemporal, {"nPrcTar2"     ,"N", 16, 6, "Precio 2" ,              "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cCodFam"      ,"C", 10, 0, "Codigo familia" ,        "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cNomFam"      ,"C",150, 0, "Nombre familia" ,        "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cCodFab"      ,"C", 10, 0, "Codigo fabricante" ,     "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cNomFab"      ,"C",150, 0, "Nombre fabricante" ,     "", "( cDbf )" } )
   aAdd( aItmTemporal, {"nPesoKg"      ,"N", 16, 6, "Peso" ,                  "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cUnidad"      ,"C",  1, 0, "Unidad" ,                "", "( cDbf )" } )
   aAdd( aItmTemporal, {"nIncPrc1"     ,"N", 16, 6, "Incremento 1" ,          "", "( cDbf )" } )
   aAdd( aItmTemporal, {"nIncPrc2"     ,"N", 16, 6, "Incremento 2" ,          "", "( cDbf )" } )
   aAdd( aItmTemporal, {"nIncPrc3"     ,"N", 16, 6, "Incremento 3" ,          "", "( cDbf )" } )
   aAdd( aItmTemporal, {"nUndPal"      ,"N", 16, 6, "Unidad palet" ,          "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cImagen1"     ,"C",200, 0, "Imagen 1" ,              "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cImagen2"     ,"C",200, 0, "Imagen 2" ,              "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cImagen3"     ,"C",200, 0, "Imagen 3" ,              "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cImagen4"     ,"C",200, 0, "Imagen 4" ,              "", "( cDbf )" } )
   aAdd( aItmTemporal, {"cImagen5"     ,"C",200, 0, "Imagen 5" ,              "", "( cDbf )" } )
   aAdd( aItmTemporal, {"nDtoAtp"      ,"N", 16, 6, "Descuento" ,             "", "( cDbf )" } )

RETURN ( aItmTemporal )

//---------------------------------------------------------------------------//