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

   ::cFicheroExcel            := "C:\ficheros\clientes.xlsx"

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 1

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

   MsgWait( ::getExcelString( "H" ), "Procesando... " + Str( ::nCount ), 0.1 )

   ( D():Clientes( ::nView ) )->Cod             	:= RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() )

   if !empty( ::getExcelString( "H" ) )
      ( D():Clientes( ::nView ) )->Titulo       	:= ::getExcelString( "H" )
   end if 

   if !empty( ::getExcelString( "I" ) )
      ( D():Clientes( ::nView ) )->Nif       		:= ::getExcelString( "I" )
   end if 

   if !empty( ::getExcelString( "J" ) )
      ( D():Clientes( ::nView ) )->Domicilio       	:= ::getExcelString( "J" )
   end if

   if !empty( ::getExcelString( "K" ) )
      ( D():Clientes( ::nView ) )->Poblacion    	:= ::getExcelString( "K" )
   end if

   if !empty( ::getExcelString( "M" ) )
      ( D():Clientes( ::nView ) )->Provincia    	:= ::getExcelString( "M" )
   end if

   if !empty( ::getExcelString( "L" ) )
      ( D():Clientes( ::nView ) )->CodPostal    	:= ::getExcelString( "L" )
   end if

   if !empty( ::getExcelString( "N" ) )
      ( D():Clientes( ::nView ) )->Telefono    		:= ::getExcelString( "N" )
   end if

   if !empty( ::getExcelString( "O" ) )
      ( D():Clientes( ::nView ) )->Fax    			:= ::getExcelString( "O" )
   end if

   if !empty( ::getExcelString( "P" ) )
      ( D():Clientes( ::nView ) )->cPerCto    		:= ::getExcelString( "P" )
   end if

   if !empty( ::getExcelString( "T" ) )
      ( D():Clientes( ::nView ) )->cCodGrp    		:= RJust( ::getExcelString( "T" ), "0", 4 )
   end if

   if !empty( ::getExcelString( "Q" ) )
      ( D():Clientes( ::nView ) )->mComent    		:= ::getExcelString( "Q" ) + ";" + ::getExcelString( "R" ) + ";" + ::getExcelString( "S" )
   end if

   ( D():Clientes( ::nView ) )->Uuid         		:= win_uuidcreatestring()

   ( D():Clientes( ::nView ) )->( dbcommit() )

   ( D():Clientes( ::nView ) )->( dbunlock() )

   ::nCount++

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"