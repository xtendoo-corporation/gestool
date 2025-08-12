#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS FacturasProveedoresModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "FacPrvT" )

   METHOD getField()

END CLASS

//---------------------------------------------------------------------------//

METHOD getField( cSerie, nNumero, cSufijo, cField ) CLASS FacturasProveedoresModel

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