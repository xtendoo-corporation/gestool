#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS FacturasClientesModel FROM ADSBaseModel

   METHOD getHeaderTableName()                  INLINE ::getEmpresaTableName( "FacCliT" )

   METHOD UltimoDocumento( cCodigoCliente )

   METHOD defaultSufijo()

   METHOD getInsertStatement( hFields )

   METHOD getField( cSerie, nNumero, cSufijo, cField )

END CLASS

//---------------------------------------------------------------------------//

METHOD getField( cSerie, nNumero, cSufijo, cField )

   local cStm  
   local cSql

   cSql              := "SELECT " + cField + " "                              
   cSql              +=    "FROM " + ::getHeaderTableName() + " "                   
   cSql              +=    "WHERE cSerie = " + quoted( cSerie ) + " AND nNumFac = " + AllTrim( Str( nNumero ) ) + " AND cSufFac = " + + quoted( cSufijo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( fieldget( fieldpos( cField ) ) ) )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD UltimoDocumento( cCodigoCliente )

   local cStm
   local cSql  := "SELECT TOP 1 dFecFac " + ;
                     "FROM " + ::getHeaderTableName() + " " + ;
                     "WHERE cCodCli = " + quoted( cCodigoCliente ) + " ORDER BY dFecFac DESC"

   if ::ExecuteSqlStatement( cSql, @cStm )
      Return ( ( cStm )->dFecFac )
   end if 

Return ( ctod( "" ) )

//---------------------------------------------------------------------------//

METHOD defaultSufijo()

   local cStm
   local cSql  := "UPDATE " + ::getHeaderTableName() + ;
                     " SET cSufFac = '00'" + ;
                     " WHERE cSufFac = ''"

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD getInsertStatement( hFields )

   local cStatement  

   cStatement           := "INSERT INTO " + ::getHeaderTableName() + " "  
   cStatement           += "( " 
   
      hEval( hFields,   {| k, v | cStatement += k + ", " } )
   cStatement           := chgAtEnd( cStatement, " ) VALUES ( ", 2 )

      hEval( hFields,   {| k, v | cStatement += toAdsSQLString( v ) + ", " } )
   cStatement           := chgAtEnd( cStatement, " )", 2 )

RETURN ( cStatement )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

Function getFechaFactura( cNumFac )

   local cSerie 
   local nNumero
   local cSufijo

   if Empty( cNumFac )
      Return ( ctod( "" ) )
   end if

   cSerie   := SubStr( cNumFac, 1, 1 )
   nNumero  := Val( SubStr( cNumFac, 2, 9 ) )
   cSufijo  := SubStr( cNumFac, 11, 2 )

Return( FacturasClientesModel():getField( cSerie, nNumero, cSufijo, "dFecFac" ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS FacturasClientesCobrosModel FROM ADSBaseModel

   METHOD getHeaderTableName()                  INLINE ::getEmpresaTableName( "FacCliP" )

   METHOD dFechaCobro( cSerie, nNumero, cSufijo )

END CLASS

//---------------------------------------------------------------------------//

METHOD dFechaCobro( cSerie, nNumero, cSufijo )

   local cStm
   local cSql  := "SELECT TOP 1 dEntrada " + ;
                     "FROM " + ::getHeaderTableName() + " " + ;
                     "WHERE cSerie = " + quoted( cSerie ) + " AND " + ;
                     "nNumFac = " + AllTrim( Str( nNumero ) ) + " AND " + ;
                     "cSufFac = " + quoted( cSufijo )

   if ::ExecuteSqlStatement( cSql, @cStm )
      Return ( ( cStm )->dEntrada )
   end if 

Return ( ctod( "" ) )

//---------------------------------------------------------------------------//