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

   METHOD New()

   METHOD Run()

   METHOD getCampoClave()        INLINE ( ::getExcelNumeric( ::cColumnaCampoClave ) )

   METHOD getCodigoArticulo()    INLINE ( Padr( ::getExcelString( "A" ), 18 ) )

   METHOD procesaFicheroExcel()

   METHOD filaValida()
   
   METHOD siguienteLinea()       INLINE ( ++::nFilaInicioImportacion )

   METHOD existeRegistro()       INLINE ( D():gotoArticulos( ::getCodigoArticulo(), ::nView ) )

   METHOD importarArticulo()

   METHOD CreaCabecera()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := "C:\ficheros\StockOxygen.xls"

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 3

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

   ::openExcel()

   while ( ::filaValida() )

      if !Empty( AllTrim( ::getExcelString( "A" ) ) )

         MsgWait( "Artículo: " + ::getCodigoArticulo() + "Nombre:" + AllTrim( ::getExcelString( "B" ) ), "Procesando" , 0.2 )

         ::importarArticulo()

      end if

      ::siguienteLinea()

   end if

   ::closeExcel()

   ::CreaCabecera()

Return nil

//---------------------------------------------------------------------------//

METHOD importarArticulo()

   if ( D():Articulos( ::nView ) )->( dbSeek( ::getCodigoArticulo() ) )

      ( D():AlbaranesProveedoresLineas( ::nView ) )->( dbappend() )
   
      ( D():AlbaranesProveedoresLineas( ::nView ) )->cSerAlb            := "A"
      ( D():AlbaranesProveedoresLineas( ::nView ) )->nNumAlb            := 1
      ( D():AlbaranesProveedoresLineas( ::nView ) )->cSufAlb            := "00"
      ( D():AlbaranesProveedoresLineas( ::nView ) )->cRef               := ::getCodigoArticulo()
      
      if !empty( ::getExcelString( "B" ) )
         ( D():AlbaranesProveedoresLineas( ::nView ) )->cDetalle        := ( D():Articulos( ::nView ) )->Nombre
      end if 

      ( D():AlbaranesProveedoresLineas( ::nView ) )->nCanEnt           := 1

      if !empty( ::getExcelNumeric( "C" ) )
         ( D():AlbaranesProveedoresLineas( ::nView ) )->nUniCaja        := ::getExcelNumeric( "C" )
      end if 

      ( D():AlbaranesProveedoresLineas( ::nView ) )->cAlmLin           := "000"

      ( D():AlbaranesProveedoresLineas( ::nView ) )->( dbcommit() )

      ( D():AlbaranesProveedoresLineas( ::nView ) )->( dbunlock() )

   end if

Return nil

//---------------------------------------------------------------------------// 

METHOD CreaCabecera()

   ( D():AlbaranesProveedores( ::nView ) )->( dbappend() )

   ( D():AlbaranesProveedores( ::nView ) )->cSerAlb            := "A"
   ( D():AlbaranesProveedores( ::nView ) )->nNumAlb            := 1
   ( D():AlbaranesProveedores( ::nView ) )->cSufAlb            := "00"

   ( D():AlbaranesProveedores( ::nView ) )->dFecAlb            := cTod( "01/01/2020" )
   ( D():AlbaranesProveedores( ::nView ) )->cCodAlm            := "000"
   ( D():AlbaranesProveedores( ::nView ) )->cCodCaj            := "000"

   ( D():AlbaranesProveedores( ::nView ) )->cNomPrv            := "Importación de Stock"

   ( D():AlbaranesProveedores( ::nView ) )->( dbcommit() )

   ( D():AlbaranesProveedores( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"