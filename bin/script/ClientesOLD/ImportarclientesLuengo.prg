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

   DATA nCount

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

   ::nCount                   := 1

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := "C:\ficheros\clientesluengo.xls"

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

   MsgWait( "Codigo: " + RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() ) + "  Nombre: " + AllTrim( ::getExcelString( "C" ) ), "Procesando... " + Str( ::nCount ), 0.005 )

   LogWrite( "Codigo: " + RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() ) + "  Nombre: " + AllTrim( ::getExcelString( "C" ) ) )

   ( D():Clientes( ::nView ) )->( dbappend() )

   ( D():Clientes( ::nView ) )->Cod             := RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() )

   if !empty( ::getExcelString( "J" ) )
      ( D():Clientes( ::nView ) )->Titulo       := ::getExcelString( "C" )
   else
      ( D():Clientes( ::nView ) )->Titulo       := ::getExcelString( "D" )
   end if 

   if !empty( ::getExcelString( "D" ) )
      ( D():Clientes( ::nView ) )->NbrEst       := ::getExcelString( "D" )
   end if
   
   if !empty( ::getExcelString( "B" ) )
      ( D():Clientes( ::nView ) )->Nif          := ::getExcelString( "B" )
   end if 

   if !empty( ::getExcelString( "E" ) )
      ( D():Clientes( ::nView ) )->Domicilio    := ::getExcelString( "E" )
   end if

   if !empty( ::getExcelString( "F" ) )
      ( D():Clientes( ::nView ) )->Poblacion    := ::getExcelString( "F" )
   end if

   if !empty( ::getExcelString( "H" ) )
      ( D():Clientes( ::nView ) )->Provincia    := ::getExcelString( "H" )
   end if

   if !empty( ::getExcelString( "G" ) )
      ( D():Clientes( ::nView ) )->CodPostal    := ::getExcelString( "G" )
   end if

   if !empty( ::getExcelString( "I" ) )
      ( D():Clientes( ::nView ) )->Telefono     := ::getExcelString( "I" )
   end if

   ( D():Clientes( ::nView ) )->CodPago         := "00"
   ( D():Clientes( ::nView ) )->cCodAlm         := "000"

   ( D():Clientes( ::nView ) )->( dbcommit() )

   ( D():Clientes( ::nView ) )->( dbunlock() )

   ::nCount++

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"