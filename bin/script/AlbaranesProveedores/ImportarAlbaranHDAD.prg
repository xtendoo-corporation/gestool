/*
COLUMNA A---------Ref Hdad
COLUMNA B---------Descripción
COLUMNA C---------Cantidad
COLUMNA D---------Precio (€/ud)
COLUMNA E---------Importe (€)
COLUMNA F---------PVP
COLUMNA G---------Importe (€)
COLUMNA H---------FAMILIA
COLUMNA I---------FAM DESC
*/

#include "FiveWin.Ch"

#include "Hbxml.ch"
#include "Hbclass.ch"
#include "Fileio.ch"
#include "Factu.ch" 
      
//---------------------------------------------------------------------------//

Function ImportarExcelAlbaranes( nView, oWndBrw )                	 
	      
   local oImportarExcel    := TImportarExcelAlbaranes():New( nView, oWndBrw )

   oImportarExcel:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TImportarExcelAlbaranes FROM TImportarExcel

   DATA nView
   DATA oWndBrw

   DATA oDialog

   DATA oExcel

   DATA oFicheroExcel
   DATA cFicheroExcel

   DATA oCodigoProveedor
   DATA cCodigoProveedor

   DATA oCodigoAlmacen
   DATA cCodigoAlmacen

   DATA aLineasPedido

   DATA cSerieAlbaran
   DATA cNumeroAlbaran
   DATA cSufijoAlbaran

   DATA dFechaAlbaran
   DATA cHoraAlbaran

   DATA nNumeroHojas

   METHOD New()

   METHOD Run()

   METHOD SetResources()      INLINE ( SetResources( fullcurdir() + "Script\AlbaranesProveedores\ImportarAlbaranHDAD.dll" ) )

   METHOD FreeResources()     INLINE ( FreeResources() )

   METHOD Resource()

   METHOD Process()
   METHOD lValidProcess()

   METHOD addCabecera()
   METHOD addLineas()
   METHOD addLine( hLine )
   METHOD addProduct( hLine )
   METHOD addFamilia( hLine )
   METHOD recalculaTotales()

   METHOD procesaFicheroExcel()
   METHOD procesaLinea()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView, oWndBrw )

   ::nView                    := nView
   ::oWndBrw                  := oWndBrw

   ::aLineasPedido            := {}

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run()

   ::SetResources()

   ::Resource()

   ::FreeResources()

   if !Empty( ::oWndBrw )
      ::oWndBrw:Refresh()
   end if

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD Resource()

   DEFINE DIALOG ::oDialog RESOURCE "INFORME" 

   REDEFINE GET ::oCodigoProveedor VAR ::cCodigoProveedor ;
      ID       100 ;
      IDTEXT   110 ;   
      BITMAP   "LUPA" ;
      OF       ::oDialog

   ::oCodigoProveedor:bHelp   := {|| BrwProvee( ::oCodigoProveedor, ::oCodigoProveedor:oHelpText, .f. ) }
   ::oCodigoProveedor:bValid  := {|| cProvee( ::oCodigoProveedor, D():Proveedores( ::nView ), ::oCodigoProveedor:oHelpText ) }

   REDEFINE GET ::oCodigoAlmacen VAR ::cCodigoAlmacen ;
      ID       130 ;
      IDTEXT   140 ;   
      BITMAP   "LUPA" ;
      OF       ::oDialog

   ::oCodigoAlmacen:bHelp   := {|| BrwAlmacen( ::oCodigoAlmacen, ::oCodigoAlmacen:oHelpText, .f. ) }
   ::oCodigoAlmacen:bValid  := {|| cAlmacen( ::oCodigoAlmacen, D():Almacen( ::nView ), ::oCodigoAlmacen:oHelpText ) }

   REDEFINE GET ::oFicheroExcel VAR ::cFicheroExcel ;
      ID       120 ;
      BITMAP   "LUPA" ;
      OF       ::oDialog ;

   ::oFicheroExcel:bHelp      := {|| ::oFicheroExcel:cText( cGetFile( "Excel ( *Xls, *.Xlsx ) |*Xls;*.Xlsx", "Seleccione la hoja de calculo" ) ) }

   REDEFINE BUTTON ;
      ID          IDOK ;
      OF          ::oDialog ;
      ACTION      ( ::Process() )

   REDEFINE BUTTON ;
      ID          IDCANCEL ;
      OF          ::oDialog ;
      ACTION      ( ::oDialog:End( IDCANCEL ) )

   ::oDialog:AddFastKey( VK_F5, {|| ::Process() } )

   ACTIVATE DIALOG ::oDialog CENTER

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD lValidProcess()

   if Empty( ::cCodigoProveedor )
      MsgStop( "Tiene que seleccionar un proveedor" )
      ::oCodigoProveedor:SetFocus()
      Return ( .f. )
   end if

   if Empty( ::cCodigoAlmacen )
      MsgStop( "Tiene que seleccionar un almacen" )
      ::oCodigoAlmacen:SetFocus()
      Return ( .f. )
   end if

   if !file( ::cFicheroExcel )
      msgStop( "Fichero erroneo" )
      ::oFicheroExcel:SetFocus()
      Return ( .f. )
   end if 

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD Process()

   if !::lValidProcess()
      Return .f.
   end if

   msgrun( "Procesando fichero " + ::cFicheroExcel, "Espere por favor...",  {|| ::procesaFicheroExcel() } )

   if Len( ::aLineasPedido ) == 0
      MsgInfo( "No existen lineas que importar en el fichero indicado" )
      ::oDialog:End( IDOK )
      Return .f.
   end if

   ::addCabecera()

   ::addLineas()

   ::RecalculaTotales()

   msginfo( "Proceso finalizado" )

   ::oDialog:End( IDOK )

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD procesaFicheroExcel()

   ::oExcel                      := TOleExcel():New( "Importando hoja de excel", "Conectando...", .f. )

   ::oExcel:oExcel:Visible       := .f.
   ::oExcel:oExcel:DisplayAlerts := .f.
   ::oExcel:oExcel:WorkBooks:Open( ::cFicheroExcel )
   ::oExcel:oExcel:WorkSheets( 1 ):Activate()

   ::procesaLinea()

   ::oExcel:oExcel:Quit()
   ::oExcel:oExcel:DisplayAlerts := .t.
   ::oExcel:End()

Return nil

//---------------------------------------------------------------------------//

METHOD procesaLinea()

   local n
   local cCodArt
   local cCodBar
   local hLine    := {=>}
   local nPos

   for n := 2 to 65536

      cCodArt     := cValToChar( ::oExcel:oExcel:ActiveSheet:Range( "A" + lTrim( str( n ) ) ):Value )
         
      if !empty( cCodArt )

         /*
         Código artículo-------------------------------------------------------
         */

         nPos           := at( ".", cCodArt )
         if nPos != 0
            cCodArt     := SubStr( cCodArt, 1, nPos - 1 )
         end if
         hSet( hLine, "CodigoArticulo", Padr( cCodArt, 18 ) )

         /*
         Nombre artículo-------------------------------------------------------
         */

         hSet( hLine, "NombreArticulo", cValToChar( ::oExcel:oExcel:ActiveSheet:Range( "B" + lTrim( str( n ) ) ):Value ) )

         /*
         Unidades compradas----------------------------------------------------
         */

         hSet( hLine, "Unidades", ::oExcel:oExcel:ActiveSheet:Range( "C" + lTrim( str( n ) ) ):Value )

         /*
         PVP-------------------------------------------------------------------
         */

         hSet( hLine, "PVenta", ::oExcel:oExcel:ActiveSheet:Range( "F" + lTrim( str( n ) ) ):Value )

         /*
         Costo-----------------------------------------------------------------
         */

         hSet( hLine, "PCosto", ::oExcel:oExcel:ActiveSheet:Range( "D" + lTrim( str( n ) ) ):Value )

         /*
         Familia---------------------------------------------------------------
         */

         hSet( hLine, "Familia", ::oExcel:oExcel:ActiveSheet:Range( "H" + lTrim( str( n ) ) ):Value )
         hSet( hLine, "cNomFamilia", ::oExcel:oExcel:ActiveSheet:Range( "I" + lTrim( str( n ) ) ):Value )

         aAdd( ::aLineasPedido, hLine )

      else

         exit

      end if

      hLine     := {=>}

   next

Return nil

//---------------------------------------------------------------------------//

METHOD addCabecera()

   ::cSerieAlbaran      := cNewSer( "nAlbPrv", D():Contadores( ::nView ) )
   ::cNumeroAlbaran     := nNewDoc( ::cSerieAlbaran, D():AlbaranesProveedores( ::nView ), "NALBPRV", , D():Contadores( ::nView ) )
   ::cSufijoAlbaran     := Application():CodigoDelegacion()
   ::dFechaAlbaran      := getSysDate()
   ::cHoraAlbaran       := getSysTime()

   ( D():AlbaranesProveedores( ::nView ) )->( dbAppend() )

   ( D():AlbaranesProveedores( ::nView ) )->CSERALB       := ::cSerieAlbaran
   ( D():AlbaranesProveedores( ::nView ) )->NNUMALB       := ::cNumeroAlbaran
   ( D():AlbaranesProveedores( ::nView ) )->CSUFALB       := ::cSufijoAlbaran
   ( D():AlbaranesProveedores( ::nView ) )->CTURALB       := cCurSesion()
   ( D():AlbaranesProveedores( ::nView ) )->DFECALB       := ::dFechaAlbaran
   ( D():AlbaranesProveedores( ::nView ) )->tFecALB       := ::cHoraAlbaran
   ( D():AlbaranesProveedores( ::nView ) )->CCODALM       := ::cCodigoAlmacen
   ( D():AlbaranesProveedores( ::nView ) )->CCODCAJ       := Application():CodigoCaja()
   ( D():AlbaranesProveedores( ::nView ) )->CDTOESP       := "General"
   ( D():AlbaranesProveedores( ::nView ) )->CDPP          := "Pronto pago"
   ( D():AlbaranesProveedores( ::nView ) )->CDIVALB       := cDivEmp()
   ( D():AlbaranesProveedores( ::nView ) )->NVDVALB       := nChgDiv( cDivEmp(), D():Divisas( ::nView ) )
   ( D():AlbaranesProveedores( ::nView ) )->CCODUSR       := Auth():Codigo()
   ( D():AlbaranesProveedores( ::nView ) )->cCodDlg       := ::cSufijoAlbaran
   ( D():AlbaranesProveedores( ::nView ) )->lFacturado    := .f.
   ( D():AlbaranesProveedores( ::nView ) )->nFacturado    := 1  

   ( D():AlbaranesProveedores( ::nView ) )->CCODPRV       := ::cCodigoProveedor 

   if ( D():Proveedores( ::nView ) )->( dbSeek( ::cCodigoProveedor  ) )
      ( D():AlbaranesProveedores( ::nView ) )->CNOMPRV    := ( D():Proveedores( ::nView ) )->Titulo
      ( D():AlbaranesProveedores( ::nView ) )->CDIRPRV    := ( D():Proveedores( ::nView ) )->Domicilio
      ( D():AlbaranesProveedores( ::nView ) )->CPOBPRV    := ( D():Proveedores( ::nView ) )->Poblacion
      ( D():AlbaranesProveedores( ::nView ) )->CPROPRV    := ( D():Proveedores( ::nView ) )->Poblacion
      ( D():AlbaranesProveedores( ::nView ) )->CPOSPRV    := ( D():Proveedores( ::nView ) )->CodPostal
      ( D():AlbaranesProveedores( ::nView ) )->CDNIPRV    := ( D():Proveedores( ::nView ) )->Nif
      ( D():AlbaranesProveedores( ::nView ) )->CCODPGO    := ( D():Proveedores( ::nView ) )->fPago
   end if

   ( D():AlbaranesProveedores( ::nView ) )->( dbUnLock() )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addLineas()

   aEval( ::aLineasPedido, {|hLine| ::addLine( hLine ) } )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addProduct( hLine )

   local nRecAntArticulos     := ( D():Articulos( ::nView ) )->( recno() )
   local nOrdAntArticulos     := ( D():Articulos( ::nView ) )->( OrdSetFocus( "Codigo" ) )

   if !( D():Articulos( ::nView ) )->( dbSeek( hGet( hLine, "CodigoArticulo" ) ) )
      
      ( D():Articulos( ::nView ) )->( dbAppend() )

      ( D():Articulos( ::nView ) )->Codigo      := hGet( hLine, "CodigoArticulo" )
      ( D():Articulos( ::nView ) )->Nombre      := hGet( hLine, "NombreArticulo" )
      ( D():Articulos( ::nView ) )->pCosto      := hGet( hLine, "PCosto" )
      ( D():Articulos( ::nView ) )->TipoIva     := "G"
      ( D():Articulos( ::nView ) )->pVenta1     := ( hGet( hLine, "PVenta" ) / 1.21 )
      ( D():Articulos( ::nView ) )->pVtaIva1    := hGet( hLine, "PVenta" )
      ( D():Articulos( ::nView ) )->Familia     := hGet( hLine, "Familia" )

      ( D():Articulos( ::nView ) )->( dbUnLock() )

   else

      /*if dbLock( D():Articulos( ::nView ) )
         ( D():Articulos( ::nView ) )->pCosto      := hGet( hLine, "PCosto" )
         ( D():Articulos( ::nView ) )->pVenta1     := ( hGet( hLine, "PVenta" ) / 1.21 )
         ( D():Articulos( ::nView ) )->pVtaIva1    := hGet( hLine, "PVenta" )  
         if !Empty( hGet( hLine, "Familia" ) )
            ( D():Articulos( ::nView ) )->Familia  := hGet( hLine, "Familia" )
         end if
         ( D():Articulos( ::nView ) )->( dbUnLock() )
      end if*/

   end if

   ( D():Articulos( ::nView ) )->( OrdSetFocus( nOrdAntArticulos ) )
   ( D():Articulos( ::nView ) )->( dbGoTo( nRecAntArticulos ) )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addFamilia( hLine )

   local nRecAnt     := ( D():Familias( ::nView ) )->( recno() )
   local nOrdAnt     := ( D():Familias( ::nView ) )->( OrdSetFocus( "cNomFam" ) )
   local cNewCodFam  := ""
   
   if !( D():Familias( ::nView ) )->( dbSeek( Upper( hGet( hLine, "cNomFamilia" ) ) ) )
      
      cNewCodFam     := NextKey( space (16), D():Familias( ::nView ) )

      ( D():Familias( ::nView ) )->( dbAppend() )

      ( D():Familias( ::nView ) )->cCodFam      := cNewCodFam
      ( D():Familias( ::nView ) )->cNomFam      := hGet( hLine, "cNomFamilia" )

      ( D():Familias( ::nView ) )->( dbUnLock() )

      hSet( hLine, "Familia", cNewCodFam )

   else

      hSet( hLine, "Familia", ( D():Familias( ::nView ) )->cCodFam )

   end if

   ( D():Familias( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():Familias( ::nView ) )->( dbGoTo( nRecAnt ) )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD addLine( hLine )

   /*
   Creo el artículo si no lo tengo creado--------------------------------------
   */

   ::addFamilia( hLine )
   ::addProduct( hLine )

   /*
   Añado la linea--------------------------------------------------------------
   */

   ( D():AlbaranesProveedoresLineas( ::nView ) )->( dbAppend() )

   ( D():AlbaranesProveedoresLineas( ::nView ) )->cSerAlb       :=  ::cSerieAlbaran
   ( D():AlbaranesProveedoresLineas( ::nView ) )->nNumAlb       :=  ::cNumeroAlbaran
   ( D():AlbaranesProveedoresLineas( ::nView ) )->cSufAlb       :=  ::cSufijoAlbaran
   ( D():AlbaranesProveedoresLineas( ::nView ) )->dFecAlb       :=  ::dFechaAlbaran
   ( D():AlbaranesProveedoresLineas( ::nView ) )->tFecAlb       :=  ::cHoraAlbaran

   ( D():AlbaranesProveedoresLineas( ::nView ) )->CREF          := hGet( hLine, "CodigoArticulo" )

   if ( D():Articulos( ::nView ) )->( dbSeek( hGet( hLine, "CodigoArticulo" ) ) )

      ( D():AlbaranesProveedoresLineas( ::nView ) )->CDETALLE   :=  ( D():Articulos( ::nView ) )->Nombre
      ( D():AlbaranesProveedoresLineas( ::nView ) )->CUNIDAD    :=  ( D():Articulos( ::nView ) )->cUnidad
      ( D():AlbaranesProveedoresLineas( ::nView ) )->NIVA       :=  nIva( D():TiposIva( ::nView ), ( D():Articulos( ::nView ) )->TipoIva )
      ( D():AlbaranesProveedoresLineas( ::nView ) )->NCTLSTK    :=  ( D():Articulos( ::nView ) )->NCTLSTOCK
      ( D():AlbaranesProveedoresLineas( ::nView ) )->CCODFAM    :=  ( D():Articulos( ::nView ) )->Familia

   end if

   ( D():AlbaranesProveedoresLineas( ::nView ) )->nPreDiv       := hGet( hLine, "PCosto" )
   ( D():AlbaranesProveedoresLineas( ::nView ) )->NUNICAJA      := hGet( hLine, "Unidades" )
   ( D():AlbaranesProveedoresLineas( ::nView ) )->nCanEnt       := 1
   ( D():AlbaranesProveedoresLineas( ::nView ) )->CALMLIN       := ::cCodigoAlmacen

   ( D():AlbaranesProveedoresLineas( ::nView ) )->( dbUnLock() )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD recalculaTotales()

   local aTotAlb
   local nRec     := ( D():AlbaranesProveedores( ::nView ) )->( recno() )
   local nOrdAnt  := ( D():AlbaranesProveedores( ::nView ) )->( OrdSetFocus( "NNUMALB" ) )
   
   if ( D():AlbaranesProveedores( ::nView ) )->( dbSeek( ::cSerieAlbaran + Str( ::cNumeroAlbaran ) + ::cSufijoAlbaran ) )

      if dbLock( D():AlbaranesProveedores( ::nView ) )

         aTotAlb                 := aTotAlbPrv( ::cSerieAlbaran + Str( ::cNumeroAlbaran ) + ::cSufijoAlbaran,;
                                                D():AlbaranesProveedores( ::nView ),;
                                                D():AlbaranesProveedoresLineas( ::nView ),;
                                                D():TiposIva( ::nView ),;
                                                D():Divisas( ::nView ),;
                                                ( D():AlbaranesProveedores( ::nView ) )->cDivAlb )

         ( D():AlbaranesProveedores( ::nView ) )->nTotNet := aTotAlb[1]
         ( D():AlbaranesProveedores( ::nView ) )->nTotIva := aTotAlb[2]
         ( D():AlbaranesProveedores( ::nView ) )->nTotReq := aTotAlb[3]
         ( D():AlbaranesProveedores( ::nView ) )->nTotAlb := aTotAlb[4]

         ( D():AlbaranesProveedores( ::nView ) )->( dbUnLock() )

      end if

   end if

   ( D():AlbaranesProveedores( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():AlbaranesProveedores( ::nView ) )->( dbGoTo( nRec ) )
   
Return ( .t. )

//---------------------------------------------------------------------------//  

#include "ImportarExcel.prg"