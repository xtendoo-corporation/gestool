#include "fiveWin.ch"
#include "Hbxml.ch"

//--------------------------------------------------------------------------//

CLASS TPrestaShopWebService

   DATA oController
   
   DATA cUrl

   DATA cWeb

   DATA oLanguagesWebService
   DATA oImageTypesWebService
   DATA oCategoriesWebService
   DATA oManufacturerWebService
   DATA oProductsWebService
   DATA oStocksWebService
   DATA oPropiedadesWebService
   DATA oValoresPropiedadesWebService
   DATA oCombinationsWebService

   DATA aIdsLanguages
   DATA aImageTypes

   METHOD New()

   METHOD End()

   METHOD setWeb( cWeb )                        INLINE ( ::cWeb := cWeb )
   METHOD getWeb()                              INLINE ( ::cWeb )

   METHOD setUrl( cUrl )                        INLINE ( ::cUrl := cUrl )
   METHOD getUrl()                              INLINE ( ::cUrl )

   METHOD setDefaultValuesWeb()

   METHOD getLanguagesWebService()              INLINE ( iif( empty( ::oLanguagesWebService ), ::oLanguagesWebService := TPrestashopLanguagesWebService():New( self ), ), ::oLanguagesWebService )
   METHOD getImagesTypesWebService()            INLINE ( iif( empty( ::oImageTypesWebService ), ::oImageTypesWebService := TPrestashopImagesTypesWebService():New( self ), ), ::oImageTypesWebService )
   METHOD getCategoriesWebService()             INLINE ( iif( empty( ::oCategoriesWebService ), ::oCategoriesWebService := TPrestashopCategoriesWebService():New( self ), ), ::oCategoriesWebService )
   METHOD getManufacturerWebService()           INLINE ( iif( empty( ::oManufacturerWebService ), ::oManufacturerWebService := TPrestashopManufacturerWebService():New( self ), ), ::oManufacturerWebService )
   METHOD getProductsWebService()               INLINE ( iif( empty( ::oProductsWebService ), ::oProductsWebService := TPrestashopProductsWebService():New( self ), ), ::oProductsWebService )
   METHOD getStocksWebService()                 INLINE ( iif( empty( ::oStocksWebService ), ::oStocksWebService := TPrestashopStocksWebService():New( self ), ), ::oStocksWebService )
   METHOD getPropiedadesWebService()            INLINE ( iif( empty( ::oPropiedadesWebService ), ::oPropiedadesWebService := TPrestashopPropiedadesWebService():New( self ), ), ::oPropiedadesWebService )
   METHOD getValoresPropiedadesWebService()     INLINE ( iif( empty( ::oValoresPropiedadesWebService ), ::oValoresPropiedadesWebService := TPrestashopValoresPropiedadesWebService():New( self ), ), ::oValoresPropiedadesWebService )
   METHOD getCombinationsWebService()           INLINE ( iif( empty( ::oCombinationsWebService ), ::oCombinationsWebService := TPrestashopCombinationsWebService():New( self ), ), ::oCombinationsWebService )
   
   METHOD getComercioInstance()                 INLINE ( TComercioConfig():getInstance() )

   METHOD getPrestashopIdInstance()             INLINE ( ::oController:TPrestashopId )

   METHOD UploadCategoryImage( cFile )

   METHOD UploadManufacturerImage( cFile )

END CLASS

//--------------------------------------------------------------------------//

METHOD New( oController ) CLASS TPrestashopWebService

   ::oController                  := oController

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD End() CLASS TPrestashopWebService

   if !empty( ::oLanguagesWebService )
      ::oLanguagesWebService:end()
   end if

   if !empty( ::oImageTypesWebService )
      ::oImageTypesWebService:end()
   end if

   if !empty( ::oCategoriesWebService )
      ::oCategoriesWebService:end()
   end if

   if !empty( ::oManufacturerWebService )
      ::oManufacturerWebService:end()
   end if

   if !empty( ::oStocksWebService )
      ::oStocksWebService:end()
   end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD setDefaultValuesWeb( cWeb ) CLASS TPrestashopWebService

   ::SetWeb( cWeb )

   TComercioConfig():getInstance():setCurrentWebName( cWeb )

   if !Empty( ::getComercioInstance():getFromCurrentWebServices( "url" ) )
      ::SetUrl( AllTrim( ::getComercioInstance():getFromCurrentWebServices( "url" ) ) )
   end if

   ::aIdsLanguages   := ::getLanguagesWebService():getIdsIdiomas()
   ::aImageTypes     := ::getImagesTypesWebService():getImagesTypes()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD UploadCategoryImage( idCategory, cFile ) CLASS TPrestashopWebService

   local oFtp
   local aImages     := {}
   local hTypeImage
   local cPath       := StrTran( alltrim( cPatOut() ), "\", "/" )
   local hImage

   if hb_isnil( idCategory )
      return ( nil )
   end if

   if !File( cFile )
      Return ( nil )
   end if
   
   /*
   Nombre de los ficheros a subir----------------------------------------------
   */

   aAdd( aImages, {  "name" => cPath + AllTrim( Str( idCategory ) ) + ".jpg", "width" => 0, "height" => 0 } )   

   for each hTypeImage in ::aImageTypes

      if hGet( hTypeImage, "categories" ) == "1"

         aAdd( aImages, {  "name" => cPath + AllTrim( Str( idCategory ) ) + "-" + hGet( hTypeImage, "name" ) + ".jpg" ,;
                           "width" => Val( hGet( hTypeImage, "width" ) ),;
                           "height" => Val( hGet( hTypeImage, "height" ) ) } )

      end if

   next

   /*
   Creamos las imagenes temporales---------------------------------------------
   */

   aEval( aImages, {|h| saveImage( cFile,;
                        hGet( h, "name" ),;
                        if( !Empty( hGet( h, "width" ) ), hGet( h, "width" ), nil ),;
                        if( !Empty( hGet( h, "height" ) ), hGet( h, "height" ), nil ) ) } )

   /*
   Subimos al Ftp--------------------------------------------------------------
   */
  

   aEval( aImages, {|h| ::oController:meterProcesoText( "Subiendo imagen " + hGet( h, "name" ) ),; 
                        ::oController:oFtp:CreateFile( hGet( h, "name" ), ::oController:cDirectoryCategories() ) } )

   /*
   Limpiamos el temporal-------------------------------------------------------
   */

   aEval( aImages, {|h| if( File( hGet( h, "name" ) ), fErase( hGet( h, "name" ) ), ) } )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD UploadManufacturerImage( idFab, cFile ) CLASS TPrestashopWebService

   local oFtp
   local aImages     := {}
   local hTypeImage
   local cPath       := StrTran( alltrim( cPatOut() ), "\", "/" )
   local hImage

   if hb_isnil( idFab )
      return ( nil )
   end if

   if !File( cFile )
      Return ( nil )
   end if
   
   /*
   Nombre de los ficheros a subir----------------------------------------------
   */

   aAdd( aImages, {  "name" => cPath + AllTrim( Str( idFab ) ) + ".jpg", "width" => 0, "height" => 0 } )   

   for each hTypeImage in ::aImageTypes

      if hGet( hTypeImage, "manufacturers" ) == "1"

         aAdd( aImages, {  "name" => cPath + AllTrim( Str( idFab ) ) + "-" + hGet( hTypeImage, "name" ) + ".jpg" ,;
                           "width" => Val( hGet( hTypeImage, "width" ) ),;
                           "height" => Val( hGet( hTypeImage, "height" ) ) } )

      end if

   next

   /*
   Creamos las imagenes temporales---------------------------------------------
   */

   aEval( aImages, {|h| saveImage( cFile,;
                        hGet( h, "name" ),;
                        if( !Empty( hGet( h, "width" ) ), hGet( h, "width" ), nil ),;
                        if( !Empty( hGet( h, "height" ) ), hGet( h, "height" ), nil ) ) } )

   /*
   Subimos al Ftp--------------------------------------------------------------
   */

   aEval( aImages, {|h| ::oController:meterProcesoText( "Subiendo imagen " + hGet( h, "name" ) ),; 
                        ::oController:oFtp:CreateFile( hGet( h, "name" ), ::oController:cDirectoryManufacture() ) } )

   /*
   Limpiamos el temporal-------------------------------------------------------
   */

   aEval( aImages, {|h| if( File( hGet( h, "name" ) ), fErase( hGet( h, "name" ) ), ) } )

RETURN ( self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TPrestashopLanguagesWebService

   DATA oController

   METHOD new( oController )

   METHOD getIdsIdiomas()

   METHOD getComercioInstance()        INLINE ( ::oController:getComercioInstance() )

END CLASS

//---------------------------------------------------------------------------//

METHOD new( oController ) CLASS TPrestashopLanguagesWebService

   ::oController     :=  oController

RETURN ( self )

//--------------------------------------------------------------------------//

METHOD getIdsIdiomas() CLASS TPrestashopLanguagesWebService

   local aIds        := {}
   local oService

   if !Empty( ::getComercioInstance():getFromCurrentWebServices( "languages" ) )

      with object( LanguagesWebService():New( self ) )
         :setMethodGet()
         if !Empty( ::oController:getUrl() )
         :setUrl( AllTrim( ::oController:getUrl() ) )
         end if
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :runGetJson()
         aIds              := :getListIdsLenguages()
         :End()
      end

   end if

RETURN ( aIds )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TPrestashopImagesTypesWebService

   DATA oController

   METHOD new( oController )

   METHOD getImagesTypes()

   METHOD getComercioInstance()        INLINE ( ::oController:getComercioInstance() )

END CLASS

//---------------------------------------------------------------------------//

METHOD new( oController ) CLASS TPrestashopImagesTypesWebService

   ::oController     :=  oController

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD getImagesTypes() CLASS TPrestashopImagesTypesWebService

   local Id          := ""
   local aIds        := {}
   local oService
   local aTypes      := {}

   if !Empty( ::getComercioInstance():getFromCurrentWebServices( "image_types" ) )

      /*
      Sacamos las ids de los tipos de imágenes---------------------------------
      */

      with object( ImagesTypesWebService():New( self ) )
         :setMethodGet()
         if !Empty( ::oController:getUrl() )
            :setUrl( AllTrim( ::oController:getUrl() ) )
         end if
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :runGetJson()
         aIds              := :ImagesTypesWebService():getListImageTypes()
         :End()
      end

      /*
      Sacamos los todas las características de cada id
      */
      
      for each Id in aIds

         with object( ImagesTypesWebService():New( self ) )
            :setMethodGet()
            :setIdToGet( ID )

            if !Empty( ::oController:getUrl() )
               :setUrl( AllTrim( ::oController:getUrl() ) )
            end if

            :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )

            :runGetJson()

            aAdd( aTypes, :ImagesTypesWebService():getArrayImageTypes() )

            :End()

         end

      next

   end if

RETURN ( aTypes )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TPrestashopCategoriesWebService

   DATA oController

   DATA aCodFam

   METHOD new( oController )

   METHOD getComercioInstance()      INLINE ( ::oController:getComercioInstance() )

   METHOD getPrestashopIdInstance()  INLINE ( ::oController:getPrestashopIdInstance() )

   METHOD SetArrayUuids( aCodFam )   INLINE ( ::aCodFam := aCodFam )

   METHOD InsertOrUpdateCategorie()

   METHOD getIdsCategories()

   METHOD uploadImageCategorie( cCodFam )

END CLASS

//--------------------------------------------------------------------------//

METHOD new( oController ) CLASS TPrestashopCategoriesWebService

   ::oController   :=  oController

RETURN ( self )

//--------------------------------------------------------------------------//

METHOD getIdsCategories() CLASS TPrestashopCategoriesWebService

   local aIds        := {}
   local oService

   if !Empty( ::getComercioInstance():getFromCurrentWebServices( "categories" ) )

      with object( categoriesWebService():New( self ) )
         :setMethodGet()
         if !Empty( ::oController:getUrl() )
         :setUrl( AllTrim( ::oController:getUrl() ) )
         end if
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :runGetJson()
         aIds              := :getListIdsCategories()
         :End()
      end

   end if

RETURN ( aIds )

//---------------------------------------------------------------------------//

METHOD InsertOrUpdateCategorie( cCodFam, idParent ) CLASS TPrestashopCategoriesWebService

   local nIdCategory
   local nIdParent

   nIdCategory    := ::getPrestashopIdInstance():getValueCategory( cCodFam, ::oController:getWeb() )
   nIdParent      := ::getPrestashopIdInstance():getValueCategory( idParent, ::oController:getWeb() )

   if nIdCategory != 0

      /*
      Modifico la categoría----------------------------------------------------
      */

      with object( categoriesWebService():New( self ) )
   
         :setMethodPut()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :hName       := FamiliasModel():getNamesFromIdLanguagesPS( cCodFam, ::oController:aIdsLanguages )
         :runPut( nIdCategory, nIdParent )
         :End()

      end with

   else
      
      /*
      Añado la categoría-------------------------------------------------------
      */

      with object( categoriesWebService():New( self ) )
   
         :setMethodPost()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :hName       := FamiliasModel():getNamesFromIdLanguagesPS( cCodFam, ::oController:aIdsLanguages )
         :runPost( nIdParent )
         nIdCategory  := :getResponseId()
         iif( !Empty( nIdCategory ), ::getPrestashopIdInstance():setValueCategory( cCodFam, ::oController:getWeb(), val( nIdCategory ) ), )
         :End()

      end with

   end if

   ::uploadImageCategorie( cCodFam, nIdCategory )

RETURN ( nIdCategory )

//---------------------------------------------------------------------------//

METHOD uploadImageCategorie( cCodFam, nIdCategory ) CLASS TPrestashopCategoriesWebService

   ::oController:UploadCategoryImage( nIdCategory, cFileBmpName( AllTrim( FamiliasModel():getField( 'cImgBtn', 'cCodFam', cCodFam ) ) ) )

RETURN ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TPrestashopManufacturerWebService

   DATA oController

   METHOD new( oController )

   METHOD getComercioInstance()      INLINE ( ::oController:getComercioInstance() )

   METHOD getPrestashopIdInstance()  INLINE ( ::oController:getPrestashopIdInstance() )

   METHOD InsertOrUpdateManufacturer( cCodFab )

   METHOD uploadImageManuFacturer( cCodFab )

END CLASS

//--------------------------------------------------------------------------//

METHOD new( oController ) CLASS TPrestashopManufacturerWebService

   ::oController   :=  oController

RETURN ( self )

//--------------------------------------------------------------------------//

METHOD InsertOrUpdateManufacturer( cCodFab ) CLASS TPrestashopManufacturerWebService

   local nIdManufacturer
   local nIdParent

   nIdManufacturer  := ::getPrestashopIdInstance():getValueManufacturer( cCodFab, ::oController:getWeb() )

   if nIdManufacturer != 0

      /*
      Modifico la categoría----------------------------------------------------
      */

      with object( manufacturerWebService():New( self ) )
   
         :setMethodPut()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :hName       := FabricantesModel():getNamesFromIdLanguagesPS( cCodFab, ::oController:aIdsLanguages )
         :cName       := FabricantesModel():getNombre( cCodFab )
         :runPut( nIdManufacturer )
         :End()

      end with

   else
      
      /*
      Añado el fabricante------------------------------------------------------
      */

      with object( manufacturerWebService():New( self ) )
   
         :setMethodPost()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :hName       := FabricantesModel():getNamesFromIdLanguagesPS( cCodFab, ::oController:aIdsLanguages )
         :cName       := FabricantesModel():getNombre( cCodFab )
         :runPost()
         nIdManufacturer  := :getResponseId()
         iif( !Empty( nIdManufacturer ), ::getPrestashopIdInstance():setValueManufacturer( cCodFab, ::oController:getWeb(), val( nIdManufacturer ) ), )
         :End()

      end with

   end if

   ::uploadImageManuFacturer( cCodFab, nIdManufacturer )

RETURN ( nIdManufacturer )

//---------------------------------------------------------------------------//

METHOD uploadImageManuFacturer( cCodFab, nIdManufacturer ) CLASS TPrestashopManufacturerWebService

   ::oController:UploadManufacturerImage( nIdManufacturer, cFileBmpName( AllTrim( FabricantesModel():getField( 'cImgLogo', 'cCodFab', cCodFab ) ) ) )

RETURN ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TPrestashopProductsWebService

   DATA oController

   METHOD new( oController )

   METHOD getComercioInstance()      INLINE ( ::oController:getComercioInstance() )

   METHOD getPrestashopIdInstance()  INLINE ( ::oController:getPrestashopIdInstance() )

   METHOD InsertOrUpdateProduct( cCodArt )

   METHOD uploadImageProduct( cCodArt )

   METHOD uploadStocksProduct( hProduct, nIdProduct )

END CLASS

//--------------------------------------------------------------------------//

METHOD new( oController ) CLASS TPrestashopProductsWebService

   ::oController   :=  oController

RETURN ( self )

//--------------------------------------------------------------------------//

METHOD InsertOrUpdateProduct( hProduct ) CLASS TPrestashopProductsWebService

   local nIdProduct

   nIdProduct  := ::getPrestashopIdInstance():getValueProduct( hGet( hProduct, "id" ), ::oController:getWeb() )

   if nIdProduct != 0

      /*
      Modifico la producto----------------------------------------------------
      */

      with object( productWebService():New( self ) )
   
         :setMethodPut()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :hName       := ArticulosModel():getNamesFromIdLanguagesPS( hGet( hProduct, "id" ), ::oController:aIdsLanguages )
         :runPut( nIdProduct, hProduct )
         :End()

      end with

   else

      /*
      Añado el fabricante------------------------------------------------------
      */

      with object( productWebService():New( self ) )

         :setMethodPost()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :hName       := ArticulosModel():getNamesFromIdLanguagesPS( hGet( hProduct, "id" ), ::oController:aIdsLanguages )
         :runPost( hProduct )
         nIdProduct  := :getResponseId()
         iif( !Empty( nIdProduct ), ::getPrestashopIdInstance():setValueProduct( hGet( hProduct, "id" ), ::oController:getWeb(), val( nIdProduct ) ), )
         :End()

      end with

   end if

   ::uploadStocksProduct( hProduct, nIdProduct )

   //::uploadImageProduct( hProduct, nIdProduct )

RETURN ( nIdProduct )

//---------------------------------------------------------------------------//

METHOD uploadStocksProduct( hProduct, nIdProduct ) CLASS TPrestashopProductsWebService

   local hStock
   local nIdStock
   local nidproductattribute     := 0

   if Empty( nIdProduct )
      Return nil
   end if

   //Inserto stock del producto
   
   for each hStock in hGet( hProduct, "aStock" )

      if !Empty( hGet( hStock, "propiedad1" ) ) .and. ;
         !Empty( hGet( hStock, "propiedad2" ) ) .and. ;
         !Empty( hGet( hStock, "valor1" ) ) .and. ;
         !Empty( hGet( hStock, "valor2" ) )

         nidproductattribute     := ::getPrestashopIdInstance():getValueProductAttributeCombination( hget( hStock, "articulo" ) + hget( hStock, "propiedad1" ) + hget( hStock, "valor1" ) + hget( hStock, "propiedad2" ) + hget( hStock, "valor2" ), ::oController:getWeb() )

      end if

      //Creamos el stock del producto
      nIdStock                   := ::oController:getStocksWebService():InsertOrUpdateStockProduct( hStock, nIdProduct, nidproductattribute )

      //Actualizamos el Articulo con el stock

      with object( productWebService():New( self ) )
   
         :setMethodPut()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :hName                  := ArticulosModel():getNamesFromIdLanguagesPS( hGet( hProduct, "id" ), ::oController:aIdsLanguages )
         :runPut( nIdProduct, hProduct, nIdStock, nidproductattribute )
         :End()

      end with

      nidproductattribute     := 0

   next

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD uploadImageProduct( hProduct, nIdProduct ) CLASS TPrestashopProductsWebService

   /*MsgInfo( hb_valToExp( hProduct ), "hProduct" )
   MsgInfo( hb_valToExp( hGet( hProduct, "aImages" ) ), "aImages" )
   MsgInfo( nIdProduct, "nIdProduct" )*/

   //::oController:UploadManufacturerImage( nIdManufacturer, cFileBmpName( AllTrim( FabricantesModel():getField( 'cImgLogo', 'cCodFab', cCodFab ) ) ) )

RETURN ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TPrestashopStocksWebService

   DATA oController

   METHOD new( oController )

   METHOD getComercioInstance()      INLINE ( ::oController:getComercioInstance() )

   METHOD getPrestashopIdInstance()  INLINE ( ::oController:getPrestashopIdInstance() )

   METHOD InsertOrUpdateStockProduct( hProduct, nIdProduct )

   METHOD getIdStocks()

END CLASS

//--------------------------------------------------------------------------//

METHOD new( oController ) CLASS TPrestashopStocksWebService

   ::oController   :=  oController

RETURN ( self )

//--------------------------------------------------------------------------//

METHOD InsertOrUpdateStockProduct( hStock, nIdProduct, nidproductattribute ) CLASS TPrestashopStocksWebService

   local nIdsStock            := {}
   local nId                  := 0

   nId                        := ::getIdStocks( nIdProduct, nIdProductAttribute )

   if nId != 0

      /*
      Update Stock----------------------------------------------------------------
      */

         with object( stockProductWebService():New( self ) )
      
            :setMethodPut()
            :setUrl( ::oController:getUrl() )
            :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
            :runPut( hStock, nIdProduct, nidproductattribute, nId )
            :End()

         end with


      else

      /*
      Añado el Stock--------------------------------------------------------------
      */

      with object( stockProductWebService():New( self ) )

         :setMethodPost()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :runPost( hStock, nIdProduct, nidproductattribute )
         nIdsStock  := :getResponseId()
         :End()

      end with

   end if

RETURN ( nIdsStock )

//--------------------------------------------------------------------------//

METHOD getIdStocks( nIdProduct, nIdProductAttribute )

   local nIdStock          := 0
   local Id                := ""
   local aIds              := {}
   local oService
   local aTypesStock       := {}
   local hType

   if !Empty( ::getComercioInstance():getFromCurrentWebServices( "stock_availables" ) )

      /*
      Sacamos las ids de los tipos de imágenes---------------------------------
      */

      with object( stockProductWebService():New( self ) )
         :setMethodGet()
         if !Empty( ::oController:getUrl() )
            :setUrl( AllTrim( ::oController:getUrl() ) )
         end if
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :runGetJson()
         aIds              := :stockProductWebService():getListIdsStocks()
         :End()
      end

      /*
      Sacamos los todas las características de cada id
      */
      
      for each Id in aIds

         with object( stockProductWebService():New( self ) )
            :setMethodGet()
            :setIdToGet( ID )

            if !Empty( ::oController:getUrl() )
               :setUrl( AllTrim( ::oController:getUrl() ) )
            end if

            :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )

            :runGetJson()

            aAdd( aTypesStock, :stockProductWebService():getArrayStocks() )

            :End()

         end

      next

   end if

   /*
   Sacamos los todas las características de cada id
   */

   for each hType in aTypesStock
      
      if hGet( hType, "id_product" ) == hb_ntos( nIdProduct ) .and.;
         hGet( hType, "id_product_attribute" ) == hb_ntos( nIdProductAttribute )

         nIdStock    := hGet( hType, "id" )

      end if

   next

RETURN ( nIdStock )

//--------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TPrestashopPropiedadesWebService

   DATA oController

   METHOD new( oController )

   METHOD getComercioInstance()      INLINE ( ::oController:getComercioInstance() )

   METHOD getPrestashopIdInstance()  INLINE ( ::oController:getPrestashopIdInstance() )

   METHOD setProperties( hPropierties )

   METHOD InsertOrUpdate()

END CLASS

//--------------------------------------------------------------------------//

METHOD new( oController ) CLASS TPrestashopPropiedadesWebService

   ::oController     :=  oController

RETURN ( self )

//--------------------------------------------------------------------------//

METHOD setProperties( hPropierties ) CLASS TPrestashopPropiedadesWebService

   aEval( hGet( hPropierties, "aProperties" ), {|h| ::InsertOrUpdate( h) } )

RETURN ( nil )

//--------------------------------------------------------------------------//

METHOD InsertOrUpdate( hPropiertie ) CLASS TPrestashopPropiedadesWebService

   local nId

   nId               := ::getPrestashopIdInstance():getValueAttributeGroup( hGet( hPropiertie, "Codigo" ), ::oController:getWeb() )

   if nId != 0

      /*
      Modifico la propiedad----------------------------------------------------
      */

      with object( propiedadesWebService():New( self ) )
   
         :setMethodPut()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :hName      := PropiedadesModel():getNamesFromIdLanguagesPS( hGet( hPropiertie, "Codigo" ), ::oController:aIdsLanguages )
         :runPut( nId, hPropiertie )
         :End()

      end with

   else
      
      /*
      Añado la propiedad-------------------------------------------------------
      */

      with object( propiedadesWebService():New( self ) )
   
         :setMethodPost()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :hName      := PropiedadesModel():getNamesFromIdLanguagesPS( hGet( hPropiertie, "Codigo" ), ::oController:aIdsLanguages )
         :runPost( hPropiertie )
         nId  := :getResponseId()
         iif( !Empty( nId ), ::getPrestashopIdInstance():setValueAttributeGroup( hGet( hPropiertie, "Codigo" ), ::oController:getWeb(), val( nId ) ), )
         :End()

      end with

   end if

RETURN ( nId )

//--------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TPrestashopValoresPropiedadesWebService

   DATA oController

   METHOD new( oController )

   METHOD getComercioInstance()      INLINE ( ::oController:getComercioInstance() )

   METHOD getPrestashopIdInstance()  INLINE ( ::oController:getPrestashopIdInstance() )

   METHOD setValuesProperties( hPropierties )

   METHOD InsertOrUpdate()

END CLASS

//--------------------------------------------------------------------------//

METHOD new( oController ) CLASS TPrestashopValoresPropiedadesWebService

   ::oController     :=  oController

RETURN ( self )

//--------------------------------------------------------------------------//

METHOD setValuesProperties( hValues ) CLASS TPrestashopValoresPropiedadesWebService

   aEval( hGet( hValues, "aValues" ), {|h| ::InsertOrUpdate( h ) } )

RETURN ( nil )

//--------------------------------------------------------------------------//

METHOD InsertOrUpdate( hValue ) CLASS TPrestashopValoresPropiedadesWebService

   local nId
   local nIdProp

   nIdProp           := ::getPrestashopIdInstance():getValueAttributeGroup( hGet( hValue, "codigo" ), ::oController:getWeb() )
   nId               := ::getPrestashopIdInstance():getValueAttribute( hGet( hValue, "codigo" ) + hGet( hValue, "valor" ), ::oController:getWeb() )

   if nId != 0

      /*
      Modifico la propiedad----------------------------------------------------
      */

      with object( valoresPropiedadesWebService():New( self ) )
   
         :setMethodPut()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         aEval( ::oController:aIdsLanguages, {|id| hSet( :hName, AllTrim( Str( id ) ), AllTrim( hGet( hValue, "nombre" ) ) ) } )
         :runPut( nId, hValue, nIdProp )
         :End()

      end with

   else
      
      /*
      Añado la propiedad-------------------------------------------------------
      */

      with object( valoresPropiedadesWebService():New( self ) )
   
         :setMethodPost()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         aEval( ::oController:aIdsLanguages, {|id| hSet( :hName, AllTrim( Str( id ) ), AllTrim( hGet( hValue, "nombre" ) ) ) } )
         :runPost( hValue, nIdProp )
         nId  := :getResponseId()
         iif( !Empty( nId ), ::getPrestashopIdInstance():setValueAttribute( hGet( hValue, "codigo" ) + hGet( hValue, "valor" ), ::oController:getWeb(), val( nId ) ), )
         :End()

      end with

   end if

RETURN ( nId )

//--------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TPrestashopCombinationsWebService

   DATA oController

   METHOD new( oController )

   METHOD getComercioInstance()      INLINE ( ::oController:getComercioInstance() )

   METHOD getPrestashopIdInstance()  INLINE ( ::oController:getPrestashopIdInstance() )

   METHOD setCombinations( hValues )

   METHOD InsertOrUpdate()

END CLASS

//--------------------------------------------------------------------------//

METHOD new( oController ) CLASS TPrestashopCombinationsWebService

   ::oController     :=  oController

RETURN ( self )

//--------------------------------------------------------------------------//

METHOD setCombinations( hValues ) CLASS TPrestashopCombinationsWebService

   aEval( hGet( hValues, "aValuesCombinations" ), {|h| ::InsertOrUpdate( h ) } )

RETURN ( nil )

//--------------------------------------------------------------------------//

METHOD InsertOrUpdate( hCombination ) CLASS TPrestashopCombinationsWebService

   local nId
   local nIdProp

   nId               := ::getPrestashopIdInstance():getValueProductAttributeCombination( hget( hCombination, "CCODART" ) + hget( hCombination, "CCODPR1" ) + hget( hCombination, "CVALPR1" ) + hget( hCombination, "CCODPR2" ) + hget( hCombination, "CVALPR2" ), ::oController:getWeb() )

   if nId != 0

      /*
      Modifico la propiedad----------------------------------------------------
      */

      with object( combinationsWebService():New( self ) )
   
         :setMethodPut()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :runPut( nId, hCombination )
         :End()

      end with

   else
      
      /*
      Añado la propiedad-------------------------------------------------------
      */

      with object( combinationsWebService():New( self ) )
   
         :setMethodPost()
         :setUrl( ::oController:getUrl() )
         :setKey( AllTrim( ::getComercioInstance():getFromCurrentSourceWebServices( :cSource, :cMethod, "" ) ) )
         :runPost( hCombination )
         nId  := :getResponseId()
         iif( !Empty( nId ), ::getPrestashopIdInstance():setValueProductAttributeCombination( hget( hCombination, "CCODART" ) + hget( hCombination, "CCODPR1" ) + hget( hCombination, "CVALPR1" ) + hget( hCombination, "CCODPR2" ) + hget( hCombination, "CVALPR2" ), ::oController:getWeb(), val( nId ) ), )
         :End()

      end with

   end if

RETURN ( nId )

//--------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//