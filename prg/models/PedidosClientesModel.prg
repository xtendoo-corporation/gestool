#include "fivewin.ch"
#include "factu.ch" 
#include "hdo.ch"

//---------------------------------------------------------------------------//

CLASS PedidosClientesModel FROM TransaccionesComercialesLineasModel

  METHOD getTableName()                           INLINE ::getEmpresaTableName( "PedCliT" )

  METHOD getField( cSerie, nNumero, cSufijo, cField )

  METHOD existInWP( cId )

END CLASS

//---------------------------------------------------------------------------//

METHOD getField( cSerie, nNumero, cSufijo, cField ) CLASS PedidosClientesModel

   local cStm  
   local cSql

   cSql              := "SELECT " + cField + " "                              
   cSql              +=    "FROM " + ::getTableName() + " "                   
   cSql              +=    "WHERE cSerPed = " + quoted( cSerie ) + " AND nNumPed = " + AllTrim( Str( nNumero ) ) + " AND cSufPed = " + + quoted( cSufijo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( fieldget( fieldpos( cField ) ) ) )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD existInWP( cId ) CLASS PedidosClientesModel

   local cStm
   local cSql  := "SELECT * "                                   + ;
                     "FROM " + ::getTableName() + " "             + ;
                     "WHERE cIdWP = " + quoted( cId ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//