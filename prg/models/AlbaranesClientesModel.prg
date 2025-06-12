#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS AlbaranesClientesModel FROM ADSBaseModel

   METHOD getHeaderTableName()                  INLINE ::getEmpresaTableName( "AlbCliT" )

   METHOD getField( cSerie, nNumero, cSufijo, cField )

   METHOD Riesgo( idCliente )
   
   METHOD UltimoDocumento( idCliente )

   METHOD UpdateFacturado( cNumAlb, nEstado )

   METHOD ListNoFacturados( cCodCli, cCodObr )

   METHOD ListFacturados()

END CLASS

//---------------------------------------------------------------------------//

METHOD getField( cSerie, nNumero, cSufijo, cField )

   local cStm  
   local cSql

   cSql              := "SELECT " + cField + " "                              
   cSql              +=    "FROM " + ::getHeaderTableName() + " "                   
   cSql              +=    "WHERE cSerAlb = " + quoted( cSerie ) + " AND nNumAlb = " + AllTrim( Str( nNumero ) ) + " AND cSufAlb = " + + quoted( cSufijo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( fieldget( fieldpos( cField ) ) ) )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD Riesgo( idCliente )

   local cStm
   local cSql  := "SELECT SUM( nTotAlb - nTotPag ) AS nRiesgo " + ;
                     "FROM " + ::getHeaderTableName() + " " + ;
                     "WHERE cCodCli = " + quoted( idCliente ) + " AND NOT lFacturado"

   if ::ExecuteSqlStatement( cSql, @cStm )
      Return( ( cStm )->nRiesgo )
   end if 

Return ( 0 )

//---------------------------------------------------------------------------//

METHOD UltimoDocumento( idCliente )

   local cStm
   local cSql  := "SELECT TOP 1 dFecAlb " + ;
                     "FROM " + ::getHeaderTableName() + " " + ;
                     "WHERE cCodCli = " + quoted( idCliente ) + " ORDER BY dFecAlb DESC"

   if ::ExecuteSqlStatement( cSql, @cStm )
      Return ( ( cStm )->dFecAlb )
   end if 

Return ( ctod( "" ) )

//---------------------------------------------------------------------------//

METHOD UpdateFacturado( cNumAlb, nEstado )

  local cStm  := "UpdateFacturado"
  local cSql  := ""

  cSql        := "UPDATE " + ::getHeaderTableName()
  cSql        += " SET nFacturado = " + Str( nEstado )
  cSql        += " WHERE cSerAlb = " + quoted( SubStr( cNumAlb, 1, 1 ) )
  cSql        += " AND nNumAlb = " + SubStr( cNumAlb, 2, 9 )
  cSql        += " AND cSufAlb = " + quoted( SubStr( cNumAlb, 11, 2 ) )

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD ListNoFacturados( cCodCli, cCodObr ) CLASS AlbaranesClientesModel

  local cStm  := "ListNoFacturados"
  local cSql
  local aList := {}

  cSql        := "SELECT * "
  cSql        += "FROM " + ::getHeaderTableName() + " "                   
  cSql        += "WHERE nFacturado < 3"

  if !Empty( cCodCli )
    cSql      += " AND cCodCli = " + quoted( cCodCli )
  end if

  if !Empty( cCodObr )
    cSql      += " AND cCodObr = " + quoted( cCodObr )
  end if

  if ::ExecuteSqlStatement( cSql, @cStm )
    aList     := DBHScatter( cStm )
  end if 

Return ( aList )

//---------------------------------------------------------------------------//

METHOD ListFacturados() CLASS AlbaranesClientesModel

  local cStm  := "ListNoFacturados"
  local cSql
  local aList := {}

  cSql        := "SELECT * "
  cSql        += "FROM " + ::getHeaderTableName() + " "                   
  cSql        += "WHERE nFacturado = 3"

  if ::ExecuteSqlStatement( cSql, @cStm )
    aList     := DBHScatter( cStm )
  end if 

Return ( aList )

//---------------------------------------------------------------------------//