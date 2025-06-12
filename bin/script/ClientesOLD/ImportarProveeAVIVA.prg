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

   METHOD getCampoClave()        INLINE ( ::getExcelString( "A" ) )

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

   ::cFicheroExcel            := "c:\ficheros\proveedores.xlsx"

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

      //if !D():SeekInOrd( D():Clientes( ::nView ), ::getCampoClave(), "Titulo" )
         ::importarCampos()
      //end if

      ::siguienteLinea()

   end if

   ::closeExcel()

Return nil

//---------------------------------------------------------------------------//

METHOD importarCampos()

   ( D():Proveedores( ::nView ) )->( dbappend() )

   MsgWait( ::getExcelString( "A" ), "Procesando... " + Str( ::nCount ), 0.1 )

   ( D():Proveedores( ::nView ) )->Cod             := RJust( ::getExcelString( "A" ), "0", RetNumCodPrvEmp() )

   if !empty( ::getExcelString( "B" ) )
      ( D():Proveedores( ::nView ) )->Titulo       := AllTrim( ::getExcelString( "B" ) )
   end if 

   if !empty( ::getExcelString( "D" ) )
      ( D():Proveedores( ::nView ) )->Domicilio    := AllTrim( ::getExcelString( "D" ) )
   end if 

   if !empty( ::getExcelString( "G" ) )
      ( D():Proveedores( ::nView ) )->CodPostal    := ::getExcelString( "G" )
   end if 

   if !empty( ::getExcelString( "F" ) )
      ( D():Proveedores( ::nView ) )->Telefono     := ::getExcelString( "F" )
   end if

   if !empty( ::getExcelString( "E" ) )
      ( D():Proveedores( ::nView ) )->cMeiInt      := ::getExcelString( "E" )
   end if

   if !empty( ::getExcelString( "C" ) )
      ( D():Proveedores( ::nView ) )->Nif          := ::getExcelString( "C" )
   end if

   if !empty( ::getExcelString( "I" ) )
      ( D():Proveedores( ::nView ) )->cPerCto      := ::getExcelString( "I" )
   end if

   ( D():Proveedores( ::nView ) )->( dbcommit() )

   ( D():Proveedores( ::nView ) )->( dbunlock() )

   ::nCount++

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"