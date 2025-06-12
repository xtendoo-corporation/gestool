#include "FiveWin.Ch"

#include "Hbxml.ch"
#include "Hbclass.ch"
#include "Fileio.ch"
#include "Factu.ch" 
      
//---------------------------------------------------------------------------//

Function ImportarExcelArguelles( nView )                	 
	      
   local oImportarExcel    := TImportarExcelClientes():New( nView )

   oImportarExcel:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TImportarExcelClientes FROM TImportarExcel

   DATA cCodigoFamilia
   DATA cCodigoFabricante
   DATA cCodigoProveedor

   DATA nRecFamilias
   DATA nOrdAntFamilias
   DATA nRecFabricantes
   DATA nOrdAntFabricantes
   DATA nRecProveedores
   DATA nOrdAntProveedores

   METHOD New()

   METHOD Run()

   METHOD getCampoClave()        INLINE ( ::getExcelNumeric( ::cColumnaCampoClave ) )

   METHOD getCodigoArticulo()    INLINE ( if( !Empty( ::getExcelString( "B" ) ), Padr( ::getExcelString( "B" ), 18 ), Padr( ::getExcelString( "A" ), 18 ) ) )

   METHOD procesaFicheroExcel()

   METHOD filaValida()
   
   METHOD siguienteLinea()       INLINE ( ++::nFilaInicioImportacion )

   METHOD existeRegistro()       INLINE ( D():gotoArticulos( ::getCodigoArticulo(), ::nView ) )

   METHOD importarArticulo()

   METHOD getExcelNumeric( columna, fila )

   METHOD getFamilia()
   METHOD addFamilia()

   METHOD getFabricante()
   METHOD addFabricante()

   METHOD getProveedor()
   METHOD addProveedor( cNomPrv )

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := "c:\ficheros\productos.xls"

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 2

   /*
   Columna de campo clave------------------------------------------------------
   */

   ::cColumnaCampoClave       := 'A'

Return ( Self )

//----------------------------------------------------------------------------//

METHOD Run()

   if !file( ::cFicheroExcel )
      msgStop( "El fichero " + ::cFicheroExcel + " no existe." )
      Return ( .f. )
   end if 

   msgrun( "Procesando fichero " + ::cFicheroExcel, "Espere por favor...",  {|| ::procesaFicheroExcel() } )

   msginfo( "Proceso finalizado" )

Return ( .t. )

//----------------------------------------------------------------------------//

METHOD procesaFicheroExcel()

   local nOrdAnt := ( D():ArticulosCodigosBarras( ::nView ) )->( OrdSetFocus( "cCodBar" ) )

   ::openExcel()

   while ( ::filaValida() )

      if !Empty( ::getCodigoArticulo() )

         MsgWait( "Artículo: " + AllTrim( ::getCodigoArticulo() ) + " - " + ::getExcelString( "F" ), "Procesando" , 0.2 )

         if !ArticulosModel():exist( ::getCodigoArticulo() )

            ::importarArticulo()

         end if

      end if

      ::siguienteLinea()

   end if

   ::closeExcel()

   ( D():ArticulosCodigosBarras( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

Return nil

//---------------------------------------------------------------------------//

METHOD importarArticulo()

   ( D():Articulos( ::nView ) )->( dbappend() )
   
   ( D():Articulos( ::nView ) )->Codigo                  := ::getCodigoArticulo()
   
   if !empty( ::getExcelString( "F" ) )
      ( D():Articulos( ::nView ) )->Nombre               := AllTrim( ::getExcelString( "F" ) )
   end if 

   if !empty( ::getExcelNumeric( "C" ) )
      ( D():Articulos( ::nView ) )->pVenta1              := ::getExcelNumeric( "C" )
      ( D():Articulos( ::nView ) )->pVtaIva1             := ( ::getExcelNumeric( "C" ) * ( 1.21 ) )
   end if

   ( D():Articulos( ::nView ) )->TIPOIVA                 := "G"

   ( D():Articulos( ::nView ) )->( dbcommit() )

   ( D():Articulos( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------// 

METHOD getFamilia()

   ::cCodigoFamilia     := ""

   if Empty( ::getExcelString( "H" ) )
      Return nil
   end if

   if ( D():Familias( ::nView ) )->( dbSeek( Padr( ::getExcelString( "H" ), 40 ) ) )
      ::cCodigoFamilia  := ( D():Familias( ::nView ) )->cCodFam
   else
      ::addFamilia( Padr( ::getExcelString( "H" ), 40 ) )
   end if

Return nil

//---------------------------------------------------------------------------// 

METHOD addFamilia( cNomFam )

   local cNewCodigo

   ( D():Familias( ::nView ) )->( dbappend() )

   cNewCodigo                             := NextKey( dbLast( D():Familias( ::nView ), 1 ), D():Familias( ::nView ) )

   ( D():Familias( ::nView ) )->cCodFam   := cNewCodigo
   ( D():Familias( ::nView ) )->cNomFam   := cNomFam

   ( D():Familias( ::nView ) )->( dbcommit() )

   ( D():Familias( ::nView ) )->( dbunlock() )

   ::cCodigoFamilia                       := cNewCodigo

Return nil

//---------------------------------------------------------------------------// 

METHOD getFabricante()

   ::cCodigoFabricante  := ""

   if Empty( ::getExcelString( "G" ) )
      Return nil
   end if

   if ( D():Fabricantes( ::nView ) )->( dbSeek( Padr( ::getExcelString( "G" ), 35 ) ) )
      ::cCodigoFabricante  := ( D():Fabricantes( ::nView ) )->cCodFab
   else
      ::addFabricante( Padr( ::getExcelString( "G" ), 35 ) )
   end if

Return nil

//---------------------------------------------------------------------------// 

METHOD addFabricante( cNomFab )

   local cNewCodigo

   ( D():Fabricantes( ::nView ) )->( dbappend() )

   cNewCodigo                                := NextKey( dbLast( D():Fabricantes( ::nView ), 1 ), D():Fabricantes( ::nView ) )

   ( D():Fabricantes( ::nView ) )->cCodFab   := cNewCodigo
   ( D():Fabricantes( ::nView ) )->cNomFab   := cNomFab

   ( D():Fabricantes( ::nView ) )->( dbcommit() )

   ( D():Fabricantes( ::nView ) )->( dbunlock() )

   ::cCodigoFabricante                       := cNewCodigo

Return nil

//---------------------------------------------------------------------------// 
   
METHOD getProveedor()

   ::cCodigoProveedor      := ""

   if Empty( ::getExcelString( "G" ) )
      Return nil
   end if

   if ( D():Proveedores( ::nView ) )->( dbSeek( Upper( Padr( ::getExcelString( "G" ), 80 ) ) ) )
      ::cCodigoProveedor   := ( D():Proveedores( ::nView ) )->Cod
   else
      ::addProveedor( Padr( ::getExcelString( "G" ), 80 ) )
   end if

Return nil

//---------------------------------------------------------------------------// 

METHOD addProveedor( cNomPrv )

   local cNewCodigo

   ( D():Proveedores( ::nView ) )->( dbappend() )

   cNewCodigo                                := NextKey( dbLast( D():Proveedores( ::nView ), 1 ), D():Proveedores( ::nView ), "0", RetNumCodPrvEmp() )

   ( D():Proveedores( ::nView ) )->Cod       := cNewCodigo
   ( D():Proveedores( ::nView ) )->Titulo    := cNomPrv

   ( D():Proveedores( ::nView ) )->( dbcommit() )

   ( D():Proveedores( ::nView ) )->( dbunlock() )

   ::cCodigoProveedor                        := cNewCodigo

Return nil

//---------------------------------------------------------------------------//

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

METHOD getExcelNumeric( columna, fila )

   local excelValue  
   local valorPorDefecto      := 0

   DEFAULT fila               := ::nFilaInicioImportacion

   excelValue                 := ::getExcelValue( columna, fila, valorPorDefecto )

   if valtype( excelValue ) != "N" 
      excelValue              := val( excelValue )
   end if 

   if empty( excelValue )
      Return ( valorPorDefecto ) 
   end if 

Return ( excelValue )   

//---------------------------------------------------------------------------// 

#include "ImportarExcel.prg"