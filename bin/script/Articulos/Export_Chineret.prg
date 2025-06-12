/******************************************************************************
Script creado a Chineret para exportar a ecommerce
******************************************************************************/

#include ".\Include\Factu.ch"
#define CRLF chr( 13 ) + chr( 10 )

static nView
static cTextoArticulo
static cSeparator
static cNameFile
static lOpenFiles
static oMeter

//---------------------------------------------------------------------------//

function InicioHRB()

   lOpenFiles  := .f.

   cNameFile   := "C:\WDGES32\EXPWOO\export_woo.csv"

   cSeparator  := ","

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

   InitProcess()

   uploadImages()

   /*
   Importamos los datos necesarios---------------------------------------------
   */
   
   Exportacion()

   CursorWe()

   /*
   Cerramos los ficheros abiertos anteriormente--------------------------------
   */

   CloseFiles()

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

static function InitProcess()

   cTextoArticulo  := "ID"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Tipo"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "SKU"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Nombre"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Publicado"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "¿Está destacado?"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Visibilidad en el catálogo"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Descripción corta"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Descripción"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Día en que empieza el precio rebajado"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Día en que termina el precio rebajado"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Estado del impuesto"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Clase de impuesto"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "¿Existencias?"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Inventario"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Cantidad de bajo inventario"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "¿Permitir reservas de productos agotados?"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "¿Vendido individualmente?"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Peso (kg)"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Longitud (cm)"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Anchura (cm)"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Altura (cm)"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "¿Permitir valoraciones de clientes?"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Nota de compra"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Precio rebajado"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Precio normal"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Categorías"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Etiquetas"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Clase de envío"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Imágenes"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Límite de descargas"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Días de caducidad de la descarga"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Superior"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Productos agrupados"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Ventas dirigidas"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Ventas cruzadas"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "URL externa"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Texto del botón"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "Posición"
   cTextoArticulo  += CRLF

   /*cTextoArticulo  := "id"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "type"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "sku"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "name"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "status"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "featured"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "catalog_visibility"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "short_description"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "description"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "date_on_sale_from"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "date_on_sale_to"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "tax_status"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "tax_class"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "stock_status"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "backorders"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "sold_individually"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "weight"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "height"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "reviews_allowed"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "purchase_note"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "price"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "regular_price"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "manage_stock/stock_quantitiy"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "category_ids"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "tag_ids"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "shipping_class_id"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "attributes"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "attributes"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "default_attributes"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "attributes"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "image_id/gallery_image_ids"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "attributes"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "downloads"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "downloads"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "download_limit"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "download_expiry"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "parent_id"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "upsell_ids"
   cTextoArticulo  += cSeparator
   cTextoArticulo  += "cross_sell_id"
   cTextoArticulo  += CRLF*/

RETURN ( .t. )

//----------------------------------------------------------------------------//

static function uploadImages()

   local n
   local aImages

   CursorWait()

   oMeter               := TWaitMeter():New( , , ( D():Articulos( nView ) )->( LastRec() ) )

   /*
   Vamos la primera vuelta para los clientes-----------------------------------
   */

   ( D():Articulos( nView ) )->( dbGoTop() )

   while !( D():Articulos( nView ) )->( Eof() )

      if ( D():Articulos( nView ) )->lPubInt

         aImages        := ArticulosImagenesModel():getList( ( D():Articulos( nView ) )->Codigo )

         if Len( aImages ) > 0

            aEval( aImages, {|hImage| upImageToFtp( hImage ) } )

         end if

      end if

      ( D():Articulos( nView ) )->( dbSkip() )
      
      oMeter:oProgress:AutoInc()

   end while

   CursorWE()

RETURN ( .t. )

//----------------------------------------------------------------------------//

static function upImageToFtp( hImage )

   local oFtp
   local ftpSit            := "ftp.cluster030.hosting.ovh.net"
   local ftpDir            := cNoPathLeft( Rtrim( ftpSit ) )
   local nbrUsr            := "gestooc"
   local accUsr            := "Xtend000"
   local pasInt            := .f.
   local nPuerto           := 21
   local cCarpeta          := "www/imageneschineret/"

   cFile                   := hGet( hImage, "CIMGART" )

   if !file( cFile )
      Return ( Self )
   end if

   oFtp               := TFtpCurl():New( nbrUsr, accUsr, ftpSit, nPuerto )
   oFtp:setPassive( pasInt )

   if oFtp:CreateConexion()

      oFtp:createFile( cFile, cCarpeta )

      oFtp:EndConexion()

   else
      msgStop( "Imposible conectar al sitio ftp" )
   end if

   cDirImage   := "https://gestool.es/imageneschineret/" + cNoPath( hGet( hImage, "CIMGART" ) ) 

   ArticulosImagenesModel():setDirImage( hGet( hImage, "CCODART" ), hGet( hImage, "NID" ), cDirImage )

RETURN ( .t. )

//----------------------------------------------------------------------------//

static function Exportacion()

   local n
   local aImages
   local cImage         := ""
   local hImage

   CursorWait()

   oMeter               := TWaitMeter():New( , , ( D():Articulos( nView ) )->( LastRec() ) )

   /*
   Vamos la primera vuelta para los clientes-----------------------------------
   */

   ( D():Articulos( nView ) )->( dbGoTop() )

   while !( D():Articulos( nView ) )->( Eof() )

      if ( D():Articulos( nView ) )->lPubInt

         aImages           := ArticulosImagenesModel():getList( ( D():Articulos( nView ) )->Codigo )

         if Len( aImages ) > 0
            
            for each hImage in aImages
               cImage      += AllTrim( hGet( hImage, "CRMTART" ) ) + ","
            next

            cImage         := substr( cImage, 1, len( cImage ) - 1 )

            cImage         := '"' + cImage + '"'

         end if

         cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->Codigo )       //"id"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "Simple"                                 //"Tipo"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->Codigo )       //"sku"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->Nombre )       //"Nombre"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "1"                                        //"Publicado"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "1"                                        //"¿Está destacado?"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "visible"                                //"Visibilidad en el catálogo"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->Nombre )      //"Descripción corta"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += AllTrim( ( D():Articulos( nView ) )->Descrip )      //"Descripción"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Día en que empieza el precio rebajado"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Día en que termina el precio rebajado"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "taxable"                                //"Estado del impuesto"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "standard"                               //"Clase de impuesto"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "1"                                        //"¿Existencias?"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += AllTrim( Trans( StocksModel():nStockArticulo( ( D():Articulos( nView ) )->Codigo, "002" ), "@ 999,999.99" ) ) //"Inventario"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "0"                                        //"Cantidad de bajo inventario"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "0"                                        //"¿Permitir reservas de productos agotados?"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                        //"¿Vendido individualmente?"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "0"                                        //"Peso (kg)"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "0"                                        //"Longitud (cm)"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "0"                                        //"Anchura (cm)"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "0"                                        //"Altura (cm)"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "0"                                        //"¿Permitir valoraciones de clientes?"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Nota de compra"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += AllTrim( Trans( ( D():Articulos( nView ) )->pVtaIva1, "@ 999,999.99" ) )    //"Precio rebajado"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += AllTrim( Trans( ( D():Articulos( nView ) )->pVtaIva1, "@ 999,999.99" ) )    //"Precio normal"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += AllTrim( FamiliasModel():getNombre( ( D():Articulos( nView ) )->Familia ) )       //"Categorías"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Etiquetas"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += "local"                                  //"Clase de envío"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += cImage                                   //"Imágenes"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Límite de descargas"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Días de caducidad de la descarga"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Superior"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Productos agrupados"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Ventas dirigidas"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Ventas cruzadas"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"URL externa"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Texto del botón"
         cTextoArticulo  += cSeparator
         cTextoArticulo  += ""                                       //"Posición"
         cTextoArticulo  += CRLF

      end if

      ( D():Articulos( nView ) )->( dbSkip() )

      cImage            := ""
      
      oMeter:oProgress:AutoInc()

   end while

   if !Empty( cTextoArticulo )

      fErase( cNameFile )
      nHand       := fCreate( cNameFile )
      fWrite( nHand, cTextoArticulo )
      fClose( nHand )

      MsgInfo( "Fichero exportado correctamente en " + cNameFile )

   end if

   CursorWE()

Return .t.

//---------------------------------------------------------------------------//