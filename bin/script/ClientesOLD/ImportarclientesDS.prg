 #include "FiveWin.Ch"

#include "Hbxml.ch"
#include "Hbclass.ch"
#include "Fileio.ch"
#include "Factu.ch" 
      
//---------------------------------------------------------------------------//

Function ImportarExcelArguelles( nView )                	 
	      
   local oImportarExcel    := TImportarExcelArticulos():New( nView )

   oImportarExcel:Run()

Return nil

//---------------------------------------------------------------------------//  

CLASS TImportarExcelArticulos FROM TImportarExcel

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

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := "C:\ficheros\DS\nombres.xls"

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
   
   local cCodArt        := ""
   local nRec           := ( D():Articulos( ::nView ) )->( Recno() )
   local nOrdAnt        := ( D():Articulos( ::nView ) )->( OrdSetFocus( "Codigo" ) )

   cCodArt              := AllTrim( ::getExcelString( "A" ) )

   if !Empty( AllTrim( ::getExcelString( "B" ) ) )

      if ( D():Articulos( ::nView ) )->( dbSeek( cCodArt ) )

         MsgWait( "Articulo: " + cCodArt + Space( 5 ) + AllTrim( ::getExcelString( "B" ) ), "AAA", 0.01 )

         if dbLock( D():Articulos( ::nView ) )

            ( D():Articulos( ::nView ) )->Nombre    := AllTrim( ::getExcelString( "B" ) )

            LogWrite( "Articulo: " + cCodArt + " - " + AllTrim( ::getExcelString( "B" ) ) )

            ( D():Articulos( ::nView ) )->( dbunlock() )

         end if

      end if

   end if

   ( D():Articulos( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():Articulos( ::nView ) )->( dbGoTo( nRec ) )

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"