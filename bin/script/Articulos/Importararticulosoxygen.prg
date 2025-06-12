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

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := "C:\ficheros\ARTICULOSOXYGEN.xls"

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

   ::openExcel()

   while ( ::filaValida() )

      if !Empty( AllTrim( ::getExcelString( "A" ) ) )

         MsgWait( "Artículo: " + ::getCodigoArticulo() + "Nombre:" + AllTrim( ::getExcelString( "B" ) ), "Procesando" , 0.2 )

         ::importarArticulo()

      end if

      ::siguienteLinea()

   end if

   ::closeExcel()

Return nil

//---------------------------------------------------------------------------//

METHOD importarArticulo()

   ( D():Articulos( ::nView ) )->( dbappend() )
   
   ( D():Articulos( ::nView ) )->Codigo            := ::getCodigoArticulo()
   
   if !empty( ::getExcelString( "B" ) )
      ( D():Articulos( ::nView ) )->Nombre         := AllTrim( ::getExcelString( "B" ) )
   end if 

   if !empty( ::getExcelNumeric( "M" ) )
      ( D():Articulos( ::nView ) )->pCosto         := ::getExcelNumeric( "M" )
   end if

   if !empty( ::getExcelString( "D" ) )
      ( D():Articulos( ::nView ) )->cCodTip        := ::getExcelString( "D" )
   end if

   if !empty( ::getExcelString( "E" ) )
      ( D():Articulos( ::nView ) )->cCodCate       := ::getExcelString( "E" )
   end if

   if !empty( ::getExcelString( "AB" ) )
      ( D():Articulos( ::nView ) )->Familia        := ::getExcelString( "AB" )
   end if
   
   ( D():Articulos( ::nView ) )->TipoIva           := "G"

   ( D():Articulos( ::nView ) )->( dbcommit() )

   ( D():Articulos( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"