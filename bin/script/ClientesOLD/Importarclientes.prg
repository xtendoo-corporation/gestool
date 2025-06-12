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

   ::cFicheroExcel            := "C:\ficheros\clientes.xls"

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 4

   /*
   Columna de campo clave------------------------------------------------------
   */

   ::cColumnaCampoClave       := 'C'

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

   MsgWait( ::getExcelString( "X" ), "Procesando... " + Str( ::nCount ), 0.005 )

   ( D():Clientes( ::nView ) )->Cod             := RJust( ::getExcelString( "C" ), "0", RetNumCodCliEmp() )

   if !empty( ::getExcelString( "X" ) )
      ( D():Clientes( ::nView ) )->Titulo       := ::getExcelString( "X" )
   end if 

   if !empty( ::getExcelString( "E" ) )
      ( D():Clientes( ::nView ) )->Nif          := ::getExcelString( "E" )
   end if 

   if !empty( ::getExcelString( "DS" ) )
      ( D():Clientes( ::nView ) )->NbrEst       := ::getExcelString( "DS" )
   end if

   if !empty( ::getExcelString( "CR" ) )
      ( D():Clientes( ::nView ) )->Domicilio    := ::getExcelString( "CR" )
   end if

   if !empty( ::getExcelString( "DA" ) )
      ( D():Clientes( ::nView ) )->Poblacion    := ::getExcelString( "DA" )
   end if

   if !empty( ::getExcelString( "DD" ) )
      ( D():Clientes( ::nView ) )->Provincia    := ::getExcelString( "DD" )
   end if

   if !empty( ::getExcelString( "DY" ) )
      ( D():Clientes( ::nView ) )->CodPostal    := ::getExcelString( "DY" )
   end if

   if !empty( ::getExcelString( "DK" ) )
      ( D():Clientes( ::nView ) )->cMeiInt      := ::getExcelString( "DK" )
   end if

   if !empty( ::getExcelString( "DG" ) )
      ( D():Clientes( ::nView ) )->Telefono     := ::getExcelString( "DG" )
   end if

   if !empty( ::getExcelString( "DH" ) )
      ( D():Clientes( ::nView ) )->Movil        := ::getExcelString( "DH" )
   end if

   if !empty( ::getExcelString( "DJ" ) )
      ( D():Clientes( ::nView ) )->Fax          := ::getExcelString( "DJ" )
   end if

   if !empty( ::getExcelString( "I" ) )
      ( D():Clientes( ::nView ) )->SubCta       := ::getExcelString( "I" )
   end if

   if !empty( ::getExcelString( "FY" ) )
      ( D():Clientes( ::nView ) )->Uuid         := ::getExcelString( "FY" )
   end if

   if !empty( ::getExcelString( "BX" ) )
      ( D():Clientes( ::nView ) )->mComent      := ::getExcelString( "BX" )
   end if

   if !empty( ::getExcelString( "AF" ) )
      ( D():Clientes( ::nView ) )->mObserv      := ::getExcelString( "AF" )
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