#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS SQLOdooIdsModel FROM SQLCompanyModel

   DATA cTableName               INIT "OdooIds"

   METHOD getColumns()

   METHOD insertOdooId( cTipo, idGestool, idOdoo )
   METHOD insertClienteToOdooId( idGestool, idOdoo )           INLINE ( ::insertOdooId( "cliente", idGestool, idOdoo ) )
   METHOD insertProveedorToOdooId( idGestool, idOdoo )         INLINE ( ::insertOdooId( "proveedor", idGestool, idOdoo ) )
   METHOD insertArticuloToOdooId( idGestool, idOdoo )          INLINE ( ::insertOdooId( "articulo", idGestool, idOdoo ) )

   METHOD deleteTipoDocumento( tipoDocumento )
   METHOD deleteCliente()                                      INLINE ( ::deleteTipoDocumento( "cliente" ) )
   METHOD deleteProveedor()                                    INLINE ( ::deleteTipoDocumento( "proveedor" ) )
   METHOD deleteArticulo()                                     INLINE ( ::deleteTipoDocumento( "articulo" ) )

   METHOD lastCountResPartner()

   METHOD getCountCliente( cCodigo, lNew )                     INLINE ( ::getCount( cCodigo, "cliente", lNew ) )
   METHOD getCountProveedor( cCodigo, lNew )                   INLINE ( ::getCount( cCodigo, "proveedor", lNew ) )

   METHOD getCount( cCodigo, cTipo )

   METHOD SeederToADS()

END CLASS

//---------------------------------------------------------------------------//

METHOD getColumns() CLASS SQLOdooIdsModel
   
   hset( ::hColumns, "id",                         {  "create"    => "INTEGER AUTO_INCREMENT UNIQUE"           ,;
                                                      "default"   => {|| 0 } }                                 )

   hset( ::hColumns, "uuid",                       {  "create"    => "VARCHAR( 40 ) NOT NULL UNIQUE"           ,;
                                                      "default"   => {|| win_uuidcreatestring() } }            )

   ::getEmpresaColumns()

   hset( ::hColumns, "tipo_documento",             {  "create"    => "VARCHAR( 60 )"                           ,;
                                                      "default"   => {|| space( 60 ) } }                       )

   hset( ::hColumns, "codigo_gestool",             {  "create"    => "VARCHAR( 40 )"                           ,;
                                                      "default"   => {|| space( 40 ) } }                       )

   hset( ::hColumns, "id_odoo",                    {  "create"    => "VARCHAR( 40 )"                           ,;
                                                      "default"   => {|| space( 40 ) } }                       )

RETURN ( ::hColumns )

//---------------------------------------------------------------------------//

METHOD insertOdooId( cTipo, idGestool, idOdoo ) CLASS SQLOdooIdsModel

   local nId
   local cSentence   := ""

   cSentence         := "SELECT id_odoo FROM " + ::cTableName + ;
                        " WHERE tipo_documento = " + toSQLString( cTipo ) + " AND " + ;
                           "codigo_gestool = " + toSQLString( idGestool ) + " AND " + ;
                           "id_odoo = " + toSQLString( idOdoo ) + " AND " + ;
                           "empresa_codigo = " + toSQLString( cCodEmp() )

   nId               := getSQLDatabase():getValue( cSentence )

   if Empty( nId )

      cSentence         := "INSERT INTO " + ::cTableName + " ( "                 + ;
                              "uuid, empresa_codigo, usuario_codigo, tipo_documento, codigo_gestool, id_odoo ) " + ;
                           "VALUES  ( "                                          + ;
                              toSQLString( win_uuidcreatestring() ) + ", " + ;
                              toSQLString( cCodEmp() ) + ", " + ;
                              toSQLString( Auth():Codigo() ) + ", " + ;
                              toSQLString( cTipo ) + ", " + ;
                              toSQLString( idGestool ) + ", " + ;
                              toSQLString( idOdoo ) + " )"

      getSQLDatabase():Exec( cSentence  )

   end if

Return .t.

//---------------------------------------------------------------------------//

METHOD deleteTipoDocumento( tipoDocumento ) CLASS SQLOdooIdsModel

   local cSentence   := ""

   cSentence         := "DELETE FROM " + ::cTableName + ;
                        " WHERE tipo_documento = " + toSQLString( tipodocumento ) + " AND " + ;
                           "empresa_codigo = " + toSQLString( cCodEmp() )

   getSQLDatabase():Exec( cSentence  )

Return .t.

//---------------------------------------------------------------------------//

METHOD lastCountResPartner() CLASS SQLOdooIdsModel

   local lastid      := 0
   local cSentence   := ""

   cSentence         := "SELECT id_odoo FROM " + ::cTableName + ;
                        " WHERE tipo_documento IN ( 'cliente', 'proveedor' ) AND " + ;
                           "empresa_codigo = " + toSQLString( cCodEmp() ) + Space( 1 ) + ;
                           "ORDER BY cast(id_odoo as unsigned) DESC LIMIT 1"

   lastid         := getSQLDatabase():getValue( cSentence )

   if ValType( lastid ) == "C"
      lastid      := Val( AllTrim( getSQLDatabase():getValue( cSentence ) ) )
   end if

   if Empty( lastid )
      lastid      := 1
   end if

Return lastid

//---------------------------------------------------------------------------//

METHOD getCount( cCodigo, cTipo, lNew ) CLASS SQLOdooIdsModel

   local nCount      := 0
   local cSentence   := ""

   DEFAULT lNew      := .t.

   cSentence         := "SELECT id_odoo FROM " + ::cTableName + ;
                        " WHERE tipo_documento = " + toSQLString( cTipo ) + " AND " + ;
                           "codigo_gestool = " + toSQLString( cCodigo ) + " AND " + ;
                           "empresa_codigo = " + toSQLString( cCodEmp() )

   nCount            := getSQLDatabase():getValue( cSentence )

   if lNew
      if Empty( nCount )
         nCount         := Str( ::lastCountResPartner() + 1 )
      end if
   end if

Return nCount

//---------------------------------------------------------------------------//

METHOD SeederToADS() CLASS SQLOdooIdsModel

   local cSql  := "SELECT * FROM " + ::getTableName()

RETURN ( getSQLDataBase():selectFetchHash( cSql ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//