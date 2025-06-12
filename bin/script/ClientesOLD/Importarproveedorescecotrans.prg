 #include "FiveWin.Ch"

#include "Hbxml.ch"
#include "Hbclass.ch"
#include "Fileio.ch"
#include "Factu.ch" 
      
//---------------------------------------------------------------------------//

Function ImportarExcelArguelles( nView )                	 
	      
   local oImportarExcel    := TImportarExcelProveedores():New( nView )

   oImportarExcel:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TImportarExcelProveedores FROM TImportarExcel

   DATA nCount

   METHOD New()

   METHOD Run()

   METHOD getCampoClave()        INLINE ( ::getExcelString( "M" ) )

   METHOD procesaFicheroExcel()

   METHOD filaValida()
   
   METHOD siguienteLinea()       INLINE ( ++::nFilaInicioImportacion )

   METHOD importarCampos()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

   ::nCount                   := 1

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := "E:\Xtendoo\CECOTRANS\proveedores.xls"

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 2

   /*
   Columna de campo clave------------------------------------------------------
   */

   ::cColumnaCampoClave       := 'M'

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

      //if !D():SeekInOrd( D():Proveedores( ::nView ), ::getCampoClave(), "Titulo" )
      ::importarCampos()
      //end if

      ::siguienteLinea()

   end if

   ::closeExcel()

Return nil

//---------------------------------------------------------------------------//

METHOD importarCampos()

   ( D():Proveedores( ::nView ) )->( dbappend() )

   MsgWait( ::getExcelString( "C" ), "Procesando... " + Str( ::nCount ), 0.1 )

   ( D():Proveedores( ::nView ) )->Cod             := RJust( ::getExcelString( "M" ), "0", RetNumCodCliEmp() )

   if !empty( ::getExcelString( "C" ) )
      ( D():Proveedores( ::nView ) )->Titulo       := ::getExcelString( "C" )
   end if 

   if !empty( ::getExcelString( "E" ) )
      ( D():Proveedores( ::nView ) )->Domicilio    := ::getExcelString( "E" )
   end if 

   if !empty( ::getExcelString( "H" ) )
      ( D():Proveedores( ::nView ) )->CodPostal    := ::getExcelString( "H" )
   end if 

   if !empty( ::getExcelString( "F" ) )
      ( D():Proveedores( ::nView ) )->Poblacion    := ::getExcelString( "F" )
   end if 

   if !empty( ::getExcelString( "G" ) )
      ( D():Proveedores( ::nView ) )->Provincia    := ::getExcelString( "G" )
   end if

   if !empty( ::getExcelString( "I" ) )
      ( D():Proveedores( ::nView ) )->Telefono     := ::getExcelString( "I" )
   end if

   if !empty( ::getExcelString( "J" ) )
      ( D():Proveedores( ::nView ) )->Fax          := ::getExcelString( "J" )
   end if

   if !empty( ::getExcelString( "K" ) )
      ( D():Proveedores( ::nView ) )->cMeiInt      := ::getExcelString( "K" )
   end if

   if !empty( ::getExcelString( "D" ) )
      ( D():Proveedores( ::nView ) )->Nif          := ::getExcelString( "D" )
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