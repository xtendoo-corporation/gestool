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

   DATA cCodigoFamilia

   DATA cCodigoTipo

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

   METHOD getFamilia()

   METHOD addFamilia( cNomFam )

   METHOD getTipoArt()

   METHOD addTipoArt( cNomTip )

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

   //MsgCombo( "Seleccione fila de inicio", "Fila:", { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, @::nFilaInicioImportacion )

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

   while !Empty( ::getExcelString( "A" ) )     ///  ( ::filaValida() )

      //if !Empty( ::getCodigoArticulo() )

         //MsgWait( "Artículo: " + AllTrim( ::getExcelString( "E" ) ), "Procesando" , 0.01 )

         if !::existeRegistro()
            ::importarArticulo()
         else
            ::reemplazaArticulo()
         end if 

      //end if

      ::siguienteLinea()

   end while

   ::closeExcel()

Return nil

//---------------------------------------------------------------------------//

METHOD reemplazaArticulo()

   if dbLock( D():Articulos( ::nView ) )

      if !empty( ::getExcelString( "E" ) )
         ( D():Articulos( ::nView ) )->Nombre         := ::getExcelString( "E" )
      end if 

      /*if !empty( ::getExcelNumeric( "G" ) )
         ( D():Articulos( ::nView ) )->pCosto         := ::getExcelNumeric( "G" )
      end if*/

      if !empty( ::getExcelNumeric( "G" ) )
         ( D():Articulos( ::nView ) )->pVenta1        := ::getExcelNumeric( "G" )
         ( D():Articulos( ::nView ) )->pVtaIva1       := ( ::getExcelNumeric( "G" ) * 1.21 )
      end if

      ( D():Articulos( ::nView ) )->cDesUbi           := ::getExcelString( "B" )

      ( D():Articulos( ::nView ) )->Descrip           := ::getExcelString( "V" )

      //::getFamilia()
      //( D():Articulos( ::nView ) )->Familia           := ::cCodigoFamilia

      //::getTipoArt()
      //( D():Articulos( ::nView ) )->cCodTip           := ::cCodigoTipo

      ( D():Articulos( ::nView ) )->( dbUnLock() )

   end if

   /*
   comprobamos código de barras el código de barras-------------------------------------------------
   */

   if !Empty( ::getExcelString( "R" ) ) .and. ::getExcelString( "R" ) != "N/D"

      if !D():SeekInOrd( D():ArticulosCodigosBarras( ::nView ), ::getCodigoArticulo() + ::getExcelString( "R" ), "cArtBar" )

         ( D():ArticulosCodigosBarras( ::nView ) )->( dbappend() )
      
         ( D():ArticulosCodigosBarras( ::nView ) )->cCodArt           := ::getCodigoArticulo()
         ( D():ArticulosCodigosBarras( ::nView ) )->cCodBar           := ::getExcelString( "R" )
      
         ( D():ArticulosCodigosBarras( ::nView ) )->( dbcommit() )

         ( D():ArticulosCodigosBarras( ::nView ) )->( dbunlock() )

      end if

   end if

Return nil

//---------------------------------------------------------------------------//

METHOD importarArticulo()

   ( D():Articulos( ::nView ) )->( dbappend() )
   
   ( D():Articulos( ::nView ) )->Codigo            := ::getCodigoArticulo()
   
   if !empty( ::getExcelString( "E" ) )
      ( D():Articulos( ::nView ) )->Nombre         := ::getExcelString( "E" )
   end if 

   /*if !empty( ::getExcelNumeric( "G" ) )
      ( D():Articulos( ::nView ) )->pCosto         := ::getExcelNumeric( "G" )
   end if*/

   if !empty( ::getExcelNumeric( "G" ) )
      ( D():Articulos( ::nView ) )->pVenta1        := ::getExcelNumeric( "G" )
      ( D():Articulos( ::nView ) )->pVtaIva1       := ( ::getExcelNumeric( "G" ) * 1.21 )
   end if

   ( D():Articulos( ::nView ) )->cDesUbi           := ::getExcelString( "B" )

   ( D():Articulos( ::nView ) )->Descrip           := ::getExcelString( "V" )

   //::getFamilia()
   //( D():Articulos( ::nView ) )->Familia           := ::cCodigoFamilia

   //::getTipoArt()
   //( D():Articulos( ::nView ) )->cCodTip           := ::cCodigoTipo

   do case
      case ::getExcelNumeric( "J" ) == 21
         ( D():Articulos( ::nView ) )->TIPOIVA     := "G"
      case ::getExcelNumeric( "J" ) == 10
         ( D():Articulos( ::nView ) )->TIPOIVA     := "N"
      case ::getExcelNumeric( "J" ) == 4
         ( D():Articulos( ::nView ) )->TIPOIVA     := "R"
      case ::getExcelNumeric( "J" ) == 0
         ( D():Articulos( ::nView ) )->TIPOIVA     := "E"
   end case
   
   ( D():Articulos( ::nView ) )->( dbcommit() )

   ( D():Articulos( ::nView ) )->( dbunlock() )

   /*
   Metemos el código de barras-------------------------------------------------
   */

   if !Empty( ::getExcelString( "R" ) )

      ( D():ArticulosCodigosBarras( ::nView ) )->( dbappend() )
      
      ( D():ArticulosCodigosBarras( ::nView ) )->cCodArt           := ::getCodigoArticulo()
      ( D():ArticulosCodigosBarras( ::nView ) )->cCodBar           := ::getExcelString( "R" )
      
      ( D():ArticulosCodigosBarras( ::nView ) )->( dbcommit() )

      ( D():ArticulosCodigosBarras( ::nView ) )->( dbunlock() )

   end if

Return nil

//---------------------------------------------------------------------------// 

METHOD getFamilia()

   ::cCodigoFamilia     := ""

   if Empty( ::getExcelString( "C" ) )
      Return nil
   end if

   if ( D():Familias( ::nView ) )->( dbSeek( Padr( ::getExcelString( "C" ), 40 ) ) )
      ::cCodigoFamilia  := ( D():Familias( ::nView ) )->cCodFam
   else
      ::addFamilia( Padr( ::getExcelString( "C" ), 40 ) )
   end if

Return nil

//---------------------------------------------------------------------------// 

METHOD addFamilia( cNomFam )

   local cNewCodigo

   ( D():Familias( ::nView ) )->( dbappend() )

   cNewCodigo                             := NextKey( dbLast( D():Familias( ::nView ), 1 ), D():Familias( ::nView ) )

   ( D():Familias( ::nView ) )->cCodFam   := cNewCodigo
   ( D():Familias( ::nView ) )->cNomFam   := cNomFam

   ( D():Familias( ::nView ) )->( dbcommit() )

   ( D():Familias( ::nView ) )->( dbunlock() )

   ::cCodigoFamilia                       := cNewCodigo

Return nil

//---------------------------------------------------------------------------// 

METHOD getTipoArt()

   ::cCodigoTipo     := ""

   if Empty( ::getExcelString( "D" ) )
      Return nil
   end if

   if ( D():ArticuloTipos( ::nView ) )->( dbSeek( Padr( ::getExcelString( "D" ), 4 ) ) )
      ::cCodigoTipo  := ( D():ArticuloTipos( ::nView ) )->cCodTip
   else
      ::addTipoArt( Padr( ::getExcelString( "D" ), 4 ) )
   end if

Return nil

//---------------------------------------------------------------------------// 

METHOD addTipoArt( cNomTip )

   local cNewCodigo

   ( D():ArticuloTipos( ::nView ) )->( dbappend() )

   cNewCodigo                                   := NextKey( dbLast( D():ArticuloTipos( ::nView ), 1 ), D():ArticuloTipos( ::nView ) )

   ( D():ArticuloTipos( ::nView ) )->cCodTip    := cNewCodigo
   ( D():ArticuloTipos( ::nView ) )->cNomTip    := cNomTip

   ( D():ArticuloTipos( ::nView ) )->( dbcommit() )

   ( D():ArticuloTipos( ::nView ) )->( dbunlock() )

   ::cCodigoTipo                                := cNewCodigo

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"