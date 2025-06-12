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

   ::cFicheroExcel            := "C:\ficheros\clientesoxigentlf.xls"

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

   MsgWait( "Codigo: " + RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() ) + "  Teléfono: " + AllTrim( ::getExcelString( "C" ) ), "Procesando... " + Str( ::nCount ), 0.005 )

   LogWrite( "Codigo: " + RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() ) + "  Nombre: " + AllTrim( ::getExcelString( "C" ) ) )

   if ( D():Clientes( ::nView ) )->( dbSeek( RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() ) ) )

      if dbLock( D():Clientes( ::nView ) )

         if !empty( ::getExcelString( "C" ) )
            
            do case
               case AllTrim( ::getExcelString( "B" ) ) == "1"

                  ( D():Clientes( ::nView ) )->Telefono  := AllTrim( ::getExcelString( "C" ) )

               case AllTrim( ::getExcelString( "B" ) ) == "2"

                  ( D():Clientes( ::nView ) )->Movil     := AllTrim( ::getExcelString( "C" ) )

            end case

         end if   

         ( D():Clientes( ::nView ) )->( dbunlock() )

      end if

   end if

   ::nCount++

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"