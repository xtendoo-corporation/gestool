#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS SenderReciverController FROM TSenderReciverItem

   DATA oController

   DATA aUuidParent           INIT {}

   METHOD New()

   METHOD End()               INLINE ( Self )

   METHOD CreateData()

   METHOD RestoreData()

   METHOD SendData()

   METHOD ReciveData()

   METHOD Process()

   METHOD cTitle( )           INLINE ( lower( ::oController:cTitle ) )

   METHOD ProcesaCabecera( cFile )
   METHOD ProcesaLineas( cFileLine )

   METHOD ActualizaStock( hBuffer )
   METHOD RollbackStock( hBuffer )

END CLASS

//---------------------------------------------------------------------------//

METHOD New( oController ) CLASS SenderReciverController
   
   ::oController                 := oController

   ::super:new( ::oController:cTitle )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD CreateData() CLASS SenderReciverController

   local lSnd        := .t.
   local cFileName
   local cFile
   local cJson

   if ::oSender:lServer

      cFileName      := ::oController:cOldName + StrZero( ::nGetNumberToSend(), 6 ) + ".All"

      /*
      Cabeceras----------------------------------------------------------------
      */

      ::oSender:SetText( "Enviando " + ::cTitle() )
      
      cJson          := ::oController:oModel:getListToSend() 
      ::aUuidParent  := ::oController:oModel:getListUuidsToSend()

      cFile          := cPatSnd() + ::oController:cName + ".json"

      ::oSender:SetText( "Exportando fichero json " + alltrim( cFile ) )

      if !MemoWrit( cFile, cJson )
         lSnd        := .f.
         ::oSender:SetText( "Error al escribir el fichero " + alltrim( cFile ) )
      end if

      /*
      Lineas----------------------------------------------------------------
      */

      if !Empty( ::oController:oLineasController ) .and. len( ::aUuidParent ) > 0

         ::oSender:SetText( "Enviando " + lower( ::oController:oLineasController:cTitle ) )
      
         cJson          := ::oController:oLineasController:oModel:getListToSend( ::aUuidParent )

         cFile          := cPatSnd() + ::oController:oLineasController:cName + ".json"

         ::oSender:SetText( "Exportando fichero json " + alltrim( cFile ) )

         if !MemoWrit( cFile, cJson )
            lSnd        := .f.
            ::oSender:SetText( "Error al escribir el fichero " + alltrim( cFile ) )
         end if

      end if

      /*
      Comprimimos los ficheros creados-----------------------------------------
      */

      if lSnd

         ::oSender:SetText( "Comprimiendo " + ::cTitle() )

         if ::oSender:lZipData( cFileName )
            ::oSender:SetText( "Ficheros comprimidos en " + Rtrim( cFileName ) )
         else
            ::oSender:SetText( "ERROR al crear fichero comprimido" )
         end if

      else

         ::oSender:SetText( "No hay " + ::cTitle() + " para enviar" )

      end if

   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD SendData() CLASS SenderReciverController

   local cFileName

   if ::oSender:lServer
      cFileName         := ::oController:cOldName + StrZero( ::nGetNumberToSend(), 6 ) + ".All"
   else
      cFileName         := ::oController:cOldName + StrZero( ::nGetNumberToSend(), 6 ) + "." + RetSufEmp()
   end if

   /*
   Enviarlos a internet--------------------------------------------------------
   */

   if !file( cPatOut() + cFileName )
      ::oSender:SetText( "El fichero " + cPatOut() + cFileName + " no existe" )
      RETURN ( Self )
   end if 

   if ::oSender:SendFiles( cPatOut() + cFileName, cFileName )
      ::IncNumberToSend()
      ::lSuccesfullSend := .t.
      ::oSender:SetText( "Fichero enviado " + cFileName )
   else
      ::oSender:SetText( "ERROR al enviar fichero" + cFileName )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD RestoreData() CLASS SenderReciverController

   if len( ::aUuidParent ) > 0
      ::oController:oModel:updateMarcaEnvio( ::aUuidParent )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ReciveData() CLASS SenderReciverController

   local n
   local aExt

   aExt     := ::oSender:aExtensions()

   /*
   Recibirlo de internet
   */

   ::oSender:SetText( "Recibiendo " + ::cTitle() )

   for n := 1 to len( aExt )
      ::oSender:GetFiles( ::oController:cOldName + "*." + aExt[ n ], cPatIn() )
   next

   ::oSender:SetText( ::oController:cTitle + " recibidos" )
   
RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Process() CLASS SenderReciverController

   local m
   local oError
   local oBlock
   local aFiles            := directory( cPatIn() + ::oController:cOldName + "*.*" )
   local cFile             := cPatSnd() + ::oController:cName + ".json"
   local cFileLine         := cPatSnd() + ::oController:oLineasController:cName + ".json"

   for m := 1 to len( aFiles )

      ::oSender:SetText( "Procesando fichero : " + aFiles[ m, 1 ] )

      oBlock               := ErrorBlock( { | oError | ApoloBreak( oError ) } )
      BEGIN SEQUENCE

         if ::oSender:lUnZipData( cPatIn() + aFiles[ m, 1 ], .f. )

            if File( cFile ) .and. File( cFileLine )

               ::ProcesaCabecera( cFile )

               ::ProcesaLineas( cFileLine )

               ::oSender:appendFileRecive( aFiles[ m, 1 ] )

            else

               ::oSender:SetText( "Faltan ficheros json para poder importar" )

            end if

         else

            ::oSender:SetText( "Error al descomprimir los ficheros" )

         end if

      RECOVER USING oError

         ::oSender:SetText( "Error procesando fichero " + aFiles[ m, 1 ] )
         ::oSender:SetText( ErrorMessage( oError ) )

      END SEQUENCE
      ErrorBlock( oBlock )

   next

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ProcesaCabecera( cFile )

   local cJson
   local aJson
   local hBuffer

   cJson             := memoread( cFile )

   if empty( cJson )
      ::oSender:SetText( "Error procesando fichero " + cFile )
      RETURN ( self )
   end if 

   hb_jsondecode( cJson, @aJson )

   if !hb_isarray( aJson )
      RETURN ( .f. )
   end if 

   for each hBuffer in aJson

      if AllTrim( Application():codigoAlmacen() ) != AllTrim( hGet( hBuffer, "almacen_destino" ) ) .and. AllTrim( Application():codigoAlmacen() ) != AllTrim( hGet( hBuffer, "almacen_origen" ) )

         ::oSender:SetText( "Movimiento nº " + AllTrim( hGet( hBuffer, "numero" ) ) + " desestimado por no coincidir el almacén " + cFile )

      else

         ::oController:oModel:InSertOrUpdateFromUuid( ::oController:oModel:prepareFromInsertBuffer( hBuffer ) )

      end if

   next

RETURN ( Self )
   
//---------------------------------------------------------------------------//

METHOD ProcesaLineas( cFileLine )

   local cJson
   local aJson
   local hBuffer

   cJson             := memoread( cFileLine )

   if empty( cJson )
      ::oSender:SetText( "Error procesando fichero " + cFileLine )
      RETURN ( self )
   end if 

   hb_jsondecode( cJson, @aJson )

   if !hb_isarray( aJson )
      RETURN ( .f. )
   end if 

   for each hBuffer in aJson

      if ::oController:oModel:existeUuid( hGet( hBuffer, "parent_uuid" ) )

         ::RollbackStock( hBuffer )
      
         ::oController:oLineasController:oModel:InsertOrUpdateFromUuid( ::oController:oLineasController:oModel:prepareFromInsertBuffer( hBuffer ) )

         ::ActualizaStock( hBuffer )

      end if

   next

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD RollbackStock( hBuffer )

   local hStockBuffer   := {=>}
   local hParent        := {=>}
   local hLine          := {=>}

   if !::oController:oLineasController:oModel:existeUuid( hGet( hBuffer, "uuid" ) )
      Return( self )
   end if

   hParent              := ::oController:oModel:getWhereUuid( hBuffer[ "parent_uuid" ] )
   hLine                := ::oController:oLineasController:oModel:getWhereUuid( hBuffer[ "uuid" ] )

   hset( hStockBuffer, "codigo_articulo", AllTrim( hLine[ "codigo_articulo" ] ) )
   hset( hStockBuffer, "codigo_almacen_entrada", AllTrim( hParent[ "almacen_destino" ] ) )
   hset( hStockBuffer, "codigo_almacen_salida", AllTrim( hParent[ "almacen_origen" ] ) )
   hset( hStockBuffer, "codigo_primera_propiedad", AllTrim( hLine[ "codigo_primera_propiedad" ] ) )
   hset( hStockBuffer, "valor_primera_propiedad", AllTrim( hLine[ "valor_primera_propiedad" ] ) )
   hset( hStockBuffer, "codigo_segunda_propiedad", AllTrim( hLine[ "codigo_segunda_propiedad" ] ) )
   hset( hStockBuffer, "valor_segunda_propiedad", AllTrim( hLine[ "valor_segunda_propiedad" ] ) )
   hset( hStockBuffer, "lote", AllTrim( hLine[ "lote" ] ) )
   hset( hStockBuffer, "bultos_articulo", hLine[ "bultos_articulo" ] )
   hset( hStockBuffer, "cajas_articulo", hLine[ "cajas_articulo" ] )
   hset( hStockBuffer, "unidades_articulo", ( NotCaja( hLine[ "cajas_articulo" ] ) * hLine[ "unidades_articulo" ] ) )
   hset( hStockBuffer, "fecha", hb_ttod( hParent[ "fecha_hora" ] ) )
   hset( hStockBuffer, "hora", substr( hb_tstostr( hParent[ "fecha_hora" ] ), 12, 8 ) )
   hset( hStockBuffer, "tipo_movimiento", hParent[ "tipo_movimiento" ] )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ActualizaStock( hBuffer )

   local hStockBuffer   := {=>}
   local hParent        := ::oController:oModel:getWhereUuid( hBuffer[ "parent_uuid" ] )

   hset( hStockBuffer, "codigo_articulo", AllTrim( hBuffer[ "codigo_articulo" ] ) )
   hset( hStockBuffer, "codigo_almacen_entrada", AllTrim( hParent[ "almacen_destino" ] ) )
   hset( hStockBuffer, "codigo_almacen_salida", AllTrim( hParent[ "almacen_origen" ] ) )
   hset( hStockBuffer, "codigo_primera_propiedad", AllTrim( hBuffer[ "codigo_primera_propiedad" ] ) )
   hset( hStockBuffer, "valor_primera_propiedad", AllTrim( hBuffer[ "valor_primera_propiedad" ] ) )
   hset( hStockBuffer, "codigo_segunda_propiedad", AllTrim( hBuffer[ "codigo_segunda_propiedad" ] ) )
   hset( hStockBuffer, "valor_segunda_propiedad", AllTrim( hBuffer[ "valor_segunda_propiedad" ] ) )
   hset( hStockBuffer, "lote", AllTrim( hBuffer[ "lote" ] ) )
   hset( hStockBuffer, "bultos_articulo", hBuffer[ "bultos_articulo" ] )
   hset( hStockBuffer, "cajas_articulo", hBuffer[ "cajas_articulo" ] )
   hset( hStockBuffer, "unidades_articulo", ( NotCaja( hBuffer[ "cajas_articulo" ] ) * hBuffer[ "unidades_articulo" ] ) )
   hset( hStockBuffer, "fecha", hb_ttod( hParent[ "fecha_hora" ] ) )
   hset( hStockBuffer, "hora", substr( hb_tstostr( hParent[ "fecha_hora" ] ), 12, 8 ) )
   hset( hStockBuffer, "tipo_movimiento", hParent[ "tipo_movimiento" ] )

RETURN ( Self )

//---------------------------------------------------------------------------//