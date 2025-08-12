#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TicketsClientesPagosModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "TikeP" )

   METHOD updateDelete( cuuid )

   METHOD recuperar( cUuid )

END CLASS

//---------------------------------------------------------------------------//

METHOD updateDelete( cuuid ) CLASS TicketsClientesPagosModel

   local cStm 	:= "UpdateDeletePagos"
   local cSql   := "UPDATE " + ::getTableName() + ;
                    " SET lDelete = .t." + ;
                    " WHERE paruuid = '" + cuuid + "'"

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD recuperar( cUuid ) CLASS TicketsClientesPagosModel

   local cStm  := "recuperarPagos"
   local cSql  := "UPDATE " + ::getTableName() + ;
                     " SET lDelete = .f." + ;
                     " WHERE paruuid = '" + cUuid + "'" 

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//