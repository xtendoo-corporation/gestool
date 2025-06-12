#include "fivewin.ch"
#include "factu.ch" 
#include "hdo.ch"

//---------------------------------------------------------------------------//

CLASS SQLMovimientosAlmacenLineasModel FROM SQLExportableModel

   DATA cTableName            INIT  "movimientos_almacen_lineas"

   DATA cTableTemporal        

   DATA cConstraints          INIT  "PRIMARY KEY ( id ), "                       + ; 
                                       "KEY ( uuid ), "                          + ;
                                       "KEY ( parent_uuid ), "                   + ;
                                       "KEY ( codigo_articulo ), "               + ;
                                       "KEY stock ( codigo_articulo,codigo_primera_propiedad,valor_primera_propiedad,codigo_segunda_propiedad,valor_segunda_propiedad,lote ) "

   METHOD getColumns()

   METHOD getInitialSelect()

   METHOD getInsertSentence()

   METHOD addInsertSentence()

   METHOD addUpdateSentence()
   
   METHOD addDeleteSentence()

   METHOD addDeleteSentenceById()

   METHOD deleteWhereUuid( uuid )

   METHOD aUuidToDelete( uuid )

   METHOD getDeleteSentenceFromParentsUuid()

   METHOD getSQLSubSentenceTotalUnidadesLinea( cTable, cAs )

   METHOD getSQLSubSentenceTotalPrecioLinea( cTable, cAs )

   METHOD getSQLSubSentenceTotalVentaLinea( cTable, cAs )

   METHOD getSQLSubSentenceTotalIva( cTable, cAs )

   METHOD getSQLSubSentenceSumatorioUnidadesLinea( cTable, cAs )

   METHOD getSQLSubSentenceSumatorioTotalPrecioLinea( cTable, cAs )

   METHOD getSQLSumatorioTotalVentaLinea( cTable, cAs )

   METHOD getSentenceNotSent( aFetch )

   METHOD getIdProductAdded()

   METHOD getUpdateUnitsSentece()

   METHOD createTemporalTableWhereUuid( id )

   METHOD alterTemporalTableWhereUuid()

   METHOD replaceUuidInTemporalTable( duplicatedUuid )

   METHOD insertTemporalTable()

   METHOD dropTemporalTable()

   METHOD duplicateByUuid( id, duplicatedUuid )

   METHOD getListToSend()

   METHOD prepareFromInsertBuffer( hBuffer )

   METHOD updatePrecioVenta( uuid, nNewPrice )

   METHOD getLinesFromStock( cCodigoArticulo, dFechaInicio, dFechaFin, cCodigoAlmacen )

   METHOD ValidaDocumentos()

   METHOD exist( uuid )

   METHOD SeederToADS()

END CLASS

//---------------------------------------------------------------------------//

METHOD getColumns()

   hset( ::hColumns, "id",                         {  "create"    => "INTEGER AUTO_INCREMENT"         ,;
                                                      "default"   => {|| 0 } }                        )

   hset( ::hColumns, "uuid",                       {  "create"    => "VARCHAR(40) NOT NULL UNIQUE"    ,;
                                                      "default"   => {|| win_uuidcreatestring() } }   )

   hset( ::hColumns, "parent_uuid",                {  "create"    => "VARCHAR(40) NOT NULL"           ,;
                                                      "default"   => {|| space(40) } }                )

   hset( ::hColumns, "codigo_articulo",            {  "create"    => "VARCHAR(18) NOT NULL"           ,;
                                                      "default"   => {|| space(18) } }                )

   hset( ::hColumns, "nombre_articulo",            {  "create"    => "VARCHAR(250) NOT NULL"          ,;
                                                      "default"   => {|| space(250) } }               )

   hset( ::hColumns, "codigo_primera_propiedad",   {  "create"    => "VARCHAR(20)"                    ,;
                                                      "default"   => {|| space(20) } }                )

   hset( ::hColumns, "valor_primera_propiedad",    {  "create"    => "VARCHAR(200)"                   ,;
                                                      "default"   => {|| space(200) } }               )

   hset( ::hColumns, "codigo_segunda_propiedad",   {  "create"    => "VARCHAR(20)"                    ,;
                                                      "default"   => {|| space(20) } }                )

   hset( ::hColumns, "valor_segunda_propiedad",    {  "create"    => "VARCHAR(200)"                   ,;
                                                      "default"   => {|| space(200) } }               )

   hset( ::hColumns, "fecha_caducidad",            {  "create"    => "DATE"                           ,;
                                                      "default"   => {|| ctod('') } }                 )

   hset( ::hColumns, "lote",                       {  "create"    => "VARCHAR(40)"                    ,;
                                                      "default"   => {|| space(40) } }                )

   hset( ::hColumns, "bultos_articulo",            {  "create"    => "DECIMAL(19,6)"                  ,;
                                                      "default"   => {|| 0 } }                        )

   hset( ::hColumns, "cajas_articulo",             {  "create"    => "DECIMAL(19,6)"                  ,;
                                                      "default"   => {|| 0 } }                        )

   hset( ::hColumns, "unidades_articulo",          {  "create"    => "DECIMAL(19,6)"                  ,;
                                                      "default"   => {|| 1 } }                        )

   hset( ::hColumns, "precio_articulo",            {  "create"    => "DECIMAL(19,6)"                  ,;
                                                      "default"   => {|| 0 } }                        )

   hset( ::hColumns, "precio_venta",               {  "create"    => "DECIMAL(19,6)"                  ,;
                                                      "default"   => {|| 0 } }                        )

   hset( ::hColumns, "tipo_iva",                   {  "create"    => "DECIMAL(6,2)"                  ,;
                                                      "default"   => {|| 0 } }                        )

RETURN ( ::hColumns )

//---------------------------------------------------------------------------//

METHOD getInitialSelect()

   local cSelect  := "SELECT id, "                                            + ;
                        "uuid, "                                              + ;
                        "parent_uuid, "                                       + ;
                        "codigo_articulo, "                                   + ;
                        "nombre_articulo, "                                   + ;
                        "codigo_primera_propiedad, "                          + ;
                        "valor_primera_propiedad, "                           + ;
                        "codigo_segunda_propiedad, "                          + ;
                        "valor_segunda_propiedad, "                           + ;
                        "fecha_caducidad, "                                   + ;
                        "lote, "                                              + ;
                        "bultos_articulo, "                                   + ;
                        "cajas_articulo, "                                    + ;
                        "unidades_articulo, "                                 + ;
                        ::getSQLSubSentenceTotalUnidadesLinea() + ", "        + ;
                        "precio_articulo, "                                   + ;
                        ::getSQLSubSentenceTotalPrecioLinea() + ", "          + ;
                        "precio_venta, "                                      + ;
                        "tipo_iva, "                                          + ;
                        ::getSQLSubSentenceTotalVentaLinea() + ", "           + ;
                        ::getSQLSubSentenceTotalIva()                         + ;
                     "FROM " + ::getTableName()    

RETURN ( cSelect )

//---------------------------------------------------------------------------//

METHOD getInsertSentence( hBuffer )

   local nId

   if !Empty( hBuffer )
      ::hBuffer   := hBuffer
   end if

   nId            := ::getIdProductAdded()

   if empty( nId )
      RETURN ( ::Super:getInsertSentence( ::hBuffer ) )
   end if 

   ::setSQLInsert( ::getUpdateUnitsSentece( nId ) )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD addInsertSentence( aSQLInsert, oProperty )

   if empty( oProperty:Value )
      RETURN ( nil )
   end if

   hset( ::hBuffer, "uuid",                     win_uuidcreatestring() )
   hset( ::hBuffer, "codigo_primera_propiedad", oProperty:cCodigoPropiedad1 )
   hset( ::hBuffer, "valor_primera_propiedad",  oProperty:cValorPropiedad1 )
   hset( ::hBuffer, "codigo_segunda_propiedad", oProperty:cCodigoPropiedad2 )
   hset( ::hBuffer, "valor_segunda_propiedad",  oProperty:cValorPropiedad2 )
   hset( ::hBuffer, "unidades_articulo",        oProperty:Value )

   aadd( aSQLInsert, ::Super:getInsertSentence() + "; " )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD addUpdateSentence( aSQLUpdate, oProperty )

   aadd( aSQLUpdate, "UPDATE " + ::cTableName + " " +                                                       ;
                        "SET unidades_articulo = " + toSqlString( oProperty:Value )                + ", " + ;
                        "precio_articulo = " + toSqlString( hget( ::hBuffer, "precio_articulo" ) ) + " " +  ;
                        "WHERE uuid = " + quoted( oProperty:Uuid ) +  "; " )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD addDeleteSentence( aSQLUpdate, oProperty )

   aadd( aSQLUpdate, "DELETE FROM " + ::cTableName + " " +                          ;
                        "WHERE uuid = " + quoted( oProperty:Uuid ) + "; " )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD addDeleteSentenceById( aSQLUpdate, nId )

   aadd( aSQLUpdate, "DELETE FROM " + ::cTableName + " " +                          ;
                        "WHERE id = " + quoted( nId ) + "; " )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD deleteWhereUuid( uuid )

   local cSentence   := "DELETE FROM " + ::cTableName + " " + ;
                           "WHERE parent_uuid = " + quoted( uuid )

RETURN ( ::getDatabase():Exec( cSentence ) )

//---------------------------------------------------------------------------//

METHOD aUuidToDelete( aParentsUuid )

   local cSentence   

   cSentence            := "SELECT uuid FROM " + ::cTableName + " "
   cSentence            +=    "WHERE parent_uuid IN ( " 

   aeval( aParentsUuid, {| v | cSentence += toSQLString( v ) + ", " } )

   cSentence            := chgAtEnd( cSentence, ' )', 2 )

RETURN ( ::getDatabase():selectFetchArray( cSentence ) )

//---------------------------------------------------------------------------//

METHOD getDeleteSentenceFromParentsUuid( aParentsUuid )

   local aUuid       := ::aUuidToDelete( aParentsUuid )

   if !empty( aUuid )
      RETURN ::getDeleteSentence( aUuid )
   end if 

RETURN ( "" )

//---------------------------------------------------------------------------//

METHOD getSQLSubSentenceTotalUnidadesLinea( cTable, cAs )

   DEFAULT cTable    := ""
   DEFAULT cAs       := "total_unidades"
   
   if !empty( cTable )
      cTable         += "."
   end if 

   do case
      case lCalCaj() .and. lCalBul()
         RETURN ( "( IF( " + cTable + "bultos_articulo = 0, 1, " + cTable + "bultos_articulo ) * IF( " + cTable + "cajas_articulo = 0, 1, " + cTable + "cajas_articulo ) * " + cTable + "unidades_articulo ) AS " + cAs + " " )

      case lCalCaj() .and. !lCalBul()
         RETURN ( "( IF( " + cTable + "cajas_articulo = 0, 1, " + cTable + "cajas_articulo ) * " + cTable + "unidades_articulo ) AS " + cAs + " " )

      case !lCalCaj() .and. lCalBul()
         RETURN ( "( IF( " + cTable + "bultos_articulo = 0, 1, " + cTable + "bultos_articulo ) * " + cTable + "unidades_articulo ) AS " + cAs + " " )

   end case

RETURN ( cTable + "unidades_articulo AS " + cAs + " " )

//---------------------------------------------------------------------------//

METHOD getSQLSubSentenceTotalPrecioLinea( cTable, cAs )

   DEFAULT cTable    := ""
   DEFAULT cAs       := "total_precio"

   if !empty( cTable )
      cTable         += "."
   end if 

   if lCalCaj()   
      RETURN ( "( IF( " + cTable + "cajas_articulo = 0, 1, " + cTable + "cajas_articulo ) * " + cTable + "unidades_articulo * " + cTable + "precio_articulo ) AS " + cAs + " " )
   end if 

RETURN ( cTable + "unidades_articulo * " + cTable + "precio_articulo AS " + cAs + " " )

//---------------------------------------------------------------------------//

METHOD getSQLSubSentenceTotalVentaLinea( cTable, cAs )

   DEFAULT cTable    := ""
   DEFAULT cAs       := "total_precio_venta"

   if !empty( cTable )
      cTable         += "."
   end if 

   if lCalCaj()   
      RETURN ( "( IF( " + cTable + "cajas_articulo = 0, 1, " + cTable + "cajas_articulo ) * " + cTable + "unidades_articulo * " + cTable + "precio_venta ) AS " + cAs + " " )
   end if 

RETURN ( cTable + "unidades_articulo * " + cTable + "precio_venta AS " + cAs + " " )

//---------------------------------------------------------------------------//

METHOD getSQLSubSentenceTotalIva( cTable, cAs )

   DEFAULT cTable    := ""
   DEFAULT cAs       := "total_precio_venta_iva"

   if !empty( cTable )
      cTable         += "."
   end if 

   if lCalCaj()   
      RETURN ( "( ( IF( " + cTable + "cajas_articulo = 0, 1, " + cTable + "cajas_articulo ) * " + cTable + "unidades_articulo * " + cTable + "precio_venta )  * ( 1 + ( " + cTable + "tipo_iva / 100 ) ) ) AS " + cAs + " " )
   end if 

RETURN ( "( ( " + cTable + "unidades_articulo * " + cTable + "precio_venta ) * ( 1 + ( " + cTable + "tipo_iva / 100 ) ) ) AS " + cAs + " " )

//---------------------------------------------------------------------------//

METHOD getSQLSubSentenceSumatorioUnidadesLinea( cTable, cAs )

   DEFAULT cAs       := "total_unidades"

   if empty( cTable )
      cTable         := ""
   else
      cTable         += "."
   end if

   if lCalCaj()   
      RETURN ( "SUM( IF( " + cTable + "cajas_articulo = 0, 1, " + cTable + "cajas_articulo ) * " + cTable + "unidades_articulo ) AS " + cAs + " " )
   end if 

RETURN ( "SUM( " + cTable + "unidades_articulo ) AS " + cAs + " " )

//---------------------------------------------------------------------------//

METHOD getSQLSubSentenceSumatorioTotalPrecioLinea( cTable, cAs )

   DEFAULT cAs       := "total_precio"

   if empty( cTable )
      cTable         := ""
   else
      cTable         += "."
   end if

   if lCalCaj()   
      RETURN ( "SUM( IF( " + cTable + "cajas_articulo = 0, 1, " + cTable + "cajas_articulo ) * " + cTable + "unidades_articulo * " + cTable + "precio_articulo ) AS " + cAs + " " )
   end if 

RETURN ( "SUM( " + cTable + "unidades_articulo * " + cTable + "precio_articulo ) AS " + cAs + " " )

//---------------------------------------------------------------------------//

METHOD getSQLSumatorioTotalVentaLinea( cTable, cAs )

   //local cPrecioVenta

   DEFAULT cAs       := "total_precio_venta_iva"
   
   if empty( cTable )
      cTable         := ""
   else
      cTable         += "."
   end if

   //cPrecioVenta      := "( precio_venta * ( 1 + ( " + cTable + "tipo_iva / 100 ) ) )"

   if lCalCaj()   
      RETURN ( "SUM( IF( " + cTable + "cajas_articulo = 0, 1, " + cTable + "cajas_articulo ) * " + cTable + "unidades_articulo * precio_venta ) AS " + cAs + " " )
   end if 

RETURN ( "SUM( " + cTable + "unidades_articulo * precio_venta ) AS " + cAs + " " )

//---------------------------------------------------------------------------//

METHOD getSentenceNotSent( aFetch )

   local cSentence   := "SELECT * FROM " + ::cTableName + " "

   cSentence         +=    "WHERE parent_uuid IN ( " 

   aeval( aFetch, {|h| cSentence += toSQLString( hget( h, "uuid" ) ) + ", " } )

   cSentence         := chgAtEnd( cSentence, ' )', 2 )

RETURN ( cSentence )

//---------------------------------------------------------------------------//
//
// Comentado para no acumular
//
METHOD getIdProductAdded()

   // local aId         := MovimientosAlmacenLineasRepository():getIdFromBuffer( ::hBuffer )

   // if !empty( aId )
   //    RETURN( hget( atail( aId ), "id" ) )
   // end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getUpdateUnitsSentece( id )
   
   local cSentence   := "UPDATE " + ::cTableName                                                                                    + " " +  ;
                           "SET unidades_articulo = unidades_articulo + " + toSQLString( hget( ::hBuffer, "unidades_articulo" ) )   + " " +  ;
                        "WHERE id = " + quoted( id )

RETURN ( cSentence )

//---------------------------------------------------------------------------//

METHOD createTemporalTableWhereUuid( uuid )

   local cSentence

   ::cTableTemporal  := ::cTableName + hb_ttos( hb_datetime() )

   cSentence         := "CREATE TEMPORARY TABLE " + ::cTableTemporal          + " "
   cSentence         +=    "SELECT * from " + ::cTableName                    + " " 
   cSentence         += "WHERE parent_uuid = " + quoted( uuid )               + "; "

RETURN ( ::getDatabase():Exec( cSentence ) )

//---------------------------------------------------------------------------//

METHOD alterTemporalTableWhereUuid()

   local cSentence

   cSentence         := "ALTER TABLE " + ::cTableTemporal + " DROP id"

RETURN ( ::getDatabase():Exec( cSentence ) )

//---------------------------------------------------------------------------//

METHOD replaceUuidInTemporalTable( duplicatedUuid )

   local cSentence

   cSentence         := "UPDATE " + ::cTableTemporal                          + " "
   cSentence         +=    "SET id = 0"                                       + ", "
   cSentence         +=       "uuid = UUID()"                                 + ", "
   cSentence         +=       "parent_uuid = " + quoted( duplicatedUuid )    

RETURN ( ::getDatabase():Exec( cSentence ) )

//---------------------------------------------------------------------------//

METHOD insertTemporalTable()

   local cSentence

   cSentence         := "INSERT INTO " + ::cTableName                         + " "
   cSentence         +=    "SELECT * FROM " + ::cTableTemporal

RETURN ( ::getDatabase():Exec( cSentence ) )

//---------------------------------------------------------------------------//

METHOD dropTemporalTable()

RETURN ( ::getDatabase():Exec( "DROP TABLE " + ::cTableTemporal ) )

//---------------------------------------------------------------------------//

METHOD duplicateByUuid( uuid, duplicatedUuid )

   if !( ::createTemporalTableWhereUuid( uuid ) )
      RETURN ( nil )
   end if 

   if !( ::replaceUuidInTemporalTable( duplicatedUuid ) )
      RETURN ( nil )
   end if 

   if !( ::insertTemporalTable() )
      RETURN ( nil )
   end if 

   if !( ::dropTemporalTable() )
      RETURN ( nil )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getListToSend( aListParentUuid )

   local cSentence   := ""

   cSentence         +=  "SELECT * "
   cSentence         +=  "FROM " + ::getTableName() + Space(1)
   cSentence         +=  "WHERE parent_uuid in ( "

   aeval( aListParentUuid, {|h| cSentence += toSQLString( h ) + ", " } )

   cSentence         := chgAtEnd( cSentence, ' )', 2 )

RETURN ( ::getDatabase():selectFetchToJson( cSentence ) )

//---------------------------------------------------------------------------//

METHOD prepareFromInsertBuffer( hBuffer )

   hSet( hBuffer, "fecha_caducidad", hb_SToT( hGet( hBuffer, "fecha_caducidad" ) ) )

Return ( hBuffer )

//---------------------------------------------------------------------------//

METHOD updatePrecioVenta( uuid, nNewPrice )
   
   local cSentence

   cSentence         := "UPDATE " + ::getTableName()                             + " "
   cSentence         +=    "SET precio_venta = " + AllTrim( Str( nNewPrice ) )   + " "
   cSentence         +=    "WHERE uuid = " + quoted( uuid )    

RETURN ( ::getDatabase():Exec( cSentence ) )

//---------------------------------------------------------------------------//

METHOD ValidaDocumentos( parentBuffer, oMeter ) CLASS SQLMovimientosAlmacenLineasModel
   
   local cSql              := "select * FROM " + ::getTableName() + " WHERE parent_uuid = " + quoted( hGet( parentBuffer, "uuid" ) )
   local aLineas
   local hLine
   local dConsolidacion

   aLineas                 := ::getDatabase():selectFetchHash( cSql )

   if !Empty( oMeter )
      oMeter:Show()
      oMeter:SetTotal( Len( aLineas ) )
   end if

   for each hLine in aLineas

      dConsolidacion       := MovimientosAlmacenLineasRepository():getFechaHoraConsolidacion(   hGet( hLine, "codigo_articulo" ),;
                                                                                                hGet( parentBuffer, "almacen_destino" ),;
                                                                                                hGet( hLine, "codigo_primera_propiedad" ),;
                                                                                                hGet( hLine, "codigo_segunda_propiedad" ),;
                                                                                                hGet( hLine, "valor_primera_propiedad" ),;
                                                                                                hGet( hLine, "valor_segunda_propiedad" ),;
                                                                                                hGet( hLine, "lote" ) )

      if !Empty( dConsolidacion ) .and. hget( parentBuffer, "fecha_hora" ) >= dConsolidacion

         ValidateLinesTransaccionesComercialesLineas(   hGet( hLine, "codigo_articulo" ),;
                                                                     hGet( parentBuffer, "almacen_destino" ),;
                                                                     hGet( hLine, "codigo_primera_propiedad" ),;
                                                                     hGet( hLine, "codigo_segunda_propiedad" ),;
                                                                     hGet( hLine, "valor_primera_propiedad" ),;
                                                                     hGet( hLine, "valor_segunda_propiedad" ),;
                                                                     hGet( hLine, "lote" ),;
                                                                     hget( parentBuffer, "fecha_hora" ) )

      end if

      if !Empty( oMeter )
         oMeter:AutoInc()
      end if

   next

   if !Empty( oMeter )
      oMeter:Hide()
   end if

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD getLinesFromStock( aParentsUuid )

   local cSql        := "SELECT cabecera.uuid, "                                                         + ;
                           "cabecera.numero AS numero, "                                                 + ;
                           "cabecera.almacen_origen AS almacen_origen, "                                 + ;
                           "cabecera.almacen_destino AS almacen_destino, "                               + ;
                           "cabecera.tipo_movimiento AS tipo, "                                          + ;
                           "cabecera.fecha_hora AS fecha_hora, "                                         + ;
                           "lineas.codigo_articulo AS codigo_articulo , "                                + ;
                           "lineas.nombre_articulo AS nombre_articulo, "                                 + ;
                           "lineas.codigo_primera_propiedad AS codigo_primera_propiedad, "               + ;
                           "lineas.valor_primera_propiedad AS valor_primera_propiedad, "                 + ;
                           "lineas.codigo_segunda_propiedad AS codigo_segunda_propiedad, "               + ;
                           "lineas.valor_primera_propiedad AS valor_segunda_propiedad, "                 + ;
                           "lineas.lote AS lote, "                                                       + ;
                           "lineas.bultos_articulo AS bultos, "                                          + ;
                           "lineas.cajas_articulo AS cajas, "                                            + ;
                           "lineas.unidades_articulo AS unidades "                                       + ;
                              "FROM " + ::getTableName() + " AS lineas "                                 + ;
                                 "INNER JOIN movimientos_almacen AS cabecera "                           + ;
                                 "ON cabecera.uuid = lineas.parent_uuid" + Space( 1 )                    + ;
                              "WHERE cabecera.empresa_codigo = " + quoted( cCodEmp() ) + " AND "         + ;
                                 "lineas.parent_uuid IN ( "

   aeval( aParentsUuid, {|v| cSql += toSQLString(v) + ", " } )

   cSql            := chgAtEnd( cSql, ' )', 2 )

RETURN ( ::getDatabase():selectFetchHash( cSql ) )

//---------------------------------------------------------------------------//

FUNCTION getValorLineasMovimientosAlmacen( id, uuid, parent_uuid, cField )

   local uValue      := ""

   if !Empty( id )
      uValue         := SQLMovimientosAlmacenLineasModel():getField( cField, "id", id )
   end if

   if !Empty( uuid )
      uValue         := SQLMovimientosAlmacenLineasModel():getField( cField, "uuid", uuid )
   end if

   if !Empty( parent_uuid )
      uValue         := SQLMovimientosAlmacenLineasModel():getField( cField, "parent_uuid", parent_uuid )
   end if

RETURN ( uValue )

//---------------------------------------------------------------------------//

METHOD exist( uuid )

   local cStm  
   local cSql  := "SELECT codigo_articulo "                             + ;
                     "FROM " + ::getTableName() + " "                   + ;
                     "WHERE uuid = " + quoted( uuid ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD SeederToADS( parent_uuid )

   local cSql  := "SELECT * FROM " + ::getTableName() + " WHERE parent_uuid = " + quoted( parent_uuid )

RETURN ( getSQLDataBase():selectFetchHash( cSql ) )

//---------------------------------------------------------------------------//