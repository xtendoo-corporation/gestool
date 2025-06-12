#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TicketsClientesModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "TikeT" )

   METHOD Riesgo( idCliente )

   METHOD existId() 
   METHOD existUuid()

   METHOD hTicketsPendientesFromCliente( idCliente )

   METHOD getField( cSerie, nNumero, cSufijo, cField )

   METHOD updateDelete( cuuid )

   METHOD recuperar( cUuid )

   METHOD getNumeroFromUuid( uuid )
   METHOD getClienteFromUuid( uuid )
   METHOD getFechaHoraFromUuid( uuid )

   METHOD getToOdoo( cArea )

END CLASS

//---------------------------------------------------------------------------//

METHOD getField( cSerie, nNumero, cSufijo, cField )

   local cStm  
   local cSql

   cSql              := "SELECT " + cField + " "                              
   cSql              +=    "FROM " + ::getTableName() + " "                   
   cSql              +=    "WHERE cSerTik = " + quoted( cSerie ) + " AND cNumTik = " + quoted( nNumero ) + " AND cSufTik = " + + quoted( cSufijo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( fieldget( fieldpos( cField ) ) ) )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getNumeroFromUuid( uuid ) CLASS TicketsClientesModel

   local cStm        := "getNumeroFromUuid" 
   local cSql

   cSql              := "SELECT * "
   cSql              +=    "FROM " + ::getTableName() + " "                   
   cSql              +=    "WHERE uuid = " + quoted( uuid )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->cSerTik + "/" + AllTrim( ( cStm )->cNumTik ) + "/" + ( cStm )->cSufTik )
   end if 

RETURN ( Space( 200 ) )

//---------------------------------------------------------------------------//

METHOD getClienteFromUuid( uuid ) CLASS TicketsClientesModel

   local cStm        := "getClienteFromUuid" 
   local cSql

   cSql              := "SELECT * "
   cSql              +=    "FROM " + ::getTableName() + " "                   
   cSql              +=    "WHERE uuid = " + quoted( uuid )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( AllTrim( ( cStm )->cCliTik ) + " - " + AllTrim( ( cStm )->cNomTik ) )
   end if 

RETURN ( Space( 200 ) )

//---------------------------------------------------------------------------//

METHOD getFechaHoraFromUuid( uuid ) CLASS TicketsClientesModel

   local cStm        := "getClienteFromUuid" 
   local cSql

   cSql              := "SELECT * "
   cSql              +=    "FROM " + ::getTableName() + " "                   
   cSql              +=    "WHERE uuid = " + quoted( uuid )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( AllTrim( dToc( ( cStm )->dFecTik ) ) + " - " + AllTrim( ( cStm )->cHorTik ) )
   end if 

RETURN ( Space( 200 ) )

//---------------------------------------------------------------------------//

METHOD Riesgo( idCliente ) CLASS TicketsClientesModel

   local cSql
   local cStm
   local nRiesgo  := 0

   cSql           := "SELECT SUM( nTotTik - nCobTik ) AS nRiesgo " + ;
                        "FROM " + ::getTableName() + " " + ;
                        "WHERE cCliTik = " + quoted( idCliente ) + " AND lLiqTik AND ( cTipTik = '1' OR cTipTik = '7' )"

   if ::ExecuteSqlStatement( cSql, @cStm )
      nRiesgo     += ( cStm )->nRiesgo
   end if 

RETURN ( nRiesgo )

//---------------------------------------------------------------------------//

METHOD existId( cSerie, nNumero, cSufijo ) CLASS TicketsClientesModel

   local cStm
   local cSql  := "SELECT TOP 1 cNumTik"                                   + " " + ;
                     "FROM " + ::getTableName()                            + " " + ;
                  "WHERE cSerTik + LTRIM( cNumTik ) + cSufTik = " + quoted( cSerie + alltrim( str( nNumero ) ) + cSufijo )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( !empty( ( cStm )->( fieldget( 1 ) ) ) )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD existUuid( uuid ) CLASS TicketsClientesModel

   local cStm
   local cSql  := "SELECT TOP 1 cNumTik"                                   + " " + ;
                     "FROM " + ::getTableName()                            + " " + ;
                  "WHERE uuid = " + quoted( uuid )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( !empty( ( cStm )->( fieldget( 1 ) ) ) )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD hTicketsPendientesFromCliente( idCliente ) CLASS TicketsClientesModel

   local cSql
   local cStm
   local nRiesgo  := 0

   cSql           := "SELECT cSerTik, cNumTik, cSufTik, dFecTik, nTotTik " + ;
                        "FROM " + ::getTableName() + " " + ;
                        "WHERE cCliTik = " + quoted( idCliente ) + " AND NOT lPgdTik AND NOT lAbierto AND cTipTik = '1'"

   ::ExecuteSqlStatement( cSql, @cStm )

RETURN ( cStm )

//---------------------------------------------------------------------------//

METHOD updateDelete( cuuid ) CLASS TicketsClientesModel

   local cStm  := "UpdateDeleteCabecera"
   local cSql  := "UPDATE " + ::getTableName() + ;
                     " SET lDelete = .t." + ;
                     " WHERE uuid = '" + cuuid + "'"

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD recuperar( cUuid ) CLASS TicketsClientesModel

   local cStm  := "recuperarcabecera"
   local cSql  := "UPDATE " + ::getTableName() + ;
                     " SET lDelete = .f." + ;
                     " WHERE uuid = '" + cUuid + "'"

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS TicketsClientesModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//