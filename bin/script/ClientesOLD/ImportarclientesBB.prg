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

   ( D():Clientes( ::nView ) )->( dbappend() )

   //MsgWait( ::getExcelString( "B" ), "Procesando... " + Str( ::nCount ), 0.1 )

   ( D():Clientes( ::nView ) )->Cod             := RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() )

   if !empty( ::getExcelString( "B" ) )
      ( D():Clientes( ::nView ) )->Titulo       := ::getExcelString( "B" )
   end if 

   if !empty( ::getExcelString( "AG" ) )
      ( D():Clientes( ::nView ) )->Nif          := ::getExcelString( "AG" )
   end if 

   if !empty( ::getExcelString( "AI" ) )
      ( D():Clientes( ::nView ) )->NbrEst       := ::getExcelString( "AI" )
   end if

   if !empty( ::getExcelString( "C" ) )
      ( D():Clientes( ::nView ) )->Domicilio    := ::getExcelString( "C" )
   end if

   if !empty( ::getExcelString( "E" ) )
      ( D():Clientes( ::nView ) )->Poblacion    := ::getExcelString( "E" )
   end if

   if !empty( ::getExcelString( "F" ) )
      ( D():Clientes( ::nView ) )->Provincia    := ::getExcelString( "F" )
   end if

   if !empty( ::getExcelString( "D" ) )
      ( D():Clientes( ::nView ) )->CodPostal    := ::getExcelString( "D" )
   end if

   if !empty( ::getExcelString( "H" ) )
      ( D():Clientes( ::nView ) )->Telefono     := ::getExcelString( "H" )
   end if

   if !empty( ::getExcelString( "G" ) )
      ( D():Clientes( ::nView ) )->cPerCto     := ::getExcelString( "G" )
   end if

   if !empty( ::getExcelString( "I" ) )
      ( D():Clientes( ::nView ) )->Movil        := ::getExcelString( "I" )
   end if

   if !empty( ::getExcelString( "L" ) )
      ( D():Clientes( ::nView ) )->Fax          := ::getExcelString( "L" )
   end if

   if !empty( ::getExcelString( "I" ) )
      ( D():Clientes( ::nView ) )->SubCta       := ::getExcelString( "I" )
   end if

   if !empty( ::getExcelString( "M" ) )
      ( D():Clientes( ::nView ) )->cMeiInt      := ::getExcelString( "M" )
   end if

   if !empty( ::getExcelString( "N" ) )
      ( D():Clientes( ::nView ) )->cWebInt      := ::getExcelString( "N" )
   end if

   if !empty( ::getExcelString( "P" ) )
      ( D():Clientes( ::nView ) )->CodPago      := SubStr( AllTrim( ::getExcelString( "P" ) ), 1, 2 )
   end if

   if !empty( ::getExcelString( "X" ) )
      ( D():Clientes( ::nView ) )->DiaPago      := Val( AllTrim( ::getExcelString( "X" ) ) )
   end if

   if !empty( ::getExcelString( "Y" ) )
      ( D():Clientes( ::nView ) )->DiaPago2     := Val( AllTrim( ::getExcelString( "Y" ) ) )
   end if

   if !empty( ::getExcelString( "AB" ) )
      ( D():Clientes( ::nView ) )->nDtoEsp      := ::getExcelNumeric( "AB" )
   end if

   if !empty( ::getExcelString( "AN" ) )
      ( D():Clientes( ::nView ) )->nDtoEsp      := ::getExcelNumeric( "AN" )
   end if

   if !empty( ::getExcelString( "AE" ) )
      ( D():Clientes( ::nView ) )->lReq         := ( AllTrim( ::getExcelString( "AE" ) ) == "S" )
   end if

   if !empty( ::getExcelString( "AR" ) )
      ( D():Clientes( ::nView ) )->nTarifa         := ::getExcelNumeric( "AR" )
   end if

   if !empty( ::getExcelString( "BL" ) )
      ( D():Clientes( ::nView ) )->cAgente         := RJust( ::getExcelString( "A" ), "0", 3 )
   end if

   if !empty( ::getExcelString( "AU" ) )
      ( D():Clientes( ::nView ) )->cDomEnt      := ::getExcelString( "AU" )
   end if

   if !empty( ::getExcelString( "AW" ) )
      ( D():Clientes( ::nView ) )->cPobEnt      := ::getExcelString( "AW" )
   end if

   if !empty( ::getExcelString( "AV" ) )
      ( D():Clientes( ::nView ) )->cCPEnt       := ::getExcelString( "AV" )
   end if

   if !empty( ::getExcelString( "AX" ) )
      ( D():Clientes( ::nView ) )->cPrvEnt      := ::getExcelString( "AX" )
   end if

   if !empty( ::getExcelString( "BE" ) )
      ( D():Clientes( ::nView ) )->mComent      := ::getExcelString( "BE" )
   end if

   ( D():Clientes( ::nView ) )->Uuid         := win_uuidcreatestring()
   ( D():Clientes( ::nView ) )->cCodAlm         := "000"

   ( D():Clientes( ::nView ) )->( dbcommit() )

   ( D():Clientes( ::nView ) )->( dbunlock() )

   ::nCount++

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"