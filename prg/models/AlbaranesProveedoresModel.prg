#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS AlbaranesProveedoresModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "AlbProvT" )

   METHOD getField()

END CLASS

//---------------------------------------------------------------------------//

METHOD getField( cSerie, nNumero, cSufijo, cField )

   local cStm  
   local cSql

   cSql              := "SELECT " + cField + " "                              
   cSql              +=    "FROM " + ::getTableName() + " "                   
   cSql              +=    "WHERE cSerAlb = " + quoted( cSerie ) + " AND nNumAlb = " + AllTrim( Str( nNumero ) ) + " AND cSufAlb = " + + quoted( cSufijo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( fieldget( fieldpos( cField ) ) ) )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//