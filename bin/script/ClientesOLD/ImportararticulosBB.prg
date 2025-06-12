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

   METHOD procesaFicheroExcel()

   METHOD filaValida()
   
   METHOD siguienteLinea()       INLINE ( ++::nFilaInicioImportacion )

   METHOD existeRegistro()       INLINE ( D():gotoCliente( ::getCampoClave(), ::nView ) )

   METHOD importarCampos()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := "C:\ficheros\BB\articulos.xls"

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

      ::importarCampos()

      ::siguienteLinea()

   end if

   ::closeExcel()

Return nil

//---------------------------------------------------------------------------//

METHOD importarCampos()

   local cTipoIva    := "G"
   local nPos        := 0

   do case
      case ::getExcelNumeric( "AA" ) == 21
         cTipoIva := "G"

      case ::getExcelNumeric( "AA" ) == 10
         cTipoIva := "N"

   end case

   ( D():Articulos( ::nView ) )->( dbappend() )

   ( D():Articulos( ::nView ) )->Codigo            := ::getExcelString( "A" )

   if !empty( ::getExcelString( "B" ) )
      ( D():Articulos( ::nView ) )->Nombre         := ::getExcelString( "B" )
   end if 

   if !empty( ::getExcelNumeric( "P" ) )
      ( D():Articulos( ::nView ) )->pVenta1        := ::getExcelNumeric( "P" )
      ( D():Articulos( ::nView ) )->pVtaIva1       := ::getExcelNumeric( "Q" )
   end if

   if !empty( ::getExcelNumeric( "S" ) )
      ( D():Articulos( ::nView ) )->pVenta2        := ::getExcelNumeric( "S" )
      ( D():Articulos( ::nView ) )->pVtaIva2       := ::getExcelNumeric( "T" )
   end if

   if !empty( ::getExcelNumeric( "V" ) )
      ( D():Articulos( ::nView ) )->pVenta3        := ::getExcelNumeric( "V" )
      ( D():Articulos( ::nView ) )->pVtaIva3       := ::getExcelNumeric( "W" )
   end if

   ( D():Articulos( ::nView ) )->TIPOIVA           := cTipoIva

   ( D():Articulos( ::nView ) )->( dbcommit() )

   ( D():Articulos( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"