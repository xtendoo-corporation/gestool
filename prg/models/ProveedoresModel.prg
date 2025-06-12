#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS ProveedoresModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "Provee" )

   METHOD getToOdoo( cArea )

END CLASS

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS ProveedoresModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

   cSql        += " WHERE lSndInt"

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ProveedoresBancosModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "PrvBnc" )

   METHOD getToOdoo( cArea, cCodPrv )

END CLASS

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea, cCodPrv ) CLASS ProveedoresBancosModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

   cSql        += " WHERE cCodPrv = " + quoted( cCodPrv )

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//