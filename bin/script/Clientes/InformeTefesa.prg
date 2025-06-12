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

   METHOD SelAll( lSel )

   METHOD SaveConfig()

   METHOD upElement()

   METHOD downElement()

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

   if Empty( ::cCodCliente )
      MsgStop( "Tiene que seleccionar un cliente." )
      Return .t.
   end if

   if Empty( ::cCodTarifa )
      MsgStop( "El cliente seleccionado no tiene tarifa aplicada." )
      Return .t.
   end if

   ::LoadArticulos()

   MsgInfo( hb_valToexp( ::aArticulos ) )

   if Len( ::aArticulos ) < 1
      MsgStop( "La tarifa seleccionada no tiene articulos incluidos." )
      Return .t.
   end if   

   ::SetResources()

   ::Resource()

   ::FreeResources()

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

         aAdd( ::aArticulos, {   "lSel" => ( D():TarifaPreciosLineas( ::nView ) )->lSel,;
                                 "cCodArt" => ( D():TarifaPreciosLineas( ::nView ) )->cCodArt,;
                                 "cNomArt" => ( D():TarifaPreciosLineas( ::nView ) )->cNomArt,; 
                                 "nPrcTar1" => ( D():TarifaPreciosLineas( ::nView ) )->nPrcTar1,; 
                                 "nPrcTar2" => ( D():TarifaPreciosLineas( ::nView ) )->nPrcTar2,;
                                 "cCodFam" => ArticulosModel():getField( 'Familia', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt ),;
                                 "cNomFam" => FamiliasModel():getField( 'cNomFam', 'cCodFam', ArticulosModel():getField( 'Familia', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt ) ),;
                                 "nPesoKg" => ArticulosModel():getField( 'nPesoKg', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt ),;
                                 "cUnidad" => ArticulosModel():getField( 'cUnidad', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt ),;
                                 "nIncPrc1" => ArticulosModel():getField( 'nIncPrc1', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt ),;
                                 "nIncPrc2" => ArticulosModel():getField( 'nIncPrc2', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt ),;
                                 "nIncPrc3" => ArticulosModel():getField( 'nIncPrc3', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt ),;
                                 "nUndPal" => ArticulosModel():getField( 'nUndPal', 'Codigo', ( D():TarifaPreciosLineas( ::nView ) )->cCodArt ),;
                                 "cImagen1" => cImagen1 ,;
                                 "cImagen2" => cImagen2 ,;
                                 "cImagen3" => cImagen3 ,;
                                 "cImagen4" => cImagen4 ,;
                                 "cImagen5" => cImagen5 ,;
                                 "nDtoAtp" => nDtoAtp } )

         cImagen1 := "" 
         cImagen2 := ""
         cImagen3 := ""
         cImagen4 := ""
         cImagen5 := ""

         ( D():TarifaPreciosLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ( D():TarifaPreciosLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

   aSort( ::aArticulos,,, {|x,y| hGet( x, "cNomArt" ) < hGet( y, "cNomArt" ) } )

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

   ::oBrowseArticulos:SetArray( ::aArticulos, , , .f. )

   ::oBrowseArticulos:nMarqueeStyle          := 5
   ::oBrowseArticulos:lRecordSelector        := .f.
   ::oBrowseArticulos:lHScroll               := .f.

   ::oBrowseArticulos:bLDblClick             := {|| hSet( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "lSel", !hGet( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "lSel" ) ), ::oBrowseArticulos:Refresh() }

   ::oBrowseArticulos:CreateFromResource( 200 )

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "S."
      :bEditValue       := {|| if( hhaskey( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "lSel" ), hGet( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "lSel" ), "" ) }
      :nWidth           := 20
      :SetCheck( { "Sel16", "Nil16" } )
   end with

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "Codigo"
      :bEditValue       := {|| if( hhaskey( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "cCodArt" ), hGet( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "cCodArt" ), "" ) }
      :nWidth           := 150
   end with

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "Articulo"
      :bEditValue       := {|| if( hhaskey( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "cNomArt" ), hGet( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "cNomArt" ), "" ) }
      :nWidth           := 250
   end with

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "Fabrica"
      :bEditValue       := {|| if( hhaskey( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "nPrcTar1" ), hGet( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "nPrcTar1" ), "" ) }
      :cEditPicture     := cPouDiv()
      :nWidth           := 80
   end with

   with object ( ::oBrowseArticulos:AddCol() )
      :cHeader          := "Destino"
      :bEditValue       := {|| if( hhaskey( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "nPrcTar2" ), hGet( ::aArticulos[ ::oBrowseArticulos:nArrayAt ], "nPrcTar2" ), "" ) }
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
      ACTION      ( ::upElement(), ::oBrowseArticulos:Refresh() )

   REDEFINE BUTTON ;
      ID          550 ;
      OF          ::oDialog ;
      ACTION      ( ::downElement(), ::oBrowseArticulos:Refresh() )

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

METHOD upElement() CLASS TInformeTefesa
   
   local xElement := ::aArticulos[ ::oBrowseArticulos:nArrayAt ] // Guarda el elemento a mover
   
   hb_ADel( ::aArticulos, ::oBrowseArticulos:nArrayAt, .t. ) // Elimina el elemento de su posición original
   
   hb_AIns( ::aArticulos, ::oBrowseArticulos:nArrayAt - 1, xElement, .t. ) // Inserta el elemento en la nueva posición

RETURN ( ::oBrowseArticulos:SetArray( ::aArticulos ), ::oBrowseArticulos:Select(0), ::oBrowseArticulos:Select(1) )

//---------------------------------------------------------------------------//

METHOD downElement() CLASS TInformeTefesa
   
   local xElement := ::aArticulos[ ::oBrowseArticulos:nArrayAt ] // Guarda el elemento a mover
   
   hb_ADel( ::aArticulos, ::oBrowseArticulos:nArrayAt, .t. ) // Elimina el elemento de su posición original
   
   hb_AIns( ::aArticulos, ::oBrowseArticulos:nArrayAt + 1, xElement, .t. ) // Inserta el elemento en la nueva posición

RETURN ( ::oBrowseArticulos:SetArray( ::aArticulos ), ::oBrowseArticulos:Select(0), ::oBrowseArticulos:Select(1) )

//---------------------------------------------------------------------------//

METHOD SelAll( lSel ) CLASS TInformeTefesa

   DEFAULT lSel   := .t.

   aEval( ::aArticulos, {|h| hSet( h, "lSel", lSel ) } )

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

   MsgInfo( hb_valToexp( ::aArticulos ) )

   ::oFastReport := frReportManager():New()
   
   ::oFastReport:ClearDataSets()
   
   ::oFastReport:LoadLangRes( "Spanish.Xml" )
   
   ::oFastReport:SetProperty( "Designer.DefaultFont", "Name", "Verdana")

   ::oFastReport:SetProperty( "Designer.DefaultFont", "Size", 10)
   
   ::oFastReport:SetIcon( 1 )
   
   ::VariableReport()

   ::oFastReport:SetTitle( "Dise ador de documentos" ) 
   
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
   
   ::oFastReport:SetTitle( "Dise ador de documentos" ) 
   
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
   
   ::oFastReport:SetTitle( "Dise ador de documentos" ) 

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

   ::oFastReport:setUserDataSet( "Informe",;
                                 "lSel;cCodArt;cNomArt;nPrcTar1;nPrcTar2;cCodFam;cNomFam;nPesoKg;cUnidad;nIncPrc1;nIncPrc2;nIncPrc3;nUndPal;cImagen1;cImagen2;cImagen3;cImagen4;cImagen5;nDtoAtp",;
                                 {||np := 1},;
                                 {||np := np + 1},;
                                 {||np := np - 1},;
                                 {||np > Len( ::aArticulos )},;
                                 {|key| hGet( ::aArticulos[np], key ) } )

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

   aEval( ::aArticulos, {|h| TarifasLineasModel():SaveSelTar( ::cCodTarifa, hGet( h, "cCodArt" ), hGet( h, "lSel") ) } )

Return ( .t. )

//---------------------------------------------------------------------------//