#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS PedidosProveedoresModel FROM ADSBaseModel

   CLASSDATA cHeader                            INIT  "Header"

   METHOD getHeaderTableName()                  INLINE ::getEmpresaTableName( "PedProvT" )
   METHOD getLineTableName()                    INLINE ::getEmpresaTableName( "PedProvL" )
   METHOD getIncidenceTableName()               INLINE ::getEmpresaTableName( "PedPrvI" )
   METHOD getDocumentsTableName()               INLINE ::getEmpresaTableName( "PedPrvD" )

   METHOD selectLineasEmpty( cArea )            

   METHOD selectDocumentosEmpty( cArea )            

   METHOD selectLineasById( cSerie, nNumero, cSufijo, cArea ) ;
                                                INLINE ::selectById( cSerie, nNumero, cSufijo, ::getLineTableName(), @cArea )

   METHOD selectDocumentosById( cSerie, nNumero, cSufijo, cArea ) ;
                                                INLINE ::selectById( cSerie, nNumero, cSufijo, ::getDocumentsTableName(), @cArea )

   METHOD selectById( cSerie, nNumero, cSufijo, cTableName )   

   METHOD deleteLineasById( cSerie, nNumero, cSufijo ) ;
                                                INLINE ::deleteById( cSerie, nNumero, cSufijo, ::getLineTableName() ) 

   METHOD deleteIncidenciasById( cSerie, nNumero, cSufijo ) ;
                                                INLINE ::deleteById( cSerie, nNumero, cSufijo, ::getIncidenceTableName() )

   METHOD deleteDocumentosById( cSerie, nNumero, cSufijo ) ;
                                                INLINE ::deleteById( cSerie, nNumero, cSufijo, ::getDocumentsTableName() )


   METHOD deleteById( cSerie, nNumero, cSufijo, cTableName )

   METHOD getField( cSerie, nNumero, cSufijo, cField )

   METHOD generateWhere( cSerie, nNumero, cSufijo ) ;
                                                INLINE ( "WHERE " + ;
                                                            "cSerPed = " + quoted( cSerie )  + " AND " + ;
                                                            "nNumPed = " + quoted( nNumero ) + " AND " + ;
                                                            "cSufPed = " + quoted( cSufijo ) )

END CLASS

//---------------------------------------------------------------------------//

METHOD getField( cSerie, nNumero, cSufijo, cField )

   local cStm  
   local cSql

   cSql              := "SELECT " + cField + " "                              
   cSql              +=    "FROM " + ::getHeaderTableName() + " "                   
   cSql              +=    "WHERE cSerPed = " + quoted( cSerie ) + " AND nNumPed = " + AllTrim( Str( nNumero ) ) + " AND cSufPed = " + + quoted( cSufijo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( fieldget( fieldpos( cField ) ) ) )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD selectLineasEmpty( cArea )

   local cSql  := "SELECT * FROM " + ::getLineTableName() + " WHERE cSerPed = ''"

Return ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD selectDocumentosEmpty( cArea )

   local cSql  := "SELECT * FROM " + ::getDocumentsTableName() + " WHERE cSerPed = ''"

Return ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD selectById( cSerie, nNumero, cSufijo, cTableName, cArea )

   local cSql  := "SELECT * FROM " + cTableName + " " + ::generateWhere( cSerie, nNumero, cSufijo )

Return ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD deleteById( cSerie, nNumero, cSufijo, cTableName )        

   local cSql  := "DELETE FROM " + cTableName + " " + + ::generateWhere( cSerie, nNumero, cSufijo )   

Return ( ::ExecuteSqlStatement( cSql ) )

//---------------------------------------------------------------------------//