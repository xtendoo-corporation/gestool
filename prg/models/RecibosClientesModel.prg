#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS RecibosClientesModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "FacCliP" )

   METHOD Riesgo( idCliente )

   METHOD dPrimerReciboPendiente( cCodCli )

END CLASS

//---------------------------------------------------------------------------//

METHOD Riesgo( idCliente )

   local cSql
   local cStm
   local nRiesgo  := 0

   cSql           := "SELECT SUM( nImporte ) AS nRiesgo " + ;
                        "FROM " + ::getTableName() + " " + ;
                        "WHERE cCodCli = " + quoted( idCliente ) + " AND NOT lCobrado AND NOT lPasado"

   if ::ExecuteSqlStatement( cSql, @cStm )
      nRiesgo     += ( cStm )->nRiesgo
   end if 

Return ( nRiesgo )

//---------------------------------------------------------------------------//

METHOD dPrimerReciboPendiente( cCodCli )

   local cSql
   local cStm

   cSql           := "SELECT dPreCob AS fecha " + ;
                        "FROM " + ::getTableName() + " " + ;
                        "WHERE cCodCli = " + quoted( cCodCli ) + " AND NOT lCobrado AND NOT lPasado ORDER BY dPreCob ASC"

   if ::ExecuteSqlStatement( cSql, @cStm )
      ( cStm )->( dbGoTop() )
      Return ( cStm )->fecha
   end if                         

Return ( GetSysDate() )

//---------------------------------------------------------------------------//