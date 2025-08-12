#include "FiveWin.Ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

FUNCTION ImpGamma( oMenuItem, oWnd )

   local oImpGamma
   local nLevel   := Auth():Level( oMenuItem )
   if nAnd( nLevel, 1 ) == 0
      msgStop( "Acceso no permitido." )
      return ( nil )
   end if

   oImpGamma       := ImportGamma():New():Resource()

RETURN nil

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ImportGamma

   DATA oDlg

   DATA oDireccion
   DATA oUsuario
   DATA oClave

   DATA cDireccion
   DATA cUsuario
   DATA cClave

   DATA cToken

   DATA oArticulos
   DATA cArticulos

   DATA oTarifas
   DATA cTarifas

   DATA oStock
   DATA cStock

   DATA oBmpCategoria
   DATA oCategoria
   DATA cCategoria

   DATA oAlbaranes
   DATA cAlbaranes

   DATA oFacturas
   DATA cFacturas

   DATA oSayProcess

   METHOD New()

   METHOD Resource()

   METHOD getToken()

   METHOD ImportaArticulos()
      METHOD IntegraArticulo( hArticulo )
      METHOD addArticulo( hArticulo )
      METHOD editArticulo( hArticulo )
   METHOD ImportaTarifas()
      METHOD IntegraTarifa( hTarifa )
      METHOD addTarifa( hTarifa )
      METHOD editTarifa( hTarifa )
   METHOD ImportaAlbaranes()
   METHOD ImportaFacturas()

   METHOD getStockProduct( cCodArt )

   METHOD setProcessText( cText )               INLINE ( if( !Empty( ::oSayProcess ), ( ::oSayProcess:SetText( cText ), ::oSayProcess:Refresh(), sysrefresh() ), ) )

END CLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS ImportGamma

   ::cDireccion      := "http://ws.gammaasociados.com/v1/" //Space( 200 )
   ::cUsuario        := "1460webserviceG" //Space( 200 )
   ::cClave          := "QPN0Y24e8KU8Dl1bKsJf" //Space( 200 )
   ::cToken          := Space( 200 )

   ::cArticulos      := "asociado/productos"
   ::cTarifas        := "asociado/tarifas"
   ::cAlbaranes      := "asociado/albaranes"
   ::cFacturas       := "asociado/facturas"
   ::cStock          := "asociado/stock"
   ::cCategoria      := Space( 10 )
   
RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Resource() CLASS ImportGamma

   local oBmp
   
   if oWnd() != nil
      oWnd():CloseAll()
   end if

   DEFINE DIALOG ::oDlg RESOURCE "IMPGAMMA" OF oWnd() TITLE "Integración de datos desde Gamma"

      REDEFINE BITMAP oBmp RESOURCE "gamma_48" TRANSPARENT ID 600 OF ::oDlg

      REDEFINE GET ::oDireccion VAR ::cDireccion ID 100 OF ::oDlg
      REDEFINE GET ::oUsuario VAR ::cUsuario ID 110 OF ::oDlg
      REDEFINE GET ::oClave VAR ::cClave ID 120 OF ::oDlg

      REDEFINE GET ::oArticulos VAR ::cArticulos ID 130 OF ::oDlg
      TBtnBmp():ReDefine( 131, "GC_IMPORT_16",,,,,{|| ::ImportaArticulos() }, ::oDlg, .f., , .f.,  )

      REDEFINE GET ::oTarifas VAR ::cTarifas ID 140 OF ::oDlg
      TBtnBmp():ReDefine( 141, "GC_IMPORT_16",,,,,{|| ::ImportaTarifas() }, ::oDlg, .f., , .f.,  )

      REDEFINE GET ::oAlbaranes VAR ::cAlbaranes ID 150 OF ::oDlg
      TBtnBmp():ReDefine( 151, "GC_IMPORT_16",,,,,{|| ::ImportaAlbaranes }, ::oDlg, .f., , .f.,  )

      REDEFINE GET ::oFacturas VAR ::cFacturas ID 160 OF ::oDlg
      TBtnBmp():ReDefine( 161, "GC_IMPORT_16",,,,,{|| ::ImportaFacturas() }, ::oDlg, .f., , .f.,  )

      REDEFINE GET ::oStock VAR ::cStock ID 170 OF ::oDlg

      REDEFINE GET ::oCategoria VAR ::cCategoria ;
         ID       230 ;
         IDTEXT   231 ;
         BITMAP   "LUPA" ;
         OF       ::oDlg

         ::oCategoria:bHelp := {|| BrwCategoria( ::oCategoria, ::oCategoria:oHelpText, ::oBmpCategoria ) }
         ::oCategoria:bValid := {|| cCategoria( ::oCategoria, ::oCategoria:oHelpText, ::oBmpCategoria ) }

      REDEFINE BITMAP ::oBmpCategoria ;
         ID       232 ;
         TRANSPARENT ;
         OF       ::oDlg
      
      REDEFINE SAY ::oSayProcess ID 700 OF ::oDlg

      REDEFINE BUTTON ID IDCANCEL   OF ::oDlg ACTION ( ::oDlg:end() )

      //::oDlg:AddFastKey( VK_F5, {|| ::Importar() } )

   ACTIVATE DIALOG ::oDlg CENTER

   oBmp:End()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getToken() CLASS ImportGamma

   local oXml
   local cXml  
   local oXmlId
   local oXmlIdData
   local oWebService 
   local hJson

   ::setProcessText( "Pido el token para hacer la consulta" )
   
   cXml  := "user=" + ::cUsuario + "&password=" + ::cClave

   oWebService    := WebService():New()
   oWebService:setService( "asociado/login" )
   oWebService:setUrl( ::cDireccion )
   oWebService:setParams( "user", ::cUsuario )
   oWebService:setParams( "password", ::cClave )
   oWebService:setMethod( "POST" )
   oWebService:Open()
   oWebService:SetRequestHeader( "Content-Type", "application/x-www-form-urlencoded" )
   oWebService:SetRequestHeader( "Content-Length", len( cXml ) )
   
   oWebService:Send( cXml ) 

   hb_jsonDecode( oWebService:getResponseText(), @hJson )

   ::cToken    := hGet( hJson, "token" )

   ::setProcessText( "Token: " + ::cToken )

   oWebService:End()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getStockProduct( cCodArt ) CLASS ImportGamma

   local oWebService 
   local hJson
   local hStock
   local hArticulo
   local nStock   := 0

   if Empty( cCodArt )
      return ( Self )
   end if

   ::getToken()

   oWebService    := WebService():New()
   oWebService:setService( ::cStock + "/" + AllTrim( cCodArt ) )     //Hay que ver el tema de la tabla
   oWebService:setUrl( ::cDireccion )
   oWebService:setParams( "token", ::cToken )
   oWebService:setMethod( "GET" )
   oWebService:Open()
   oWebService:Send() 

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      hb_jsonDecode( oWebService:getResponseText(), @hJson )

      hStock      := hGet( hJson, "data" )
      hArticulo   := hGet( hStock, AllTrim( cCodArt ) )

   else
      ::setProcessText( "Fallo de comunicación." )
   end if

   oWebService:End()

   MsgInfo( hGet( hArticulo, "Qty" ) )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ImportaArticulos() CLASS ImportGamma

   local oWebService 
   local hJson
   local aArticulos

   if Empty( ::cCategoria )
      MsgInfo( "Tiene que seleccionar una categoría para importar artículos." )
      ::oCategoria:SetFocus()
      return ( self )
   end if

   ::getToken()

   ::setProcessText( "Consultando de tabla de artículos." )

   oWebService    := WebService():New()
   oWebService:setService( ::cArticulos )
   oWebService:setUrl( ::cDireccion )
   oWebService:setParams( "token", ::cToken )
   oWebService:setMethod( "GET" )
   oWebService:Open()
   oWebService:Send() 

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      ::setProcessText( "Conexión realizada con éxito." )

      hb_jsonDecode( oWebService:getResponseText(), @hJson )

      aArticulos  := hGet( hJson, "data" )

   else

      ::setProcessText( "Fallo de comunicación." )

   end if

   oWebService:End()

   ::setProcessText(  "Conexión cerrada." )

   if Len( aArticulos ) > 0
      aEval( aArticulos, {| hArticulo | ::IntegraArticulo( hArticulo ) } )
   end if

   ::setProcessText(  "Importación de artículos finalizada con éxito." )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD IntegraArticulo( hArticulo ) CLASS ImportGamma

   if ArticulosModel():exist( hGet( hArticulo, "COD_ARTICULO" ) )
      ::editArticulo( hArticulo )
   else
      ::addArticulo( hArticulo )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD editArticulo( hArticulo ) CLASS ImportGamma
   
   local cArea := "EditArticuloGamma"
   local cSql

   ::oSayProcess:SetText( "Modificando artículo: " + hGet( hArticulo, "DESCRIPCION_ERP" ) )

   cSql        := "UPDATE " + ArticulosModel():getTableName() + Space( 1 )
   cSql        += "SET Nombre=" + quoted( StrTran( upper( hGet( hArticulo, "DESCRIPCION_ERP" ) ), "'", "" ) ) + ","
   cSql        += "nPesoKg=" + AllTrim( Str( hGet( hArticulo, "PESO" ) ) ) + ","
   cSql        += "lObs=.t., "
   cSql        += "cCodCate=" + quoted( ::cCategoria ) + Space( 1 )
   cSql        += "WHERE Codigo = " + quoted( hGet( hArticulo, "COD_ARTICULO" ) )

   ArticulosModel():ExecuteSqlStatement( cSql, @cArea )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addArticulo( hArticulo ) CLASS ImportGamma
   
   local cArea := "AddArticuloGamma"
   local cSql

   ::oSayProcess:SetText( "Añadiendo artículo: " + hGet( hArticulo, "DESCRIPCION_ERP" ) )

   cSql        := "INSERT INTO " + ArticulosModel():getTableName() 
   cSql        += " ( Codigo, Nombre, TipoIva, nPesoKg, lObs, cCodCate ) VALUES "
   cSql        += " ( " + quoted( hGet( hArticulo, "COD_ARTICULO" ) )
   cSql        += ", " + quoted( strTran( upper( hGet( hArticulo, "DESCRIPCION_ERP" ) ), "'", "" ) )
   cSql        += ", 'G', " + AllTrim( Str( hGet( hArticulo, "PESO" ) ) ) + ", .t., " + quoted( ::cCategoria ) + " )"

   ArticulosModel():ExecuteSqlStatement( cSql, @cArea )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ImportaTarifas() CLASS ImportGamma

   local oWebService 
   local hJson
   local aTarifas

   ::getToken()

   ::setProcessText( "Consultando de tabla de tarifas." )

   oWebService    := WebService():New()
   oWebService:setService( ::cTarifas )
   oWebService:setUrl( ::cDireccion )
   oWebService:setParams( "token", ::cToken )
   oWebService:setMethod( "GET" )
   oWebService:Open()
   oWebService:Send() 

   if oWebService:getStatus() == 200 .or. oWebService:getStatus() == 201

      ::setProcessText( "Conexión realizada con éxito." )

      hb_jsonDecode( oWebService:getResponseText(), @hJson )

      aTarifas  := hGet( hJson, "data" )

   else

      ::setProcessText( "Fallo de comunicación." )

   end if

   oWebService:End()

   ::setProcessText(  "Conexión cerrada." )

   if Len( aTarifas ) > 0
      aEval( aTarifas, {| hTarifa | ::IntegraTarifa( hTarifa ) } )
   end if

   ::setProcessText(  "Importación de tarifas finalizada con éxito." )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD IntegraTarifa( hTarifa ) CLASS ImportGamma

   if ArticulosModel():exist( hGet( hTarifa, "COD_ARTICULO" ) )
      ::editTarifa( hTarifa )
   else
      ::addTarifa( hTarifa )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD editTarifa( hTarifa ) CLASS ImportGamma
   
   local cArea := "EditTarifaGamma"
   local cSql

   ::oSayProcess:SetText( "Modificando tarifa: " + hGet( hTarifa, "DESCRIPCION" ) )

   cSql        := "UPDATE " + ArticulosModel():getTableName() + Space( 1 )
   cSql        += "SET Nombre=" + quoted( strTran( hGet( hTarifa, "DESCRIPCION" ), "'", "" ) ) + ","
   cSql        += "pCosto=" + AllTrim( Str( hGet( hTarifa, "PVP_UNIDAD" ) ) ) + Space( 1 )
   cSql        += "WHERE Codigo = " + quoted( hGet( hTarifa, "COD_ARTICULO" ) )

   ArticulosModel():ExecuteSqlStatement( cSql, @cArea )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addTarifa( hTarifa ) CLASS ImportGamma
   
   local cArea := "AddTarifaGamma"
   local cSql

   ::oSayProcess:SetText( "Añadiendo tarifa: " + hGet( hTarifa, "DESCRIPCION" ) )

   cSql        := "INSERT INTO " + ArticulosModel():getTableName() 
   cSql        += " ( Codigo, Nombre, TipoIva, pCosto ) VALUES "
   cSql        += " ( " + quoted( hGet( hTarifa, "COD_ARTICULO" ) )
   cSql        += ", " + quoted( strTran(hGet( hTarifa, "DESCRIPCION" ), "'", "" ) )
   cSql        += ", 'G', " + AllTrim( Str( hGet( hTarifa, "PVP_UNIDAD" ) ) ) + " )"

   ArticulosModel():ExecuteSqlStatement( cSql, @cArea )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ImportaAlbaranes() CLASS ImportGamma

   MsgInfo( "Importo albaranes" )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ImportaFacturas() CLASS ImportGamma

   MsgInfo( "Importo facturas" )

RETURN ( Self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//