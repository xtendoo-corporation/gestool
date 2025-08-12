#include "fiveWin.ch"
#include "Hbxml.ch"

//----------------------------------------------------------------------------// 

FUNCTION testWebServiceGet()

   local oXml
   local cXml  
   local oXmlId
   local oXmlIdData
   local oWebService 

   MsgInfo( "testWebServiceGet" )

   oWebService    := WebService():New()
   oWebService:setService( "products/" )
   oWebService:setUrl( "https://www.p-escamas.es/api/" )
   oWebService:setParams( "ws_key", "5XV4KE42BBX631RW9GW1DLG8K4JCDVAM" )
   //oWebService:setUrl( "http://localhost/ps17/api/" )
   //oWebService:setParams( "ws_key", "VFJMINDYCSEGGC1ZUM18J8B3IE88FA14" )
   //oWebService:setUrl( "https://www.gestoolsoftware.es/tienda/api/" )
   //oWebService:setParams( "ws_key", "AMG1S1M615NQTE61MBM6I1ECYZBCRXHN" )
   oWebService:setMethod( "GET" )
   oWebService:Open()
   oWebService:Send() 

   MsgInfo( oWebService:getStatus(), "status" )
   Msginfo( oWebService:getResponseText(), "getresponsetext" )

   oWebService:End()

RETURN ( nil )

//----------------------------------------------------------------------------// 

FUNCTION testWebServicePost()

   local oXml
   local cXml  
   local oXmlId
   local oXmlIdData
   local oWebService 

   MsgInfo( "testWebServicePost" )

   cXml           := getXML()

   oWebService    := WebService():New()
   oWebService:setService( "products/" )
   oWebService:setUrl( "https://www.p-escamas.es/api/" )
   oWebService:setParams( "ws_key", "5XV4KE42BBX631RW9GW1DLG8K4JCDVAM" )
   //oWebService:setUrl( "http://localhost/ps17/api/" )
   //oWebService:setParams( "ws_key", "VFJMINDYCSEGGC1ZUM18J8B3IE88FA14" )
   //oWebService:setUrl( "https://www.gestoolsoftware.es/tienda/api/" )
   //oWebService:setParams( "ws_key", "AMG1S1M615NQTE61MBM6I1ECYZBCRXHN" )
   oWebService:setMethod( "POST" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   oWebService:SetRequestHeader( "Content-Length", len( cXml ) )
   oWebService:Send( cXml ) 

   MsgInfo( oWebService:getStatus(), "status" )
   Msginfo( oWebService:getResponseText(), "getresponsetext" )
   Msginfo( oWebService:getResponseId(), "getResponseId" )

   oWebService:End()

RETURN ( nil )

//----------------------------------------------------------------------------// 

STATIC FUNCTION getXML()

   local cXml

TEXT INTO cXml
<?xml version="1.0" encoding="UTF-8"?>
<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">
<product>
<id_category_default>8</id_category_default>
<id_shop_default>1</id_shop_default>
<id_tax_rules_group>1</id_tax_rules_group>
<reference>999999999</reference>
<state>1</state>
<additional_delivery_times>1</additional_delivery_times>
<minimal_quantity>1</minimal_quantity>
<low_stock_alert>0</low_stock_alert>
<active>1</active>
<price>5.37190100</price>
<available_for_order>1</available_for_order>
<show_condition>1</show_condition>
<condition>new</condition>
<show_price>1</show_price>
<visibility>both</visibility>
<pack_stock_type>3</pack_stock_type>
<meta_description>
<language id="1"></language>
</meta_description>
<meta_keywords>
<language id="1"></language>
</meta_keywords>
<meta_title>
<language id="1"></language>
</meta_title>
<link_rewrite>
<language id="1">articulo-dario</language>
</link_rewrite>
<name>
<language id="1">Artículo Darío</language>
</name>
<description>
<language id="1">Este bajo de línea cónico.</language>
</description>
<description_short>
<language id="1">Artículo Darío</language>
</description_short>
<associations>
<categories>
<category>
<id>8</id>
</category>
</categories>
</associations>
</product>
</prestashop>
ENDTEXT

MsgInfo( cXml )

RETURN ( cXml )

//--------------------------------------------------------------------------//

CLASS WebService

   DATA oParent

   DATA oService

   DATA cKey   

   DATA cMethod

   DATA cSource       

   DATA cUrl 

   DATA cPost     

   DATA lErrors  

   DATA hParams

   DATA nIdToGet  

   DATA cXml

   DATA cUser

   DATA cPassword

   METHOD New()                        CONSTRUCTOR

   METHOD End() 

   METHOD createService()

   METHOD Open()

   METHOD hasErrors()                  INLINE ( ::lErrors )

   METHOD setKey( cKey )               INLINE ( ::cKey := cKey )
   METHOD getKey()                     INLINE ( ::cKey )

   METHOD setService( cSource )        INLINE ( ::cSource := cSource )
   METHOD getService()                 INLINE ( ::cSource )

   METHOD setMethod( cMethod )         INLINE ( ::cMethod := cMethod )
   METHOD getMethod()                  INLINE ( ::cMethod )

   METHOD setIdToGet( nIdToGet )       INLINE ( ::nIdToGet := "/" + AllTrim( Str( nIdToGet ) ) + "/" )
   METHOD getIdToGet()                 INLINE ( ::nIdToGet )

   METHOD setUrl( cUrl )               INLINE ( ::cUrl := cUrl + ::cSource + if( !Empty( ::getIdToGet() ), ::getIdToGet(), "" ) )
   METHOD getUrl()                     

   METHOD setUser( cUser )             INLINE ( ::cUser := cUser )
   METHOD getUser()                    INLINE ( ::cUser )

   METHOD setPassword( cPassword )     INLINE ( ::cPassword := cPassword )
   METHOD getPassword()                INLINE ( ::cPassword )

   METHOD createPostXml()              VIRTUAL
   METHOD createPutXml()               VIRTUAL
   METHOD createGetXml()               VIRTUAL
   
   METHOD setMethodPost()              INLINE ( ::setMethod( "POST" ) )
   METHOD setMethodPut()               INLINE ( ::setMethod( "PUT" ) )
   METHOD setMethodGet()               INLINE ( ::setMethod( "GET" ) )
   METHOD setMethodDelete()            INLINE ( ::setMethod( "DELETE" ) )
   METHOD setMethodHead()              INLINE ( ::setMethod( "HEAD" ) )
   
   METHOD runPost()
   METHOD runGetJSon()
   METHOD runGetXml()
   METHOD runPut()
   METHOD runDelete()                  INLINE ( nil )
   METHOD runHead()                    INLINE ( nil )

   METHOD setXml( cXml )               INLINE ( ::cXml := cXml )
   METHOD getXml()                     INLINE ( ::cXml )

   METHOD SetRequestHeader( cHeader, uValue )  

   METHOD Send( uBody )   

   METHOD getStatus()                  INLINE ( ::oService:Status )

   METHOD getResponseText()            INLINE ( ::oService:ResponseText )
   METHOD getResponseTextAsXml()       INLINE ( TXmlDocument():new( ::oService:ResponseText ) )
   METHOD getResponseId()

   METHOD setParams( cKey, uValue )

END CLASS

//--------------------------------------------------------------------------//

METHOD New( oParent )

   ::oParent      := oParent

   ::lErrors      := .f.

   ::hParams      := {=>}

   ::createService()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD End()

   ::oService  := nil

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createService()

   local oError

   try
     ::oService   := CreateObject( "MSXML2.ServerXMLHTTP.6.0" )
   catch oError
     ::lErrors    := .t.
   end

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD Open( cMethod, cUrl, lAsync, cUser, cPassword )   

   DEFAULT cMethod   := ::getMethod()
   DEFAULT cUrl      := ::getUrl()
   DEFAULT lAsync    := .f.
   DEFAULT cUser     := ::getUser()
   DEFAULT cPassword := ::getPassword()

RETURN ( ::oService:Open( cMethod, cUrl, lAsync, cUser, cPassword ) )

//---------------------------------------------------------------------------//

METHOD getUrl()

   if Len( ::hParams ) > 0
      ::cUrl  += "?"
      hEval( ::hParams, {| k, v, n | ::cUrl  += if( n > 1, "&", "" ) + k + "=" + v } )
   end if

RETURN ( ::cUrl )

//---------------------------------------------------------------------------//

METHOD SetRequestHeader( cHeader, uValue )     

RETURN ( ::oService:SetRequestHeader( cHeader, uValue ) )

//---------------------------------------------------------------------------//

METHOD Send( uBody ) 

RETURN ( ::oService:Send( uBody ) )

//---------------------------------------------------------------------------//

METHOD setParams( cKey, uValue )

RETURN ( hset( ::hParams, cKey, uValue ) )

//---------------------------------------------------------------------------//

METHOD getResponseId()

   local oXml
   local oNodeId
   local oNodeData

   if ::getStatus() != 201
      RETURN ( nil )
   end if 

   oNodeId     := ::getResponseTextAsXml():findFirst( 'id' ) 
   if empty( oNodeId )
      RETURN ( nil )
   end if 

   oNodeData   :=  oNodeId:NextInTree()
   if !empty( oNodeData )
      RETURN ( oNodeData:cData ) 
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------// 

METHOD runPost( idParent )

   ::createPostXml( idParent )
   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   ::SetRequestHeader( "Content-Length", len( ::getXml() ) )
   ::Send( ::getXml() )

RETURN ( nil )

//---------------------------------------------------------------------------// 

METHOD runGetXml()

   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::Send()

RETURN ( nil )

//---------------------------------------------------------------------------// 

METHOD runGetJSon()

   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::oService:SetRequestHeader( "Output-Format", "JSON" )
   ::Send()

RETURN ( nil )

//---------------------------------------------------------------------------// 

METHOD runPut( nId, idParent )

   ::createPutXml( nId, idParent )
   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   ::SetRequestHeader( "Content-Length", len( ::getXml() ) )
   ::Send( ::getXml() )

RETURN ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS LanguagesWebService FROM WebService

   DATA cSource        INIT "languages"

   METHOD getListIdsLenguages()

END CLASS

//---------------------------------------------------------------------------//

METHOD getListIdsLenguages() CLASS LanguagesWebService

   local hJson
   local aJson
   local aIdsLanguages  := {}

   if ::getStatus() != 200
      RETURN ( nil )
   end if

   hb_jsonDecode( ::getResponseText(), @hJson )   

   aJson    := hGet( hJson, "languages" )

   aEval( aJson, { |a| aAdd( aIdsLanguages, hGet( a, "id" ) ) } )

RETURN ( aIdsLanguages )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ImagesTypesWebService FROM WebService

   DATA cSource        INIT "image_types"

   METHOD getListImageTypes()

   METHOD getArrayImageTypes()

END CLASS

//---------------------------------------------------------------------------//

METHOD getListImageTypes() CLASS ImagesTypesWebService

   local hJson
   local aJson
   local aIdsImageTypes  := {}

   if ::getStatus() != 200
      RETURN ( nil )
   end if

   hb_jsonDecode( ::getResponseText(), @hJson )

   aJson    := hGet( hJson, "image_types" )

   aEval( aJson, { |a| aAdd( aIdsImageTypes, hGet( a, "id" ) ) } )

RETURN ( aIdsImageTypes )

//---------------------------------------------------------------------------//

METHOD getArrayImageTypes() CLASS ImagesTypesWebService

   local hJson

   if ::getStatus() != 200
      RETURN ( nil )
   end if

   hb_jsonDecode( ::getResponseText(), @hJson )

RETURN ( hGet( hJson, "image_type" ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS categoriesWebService  FROM WebService

   DATA cSource        INIT "categories"

   DATA hName          INIT {=>} 

   METHOD createPostXml()
   METHOD createPutXml()

   METHOD setHName( hName )      INLINE ( ::hName  := hName )

END CLASS

//---------------------------------------------------------------------------//

METHOD createPostXml( idParent ) CLASS categoriesWebService

   local oXmlHead
   local oXmlPrincipal
   local oXmlxlink
   local oXmlNode

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'category' )

   oXmlxlink:addBelow( oXmlHead )

   //id_shop_default

   oXmlNode   := TXmlNode():new( , 'id_shop_default', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //idParent

   oXmlNode   := TXmlNode():new( , 'id_parent', , hb_ntos( idParent ) )
   oXmlHead:addBelow( oXmlNode )

   //active

   oXmlNode   := TXmlNode():new( , 'active', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //Name

   oXmlNode   := TXmlNode():new( , 'name' )

      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } )
   
   oXmlHead:addBelow( oXmlNode )

   //description

   oXmlNode   := TXmlNode():new( , 'description' )

      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   
   oXmlHead:addBelow( oXmlNode )

   //link_rewrite

   oXmlNode   := TXmlNode():new( , 'link_rewrite' )

      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, StrTran( v, " ", "_" ) ) ) } )
   
   oXmlHead:addBelow( oXmlNode )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPutXml( idCategory, idParent ) CLASS categoriesWebService

   local oXmlHead
   local oXmlPrincipal
   local oXmlxlink
   local oXmlNode

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'category' )

   oXmlxlink:addBelow( oXmlHead )

   //id

   oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( idCategory ) )
   oXmlHead:addBelow( oXmlNode )

   //id_shop_default

   oXmlNode   := TXmlNode():new( , 'id_shop_default', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //idParent

   oXmlNode   := TXmlNode():new( , 'id_parent', , hb_ntos( idParent ) )
   oXmlHead:addBelow( oXmlNode )

   //active

   oXmlNode   := TXmlNode():new( , 'active', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //Name

   oXmlNode   := TXmlNode():new( , 'name' )

      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } )
   
   oXmlHead:addBelow( oXmlNode )

   //description

   oXmlNode   := TXmlNode():new( , 'description' )

      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } )
   
   oXmlHead:addBelow( oXmlNode )

   //link_rewrite

   oXmlNode   := TXmlNode():new( , 'link_rewrite' )

      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, StrTran( v, " ", "_" ) ) ) } )
   
   oXmlHead:addBelow( oXmlNode )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()
   
RETURN ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS manufacturerWebService  FROM WebService

   DATA cSource        INIT "manufacturers"

   DATA hName          INIT {=>} 
   DATA cName          INIT ""

   METHOD createPostXml()
   METHOD createPutXml()

   METHOD setHName( hName )      INLINE ( ::hName  := hName )

END CLASS

//---------------------------------------------------------------------------//

METHOD createPostXml() CLASS manufacturerWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'manufacturer' )

   oXmlxlink:addBelow( oXmlHead )

   //active

   oXmlNode   := TXmlNode():new( , 'active', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //name

   oXmlNode   := TXmlNode():new( , 'name', , AllTrim( ::cName ) )
   oXmlHead:addBelow( oXmlNode )

   //description

   oXmlNode   := TXmlNode():new( , 'description' )

      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   
   oXmlHead:addBelow( oXmlNode )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPutXml( idFab ) CLASS manufacturerWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'manufacturer' )

   oXmlxlink:addBelow( oXmlHead )

   //id

   oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( idFab ) )
   oXmlHead:addBelow( oXmlNode )

   //active

   oXmlNode   := TXmlNode():new( , 'active', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //name

   oXmlNode   := TXmlNode():new( , 'name', , AllTrim( ::cName ) )
   oXmlHead:addBelow( oXmlNode )

   //description

   oXmlNode   := TXmlNode():new( , 'description' )

      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } )
   
   oXmlHead:addBelow( oXmlNode )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()
   
RETURN ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS productWebService  FROM WebService

   DATA cSource        INIT "products"

   DATA hName          INIT {=>} 

   METHOD createPostXml( hProduct )
   METHOD createPutXml( idProduct, hProduct )
   METHOD createStockPutXml( idProduct, hProduct, nIdStock, nidproductattribute )

   METHOD setHName( hName )      INLINE ( ::hName  := hName )

   METHOD runPut( idProduct, hProduct, nIdStock, nidproductattribute )

END CLASS

//---------------------------------------------------------------------------//

METHOD runPut( idProduct, hProduct, nIdStock, nidproductattribute ) CLASS productWebService

   if hb_isnil( nIdStock )
      ::createPutXml( idProduct, hProduct )
   else
      ::createStockPutXml( idProduct, hProduct, nIdStock, nidproductattribute )
   end if

   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   ::SetRequestHeader( "Content-Length", len( ::getXml() ) )
   ::Send( ::getXml() )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPostXml( hProduct ) CLASS productWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode
   local oXmlAsociation
   local oXmlAsociationNode
   local oXmlAsociationNodeName
   local idManufacturer

   if !Empty( hGet( hProduct, "id_manufacturer" ) )
      idManufacturer    := ::oParent:getPrestashopIdInstance():getValueManufacturer( hGet( hProduct, "id_manufacturer" ), ::oParent:oController:getWeb() )
   end if

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'product' )

   oXmlxlink:addBelow( oXmlHead )

   //id_manufacturer
   
   if !Empty( hGet( hProduct, "id_manufacturer" ) ) .and. !Empty( idManufacturer )
      oXmlNode   := TXmlNode():new( , 'id_manufacturer', , hb_ntos( idManufacturer ) )
      oXmlHead:addBelow( oXmlNode )
   end if

   //id_category_default
   oXmlNode   := TXmlNode():new( , 'id_category_default', , hb_ntos( ::oParent:getPrestashopIdInstance():getValueCategory( hGet( hProduct, "id_category_default" ), ::oParent:oController:getWeb() ) ) )
   oXmlHead:addBelow( oXmlNode )

   //id_shop_default
   oXmlNode   := TXmlNode():new( , 'id_shop_default', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //id_tax_rules_group
   oXmlNode   := TXmlNode():new( , 'id_tax_rules_group', , hb_ntos( ::oParent:getPrestashopIdInstance():getValueTaxRuleGroup( hGet( hProduct, "id_tax_rules_group" ), ::oParent:oController:getWeb() ) ) )
   oXmlHead:addBelow( oXmlNode )

   //reference
   oXmlNode   := TXmlNode():new( , 'reference', , AllTrim( hGet( hProduct, "id" ) ) )
   oXmlHead:addBelow( oXmlNode )

   //state
   oXmlNode   := TXmlNode():new( , 'state', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //additional_delivery_times
   oXmlNode   := TXmlNode():new( , 'additional_delivery_times', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //minimal_quantity
   oXmlNode   := TXmlNode():new( , 'minimal_quantity', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //low_stock_alert
   oXmlNode   := TXmlNode():new( , 'low_stock_alert', , hb_ntos( 0 ) )
   oXmlHead:addBelow( oXmlNode )

   //active
   oXmlNode   := TXmlNode():new( , 'active', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //price
   oXmlNode   := TXmlNode():new( , 'price', , hb_ntos( hGet( hProduct, "price" ) ) )
   oXmlHead:addBelow( oXmlNode )

   //available_for_order
   oXmlNode   := TXmlNode():new( , 'available_for_order', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //show_condition
   oXmlNode   := TXmlNode():new( , 'show_condition', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //condition
   oXmlNode   := TXmlNode():new( , 'condition', , 'new' )
   oXmlHead:addBelow( oXmlNode )

   //show_price
   oXmlNode   := TXmlNode():new( , 'show_price', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //visibility
   oXmlNode   := TXmlNode():new( , 'visibility', , 'both' )
   oXmlHead:addBelow( oXmlNode )

   //pack_stock_type
   oXmlNode   := TXmlNode():new( , 'pack_stock_type', , hb_ntos( 3 ) )
   oXmlHead:addBelow( oXmlNode )

   //meta_description
   oXmlNode   := TXmlNode():new( , 'meta_description' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "meta_description" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //meta_keywords
   oXmlNode   := TXmlNode():new( , 'meta_keywords' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "meta_keywords" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //meta_title
   oXmlNode   := TXmlNode():new( , 'meta_title' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "meta_title" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //link_rewrite
   oXmlNode   := TXmlNode():new( , 'link_rewrite' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "link_rewrite" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //name
   oXmlNode   := TXmlNode():new( , 'name' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "name" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //description
   oXmlNode   := TXmlNode():new( , 'description' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "description" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //description_short
   oXmlNode   := TXmlNode():new( , 'description_short' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //associations
   oXmlAsociation   := TXmlNode():new( , 'associations' )
      
      //Categorias asociadas
      oXmlAsociationNode := TXmlNode():new( , 'categories' )
      
         oXmlAsociationNodeName  := TXmlNode():new( , 'category' )

            oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( ::oParent:getPrestashopIdInstance():getValueCategory( hGet( hProduct, "id_category_default" ), ::oParent:oController:getWeb() ) ) )
            oXmlAsociationNodeName:addBelow( oXmlNode )

         oXmlAsociationNode:addBelow( oXmlAsociationNodeName )            

      oXmlAsociation:addBelow( oXmlAsociationNode ) 

   oXmlHead:addBelow( oXmlAsociation )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPutXml( idProduct, hProduct ) CLASS productWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode
   local oXmlAsociation
   local oXmlAsociationNode
   local oXmlAsociationNodeName
   local idManufacturer

   if !Empty( hGet( hProduct, "id_manufacturer" ) )
      idManufacturer    := ::oParent:getPrestashopIdInstance():getValueManufacturer( hGet( hProduct, "id_manufacturer" ), ::oParent:oController:getWeb() )
   end if

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'product' )

   oXmlxlink:addBelow( oXmlHead )

   //id
   oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( idProduct ) )
   oXmlHead:addBelow( oXmlNode )

   //id_manufacturer
   if !Empty( hGet( hProduct, "id_manufacturer" ) ) .and. !Empty( idManufacturer )
      oXmlNode   := TXmlNode():new( , 'id_manufacturer', , hb_ntos( idManufacturer ) )
      oXmlHead:addBelow( oXmlNode )
   end if

   //id_category_default
   oXmlNode   := TXmlNode():new( , 'id_category_default', , hb_ntos( ::oParent:getPrestashopIdInstance():getValueCategory( hGet( hProduct, "id_category_default" ), ::oParent:oController:getWeb() ) ) )
   oXmlHead:addBelow( oXmlNode )

   //id_shop_default
   oXmlNode   := TXmlNode():new( , 'id_shop_default', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //id_tax_rules_group
   oXmlNode   := TXmlNode():new( , 'id_tax_rules_group', , hb_ntos( ::oParent:getPrestashopIdInstance():getValueTaxRuleGroup( hGet( hProduct, "id_tax_rules_group" ), ::oParent:oController:getWeb() ) ) )
   oXmlHead:addBelow( oXmlNode )

   //reference
   oXmlNode   := TXmlNode():new( , 'reference', , AllTrim( hGet( hProduct, "id" ) ) )
   oXmlHead:addBelow( oXmlNode )

   //state
   oXmlNode   := TXmlNode():new( , 'state', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //additional_delivery_times
   oXmlNode   := TXmlNode():new( , 'additional_delivery_times', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //minimal_quantity
   oXmlNode   := TXmlNode():new( , 'minimal_quantity', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //low_stock_alert
   oXmlNode   := TXmlNode():new( , 'low_stock_alert', , hb_ntos( 0 ) )
   oXmlHead:addBelow( oXmlNode )

   //active
   oXmlNode   := TXmlNode():new( , 'active', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //price
   oXmlNode   := TXmlNode():new( , 'price', , hb_ntos( hGet( hProduct, "price" ) ) )
   oXmlHead:addBelow( oXmlNode )

   //available_for_order
   oXmlNode   := TXmlNode():new( , 'available_for_order', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //show_condition
   oXmlNode   := TXmlNode():new( , 'show_condition', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //condition
   oXmlNode   := TXmlNode():new( , 'condition', , 'new' )
   oXmlHead:addBelow( oXmlNode )

   //show_price
   oXmlNode   := TXmlNode():new( , 'show_price', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //visibility
   oXmlNode   := TXmlNode():new( , 'visibility', , 'both' )
   oXmlHead:addBelow( oXmlNode )

   //pack_stock_type
   oXmlNode   := TXmlNode():new( , 'pack_stock_type', , hb_ntos( 3 ) )
   oXmlHead:addBelow( oXmlNode )

   //meta_description
   oXmlNode   := TXmlNode():new( , 'meta_description' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "meta_description" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //meta_keywords
   oXmlNode   := TXmlNode():new( , 'meta_keywords' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "meta_keywords" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //meta_title
   oXmlNode   := TXmlNode():new( , 'meta_title' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "meta_title" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //link_rewrite
   oXmlNode   := TXmlNode():new( , 'link_rewrite' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "link_rewrite" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //name
   oXmlNode   := TXmlNode():new( , 'name' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "name" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //description
   oXmlNode   := TXmlNode():new( , 'description' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "description" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //description_short
   oXmlNode   := TXmlNode():new( , 'description_short' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //associations
   oXmlAsociation   := TXmlNode():new( , 'associations' )
      
      oXmlAsociationNode := TXmlNode():new( , 'categories' )
      
         oXmlAsociationNodeName  := TXmlNode():new( , 'category' )

            oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( ::oParent:getPrestashopIdInstance():getValueCategory( hGet( hProduct, "id_category_default" ), ::oParent:oController:getWeb() ) ) )
            oXmlAsociationNodeName:addBelow( oXmlNode )

         oXmlAsociationNode:addBelow( oXmlAsociationNodeName )            

      oXmlAsociation:addBelow( oXmlAsociationNode )   
   
   oXmlHead:addBelow( oXmlAsociation )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createStockPutXml( idProduct, hProduct, nIdStock, nidproductattribute ) CLASS productWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode
   local oXmlAsociation
   local oXmlAsociationNode
   local oXmlAsociationNodeName
   local idManufacturer

   if !Empty( hGet( hProduct, "id_manufacturer" ) )
      idmanufacturer   := ::oParent:getPrestashopIdInstance():getValueManufacturer( hGet( hProduct, "id_manufacturer" ), ::oParent:oController:getWeb() )
   end if

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'product' )

   oXmlxlink:addBelow( oXmlHead )

   //id
   oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( idProduct ) )
   oXmlHead:addBelow( oXmlNode )

   //id_manufacturer
   if !Empty( hGet( hProduct, "id_manufacturer" ) ) .and. !Empty( idManufacturer )
      oXmlNode   := TXmlNode():new( , 'id_manufacturer', , hb_ntos( idManufacturer ) )
      oXmlHead:addBelow( oXmlNode )
   end if

   //id_category_default
   oXmlNode   := TXmlNode():new( , 'id_category_default', , hb_ntos( ::oParent:getPrestashopIdInstance():getValueCategory( hGet( hProduct, "id_category_default" ), ::oParent:oController:getWeb() ) ) )
   oXmlHead:addBelow( oXmlNode )

   //id_shop_default
   oXmlNode   := TXmlNode():new( , 'id_shop_default', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //id_tax_rules_group
   oXmlNode   := TXmlNode():new( , 'id_tax_rules_group', , hb_ntos( ::oParent:getPrestashopIdInstance():getValueTaxRuleGroup( hGet( hProduct, "id_tax_rules_group" ), ::oParent:oController:getWeb() ) ) )
   oXmlHead:addBelow( oXmlNode )

   //reference
   oXmlNode   := TXmlNode():new( , 'reference', , AllTrim( hGet( hProduct, "id" ) ) )
   oXmlHead:addBelow( oXmlNode )

   //state
   oXmlNode   := TXmlNode():new( , 'state', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //additional_delivery_times
   oXmlNode   := TXmlNode():new( , 'additional_delivery_times', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //minimal_quantity
   oXmlNode   := TXmlNode():new( , 'minimal_quantity', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //low_stock_alert
   oXmlNode   := TXmlNode():new( , 'low_stock_alert', , hb_ntos( 0 ) )
   oXmlHead:addBelow( oXmlNode )

   //active
   oXmlNode   := TXmlNode():new( , 'active', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //price
   oXmlNode   := TXmlNode():new( , 'price', , hb_ntos( hGet( hProduct, "price" ) ) )
   oXmlHead:addBelow( oXmlNode )

   //available_for_order
   oXmlNode   := TXmlNode():new( , 'available_for_order', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //show_condition
   oXmlNode   := TXmlNode():new( , 'show_condition', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //condition
   oXmlNode   := TXmlNode():new( , 'condition', , 'new' )
   oXmlHead:addBelow( oXmlNode )

   //show_price
   oXmlNode   := TXmlNode():new( , 'show_price', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //visibility
   oXmlNode   := TXmlNode():new( , 'visibility', , 'both' )
   oXmlHead:addBelow( oXmlNode )

   //pack_stock_type
   oXmlNode   := TXmlNode():new( , 'pack_stock_type', , hb_ntos( 3 ) )
   oXmlHead:addBelow( oXmlNode )

   //meta_description
   oXmlNode   := TXmlNode():new( , 'meta_description' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "meta_description" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //meta_keywords
   oXmlNode   := TXmlNode():new( , 'meta_keywords' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "meta_keywords" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //meta_title
   oXmlNode   := TXmlNode():new( , 'meta_title' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "meta_title" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //link_rewrite
   oXmlNode   := TXmlNode():new( , 'link_rewrite' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "link_rewrite" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //name
   oXmlNode   := TXmlNode():new( , 'name' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "name" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //description
   oXmlNode   := TXmlNode():new( , 'description' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, hGet( hProduct, "description" ) ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //description_short
   oXmlNode   := TXmlNode():new( , 'description_short' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //associations
   oXmlAsociation   := TXmlNode():new( , 'associations' )
      
      //Stock -----------------------------------------------------------------

      oXmlAsociationNode := TXmlNode():new( , 'stock_availables' )
      
         oXmlAsociationNodeName  := TXmlNode():new( , 'stock_available' )

            oXmlAsociationNodeName:addBelow( TXmlNode():new( , 'id', , hb_ntos( nIdStock ) ) )
            oXmlAsociationNodeName:addBelow( TXmlNode():new( , 'id_product_attribute', , hb_ntos( nidproductattribute ) ) )

         oXmlAsociationNode:addBelow( oXmlAsociationNodeName )            

      oXmlAsociation:addBelow( oXmlAsociationNode )
   
   oXmlHead:addBelow( oXmlAsociation )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()

RETURN ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS stockProductWebService  FROM WebService

   DATA cSource                  INIT "stock_availables"

   DATA hName                    INIT {=>} 

   METHOD createPostXml(  hStock, idProduct, idproductattribute )
   METHOD createPutXml(  hStock, idProduct, idproductattribute, idStock )

   METHOD runPost( hStock, idProduct, idproductattribute )
   METHOD runPut( hStock, idProduct, idproductattribute, idStock )

   METHOD setHName( hName )      INLINE ( ::hName  := hName )

   METHOD getListIdsStocks()

   METHOD getArrayStocks()

END CLASS

//---------------------------------------------------------------------------//

METHOD runPost( hStock, idProduct, idproductattribute ) CLASS stockProductWebService

   ::createPostXml( hStock, idProduct, idproductattribute )
   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   ::SetRequestHeader( "Content-Length", len( ::getXml() ) )
   ::Send( ::getXml() )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD runPut( hStock, idProduct, idproductattribute, idStock ) CLASS stockProductWebService

   ::createPutXml( hStock, idProduct, idproductattribute, idStock )
   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   ::SetRequestHeader( "Content-Length", len( ::getXml() ) )
   ::Send( ::getXml() )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPutXml( hStock, idProduct, idproductattribute, idStock ) CLASS stockProductWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode
   local oXmlAsociation
   local oXmlAsociationNode
   local oXmlAsociationNodeName

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'stock_available' )

   oXmlxlink:addBelow( oXmlHead )

   //id
   oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( idStock ) )
   oXmlHead:addBelow( oXmlNode )

   //id_product
   oXmlNode   := TXmlNode():new( , 'id_product', , hb_ntos( idProduct ) )
   oXmlHead:addBelow( oXmlNode )

   //id_product_attribute
   oXmlNode   := TXmlNode():new( , 'id_product_attribute', , hb_ntos( idproductattribute ) )
   oXmlHead:addBelow( oXmlNode )

   //id_shop
   oXmlNode   := TXmlNode():new( , 'id_shop', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //quantity
   oXmlNode   := TXmlNode():new( , 'quantity', , hb_ntos( int( hget( hStock, "unidades" ) ) ) )
   oXmlHead:addBelow( oXmlNode )

   //depends_on_stock
   oXmlNode   := TXmlNode():new( , 'depends_on_stock', , hb_ntos( 0 ) )
   oXmlHead:addBelow( oXmlNode )

   //out_of_stock
   oXmlNode   := TXmlNode():new( , 'out_of_stock', , hb_ntos( 2 ) )
   oXmlHead:addBelow( oXmlNode )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPostXml( hStock, idProduct, idproductattribute ) CLASS stockProductWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode
   local oXmlAsociation
   local oXmlAsociationNode
   local oXmlAsociationNodeName

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'stock_available' )

   oXmlxlink:addBelow( oXmlHead )

   //id_product
   oXmlNode   := TXmlNode():new( , 'id_product', , hb_ntos( idProduct ) )
   oXmlHead:addBelow( oXmlNode )

   //id_product_attribute
   oXmlNode   := TXmlNode():new( , 'id_product_attribute', , hb_ntos( idproductattribute ) )
   oXmlHead:addBelow( oXmlNode )

   //id_shop
   oXmlNode   := TXmlNode():new( , 'id_shop', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //quantity
   oXmlNode   := TXmlNode():new( , 'quantity', , hb_ntos( Int( hget( hStock, "unidades" ) ) ) )
   oXmlHead:addBelow( oXmlNode )

   //depends_on_stock
   oXmlNode   := TXmlNode():new( , 'depends_on_stock', , hb_ntos( 0 ) )
   oXmlHead:addBelow( oXmlNode )

   //out_of_stock
   oXmlNode   := TXmlNode():new( , 'out_of_stock', , hb_ntos( 2 ) )
   oXmlHead:addBelow( oXmlNode )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getListIdsStocks() CLASS stockProductWebService

   local hJson
   local aJson
   local aIdsStocks  := {}

   if ::getStatus() != 200
      RETURN ( nil )
   end if

   hb_jsonDecode( ::getResponseText(), @hJson )

   aJson    := hGet( hJson, "stock_availables" )

   aEval( aJson, { |a| aAdd( aIdsStocks, hGet( a, "id" ) ) } )

RETURN ( aIdsStocks )

//---------------------------------------------------------------------------//

METHOD getArrayStocks() CLASS stockProductWebService

   local hJson

   if ::getStatus() != 200
      RETURN ( nil )
   end if

   hb_jsonDecode( ::getResponseText(), @hJson )

RETURN ( hGet( hJson, "stock_available" ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS propiedadesWebService  FROM WebService

   DATA cSource        INIT "product_options"

   DATA hName          INIT {=>} 
   DATA cName          INIT ""

   METHOD createPostXml()
   METHOD createPutXml()

   METHOD setHName( hName )      INLINE ( ::hName  := hName )

END CLASS

//---------------------------------------------------------------------------//

METHOD createPostXml( hPropertie ) CLASS propiedadesWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'product_option' )

   oXmlxlink:addBelow( oXmlHead )

   //isColor
   oXmlNode   := TXmlNode():new( , 'is_color_group', , if( hGet( hPropertie, "lColor" ), hb_ntos( 1 ), hb_ntos( 0 ) ) )
   oXmlHead:addBelow( oXmlNode )

   //group_type
   oXmlNode   := TXmlNode():new( , 'group_type', , if( hGet( hPropertie, "lColor" ), "color", "select" ) )
   oXmlHead:addBelow( oXmlNode )

   //name
   oXmlNode   := TXmlNode():new( , 'name' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //public_name
   oXmlNode   := TXmlNode():new( , 'public_name' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPutXml( idPro, hPropertie ) CLASS propiedadesWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'product_option' )

   oXmlxlink:addBelow( oXmlHead )

   //id
   oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( idPro ) )
   oXmlHead:addBelow( oXmlNode )

   //isColor
   oXmlNode   := TXmlNode():new( , 'is_color_group', , if( hGet( hPropertie, "lColor" ), hb_ntos( 1 ), hb_ntos( 0 ) ) )
   oXmlHead:addBelow( oXmlNode )

   //group_type
   oXmlNode   := TXmlNode():new( , 'group_type', , if( hGet( hPropertie, "lColor" ), "color", "select" ) )
   oXmlHead:addBelow( oXmlNode )

   //name
   oXmlNode   := TXmlNode():new( , 'name' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   //public_name
   oXmlNode   := TXmlNode():new( , 'public_name' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()
   
RETURN ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS valoresPropiedadesWebService  FROM WebService

   DATA cSource        INIT "product_option_values"

   DATA hName          INIT {=>} 
   DATA cName          INIT ""

   METHOD runPost( hValue, idProp )
   METHOD runPut( nId, hValue, idProp )

   METHOD createPostXml()
   METHOD createPutXml()

   METHOD setHName( hName )      INLINE ( ::hName  := hName )

END CLASS

//---------------------------------------------------------------------------//

METHOD runPost( hValue, idProp ) CLASS valoresPropiedadesWebService

   ::createPostXml( hValue, idProp )
   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   ::SetRequestHeader( "Content-Length", len( ::getXml() ) )
   ::Send( ::getXml() )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD runPut( nId, hValue, idProp ) CLASS valoresPropiedadesWebService

   ::createPutXml( nId, hValue, idProp )
   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   ::SetRequestHeader( "Content-Length", len( ::getXml() ) )
   ::Send( ::getXml() )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPostXml( hValue, idProp ) CLASS valoresPropiedadesWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'product_option_value' )

   oXmlxlink:addBelow( oXmlHead )

   //id_attribute_group 
   oXmlNode   := TXmlNode():new( , 'id_attribute_group', , hb_ntos( idProp ) )
   oXmlHead:addBelow( oXmlNode )

   //color
   oXmlNode   := TXmlNode():new( , 'color', , hGet( hValue, "color" ) )
   oXmlHead:addBelow( oXmlNode )

   //name
   oXmlNode   := TXmlNode():new( , 'name' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPutXml( nId, hValue, idProp  ) CLASS valoresPropiedadesWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'product_option_value' )

   oXmlxlink:addBelow( oXmlHead )

   //id
   oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( nId ) )
   oXmlHead:addBelow( oXmlNode )

   //id_attribute_group 
   oXmlNode   := TXmlNode():new( , 'id_attribute_group', , hb_ntos( idProp ) )
   oXmlHead:addBelow( oXmlNode )

   //color
   oXmlNode   := TXmlNode():new( , 'color', , hGet( hValue, "color" ) )
   oXmlHead:addBelow( oXmlNode )

   //name
   oXmlNode   := TXmlNode():new( , 'name' )
      heval( ::hName, {|k,v| oXmlNode:addBelow( TXmlNode():new( , 'language', { "id" => k }, v ) ) } ) 
   oXmlHead:addBelow( oXmlNode )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()
   
RETURN ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS combinationsWebService  FROM WebService

   DATA cSource        INIT "combinations"

   DATA hName          INIT {=>} 
   DATA cName          INIT ""

   METHOD runPost( hCombination )
   METHOD runPut( nId, hCombination )

   METHOD createPostXml()
   METHOD createPutXml()

   METHOD setHName( hName )      INLINE ( ::hName  := hName )

END CLASS

//---------------------------------------------------------------------------//

METHOD runPost( hCombination ) CLASS combinationsWebService

   ::createPostXml( hCombination )
   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   ::SetRequestHeader( "Content-Length", len( ::getXml() ) )
   ::Send( ::getXml() )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD runPut( nId, hCombination ) CLASS combinationsWebService

   ::createPutXml( nId, hCombination )
   ::setParams( "ws_key", ::getKey() )
   ::Open()
   ::SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   ::SetRequestHeader( "Content-Length", len( ::getXml() ) )
   ::Send( ::getXml() )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPostXml( hCombination ) CLASS combinationsWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode
   local oXmlAsociation
   local oXmlAsociationNode
   local oXmlAsociationNodeName
   local nIdProduct
   local nIdVal1
   local nIdVal2
   local nIdImg

   nIdProduct     := ::oParent:getPrestashopIdInstance():getValueProduct( hGet( hCombination, "CCODART" ), ::oParent:oController:getWeb() )
   nIdVal1        := ::oParent:getPrestashopIdInstance():getValueAttribute( hGet( hCombination, "CCODPR1" ) + hGet( hCombination, "CVALPR1" ), ::oParent:oController:getWeb() )
   nIdVal2        := ::oParent:getPrestashopIdInstance():getValueAttribute( hGet( hCombination, "CCODPR2" ) + hGet( hCombination, "CVALPR2" ), ::oParent:oController:getWeb() )
   nIdImg         := ::oParent:getPrestashopIdInstance():getValueImage( hGet( hCombination, "CCODART" ) + Str( ArticulosImagenesModel():idImagenArticulo( hGet( hCombination, "CCODART" ), StrTran( hGet( hCombination, "MIMGWEB" ), ",", "" ) ), 10 ), ::oParent:oController:getWeb() )

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'combination' )

   oXmlxlink:addBelow( oXmlHead )

   //id_product  
   oXmlNode   := TXmlNode():new( , 'id_product', , hb_ntos( nIdProduct ) )
   oXmlHead:addBelow( oXmlNode )

   //quantity
   oXmlNode   := TXmlNode():new( , 'quantity', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //price
   oXmlNode   := TXmlNode():new( , 'price', , hb_ntos( hGet( hCombination, "NPREVTA1" ) ) )
   oXmlHead:addBelow( oXmlNode )

   //minimal_quantity
   oXmlNode   := TXmlNode():new( , 'minimal_quantity', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )
   
   //associations
   oXmlAsociation   := TXmlNode():new( , 'associations' )
      
      //propiedades asociadas
      oXmlAsociationNode := TXmlNode():new( , 'product_option_values' )
      
         oXmlAsociationNodeName  := TXmlNode():new( , 'product_option_value' )

            oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( nIdVal1 ) )
            oXmlAsociationNodeName:addBelow( oXmlNode )

         oXmlAsociationNode:addBelow( oXmlAsociationNodeName )            

         oXmlAsociationNodeName  := TXmlNode():new( , 'product_option_value' )

            oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( nIdVal2 ) )
            oXmlAsociationNodeName:addBelow( oXmlNode )

         oXmlAsociationNode:addBelow( oXmlAsociationNodeName )

      oXmlAsociation:addBelow( oXmlAsociationNode ) 

      if nIdImg != 0

         //imagen asociadaa
         oXmlAsociationNode := TXmlNode():new( , 'images' )
         
            oXmlAsociationNodeName  := TXmlNode():new( , 'image' )

               oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( nIdImg ) )
               oXmlAsociationNodeName:addBelow( oXmlNode )

            oXmlAsociationNode:addBelow( oXmlAsociationNodeName )            

         oXmlAsociation:addBelow( oXmlAsociationNode )

      end if

   oXmlHead:addBelow( oXmlAsociation )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD createPutXml( nId, hCombination ) CLASS combinationsWebService

   local oXmlHead
   local oXmlxlink
   local oXmlNode
   local oXmlAsociation
   local oXmlAsociationNode
   local oXmlAsociationNodeName
   local nIdProduct
   local nIdVal1
   local nIdVal2
   local nPrice
   local nIdImg

   nIdProduct     := ::oParent:getPrestashopIdInstance():getValueProduct( hGet( hCombination, "CCODART" ), ::oParent:oController:getWeb() )
   nIdVal1        := ::oParent:getPrestashopIdInstance():getValueAttribute( hGet( hCombination, "CCODPR1" ) + hGet( hCombination, "CVALPR1" ), ::oParent:oController:getWeb() )
   nIdVal2        := ::oParent:getPrestashopIdInstance():getValueAttribute( hGet( hCombination, "CCODPR2" ) + hGet( hCombination, "CVALPR2" ), ::oParent:oController:getWeb() )
   nPrice         := if( hGet( hCombination, "NPREVTA1" ) == 0, hGet( hCombination, "NPREVTA1" ), hGet( hCombination, "NPREVTA1" ) - ArticulosModel():getField( 'pVtaWeb', 'Codigo', hGet( hCombination, "CCODART" ) ) )
   nIdImg         := ::oParent:getPrestashopIdInstance():getValueImage( hGet( hCombination, "CCODART" ) + Str( ArticulosImagenesModel():idImagenArticulo( hGet( hCombination, "CCODART" ), StrTran( hGet( hCombination, "MIMGWEB" ), ",", "" ) ), 10 ), ::oParent:oController:getWeb() )

   ::cXml     := TXmlDocument():new( '<?xml version="1.0" encoding="UTF-8"?>' )

   oXmlxlink  := TXmlNode():new( , 'prestashop', { "xmlns:xlink" => "http://www.w3.org/1999/xlink" } )

   oXmlHead   := TXmlNode():new( , 'combination' )

   oXmlxlink:addBelow( oXmlHead )

   //id
   oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( nId ) )
   oXmlHead:addBelow( oXmlNode )

   //id_product  
   oXmlNode   := TXmlNode():new( , 'id_product', , hb_ntos( nIdProduct ) )
   oXmlHead:addBelow( oXmlNode )

   //quantity
   oXmlNode   := TXmlNode():new( , 'quantity', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )

   //price
   oXmlNode   := TXmlNode():new( , 'price', , hb_ntos( nPrice ) )
   oXmlHead:addBelow( oXmlNode )

   //minimal_quantity
   oXmlNode   := TXmlNode():new( , 'minimal_quantity', , hb_ntos( 1 ) )
   oXmlHead:addBelow( oXmlNode )
   
   //associations
   oXmlAsociation   := TXmlNode():new( , 'associations' )
      
      //propiedades asociadas
      oXmlAsociationNode := TXmlNode():new( , 'product_option_values' )
      
         oXmlAsociationNodeName  := TXmlNode():new( , 'product_option_value' )

            oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( nIdVal1 ) )
            oXmlAsociationNodeName:addBelow( oXmlNode )

         oXmlAsociationNode:addBelow( oXmlAsociationNodeName )            

         oXmlAsociationNodeName  := TXmlNode():new( , 'product_option_value' )

            oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( nIdVal2 ) )
            oXmlAsociationNodeName:addBelow( oXmlNode )

         oXmlAsociationNode:addBelow( oXmlAsociationNodeName )

      oXmlAsociation:addBelow( oXmlAsociationNode ) 

      if nIdImg != 0

         //imagen asociadaa
         oXmlAsociationNode := TXmlNode():new( , 'images' )
         
            oXmlAsociationNodeName  := TXmlNode():new( , 'image' )

               oXmlNode   := TXmlNode():new( , 'id', , hb_ntos( nIdImg ) )
               oXmlAsociationNodeName:addBelow( oXmlNode )

            oXmlAsociationNode:addBelow( oXmlAsociationNodeName )            

         oXmlAsociation:addBelow( oXmlAsociationNode )

      end if

   oXmlHead:addBelow( oXmlAsociation )

   ::cXml:oRoot:addBelow( oXmlxlink )

   ::cXml   := ::cXml:ToString()
   
RETURN ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//