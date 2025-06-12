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

   METHOD getCampoClave()        INLINE ( ::getExcelNumeric( ::cColumnaCampoClave ) )

   METHOD getCodigoArticulo()    INLINE ( Padr( ::getExcelString( "A" ), 18 ) )

   METHOD procesaFicheroExcel()

   METHOD filaValida()
   
   METHOD siguienteLinea()       INLINE ( ++::nFilaInicioImportacion )

   METHOD existeRegistro()       INLINE ( D():gotoArticulos( ::getCodigoArticulo(), ::nView ) )

   METHOD importarArticulo()

   METHOD reemplazaArticulo()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := cGetFile( "*.*", "Selección de fichero" )

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 2

   //MsgCombo( "nFilaInicioImportacion", "AAA", { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, @::nFilaInicioImportacion )

   /*
   Columna de campo clave------------------------------------------------------
   */

   ::cColumnaCampoClave       := 'A'

   //MsgGet( "cColumnaCampoClave", "BBB", @::cColumnaCampoClave )

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

   while ::nFilaInicioImportacion < 1995

      //if ( ::filaValida() )

         if !Empty( AllTrim( ::getExcelString( "A" ) ) )

            MsgWait( "Asistencia: " + AllTrim( ::getExcelString( "A" ) ), "Procesando" , 1 )

            //if !::existeRegistro()
               ::importarArticulo()
            /*else
               ::reemplazaArticulo()
            end if */

         end if

      //end if

      ::siguienteLinea()

   end if

   ::closeExcel()

Return nil

//---------------------------------------------------------------------------//

METHOD reemplazaArticulo()

   if dbLock( D():Articulos( ::nView ) )

      if !empty( ::getExcelString( "E" ) )
         ( D():Articulos( ::nView ) )->Nombre         := ::getExcelString( "E" )
      end if 

      if !empty( ::getExcelNumeric( "K" ) )
         ( D():Articulos( ::nView ) )->pCosto         := ::getExcelNumeric( "K" )
      end if

      if !empty( ::getExcelNumeric( "L" ) )
         ( D():Articulos( ::nView ) )->pVenta1        := ( ::getExcelNumeric( "L" ) / 1.21 )
         ( D():Articulos( ::nView ) )->pVtaIva1       := ::getExcelNumeric( "L" )
      end if
            
      ( D():Articulos( ::nView ) )->( dbUnLock() )

   end if

   /*
   comprobamos código de barras el código de barras-------------------------------------------------
   */

   if !Empty( ::getExcelString( "D" ) )   

      if !D():SeekInOrd( D():ArticulosCodigosBarras( ::nView ), ::getCodigoArticulo() + ::getExcelString( "D" ), "cArtBar" )

         ( D():ArticulosCodigosBarras( ::nView ) )->( dbappend() )
      
         ( D():ArticulosCodigosBarras( ::nView ) )->cCodArt           := ::getCodigoArticulo()
         ( D():ArticulosCodigosBarras( ::nView ) )->cCodBar           := ::getExcelString( "D" )
      
         ( D():ArticulosCodigosBarras( ::nView ) )->( dbcommit() )

         ( D():ArticulosCodigosBarras( ::nView ) )->( dbunlock() )

      end if

   end if

Return nil

//---------------------------------------------------------------------------//

METHOD importarArticulo()

   ( D():Asistencias( ::nView ) )->( dbappend() )
   
   ( D():Asistencias( ::nView ) )->uuid            := ::getExcelString( "A" )
   
   if !empty( ::getExcelString( "B" ) )
      ( D():Asistencias( ::nView ) )->cCodUsr         := ::getExcelString( "B" )
   end if 

   if !empty( ::getExcelString( "C" ) )
      ( D():Asistencias( ::nView ) )->dFecEnt         := ctod( ::getExcelString( "C" ) )
   end if

   if !empty( ::getExcelString( "D" ) )
      ( D():Asistencias( ::nView ) )->cHorEnt         := strtran( ::getExcelString( "D" ), ":", "" )
   end if

   if !empty( ::getExcelString( "E" ) )
      ( D():Asistencias( ::nView ) )->dFecSal         := ctod( ::getExcelString( "E" ) )
   end if

   if !empty( ::getExcelString( "F" ) )
      ( D():Asistencias( ::nView ) )->cHorSal         := strtran( ::getExcelString( "F" ), ":", "" )
   end if

   ( D():Asistencias( ::nView ) )->( dbcommit() )

   ( D():Asistencias( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"