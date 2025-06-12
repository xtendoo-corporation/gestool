#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS SQLStockModel FROM SQLBaseModel

   DATA cTableName               INIT "stock"

   METHOD getColumns()

   METHOD ClearTable()
 
   METHOD RecalculaStock()

   METHOD insertOrUpdate( hBuffer, lSuma )
   METHOD existeStock( hBuffer, lSuma )
   METHOD insertStock( hBuffer, lSuma ) 
   METHOD updateStock( hBuffer, lSuma )  

   METHOD insertOrUpdateConsolidacion( hBuffer, lSuma )
   METHOD insertConsolidacion( hBuffer, lSuma ) 
   METHOD updateConsolidacion( hBuffer, lSuma )  
   METHOD RollBackStockAnterior( hBuffer )

   METHOD sumaRestaStock( hBuffer )                INLINE ( ::sumaStock( hBuffer ), ::restaStock( hBuffer ) )
   METHOD sumaStock( hBuffer )                     INLINE ( if( ::lCheckConsolidacion( hBuffer, .t., .f. ), ::insertOrUpdate( hBuffer, .t., .f. ), ) )
   METHOD restaStock( hBuffer )                    INLINE ( if( ::lCheckConsolidacion( hBuffer, .f., .f. ), ::insertOrUpdate( hBuffer, .f., .f. ), ) )

   METHOD sumaRestaRollBackStock( hBuffer )        INLINE ( ::sumaRollBackStock( hBuffer ), ::restaRollBackStock( hBuffer ) )
   METHOD sumaRollBackStock( hBuffer )             INLINE ( if( ::lCheckConsolidacion( hBuffer, .f., .t. ), ::insertOrUpdate( hBuffer, .f., .t. ), ) )
   METHOD restaRollBackStock( hBuffer )            INLINE ( if( ::lCheckConsolidacion( hBuffer, .t., .t. ), ::insertOrUpdate( hBuffer, .t., .t. ), ) )

   METHOD getAlmacen( hBuffer, lSuma, lRollBack )
   
   METHOD lCheckConsolidacion( hBuffer )

   METHOD getStockArticulo( hBuffer )
      METHOD aStockArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cValorPrimeraPropiedad, cCodigoSegundaPropiedad, cValorSegundaPropiedad, cLote )
      METHOD getBufferArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cValorPrimeraPropiedad, cCodigoSegundaPropiedad, cValorSegundaPropiedad, cLote )
      METHOD nStockArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cValorPrimeraPropiedad, cCodigoSegundaPropiedad, cValorSegundaPropiedad, cLote )

   METHOD lPutStockActual( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cValorPrimeraPropiedad, cCodigoSegundaPropiedad, cValorSegundaPropiedad, cLote, oGet )

   METHOD existePendiente( hBuffer )
   
   METHOD insertOrUpdatePendienteEntregar( hBuffer, lRollBack )
   METHOD insertPendienteEntregar( hBuffer, lRollback )
   METHOD updatePendienteEntregar( hBuffer, lRollBack )
   
   METHOD insertOrUpdatePendienteRecibir( hBuffer, lRollBack )
   METHOD insertPendienteRecibir( hBuffer, lRollback )
   METHOD updatePendienteRecibir( hBuffer, lRollBack )

END CLASS

//---------------------------------------------------------------------------//

METHOD getColumns() CLASS SQLStockModel
   
   hset( ::hColumns, "id",                         {  "create"    => "INTEGER AUTO_INCREMENT UNIQUE"  ,;
                                                      "default"   => {|| 0 } }                        )

   ::getEmpresaColumns()

   hset( ::hColumns, "codigo_articulo",            {  "create"    => "VARCHAR( 18 )"                  ,;
                                                      "default"   => {|| space( 18 ) } }              )

   hset( ::hColumns, "codigo_almacen",             {  "create"    => "VARCHAR( 16 )"                  ,;
                                                      "default"   => {|| space( 16 ) } }              )

   hset( ::hColumns, "codigo_primera_propiedad",   {  "create"    => "VARCHAR(20)"                    ,;
                                                      "default"   => {|| space(20) } }                )

   hset( ::hColumns, "valor_primera_propiedad",    {  "create"    => "VARCHAR(200)"                   ,;
                                                      "default"   => {|| space(200) } }               )

   hset( ::hColumns, "codigo_segunda_propiedad",   {  "create"    => "VARCHAR(20)"                    ,;
                                                      "default"   => {|| space(20) } }                )

   hset( ::hColumns, "valor_segunda_propiedad",    {  "create"    => "VARCHAR(200)"                   ,;
                                                      "default"   => {|| space(200) } }               )

   hset( ::hColumns, "lote",                       {  "create"    => "VARCHAR(40)"                    ,;
                                                      "default"   => {|| space(40) } }                )

   hset( ::hColumns, "bultos_articulo",            {  "create"    => "DECIMAL(19,6)"                  ,;
                                                      "default"   => {|| 0 } }                        )

   hset( ::hColumns, "cajas_articulo",             {  "create"    => "DECIMAL(19,6)"                  ,;
                                                      "default"   => {|| 0 } }                        )

   hset( ::hColumns, "unidades_articulo",          {  "create"    => "DECIMAL(19,6)"                  ,;
                                                      "default"   => {|| 0 } }                        )

   hset( ::hColumns, "pendiente_entregar",          {  "create"    => "DECIMAL(19,6)"                  ,;
                                                      "default"   => {|| 0 } }                        )

   hset( ::hColumns, "pendiente_recibir",          {  "create"    => "DECIMAL(19,6)"                  ,;
                                                      "default"   => {|| 0 } }                        )

RETURN ( ::hColumns )

//---------------------------------------------------------------------------//

METHOD ClearTable() CLASS SQLStockModel

   local cStm
   local cSentence   := "DELETE FROM " + ::getTableName() + " WHERE empresa_codigo=" + quoted( cCodEmp() )

   getSQLDatabase():Exec( cSentence )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD RecalculaStock( aAdsStock ) CLASS SQLStockModel

   local cSentence   := ""

   cSentence         := "INSERT INTO " + ::getTableName()
   cSentence         += " ( empresa_codigo, "
   cSentence         += "usuario_codigo, "
   cSentence         += "codigo_articulo, "
   cSentence         += "codigo_almacen, "
   cSentence         += "codigo_primera_propiedad, "
   cSentence         += "valor_primera_propiedad, "
   cSentence         += "codigo_segunda_propiedad, "
   cSentence         += "valor_segunda_propiedad, "
   cSentence         += "lote, "
   cSentence         += "bultos_articulo, "
   cSentence         += "cajas_articulo, "
   cSentence         += "unidades_articulo, "
   cSentence         += "pendiente_entregar, "
   cSentence         += "pendiente_recibir ) "
   cSentence         += "VALUES ( "
   cSentence         += toSQLString( cCodEmp() ) + ", "
   cSentence         += toSQLString( Auth():Codigo() ) + ", "
   cSentence         += toSQLString( aAdsStock:cCodigo ) + ", "
   cSentence         += toSQLString( aAdsStock:cCodigoAlmacen ) + ", "
   cSentence         += toSQLString( aAdsStock:cCodigoPropiedad1 ) + ", "
   cSentence         += toSQLString( aAdsStock:cValorPropiedad1 ) + ", "
   cSentence         += toSQLString( aAdsStock:cCodigoPropiedad2 ) + ", "
   cSentence         += toSQLString( aAdsStock:cValorPropiedad2 ) + ", "
   cSentence         += toSQLString( aAdsStock:cLote ) + ", "
   cSentence         += toSQLString( aAdsStock:nBultos ) + ", "
   cSentence         += toSQLString( aAdsStock:nCajas ) + ", "
   cSentence         += toSQLString( aAdsStock:nUnidades ) + ", "
   cSentence         += toSQLString( aAdsStock:nPendientesEntregar ) + ", "
   cSentence         += toSQLString( aAdsStock:nPendientesRecibir ) + " )"

   getSQLDatabase():Exec( cSentence )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD getAlmacen( hBuffer, lSuma, lRollBack ) CLASS SQLStockModel

   local cCodigoAlmacen

   if lRollBack

      if lSuma
         cCodigoAlmacen := hGet( hBuffer, "codigo_almacen_salida" )
      else
         cCodigoAlmacen := hGet( hBuffer, "codigo_almacen_entrada" )
      end if

   else

      if lSuma
         cCodigoAlmacen := hGet( hBuffer, "codigo_almacen_entrada" )
      else
         cCodigoAlmacen := hGet( hBuffer, "codigo_almacen_salida" )
      end if

   end if

Return cCodigoAlmacen

//---------------------------------------------------------------------------//

METHOD existeStock( hBuffer, lSuma, lRollBack ) CLASS SQLStockModel

   local nId
   local cSentence         := ""
   local cCodigoAlmacen    := ::getAlmacen( hBuffer, lSuma, lRollBack )

   if Empty( hBuffer )
      Return ( .f. )
   end if

   if Empty( hGet( hBuffer, "codigo_articulo" ) ) .or. Empty( cCodigoAlmacen )
      Return ( .f. )
   end if

   cSentence         := "SELECT id FROM " + ::getTableName()
   cSentence         += " WHERE empresa_codigo = " + toSQLString( cCodEmp() ) + " AND "
   cSentence         += " codigo_articulo = " + toSQLString( hGet( hBuffer, "codigo_articulo" ) ) + " AND "
   cSentence         += " codigo_almacen = " + toSQLString( cCodigoAlmacen )
   cSentence         += " AND codigo_primera_propiedad = " + toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) )
   cSentence         += " AND codigo_segunda_propiedad = " + toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) )
   cSentence         += " AND valor_primera_propiedad = " + toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) )
   cSentence         += " AND valor_segunda_propiedad = " + toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) )
   cSentence         += " AND lote = " + toSQLString( hGet( hBuffer, "lote" ) )

   nId               := getSQLDatabase():getValue( cSentence )

Return ( !Empty( nId ) )

//---------------------------------------------------------------------------//

METHOD insertStock( hBuffer, lSuma, lRollBack ) CLASS SQLStockModel
   
   local cSentence         := ""
   local cCodigoAlmacen    := ::getAlmacen( hBuffer, lSuma, lRollBack )

   if Empty( hGet( hBuffer, "codigo_articulo" ) ) .or. Empty( cCodigoAlmacen )
      Return ( .f. )
   end if

   cSentence         := "INSERT INTO " + ::getTableName()
   cSentence         += " ( empresa_codigo, "
   cSentence         += "usuario_codigo, "
   cSentence         += "codigo_articulo, "
   cSentence         += "codigo_almacen, "
   cSentence         += "codigo_primera_propiedad, "
   cSentence         += "valor_primera_propiedad, "
   cSentence         += "codigo_segunda_propiedad, "
   cSentence         += "valor_segunda_propiedad, "
   cSentence         += "lote, "
   cSentence         += "bultos_articulo, "
   cSentence         += "cajas_articulo, "
   cSentence         += "unidades_articulo ) "
   cSentence         += "VALUES ( "
   cSentence         += toSQLString( cCodEmp() ) + ", "
   cSentence         += toSQLString( Auth():Codigo() ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_articulo" ) ) + ", "
   cSentence         += toSQLString( cCodigoAlmacen ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "lote" ) ) + ", "
   
   if lSuma
      cSentence         += toSQLString( hGet( hBuffer, "bultos_articulo" ) ) + ", "
      cSentence         += toSQLString( hGet( hBuffer, "cajas_articulo" ) ) + ", "
      cSentence         += toSQLString( hGet( hBuffer, "unidades_articulo" ) ) + " )"
   else
      cSentence         += toSQLString( ( hGet( hBuffer, "bultos_articulo" ) * - 1 ) ) + ", "
      cSentence         += toSQLString( ( hGet( hBuffer, "cajas_articulo" ) * - 1 ) ) + ", "
      cSentence         += toSQLString( ( hGet( hBuffer, "unidades_articulo" ) * - 1 ) ) + " )"
   end if

   getSQLDatabase():Exec( cSentence )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD updateStock( hBuffer, lSuma, lRollBack ) CLASS SQLStockModel
   
   local cSentence         := ""
   local cCodigoAlmacen    := ::getAlmacen( hBuffer, lSuma, lRollBack )

   if Empty( hGet( hBuffer, "codigo_articulo" ) ) .or. Empty( cCodigoAlmacen )
      Return ( .f. )
   end if

   cSentence         := "UPDATE " + ::getTableName() + " SET "
   
   if lSuma
      cSentence      += "bultos_articulo = bultos_articulo + " + toSQLString( hGet( hBuffer, "bultos_articulo" ) ) + ", "
      cSentence      += "cajas_articulo = cajas_articulo + " + toSQLString( hGet( hBuffer, "cajas_articulo" ) ) + ", "
      cSentence      += "unidades_articulo = unidades_articulo + " + toSQLString( hGet( hBuffer, "unidades_articulo" ) )
   else
      cSentence      += "bultos_articulo = bultos_articulo - " + toSQLString( hGet( hBuffer, "bultos_articulo" ) ) + ", "
      cSentence      += "cajas_articulo = cajas_articulo - " + toSQLString( hGet( hBuffer, "cajas_articulo" ) ) + ", "
      cSentence      += "unidades_articulo = unidades_articulo - " + toSQLString( hGet( hBuffer, "unidades_articulo" ) )
   end if
   
   cSentence         += " WHERE "
   cSentence         += "empresa_codigo = " + toSQLString( cCodEmp() ) + " AND "
   cSentence         += "codigo_articulo = " + toSQLString( hGet( hBuffer, "codigo_articulo" ) ) + " AND "
   cSentence         += "codigo_almacen = " + toSQLString( cCodigoAlmacen )
   cSentence         += " AND codigo_primera_propiedad = " + toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) )
   cSentence         += " AND valor_primera_propiedad = " + toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) )
   cSentence         += " AND codigo_segunda_propiedad = " + toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) )
   cSentence         += " AND valor_segunda_propiedad = " + toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) )
   cSentence         += " AND lote = " + toSQLString( hGet( hBuffer, "lote" ) )

   getSQLDatabase():Exec( cSentence )
   
Return ( .t. )

//---------------------------------------------------------------------------//

METHOD insertOrUpdate( hBuffer, lSuma, lRollBack ) CLASS SQLStockModel

   if ::existeStock( hBuffer, lSuma, lRollBack )
      ::updateStock( hBuffer, lSuma, lRollBack )
   else
      ::insertStock( hBuffer, lSuma, lRollBack )
   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lCheckConsolidacion( hBuffer, lSuma, lRollBack ) CLASS SQLStockModel

   local lCheck   := .f.

   lCheck         := TStock():lCheckConsolidacion( hGet( hBuffer, "codigo_articulo" ),;
                                                   ::getAlmacen( hBuffer, lSuma, lRollBack ),;
                                                   hGet( hBuffer, "codigo_primera_propiedad" ),;
                                                   hGet( hBuffer, "codigo_segunda_propiedad" ),;
                                                   hGet( hBuffer, "valor_primera_propiedad" ),;
                                                   hGet( hBuffer, "valor_segunda_propiedad" ),;
                                                   hGet( hBuffer, "lote" ),;
                                                   hGet( hBuffer, "fecha" ),;
                                                   hGet( hBuffer, "hora" ) )
Return ( lCheck )

//---------------------------------------------------------------------------//

METHOD insertOrUpdateConsolidacion( hBuffer, lSuma, lRollBack ) CLASS SQLStockModel

   if ::existeStock( hBuffer, lSuma, lRollBack )
      ::updateConsolidacion( hBuffer, lSuma, lRollBack )
   else
      ::insertConsolidacion( hBuffer, lSuma, lRollBack )
   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD insertConsolidacion( hBuffer, lSuma, lRollBack ) CLASS SQLStockModel
   
   local cSentence         := ""
   local cCodigoAlmacen    := ::getAlmacen( hBuffer, lSuma, lRollBack )

   if Empty( hGet( hBuffer, "codigo_articulo" ) ) .or. Empty( cCodigoAlmacen )
      Return ( .f. )
   end if

   cSentence         := "INSERT INTO " + ::getTableName()
   cSentence         += " ( empresa_codigo, "
   cSentence         += "usuario_codigo, "
   cSentence         += "codigo_articulo, "
   cSentence         += "codigo_almacen, "
   cSentence         += "codigo_primera_propiedad, "
   cSentence         += "valor_primera_propiedad, "
   cSentence         += "codigo_segunda_propiedad, "
   cSentence         += "valor_segunda_propiedad, "
   cSentence         += "lote, "
   cSentence         += "bultos_articulo, "
   cSentence         += "cajas_articulo, "
   cSentence         += "unidades_articulo ) "
   cSentence         += "VALUES ( "
   cSentence         += toSQLString( cCodEmp() ) + ", "
   cSentence         += toSQLString( Auth():Codigo() ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_articulo" ) ) + ", "
   cSentence         += toSQLString( cCodigoAlmacen ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "lote" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "bultos_articulo" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "cajas_articulo" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "unidades_articulo" ) ) + " )"

   getSQLDatabase():Exec( cSentence )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD updateConsolidacion( hBuffer, lSuma, lRollBack ) CLASS SQLStockModel
   
   local cSentence         := ""
   local cCodigoAlmacen    := ::getAlmacen( hBuffer, lSuma, lRollBack )

   if Empty( hGet( hBuffer, "codigo_articulo" ) ) .or. Empty( cCodigoAlmacen )
      Return ( .f. )
   end if

   cSentence         := "UPDATE " + ::getTableName() + " SET "
   cSentence         += "bultos_articulo = " + toSQLString( hGet( hBuffer, "bultos_articulo" ) ) + ", "
   cSentence         += "cajas_articulo = " + toSQLString( hGet( hBuffer, "cajas_articulo" ) ) + ", "
   cSentence         += "unidades_articulo = " + toSQLString( hGet( hBuffer, "unidades_articulo" ) )
   cSentence         += " WHERE "
   cSentence         += "empresa_codigo = " + toSQLString( cCodEmp() ) + " AND "
   cSentence         += "codigo_articulo = " + toSQLString( hGet( hBuffer, "codigo_articulo" ) ) + " AND "
   cSentence         += "codigo_almacen = " + toSQLString( cCodigoAlmacen )
   cSentence         += " AND codigo_primera_propiedad = " + toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) )
   cSentence         += " AND valor_primera_propiedad = " + toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) )
   cSentence         += " AND codigo_segunda_propiedad = " + toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) )
   cSentence         += " AND valor_segunda_propiedad = " + toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) )
   cSentence         += " AND lote = " + toSQLString( hGet( hBuffer, "lote" ) )

   getSQLDatabase():Exec( cSentence )
   
Return ( .t. )

//---------------------------------------------------------------------------//

METHOD RollBackStockAnterior( hBuffer )
 
   local aStock
   local oStock

   oStock               := TStock():Create( cPatEmp() )
   oStock:lOpenFiles()

   //Calculamos el stock anterior----------------------------------------------

   aStock := oStock:aStockArticulo(    hGet( hBuffer, "codigo_articulo" ),;
                                       hGet( hBuffer, "codigo_almacen_entrada" ),;
                                       hGet( hBuffer, "lote" ),;
                                       hGet( hBuffer, "codigo_primera_propiedad" ),;
                                       hGet( hBuffer, "valor_primera_propiedad" ),;
                                       hGet( hBuffer, "codigo_segunda_propiedad" ),;
                                       hGet( hBuffer, "valor_segunda_propiedad" ),;
                                       ,;
                                       ,;
                                       ,;
                                       ,;
                                       cCodEmp() )

   if !Empty( oStock )
      oStock:end()
   end if

   //Actualizo el buffer definitivo para actualizar el stock anterior----------

   hSet( hBuffer, "bultos_articulo", aStock[1]:nBultos )
   hSet( hBuffer, "cajas_articulo", aStock[1]:nCajas )
   hSet( hBuffer, "unidades_articulo", aStock[1]:nUnidades )

   //fijamos los valores en la tabla-------------------------------------------

   if ::lCheckConsolidacion( hBuffer, .t., .f. )
      ::insertOrUpdateConsolidacion( hBuffer, .t., .f. )
   end if

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD getStockArticulo( hBuffer ) CLASS SQLStockModel

   local aStock      := {}
   local cSentence   := ""

   if Empty( hBuffer )
      return( aStock )
   end if

   if !hhaskey( hBuffer, "codigo_articulo" ) .or. Empty( hGet( hBuffer, "codigo_articulo" ) )
      return( aStock )
   end if

   cSentence         := "Select * FROM " + ::getTableName() + space( 1 )
   cSentence         += "WHERE empresa_codigo = " + toSQLString( cCodEmp() ) + " AND codigo_articulo = " + toSQLString( hGet( hBuffer, "codigo_articulo" ) )

   if hhaskey( hBuffer, "codigo_almacen" ) .and. !Empty( hGet( hBuffer, "codigo_almacen" ) )
      cSentence      += " AND codigo_almacen = " + toSQLString( hGet( hBuffer, "codigo_almacen" ) )
   end if

   if hhaskey( hBuffer, "codigo_primera_propiedad" ) .and. !Empty( hGet( hBuffer, "codigo_primera_propiedad" ) )
      cSentence      += " AND codigo_primera_propiedad = " + toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) )
   end if

   if hhaskey( hBuffer, "valor_primera_propiedad" ) .and. !Empty( hGet( hBuffer, "valor_primera_propiedad" ) )
      cSentence      += " AND valor_primera_propiedad = " + toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) )
   end if

   if hhaskey( hBuffer, "codigo_segunda_propiedad" ) .and. !Empty( hGet( hBuffer, "codigo_segunda_propiedad" ) )
      cSentence      += " AND codigo_segunda_propiedad = " + toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) )
   end if

   if hhaskey( hBuffer, "valor_segunda_propiedad" ) .and. !Empty( hGet( hBuffer, "valor_segunda_propiedad" ) )
      cSentence      += " AND valor_segunda_propiedad = " + toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) )
   end if

   if hhaskey( hBuffer, "lote" ) .and. !Empty( hGet( hBuffer, "lote" ) )
      cSentence      += " AND lote = " + toSQLString( hGet( hBuffer, "lote" ) )
   end if

   cSentence         += " ORDER BY codigo_almacen, valor_primera_propiedad, valor_segunda_propiedad, valor_segunda_propiedad, lote ASC"

   aStock            := getSQLDatabase():selectFetchHash( cSentence )

   if !hb_isArray( aStock )
      aStock         := {}
   end if

Return ( aStock )

//---------------------------------------------------------------------------//

METHOD getBufferArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cValorPrimeraPropiedad, cCodigoSegundaPropiedad, cValorSegundaPropiedad, cLote )  CLASS SQLStockModel

   local hBuffer  := {=>}

   if !Empty( cCodigoArticulo )
      hset( hBuffer, "codigo_articulo", AllTrim( cCodigoArticulo ) )
   end if

   if !Empty( cCodigoAlmacen )
      hset( hBuffer, "codigo_almacen", AllTrim( cCodigoAlmacen ) )
   end if

   if !Empty( cCodigoPrimeraPropiedad )
      hset( hBuffer, "codigo_primera_propiedad", AllTrim( cCodigoPrimeraPropiedad ) )
   end if

   if !Empty( cValorPrimeraPropiedad )
      hset( hBuffer, "valor_primera_propiedad", AllTrim( cValorPrimeraPropiedad ) )
   end if

   if !Empty( cCodigoSegundaPropiedad )
      hset( hBuffer, "codigo_segunda_propiedad", AllTrim( cCodigoSegundaPropiedad ) )
   end if

   if !Empty( cValorSegundaPropiedad )
      hset( hBuffer, "valor_segunda_propiedad", AllTrim( cValorSegundaPropiedad ) )
   end if

   if !Empty( cLote )
      hset( hBuffer, "lote", AllTrim( cLote ) )
   end if

RETURN ( hBuffer )

//---------------------------------------------------------------------------//

METHOD aStockArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cValorPrimeraPropiedad, cCodigoSegundaPropiedad, cValorSegundaPropiedad, cLote ) CLASS SQLStockModel

Return ( ::getStockArticulo( ::getBufferArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cValorPrimeraPropiedad, cCodigoSegundaPropiedad, cValorSegundaPropiedad, cLote ) ) )

//---------------------------------------------------------------------------//

METHOD nStockArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cValorPrimeraPropiedad, cCodigoSegundaPropiedad, cValorSegundaPropiedad, cLote ) CLASS SQLStockModel

   local aStock         := {}
   local nStockArticulo := 0

   aStock               := ::aStockArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cValorPrimeraPropiedad, cCodigoSegundaPropiedad, cValorSegundaPropiedad, cLote )

   if hb_isArray( aStock ) .and. len( aStock ) > 0
      aEval( aStock, {|h| nStockArticulo += hGet( h, "unidades_articulo" ) } )
   end if

RETURN ( nStockArticulo )

//---------------------------------------------------------------------------//

METHOD lPutStockActual( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote, oGet ) CLASS SQLStockModel

   local nStock   := 0
   local cClass   := ""

   if !uFieldEmpresa( "lNStkAct" )
      nStock      := ::nStockArticulo( cCodigoArticulo, cCodigoAlmacen, cCodigoPrimeraPropiedad, cValorPrimeraPropiedad, cCodigoSegundaPropiedad, cValorSegundaPropiedad, cLote )
   end if

   if !empty( oGet )

      cClass      := oGet:ClassName()

      do case
         case cClass == "TGET" .or. cClass == "TGETHLP" .or. cClass == "TGRIDGET"
            oGet:cText( nStock )
         case cClass == "TSAY"
            oGet:SetText( nStock )
      end case

   end if

RETURN ( .t. )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//------------------PENDIENTE DE RECIBIR O ENTREGAR--------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

METHOD existePendiente( hBuffer ) CLASS SQLStockModel

   local nId
   local cSentence         := ""

   if Empty( hBuffer )
      Return ( .f. )
   end if

   if Empty( hGet( hBuffer, "codigo_articulo" ) ) .or. Empty( hGet( hBuffer, "codigo_almacen_salida" ) )
      Return ( .f. )
   end if

   cSentence         := "SELECT id FROM " + ::getTableName()
   cSentence         += " WHERE empresa_codigo = " + toSQLString( cCodEmp() ) + " AND "
   cSentence         += " codigo_articulo = " + toSQLString( hGet( hBuffer, "codigo_articulo" ) ) + " AND "
   cSentence         += " codigo_almacen = " + toSQLString( hGet( hBuffer, "codigo_almacen_salida" ) )
   cSentence         += " AND codigo_primera_propiedad = " + toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) )
   cSentence         += " AND codigo_segunda_propiedad = " + toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) )
   cSentence         += " AND valor_primera_propiedad = " + toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) )
   cSentence         += " AND valor_segunda_propiedad = " + toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) )

   /*if !Empty( hGet( hBuffer, "lote" ) )
      cSentence      += " AND lote = " + toSQLString( hGet( hBuffer, "lote" ) )
   end if*/

   nId               := getSQLDatabase():getValue( cSentence )

Return ( !Empty( nId ) )

//---------------------------------------------------------------------------//

METHOD insertOrUpdatePendienteEntregar( hBuffer, lRollBack ) CLASS SQLStockModel

   if ::existePendiente( hBuffer )
      ::updatePendienteEntregar( hBuffer, lRollBack )
   else
      ::insertPendienteEntregar( hBuffer, lRollBack )
   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD insertPendienteEntregar( hBuffer, lRollback ) CLASS SQLStockModel
   
   local cSentence         := ""

   DEFAULT lRollback       := .f.

   if Empty( hGet( hBuffer, "codigo_articulo" ) ) .or. Empty( hGet( hBuffer, "codigo_almacen_salida" ) )
      Return ( .f. )
   end if

   cSentence         := "INSERT INTO " + ::getTableName()
   cSentence         += " ( empresa_codigo, "
   cSentence         += "usuario_codigo, "
   cSentence         += "codigo_articulo, "
   cSentence         += "codigo_almacen, "
   cSentence         += "codigo_primera_propiedad, "
   cSentence         += "valor_primera_propiedad, "
   cSentence         += "codigo_segunda_propiedad, "
   cSentence         += "valor_segunda_propiedad, "
   cSentence         += "lote, "
   cSentence         += "bultos_articulo, "
   cSentence         += "cajas_articulo, "
   cSentence         += "unidades_articulo, "
   cSentence         += "pendiente_recibir, "
   cSentence         += "pendiente_entregar ) "
   cSentence         += "VALUES ( "
   cSentence         += toSQLString( cCodEmp() ) + ", "
   cSentence         += toSQLString( Auth():Codigo() ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_articulo" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_almacen_salida" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "lote" ) ) + ", "
   cSentence         += "0, "
   cSentence         += "0, "
   cSentence         += "0, "
   cSentence         += "0, "
   
   if !lRollback
      cSentence      += toSQLString( hGet( hBuffer, "pendiente_entregar" ) ) + " )"
   else
      cSentence      += toSQLString( ( hGet( hBuffer, "pendiente_entregar" ) * - 1 ) ) + " )"
   end if

   getSQLDatabase():Exec( cSentence )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD updatePendienteEntregar( hBuffer, lRollBack ) CLASS SQLStockModel
   
   local cSentence         := ""

   DEFAULT lRollback       := .f.

   if Empty( hGet( hBuffer, "codigo_articulo" ) ) .or. Empty( hGet( hBuffer, "codigo_almacen_salida" ) )
      Return ( .f. )
   end if

   cSentence         := "UPDATE " + ::getTableName() + " SET "
   
   if !lRollback
      cSentence      += "pendiente_entregar = pendiente_entregar + " + toSQLString( hGet( hBuffer, "pendiente_entregar" ) )
   else
      cSentence      += "pendiente_entregar = pendiente_entregar - " + toSQLString( hGet( hBuffer, "pendiente_entregar" ) )
   end if
   
   cSentence         += " WHERE "
   cSentence         += "empresa_codigo = " + toSQLString( cCodEmp() ) + " AND "
   cSentence         += "codigo_articulo = " + toSQLString( hGet( hBuffer, "codigo_articulo" ) ) + " AND "
   cSentence         += "codigo_almacen = " + toSQLString( hGet( hBuffer, "codigo_almacen_salida" ) )
   cSentence         += " AND codigo_primera_propiedad = " + toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) )
   cSentence         += " AND valor_primera_propiedad = " + toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) )
   cSentence         += " AND codigo_segunda_propiedad = " + toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) )
   cSentence         += " AND valor_segunda_propiedad = " + toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) )

   /*if !Empty( hGet( hBuffer, "lote" ) )
      cSentence      += " AND lote = " + toSQLString( hGet( hBuffer, "lote" ) )
   end if*/ 

   getSQLDatabase():Exec( cSentence )
   
Return ( .t. )

//---------------------------------------------------------------------------//

METHOD insertOrUpdatePendienteRecibir( hBuffer, lRollBack ) CLASS SQLStockModel

   if ::existePendiente( hBuffer )
      ::updatePendienteRecibir( hBuffer, lRollBack )
   else
      ::insertPendienteRecibir( hBuffer, lRollBack )
   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD insertPendienteRecibir( hBuffer, lRollback ) CLASS SQLStockModel
   
   local cSentence         := ""

   DEFAULT lRollback       := .f.

   if Empty( hGet( hBuffer, "codigo_articulo" ) ) .or. Empty( hGet( hBuffer, "codigo_almacen_salida" ) )
      Return ( .f. )
   end if

   cSentence         := "INSERT INTO " + ::getTableName()
   cSentence         += " ( empresa_codigo, "
   cSentence         += "usuario_codigo, "
   cSentence         += "codigo_articulo, "
   cSentence         += "codigo_almacen, "
   cSentence         += "codigo_primera_propiedad, "
   cSentence         += "valor_primera_propiedad, "
   cSentence         += "codigo_segunda_propiedad, "
   cSentence         += "valor_segunda_propiedad, "
   cSentence         += "lote, "
   cSentence         += "bultos_articulo, "
   cSentence         += "cajas_articulo, "
   cSentence         += "unidades_articulo, "
   cSentence         += "pendiente_entregar, "
   cSentence         += "pendiente_recibir ) "
   cSentence         += "VALUES ( "
   cSentence         += toSQLString( cCodEmp() ) + ", "
   cSentence         += toSQLString( Auth():Codigo() ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_articulo" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_almacen_salida" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) ) + ", "
   cSentence         += toSQLString( hGet( hBuffer, "lote" ) ) + ", "
   cSentence         += "0, "
   cSentence         += "0, "
   cSentence         += "0, "
   cSentence         += "0, "
   
   if !lRollback
      cSentence         += toSQLString( hGet( hBuffer, "pendiente_recibir" ) ) + " )"
   else
      cSentence         += toSQLString( ( hGet( hBuffer, "pendiente_recibir" ) * - 1 ) ) + " )"
   end if

   getSQLDatabase():Exec( cSentence )

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD updatePendienteRecibir( hBuffer, lRollBack ) CLASS SQLStockModel
   
   local cSentence         := ""

   DEFAULT lRollback       := .f.

   if Empty( hGet( hBuffer, "codigo_articulo" ) ) .or. Empty( hGet( hBuffer, "codigo_almacen_salida" ) )
      Return ( .f. )
   end if

   cSentence         := "UPDATE " + ::getTableName() + " SET "
   
   if !lRollback
      cSentence      += "pendiente_recibir = pendiente_recibir + " + toSQLString( hGet( hBuffer, "pendiente_recibir" ) )
   else
      cSentence      += "pendiente_recibir = pendiente_recibir - " + toSQLString( hGet( hBuffer, "pendiente_recibir" ) )
   end if
   
   cSentence         += " WHERE "
   cSentence         += "empresa_codigo = " + toSQLString( cCodEmp() ) + " AND "
   cSentence         += "codigo_articulo = " + toSQLString( hGet( hBuffer, "codigo_articulo" ) ) + " AND "
   cSentence         += "codigo_almacen = " + toSQLString( hGet( hBuffer, "codigo_almacen_salida" ) )
   cSentence         += " AND codigo_primera_propiedad = " + toSQLString( hGet( hBuffer, "codigo_primera_propiedad" ) )
   cSentence         += " AND valor_primera_propiedad = " + toSQLString( hGet( hBuffer, "valor_primera_propiedad" ) )
   cSentence         += " AND codigo_segunda_propiedad = " + toSQLString( hGet( hBuffer, "codigo_segunda_propiedad" ) )
   cSentence         += " AND valor_segunda_propiedad = " + toSQLString( hGet( hBuffer, "valor_segunda_propiedad" ) )

   /*if !Empty( hGet( hBuffer, "lote" ) )
      cSentence      += " AND lote = " + toSQLString( hGet( hBuffer, "lote" ) )
   end if*/ 

   getSQLDatabase():Exec( cSentence )
   
Return ( .t. )

//---------------------------------------------------------------------------//