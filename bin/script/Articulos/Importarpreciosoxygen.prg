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

   METHOD getCodigoArticulo()    INLINE ( Padr( ::getExcelString( "A" ), 18 ) )

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

   ::cFicheroExcel            := "C:\ficheros\PVPOXYGEN.xls"

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

   MsgWait( "Codigo: " + ::getCodigoArticulo(), "Procesando... " + Str( ::nCount ), 0.005 )

   if ( D():Articulos( ::nView ) )->( dbSeek( ::getCodigoArticulo() ) )

      if dbLock( D():Articulos( ::nView ) )

         if !empty( ::getExcelString( "C" ) )
            
            do case
               case AllTrim( ::getExcelString( "B" ) ) == "01"

                  ( D():Articulos( ::nView ) )->pVenta1  := ::getExcelNumeric( "C" )
                  ( D():Articulos( ::nView ) )->pVtaIva1 := ::getExcelNumeric( "C" ) * 1.21

               case AllTrim( ::getExcelString( "B" ) ) == "02"

                  ( D():Articulos( ::nView ) )->pVenta2  := ::getExcelNumeric( "C" )
                  ( D():Articulos( ::nView ) )->pVtaIva2 := ::getExcelNumeric( "C" ) * 1.21

               case AllTrim( ::getExcelString( "B" ) ) == "03"

                  ( D():Articulos( ::nView ) )->pVenta3  := ::getExcelNumeric( "C" )
                  ( D():Articulos( ::nView ) )->pVtaIva3 := ::getExcelNumeric( "C" ) * 1.21

               case AllTrim( ::getExcelString( "B" ) ) == "04"

                  ( D():Articulos( ::nView ) )->pVenta4  := ::getExcelNumeric( "C" )
                  ( D():Articulos( ::nView ) )->pVtaIva4 := ::getExcelNumeric( "C" ) * 1.21

               case AllTrim( ::getExcelString( "B" ) ) == "05"

                  ( D():Articulos( ::nView ) )->pVenta5  := ::getExcelNumeric( "C" )
                  ( D():Articulos( ::nView ) )->pVtaIva5 := ::getExcelNumeric( "C" ) * 1.21

            end case

         end if   

         ( D():Articulos( ::nView ) )->( dbunlock() )

      end if

   end if

   ::nCount++

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"