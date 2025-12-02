#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------// 

CLASS RectificativasClientesModel   FROM TransaccionesComercialesLineasModel

   	METHOD getTableName()                  INLINE ::getEmpresaTableName( "FacRecT" )

	   METHOD getField( cSerie, nNumero, cSufijo, cField )

      METHOD SetEstadoVeriFactu( uuid, nEstado )

END CLASS

//---------------------------------------------------------------------------//

METHOD getField( cSerie, nNumero, cSufijo, cField )

   local cStm  
   local cSql

   cSql              := "SELECT " + cField + " "                              
   cSql              +=    "FROM " + ::getTableName() + " "                   
   cSql              +=    "WHERE cSerie = " + quoted( cSerie ) + " AND nNumFac = " + AllTrim( Str( nNumero ) ) + " AND cSufFac = " + + quoted( cSufijo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( fieldget( fieldpos( cField ) ) ) )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD SetEstadoVeriFactu( uuid, nEstado ) CLASS RectificativasClientesModel

   local cStm :=  "ActualVeriFactu"
   local cStm2 :=  "CambioVeriFactu"
   local cSql

   cSql  :=   "SELECT nEstVeri FROM " + ::getTableName() + " WHERE cGuid = " + quoted( uuid )

   ::ExecuteSqlStatement( cSql, @cStm )
   
   if ( cStm )->nEstVeri != 3

      cSql  :=   "UPDATE " + ::getTableName() + ;
                           " SET nEstVeri = " + AllTrim( Str( nEstado ) ) + ;
                           " WHERE cGuid = " + quoted( uuid )   
      
      ::ExecuteSqlStatement( cSql, @cStm2 )
   
   end if
   
Return ( .t. )

//---------------------------------------------------------------------------//