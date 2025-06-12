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

   ::cFicheroExcel            := "C:\ficheros\articulos.xls"

   /*
   Cambiar la fila de cominezo de la importacion-------------------------------
   */

   ::nFilaInicioImportacion   := 4

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

      if !::existeRegistro()
      
         ::importarCampos()

      end if 

      ::siguienteLinea()

   end if

   ::closeExcel()

Return nil

//---------------------------------------------------------------------------//

METHOD importarCampos()

   local nPos        := 0

   ( D():Articulos( ::nView ) )->( dbappend() )

   if Empty( ::getExcelString( "B" ) )
      ( D():Articulos( ::nView ) )->Codigo         := ::getExcelString( "B" )
   else
      ( D():Articulos( ::nView ) )->Codigo         := AllTrim( Str( ::getExcelNumeric( "B" ) ) )
   end if

   if Empty( ::getExcelString( "H" ) )
      ( D():Articulos( ::nView ) )->cRefAux        := ::getExcelString( "H" )
   end if

   if Empty( ::getExcelString( "I" ) )
      ( D():Articulos( ::nView ) )->cRefAux2       := ::getExcelString( "I" )
   end if
   
   if !empty( ::getExcelString( "C" ) )
      ( D():Articulos( ::nView ) )->Nombre         := ::getExcelString( "C" )
   end if 

   if !empty( ::getExcelString( "F" ) )
      ( D():Articulos( ::nView ) )->mComent         := ::getExcelString( "F" )
   end if 

   if !empty( ::getExcelNumeric( "AZ" ) )
      ( D():Articulos( ::nView ) )->pCosto         := ::getExcelNumeric( "AZ" )
   end if

   if !empty( ::getExcelNumeric( "BH" ) )
      ( D():Articulos( ::nView ) )->pVenta1        := ::getExcelNumeric( "BH" )
      ( D():Articulos( ::nView ) )->pVtaIva1       := ::getExcelNumeric( "BH" )
   end if

   if !empty( ::getExcelNumeric( "BI" ) )
      ( D():Articulos( ::nView ) )->pVenta2        := ::getExcelNumeric( "BI" )
      ( D():Articulos( ::nView ) )->pVtaIva2       := ::getExcelNumeric( "BI" )
   end if

   if !empty( ::getExcelNumeric( "BJ" ) )
      ( D():Articulos( ::nView ) )->pVenta3        := ::getExcelNumeric( "BJ" )
      ( D():Articulos( ::nView ) )->pVtaIva3       := ::getExcelNumeric( "BJ" )
   end if

   if !empty( ::getExcelNumeric( "FJ" ) )
      ( D():Articulos( ::nView ) )->Uuid           := ::getExcelString( "FJ" )
   end if

   if !empty( ::getExcelNumeric( "L" ) )
      ( D():Articulos( ::nView ) )->cPrvHab          := ::getExcelString( "L" )
   end if

   ( D():Articulos( ::nView ) )->TIPOIVA           := "G"

   ( D():Articulos( ::nView ) )->( dbcommit() )

   ( D():Articulos( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------// 

/*METHOD importarCampos() //Un solo código de barras

   if !empty( ::getExcelString( "F" ) )

   ( D():ArticulosCodigosBarras( ::nView ) )->( dbappend() )

   ( D():ArticulosCodigosBarras( ::nView ) )->cCodArt     := ::getExcelString( "A" )

   ( D():ArticulosCodigosBarras( ::nView ) )->cCodBar     := ::getExcelString( "F" )

   ( D():ArticulosCodigosBarras( ::nView ) )->lDefBar     := .t.

   ( D():ArticulosCodigosBarras( ::nView ) )->( dbcommit() )

   ( D():ArticulosCodigosBarras( ::nView ) )->( dbunlock() )

   end if 

Return nil*/

//---------------------------------------------------------------------------//

/*METHOD importarCampos() //varios códigos de barras

   local aCodigos
   local cCodigo

   if !empty( ::getExcelString( "G" ) )

      aCodigos    := hb_aTokens( ::getExcelString( "G" ), "," )

      if len( aCodigos ) > 0

         for each cCodigo in aCodigos

            ( D():ArticulosCodigosBarras( ::nView ) )->( dbappend() )

            ( D():ArticulosCodigosBarras( ::nView ) )->cCodArt     := ::getExcelString( "A" )

            ( D():ArticulosCodigosBarras( ::nView ) )->cCodBar     := AllTrim( cCodigo )
   
            ( D():ArticulosCodigosBarras( ::nView ) )->( dbcommit() )
   
            ( D():ArticulosCodigosBarras( ::nView ) )->( dbunlock() )

         next

      end if

   end if 

Return nil*/

//---------------------------------------------------------------------------// 

/*METHOD importarCampos()

   local cCodFam
   local nOrdAnt := ( D():Familias( ::nView ) )->( OrdSetFocus( "cNomFam" ) )
   local cCodArt

   if !empty( ::getExcelString( "C" ) )
   
      if !( D():Familias( ::nView ) )->( dbSeek( ::getExcelString( "C" ) ) )

         ( D():Familias( ::nView ) )->( dbappend() )

         cCodFam                                   := RJust( NextVal( Rtrim( dbLast( D():Familias( ::nView ), 1, , , "cCodFam" ) ) ), "0", 8 )

         ( D():Familias( ::nView ) )->cCodFam      := cCodFam

         ( D():Familias( ::nView ) )->cNomFam      := ::getExcelString( "C" )

         ( D():Familias( ::nView ) )->( dbcommit() )

         ( D():Familias( ::nView ) )->( dbunlock() )

      else

         cCodFam     := ( D():Familias( ::nView ) )->cCodFam

      end if 

      if Empty( ::getExcelString( "D" ) )
         cCodArt         := ::getExcelString( "A" )
      else
         nPos  := at( ",", ::getExcelString( "D" ) )

         if nPos == 0
            cCodArt      := ::getExcelString( "D" )
         else
            cCodArt      := Substr( ::getExcelString( "D" ), 1, nPos - 1 )
         end if
      end if

      if ( D():Articulos( ::nView ) )->( dbSeek( cCodArt ) )

         if dbLock( D():Articulos( ::nView ) )
            ( D():Articulos( ::nView ) )->Familia := cCodFam
            ( D():Articulos( ::nView ) )->( dbUnLock() )
         end if

      end if

   end if

   ( D():Familias( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

Return nil*/

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"