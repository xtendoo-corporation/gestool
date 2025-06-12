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

   METHOD AddCabecera()

   METHOD AddLinea()

   METHOD AddPago()

END CLASS

//----------------------------------------------------------------------------//

METHOD New( nView )

   ::nView                    := nView

   /*
   Cambiar el nombre del fichero-----------------------------------------------
   */

   ::cFicheroExcel            := "C:\ficheros\tickets.xls"

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

      if !::existeRegistro()
      
         ::importarCampos()

      end if 

      ::siguienteLinea()

   end if

   ::closeExcel()

Return nil

//---------------------------------------------------------------------------//

METHOD importarCampos()

   MsgWait( ::getExcelString( "A" ), "Ticket", 0.001 )

   ::AddCabecera()

   ::AddLinea()

   ::AddPago()

Return nil

//---------------------------------------------------------------------------// 

METHOD AddCabecera()

   ( D():TiketsClientes( ::nView ) )->( dbappend() )

   ( D():TiketsClientes( ::nView ) )->cSerTik         := "A"
   ( D():TiketsClientes( ::nView ) )->cNumTik         := ::getExcelString( "A" )
   ( D():TiketsClientes( ::nView ) )->cSufTik         := "00"
   ( D():TiketsClientes( ::nView ) )->cTipTik         := SAVTIK
   ( D():TiketsClientes( ::nView ) )->cTurTik         := cCurSesion()
   ( D():TiketsClientes( ::nView ) )->dFecTik         := cTod( ::getExcelString( "G" ) )
   ( D():TiketsClientes( ::nView ) )->cHorTik         := "00:00"
   ( D():TiketsClientes( ::nView ) )->cCcjTik         := "000"
   ( D():TiketsClientes( ::nView ) )->cNcjTik         := "000"
   ( D():TiketsClientes( ::nView ) )->cAlmTik         := "000"
   ( D():TiketsClientes( ::nView ) )->cCliTik         := "0000000"
   ( D():TiketsClientes( ::nView ) )->nTarifa         := 1
   ( D():TiketsClientes( ::nView ) )->cNomTik         := "CLIENTE DE CONTADO"
   ( D():TiketsClientes( ::nView ) )->lModCli         := .t.
   ( D():TiketsClientes( ::nView ) )->cFpgTik         := "00"
   ( D():TiketsClientes( ::nView ) )->nCobTik         := ::getExcelNumeric( "D" )
   ( D():TiketsClientes( ::nView ) )->nCamTik         := 0
   ( D():TiketsClientes( ::nView ) )->cDivTik         := "EUR"
   ( D():TiketsClientes( ::nView ) )->nVdvTik         := 1
   ( D():TiketsClientes( ::nView ) )->lPgdTik         := .t.
   ( D():TiketsClientes( ::nView ) )->lLiqTik         := .t.
   ( D():TiketsClientes( ::nView ) )->dFecCre         := cTod( ::getExcelString( "G" ) )
   ( D():TiketsClientes( ::nView ) )->cTimCre         := "00:00"
   ( D():TiketsClientes( ::nView ) )->cCodDlg         := "00"
   ( D():TiketsClientes( ::nView ) )->cDtoEsp         := "General"
   ( D():TiketsClientes( ::nView ) )->cDpp            := "Pronto pago"
   ( D():TiketsClientes( ::nView ) )->nTotNet         := ::getExcelNumeric( "E" )
   ( D():TiketsClientes( ::nView ) )->nTotIva         := ::getExcelNumeric( "F" )
   ( D():TiketsClientes( ::nView ) )->nTotTik         := ::getExcelNumeric( "D" )
   ( D():TiketsClientes( ::nView ) )->nRegIva         := 1
   ( D():TiketsClientes( ::nView ) )->tFecTik         := "00:00"
   ( D():TiketsClientes( ::nView ) )->uuid            := win_uuidcreatestring()

   ( D():TiketsClientes( ::nView ) )->( dbcommit() )

   ( D():TiketsClientes( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------//

METHOD AddLinea()

   ( D():TiketsLineas( ::nView ) )->( dbappend() )

   ( D():TiketsLineas( ::nView ) )->cSerTil     := "A"
   ( D():TiketsLineas( ::nView ) )->cNumTil     := ::getExcelString( "A" )
   ( D():TiketsLineas( ::nView ) )->cSufTil     := "00"
   ( D():TiketsLineas( ::nView ) )->cTipTil     := SAVTIK
   ( D():TiketsLineas( ::nView ) )->cCbaTil     := ::getExcelString( "C" )
   ( D():TiketsLineas( ::nView ) )->cNomTil     := ::getExcelString( "B" )
   ( D():TiketsLineas( ::nView ) )->nPvpTil     := ::getExcelNumeric( "D" )
   ( D():TiketsLineas( ::nView ) )->nUntTil     := 1
   ( D():TiketsLineas( ::nView ) )->nIvaTil     := ::getExcelNumeric( "I" )
   ( D():TiketsLineas( ::nView ) )->cAlmLin     := "000"
   ( D():TiketsLineas( ::nView ) )->nNumLin     := 1
   ( D():TiketsLineas( ::nView ) )->cCodUsr     := "000"
   ( D():TiketsLineas( ::nView ) )->dFecTik     := cTod( ::getExcelString( "G" ) )
   ( D():TiketsLineas( ::nView ) )->tFecTik     := "00:00"
   ( D():TiketsLineas( ::nView ) )->nPosPrint   := 1
   ( D():TiketsLineas( ::nView ) )->uuid        := win_uuidcreatestring()

   ( D():TiketsLineas( ::nView ) )->( dbcommit() )

   ( D():TiketsLineas( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------//

METHOD AddPago()

   ( D():TiketsCobros( ::nView ) )->( dbappend() )

   ( D():TiketsCobros( ::nView ) )->cSerTik     := "A"
   ( D():TiketsCobros( ::nView ) )->cNumTik     := ::getExcelString( "A" )
   ( D():TiketsCobros( ::nView ) )->cSufTik     := "00"
   ( D():TiketsCobros( ::nView ) )->nNumRec     := 1
   ( D():TiketsCobros( ::nView ) )->cCodCaj     := "000"
   ( D():TiketsCobros( ::nView ) )->dPgoTik     := cTod( ::getExcelString( "G" ) )
   ( D():TiketsCobros( ::nView ) )->cTimTik     := "00:00"
   ( D():TiketsCobros( ::nView ) )->cFpgPgo     := "00"
   ( D():TiketsCobros( ::nView ) )->nImpTik     := ::getExcelNumeric( "D" )
   ( D():TiketsCobros( ::nView ) )->cDivPgo     := "EUR"
   ( D():TiketsCobros( ::nView ) )->nVdvPgo     := 1
   ( D():TiketsCobros( ::nView ) )->cTurPgo     := cCurSesion()

   ( D():TiketsCobros( ::nView ) )->( dbcommit() )

   ( D():TiketsCobros( ::nView ) )->( dbunlock() )

Return nil

//---------------------------------------------------------------------------//

METHOD filaValida()

Return ( !empty( ::getExcelValue( ::cColumnaCampoClave ) ) )

//---------------------------------------------------------------------------//

#include "ImportarExcel.prg"