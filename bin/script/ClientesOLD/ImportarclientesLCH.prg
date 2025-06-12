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

   ::cFicheroExcel            := "C:\ficheros\LCH\clientes.xls"

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 13

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

   ( D():Clientes( ::nView ) )->( dbappend() )

   MsgWait( ::getExcelString( "J" ), "Procesando... " + Str( ::nCount ), 0.005 )

   ( D():Clientes( ::nView ) )->Cod             := RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() )

   LogWrite( "Codigo: " + RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() ) + "  Nombre: " + RJust( ::getExcelString( "J" ), "0", RetNumCodCliEmp() ) )

   if !empty( ::getExcelString( "J" ) )
      ( D():Clientes( ::nView ) )->Titulo       := ::getExcelString( "J" )
   end if 

   if !empty( ::getExcelString( "C" ) )
      ( D():Clientes( ::nView ) )->Nif          := ::getExcelString( "C" )
   end if 

   if !empty( ::getExcelString( "B" ) )
      ( D():Clientes( ::nView ) )->NbrEst       := ::getExcelString( "B" )
   end if

   if !empty( ::getExcelString( "S" ) )
      ( D():Clientes( ::nView ) )->Domicilio    := ::getExcelString( "S" )
   end if

   if !empty( ::getExcelString( "E" ) )
      ( D():Clientes( ::nView ) )->Poblacion    := ::getExcelString( "E" )
   end if

   if !empty( ::getExcelString( "F" ) )
      ( D():Clientes( ::nView ) )->Provincia    := ::getExcelString( "F" )
   end if

   if !empty( ::getExcelString( "AC" ) )
      ( D():Clientes( ::nView ) )->CodPostal    := ::getExcelString( "AC" )
   end if

   /*if !empty( ::getExcelString( "DK" ) )
      ( D():Clientes( ::nView ) )->cMeiInt      := ::getExcelString( "DK" )
   end if*/

   if !empty( ::getExcelString( "D" ) )
      ( D():Clientes( ::nView ) )->Telefono     := ::getExcelString( "D" )
   end if

   /*if !empty( ::getExcelString( "DH" ) )
      ( D():Clientes( ::nView ) )->Movil        := ::getExcelString( "DH" )
   end if*/

   /*if !empty( ::getExcelString( "DJ" ) )
      ( D():Clientes( ::nView ) )->Fax          := ::getExcelString( "DJ" )
   end if*/

   if !empty( ::getExcelString( "I" ) )
      ( D():Clientes( ::nView ) )->SubCta       := ::getExcelString( "I" )
   end if

   if !empty( ::getExcelString( "AD" ) )
      ( D():Clientes( ::nView ) )->Uuid         := ::getExcelString( "AD" )
   end if

   if !empty( ::getExcelString( "AB" ) )
      ( D():Clientes( ::nView ) )->mComent      := ::getExcelString( "AB" )
   end if

   if !empty( ::getExcelString( "AA" ) )
      ( D():Clientes( ::nView ) )->mObserv      := ::getExcelString( "AA" )
   end if

   if !empty( ::getExcelString( "Z" ) ) .and. ( ::getExcelString( "Z" ) != "0" )
      ( D():Clientes( ::nView ) )->cCodRut      := RJust( ::getExcelString( "Z" ), "0", 4 )
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