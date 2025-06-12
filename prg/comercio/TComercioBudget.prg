#include "FiveWin.Ch" 
#include "Struct.ch"
#include "Factu.ch" 
#include "Ini.ch"
#include "MesDbf.ch" 

//---------------------------------------------------------------------------//

CLASS TComercioDocument FROM TComercioConector

   DATA TComercio

   DATA idDocumentPrestashop
   DATA dateDocumentPrestashop

   DATA cSerieDocument   
   DATA nNumeroDocument  
   DATA cSufijoDocument  
  
   METHOD New( TComercio )                                  CONSTRUCTOR

   METHOD insertDocumentIngestoolIfNotExist( oQuery )
   METHOD isDocumentIngestool( oQuery )                     VIRTUAL

   METHOD insertDocumentgestool( oQuery )
      
      METHOD getCountersDocumentgestool( oQuery )           VIRTUAL
      METHOD insertHeaderDocumentgestool( oQuery )
         METHOD setCustomerInDocument( oQuery )

      METHOD insertLinesDocumentgestool( oQuery )
         METHOD setProductInDocumentLine( oQueryLine )
         METHOD getProductProperty( idPropertygestool, productName )
         METHOD getNameProductProperty( idPropertygestool ) 

      METHOD insertMessageDocument( oQuery )
      METHOD insertStateDocumentPrestashop( oQuery ) 

   METHOD setgestoolIdDocument( oDatabase )                 VIRTUAL
   METHOD setgestoolSpecificDocument( oQuery )              VIRTUAL
   METHOD setPrestashopIdDocument()                         VIRTUAL
   METHOD setgestoolSpecificLineDocument()                  VIRTUAL

   METHOD idDocumentgestool()                               INLINE ( ::cSerieDocument + str( ::nNumeroDocument ) + ::cSufijoDocument ) 

   METHOD insertLinesKitsgestool()

END CLASS

//---------------------------------------------------------------------------//

METHOD New( TComercio ) CLASS TComercioDocument

   ::TComercio          := TComercio

Return ( Self )

//---------------------------------------------------------------------------//

METHOD insertDocumentIngestoolIfNotExist( oQuery ) CLASS TComercioDocument

   ::idDocumentPrestashop     := oQuery:fieldGet( 1 )
    
   if ::isDocumentIngestool( oQuery:fieldGetByName( "reference" ) )
      ::writeText( "El documento con el identificador " + alltrim( str( ::idDocumentPrestashop ) ) + " ya ha sido recibido." )
   else
      ::insertDocumentgestool( oQuery )
   end if

Return ( Self )

//---------------------------------------------------------------------------//

METHOD insertDocumentgestool( oQuery ) CLASS TComercioDocument

   ::TComercioCustomer():insertCustomerIngestoolIfNotExist( oQuery )

   if empty( ::TComercioCustomer():getCustomergestool() )
      ::writeText( "Cliente no encontrado, imposible añadir documento" )
      Return ( .f. )
   end if 

   ::getCountersDocumentgestool(      oQuery )
   ::insertHeaderDocumentgestool(     oQuery )
   ::insertLinesDocumentgestool(      oQuery )
   ::insertMessageDocument(           oQuery )
   ::insertStateDocumentPrestashop(   oQuery )

   ::setPrestashopIdDocument()
   
Return ( .t. )

//---------------------------------------------------------------------------//

METHOD insertHeaderDocumentgestool( oQuery ) CLASS TComercioDocument

   ( ::oDocumentHeaderDatabase() )->( dbappend() )

   ::setgestoolIdDocument( ::oDocumentHeaderDatabase() ) 

   ::setgestoolSpecificDocument( oQuery )

   ( ::oDocumentHeaderDatabase() )->cCodWeb      := ::idDocumentPrestashop
   ( ::oDocumentHeaderDatabase() )->cCodAlm      := Application():codigoAlmacen()
   ( ::oDocumentHeaderDatabase() )->cCodCaj      := Application():CodigoCaja()
   ( ::oDocumentHeaderDatabase() )->cCodObr      := "@" + alltrim( str( oQuery:FieldGetByName( "id_address_delivery" ) ) )
   ( ::oDocumentHeaderDatabase() )->cCodPgo      := cFPagoWeb( alltrim( oQuery:FieldGetByName( "module" ) ), D():FormasPago( ::getView() ) )
   ( ::oDocumentHeaderDatabase() )->nTarifa      := 1
   ( ::oDocumentHeaderDatabase() )->lSndDoc      := .t.
   ( ::oDocumentHeaderDatabase() )->lIvaInc      := uFieldEmpresa( "lIvaInc" )
   ( ::oDocumentHeaderDatabase() )->cManObr      := Padr( "Gastos envio", 250 )
   ( ::oDocumentHeaderDatabase() )->nManObr      := oQuery:FieldGetByName( "total_shipping_tax_excl" )
   ( ::oDocumentHeaderDatabase() )->nIvaMan      := oQuery:FieldGetByName( "carrier_tax_rate" )
   ( ::oDocumentHeaderDatabase() )->cCodUsr      := Auth():Codigo()
   ( ::oDocumentHeaderDatabase() )->dFecCre      := GetSysDate()
   ( ::oDocumentHeaderDatabase() )->cTimCre      := Time()
   ( ::oDocumentHeaderDatabase() )->cCodDlg      := Application():CodigoDelegacion()
   ( ::oDocumentHeaderDatabase() )->lWeb         := .t.
   ( ::oDocumentHeaderDatabase() )->lInternet    := .t.
   ( ::oDocumentHeaderDatabase() )->nTotNet      := oQuery:FieldGetByName( "total_products" )
   ( ::oDocumentHeaderDatabase() )->nTotIva      := oQuery:FieldGetByName( "total_paid_tax_incl" ) - ( oQuery:FieldGetByName( "total_products" ) + oQuery:FieldGetByName( "total_shipping_tax_incl" ) )

   ::setCustomerInDocument( oQuery )

   if !( ::oDocumentHeaderDatabase() )->( neterr() )
      ( ::oDocumentHeaderDatabase() )->( dbcommit() )
      ( ::oDocumentHeaderDatabase() )->( dbunlock() )

      ::writeText( "Documento " + ::cSerieDocument + "/" + alltrim( str( ::nNumeroDocument ) ) + "/" + ::cSufijoDocument + " introducido correctamente.", 3 )

   else
      
      ::writeText( "Error al descargar el documento : " + ::cSerieDocument + "/" + alltrim( str( ::nNumeroDocument ) ) + "/" + ::cSufijoDocument, 3 )

   end if   

Return ( .t. )

 //---------------------------------------------------------------------------//

 METHOD setCustomerInDocument( oQuery ) CLASS TComercioDocument

   local idCustomergestool                := ::TComercioCustomer():getCustomergestool()

   if !( D():gotoCliente( idCustomergestool, ::getView() ) )
      ::writeText( "Código de cliente " + alltrim( idCustomergestool ) + " no encontrado", 3 )
      Return ( .f. )
   end if 

   ( ::oDocumentHeaderDatabase() )->cCodCli    := ( D():Clientes( ::getView() ) )->Cod
   ( ::oDocumentHeaderDatabase() )->cNomCli    := ( D():Clientes( ::getView() ) )->Titulo
   ( ::oDocumentHeaderDatabase() )->cDirCli    := ( D():Clientes( ::getView() ) )->Domicilio
   ( ::oDocumentHeaderDatabase() )->cPobCli    := ( D():Clientes( ::getView() ) )->Poblacion
   ( ::oDocumentHeaderDatabase() )->cPrvCli    := ( D():Clientes( ::getView() ) )->Provincia
   ( ::oDocumentHeaderDatabase() )->cPosCli    := ( D():Clientes( ::getView() ) )->CodPostal
   ( ::oDocumentHeaderDatabase() )->cDniCli    := ( D():Clientes( ::getView() ) )->Nif
   ( ::oDocumentHeaderDatabase() )->cTlfCli    := ( D():Clientes( ::getView() ) )->Telefono
   ( ::oDocumentHeaderDatabase() )->cCodGrp    := ( D():Clientes( ::getView() ) )->cCodGrp
   ( ::oDocumentHeaderDatabase() )->nRegIva    := ( D():Clientes( ::getView() ) )->nRegIva
   ( ::oDocumentHeaderDatabase() )->lModCli    := .t.

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD insertLinesDocumentgestool( oQuery ) CLASS TComercioDocument

   local nNumLin           := 1
   local cQueryLine        
   local oQueryLine  
   local lKitArt           := .f.
   local cCodArt           := ""         

   cQueryLine              := "SELECT * FROM " + ::TComercio:cPrefixtable( "order_detail" ) + " " + ;
                              "WHERE id_order = " + alltrim( str( ::idDocumentPrestashop ) )
   oQueryLine              := TMSQuery():New( ::oConexionMySQLDatabase(), cQueryLine )

   if oQueryLine:Open() .and. ( oQueryLine:RecCount() > 0 )

      oQueryLine:GoTop()
      while !( oQueryLine:eof() )

         ( ::oDocumentLineDatabase() )->( dbappend() )

         ::setgestoolIdDocument( ::oDocumentLineDatabase() )
         
         ::setgestoolSpecificLineDocument()

         ( ::oDocumentLineDatabase() )->dFecha        := ::getDate( oQuery:FieldGetByName( "date_add" ) )
         ( ::oDocumentLineDatabase() )->cDetalle      := oQueryLine:FieldGetByName( "product_name" )
         ( ::oDocumentLineDatabase() )->mLngDes       := oQueryLine:FieldGetByName( "product_name" )
         ( ::oDocumentLineDatabase() )->nPosPrint     := nNumLin
         ( ::oDocumentLineDatabase() )->nNumLin       := nNumLin
         ( ::oDocumentLineDatabase() )->cAlmLin       := cDefAlm()
         ( ::oDocumentLineDatabase() )->nTarLin       := 1
         ( ::oDocumentLineDatabase() )->nUniCaja      := oQueryLine:FieldGetByName( "product_quantity" )
         ( ::oDocumentLineDatabase() )->nPreDiv       := oQueryLine:FieldGetByName( "product_price" ) 
         ( ::oDocumentLineDatabase() )->nDto          := oQueryLine:FieldGetByName( "reduction_percent" )
         ( ::oDocumentLineDatabase() )->nDtoDiv       := oQueryLine:FieldGetByName( "reduction_amount_tax_excl" )
         ( ::oDocumentLineDatabase() )->nIva          := ::TComercio:nIvaProduct( oQueryLine:FieldGetByName( "product_id" ) )

         ::setProductInDocumentLine( oQueryLine, @lKitArt, @cCodArt )

         if ( ::oDocumentLineDatabase() )->( neterr() )
            ::writeText( "Error al guardar las lineas del documento " + ::idDocumentgestool() )
         else 
            ( ::oDocumentLineDatabase() )->( dbunlock() )
         end if

         if lKitArt
            ::insertLinesKitsgestool( nNumLin, cCodArt, oQuery )
         end if

         lKitArt     := .f.

         oQueryLine:Skip()

         nNumLin++

      end while

   end if

   oQueryLine:Free()

Return ( .t. )
 
//---------------------------------------------------------------------------//

METHOD insertLinesKitsgestool( nNumLin, cCodArt, oQuery ) CLASS TComercioDocument

   local nRec     := ( D():Kit( ::getView() ) )->( Recno() )
   local nOrdAnt  := ( D():Kit( ::getView() ) )->( OrdSetFocus( "CCODKIT" ) )
   local nNumKit  := 1

   if ( D():Kit( ::getView() ) )->( dbSeek( cCodArt ) )

      while ( D():Kit( ::getView() ) )->cCodKit == cCodArt .and. !( D():Kit( ::getView() ) )->( Eof() )

         ( ::oDocumentLineDatabase() )->( dbappend() )

         ::setgestoolIdDocument( ::oDocumentLineDatabase() )
         
         ::setgestoolSpecificLineDocument()

         ( ::oDocumentLineDatabase() )->cRef          := ( D():Kit( ::getView() ) )->cRefKit
         ( ::oDocumentLineDatabase() )->cAlmLin       := cDefAlm()
         ( ::oDocumentLineDatabase() )->nPosPrint     := nNumLin
         ( ::oDocumentLineDatabase() )->nNumLin       := nNumLin
         ( ::oDocumentLineDatabase() )->nNumKit       := nNumKit
         ( ::oDocumentLineDatabase() )->nUniCaja      := ( D():Kit( ::getView() ) )->nUndKit
         ( ::oDocumentLineDatabase() )->lKitChl       := .t.
         ( ::oDocumentLineDatabase() )->nTarLin       := 1
         ( ::oDocumentLineDatabase() )->dFecha        := ::getDate( oQuery:FieldGetByName( "date_add" ) )
         
         if ( D():gotoArticulos( ( D():Kit( ::getView() ) )->cRefKit, ::getView() ) )

            ( ::oDocumentLineDatabase() )->cDetalle    := ( D():Articulos( ::getView() ) )->Nombre
            ( ::oDocumentLineDatabase() )->mLngDes     := ( D():Articulos( ::getView() ) )->Descrip
            ( ::oDocumentLineDatabase() )->cUnidad     := ( D():Articulos( ::getView() ) )->cUnidad
            ( ::oDocumentLineDatabase() )->nPesoKg     := ( D():Articulos( ::getView() ) )->nPesoKg 
            ( ::oDocumentLineDatabase() )->cPesoKg     := ( D():Articulos( ::getView() ) )->cUnidad
            ( ::oDocumentLineDatabase() )->nVolumen    := ( D():Articulos( ::getView() ) )->nVolumen
            ( ::oDocumentLineDatabase() )->cVolumen    := ( D():Articulos( ::getView() ) )->cVolumen
            ( ::oDocumentLineDatabase() )->nCtlStk     := ( D():Articulos( ::getView() ) )->nCtlStock
            ( ::oDocumentLineDatabase() )->cCodTip     := ( D():Articulos( ::getView() ) )->cCodTip
            ( ::oDocumentLineDatabase() )->cCodFam     := ( D():Articulos( ::getView() ) )->Familia
            ( ::oDocumentLineDatabase() )->cGrpFam     := retfld( ( D():Articulos( ::getView() ) )->Familia, D():Familias( ::getView() ), "cCodGrp" )
            
            ( ::oDocumentLineDatabase() )->lLote       := ( D():Articulos( ::getView() ) )->lLote 
            ( ::oDocumentLineDatabase() )->cLote       := ( D():Articulos( ::getView() ) )->cLote 

            ( ::oDocumentLineDatabase() )->nIva        := nIva( D():TiposIva( ::getView() ), ( D():Articulos( ::getView() ) )->TipoIva )

         end if

         ( ::oDocumentLineDatabase() )->( dbunlock() )
            
         nNumKit++

         ( D():Kit( ::getView() ) )->( dbSkip() )

      end while

   end if

   ( D():Kit( ::getView() ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():Kit( ::getView() ) )->( dbGoTo( nRec ) )

Return ( .t. )

//---------------------------------------------------------------------------//
         
METHOD setProductInDocumentLine( oQueryLine, lKitArt, cCodArt )

   local idProductgestool                 := oQueryLine:FieldGetByName( "product_reference" )

   if empty( idProductgestool )
      idProductgestool                    := ::TPrestashopId:getgestoolProduct( oQueryLine:FieldGetByName( "product_id" ), ::getCurrentWebName() )
   end if 

   if empty( idProductgestool )
      Return ( .f. )
   end if 

   if ( D():gotoArticulos( idProductgestool, ::getView() ) )

      ( ::oDocumentLineDatabase() )->cRef        := ( D():Articulos( ::getView() ) )->Codigo
      cCodArt                                    := ( D():Articulos( ::getView() ) )->Codigo
      ( ::oDocumentLineDatabase() )->cUnidad     := ( D():Articulos( ::getView() ) )->cUnidad
      ( ::oDocumentLineDatabase() )->nPesoKg     := ( D():Articulos( ::getView() ) )->nPesoKg
      ( ::oDocumentLineDatabase() )->cPesoKg     := ( D():Articulos( ::getView() ) )->cUnidad
      ( ::oDocumentLineDatabase() )->nVolumen    := ( D():Articulos( ::getView() ) )->nVolumen
      ( ::oDocumentLineDatabase() )->cVolumen    := ( D():Articulos( ::getView() ) )->cVolumen
      ( ::oDocumentLineDatabase() )->nCtlStk     := ( D():Articulos( ::getView() ) )->nCtlStock
      ( ::oDocumentLineDatabase() )->nCosDiv     := nCosto( ( D():Articulos( ::getView() ) )->Codigo, D():Articulos( ::getView() ), D():ArticulosCodigosBarras( ::getView() ) )
      ( ::oDocumentLineDatabase() )->cCodTip     := ( D():Articulos( ::getView() ) )->cCodTip
      ( ::oDocumentLineDatabase() )->cCodFam     := ( D():Articulos( ::getView() ) )->Familia
      ( ::oDocumentLineDatabase() )->cGrpFam     := retfld( ( D():Articulos( ::getView() ) )->Familia, D():Familias( ::getView() ), "cCodGrp" )
      
      ( ::oDocumentLineDatabase() )->lLote       := ( D():Articulos( ::getView() ) )->lLote 
      ( ::oDocumentLineDatabase() )->cLote       := ( D():Articulos( ::getView() ) )->cLote 

      ( ::oDocumentLineDatabase() )->cCodPr1     := ( D():Articulos( ::getView() ) )->cCodPrp1
      ( ::oDocumentLineDatabase() )->cCodPr2     := ( D():Articulos( ::getView() ) )->cCodPrp2
      ( ::oDocumentLineDatabase() )->cValPr1     := ::getProductProperty( ( D():Articulos( ::getView() ) )->cCodPrp1, oQueryLine:FieldGetByName( "product_name" ) )
      ( ::oDocumentLineDatabase() )->cValPr2     := ::getProductProperty( ( D():Articulos( ::getView() ) )->cCodPrp2, oQueryLine:FieldGetByName( "product_name" ) )

      ( ::oDocumentLineDatabase() )->lKitArt     := ( D():Articulos( ::getView() ) )->lKitArt

      lKitArt                                    := ( D():Articulos( ::getView() ) )->lKitArt

      Return ( .t. )

   end if

Return ( .f. )

//---------------------------------------------------------------------------//

METHOD getProductProperty( idPropertygestool, productName ) CLASS TComercioDocument

   local productProperty      := ""
   local productPropertyName  := ::getNameProductProperty( idPropertygestool, productName )

   if !empty( productPropertyName )
      Return ( productProperty )
   end if 
   
   if ( D():PropiedadesLineas( ::getView() ) )->( dbseekinord( upper( idPropertygestool ) + upper( productPropertyName ), "cCodDes" ) )
      productProperty         := ( D():PropiedadesLineas( ::getView() ) )->cCodTbl      
   end if 

Return ( productProperty )

//---------------------------------------------------------------------------//

METHOD getNameProductProperty( idPropertygestool, productName ) CLASS TComercioDocument

   local cPropertieCode       := ""
   local cPropertieName       := retFld( idPropertygestool, D():Propiedades( ::getView() ), "cDesPro" ) 

   if empty( cPropertieName )
      Return ( cPropertieCode )
   end if

   cPropertieName             := alltrim( cPropertieName ) + " : "

   if at( cPropertieName, productName ) > 0
      cPropertieCode          := substr( productName, at( cPropertieName, productName ) ) 
      cPropertieCode          := strtran( cPropertieCode, cPropertieName, "" )   
      if at( ",", cPropertieCode ) > 0
         cPropertieCode       := substr( cPropertieCode, 1, at( ",", cPropertieCode ) - 1 )
      end if 
   end if 

Return ( cPropertieCode )

//---------------------------------------------------------------------------//

METHOD insertMessageDocument( oQuery ) CLASS TComercioDocument

   local dFecha   
   local cQueryThead
   local oQueryThead
   local cQueryMessage
   local oQueryMessage

   dFecha                  := ::getDate( oQuery:FieldGetByName( "date_add" ) )

   cQueryThead             := "SELECT * FROM " + ::Tcomercio:cPrefixtable( "customer_thread" ) + " " + ;
                              "WHERE id_order = " + alltrim( str( ::idDocumentPrestashop ) )
   oQueryThead             := TMSQuery():New( ::oConexionMySQLDatabase(), cQueryThead )

   if oQueryThead:Open() .and. ( oQueryThead:recCount() > 0 )

      oQueryThead:GoTop()
      while !oQueryThead:eof()

         cQueryMessage     := "SELECT * FROM " + ::Tcomercio:cPrefixtable( "customer_message" ) + " " +;
                              "WHERE id_customer_thread = " + alltrim( str( oQueryThead:fieldget( 1 ) ) )
         oQueryMessage     := TMSQuery():New( ::oConexionMySQLDatabase(), cQueryMessage )

         if oQueryMessage:Open() .and. ( oQueryMessage:recCount() > 0 )

            oQueryMessage:GoTop()
            while !oQueryMessage:eof()

               ( ::oDocumentIncidenciaDatabase() )->( dbappend() )

               ::setgestoolIdDocument( ::oDocumentIncidenciaDatabase() )

               ( ::oDocumentIncidenciaDatabase() )->dFecInc    := dFecha
               ( ::oDocumentIncidenciaDatabase() )->mDesInc    := oQueryMessage:FieldGetByName( "message" )
               ( ::oDocumentIncidenciaDatabase() )->lAviso     := .t.

               ( ::oDocumentIncidenciaDatabase() )->( dbunlock() )

               oQueryMessage:Skip()

            end while

         end if
            
         oQueryMessage:Free()    

         oQueryThead:Skip()

      end while

   end if   

   oQueryThead:Free()

Return ( .t. )
 
//---------------------------------------------------------------------------//

METHOD insertStateDocumentPrestashop( oQuery ) CLASS TComercioDocument
   
   local nLanguage
   local cQueryState
   local oQueryState
   
   cQueryState    := "SELECT * FROM " + ::TComercio:cPrefixtable( "order_history" ) + " h " + ;
                     "INNER JOIN " + ::TComercio:cPrefixtable( "order_state_lang" ) + " s on h.id_order_state = s.id_order_state " + ;
                     "WHERE s.id_lang = " + ::TComercio:nLanguage + " and id_order = " + alltrim( str( ::idDocumentPrestashop ) )
   oQueryState    := TMSQuery():New( ::oConexionMySQLDatabase(), cQueryState  )

   if oQueryState:Open() .and. oQueryState:RecCount() > 0

      oQueryState:GoTop()

      while !oQueryState:Eof()

         ( ::oDocumentEstadoDatabase() )->( dbappend() )

         ::setgestoolIdDocument( ::oDocumentEstadoDatabase() )

         ( ::oDocumentEstadoDatabase() )->cSitua    := oQueryState:FieldGetByName( "name" )
         ( ::oDocumentEstadoDatabase() )->dFecSit   := ::getDate( oQueryState:FieldGetByName( "date_add" ) )
         ( ::oDocumentEstadoDatabase() )->tFecSit   := ::getTime( oQueryState:FieldGetByName( "date_add" ) )
         ( ::oDocumentEstadoDatabase() )->idPs      := oQueryState:FieldGetByName( "id_order_history" )
                  
         ( ::oDocumentEstadoDatabase() )->( dbunlock() )

         oQueryState:Skip()

      end while

   end if
               
Return ( .t. )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TComercioBudget FROM TComercioDocument

   METHOD isDocumentIngestool() 
   METHOD getCountersDocumentgestool( oQuery ) 

   METHOD setgestoolIdDocument( oDatabase ) 
   METHOD setgestoolSpecificDocument( oQuery )
   METHOD setgestoolSpecificLineDocument()

   METHOD setPrestashopIdDocument()

   METHOD oDocumentHeaderDatabase()                     INLINE ( D():PresupuestosClientes( ::getView() )  )
   METHOD oDocumentLineDatabase()                       INLINE ( D():PresupuestosClientesLineas( ::getView() )  )
   METHOD oDocumentIncidenciaDatabase()                 INLINE ( D():PresupuestosClientesIncidencias( ::getView() ) )
   METHOD oDocumentEstadoDatabase()                     INLINE ( D():PresupuestosClientesSituaciones( ::getView() ) )

END CLASS

//---------------------------------------------------------------------------//

METHOD isDocumentIngestool( idDocumentPrestashop ) CLASS TComercioBudget

   if empty( idDocumentPrestashop )
      Return .f.
   end if 

Return ( ( ::oDocumentHeaderDatabase() )->( dbseekInOrd( idDocumentPrestashop, "cSuPre" ) ) )

//---------------------------------------------------------------------------//

METHOD getCountersDocumentgestool( oQuery ) CLASS TComercioBudget

   ::idDocumentPrestashop  := oQuery:fieldGet( 1 )
   ::cSerieDocument        := ::TComercioConfig():getBudgetSerie()
   ::nNumeroDocument       := nNewDoc( ::cSerieDocument, ::oDocumentHeaderDatabase(), "nPreCli", , D():Contadores( ::getView() ) )
   ::cSufijoDocument       := retSufEmp()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD setgestoolIdDocument( oDatabase ) CLASS TComercioBudget

   ( oDatabase )->cSerPre  := ::cSerieDocument
   ( oDatabase )->nNumPre  := ::nNumeroDocument
   ( oDatabase )->cSufPre  := ::cSufijoDocument

Return ( self )

//---------------------------------------------------------------------------//

METHOD setgestoolSpecificDocument( oQuery ) CLASS TComercioBudget

   ( ::oDocumentHeaderDatabase() )->dFecPre  := ::getDate( oQuery:FieldGetByName( "date_add" ) )
   ( ::oDocumentHeaderDatabase() )->cTurPre  := cCurSesion()
   ( ::oDocumentHeaderDatabase() )->cSuPre   := oQuery:FieldGetByName( "reference" )
   ( ::oDocumentHeaderDatabase() )->lEstado  := .t.
   ( ::oDocumentHeaderDatabase() )->cDivPre  := cDivEmp()
   ( ::oDocumentHeaderDatabase() )->nVdvPre  := nChgDiv( cDivEmp(), D():Divisas( ::getView() ) )
   ( ::oDocumentHeaderDatabase() )->lCloPre  := .f.
   ( ::oDocumentHeaderDatabase() )->nTotPre  := oQuery:FieldGetByName( "total_paid_tax_incl" )

Return ( self )

//---------------------------------------------------------------------------//

METHOD setgestoolSpecificLineDocument() CLASS TComercioBudget

   ( ::oDocumentLineDatabase() )->nCanPre    := 1

Return ( self )

//---------------------------------------------------------------------------//

METHOD setPrestashopIdDocument() CLASS TComercioBudget

   ::TPrestashopId():setgestoolBudget( ::idDocumentgestool(), ::getCurrentWebName(), ::idDocumentPrestashop )

Return ( self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TComercioOrder FROM TComercioDocument

   METHOD isDocumentIngestool() 
   METHOD getCountersDocumentgestool( oQuery ) 
   METHOD setgestoolIdDocument( oDatabase ) 

   METHOD setPrestashopIdDocument()
   METHOD setgestoolSpecificDocument( oQuery )
   METHOD setgestoolSpecificLineDocument() 

   METHOD oDocumentHeaderDatabase()                     INLINE ( D():PedidosClientes( ::getView() )  )
   METHOD oDocumentLineDatabase()                       INLINE ( D():PedidosClientesLineas( ::getView() )  )
   METHOD oDocumentIncidenciaDatabase()                 INLINE ( D():PedidosClientesIncidencias( ::getView() ) )
   METHOD oDocumentEstadoDatabase()                     INLINE ( D():PedidosClientesSituaciones( ::getView() ) )

END CLASS

//---------------------------------------------------------------------------//

METHOD isDocumentIngestool( idDocumentPrestashop ) CLASS TComercioOrder

   if empty( idDocumentPrestashop )
      Return .f.
   end if 

Return ( ( ::oDocumentHeaderDatabase() )->( dbseekInOrd( idDocumentPrestashop, "cSuPed" ) ) )

//---------------------------------------------------------------------------//

METHOD getCountersDocumentgestool( oQuery ) CLASS TComercioOrder

   ::idDocumentPrestashop  := oQuery:fieldGet( 1 )
   ::cSerieDocument        := ::TComercioConfig():getBudgetSerie()
   ::nNumeroDocument       := nNewDoc( ::cSerieDocument, ::oDocumentHeaderDatabase(), "nPedCli", , D():Contadores( ::getView() ) )
   ::cSufijoDocument       := retSufEmp()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD setgestoolIdDocument( oDatabase ) CLASS TComercioOrder

   ( oDatabase )->cSerPed  := ::cSerieDocument
   ( oDatabase )->nNumPed  := ::nNumeroDocument
   ( oDatabase )->cSufPed  := ::cSufijoDocument

Return ( self )

//---------------------------------------------------------------------------//

METHOD setgestoolSpecificDocument( oQuery ) CLASS TComercioOrder

   ( ::oDocumentHeaderDatabase() )->dFecPed  := ::getDate( oQuery:FieldGetByName( "date_add" ) ) 
   ( ::oDocumentHeaderDatabase() )->cTurPed  := cCurSesion()
   ( ::oDocumentHeaderDatabase() )->cSuPed   := oQuery:FieldGetByName( "reference" )
   ( ::oDocumentHeaderDatabase() )->cDivPed  := cDivEmp()
   ( ::oDocumentHeaderDatabase() )->nVdvPed  := nChgDiv( cDivEmp(), D():Divisas( ::getView() ) )
   ( ::oDocumentHeaderDatabase() )->lCloPed  := .f.
   ( ::oDocumentHeaderDatabase() )->nTotPed  := oQuery:FieldGetByName( "total_paid_tax_incl" )

Return ( self )

//---------------------------------------------------------------------------//

METHOD setgestoolSpecificLineDocument() CLASS TComercioOrder

   ( ::oDocumentLineDatabase() )->nCanPed    := 1

Return ( self )

//---------------------------------------------------------------------------//

METHOD setPrestashopIdDocument() CLASS TComercioOrder

   ::TPrestashopId():setgestoolOrder( ::idDocumentgestool(), ::getCurrentWebName(), ::idDocumentPrestashop )

Return ( self )

//---------------------------------------------------------------------------//
