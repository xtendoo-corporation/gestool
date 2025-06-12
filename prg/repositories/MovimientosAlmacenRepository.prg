#include "FiveWin.Ch"
#include "Factu.ch" 
#include "Hdo.ch"

//---------------------------------------------------------------------------//

CLASS MovimientosAlmacenRepository FROM SQLBaseRepository

   METHOD getTableName()            INLINE ( SQLMovimientosAlmacenModel():getTableName() )

   METHOD getSQLSentenceByIdOrLast( id ) 

   METHOD getSQLSentenceIdByNumber( nNumber ) 

   METHOD getIdByNumber( nNumber )  INLINE ( getSQLDataBase():getValue( ::getSQLSentenceIdByNumber( nNumber ) ) )

   METHOD getSQLSentenceIdByUuid( uuid ) 

   METHOD getIdByUuid( uuid )       INLINE ( getSQLDataBase():getValue( ::getSQLSentenceIdByUuid( uuid ) ) )

   METHOD getNextNumber( cUser )

   METHOD getLastNumber( cUser )

   METHOD getLastNumberByUser( cUser )

   METHOD getSQLSentenceTotalsForReport( oReporting )

   METHOD getRowSetTotalsForReport( oReporting )      

END CLASS

//---------------------------------------------------------------------------//

METHOD getSQLSentenceByIdOrLast( uId ) 

   local cSql  := "SELECT * FROM " + ::getTableName() + " " 

   if empty( uId )
      cSql     +=    "ORDER BY id DESC LIMIT 1"
      RETURN ( cSql )
   end if 

   if hb_isnumeric( uId )
      cSql     +=    "WHERE id = " + alltrim( str( uId ) ) 
   end if 

   if hb_isarray( uId ) 
      cSql     +=    "WHERE id IN ( " 
      aeval( uId, {| v | cSql += if( hb_isarray( v ), toSQLString( atail( v ) ), toSQLString( v ) ) + ", " } )
      cSql     := chgAtEnd( cSql, ' )', 2 )
   end if

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceIdByNumber( nNumber ) 

   local cSql  := "SELECT id FROM " + ::getTableName()         + " " 

   cSql        +=    "WHERE empresa_codigo = " + quoted( cCodEmp() )  + " "  
   
   cSql        +=       "AND numero = " + quoted( nNumber ) 

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceIdByUuid( uuid ) 

   local cSql  := "SELECT id FROM " + ::getTableName()         + " " 

   cSql        +=    "WHERE uuid = " + quoted( uuid ) 

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getLastNumberByUser( cUser )

   local cSql  := "SELECT numero FROM " + ::getTableName()        + " " 

   cSql        +=    "WHERE empresa_codigo = " + quoted( cCodEmp() )     + " "  

   if empty( cUser )
      cSql     +=       "AND usuario_codigo = " + quoted( cUser )        + " " 
   end if 

   cSql        +=    "ORDER BY creado DESC, numero DESC"          + " "
   cSql        +=       "LIMIT 1"
      
RETURN ( cSql )

//---------------------------------------------------------------------------//
   
METHOD getLastNumber( cUser )

   local cNumero  

   DEFAULT cUser  := Auth():Codigo()

   cNumero        := getSqlDataBase():getValue( ::getLastNumberByUser( cUser ) )

   if empty( cNumero )
      cNumero     := getSqlDataBase():getValue( ::getLastNumberByUser() )
   end if 

RETURN ( cNumero )

//---------------------------------------------------------------------------//

METHOD getNextNumber( cUser )

   local cNumero  := ::getLastNumber( cUser ) 

RETURN ( nextDocumentNumber( cNumero ) )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceTotalsForReport( oReporting )

   local cSentence   

   cSentence   := "SELECT "                                                               + ;
                  "movimientos_almacen.id                         AS id, "                + ;
                  "movimientos_almacen.uuid                       AS uuid, "              + ;
                  "movimientos_almacen.numero                     AS numero, "            + ;
                  "CAST( movimientos_almacen.fecha_hora AS date ) AS fecha, "             + ;
                  "CAST( movimientos_almacen.fecha_hora AS time ) AS hora, "              + ;
                  "movimientos_almacen.tipo_movimiento            AS tipo_movimiento, "   + ;
                  SQLMovimientosAlmacenModel():getColumnMovimiento( "movimientos_almacen" ) + ;
                  "movimientos_almacen.fecha_hora                 AS fecha_hora, "        + ;
                  "movimientos_almacen.almacen_origen             AS almacen_origen, "    + ;
                  "movimientos_almacen.almacen_destino            AS almacen_destino, "   + ;
                  SQLMovimientosAlmacenLineasModel():getSQLSubSentenceSumatorioTotalPrecioLinea( "movimientos_almacen_lineas" ) + ", " +;
                  SQLMovimientosAlmacenLineasModel():getSQLSumatorioTotalVentaLinea( "movimientos_almacen_lineas" ) + ", " +;
                  "movimientos_almacen.divisa                     AS divisa, "            + ;
                  "movimientos_almacen.divisa_cambio              AS divisa_cambio, "     + ;
                  "movimientos_almacen.comentarios                AS comentarios, "       + ;        
                  "movimientos_almacen.creado                     AS creado, "            + ;
                  "movimientos_almacen.modificado                 AS modificado, "        + ;
                  "movimientos_almacen.enviado                    AS enviado "            + ;  
               "FROM " + ::getTableName() + " "                                           + ;
                  "INNER JOIN movimientos_almacen_lineas "                                + ;
                  "ON movimientos_almacen.uuid = movimientos_almacen_lineas.parent_uuid " + ;
               "WHERE movimientos_almacen.empresa_codigo = " + quoted( cCodEmp() ) + " "                                     

   if !empty( oReporting )
      cSentence   += "AND "                                     
      cSentence   += "( movimientos_almacen.almacen_origen >= " + quoted(  oReporting:getDesdeAlmacen() ) + " "                                     
      cSentence   += "AND "                                     
      cSentence   += "movimientos_almacen.almacen_origen <= " + quoted(  oReporting:getHastaAlmacen() ) + " ) "                                     
      cSentence   += "OR "                                     
      cSentence   += "( movimientos_almacen.almacen_destino >= " + quoted(  oReporting:getDesdeAlmacen() ) + " "                                     
      cSentence   += "AND "                                     
      cSentence   += "movimientos_almacen.almacen_destino <= " + quoted(  oReporting:getHastaAlmacen() ) + " ) "                                     
   end if 

RETURN ( cSentence )

//---------------------------------------------------------------------------//

METHOD getRowSetTotalsForReport( oReporting )

RETURN ( SQLRowSet():New():Build( ::getSQLSentenceTotalsForReport( oReporting ) ) ) 

//---------------------------------------------------------------------------//
