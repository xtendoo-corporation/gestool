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

   ::nFilaInicioImportacion   := 1

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

   while ( ::filaValida() )

      if !Empty( ::getCodigoArticulo() )

         MsgWait( "Artículo: " + AllTrim( ::getExcelString( "A" ) ), "Procesando" , 0.1 )

         //if !::existeRegistro()
            ::importarArticulo()
         /*else
            ::reemplazaArticulo()
         end if */

      end if

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

   ( D():Articulos( ::nView ) )->( dbappend() )
   
   ( D():Articulos( ::nView ) )->Codigo            := ::getCodigoArticulo()
   
   if !empty( ::getExcelString( "B" ) )
      ( D():Articulos( ::nView ) )->Nombre         := ::getExcelString( "B" )
   end if 

   if !empty( ::getExcelNumeric( "E" ) )
      ( D():Articulos( ::nView ) )->pCosto         := ::getExcelNumeric( "E" )
   end if

   if !empty( ::getExcelNumeric( "C" ) )
      ( D():Articulos( ::nView ) )->pVenta1       := ::getExcelNumeric( "C" )

      do case
         case ::getExcelString( "D" ) == "21"
            ( D():Articulos( ::nView ) )->TIPOIVA  := "G"
            ( D():Articulos( ::nView ) )->pVtaIva1  := ( ::getExcelNumeric( "D" ) * 1.21 )
         case ::getExcelString( "D" ) == "10"
            ( D():Articulos( ::nView ) )->TIPOIVA  := "N"
            ( D():Articulos( ::nView ) )->pVtaIva1  := ( ::getExcelNumeric( "D" ) * 1.10 )
         case ::getExcelString( "D" ) == "4"
            ( D():Articulos( ::nView ) )->TIPOIVA  := "S"
            ( D():Articulos( ::nView ) )->pVtaIva1  := ( ::getExcelNumeric( "D" ) * 1.04 )
         case ::getExcelString( "D" ) == "12"
            ( D():Articulos( ::nView ) )->TIPOIVA  := "A"
            ( D():Articulos( ::nView ) )->pVtaIva1  := ( ::getExcelNumeric( "D" ) * 1.12 )
         otherwise
            ( D():Articulos( ::nView ) )->TIPOIVA  := "E"
            ( D():Articulos( ::nView ) )->pVtaIva1  := ::getExcelNumeric( "D" )
      endcase

   end if

   if !empty( ::getExcelString( "G" ) )
      ( D():Articulos( ::nView ) )->FAMILIA         := FamiliasModel():getField( 'cCodFam', 'cNomFam', AllTrim( ::getExcelString( "G" ) ) )
   end if 

   if !empty( ::getExcelString( "H" ) )
      ( D():Articulos( ::nView ) )->CCODTIP         := TiposArticulosModel():getField( 'cCodTip', 'cNomTip', AllTrim( ::getExcelString( "H" ) ) )
   end if 

   if !empty( ::getExcelString( "F" ) )
      ( D():Articulos( ::nView ) )->cDesUbi         := ::getExcelString( "F" )
   end if 


   ( D():Articulos( ::nView ) )->( dbcommit() )

   ( D():Articulos( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"