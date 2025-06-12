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

   METHOD run2()

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

   ::cFicheroExcel            := "C:\ficheros\BB\clientes.xls"

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
   
   local cCodCli        := ""
   local nRec           := ( D():Clientes( ::nView ) )->( Recno() )
   local nOrdAnt        := ( D():Clientes( ::nView ) )->( OrdSetFocus( "COD" ) )

   cCodCli              := AllTrim( ::getExcelString( "A" ) )

   if SubStr( cCodCli, 1, 1 ) == "B"
      cCodCli           := SubStr( cCodCli, 2 )
   end if

   cCodCli              := RJust( cCodCli, "0", RetNumCodCliEmp() )

   //MsgWait( "Clienteaaa: " + cCodCli, "AAA", 0.5 )

   if ( D():Clientes( ::nView ) )->( dbSeek( cCodCli ) )

      MsgWait( "Cliente: " + cCodCli + " - " + ( D():Clientes( ::nView ) )->Titulo, "BBBBBBBB", 0.01 )

      if dbLock( D():Clientes( ::nView ) )

         if !empty( ::getExcelString( "E" ) )
            ( D():Clientes( ::nView ) )->cAgente       := SubStr( ::getExcelString( "E" ), 1, 3 )
         else
            ( D():Clientes( ::nView ) )->cAgente       := Space(3)
         end if

         LogWrite( "Cliente: " + cCodCli )
         LogWrite( "   Agente: " + SubStr( ::getExcelString( "E" ), 1, 3 ) )

         ( D():Clientes( ::nView ) )->( dbunlock() )

      end if

   end if

   ( D():Clientes( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():Clientes( ::nView ) )->( dbGoTo( nRec ) )

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

METHOD run2()

   ( D():Clientes( ::nView ) )->( dbGoTop() )

   while !( D():Clientes( ::nView ) )->( Eof() )

      if dbLock( D():Clientes( ::nView ) )

         ( D():Clientes( ::nView ) )->NbrEst       := ( D():Clientes( ::nView ) )->Titulo
         ( D():Clientes( ::nView ) )->Titulo       := ( D():Clientes( ::nView ) )->DirEst
         ( D():Clientes( ::nView ) )->DirEst       := ""
         
         ( D():Clientes( ::nView ) )->( dbunlock() )

      end if

   ( D():Clientes( ::nView ) )->( dbskip() )

   end while

Return nil

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"