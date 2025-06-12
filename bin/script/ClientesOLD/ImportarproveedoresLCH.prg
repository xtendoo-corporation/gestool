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

   ::cFicheroExcel            := "C:\ficheros\LCH\provee.xls"

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 8

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

   ( D():Proveedores( ::nView ) )->( dbappend() )

   ( D():Proveedores( ::nView ) )->Cod             := RJust( ::getExcelString( "A" ), "0", RetNumCodPrvEmp() )

   if !empty( ::getExcelString( "K" ) )
      ( D():Proveedores( ::nView ) )->Titulo       := ::getExcelString( "K" )
   end if 

   if !empty( ::getExcelString( "B" ) )
      ( D():Proveedores( ::nView ) )->cNbrEst       := ::getExcelString( "B" )
   end if 

   if !empty( ::getExcelString( "C" ) )
      ( D():Proveedores( ::nView ) )->Nif          := ::getExcelString( "C" )
   end if 

   if !empty( ::getExcelString( "E" ) )
      ( D():Proveedores( ::nView ) )->Telefono     := ::getExcelString( "E" )
   end if

   if !empty( ::getExcelString( "L" ) )
      ( D():Proveedores( ::nView ) )->Domicilio    := ::getExcelString( "L" ) + Space( 1 ) + ::getExcelString( "M" )
   end if   

   if !empty( ::getExcelString( "F" ) )
      ( D():Proveedores( ::nView ) )->Poblacion    := ::getExcelString( "F" )
   end if

   if !empty( ::getExcelString( "G" ) )
      ( D():Proveedores( ::nView ) )->Provincia    := ::getExcelString( "G" )
   end if

   if !empty( ::getExcelString( "F" ) )
      ( D():Proveedores( ::nView ) )->CodPostal    := ::getExcelString( "F" )
   end if

   if !empty( ::getExcelString( "H" ) )
      ( D():Proveedores( ::nView ) )->SubCta       := ::getExcelString( "H" )
   end if

   if !empty( ::getExcelString( "R" ) )
      ( D():Proveedores( ::nView ) )->CMEIINT      := ::getExcelString( "R" )
   end if

   if !empty( ::getExcelString( "T" ) )
      ( D():Proveedores( ::nView ) )->MCOMENT      := ::getExcelString( "T" )
   end if

   ( D():Proveedores( ::nView ) )->FPAGO           := "00"

   ( D():Proveedores( ::nView ) )->( dbcommit() )

   ( D():Proveedores( ::nView ) )->( dbunlock() )

   ::nCount++

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"