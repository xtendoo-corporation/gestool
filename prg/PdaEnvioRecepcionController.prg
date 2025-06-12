// TODO 
// - Establecer contador al agregar el ticket (done)
// - Crear el pago (done)
// - Controlar que el uuid ya haya sido añadido (done)
// - Eliminar los ficheros q se vayan integrando
// - Escribir un log por pantalla (done)

#include "FiveWin.Ch"
#include "Directry.ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS PdaEnvioRecepcionController   

   CLASSDATA oInstance

   DATA nSeconds

   DATA oTimer

   DATA oMsgAlarm

   DATA oDialogView

   DATA aJson

   DATA cPath

   DATA hTicketHeader

   DATA cSerieTicket       INIT "A"

   DATA cNumeroTicket   

   DATA cSufijoTicket      INIT retSufEmp()

   DATA dFechaTicket    

   DATA cHoraTicket     

   DATA nDescuentoTicket

   DATA cFormaPago

   DATA cAlmacenTicket  

   DATA lPrintTicket       INIT .f.

   DATA lProcesing         INIT .f.

   DATA nTotalTicket
   
   DATA hTicketHeader  
   
   DATA aTicketLines 

   DATA hTicketPay

   METHOD New()
   METHOD End()

   METHOD getInstance()                INLINE ( iif( empty( ::oInstance ), ::oInstance := ::New(), ),;
                                                ::oInstance ) 
   METHOD rebuildInstance()            INLINE ( iif( !empty( ::oInstance ), ( ::oInstance:end(), ::oInstance := nil ), ),;
                                                ::getInstance() ) 

   METHOD stopTimer()
   METHOD activateTimer()

   METHOD Activate()

   METHOD exportJson()
      METHOD exportArticulosJson()
      METHOD buildArticuloJson()

      METHOD exportUsuariosJson()   
      METHOD buildUsuariosJson()

      METHOD writeJsonFile( cFileName )
      METHOD writeArticulosJson()      INLINE ( ::writeJsonFile( "articulos.json" ) )
      METHOD writeUsuariosJson()       INLINE ( ::writeJsonFile( "usuarios.json" ) )

   METHOD cFileIn( cFileName )         INLINE ( cPath( ::cPath ) + "in\" + cFileName )
   METHOD cFileOut( cFileName )        INLINE ( cPath( ::cPath ) + "out\" + cFileName )
   METHOD cFileProcessed( cFileName )  INLINE ( cPath( ::cPath ) + "processed\" + cFileName )
   
   METHOD importJson()
      METHOD importJsonFile( cFileName )
      METHOD isJsonProcessed( hJson )
      METHOD moveFileToProcessed( cFileName )

      METHOD getTicketCount()
      METHOD setTicketCount()

      METHOD buildTicketHeaderHash( hJson )
      METHOD buildTicketPayHash( hJson )
      METHOD buildTicketLinesHash( hJson )
         METHOD buildTicketLineHash( hLine )

      METHOD createTicket( hJson )
      METHOD createTicketLines()    
         METHOD createTicketLine( hLine )  
      METHOD createTicketPay()

      METHOD printTicket()

   METHOD setTotalProgress( nTotal )   INLINE ( iif(  !empty( ::oDialogView:oProgress ),;
                                                      ::oDialogView:oProgress:setTotal( nTotal ), ) )

   METHOD autoIncProgress()            INLINE ( iif(  !empty( ::oDialogView:oProgress ),;
                                                      ::oDialogView:oProgress:autoInc(), ) )

   METHOD deleteTreeLog( cText )       INLINE ( iif(  !empty( ::oDialogView:oTreeLog ),;
                                                      ::oDialogView:oTreeLog:deleteAll(), ) )

   METHOD addTreeLog( cText )          INLINE ( iif(  !empty( ::oDialogView:oTreeLog ),;
                                                      ::oDialogView:oTreeLog:Select( ::oDialogView:oTreeLog:Add( cText ) ), ) )

   METHOD clearPath()

   METHOD setAlarmoMsgBar()

   METHOD CheckDirectories()

   METHOD nCalculateTotal()

END CLASS

//---------------------------------------------------------------------------//

METHOD New()

   ::cPath                 := ConfiguracionesEmpresaModel():getValue( 'pda_ruta', '' )

   if !Empty( ::cPath )
      ::CheckDirectories()
   end if

   ::nSeconds              := ConfiguracionesEmpresaModel():getNumeric( 'pda_recoger_ventas', 0 )

   if !empty( ::nSeconds )
      
      ::oTimer             := TTimer():New( ::nSeconds * 1000, {|| ::importJson() }, ) 
      ::oTimer:hWndOwner   := GetActiveWindow()
      
      ::setAlarmoMsgBar()

   end if 

   ::oDialogView           := PdaEnvioRecepcionView():New( Self )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD End()

   if !empty( ::oTimer )
      ::oTimer:end()
   end if 

   ::oTimer                := nil

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD Activate()

   ::stopTimer()

   ::oDialogView:Activate()

   ::activateTimer()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD exportJson()

   ::addTreeLog( "Iniciando el proceso de exportación" )

   ::exportArticulosJson()

   ::exportUsuariosJson()

   ::addTreeLog( "Proceso de exportación finalizado" )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD exportArticulosJson() 

   local cArea    := "ArtJson"

   ::aJson        := {}

   ::addTreeLog( "Exportando articulos a json" )

   ArticulosModel():getArticulosToJson( @cArea )

   ::setTotalProgress( ( cArea )->( lastrec() ) )

   ( cArea )->( dbgotop() )

   while !( cArea )->( eof() )

      aadd( ::aJson, ::buildArticuloJson( cArea ) )

      ::autoIncProgress()

      ( cArea )->( dbskip() )

   end while

   CLOSE ( cArea )

   ::writeArticulosJson()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD buildArticuloJson( cArea )

   local hJson    := {=>}
   local aCodebar := {}

   hset( hJson, "id",                           alltrim( ( cArea )->Codigo ) )
   hset( hJson, "nombre",                       alltrim( hb_oemtoansi( ( cArea )->Nombre ) ) )
   hset( hJson, "uuid",                         alltrim( ( cArea )->uuid ) )
   hset( hJson, "precio_venta",                 ( cArea )->pVenta1 )
   hset( hJson, "porcentaje_iva",               ( cArea )->tpIva )
   hset( hJson, "precio_impuestos_incluidos",   ( cArea )->pVtaIva1 )

   aadd( aCodebar, alltrim( ( cArea )->Codigo ) )

   if !empty( ( cArea )->cCodBar )
      aadd( aCodebar, alltrim( ( cArea )->cCodBar ) )
   end if 

   hset( hJson, "codigos_barras", aCodebar )

RETURN ( hJson )   

//---------------------------------------------------------------------------//

METHOD exportUsuariosJson() 

   local aUsuarios   := {}

   ::aJson           := {}

   ::addTreeLog( "Exportando usuarios a json" )

   aUsuarios         := UsuariosModel():getUsuariosToJson()

   ::setTotalProgress( len( aUsuarios ) )

   aeval( aUsuarios, {|a| aAdd( ::aJson, ::buildUsuariosJson( a ) ), ::autoIncProgress() } )

   ::writeUsuariosJson()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD buildUsuariosJson( aUsuario )

   local hJson    := {=>}

   hset( hJson, "id",      alltrim( aUsuario[1] ) )
   hset( hJson, "nombre",  alltrim( aUsuario[2] ) )

RETURN ( hJson )   

//---------------------------------------------------------------------------//

METHOD writeJsonFile( cFileName )

   local cFile
   local cJson

   cJson          := hb_jsonencode( ::aJson, .t. )

   cFile          := cPath( ::cPath ) + "in\" + cFileName

   ::addTreeLog( "Exportando fichero json " + alltrim( cFile ) )

   if !( memowrit( cFile, cJson ) ) 
      msgStop( "Error al escribir el fichero " + alltrim( cFile ), "Error" )
   end if 

RETURN ( Self ) 

//---------------------------------------------------------------------------//

METHOD importJson()

   local aDirectory

   if ::lProcesing
      RETURN ( nil )
   end if 

   ::lProcesing   := .t.

   aDirectory     := directory( cPath( ::cPath ) + "out\*.*" )

   ::setTotalProgress( len( aDirectory ) )

   ::deleteTreeLog()

   ::addTreeLog( "Inicio proceso importación" )  

   if !empty( aDirectory )
      aeval( aDirectory, {|cFileName| ::importJsonFile( cFileName[ F_NAME ] ) } )
   end if 

   ::addTreeLog( "Proceso importación finalizado" )  
   
   ::lProcesing   := .f.

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD importJsonFile( cFileName )

   local hJson

   if At( "inventory", cFileName ) != 0
      ::addTreeLog( "Excluido : " + cFileName )
      RETURN ( Self )
   end if

   ::addTreeLog( "Directorio de trabajo : " + cPath( ::cPath ) )

   ::autoIncProgress()

   ::addTreeLog( "Procesando : " + cFileName )

   hb_jsondecode( memoread( cPath( ::cPath ) + "out\" + cFileName ), @hJson )

   if ::isJsonProcessed( hJson )
      ::moveFileToProcessed( cFileName )
   end if 

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD isJsonProcessed( hJson )

   if !hb_ishash( hJson )
      RETURN ( .f. )
   end if 
   
   ::nTotalTicket          := 0
   
   ::hTicketHeader         := {=>}
   
   ::aTicketLines          := {}

   ::cNumeroTicket         := ::getTicketCount()

   ::dFechaTicket          := ctod( substr( hget( hJson, "fecha_hora" ), 1, 10 ) ) 

   ::cHoraTicket           := substr( hget( hJson, "fecha_hora" ), 12, 5 ) 

   if hhaskey( hJson, "descuento" )
      ::nDescuentoTicket   := Round( hget( hJson, "descuento" ), 2 )
   else
      ::nDescuentoTicket   := 0
   end if

   if hhaskey( hJson, "fpago" )
      ::cFormaPago         := hget( hJson, "fpago" )
   else
      ::cFormaPago         := "00"
   end if

   ::cAlmacenTicket  := Application():codigoAlmacen() 

   ::buildTicketLinesHash( hJson )

   ::buildTicketHeaderHash( hJson )

   ::buildTicketPayHash( hJson )

   if ::createTicket()

      ::setTicketCount()

      ::createTicketLines()

      ::createTicketPay()

      ::printTicket()

      RETURN ( .t. )

   end if

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD getTicketCount()

   local nNumTik     := ContadoresModel():getNumeroTicket( ::cSerieTicket )

   while TicketsClientesModel():existId( ::cSerieTicket, nNumTik, ::cSufijoTicket )
      nNumTik++
   end while

RETURN ( padl( str( nNumTik ), 10 ) )

//---------------------------------------------------------------------------//

METHOD setTicketCount()

RETURN ( ContadoresModel():setNumeroTicket( ::cSerieTicket, val( ::cNumeroTicket ) + 1 ) )

//---------------------------------------------------------------------------//

METHOD nCalculateTotal()

   local nTotal   := 0

   nTotal         := ::nTotalTicket

   nTotal         -= ( ( ::nTotalTicket * ::nDescuentoTicket ) / 100 )

RETURN nTotal

//---------------------------------------------------------------------------//

METHOD buildTicketHeaderHash( hJson )

   ::addTreeLog( "Contruyendo cabecera de ticket" )

   hset( ::hTicketHeader, "cSerTik", ::cSerieTicket )
   hset( ::hTicketHeader, "cNumTik", ::cNumeroTicket )
   hset( ::hTicketHeader, "cSufTik", ::cSufijoTicket )
   
   hset( ::hTicketHeader, "cTurTik", cShortSesion() )
   hset( ::hTicketHeader, "cTipTik", "1" )

   hset( ::hTicketHeader, "dFecTik", ::dFechaTicket )
   hset( ::hTicketHeader, "cHorTik", ::cHoraTicket )
   hset( ::hTicketHeader, "cAlmTik", ::cAlmacenTicket )

   hset( ::hTicketHeader, "cCcjTik", hget( hJson, "usuario" ) )
   hset( ::hTicketHeader, "cNcjTik", Application():CodigoCaja() )

   hset( ::hTicketHeader, "cCliTik", cDefCli() )
   hset( ::hTicketHeader, "cNomTik", ClientesModel():getNombre( cDefCli() ) )
   hset( ::hTicketHeader, "nTarifa", max( uFieldEmpresa( "nPreVta" ), 1 ) )
   if Empty( ::cFormaPago )
      hset( ::hTicketHeader, "cFpgTik", cDefFpg() )
   else 
      hset( ::hTicketHeader, "cFpgTik", ::cFormaPago )
   end if
   hset( ::hTicketHeader, "cDivTik", cDivEmp() )
   hset( ::hTicketHeader, "nVdvTik", 1 )
   hset( ::hTicketHeader, "lPgdTik", .t. )
   hset( ::hTicketHeader, "lSndDoc", .t. )
   hset( ::hTicketHeader, "dFecCre", date() )
   hset( ::hTicketHeader, "cTimCre", substr( time(), 1, 5 ) )
   //hset( ::hTicketHeader, "nTotTik", ::nTotalTicket )
   //hset( ::hTicketHeader, "nCobTik", ::nTotalTicket )

   hset( ::hTicketHeader, "nTotTik", ::nCalculateTotal() )
   hset( ::hTicketHeader, "nCobTik", ::nCalculateTotal() )

   hset( ::hTicketHeader, "uuid",    hget( hJson, "uuid" ) )

   if hhaskey( hJson, "descuento" )   
      hset( ::hTicketHeader, "cDtoEsp", "General" )
      hset( ::hTicketHeader, "nDtoEsp", ::nDescuentoTicket )
   end if

   ::lPrintTicket       := hget( hJson, "imprimir" )

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD buildTicketLinesHash( hJson )

   ::addTreeLog( "Contruyendo líneas de ticket" )

RETURN ( aeval( hget( hJson, "lineas" ), {|hLine| ::buildTicketLineHash( hLine ) } ) )

//---------------------------------------------------------------------------//

METHOD buildTicketLineHash( hLine )
   
   local hArticulo 
   local idArticulo
   local hTicketLine 

   hTicketLine       := {=>}
   idArticulo        := cvaltochar( hget( hLine, "id_articulo" ) ) 
   hArticulo         := ArticulosModel():getHash( idArticulo )

   hset( hTicketLine, "cSerTil", ::cSerieTicket )
   hset( hTicketLine, "cNumTil", ::cNumeroTicket )
   hset( hTicketLine, "cSufTil", ::cSufijoTicket )
   
   hset( hTicketLine, "cTipTil", "1" )

   hset( hTicketLine, "dFecTik", ::dFechaTicket )
   hset( hTicketLine, "tFecTik", ::cHoraTicket )
   hset( hTicketLine, "cAlmLin", ::cAlmacenTicket )

   hset( hTicketLine, "cCbaTil", idArticulo )
   hset( hTicketLine, "nUntTil", hget( hLine, "unidades" ) )
   hset( hTicketLine, "nPvpTil", hget( hLine, "precio" ) / hget( hLine, "unidades" ) )
   hset( hTicketLine, "uuid",    hget( hLine, "uuid" ) )

   if !empty( hArticulo )
      hset( hTicketLine, "cNomTil", alltrim( hget( hArticulo, "nombre" ) ) )
      hset( hTicketLine, "cFamTil", alltrim( hget( hArticulo, "familia" ) ) )
      hset( hTicketLine, "nCosTil", hget( hArticulo, "pcosto" ) )
      hset( hTicketLine, "nCtlStk", hget( hArticulo, "nctlstock" ) )
      hset( hTicketLine, "nIvaTil", TiposIvaModel():getIva( hget( hArticulo, "tipoiva" ) ) )
      hset( hTicketLine, "cCodFam", alltrim( hget( hArticulo, "familia" ) ) )
      hset( hTicketLine, "cGrpFam", FamiliasModel():getGrupo( hget( hArticulo, "familia" ) ) )
   end if 

   aadd( ::aTicketLines, hTicketLine )

   ::nTotalTicket    += hget( hLine, "precio" )

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD buildTicketPayHash( hJson )
   
   ::hTicketPay      := {=>}

   hset( ::hTicketPay, "cSerTik", ::cSerieTicket )
   hset( ::hTicketPay, "cNumTik", ::cNumeroTicket )
   hset( ::hTicketPay, "cSufTik", ::cSufijoTicket )
   hset( ::hTicketPay, "cCodCaj", Application():CodigoCaja() )
   hset( ::hTicketPay, "dPgoTik", ctod( substr( hget( hJson, "fecha_hora" ), 1, 10 ) ) )
   hset( ::hTicketPay, "cTimTik", substr( hget( hJson, "fecha_hora" ), 12, 5 ) )
   if Empty( ::cFormaPago )
      hset( ::hTicketPay, "cFpgPgo", cDefFpg() )
   else 
      hset( ::hTicketPay, "cFpgPgo", ::cFormaPago )
   end if
   hset( ::hTicketPay, "nImpTik", ::nCalculateTotal() )
   hset( ::hTicketPay, "cDivPgo", cDivEmp() )
   hset( ::hTicketPay, "nVdvPgo", 1 )
   hset( ::hTicketPay, "lSndPgo", .t. )
   hset( ::hTicketPay, "cTurPgo", cShortSesion() )

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD createTicket()

   ::addTreeLog( "Creando ticket" )

   if TicketsClientesModel():existUuid( hget( ::hTicketHeader, "uuid" ) )
      ::addTreeLog( "Ticket ya importado : " + hget( ::hTicketHeader, "uuid" ) ) 
      RETURN ( .f. )
   end if 

   TicketsClientesModel():createFromHash( ::hTicketHeader )

   ::addTreeLog( "Ticket creado : " + hget( ::hTicketHeader, "cSerTik" ) + "/" + alltrim( hget( ::hTicketHeader, "cNumTik" ) ) + "/" + hget( ::hTicketHeader, "cSufTik" ) ) 

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD createTicketLines()

   ::addTreeLog( "Creando lineas de ticket" )

   aeval( ::aTicketLines, {| hLine | ::createTicketLine( hLine ) } )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD createTicketLine( hLine )

   TicketsClientesLineasModel():createFromHash( hLine ) 

   ::addTreeLog( "Línea ticket creado : " + hget( hLine, "cCbaTil" ) + " - " + cvaltochar( hget( hLine, "nUntTil" ) ) + " - " + cvaltochar( hget( hLine, "nPvpTil" ) ) ) 

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD createTicketPay()

   TicketsClientesPagosModel():createFromHash( ::hTicketPay ) 

   ::addTreeLog( "Pago ticket creado : " + hget( ::hTicketPay, "cSerTik" ) + "/" + alltrim( hget( ::hTicketPay, "cNumTik" ) ) + "/" + hget( ::hTicketPay, "cSufTik" ) ) 

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD moveFileToProcessed( cFileName )

   if copyfile( ::cFileOut( cFileName ), ::cFileProcessed( cFileName ) )
      ferase( ::cFileOut( cFileName ) )
   end if 

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD printTicket()

   if ::lPrintTicket
      
      prnTikCli( ::cSerieTicket + ::cNumeroTicket + ::cSufijoTicket )

   end if 

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD activateTimer()

   ::stopTimer()

   if !empty( ::oTimer )
      ::oTimer:Activate()
   end if 

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD stopTimer()

   if !empty( ::oTimer )
      ::oTimer:deactivate()
   endif

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD clearPath()

   local aDirectory

   aDirectory        := directory( cPath( ::cPath ) + "*.*" )

   if !empty( aDirectory )
      aeval( aDirectory, {|cFileName| ferase( cPath( ::cPath ) + "\" + cFileName[ F_NAME ] ) } )
   end if

   aDirectory        := directory( cPath( ::cPath ) + "out\*.*" )

   if !empty( aDirectory )
      aeval( aDirectory, {|cFileName| ferase( cPath( ::cPath ) + "out\" + cFileName[ F_NAME ] ) } )
   end if

   aDirectory        := directory( cPath( ::cPath ) + "in\*.*" )

   if !empty( aDirectory )
      aeval( aDirectory, {|cFileName| ferase( cPath( ::cPath ) + "in\" + cFileName[ F_NAME ] ) } )
   end if

   /*aDirectory        := directory( cPath( ::cPath ) + "processed\*.*" )

   if !empty( aDirectory )
      aeval( aDirectory, {|cFileName| ferase( cPath( ::cPath ) + "processed\" + cFileName[ F_NAME ] ) } )
   end if*/

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD setAlarmoMsgBar()
   
   if Empty( ::oMsgAlarm )
      ::oMsgAlarm         := TMsgItem():New( oWnd():oMsgBar,,24,,,,.t.,,"gc_pda_16",, "Timmer pda activado" )
      ::oMsgAlarm:bAction := {|| nil }
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD CheckDirectories()

   if !lIsDir( cPath( ::cPath ) + "in" )
      makedir( cNamePath( cPath( ::cPath ) + "in\" ) )
   end if

   if !lIsDir( cPath( ::cPath ) + "out\" )
      makedir( cNamePath( cPath( ::cPath ) + "out\" ) )
   end if

   if !lIsDir( cPath( ::cPath ) + "processed\" )
      makedir( cNamePath( cPath( ::cPath ) + "processed\" ) )
   end if

Return ( nil )

//---------------------------------------------------------------------------//