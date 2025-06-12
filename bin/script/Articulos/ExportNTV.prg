/******************************************************************************
Script creado a Chineret para exportar a ecommerce
******************************************************************************/

#include ".\Include\Factu.ch"
#define CRLF chr( 13 ) + chr( 10 )

static nView
static cSeparator
static cCarpeta
static cNameFileArticulos
static cNameFileFamilias
static cNameFileAgentes
static cNameFileFormaPago
static cNameFileClientes
static cNameFileCodigosBarras
static cNameFileImagenes
static lOpenFiles
static oMeter

//---------------------------------------------------------------------------//

function InicioHRB()

   lOpenFiles                 := .f.

   cNameFileArticulos         := "C:\ficheros\articulos.csv"
   cNameFileFamilias          := "C:\ficheros\familias.csv"
   cNameFileAgentes           := "C:\ficheros\agentes.csv"
   cNameFileFormaPago         := "C:\ficheros\formapago.csv"
   cNameFileClientes          := "C:\ficheros\clientes.csv"
   cNameFileCodigosBarras     := "C:\ficheros\codigosbarras.csv"
   cNameFileImagenes          := "C:\ficheros\imagenes.csv"

   cSeparator                 := ";"

   /*
   Abrimos los ficheros necesarios---------------------------------------------
   */

   if !OpenFiles( .f. )
      return .f.
   end if

   /*
   Damos valores por defacto a las variables-----------------------------------
   */

   CursorWait()

   /*
   Importamos los datos necesarios---------------------------------------------
   */
   
   ExportacionArticulos()
   ExportacionFamilias()
   ExportacionAgentes()
   ExportacionFormasPago()
   ExportacionClientes()
   ExportacionCodigosBarras()
   ExportacionImagenes()

   CursorWe()

   /*
   Cerramos los ficheros abiertos anteriormente--------------------------------
   */

   CloseFiles()

   MsgInfo( "Proceso finalizado." )

return .t.

//---------------------------------------------------------------------------//

static function OpenFiles()

   local oError
   local oBlock

   if lOpenFiles
      MsgStop( 'Imposible abrir ficheros' )
      Return ( .f. )
   end if

   CursorWait()

   oBlock         := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      lOpenFiles  := .t.

      nView    := D():CreateView()

   RECOVER USING oError

      lOpenFiles           := .f.

      msgStop( ErrorMessage( oError ), 'Imposible abrir las bases de datos' )

   END SEQUENCE

   ErrorBlock( oBlock )

   if !lOpenFiles
      CloseFiles()
   end if

   CursorWE()

return ( lOpenFiles )

//--------------------------------------------------------------------------//

static function CloseFiles()

   D():DeleteView( nView )

   lOpenFiles     := .f.

RETURN ( .t. )

//----------------------------------------------------------------------------//

static function ExportacionArticulos()

   local nHand
   local cTextoArticulo := ""

   CursorWait()

   oMeter               := TWaitMeter():New( , , ( D():Articulos( nView ) )->( LastRec() ) )

   /*
   Vamos la primera vuelta para los clientes-----------------------------------
   */

   ( D():Articulos( nView ) )->( dbGoTop() )

   while !( D():Articulos( nView ) )->( Eof() )

      cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->cCodCate )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->Codigo )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->Nombre )
      cTextoArticulo  += cSeparator   
      cTextoArticulo  += AllTrim( Trans( ( D():Articulos( nView ) )->pVtaIva1, "@ 999,999.99" ) )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( Trans( ( D():Articulos( nView ) )->pVtaIva2, "@ 999,999.99" ) )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( Trans( ( D():Articulos( nView ) )->pVtaIva3, "@ 999,999.99" ) )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( Trans( ( D():Articulos( nView ) )->pVtaIva4, "@ 999,999.99" ) )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( Trans( ( D():Articulos( nView ) )->pVtaIva5, "@ 999,999.99" ) )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( Trans( ( D():Articulos( nView ) )->pVtaIva6, "@ 999,999.99" ) )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( Trans( ( D():Articulos( nView ) )->nCajEnt, "@ 999,999.99" ) )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->TipoIva )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->Familia )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->cSubFam )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->Descrip )
      cTextoArticulo  += cSeparator
      cTextoArticulo  += AllTrim( Trans( ( D():Articulos( nView ) )->nunicaja, "@ 999,999.99" ) )

      cTextoArticulo  += CRLF

      ( D():Articulos( nView ) )->( dbSkip() )

      oMeter:oProgress:AutoInc()

   end while

   StrTran( cTextoArticulo, ",", "." )

   if !Empty( cTextoArticulo )

      fErase( cNameFileArticulos )
      nHand       := fCreate( cNameFileArticulos )
      fWrite( nHand, cTextoArticulo )
      fClose( nHand )

      MsgWait( "Fichero exportado correctamente en " + cNameFileArticulos, "Terminado", 1 )

   end if

   CursorWE()

Return .t.

//---------------------------------------------------------------------------//

static function ExportacionFamilias()
   
   local nHand
   local cTextoFamilia := ""

   CursorWait()

   oMeter               := TWaitMeter():New( , , ( D():Familias( nView ) )->( LastRec() ) )

   /*
   Vamos la primera vuelta para los clientes-----------------------------------
   */

   ( D():Familias( nView ) )->( dbGoTop() )

   while !( D():Familias( nView ) )->( Eof() )

      cTextoFamilia  += AllTrim( ( D():Familias( nView ) )->cNomFam )
      cTextoFamilia  += cSeparator
      cTextoFamilia  += AllTrim( ( D():Familias( nView ) )->cCodFam )

      cTextoFamilia  += CRLF

      ( D():Familias( nView ) )->( dbSkip() )

      oMeter:oProgress:AutoInc()

   end while

   if !Empty( cTextoFamilia )

      fErase( cNameFileFamilias )
      nHand       := fCreate( cNameFileFamilias )
      fWrite( nHand, cTextoFamilia )
      fClose( nHand )

      MsgWait( "Fichero exportado correctamente en " + cNameFileFamilias, "Terminado", 1 )

   end if

   CursorWE()

Return .t.

//---------------------------------------------------------------------------//

static function ExportacionAgentes()

   local nHand
   local cTextoAgentes := ""

   CursorWait()

   oMeter               := TWaitMeter():New( , , ( D():Agentes( nView ) )->( LastRec() ) )

   /*
   Vamos la primera vuelta para los clientes-----------------------------------
   */

   ( D():Agentes( nView ) )->( dbGoTop() )

   while !( D():Agentes( nView ) )->( Eof() )

      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->ccodage )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->cdninif )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->cdirage )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->cpobage )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->cprov )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->cptlage )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->ctfoage )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->cfaxage )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->cmovage )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->mcoment )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( Trans( ( D():Agentes( nView ) )->ncom1, "@ 999,999.99" ) )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->capeage )
      cTextoAgentes  += cSeparator
      cTextoAgentes  += AllTrim( ( D():Agentes( nView ) )->cnbrage )

      cTextoAgentes  += CRLF

      ( D():Agentes( nView ) )->( dbSkip() )

      oMeter:oProgress:AutoInc()

   end while

   StrTran( cTextoAgentes, ",", "." )

   if !Empty( cTextoAgentes )

      fErase( cNameFileAgentes )
      nHand       := fCreate( cNameFileAgentes )
      fWrite( nHand, cTextoAgentes )
      fClose( nHand )

      MsgWait( "Fichero exportado correctamente en " + cNameFileAgentes, "Terminado", 1 )

   end if

   CursorWE()

Return .t.

//---------------------------------------------------------------------------//

static function ExportacionFormasPago()

   local nHand
   local cTextoFormaPago := ""

   CursorWait()

   oMeter               := TWaitMeter():New( , , ( D():FormasPago( nView ) )->( LastRec() ) )

   /*
   Vamos la primera vuelta para los clientes-----------------------------------
   */

   ( D():FormasPago( nView ) )->( dbGoTop() )

   while !( D():FormasPago( nView ) )->( Eof() )

      cTextoFormaPago  += AllTrim( ( D():FormasPago( nView ) )->cCodPago )
      cTextoFormaPago  += cSeparator
      cTextoFormaPago  += AllTrim( ( D():FormasPago( nView ) )->cDesPago )
      cTextoFormaPago  += cSeparator
      cTextoFormaPago  += AllTrim( Str( ( D():FormasPago( nView ) )->nTipPgo ) )
      cTextoFormaPago  += cSeparator
      cTextoFormaPago  += AllTrim( Str( ( D():FormasPago( nView ) )->nPlazos ) )

      cTextoFormaPago  += CRLF

      ( D():FormasPago( nView ) )->( dbSkip() )

      oMeter:oProgress:AutoInc()

   end while

   StrTran( cTextoFormaPago, ",", "." )

   if !Empty( cTextoFormaPago )

      fErase( cNameFileFormaPago )
      nHand       := fCreate( cNameFileFormaPago )
      fWrite( nHand, cTextoFormaPago )
      fClose( nHand )

      MsgWait( "Fichero exportado correctamente en " + cNameFileFormaPago, "Terminado", 1 )

   end if

   CursorWE()

Return .t.

//---------------------------------------------------------------------------//

static function ExportacionClientes()

   local nHand
   local cTextoClientes := ""

   CursorWait()

   oMeter               := TWaitMeter():New( , , ( D():Clientes( nView ) )->( LastRec() ) )

   /*
   Vamos la primera vuelta para los clientes-----------------------------------
   */

   ( D():Clientes( nView ) )->( dbGoTop() )

   while !( D():Clientes( nView ) )->( Eof() )

      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->Cod )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->Titulo )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->Nif )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->Domicilio )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->Poblacion )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->Provincia )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->CodPostal )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->Telefono )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->Fax )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->Movil )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->NbrEst )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->CodPago )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( Str( ( D():Clientes( nView ) )->nDtoEsp ) )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( Str( ( D():Clientes( nView ) )->nRegIva ) )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->cAgente )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->mComent )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->CodPostal )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->cMeiInt )
      cTextoClientes  += cSeparator
      cTextoClientes  += AllTrim( ( D():Clientes( nView ) )->cPercto )

      cTextoClientes  += CRLF

      ( D():Clientes( nView ) )->( dbSkip() )

      oMeter:oProgress:AutoInc()

   end while

   StrTran( cTextoClientes, ",", "." )

   if !Empty( cTextoClientes )

      fErase( cNameFileClientes )
      nHand       := fCreate( cNameFileClientes )
      fWrite( nHand, cTextoClientes )
      fClose( nHand )

      MsgWait( "Fichero exportado correctamente en " + cNameFileClientes, "Terminado", 1 )

   end if

   CursorWE()

Return .t.

//---------------------------------------------------------------------------//

static function ExportacionCodigosBarras()

   local nHand
   local cTextoCodigoBarras := ""

   CursorWait()

   oMeter               := TWaitMeter():New( , , ( D():ArticulosCodigosBarras( nView ) )->( LastRec() ) )

   /*
   Vamos la primera vuelta para los clientes-----------------------------------
   */

   ( D():ArticulosCodigosBarras( nView ) )->( dbGoTop() )

   while !( D():ArticulosCodigosBarras( nView ) )->( Eof() )

      cTextoCodigoBarras  += AllTrim( ( D():ArticulosCodigosBarras( nView ) )->cCodArt )
      cTextoCodigoBarras  += cSeparator
      cTextoCodigoBarras  += AllTrim( ( D():ArticulosCodigosBarras( nView ) )->cCodBar )

      cTextoCodigoBarras  += CRLF

      ( D():ArticulosCodigosBarras( nView ) )->( dbSkip() )

      oMeter:oProgress:AutoInc()

   end while

   if !Empty( cTextoCodigoBarras )

      fErase( cNameFileCodigosBarras )
      nHand       := fCreate( cNameFileCodigosBarras )
      fWrite( nHand, cTextoCodigoBarras )
      fClose( nHand )

      MsgWait( "Fichero exportado correctamente en " + cNameFileCodigosBarras, "Terminado", 1 )

   end if

   CursorWE()

Return .t.

//---------------------------------------------------------------------------//

static function ExportacionImagenes()

   local nHand
   local cTextoImagenes := ""

   CursorWait()

   oMeter               := TWaitMeter():New( , , ( D():ArticuloImagenes( nView ) )->( LastRec() ) )

   /*
   Vamos la primera vuelta para los clientes-----------------------------------
   */

   ( D():ArticuloImagenes( nView ) )->( dbGoTop() )

   while !( D():ArticuloImagenes( nView ) )->( Eof() )

      cTextoImagenes  += AllTrim( ( D():ArticuloImagenes( nView ) )->cCodArt )
      cTextoImagenes  += cSeparator
      cTextoImagenes  += AllTrim( ( D():ArticuloImagenes( nView ) )->cImgArt )

      cTextoImagenes  += CRLF

      ( D():ArticuloImagenes( nView ) )->( dbSkip() )

      oMeter:oProgress:AutoInc()

   end while

   if !Empty( cTextoImagenes )

      fErase( cNameFileImagenes )
      nHand       := fCreate( cNameFileImagenes )
      fWrite( nHand, cTextoImagenes )
      fClose( nHand )

      MsgWait( "Fichero exportado correctamente en " + cNameFileImagenes, "Terminado", 1 )

   end if

   CursorWE()

Return .t.

//---------------------------------------------------------------------------//