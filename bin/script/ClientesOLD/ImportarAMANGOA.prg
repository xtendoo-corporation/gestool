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

   METHOD getCampoClave()        INLINE ( ::getExcelString( ::cColumnaCampoClave ) )

   METHOD procesaFicheroExcel()

   METHOD filaValida()
   
   METHOD siguienteLinea()       INLINE ( ++::nFilaInicioImportacion )

   METHOD existeRegistro()       INLINE ( D():gotoArticulos( ::getCampoClave(), ::nView ) )

   METHOD importarCampos()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := "C:\ficheros\articulos.xls"

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

   local nRec     := ( D():ArticulosCodigosBarras( ::nView ) )->( Recno() )
   local nOrdAnt  := ( D():ArticulosCodigosBarras( ::nView ) )->( OrdSetFocus( "cArtBar" ) )

   Msgwait( Padr( ::getExcelString( "C" ), 18 ) + Padr( ::getExcelString( "D" ), 20 ), "lo que busco", 0.1 )

   if !empty( ::getExcelString( "C" ) ) .and. !empty( ::getExcelString( "D" ) )

      if !( D():ArticulosCodigosBarras( ::nView ) )->( dbSeek( Padr( ::getExcelString( "C" ), 18 ) + Padr( ::getExcelString( "D" ), 20 ) ) )

         ( D():ArticulosCodigosBarras( ::nView ) )->( dbappend() )

         ( D():ArticulosCodigosBarras( ::nView ) )->cCodArt     := Padr( ::getExcelString( "C" ), 18 )

         ( D():ArticulosCodigosBarras( ::nView ) )->cCodBar     := Padr( ::getExcelString( "D" ), 20 )

         ( D():ArticulosCodigosBarras( ::nView ) )->( dbcommit() )

         ( D():ArticulosCodigosBarras( ::nView ) )->( dbunlock() )

         //Msgwait( Padr( ::getExcelString( "C" ), 18 ) + Padr( ::getExcelString( "D" ), 20 ), "Dentro", 1 )

      //else

         //Msgwait( Padr( ::getExcelString( "C" ), 18 ) + Padr( ::getExcelString( "D" ), 20 ), "Fuera", 1 )

      end if

   end if 

   ( D():ArticulosCodigosBarras( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():ArticulosCodigosBarras( ::nView ) )->( dbGoTo( nRec ) )

Return nil

//---------------------------------------------------------------------------//

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"