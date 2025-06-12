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

   ::cFicheroExcel            := "C:\ficheros\ClientesFactucon.xls"

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

   ( D():Clientes( ::nView ) )->( dbappend() )

   ( D():Clientes( ::nView ) )->Cod                := RJust( ::getExcelString( "A" ), "0", RetNumCodCliEmp() )

   if !empty( ::getExcelString( "B" ) )
      ( D():Clientes( ::nView ) )->Titulo          := upper( ::getExcelString( "C" ) )
   end if 

   if !empty( ::getExcelString( "H" ) )
      ( D():Clientes( ::nView ) )->Nif             := ::getExcelString( "H" )
   end if 

   if !empty( ::getExcelString( "C" ) )
      ( D():Clientes( ::nView ) )->Domicilio       := ::getExcelString( "C" )
   end if

   if !empty( ::getExcelString( "D" ) )
      ( D():Clientes( ::nView ) )->Poblacion       := ::getExcelString( "D" )
   end if

   if !empty( ::getExcelString( "N" ) )
      ( D():Clientes( ::nView ) )->Telefono        := ::getExcelString( "N" )
   end if

   if !empty( ::getExcelString( "P" ) )
      ( D():Clientes( ::nView ) )->Fax             := ::getExcelString( "P" )
   end if

   if !empty( ::getExcelString( "O" ) )
      ( D():Clientes( ::nView ) )->Movil           := ::getExcelString( "O" )
   end if

   if !empty( ::getExcelString( "E" ) )
      ( D():Clientes( ::nView ) )->NbrEst          := ::getExcelString( "E" )
   end if

   if !empty( ::getExcelString( "F" ) )
      ( D():Clientes( ::nView ) )->Direst          := ::getExcelString( "F" ) + Space( 1 ) +  ::getExcelString( "G" )
   end if

   if !empty( ::getExcelString( "Q" ) )
      ( D():Clientes( ::nView ) )->cMeiInt         := ::getExcelString( "Q" )
   end if

   if !empty( ::getExcelString( "R" ) )
      ( D():Clientes( ::nView ) )->cWebInt         := ::getExcelString( "R" )
   end if

   if !empty( ::getExcelString( "S" ) )
      ( D():Clientes( ::nView ) )->cPerCto         := ::getExcelString( "S" )
   end if

   ( D():Clientes( ::nView ) )->CodPago            := "00"
   ( D():Clientes( ::nView ) )->cCodAlm            := "000"
   ( D():Clientes( ::nView ) )->CopiasF            := 1
   ( D():Clientes( ::nView ) )->nTipCli            := 1
   ( D():Clientes( ::nView ) )->Serie              := "A"
   ( D():Clientes( ::nView ) )->lChgPre            := .t.
   ( D():Clientes( ::nView ) )->cCodUsr            := Auth():Codigo()
   ( D():Clientes( ::nView ) )->dFecChg            := GetSysDate()
   ( D():Clientes( ::nView ) )->cTimChg            := Time()
   ( D():Clientes( ::nView ) )->cDtoEsp            := Padr( "General", 50 )
   ( D():Clientes( ::nView ) )->cDpp               := Padr( "Pronto pago", 50 )
   ( D():Clientes( ::nView ) )->cDtoAtp            := Padr( "Atipico", 50 )

   ( D():Clientes( ::nView ) )->( dbcommit() )

   ( D():Clientes( ::nView ) )->( dbunlock() )

   ::nCount++

Return nil

//---------------------------------------------------------------------------// 

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"