#include "Fivewin.ch"
#include "Factu.ch" 
#include "Fastreph.ch"

//---------------------------------------------------------------------------//

CLASS MovimientosAlmacenController FROM SQLNavigatorController

   DATA aRollBackStock

   DATA cFileName

   DATA oLineasController

   DATA oImportadorController

   DATA oCapturadorController

   //DATA oEtiquetasController

   DATA oConfiguracionesController

   DATA oImprimirSeriesController

   DATA oNumeroDocumentoComponent

   DATA oReport

   DATA oSenderReciver

   DATA cOldName

   METHOD New()
   METHOD End()

   METHOD validateNumero()          

   METHOD validateAlmacenOrigen()            INLINE ( iif(  ::validate( "almacen_origen" ),;
                                                      ::stampAlmacenNombre( ::oDialogView:oGetAlmacenOrigen ),;
                                                      .f. ) )

   METHOD validateAlmacenDestino()           INLINE ( iif(  ::validate( "almacen_destino" ),;
                                                      ::stampAlmacenNombre( ::oDialogView:oGetAlmacenDestino ),;
                                                      .f. ) )

   METHOD setFileName( cFileName )           INLINE ( ::cFileName := cFileName )
   METHOD getFileName()                      INLINE ( ::cFileName )

   METHOD getSenderReciver( oParent )

   METHOD stampNumero()

   METHOD checkSerie( oGetNumero )

   METHOD stampAlmacenNombre()

   METHOD stampGrupoMovimientoNombre()

   METHOD stampMarcadores()

   METHOD printDocument()  

   METHOD labelDocument()

   METHOD setConfig()              

   METHOD deleteLines()
   
   METHOD refreshLineasBrowse()              INLINE ( iif( !empty( ::oLineasController ), ::getBrowse():Refresh(), ) )

   METHOD printSerialDocument()              INLINE ( ::oImprimirSeriesController:Activate() ) 

   METHOD buildNotSentJson()

   METHOD zipNotSentJson()

   METHOD setSentFromFetch()   

   METHOD isUnzipToJson( cZipFile )

   METHOD jsonToSQL()

   METHOD setSender( cSentence )
   METHOD setSent()                          INLINE ( ::setSender( ::oModel:getSentenceSentFromIds(      ::getIdFromRecno( ::getBrowse():aSelected ) ) ) )
   METHOD setNotSent()                       INLINE ( ::setSender( ::oModel:getSentenceNotSentFromIds(   ::getIdFromRecno( ::getBrowse():aSelected ) ) ) )

   METHOD isAddedTag( cMarcador )
      METHOD addTag( uuidTag )
      METHOD deleteTag( idTageable )

   METHOD Recalcular()

   METHOD lValidaDocumento()

   METHOD isEditing()

   METHOD isDeleting()

   METHOD exitEdited()

   METHOD rollBackStock()

   METHOD stampStock()

   METHOD deleteRollbackStock()

   METHOD appenedOrDuplicated()
   METHOD edited()

   METHOD stampConsolidacion()

   METHOD rollBackEditConsolidacion()

END CLASS

//---------------------------------------------------------------------------//

METHOD New()

   ::Super:New()

   ::cTitle                      := "Movimientos de almacén" 

   ::cOldName                    := "MovAlm"

   ::setName( "movimientos_de_almacen" )

   ::cDirectory                  := cPatDocuments( "Movimientos almacen" ) 

   ::hImage                      := {  "16"  => "gc_pencil_package_16",;
                                       "48"  => "gc_package_48",;
                                       "64"  => "gc_package_64" }

   ::nLevel                      := Auth():Level( ::getName() )

   if nAnd( ::nLevel, 1 ) == 0
      msgStop( "Acceso no permitido." )
      return ( self )
   end if

   ::lTransactional              := .t.

   ::lDocuments                  := .t.

   ::lLabels                     := .t.

   ::lConfig                     := .t.

   ::lOthers                     := .t.

   ::oModel                      := SQLMovimientosAlmacenModel():New( self )

   ::oBrowseView                 := MovimientosAlmacenBrowseView():New( self )

   ::oDialogView                 := MovimientosAlmacenView():New( self )

   ::oValidator                  := MovimientosAlmacenValidator():New( self )

   ::oLineasController           := MovimientosAlmacenLineasController():New( self )
   
   ::oImportadorController       := ImportadorMovimientosAlmacenLineasController():New( self )

   ::oCapturadorController       := CapturadorMovimientosAlmacenLineasController():New( self )

   ::oImprimirSeriesController   := ImprimirSeriesController():New( self )

   //::oEtiquetasController        := EtiquetasMovimientosAlmacenController():New( self )

   ::oConfiguracionesController  := ConfiguracionesController():New( self )

   ::oReport                     := MovimientosAlmacenReport():New( self )

   ::oNumeroDocumentoComponent   := NumeroDocumentoComponent():New( self )

   ::oSenderReciver              := SenderReciverController():New( self )

   ::loadDocuments()

   ::oNavigatorView:oMenuTreeView:setEvent( 'addedConfigButton',;
      {|| ::oNavigatorView:oMenuTreeView:AddButton( "Marcar para envio", "gc_mail2_delete_16", {|| ::setNotSent() }, , ACC_EDIT, ::oNavigatorView:oMenuTreeView:oButtonOthers ) } )
 
   ::oNavigatorView:oMenuTreeView:setEvent( 'addedConfigButton',;
      {|| ::oNavigatorView:oMenuTreeView:AddButton( "Marcar como enviado", "gc_mail2_check_16", {|| ::setSent() }, , ACC_EDIT, ::oNavigatorView:oMenuTreeView:oButtonOthers ) } )

   ::setEvents( { 'editing' }, {|| ::isEditing() } )
   ::setEvents( { 'exitEdited' }, {|| ::exitEdited() } )
   ::setEvents( { 'deleting' }, {|| ::isDeleting() } )

   ::aRollBackStock              := {}

   ::setEvents( { 'appended', 'duplicated' }, {|| ::appenedOrDuplicated() } )
   ::setEvents( { 'edited' }, {|| ::edited() } )
   ::oModel:setEvents( { 'deletingSelection' }, {|| ::deleteRollbackStock() } )
   ::setEvents( { 'deletedSelection' }, {|| ::rollBackStock() } )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD End()

   ::oModel:End()

   ::oBrowseView:End()

   ::oDialogView:End()

   ::oValidator:End()

   ::oLineasController:End()

   ::oCapturadorController:End()

   ::oImportadorController:End()

   //::oEtiquetasController:End()

   ::oReport:End()

   ::oConfiguracionesController:End()

   ::oNumeroDocumentoComponent:End()

   ::oSenderReciver:End()

   ::Super:End()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getSenderReciver( oParent )

   if !Empty( ::oSenderReciver )
      ::oSenderReciver:oSender                  := oParent
   end if

Return ( ::oSenderReciver )

//---------------------------------------------------------------------------//
   
METHOD validateNumero()

   if !::validate( "numero" )
      RETURN ( .f. )
   end if 
      
   ::stampNumero( ::oDialogView:oGetNumero )
      
RETURN ( ::checkSerie( ::oDialogView:oGetNumero ) )

//---------------------------------------------------------------------------//

METHOD stampNumero( oGetNumero )

   local nAt
   local cSerie   := ""
   local nNumero
   local cNumero  := alltrim( oGetNumero:varGet() )

   nAt            := rat( "/", cNumero )
   if nAt == 0
      cNumero     := padr( rjust( cNumero, "0", 6 ), 50 )
   else 
      cSerie      := upper( substr( cNumero, 1, nAt - 1 ) )
      nNumero     := substr( cNumero, nAt + 1 )
      cNumero     := padr( cSerie + "/" + rjust( nNumero, "0", 6 ), 50 )
   end if 
      
   oGetNumero:cText( cNumero )

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD checkSerie( oGetNumero )

   local nAt
   local cSerie
   local cNumero  := alltrim( oGetNumero:varGet() )

   nAt            := rat( "/", cNumero )
   if nAt == 0
      RETURN ( .t. )
   end if 

   cSerie         := upper( substr( cNumero, 1, nAt - 1 ) )

   if SQLConfiguracionesModel():isSerie( ::cName, cSerie )
      RETURN ( .t. )
   end if

   if msgYesNo( "La serie " + cSerie + ", no existe.", "¿ Desea crear una nueva serie ?" )
      SQLConfiguracionesModel():setSerie( ::cName, cSerie ) 
   else 
      RETURN ( .f. )
   end if 

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD stampAlmacenNombre( oGetAlmacen )

   local cCodigoAlmacen    := oGetAlmacen:varGet()
   local cNombreAlmacen    := AlmacenesModel():getNombre( cCodigoAlmacen )

   oGetAlmacen:oHelpText:cText( cNombreAlmacen )

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD stampGrupoMovimientoNombre( oGetGrupoMovimiento )

   local cCodigoGrupo      := oGetGrupoMovimiento:varGet()
   local cNombreGrupo      := GruposMovimientosModel():getNombre( cCodigoGrupo )

   oGetGrupoMovimiento:oHelpText:cText( cNombreGrupo )

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD stampMarcadores( oTagsEver )
   
   /*local aMarcadores    := TageableRepository():getHashTageableTags( ::oModel:getBuffer( "uuid" ) ) 

   if empty( aMarcadores )
      RETURN ( .t. )
   end if 
   
   aeval( aMarcadores, {|h| oTagsEver:addItem( hget( h, "nombre" ), hget( h, "id" ) ) } )

   oTagsEver:Refresh()*/

RETURN ( .t. )

//---------------------------------------------------------------------------//
   
METHOD deleteLines()

   aeval( ::getRowSet():IdFromRecno( ::aSelected, "uuid" ), {| uuid | ::oLineasController:deleteLines( uuid ) } )

RETURN ( self ) 

//---------------------------------------------------------------------------//

METHOD printDocument( nDevice, cFile, nCopies, cPrinter )

   DEFAULT nDevice   := IS_SCREEN

   if empty( ::aDocuments )
      msgStop( "No hay formatos para impresión" )
      RETURN ( self )  
   end if 

   if empty( cFile )
      cFile          := ::oConfiguracionesController:oModel:getDocumentoMovimientosAlmacen()
   end if 

   if empty( cFile ) 
      cFile          := afirst( ::aDocuments )
   end if 

   if empty( cFile )
      msgStop( "No hay formatos por defecto" )
      RETURN ( self )  
   end if 

   if empty( nCopies )
      nCopies        := ::oConfiguracionesController:oModel:getCopiasMovimientosAlmacen()
   end if 

   ::oImprimirSeriesController:showDocument( nDevice, cFile, nCopies, cPrinter )

RETURN ( self ) 

//---------------------------------------------------------------------------//

METHOD labelDocument()

  //::oEtiquetasController:Activate()

RETURN ( self ) 

//---------------------------------------------------------------------------//

METHOD setConfig()

   ::oConfiguracionesController:Edit()

RETURN ( self ) 

//---------------------------------------------------------------------------//

METHOD buildNotSentJson()

   ::oModel:selectNotSentToJson()

   if empty( ::oModel:aFetch )
      RETURN ( nil )
   end if 

   ::oLineasController:oModel:selectFetchToJson( ;
      ::oLineasController:oModel:getSentenceNotSent( ::oModel:aFetch ) )  

   if empty( ::oLineasController:oModel:aFetch )
      RETURN ( nil )
   end if 

   ::oLineasController:oSeriesControler:oModel:selectFetchToJson( ;
      ::oLineasController:oSeriesControler:oModel:getSentenceNotSent( ::oLineasController:oModel:aFetch ) )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD zipNotSentJson()

   local cZipFile

   if !file( ::oModel:getJsonFileToExport() )                                    .and. ;
      !file( ::oLineasController:oModel:getJsonFileToExport() )                  .and. ;
      !file( ::oLineasController:oSeriesControler:oModel:getJsonFileToExport() )
      RETURN ( self )
   end if 

   cZipFile       := cpatout() + ::cName + "_" + hb_ttos( hb_datetime() ) + ".zip"

   hb_setdiskzip( {|| nil } )

   hb_zipfile( cZipFile, ::oModel:getJsonFileToExport(), 9 )
   hb_zipfile( cZipFile, ::oLineasController:oModel:getJsonFileToExport(), 9 ) 
   hb_zipfile( cZipFile, ::oLineasController:oSeriesControler:oModel:getJsonFileToExport(), 9 ) 

   hb_gcall()

   ::oExportableController:setZipFile( cZipFile )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD setSentFromFetch()

   local cSentence   := ::oModel:getSentenceSentFromFetch()
      
   if !empty( cSentence )
      getSQLDatabase():Exec( cSentence )
   end if 

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD isUnzipToJson( cZipFile )

   local aFiles
   local lUnZiped    := .t.

   if !file( cZipFile )
      RETURN ( .f. )
   end if 

   aFiles            := hb_getfilesinzip( cZipFile )

   if !hb_unzipfile( cZipFile, , , , cpatin(), aFiles )
      msgStop( "No se ha descomprimido el fichero " + cZipFile, "Error" )
      lUnZiped       :=  .f. 
   end if

   hb_gcall()

RETURN ( lUnZiped )

//---------------------------------------------------------------------------//

METHOD jsonToSQL()

   if !::oModel:isInsertOrUpdateFromJson( ::oModel:getJsonFileToImport() )
      msgStop( "No se ha incorporado el fichero " + ::oModel:getJsonFileToImport(), "Error" )
      RETURN ( .f. )
   end if 

   if !::oLineasController:oModel:isInsertOrUpdateFromJson()
      msgStop( "No se ha incorporado el fichero " + ::oLineasController:oModel:getJsonFileToImport(), "Error" )
      RETURN ( .f. )
   end if 

   if !::oLineasController:oSeriesControler:oModel:isInsertOrUpdateFromJson()
      msgStop( "No se ha incorporado el fichero " + ::oLineasController:oSeriesControler:oModel:getJsonFileToImport(), "Error" )
      RETURN ( .f. )
   end if 

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD setSender( cSentence )

   if empty( cSentence )
      RETURN ( self )
   end if 
      
   getSQLDatabase():Exec( cSentence )

   ::getRowSet():Refresh()

   ::getBrowse():Refresh()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD isAddedTag( cMarcador )

   local uuidTag

   if empty( uuidTag )
      RETURN ( .f. )
   end if 

   ::addTag( uuidTag )

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD addTag( uuidTag )

   /*local hBuffer

   hBuffer                    := SQLTageableModel():loadBlankBuffer()
   hBuffer[ "tag_uuid"]       := uuidTag
   hBuffer[ "tageable_uuid" ] := ::oModel:getBuffer( "uuid" )
   SQLTageableModel():insertBuffer( hBuffer )*/

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD deleteTag( idTageable )

   //SQLTageableModel():deleteById( idTageable )

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD Recalcular()

   if !MsgYesNo( "¿Desea recalcular los precios del documento?", "Confirme" )
      Return ( nil )
   end if

   ::oModel:RecalcularPreciosLineas()

   ::oLineasController:getRowSet:Refresh()

   ::oLineasController:getBrowse():Refresh()

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lValidaDocumento()

   ::oModel:ValidaDocumento()

   ::oLineasController:oModel:ValidaDocumentos( ::oModel:hBuffer, ::oDialogView:oMeter )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD isEditing() CLASS MovimientosAlmacenController

   if ( ::getRowSet():fieldGet( 'tipo_movimiento' ) == 4 ) .and. ( ::getRowSet():fieldGet( 'validado' ) == 1 )
      MsgStop( "No se puede editar una consolidación validada." )
      Return ( .f. )
   end if

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD isDeleting() CLASS MovimientosAlmacenController

   local nRec
   local lFlag    := .f.

   for each nRec in ::getBrowse():aSelected

      ::gotoRowSetRecno( nRec )

      if ( ::getRowSet():fieldGet( 'tipo_movimiento' ) == 4 ) .and. ( ::getRowSet():fieldGet( 'validado' ) == 1 )

         lFlag    := .t.
      end if

   next

   if lFlag
      MsgStop( "No se puede eliminar una consolidación validada." )
      Return .f.
   end if

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD exitEdited CLASS MovimientosAlmacenController

   ::setSender( ::oModel:getSentenceNotSentFromIds( { ::getRowSet():fieldGet( 'id' ) } ) )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD stampStock() CLASS MovimientosAlmacenController

   local hStock      := {=>}

   ::oLineasController:oRowSet:goTop()

   while !( ::oLineasController:oRowSet:Eof() )

      hset( hStock, "codigo_articulo", AllTrim( ::oLineasController:oRowSet:fieldget( 'codigo_articulo' ) ) )
      hset( hStock, "codigo_almacen_entrada", AllTrim( ::oModel:hBuffer[ "almacen_destino" ] ) )
      hset( hStock, "codigo_almacen_salida", AllTrim( ::oModel:hBuffer[ "almacen_origen" ] ) )
      hset( hStock, "codigo_primera_propiedad", AllTrim( ::oLineasController:oRowSet:fieldget( 'codigo_primera_propiedad' ) ) )
      hset( hStock, "valor_primera_propiedad", AllTrim( ::oLineasController:oRowSet:fieldget( 'valor_primera_propiedad' ) ) )
      hset( hStock, "codigo_segunda_propiedad", AllTrim( ::oLineasController:oRowSet:fieldget( 'codigo_segunda_propiedad' ) ) )
      hset( hStock, "valor_segunda_propiedad", AllTrim( ::oLineasController:oRowSet:fieldget( 'valor_segunda_propiedad' ) ) )
      hset( hStock, "lote", AllTrim( ::oLineasController:oRowSet:fieldget( 'lote' ) ) )
      hset( hStock, "bultos_articulo", ::oLineasController:oRowSet:fieldget( 'bultos_articulo' ) )
      hset( hStock, "cajas_articulo", ::oLineasController:oRowSet:fieldget( 'cajas_articulo' ) )
      hset( hStock, "unidades_articulo", ( NotCaja( ::oLineasController:oRowSet:fieldget( 'cajas_articulo' ) ) * ::oLineasController:oRowSet:fieldget( 'unidades_articulo' ) ) )
      hset( hStock, "fecha", hb_ttod( ::oModel:hBuffer[ "fecha_hora" ] ) )
      hset( hStock, "hora", substr( hb_tstostr( ::oModel:hBuffer[ "fecha_hora" ] ), 12, 8 ) )

      hStock      := {=>}      
      
      ::oLineasController:oRowSet:skip()

   end while

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD rollBackStock() CLASS MovimientosAlmacenController

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD deleteRollbackStock() CLASS MovimientosAlmacenController

   local aRecords
   local hRecord
   local hRollbackStock         := {=>}

   ::aRollBackStock     := {}

   aRecords             := ::oLineasController:oModel:getLinesFromStock( ::oModel:aUuidsToDelete )

   if hb_isArray( aRecords ) .and. ( len( aRecords ) > 0 )

      for each hRecord in aRecords

         hset( hRollbackStock, "codigo_articulo", AllTrim( hRecord[ "codigo_articulo" ] ) )
         hset( hRollbackStock, "codigo_almacen_entrada", AllTrim( hRecord[ "almacen_destino" ] ) )
         hset( hRollbackStock, "codigo_almacen_salida", AllTrim( hRecord[ "almacen_origen" ] ) )
         hset( hRollbackStock, "codigo_primera_propiedad", AllTrim( hRecord[ "codigo_primera_propiedad" ] ) )
         hset( hRollbackStock, "valor_primera_propiedad", AllTrim( hRecord[ "valor_primera_propiedad" ] ) )
         hset( hRollbackStock, "codigo_segunda_propiedad", AllTrim( hRecord[ "codigo_segunda_propiedad" ] ) )
         hset( hRollbackStock, "valor_segunda_propiedad", AllTrim( hRecord[ "valor_segunda_propiedad" ] ) )
         hset( hRollbackStock, "lote", AllTrim( hRecord[ "lote" ] ) )
         hset( hRollbackStock, "bultos_articulo", hRecord[ "bultos" ] )
         hset( hRollbackStock, "cajas_articulo", hRecord[ "cajas" ] )
         hset( hRollbackStock, "unidades_articulo", ( NotCaja( hRecord[ "cajas" ] ) * hRecord[ "unidades" ] ) )
         hset( hRollbackStock, "fecha", hb_ttod( hRecord[ "fecha_hora" ] ) )
         hset( hRollbackStock, "hora", substr( hb_tstostr( hRecord[ "fecha_hora" ] ), 12, 8 ) )
         hset( hRollbackStock, "tipo_movimiento", hRecord[ "tipo" ] )

         aAdd( ::aRollBackStock, hRollbackStock )

         hRollbackStock := {=>}

      next
      
   end if

   //::rollBackStock()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD appenedOrDuplicated() CLASS MovimientosAlmacenController

   if ::oModel:hBuffer[ "tipo_movimiento" ] == 4

      ::stampConsolidacion()

      RETURN ( Self )

   end if

   ::stampStock()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD edited() CLASS MovimientosAlmacenController

   if ::oModel:hBuffer[ "tipo_movimiento" ] == 4

      ::rollBackEditConsolidacion()
      ::stampConsolidacion()

      RETURN ( Self )

   end if

   ::rollBackStock()
   ::stampStock()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD rollBackEditConsolidacion() CLASS MovimientosAlmacenController

   local aRecords
   local hRecord
   local hRollbackStock          := {=>}
   local aRec                    := {}
   local n

   aRecords                      := ::oLineasController:oModel:getLinesFromStock( { ::oModel:hBuffer[ "uuid" ] } )

   if hb_isArray( ::aRollBackStock ) .and. ( len( ::aRollBackStock ) > 0 )

      for each hRecord in ::aRollBackStock

         n := aScan( aRecords, {|a| AllTrim( a[ "codigo_articulo" ] ) == AllTrim( hGet( hRecord, "codigo_articulo" ) ) .and.;
                                    AllTrim( a[ "almacen_destino" ] ) == AllTrim( hGet( hRecord, "codigo_almacen_entrada" ) ) .and.;
                                    AllTrim( a[ "almacen_origen" ] ) == AllTrim( hGet( hRecord, "codigo_almacen_salida" ) ) .and.;
                                    AllTrim( a[ "codigo_primera_propiedad" ] ) == AllTrim( hGet( hRecord, "codigo_primera_propiedad" ) ) .and.;
                                    AllTrim( a[ "valor_primera_propiedad" ] ) == AllTrim( hGet( hRecord, "valor_primera_propiedad" ) ) .and.;
                                    AllTrim( a[ "codigo_segunda_propiedad" ] ) == AllTrim( hGet( hRecord, "codigo_segunda_propiedad" ) ) .and.;
                                    AllTrim( a[ "valor_segunda_propiedad" ] ) == AllTrim( hGet( hRecord, "valor_segunda_propiedad" ) ) .and.;
                                    AllTrim( a[ "lote" ] ) == AllTrim( hGet( hRecord, "lote" ) ) } )

         if n == 0
            aAdd( aRec, hRecord )
         end if

      next
      
   end if

   ::aRollBackStock     := aRec


RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD stampConsolidacion() CLASS MovimientosAlmacenController

   local hStock      := {=>}

   ::oLineasController:oRowSet:goTop()

   while !( ::oLineasController:oRowSet:Eof() )

      hset( hStock, "codigo_articulo", AllTrim( ::oLineasController:oRowSet:fieldget( 'codigo_articulo' ) ) )
      hset( hStock, "codigo_almacen_entrada", AllTrim( ::oModel:hBuffer[ "almacen_destino" ] ) )
      hset( hStock, "codigo_almacen_salida", AllTrim( ::oModel:hBuffer[ "almacen_origen" ] ) )
      hset( hStock, "codigo_primera_propiedad", AllTrim( ::oLineasController:oRowSet:fieldget( 'codigo_primera_propiedad' ) ) )
      hset( hStock, "valor_primera_propiedad", AllTrim( ::oLineasController:oRowSet:fieldget( 'valor_primera_propiedad' ) ) )
      hset( hStock, "codigo_segunda_propiedad", AllTrim( ::oLineasController:oRowSet:fieldget( 'codigo_segunda_propiedad' ) ) )
      hset( hStock, "valor_segunda_propiedad", AllTrim( ::oLineasController:oRowSet:fieldget( 'valor_segunda_propiedad' ) ) )
      hset( hStock, "lote", AllTrim( ::oLineasController:oRowSet:fieldget( 'lote' ) ) )
      hset( hStock, "bultos_articulo", ::oLineasController:oRowSet:fieldget( 'bultos_articulo' ) )
      hset( hStock, "cajas_articulo", ::oLineasController:oRowSet:fieldget( 'cajas_articulo' ) )
      hset( hStock, "unidades_articulo", ( NotCaja( ::oLineasController:oRowSet:fieldget( 'cajas_articulo' ) ) * ::oLineasController:oRowSet:fieldget( 'unidades_articulo' ) ) )
      hset( hStock, "fecha", hb_ttod( ::oModel:hBuffer[ "fecha_hora" ] ) )
      hset( hStock, "hora", substr( hb_tstostr( ::oModel:hBuffer[ "fecha_hora" ] ), 12, 8 ) )

      hStock      := {=>}
      
      ::oLineasController:oRowSet:skip()

   end while

RETURN ( Self )

//---------------------------------------------------------------------------//