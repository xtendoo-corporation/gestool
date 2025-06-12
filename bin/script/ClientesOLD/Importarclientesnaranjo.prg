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

   METHOD getCampoClave()        INLINE ( ::getExcelString( "B" ) )

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

   ::cFicheroExcel            := "E:\Xtendoo\Naranjo\clientes.xls"

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 1

   /*
   Columna de campo clave------------------------------------------------------
   */

   ::cColumnaCampoClave       := 'B'

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

      if !D():SeekInOrd( D():Clientes( ::nView ), ::getCampoClave(), "Titulo" )
         ::importarCampos()
      end if

      ::siguienteLinea()

   end if

   ::closeExcel()

Return nil

//---------------------------------------------------------------------------//

METHOD importarCampos()

   ( D():Clientes( ::nView ) )->( dbappend() )

   MsgWait( ::getExcelString( "C" ), "Procesando... " + Str( ::nCount ), 0.1 )

   ( D():Clientes( ::nView ) )->Cod             := RJust( ::getExcelString( "B" ), "0", RetNumCodCliEmp() )

   if !empty( ::getExcelString( "C" ) )
      ( D():Clientes( ::nView ) )->Titulo       := ::getExcelString( "C" )
   end if 

   if !empty( ::getExcelString( "D" ) )
      ( D():Clientes( ::nView ) )->cPerCto     := ::getExcelString( "D" )
   end if

   if !empty( ::getExcelString( "E" ) )
      ( D():Clientes( ::nView ) )->Domicilio    := ::getExcelString( "E" )
   end if 

   if !empty( ::getExcelString( "F" ) )
      ( D():Clientes( ::nView ) )->CodPostal    := ::getExcelString( "F" )
   end if 

   if !empty( ::getExcelString( "G" ) )
      ( D():Clientes( ::nView ) )->Poblacion    := ::getExcelString( "G" )
   end if 

   if !empty( ::getExcelString( "H" ) )
      ( D():Clientes( ::nView ) )->Provincia    := ::getExcelString( "H" )
   end if

   if !empty( ::getExcelString( "I" ) )
      ( D():Clientes( ::nView ) )->Telefono     := ::getExcelString( "I" )
   end if

   if !empty( ::getExcelString( "J" ) )
      ( D():Clientes( ::nView ) )->Movil        := ::getExcelString( "J" )
   end if

   if !empty( ::getExcelString( "K" ) )
      ( D():Clientes( ::nView ) )->Fax          := ::getExcelString( "K" )
   end if

   if !empty( ::getExcelString( "L" ) )
      ( D():Clientes( ::nView ) )->cMeiInt      := ::getExcelString( "L" )
   end if

   if !empty( ::getExcelString( "M" ) )
      ( D():Clientes( ::nView ) )->cWebInt      := ::getExcelString( "M" )
   end if

   if !empty( ::getExcelString( "N" ) )
      ( D():Clientes( ::nView ) )->Nif          := ::getExcelString( "N" )
   end if

   ( D():Clientes( ::nView ) )->Uuid            := win_uuidcreatestring()
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