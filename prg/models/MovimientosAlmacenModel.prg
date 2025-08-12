#include "fivewin.ch"
#include "factu.ch" 
#include "hdo.ch"

//---------------------------------------------------------------------------//

CLASS MovimientosAlmacenModel FROM ADSBaseModel

   METHOD getTableName()           		INLINE ::getEmpresaTableName( "RemMovT" )

   METHOD InsertFromHashSql()

   METHOD lExisteUuid( uuid )
   
END CLASS

//---------------------------------------------------------------------------//

METHOD InsertFromHashSql( hHash )

	local cStm 		:= "InsertFromHashSql"
	local cSql 		:= ""

	if !Empty( hHash ) .and. !::lExisteUuid( hGet( hHash, "uuid" ) ) 

	   cSql         := "INSERT INTO " + ::getTableName() 
	   cSql         += " ( lSelDoc, nNumRem, cSufRem, nTipMov, cCodUsr, cCodDlg, dFecRem, cTimRem, cAlmOrg, cAlmDes, cCodDiv, nVdvDiv, cComMov, cGuid ) VALUES "
	   cSql         += " ( .t., " + allTrim( hGet( hHash, "numero" ) )
	   cSql         += ", " + quoted( RetSufEmp() )
	   cSql         += ", " + AllTrim( Str( hGet( hHash, "tipo_movimiento" ) ) )
	   cSql         += ", " + quoted( Auth():Codigo() )
	   cSql         += ", " + quoted( RetSufEmp() )
	   cSql         += ", " + quoted( dToc( hb_ttod( hGet( hHash, "fecha_hora" ) ) ) )
	   cSql         += ", " + quoted( StrTran( substr( hb_tstostr( hGet( hHash, "fecha_hora" ) ), 12, 8 ), ":", "" ) )
	   cSql         += ", " + quoted( hGet( hHash, "almacen_origen" ) )
	   cSql         += ", " + quoted( hGet( hHash, "almacen_destino" ) )
	   cSql         += ", " + quoted( hGet( hHash, "divisa" ) )
	   cSql         += ", " + AllTrim( Str( hGet( hHash, "divisa_cambio" ) ) )
	   cSql         += ", " + quoted( Padr( hGet( hHash, "comentarios" ), 100 ) )
	   cSql         += ", " + quoted( hGet( hHash, "uuid" ) ) + " )"

	   ::ExecuteSqlStatement( cSql, @cStm )

	end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lExisteUuid( uuid )

	local cStm 		:= "lExisteUuid"
	local cSql 		:= ""

	cSql     := "SELECT * FROM " + ::getTableName() + " WHERE cGuid = " + quoted( uuid )

   	if ::ExecuteSqlStatement( cSql, @cStm )

      	if ( cStm )->( RecCount() ) > 0
         	Return ( .t. )
      	end if

   	end if

Return ( .f. )

//---------------------------------------------------------------------------//