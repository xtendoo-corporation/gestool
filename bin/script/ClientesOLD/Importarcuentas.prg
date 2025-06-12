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

   ::cFicheroExcel            := "C:\ficheros\cuentas.xlsx"

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

   ( D():ClientesBancos( ::nView ) )->( dbappend() )

   ( D():ClientesBancos( ::nView ) )->cCodCli          := RJust( Str( int( ::getExcelNumeric( "A" ) ) + 1009 ), "0", RetNumCodCliEmp() )

   if !empty( ::getExcelString( "B" ) )
      ( D():ClientesBancos( ::nView ) )->cPaisIBAN     := SubStr( ::getExcelString( "B" ), 1, 2 )
      ( D():ClientesBancos( ::nView ) )->cCtrlIBAN     := SubStr( ::getExcelString( "B" ), 3, 2 )
      ( D():ClientesBancos( ::nView ) )->cEntBnc       := SubStr( ::getExcelString( "B" ), 5, 4 )
      ( D():ClientesBancos( ::nView ) )->cSucBnc       := SubStr( ::getExcelString( "B" ), 9, 4 )
      ( D():ClientesBancos( ::nView ) )->cDigBnc       := SubStr( ::getExcelString( "B" ), 13, 2 )
      ( D():ClientesBancos( ::nView ) )->cCtaBnc       := SubStr( ::getExcelString( "B" ), 15, 10 )
   end if 

   ( D():ClientesBancos( ::nView ) )->( dbcommit() )

   ( D():ClientesBancos( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"