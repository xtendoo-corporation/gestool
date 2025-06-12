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

   ::cFicheroExcel            := "C:\ficheros\LCH\articulos.xls"

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 77

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
      case ::getExcelNumeric( "Q" ) == 1
         cTipoIva := "G"

      case ::getExcelNumeric( "Q" ) == 2
         cTipoIva := "N"

   end case

   MsgWait( ::getExcelString( "P" ), "aa", 0.05  )
   logwrite( ::getExcelString( "P" ) )

   ( D():Articulos( ::nView ) )->( dbappend() )

   ( D():Articulos( ::nView ) )->Codigo               := ::getExcelString( "A" )

   if !empty( ::getExcelString( "P" ) )
      ( D():Articulos( ::nView ) )->Nombre            := ::getExcelString( "P" )
   end if 

   if !empty( ::getExcelString( "B" ) )
      ( D():Articulos( ::nView ) )->DESCRIP           := ::getExcelString( "B" )
   end if 

   if !empty( ::getExcelString( "G" ) )
      ( D():Articulos( ::nView ) )->FAMILIA           := ::getExcelString( "G" )
   end if 

   if !empty( ::getExcelString( "N" ) )
      ( D():Articulos( ::nView ) )->CCODTIP           := SubStr( ::getExcelString( "N" ), 1, 1 )
   end if 

   if !empty( ::getExcelString( "R" ) )
      ( D():Articulos( ::nView ) )->pCosto            := ::getExcelNumeric( "R" )
   end if 

   if !empty( ::getExcelNumeric( "X" ) )
      ( D():Articulos( ::nView ) )->pVenta1           := ::getExcelNumeric( "X" )
   end if

   if !empty( ::getExcelNumeric( "U" ) )
      ( D():Articulos( ::nView ) )->pVtaIva1          := ::getExcelNumeric( "U" )
   end if

   if !empty( ::getExcelNumeric( "Z" ) )
      ( D():Articulos( ::nView ) )->pVenta2           := ::getExcelNumeric( "Z" )
   end if

   if !empty( ::getExcelNumeric( "V" ) )
      ( D():Articulos( ::nView ) )->pVtaIva2          := ::getExcelNumeric( "V" )
   end if

   if !empty( ::getExcelNumeric( "Y" ) )
      ( D():Articulos( ::nView ) )->pVenta3           := ::getExcelNumeric( "Y" )
   end if

   if !empty( ::getExcelNumeric( "W" ) )
      ( D():Articulos( ::nView ) )->pVtaIva3          := ::getExcelNumeric( "W" )
   end if

   if !empty( ::getExcelString( "E" ) )
      ( D():Articulos( ::nView ) )->CODEBAR           := ::getExcelString( "E" )
   end if 

   ( D():Articulos( ::nView ) )->TIPOIVA              := cTipoIva

   ( D():Articulos( ::nView ) )->( dbcommit() )

   ( D():Articulos( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"