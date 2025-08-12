#include "FiveWin.Ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

FUNCTION ImpLatress( oMenuItem, oWnd )

   local oImpLatress
   local nLevel   := Auth():Level( oMenuItem )
   if nAnd( nLevel, 1 ) == 0
      msgStop( "Acceso no permitido." )
      return ( nil )
   end if

   oImpLatress       := ImportLatress():New():Resource()

RETURN nil

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ImportLatress

   DATA oDlg
   DATA nView

   DATA oDireccion
   DATA oUsuario
   DATA oClave

   DATA cDireccion
   DATA cUsuario
   DATA cClave

   DATA cWebImagen

   DATA oArticulos
   DATA cArticulos

   DATA oFamilias
   DATA cFamilias

   DATA oPropiedades
   DATA cPropiedades

   DATA oClientes
   DATA cClientes

   DATA oPedidos
   DATA cPedidos

   DATA oSayProcess

   DATA aProductos

   DATA cSerie
   DATA nNumero
   DATA cSufijo
   DATA cCodCli
   DATA dFecPed
   DATA hProvincias

   METHOD New()

   METHOD Resource()

   METHOD setProcessText( cText )               INLINE ( if( !Empty( ::oSayProcess ), ( ::oSayProcess:SetText( cText ), ::oSayProcess:Refresh(), sysrefresh() ), ) )

   METHOD Importar()

   METHOD addFamilias()
      METHOD addFamilia()
      METHOD updateFamilia()

   METHOD addPropiedades()
      METHOD addPropiedad( aPropiedad )
      METHOD updatePropiedad( aPropiedad )
      METHOD addPropiedadLine( aPropiedadLine )
      METHOD updatePropiedadLine( aPropiedadLine )

   METHOD addArticulos()
      METHOD addArticulo()
      METHOD updateArticulo()
   METHOD addOneArticulo()
   METHOD addVariations()

   METHOD addClientes()
      METHOD addCliente( hCliente )
      METHOD addClienteNotReg( hCliente )

   METHOD addPedidos()
      METHOD addPedido( hPedido )
      METHOD addLineaPedido( hLinea )

   METHOD ActualizaStock( hPropiedades )

   METHOD getProductosWp()

   METHOD getidProductWp( cCodArt )

   METHOD addFtpImage( cFile )
   METHOD cleanFtp()

   METHOD GetProv( cProv )

   METHOD ActStockArticulo( cId, cCodArt )

   METHOD activateArticulo( cId )
   METHOD desactivateArticulo( cId )
   METHOD getArticulo( cId )

   METHOD saveConfig()

   METHOD Prueba()

END CLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS ImportLatress

   ::cDireccion      := "https://perfectainvitada.es/" //Space( 200 )
   ::cUsuario        := "ck_66c156d66673cd6da0fead5d720cb3b06b1d771d" //Space( 200 )
   ::cClave          := "cs_4cb3ddb87d4b2c9da1b4e39066c30bb7ff61a33d" //Space( 200 )

   //::cDireccion      := padr( ConfiguracionesEmpresaModel():getValue( 'direccionWP', 'http://talleresbeldet.com/' ), 200 )                           //   https://gestool.es/ps/
   //::cUsuario        := padr( ConfiguracionesEmpresaModel():getValue( 'usuarioWP', 'ck_81763c14f1311bdf327b899fc6347aff4e248629' ), 200 )        //   ck_382906a57eb00fab49f1509e367c7e98f585ff6d
   //::cClave          := padr( ConfiguracionesEmpresaModel():getValue( 'claveWP', 'cs_b9dc3e2b5076a7caaf4299a1565dafcab95ee793' ), 200 )          //   cs_41e2f996ef9b6d948de1596710d25470a11a2d97


   ::cArticulos      := padr( ConfiguracionesEmpresaModel():getValue( 'articulosWP', 'wp-json/wc/v3/products' ), 200 )                           //   wp-json/wc/v3/products
   ::cFamilias       := padr( ConfiguracionesEmpresaModel():getValue( 'familiasWP', 'wp-json/wc/v3/products/categories' ), 200 )                 //   wp-json/wc/v3/products/categories
   ::cPropiedades    := padr( ConfiguracionesEmpresaModel():getValue( 'propiedadesWP', 'wp-json/wc/v3/products/attributes' ), 200 )              //   wp-json/wc/v3/products/attributes
   ::cClientes       := padr( ConfiguracionesEmpresaModel():getValue( 'clientesWP', 'wp-json/wc/v3/customers' ), 200 )                           //   wp-json/wc/v3/customers
   ::cPedidos        := padr( ConfiguracionesEmpresaModel():getValue( 'pedidosWP', 'wp-json/wc/v3/orders' ), 200 )                               //   wp-json/wc/v3/orders
   ::cWebImagen      := padr( ConfiguracionesEmpresaModel():getValue( 'imagenesWP', 'https://gestool.es/imageneswp/' ), 200 )                    //   https://gestool.es/imageneswp/

   ::cSerie          := ""
   ::nNumero         := 0
   ::cSufijo         := ""
   ::cCodCli         := ""
   ::dFecPed         := Stod( "" )

   ::hProvincias     := {=>}
   hSet( ::hProvincias, "VI", "Álava" )
   hSet( ::hProvincias, "AB", "Albacete" )
   hSet( ::hProvincias, "A" , "Alicante" )
   hSet( ::hProvincias, "AL", "Almería" )
   hSet( ::hProvincias, "AV", "Ávila" )
   hSet( ::hProvincias, "BA", "Badajoz" )
   hSet( ::hProvincias, "B" , "Barcelona" )
   hSet( ::hProvincias, "BU", "Burgos" )
   hSet( ::hProvincias, "CC", "Cáceres" )
   hSet( ::hProvincias, "CA", "Cádiz" )
   hSet( ::hProvincias, "CS", "Castellón" )
   hSet( ::hProvincias, "CR", "Ciudad Real" )
   hSet( ::hProvincias, "CO", "Córdoba" )
   hSet( ::hProvincias, "C" , "La Coruña" )
   hSet( ::hProvincias, "CU", "Cuenca" )
   hSet( ::hProvincias, "GE", "Gerona" )
   hSet( ::hProvincias, "GR", "Granada" )
   hSet( ::hProvincias, "GU", "Guadalajara" )
   hSet( ::hProvincias, "SS", "Guipúzcoa" )
   hSet( ::hProvincias, "H" , "Huelva" )
   hSet( ::hProvincias, "HU", "Huesca" )
   hSet( ::hProvincias, "J" , "Jaén" )
   hSet( ::hProvincias, "LE", "León" )
   hSet( ::hProvincias, "L" , "Lérida" )
   hSet( ::hProvincias, "LO", "La Rioja" )
   hSet( ::hProvincias, "LU", "Lugo" )
   hSet( ::hProvincias, "M" , "Madrid" )
   hSet( ::hProvincias, "MA", "Málaga" )
   hSet( ::hProvincias, "MU", "Murcia" )
   hSet( ::hProvincias, "NA", "Navarra" )
   hSet( ::hProvincias, "OR", "Orense" )
   hSet( ::hProvincias, "O" , "Asturias" )
   hSet( ::hProvincias, "P" , "Palencia" )
   hSet( ::hProvincias, "GC", "Las Palmas" )
   hSet( ::hProvincias, "PO", "Pontevedra" )
   hSet( ::hProvincias, "SA", "Salamanca" )
   hSet( ::hProvincias, "TF", "Santa Cruz de Tenerife" )
   hSet( ::hProvincias, "S" , "Cantabria" )
   hSet( ::hProvincias, "SG", "Segovia" )
   hSet( ::hProvincias, "SE", "Sevilla" )
   hSet( ::hProvincias, "SO", "Soria" )
   hSet( ::hProvincias, "T" , "Tarragona" )
   hSet( ::hProvincias, "TE", "Teruel" )
   hSet( ::hProvincias, "TO", "Toledo" )
   hSet( ::hProvincias, "V" , "Valencia" )
   hSet( ::hProvincias, "VA", "Valladolid" )
   hSet( ::hProvincias, "BI", "Vizcaya" )
   hSet( ::hProvincias, "ZA", "Zamora" )
   hSet( ::hProvincias, "Z" , "Zaragoza" )
   hSet( ::hProvincias, "CE", "Ceuta" )
   hSet( ::hProvincias, "ML", "Melilla" )

   ::aProductos      := {} //::getProductosWp()

   ::nView           := D():CreateView()
   
RETURN ( Self )

//---------------------------------------------------------------------------// 

METHOD Resource() CLASS ImportLatress

   local oBmp
   
   if oWnd() != nil
      oWnd():CloseAll()
   end if

   DEFINE DIALOG ::oDlg RESOURCE "IMPWP" OF oWnd() TITLE "Conexión Web-Services con WordPress"

      REDEFINE BITMAP oBmp RESOURCE "WORDPRESS_48" TRANSPARENT ID 600 OF ::oDlg

      REDEFINE GET ::oDireccion VAR ::cDireccion ID 100 OF ::oDlg
      REDEFINE GET ::oUsuario VAR ::cUsuario ID 110 OF ::oDlg
      REDEFINE GET ::oClave VAR ::cClave ID 120 OF ::oDlg

      REDEFINE GET ::oArticulos VAR ::cArticulos ID 130 OF ::oDlg
      TBtnBmp():ReDefine( 131, "GC_IMPORT_16",,,,,{|| ::addArticulos() }, ::oDlg, .f., , .f.,  )

      REDEFINE GET ::oFamilias VAR ::cFamilias ID 140 OF ::oDlg
      TBtnBmp():ReDefine( 141, "GC_IMPORT_16",,,,,{|| ::addFamilias() }, ::oDlg, .f., , .f.,  )

      REDEFINE GET ::oPropiedades VAR ::cPropiedades ID 150 OF ::oDlg
      TBtnBmp():ReDefine( 151, "GC_IMPORT_16",,,,,{|| ::addPropiedades() }, ::oDlg, .f., , .f.,  )

      REDEFINE GET ::oClientes VAR ::cClientes ID 160 OF ::oDlg
      TBtnBmp():ReDefine( 161, "GC_IMPORT_16",,,,,{|| ::addClientes() }, ::oDlg, .f., , .f.,  )

      REDEFINE GET ::oPedidos VAR ::cPedidos ID 170 OF ::oDlg
      TBtnBmp():ReDefine( 171, "GC_IMPORT_16",,,,,{|| ::Prueba() }, ::oDlg, .f., , .f.,  )   //::addPedidos()

      REDEFINE SAY ::oSayProcess ID 700 OF ::oDlg

      REDEFINE BUTTON ID IDCANCEL   OF ::oDlg ACTION ( ::oDlg:end() )

   ACTIVATE DIALOG ::oDlg CENTER

   D():DeleteView( ::nView )

   oBmp:End()

   ::saveConfig()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Prueba()

   local oWebService 
   local hResult           := {}
   local hJson             := {=>}
   local cJson

   Msginfo( "entro a probar" )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cArticulos ) + "/7608" )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "GET" )
   Msginfo( oWebService:cUrl, "cUrl" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   Msginfo( oWebService:cUrl, "cUrl" )
   oWebService:Send()

   Msginfo( oWebService:getStatus(), "getStatus" )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
      Msginfo( "Conexión correcta: artículo creado" )
      MsgInfo( hResult, Valtype( hResult ) )
      MsgInfo( hb_valToExp( hResult ), "hResult" )
      logwrite( hb_valToExp( hResult ) )
   else
      Msginfo( "Fallo de comunicación." )
   end if

   oWebService:End()

   Msginfo( "Salgo de la prueba" )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Importar() CLASS ImportLatress

   local aJson
   local aPropiedades      := {}

   aPropiedades            := ArticulosPrecios():listWpCode()

   if Len( aPropiedades ) > 0
      aEval( aPropiedades, {|h| ::ActualizaStock( h ) } )
   end if

   ::setProcessText( "Proceso terminado con éxito" )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addFamilias() CLASS ImportLatress

   local aListFamilia := FamiliasModel():getListToWP()

   if Len( aListFamilia ) > 0
      aEval( aListFamilia, {|a| if( Empty( hGet( a, "CIDWP" ) ), ::addFamilia( a ), ::UpdateFamilia( a ) ) } )
   end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD addFamilia( aFamilia ) CLASS ImportLatress

   local oWebService 
   local hResult           := {}
   local hJson             := {=>}
   local cJson

   ::setProcessText( "Añadiendo familia " + AllTrim( hGet( aFamilia, "CNOMFAM" ) ) + " - " + AllTrim( hGet( aFamilia, "CCODFAM" ) ) )

   hSet( hJson, "name", AllTrim( hGet( aFamilia, "CNOMFAM" ) ) )
   hSet( hJson, "slug", AllTrim( hGet( aFamilia, "CCODFAM" ) ) )

   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( Alltrim( ::cFamilias ) )
   oWebService:setUrl( Alltrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", Alltrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", Alltrim( ::cClave ) )
   oWebService:setMethod( "POST" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
      ::setProcessText( "Conexión correcta: familia creada" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

   if hhaskey( hResult, "id" )
      FamiliasModel():updateWpId( AllTrim( Str( hGet( hResult, "id" ) ) ), AllTrim( hGet( aFamilia, "CCODFAM" ) ) )
   end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD updateFamilia( aFamilia ) CLASS ImportLatress

   local oWebService 
   local hResult           := {}
   local hJson             := {=>}
   local cJson

   ::setProcessText( "Actualizando familia " + AllTrim( hGet( aFamilia, "CNOMFAM" ) ) + " - " + AllTrim( hGet( aFamilia, "CCODFAM" ) ) )

   hSet( hJson, "id", AllTrim( hGet( aFamilia, "CIDWP" ) ) )
   hSet( hJson, "name", AllTrim( hGet( aFamilia, "CNOMFAM" ) ) )
   hSet( hJson, "slug", AllTrim( hGet( aFamilia, "CCODFAM" ) ) )

   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cFamilias ) + "/" + AllTrim( hGet( aFamilia, "CIDWP" ) ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "PUT" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
      ::setProcessText( "Conexión correcta: Familia actualizada" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD addPropiedades() CLASS ImportLatress

   local aListPropiedades := PropiedadesModel():getListToWP()

   if Len( aListPropiedades ) > 0
      aEval( aListPropiedades, {|a| if( Empty( hGet( a, "CIDWP" ) ), ::addPropiedad( a ), ::updatePropiedad( a ) ) } )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addPropiedad( aPropiedad ) CLASS ImportLatress

   local oWebService 
   local hResult                 := {}
   local hJson                   := {=>}
   local cJson
   local aListPropiedadesLines

   ::setProcessText( "Añadiendo propiedad " + AllTrim( hGet( aPropiedad, "CCODPRO" ) ) + " - " + AllTrim( hGet( aPropiedad, "CDESPRO" ) ) )

   hSet( hJson, "name", AllTrim( hGet( aPropiedad, "CDESPRO" ) ) )
   hSet( hJson, "slug", AllTrim( hGet( aPropiedad, "CCODPRO" ) ) )
   hSet( hJson, "type", "select" )
   hSet( hJson, "order_by", "name" )
   
   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cPropiedades ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "POST" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
      ::setProcessText( "Conexión correcta: propiedad creada" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

   if hb_ishash( hResult ) .and. hhaskey( hResult, "id" )
      PropiedadesModel():updateWpId( AllTrim( Str( hGet( hResult, "id" ) ) ), AllTrim( hGet( aPropiedad, "CCODPRO" ) ) )
   end if

   aListPropiedadesLines := PropiedadesLineasModel():getListToWP( hGet( aPropiedad, "CCODPRO" ) )

   if hb_ishash( hResult ) .and. hhaskey( hResult, "id" )
      if Len( aListPropiedadesLines ) > 0
         aEval( aListPropiedadesLines, {|a| if( Empty( hGet( a, "CIDWP" ) ), ::addPropiedadLine( a, hGet( hResult, "id" ) ), ::updatePropiedadLine( a, hGet( hResult, "id" ) ) ) } )
      end if
   end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD updatePropiedad( aPropiedad ) CLASS ImportLatress

   local oWebService 
   local hResult           := {}
   local hJson             := {=>}
   local cJson
   local aListPropiedadesLines

   ::setProcessText( "Actualizando propiedad " + AllTrim( hGet( aPropiedad, "CCODPRO" ) ) + " - " + AllTrim( hGet( aPropiedad, "CDESPRO" ) ) )

   hSet( hJson, "name", AllTrim( hGet( aPropiedad, "CDESPRO" ) ) )
   hSet( hJson, "slug", AllTrim( hGet( aPropiedad, "CCODPRO" ) ) )
   hSet( hJson, "type", "select" )
   hSet( hJson, "order_by", "name" )

   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cPropiedades )+ "/" + AllTrim( hGet( aPropiedad, "CIDWP" ) ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "PUT" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
      ::setProcessText( "Conexión correcta: propiedad actualizado" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

   aListPropiedadesLines := PropiedadesLineasModel():getListToWP( hGet( aPropiedad, "CCODPRO" ) )

   if Len( aListPropiedadesLines ) > 0
      aEval( aListPropiedadesLines, {|a| if( Empty( hGet( a, "CIDWP" ) ), ::addPropiedadLine( a, hGet( hResult, "id" ) ), ::updatePropiedadLine( a, hGet( hResult, "id" ) ) ) } )
   end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD addPropiedadLine( aPropiedadLine, cIdParent ) CLASS ImportLatress

   local oWebService 
   local hResult                 := {}
   local hJson                   := {=>}
   local cJson
   local aListPropiedadesLines

   ::setProcessText( "Añadiendo propiedad " + AllTrim( hGet( aPropiedadLine, "CCODTBL" ) ) + " - " + AllTrim( hGet( aPropiedadLine, "CDESTBL" ) ) )

   hSet( hJson, "name", AllTrim( hGet( aPropiedadLine, "CDESTBL" ) ) )
   hSet( hJson, "slug", AllTrim( hGet( aPropiedadLine, "CCODTBL" ) ) )
   
   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cPropiedades ) + "/" + Alltrim( Str( cIdParent ) ) + "/terms" )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "POST" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
      ::setProcessText( "Conexión correcta: propiedad creada" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

   if hhaskey( hResult, "id" )
      PropiedadesLineasModel():updateWpId( AllTrim( Str( hGet( hResult, "id" ) ) ), AllTrim( hGet( aPropiedadLine, "CCODPRO" ) ), AllTrim( hGet( aPropiedadLine, "CCODTBL" ) ) )
   end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD updatePropiedadLine( aPropiedadLine, cIdParent ) CLASS ImportLatress

   local oWebService 
   local hResult           := {}
   local hJson             := {=>}
   local cJson
   local aListPropiedadesLines

   ::setProcessText( "Actualizando propiedad " + AllTrim( hGet( aPropiedadLine, "CCODTBL" ) ) + " - " + AllTrim( hGet( aPropiedadLine, "CDESTBL" ) ) )

   hSet( hJson, "name", AllTrim( hGet( aPropiedadLine, "CDESTBL" ) ) )
   hSet( hJson, "slug", AllTrim( hGet( aPropiedadLine, "CCODTBL" ) ) )
   hSet( hJson, "type", "select" )
   hSet( hJson, "order_by", "name" )

   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cPropiedades ) + "/" + Alltrim( Str( cIdParent ) ) + "/terms/" + AllTrim( hGet( aPropiedadLine, "CIDWP" ) ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "PUT" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
      ::setProcessText( "Conexión correcta: propiedad actualizada" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD addVariations( aArticulo, hValue, cIdResult ) CLASS ImportLatress

   local oWebService 
   local hResult           := {}
   local hJson             := {=>}
   local cJson
   local cId
   local aAtributes        := {}

   if !Empty( hGet( aArticulo, "CCODPRP1" ) )
      aAdd( aAtributes, { "id" => val( AllTrim( PropiedadesModel():getField( 'cIdWP', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP1" ) ) ) ) ),;
                          "name"=> AllTrim( PropiedadesModel():getField( 'cDesPro', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP1" ) ) ) ),;
                          "option"=> PropiedadesLineasModel():getNombre( hGet( hValue, "CCODPR1" ), hGet( hValue, "CVALPR1" ) )  } )
   end if

   if !Empty( hGet( aArticulo, "CCODPRP2" ) )
      aAdd( aAtributes, { "id" => val( AllTrim( PropiedadesModel():getField( 'cIdWP', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP2" ) ) ) ) ),;
                          "name"=> AllTrim( PropiedadesModel():getField( 'cDesPro', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP2" ) ) ) ),;
                          "option" => PropiedadesLineasModel():getNombre( hGet( hValue, "CCODPR2" ), hGet( hValue, "CVALPR2" ) )  } )   
   end if

   hSet( hJson, "sku", AllTrim( hGet( aArticulo, "CODIGO" ) ) )
   hSet( hJson, "price", Trans( hGet( aArticulo, "NIMPINT1" ), "999999.99" ) )
   hSet( hJson, "regular_price", Trans( hGet( aArticulo, "NIMPINT1" ), "999999.99" ) )
   hSet( hJson, "status", "publish" )
   hSet( hJson, "manage_stock", .t. )
   hSet( hJson, "stock_quantity", 10 )
   hSet( hJson, "stock_status", "instock" )

   if !Empty( aAtributes )
      hSet( hJson, "attributes", aAtributes )
   end if

   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( Alltrim( ::cArticulos + "/" + cIdResult + "/variations" ) )
   oWebService:setUrl( Alltrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", Alltrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", Alltrim( ::cClave ) )
   oWebService:setMethod( "POST" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   ?oWebService:getStatus()

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
   end if

   oWebService:End()

   msginfo( hb_valToExp( hResult ), "hResult" )

   if hhaskey( hResult, "id" )
      FamiliasModel():updateWpId( AllTrim( Str( hGet( hResult, "id" ) ) ), AllTrim( hGet( aArticulo, "CODIGO" ) ), AllTrim( hGet( aArticulo, "CCODPRP1" ) ), AllTrim( hGet( aArticulo, "CCODPRP2" ) ), AllTrim( hGet( hValue, "CVALPR1" ) ), AllTrim( hGet( hValue, "CVALPR2" ) ) )
      cId   := AllTrim( Str( hGet( hResult, "id" ) ) )
   end if

RETURN ( cId )

//---------------------------------------------------------------------------//

METHOD addOneArticulo( hArticulo ) CLASS ImportLatress

   local nOrdAnt
   local hFamilia

   if Empty( hArticulo )
      RETURN ( Self )
   end if

   /*
   Revisamos que la categoría exista-------------------------------------------
   */

   nOrdAnt        := ( D():Familias( ::nView ) )->( OrdSetFocus( "cCodFam" ) )

   if ( D():Familias( ::nView ) )->( dbSeek( hget( hArticulo, "FAMILIA" ) ) )

      hFamilia    := dbHash( D():Familias( ::nView ) )

      if Empty( hGet( hFamilia, "CIDWP" ) )
         ::addFamilia( hFamilia )
      else
         ::updateFamilia( hFamilia )
      end if

   end if

   ( D():Familias( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

   /*
   Subimos el artículo---------------------------------------------------------
   */

   if Empty( hGet( hArticulo, "CIDWP" ) )
      ::addArticulo( hArticulo )
   else
      ::UpdateArticulo( hArticulo )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addArticulos() CLASS ImportLatress

   local aListArticulo := ArticulosModel():getListToWP()

   if Len( aListArticulo ) > 0
      aEval( aListArticulo, {|a| if( Empty( hGet( a, "CIDWP" ) ), ::addArticulo( a ), ::UpdateArticulo( a ) ) } )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addArticulo( aArticulo ) CLASS ImportLatress

   local oWebService 
   local hResult              := {}
   local hJson                := {=>}
   local cJson
   local nStock               := StocksModel():nStockArticulo( AllTrim( hGet( aArticulo, "CODIGO" ) ), Application():codigoAlmacen() )
   local aImages              := {}
   local hImage
   local aImagesWeb           := {}
   local aAtributes           := {}
   local hValuesCombinations  := {}
   local aListValuesPrp1      := {}
   local aListValuesPrp2      := {}
   local hValue
   local cNameValue           := ""
   local nIdVariation
   local aListIdVariation     := {}
   local nIdResult

   hValuesCombinations        := ArticulosPrecios():getHashProperties( AllTrim( hGet( aArticulo, "CODIGO" ) ) )

   if hHasKey( hValuesCombinations, "aValuesCombinations" )

      for each hValue in hGet( hValuesCombinations, "aValuesCombinations" )

         cNameValue           := PropiedadesLineasModel():getNombre( hGet( hValue, "CCODPR1" ), hGet( hValue, "CVALPR1" ) ) 

         if aScan( aListValuesPrp1, cNameValue ) == 0
            aAdd( aListValuesPrp1, cNameValue )
         end if

         cNameValue           := PropiedadesLineasModel():getNombre( hGet( hValue, "CCODPR2" ), hGet( hValue, "CVALPR2" ) ) 

         if aScan( aListValuesPrp2, cNameValue ) == 0
            aAdd( aListValuesPrp2, cNameValue )
         end if

      next

   end if

   if !Empty( hGet( aArticulo, "CCODPRP1" ) )
      aAdd( aAtributes, { "id" => val( AllTrim( PropiedadesModel():getField( 'cIdWP', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP1" ) ) ) ) ),;
                          "name"=> AllTrim( PropiedadesModel():getField( 'cDesPro', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP1" ) ) ) ),;
                          "position" => 0 ,;
                          "visible" => .T. ,;
                          "variation" => .T. ,;
                          "options"=> aListValuesPrp1 } )
   end if

   if !Empty( hGet( aArticulo, "CCODPRP2" ) )
      aAdd( aAtributes, { "id" => val( AllTrim( PropiedadesModel():getField( 'cIdWP', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP2" ) ) ) ) ),;
                          "name"=> AllTrim( PropiedadesModel():getField( 'cDesPro', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP2" ) ) ) ),;
                          "position" => 1 ,;
                          "visible" => .T. ,;
                          "variation"=> .T. ,;
                          "options" => aListValuesPrp2 } )   
   end if

   aImages        := ArticulosImagenesModel():getList( hGet( aArticulo, "CODIGO" ) )

   if Len( aImages ) > 0

      for each hImage in aImages

         ::addFtpImage( hGet( hImage, "CIMGART" ) )

         aAdd( aImagesWeb, { "src" => AllTrim( ::cWebImagen ) + cNoPath( hGet( hImage, "CIMGART" ) ) } )

      next

   end if

   ::setProcessText( "Añadiendo artículo " + AllTrim( hGet( aArticulo, "CODIGO" ) ) + " - " + AllTrim( hGet( aArticulo, "NOMBRE" ) ) )

   hSet( hJson, "name", AllTrim( hGet( aArticulo, "NOMBRE" ) ) )
   hSet( hJson, "slug", Strtran( lower( AllTrim( hGet( aArticulo, "NOMBRE" ) ) ), " ", "-" ) )
   hSet( hJson, "sku", AllTrim( hGet( aArticulo, "CODIGO" ) ) )
   hSet( hJson, "type", "variable" )
   hSet( hJson, "status", "publish" )
   hSet( hJson, "price", Trans( hGet( aArticulo, "NIMPINT1" ), "999999.99" ) )
   hSet( hJson, "regular_price", Trans( hGet( aArticulo, "NIMPINT1" ), "999999.99" ) )
   hSet( hJson, "sale_price", Trans( hGet( aArticulo, "NIMPINT1" ), "999999.99" ) )
   hSet( hJson, "description", AllTrim( hGet( aArticulo, "MDESTEC" ) ) )
   hSet( hJson, "short_description", AllTrim( hGet( aArticulo, "NOMBRE" ) ) )
   hSet( hJson, "manage_stock", "true" )
   hSet( hJson, "stock_quantity", AllTrim( Str( int( nStock ) ) ) )
   hSet( hJson, "stock_status", if( nStock > 0, "instock", "outofstock" )  )
   hSet( hJson, "categories", { { "id" => val( AllTrim( FamiliasModel():getField( 'cIdWP', 'cCodFam', AllTrim( hGet( aArticulo, "FAMILIA" ) ) ) ) ) } } )
   
   if !Empty( aImagesWeb )
      hSet( hJson, "images", aImagesWeb )
   end if

   if !Empty( aAtributes )
      hSet( hJson, "attributes", aAtributes )
   end if

   /*"attributes"=>{
      {"id"=>5, "name"=>"COLOR", "position"=>0, "visible"=>.T., "variation"=>.T., "options"=>{"Gris"}}, 
      {"id"=>3, "name"=>"Talla", "position"=>1, "visible"=>.T., "variation"=>.T., "options"=>{"S", "M", "L", "XL", "XXL"}}
   }, 
   "variations"=>{7671, 7672, 7673, 7674, 7670},*/
   
   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cArticulos ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "POST" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
      ::setProcessText( "Conexión correcta: artículo creado" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

   if isHash( hResult ) .and. !Empty( hResult ) .and. hhaskey( hResult, "id" )
      ArticulosModel():updateWpId( AllTrim( Str( hGet( hResult, "id" ) ) ), AllTrim( hGet( aArticulo, "CODIGO" ) ) )
      nIdResult      := AllTrim( Str( hGet( hResult, "id" ) ) )
   end if

   /*Preparamos la variaciones*/

   hJson       := {=>}
   cJson       := ""

   if hHasKey( hValuesCombinations, "aValuesCombinations" )

      for each hValue in hGet( hValuesCombinations, "aValuesCombinations" )

         if Empty( hGet( hValue, "CCODWP" ) )
            nIdVariation         := ::AddVariations( aArticulo, hValue, nIdResult )
         else 
            nIdVariation         := hGet( hValue, "CCODWP" )
         end if

         if aScan( aListIdVariation, nIdVariation ) == 0
            aAdd( aListIdVariation, nIdVariation )
         end if

      next

   end if
   
   MsgInfo( hb_valToexp( aListIdVariation ), "aListIdVariation" )

   hSet( hJson, "id", nIdResult )
   if !Empty( aListIdVariation )
      hSet( hJson, "variations", aListIdVariation )
   end if

   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cArticulos )+ "/" + nIdResult )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "PUT" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
      ::setProcessText( "Conexión correcta: artículo actualizado" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

   ::cleanFtp()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD updateArticulo( aArticulo ) CLASS ImportLatress

   local oWebService 
   local hResult              := {}
   local hJson                := {=>}
   local cJson
   local nStock               := StocksModel():nStockArticulo( AllTrim( hGet( aArticulo, "CODIGO" ) ), Application():codigoAlmacen() )
   local aImages              := {}
   local hImage
   local aImagesWeb           := {}
   local aAtributes           := {}
   local hValuesCombinations  := {}
   local aListValuesPrp1      := {}
   local aListValuesPrp2      := {}
   local hValue
   local cNameValue           := ""
   
   hValuesCombinations        := ArticulosPrecios():getHashProperties( AllTrim( hGet( aArticulo, "CODIGO" ) ) )

   if hHasKey( hValuesCombinations, "aValuesCombinations" )

      for each hValue in hGet( hValuesCombinations, "aValuesCombinations" )

         cNameValue           := PropiedadesLineasModel():getNombre( hGet( hValue, "CCODPR1" ), hGet( hValue, "CVALPR1" ) ) 

         if aScan( aListValuesPrp1, cNameValue ) == 0
            aAdd( aListValuesPrp1, cNameValue )
         end if

         cNameValue           := PropiedadesLineasModel():getNombre( hGet( hValue, "CCODPR2" ), hGet( hValue, "CVALPR2" ) ) 

         if aScan( aListValuesPrp2, cNameValue ) == 0
            aAdd( aListValuesPrp2, cNameValue )
         end if

      next

   end if

   if !Empty( hGet( aArticulo, "CCODPRP1" ) )
      aAdd( aAtributes, { "id" => val( AllTrim( PropiedadesModel():getField( 'cIdWP', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP1" ) ) ) ) ),;
                          "name"=> AllTrim( PropiedadesModel():getField( 'cDesPro', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP1" ) ) ) ),;
                          "position" => 0 ,;
                          "visible" => .T. ,;
                          "variation" => .T. ,;
                          "options"=> aListValuesPrp1 } )
   end if

   if !Empty( hGet( aArticulo, "CCODPRP2" ) )
      aAdd( aAtributes, { "id" => val( AllTrim( PropiedadesModel():getField( 'cIdWP', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP2" ) ) ) ) ),;
                          "name"=> AllTrim( PropiedadesModel():getField( 'cDesPro', 'cCodPro', AllTrim( hGet( aArticulo, "CCODPRP2" ) ) ) ),;
                          "position" => 1 ,;
                          "visible" => .T. ,;
                          "variation"=> .T. ,;
                          "options" => aListValuesPrp2 } )   
   end if

   aImages        := ArticulosImagenesModel():getList( hGet( aArticulo, "CODIGO" ) )

   if Len( aImages ) > 0

      for each hImage in aImages

         ::addFtpImage( hGet( hImage, "CIMGART" ) )

         aAdd( aImagesWeb, { "src" => AllTrim( ::cWebImagen ) + cNoPath( hGet( hImage, "CIMGART" ) ) } )

      next

   end if

   ::setProcessText( "Actualizando artículo " + AllTrim( hGet( aArticulo, "CODIGO" ) ) + " - " + AllTrim( hGet( aArticulo, "NOMBRE" ) ) )

   hSet( hJson, "name", AllTrim( hGet( aArticulo, "NOMBRE" ) ) )
   hSet( hJson, "slug", Strtran( lower( AllTrim( hGet( aArticulo, "NOMBRE" ) ) ), " ", "-" ) )
   hSet( hJson, "sku", AllTrim( hGet( aArticulo, "CODIGO" ) ) )
   hSet( hJson, "price", Trans( hGet( aArticulo, "NIMPINT1" ), "999999.99" ) )
   hSet( hJson, "regular_price", Trans( hGet( aArticulo, "NIMPINT1" ), "999999.99" ) )
   hSet( hJson, "sale_price", Trans( hGet( aArticulo, "NIMPINT1" ), "999999.99" ) )
   hSet( hJson, "description", AllTrim( hGet( aArticulo, "MDESTEC" ) ) )
   hSet( hJson, "short_description", AllTrim( hGet( aArticulo, "NOMBRE" ) ) )
   hSet( hJson, "manage_stock", "true" )
   hSet( hJson, "stock_quantity", AllTrim( Str( int( nStock ) ) ) )
   hSet( hJson, "stock_status", if( nStock > 0, "instock", "outofstock" )  )
   hSet( hJson, "categories", { { "id" => val( AllTrim( FamiliasModel():getField( 'cIdWP', 'cCodFam', AllTrim( hGet( aArticulo, "FAMILIA" ) ) ) ) ) } } )
   
   if !Empty( aImagesWeb )
      hSet( hJson, "images", aImagesWeb )
   end if

   if !Empty( aAtributes )
      hSet( hJson, "attributes", aAtributes )
   end if

   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cArticulos )+ "/" + AllTrim( hGet( aArticulo, "CIDWP" ) ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "PUT" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201
      hb_jsonDecode( oWebService:getResponseText(), @hResult )
      ::setProcessText( "Conexión correcta: artículo actualizado" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

   ::cleanFtp()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD addFtpImage( cFile ) CLASS ImportLatress

    local oFtp
    local ftpSit            := "ftp.cluster030.hosting.ovh.net"
    local ftpDir            := cNoPathLeft( Rtrim( ftpSit ) )
    local nbrUsr            := "gestooc"
    local accUsr            := "Xtend000"  
    local pasInt            := .f.
    local nPuerto           := 21
    local cCarpeta          := "www/imageneswp/"

    if !file( cFile )
        Return ( Self )
    end if

    oFtp               := TFtpCurl():New( nbrUsr, accUsr, ftpSit, nPuerto )
    oFtp:setPassive( pasInt )

    if oFtp:CreateConexion()

        ::setProcessText( "Conexión creada con el ftp." )

        if isFalse( oFtp:createFile( cFile, cCarpeta ) )
            ::setProcessText( "Error subiendo fichero " + cFile )
        else
            ::setProcessText( "Subido correctamente:  " + cFile )
        end if

        oFtp:EndConexion()

        ::setProcessText( "Conexión cerrada con el ftp." )

    else

        msgStop( "Imposible conectar al sitio ftp" )

    end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD cleanFtp() CLASS ImportLatress

   local oFtp
   local ftpSit            := "ftp.cluster030.hosting.ovh.net"
   local ftpDir            := cNoPathLeft( Rtrim( ftpSit ) )
   local nbrUsr            := "gestooc"
   local accUsr            := "Xtend000"  
   local pasInt            := .f.
   local nPuerto           := 21
   local cCarpeta          := "www/imageneswp/"
   local afiles

   oFtp               := TFTPCurl():New( nbrUsr, accUsr, ftpSit, nPuerto )
   oFtp:setPassive( pasInt )

   if oFtp:CreateConexion()

      ::setProcessText( "Conexión creada con el ftp." )

      aFiles         := ( oFTP:listFiles(), cCarpeta )

      oFtp:EndConexion()

      ::setProcessText( "Conexión cerrada con el ftp." )

   else

      msgStop( "Imposible conectar al sitio ftp" )

   end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD ActualizaStock( hPropiedades ) CLASS ImportLatress

   local oWebService 
   local aJson
   local hJson             := {=>}
   local cJson
   local cIdWP             := ::getidProductWp( hGet( hPropiedades, "CCODART" ) )
   local cCodWp            := AllTrim( hGet( hPropiedades, "CCODWP" ) )
   local nStock            := StocksModel():nStockArticulo( hGet( hPropiedades, "CCODART" ),;
                                                            Application():codigoAlmacen(),; 
                                                            hGet( hPropiedades, "CCODPR1" ),; 
                                                            hGet( hPropiedades, "CCODPR2" ),;
                                                            hGet( hPropiedades, "CVALPR1" ),;
                                                            hGet( hPropiedades, "CVALPR2" ) )

   hSet( hJson, "id", cCodWp )
   hSet( hJson, "manage_stock", "true" )
   hSet( hJson, "stock_quantity", AllTrim( Str( int( nStock ) ) ) )
   hSet( hJson, "stock_status", if( nStock > 0, "instock", "outofstock" )  )

   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cArticulos ) + "/" + cIdWP + "/variations/" + cCodWp )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "PUT" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      hb_jsonDecode( oWebService:getResponseText(), @aJson )

      ::setProcessText( "Conexión correcta: actualizado artículo y variantes" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getProductosWp() CLASS ImportLatress

   local oWebService 
   local aJson

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cArticulos ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "GET" )
   oWebService:Open()
   oWebService:Send()

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      hb_jsonDecode( oWebService:getResponseText(), @aJson )

      ::setProcessText( "Conexión correcta" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if
 
   oWebService:End()

RETURN ( aJson )

//---------------------------------------------------------------------------//

METHOD getidProductWp( cCodArt ) CLASS ImportLatress

   local cIdProduct     := ""
   local hProduct
   local nPos

   nPos                 := aScan( ::aProductos, {|h| AllTrim( hGet( h, "sku" ) ) == AllTrim( cCodArt ) } )
   if nPos != 0
      hProduct          := ::aProductos[nPos]
      cIdProduct        := AllTrim( Str( hGet( hProduct, "id" ) ) )
   end if

RETURN ( cIdProduct )

//---------------------------------------------------------------------------//

METHOD addClientes() CLASS ImportLatress

   local oWebService 
   local aJson
   local aClientes

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cClientes ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "GET" )
   oWebService:Open()
   oWebService:Send()

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      hb_jsonDecode( oWebService:getResponseText(), @aClientes )

      ::setProcessText( "Conexión correcta" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if
 
   oWebService:End()

   if hb_isarray( aClientes ) .and. len( aClientes ) > 0
      aeval( aClientes, {|h| ::addCliente( h ) } )
   end if

   ::setProcessText( "Proceso terminado con éxito." )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD addCliente( hCliente ) CLASS ImportLatress

   local hDirFac
   local hDirEnv
   local cCodCli  := NextKey( cCodCli, ( D():Clientes( ::nView ) ), "0", RetNumCodCliEmp() )

   if ClientesModel():existInWP( AllTrim( Str( hGet( hCliente, "id" ) ) ) )
      ::setProcessText( "Cliente " + AllTrim( hGet( hCliente, "first_name" ) ) + Space( 1 ) + AllTrim( hGet( hCliente, "last_name" ) ) + " ya existe en el sistema." )
      Return ( self )
   end if

   ::setProcessText( "Añadiendo cliente:  " + AllTrim( hGet( hCliente, "first_name" ) ) + Space( 1 ) + AllTrim( hGet( hCliente, "last_name" ) ) )

   ( D():Clientes( ::nView ) )->( dbAppend() )

   ( D():Clientes( ::nView ) )->cIdWP        := AllTrim( Str( hGet( hCliente, "id" ) ) )
   ( D():Clientes( ::nView ) )->Cod          := cCodCli
   ( D():Clientes( ::nView ) )->Titulo       := AllTrim( hGet( hCliente, "first_name" ) ) + Space( 1 ) + AllTrim( hGet( hCliente, "last_name" ) )
   ( D():Clientes( ::nView ) )->LSNDINT      := .t.
   ( D():Clientes( ::nView ) )->LMODDAT      := .t.
   ( D():Clientes( ::nView ) )->LCHGPRE      := .f.
   ( D():Clientes( ::nView ) )->COPIASF      := 0
   ( D():Clientes( ::nView ) )->NLABEL       := 1
   ( D():Clientes( ::nView ) )->NTARCMB      := 1
   ( D():Clientes( ::nView ) )->DLLACLI      := ctod( "" )
   ( D():Clientes( ::nView ) )->DALTA        := getSysDate()
   ( D():Clientes( ::nView ) )->cMeiInt      := AllTrim( hGet( hCliente, "email" ) )
   ( D():Clientes( ::nView ) )->NbrEst       := AllTrim( hGet( hCliente, "username" ) )

   hDirFac                                   := hGet( hCliente, "billing" )
   ( D():Clientes( ::nView ) )->Domicilio    := AllTrim( hGet( hDirFac, "address_1" ) ) + Space( 1 ) + AllTrim( hGet( hDirFac, "address_2" ) )
   ( D():Clientes( ::nView ) )->Poblacion    := AllTrim( hGet( hDirFac, "city" ) )
   ( D():Clientes( ::nView ) )->Provincia    := ::GetProv( AllTrim( hGet( hDirFac, "state" ) ) )
   ( D():Clientes( ::nView ) )->CodPostal    := AllTrim( hGet( hDirFac, "postcode" ) )
   ( D():Clientes( ::nView ) )->Telefono     := AllTrim( hGet( hDirFac, "phone" ) )

   hDirEnv                                   := hGet( hCliente, "shipping" )
   ( D():Clientes( ::nView ) )->cDomEnt      := AllTrim( hGet( hDirEnv, "address_1" ) ) + Space( 1 ) + AllTrim( hGet( hDirEnv, "address_2" ) )
   ( D():Clientes( ::nView ) )->cPobEnt      := AllTrim( hGet( hDirEnv, "city" ) )
   ( D():Clientes( ::nView ) )->cCPEnt       := AllTrim( hGet( hDirEnv, "postcode" ) )
   ( D():Clientes( ::nView ) )->cPrvEnt      := ::GetProv( AllTrim( hGet( hDirEnv, "state" ) ) )

   ( D():Clientes( ::nView ) )->( dbUnLock() )

   ::setProcessText( "Proceso terminado con éxito." )

RETURN ( self )

//---------------------------------------------------------------------------//
   
METHOD addPedidos() CLASS ImportLatress

   local oWebService 
   local aPedidos

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cPedidos ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "GET" )
   oWebService:Open()
   oWebService:Send()

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      hb_jsonDecode( oWebService:getResponseText(), @aPedidos )

      ::setProcessText( "Conexión correcta" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if
 
   oWebService:End()

   if hb_isarray( aPedidos ) .and. len( aPedidos ) > 0
      aeval( aPedidos, {|h| ::addPedido( h ) } )
   end if

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD addPedido( hPedido ) CLASS ImportLatress

   local hDirFac
   local aLineas

   if PedidosClientesModel():existInWP( AllTrim( Str( hGet( hPedido, "id" ) ) ) )
      ::setProcessText( "Pedido con " + AllTrim( Str( hGet( hPedido, "id" ) ) ) + " ya existe en el sistema." )
      Return ( self )
   end if

   ::setProcessText( "Añadiendo pedido de cliente:  " + AllTrim( Str( hGet( hPedido, "id" ) ) ) )

   ::cSerie         := cNewSer( "nPedCli", D():Contadores( ::nView ) )
   ::nNumero        := nNewDoc( ::cSerie, D():PedidosClientes( ::nView ), "NPEDCLI", , D():Contadores( ::nView ) )
   ::cSufijo        := RetSufEmp()

   ::dFecPed         := ctod( SubStr( hGet( hPedido, "date_created" ), 9, 2 ) + "/" + SubStr( hGet( hPedido, "date_created" ), 6, 2 ) + "/" + SubStr( hGet( hPedido, "date_created" ), 1, 4 ) )

   ( D():PedidosClientes( ::nView ) )->( dbAppend() )

   ( D():PedidosClientes( ::nView ) )->cIdWP          := AllTrim( Str( hGet( hPedido, "id" ) ) )
   ( D():PedidosClientes( ::nView ) )->cSerPed        := ::cSerie
   ( D():PedidosClientes( ::nView ) )->nNumPed        := ::nNumero
   ( D():PedidosClientes( ::nView ) )->cSufPed        := ::cSufijo
   ( D():PedidosClientes( ::nView ) )->cTurPed        := cCurSesion()
   ( D():PedidosClientes( ::nView ) )->cCodAlm        := Application():codigoAlmacen()
   ( D():PedidosClientes( ::nView ) )->cCodCaj        := Application():CodigoCaja()
   ( D():PedidosClientes( ::nView ) )->cDivPed        := cDivEmp()
   ( D():PedidosClientes( ::nView ) )->cCodPgo        := cDefFpg()
   ( D():PedidosClientes( ::nView ) )->nVdvPed        := nChgDiv( cDivEmp(), D():Divisas( ::nView ) )
   ( D():PedidosClientes( ::nView ) )->nEstAdo        := 1
   ( D():PedidosClientes( ::nView ) )->cCodUsr        := Auth():Codigo()
   ( D():PedidosClientes( ::nView ) )->cCodDlg        := Application():CodigoDelegacion()
   ( D():PedidosClientes( ::nView ) )->lIvaInc        := uFieldEmpresa( "lIvaInc" )
   ( D():PedidosClientes( ::nView ) )->cManObr        := padr( getConfigTraslation( "Gastos" ), 250 )
   ( D():PedidosClientes( ::nView ) )->nIvaMan        := nIva( D():TiposIva( ::nView ), cDefIva() )
   ( D():PedidosClientes( ::nView ) )->dFecPed        := ::dFecPed
   
   ( D():PedidosClientes( ::nView ) )->cSuPed         := AllTrim( hGet( hPedido, "order_key" ) )

   if AllTrim( Str( hGet( hPedido, "customer_id" ) ) ) != "0"

      ::cCodCli  := ClientesModel():getField( "Cod", "cIdWP", AllTrim( Str( hGet( hPedido, "customer_id" ) ) ) )
      ( D():PedidosClientes( ::nView ) )->cCodCli     := ::cCodCli
      ( D():PedidosClientes( ::nView ) )->cNomCli     := ClientesModel():getField( "Titulo", "Cod", ::cCodCli )
      ( D():PedidosClientes( ::nView ) )->cDirCli     := ClientesModel():getField( "Domicilio", "Cod", ::cCodCli )
      ( D():PedidosClientes( ::nView ) )->cPobCli     := ClientesModel():getField( "Poblacion", "Cod", ::cCodCli )
      ( D():PedidosClientes( ::nView ) )->cPrvCli     := ClientesModel():getField( "Provincia", "Cod", ::cCodCli )
      ( D():PedidosClientes( ::nView ) )->cPosCli     := ClientesModel():getField( "CodPostal", "Cod", ::cCodCli )
      ( D():PedidosClientes( ::nView ) )->cDniCli     := ClientesModel():getField( "Nif", "Cod", ::cCodCli )
      ( D():PedidosClientes( ::nView ) )->cTlfCli     := ClientesModel():getField( "Telefono", "Cod", ::cCodCli )

   else

      hDirFac                                         := hGet( hPedido, "billing" )

      ::cCodCli                                       := ::addClienteNotReg( hDirFac )

      ( D():PedidosClientes( ::nView ) )->cCodCli     := ::cCodCli
      ( D():PedidosClientes( ::nView ) )->cNomCli     := AllTrim( hGet( hDirFac, "first_name" ) ) + Space( 1 ) + AllTrim( hGet( hDirFac, "last_name" ) )
      ( D():PedidosClientes( ::nView ) )->cDirCli     := AllTrim( hGet( hDirFac, "address_1" ) ) + Space( 1 ) + AllTrim( hGet( hDirFac, "address_2" ) )
      ( D():PedidosClientes( ::nView ) )->cPobCli     := AllTrim( hGet( hDirFac, "city" ) )
      ( D():PedidosClientes( ::nView ) )->cPrvCli     := ::GetProv( AllTrim( hGet( hDirFac, "state" ) ) )
      ( D():PedidosClientes( ::nView ) )->cPosCli     := AllTrim( hGet( hDirFac, "postcode" ) )
      ( D():PedidosClientes( ::nView ) )->cTlfCli     := AllTrim( hGet( hDirFac, "phone" ) )

   end if
   
   ( D():PedidosClientes( ::nView ) )->nTotNet        := Val( hGet( hPedido, "total" ) ) - Val( hGet( hPedido, "total_tax" ) )
   ( D():PedidosClientes( ::nView ) )->nTotIva        := Val( hGet( hPedido, "total_tax" ) )
   ( D():PedidosClientes( ::nView ) )->nTotPed        := Val( hGet( hPedido, "total" ) )

   ( D():PedidosClientes( ::nView ) )->( dbUnLock() )

   /*
   Añadimos lineas de pedidos de clientes--------------------------------------
   */
   aLineas                                            := hGet( hPedido, "line_items" )

   if hb_isarray( aLineas ) .and. len( aLineas ) > 0
      aeval( aLineas, {|h| ::addLineaPedido( h ) } )
   end if

   ::setProcessText( "Proceso terminado con éxito." )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD addLineaPedido( hLinea ) CLASS ImportLatress

   ::setProcessText( "Añadiendo lineas pedido de cliente." )

   ( D():PedidosClientesLineas( ::nView ) )->( dbAppend() )

   ( D():PedidosClientesLineas( ::nView ) )->cSerPed        := ::cSerie
   ( D():PedidosClientesLineas( ::nView ) )->nNumPed        := ::nNumero
   ( D():PedidosClientesLineas( ::nView ) )->cSufPed        := ::cSufijo

   ( D():PedidosClientesLineas( ::nView ) )->cRef           := ArticulosModel():getField( 'Codigo', 'cIdWP', AllTrim( Str( hGet( hLinea, "product_id" ) ) ) )
   ( D():PedidosClientesLineas( ::nView ) )->cDetalle       := AllTrim( hGet( hLinea, "name" ) )
   //( D():PedidosClientesLineas( ::nView ) )->cCodPr1        :=
   //( D():PedidosClientesLineas( ::nView ) )->cCodPr2        :=
   //( D():PedidosClientesLineas( ::nView ) )->cValPr1        :=
   //( D():PedidosClientesLineas( ::nView ) )->cValPr2        :=
   ( D():PedidosClientesLineas( ::nView ) )->nIva           := nIva( D():TiposIva( ::nView ), ArticulosModel():getField( 'TipoIva', 'cIdWP', AllTrim( Str( hGet( hLinea, "product_id" ) ) ) ) )
   ( D():PedidosClientesLineas( ::nView ) )->nUniCaja       := hGet( hLinea, "quantity" )
   ( D():PedidosClientesLineas( ::nView ) )->nPreDiv        := hGet( hLinea, "price" )
   ( D():PedidosClientesLineas( ::nView ) )->cAlmLin        := Application():codigoAlmacen()

   ( D():PedidosClientesLineas( ::nView ) )->( dbUnLock() )

RETURN ( self )

//----------------------------------------------------------------//

METHOD addClienteNotReg( hCliente ) CLASS ImportLatress

   local cCodCli  := NextKey( cCodCli, ( D():Clientes( ::nView ) ), "0", RetNumCodCliEmp() )

   ::setProcessText( "Añadiendo cliente:  " + AllTrim( hGet( hCliente, "first_name" ) ) + Space( 1 ) + AllTrim( hGet( hCliente, "last_name" ) ) )

   ( D():Clientes( ::nView ) )->( dbAppend() )

   ( D():Clientes( ::nView ) )->cIdWP        := "0"
   ( D():Clientes( ::nView ) )->Cod          := cCodCli
   ( D():Clientes( ::nView ) )->Titulo       := AllTrim( hGet( hCliente, "first_name" ) ) + Space( 1 ) + AllTrim( hGet( hCliente, "last_name" ) )
   ( D():Clientes( ::nView ) )->LSNDINT      := .t.
   ( D():Clientes( ::nView ) )->LMODDAT      := .t.
   ( D():Clientes( ::nView ) )->LCHGPRE      := .f.
   ( D():Clientes( ::nView ) )->COPIASF      := 0
   ( D():Clientes( ::nView ) )->NLABEL       := 1
   ( D():Clientes( ::nView ) )->NTARCMB      := 1
   ( D():Clientes( ::nView ) )->DLLACLI      := ctod( "" )
   ( D():Clientes( ::nView ) )->DALTA        := getSysDate()
   ( D():Clientes( ::nView ) )->cMeiInt      := AllTrim( hGet( hCliente, "email" ) )
   ( D():Clientes( ::nView ) )->Domicilio    := AllTrim( hGet( hCliente, "address_1" ) ) + Space( 1 ) + AllTrim( hGet( hCliente, "address_2" ) )
   ( D():Clientes( ::nView ) )->Poblacion    := AllTrim( hGet( hCliente, "city" ) )
   ( D():Clientes( ::nView ) )->Provincia    := ::GetProv( AllTrim( hGet( hCliente, "state" ) ) )
   ( D():Clientes( ::nView ) )->CodPostal    := AllTrim( hGet( hCliente, "postcode" ) )
   ( D():Clientes( ::nView ) )->Telefono     := AllTrim( hGet( hCliente, "phone" ) )

   ( D():Clientes( ::nView ) )->( dbUnLock() )

   ::setProcessText( "Proceso terminado con éxito." )

RETURN ( cCodCli )

//---------------------------------------------------------------------------//

METHOD GetProv( cProv ) CLASS ImportLatress

   local cDevuelve   := Space( 10 )

   if hHasKey( ::hProvincias, cProv )
      cDevuelve   := ::hProvincias[ cProv ]
   end if

Return cDevuelve

//---------------------------------------------------------------------------//

METHOD desactivateArticulo( cId ) CLASS ImportLatress

   local oWebService 
   local aJson
   local hJson             := {=>}
   local cJson
   
   hSet( hJson, "id", val( cId ) )
   hSet( hJson, "status", "draft" )
   hSet( hJson, "catalog_visibility", "hidden" )

   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cArticulos ) + "/" + AllTrim( cId ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "PUT" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      hb_jsonDecode( oWebService:getResponseText(), @aJson )

      ::setProcessText( "Conexión correcta: actualizado artículo y variantes" )

   else

      ::setProcessText( "Fallo de comunicación." )

   end if

   oWebService:End()

   MsgInfo( "Artículo desactivado en woocommerce" )

Return ( self )

//---------------------------------------------------------------------------//

METHOD activateArticulo( cId ) CLASS ImportLatress

   local oWebService 
   local aJson
   local hJson             := {=>}
   local cJson
   
   hSet( hJson, "id", val( cId ) )
   hSet( hJson, "status", "publish" )
   hSet( hJson, "catalog_visibility", "visible" )

   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cArticulos ) + "/" + AllTrim( cId ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "PUT" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      hb_jsonDecode( oWebService:getResponseText(), @aJson )

      ::setProcessText( "Conexión correcta: actualizado artículo y variantes" )

   else

      ::setProcessText( "Fallo de comunicación." )

   end if

   oWebService:End()

   MsgInfo( "Artículo activado en woocommerce" )

Return ( self )

//---------------------------------------------------------------------------//

METHOD getArticulo( cId ) CLASS ImportLatress

   local oWebService 
   local aArt

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cArticulos ) + "/" + AllTrim( cId ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "GET" )
   oWebService:Open()
   oWebService:Send()

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      hb_jsonDecode( oWebService:getResponseText(), @aArt )

      ::setProcessText( "Conexión correcta" )
   else
      ::setProcessText( "Fallo de comunicación." )
   end if
 
   oWebService:End()

Return ( self )

//---------------------------------------------------------------------------//

METHOD ActStockArticulo( cCodArt, cId ) CLASS ImportLatress

   local oWebService 
   local aJson
   local hJson             := {=>}
   local cJson
   local nStock            := StocksModel():nStockArticulo( cCodArt, Application():codigoAlmacen() )

   hSet( hJson, "id", val( cId ) )
   hSet( hJson, "manage_stock", "true" )
   hSet( hJson, "stock_quantity", AllTrim( Str( int( nStock ) ) ) )
   hSet( hJson, "stock_status", if( nStock > 0, "instock", "outofstock" )  )
   
   cJson          := hb_jsonencode( hJson, .t. )

   oWebService    := WebService():New()
   oWebService:setService( AllTrim( ::cArticulos ) + "/" + AllTrim( cId ) )
   oWebService:setUrl( AllTrim( ::cDireccion ) )
   oWebService:setParams( "consumer_key", AllTrim( ::cUsuario ) )
   oWebService:setParams( "consumer_secret", AllTrim( ::cClave ) )
   oWebService:setMethod( "PUT" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/json" )
   oWebService:Send( cJson )

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      hb_jsonDecode( oWebService:getResponseText(), @aJson )

      ::setProcessText( "Conexión correcta: actualizado artículo y variantes" )

   else

      ::setProcessText( "Fallo de comunicación." )

   end if

   oWebService:End()

   MsgInfo( "Artículo actualizado en woocommerce" )

Return ( self )

//---------------------------------------------------------------------------//

METHOD saveConfig() CLASS ImportLatress

   ConfiguracionesEmpresaModel():setValue( 'direccionWP', AllTrim( ::cDireccion ) )
   ConfiguracionesEmpresaModel():setValue( 'usuarioWP', AllTrim( ::cUsuario ) )
   ConfiguracionesEmpresaModel():setValue( 'claveWP', AllTrim( ::cClave ) )
   ConfiguracionesEmpresaModel():setValue( 'articulosWP', AllTrim( ::cArticulos ) )
   ConfiguracionesEmpresaModel():setValue( 'familiasWP', AllTrim( ::cFamilias ) )
   ConfiguracionesEmpresaModel():setValue( 'propiedadesWP', AllTrim( ::cPropiedades ) )
   ConfiguracionesEmpresaModel():setValue( 'clientesWP', AllTrim( ::cClientes ) )
   ConfiguracionesEmpresaModel():setValue( 'pedidosWP', AllTrim( ::cPedidos ) )
   ConfiguracionesEmpresaModel():setValue( 'imagenesWP', AllTrim( ::cWebImagen ) )

Return ( self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//