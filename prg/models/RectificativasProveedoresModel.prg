#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS RectificativasProveedoresModel FROM TransaccionesComercialesLineasModel

   	METHOD getTableName()                           INLINE ::getEmpresaTableName( "RctPrvT" )

	METHOD getField( cSerie, nNumero, cSufijo, cField )

END CLASS

//---------------------------------------------------------------------------//

METHOD getField( cSerie, nNumero, cSufijo, cField )

   local cStm  
   local cSql

   cSql              := "SELECT " + cField + " "                              
   cSql              +=    "FROM " + ::getTableName() + " "                   
   cSql              +=    "WHERE cSerFac = " + quoted( cSerie ) + " AND nNumFac = " + AllTrim( Str( nNumero ) ) + " AND cSufFac = " + + quoted( cSufijo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( fieldget( fieldpos( cField ) ) ) )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

