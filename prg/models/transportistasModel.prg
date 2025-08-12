#include "FiveWin.Ch"
#include "Factu.ch" 

//------------------------------------------------------------------//

CLASS TransportistasModel FROM ADSBaseModel

   METHOD getTableName()                         INLINE ::getEmpresaTableName( "transpor" )

   METHOD getUuid( cCodigo )                     INLINE ( ::getField( 'uuid', 'cCodTrn', cCodigo ) )

   METHOD InsertFromHashSql( hHashHead, hHashDir )

   METHOD lExisteUuid( uuid )

END CLASS

//---------------------------------------------------------------------------//

METHOD InsertFromHashSql( hHashHead, hHashDir ) CLASS TransportistasModel

	local cStm     := "InsertFromHashSql"
   	local cSql     := ""

   	if !Empty( hHashHead ) .and. !::lExisteUuid( hGet( hHashHead, "uuid" ) ) 

      	cSql         := "INSERT INTO " + ::getTableName() 
      	cSql         += " ( cCodTrn, cNomTrn, cDirTrn, cLocTrn, cCdpTrn, cPrvTrn, cTlfTrn, cMovTrn, nKgsTrn, cMatTrn, cDniTrn, uuid ) VALUES "
      	cSql         += " ( " + quoted( Padr( hGet( hHashHead, "codigo" ), 9 ) )
      	cSql         += ", " + quoted( hGet( hHashHead, "nombre" ) )
         cSql         += ", " + if( Empty( hHashDir ), "''", quoted( hGet( hHashDir[1], "direccion" ) ) )
      	cSql         += ", " + if( Empty( hHashDir ), "''", quoted( hGet( hHashDir[1], "poblacion" ) ) )
      	cSql         += ", " + if( Empty( hHashDir ), "''", quoted( Padr( hGet( hHashDir[1], "codigo_postal" ), 5 ) ) )
      	cSql         += ", " + if( Empty( hHashDir ), "''", quoted( hGet( hHashDir[1], "provincia" ) ) )
		   cSql         += ", " + if( Empty( hHashDir ), "''", quoted( hGet( hHashDir[1], "telefono" ) ) )
      	cSql         += ", " + if( Empty( hHashDir ), "''", quoted( hGet( hHashDir[1], "movil" ) ) )
      	cSql         += ", " + AllTrim( Str( hGet( hHashHead, "tara" ) ) )
      	cSql         += ", " + quoted( hGet( hHashHead, "matricula" ) )
      	cSql         += ", " + quoted( hGet( hHashHead, "dni" ) )
      	cSql         += ", " + quoted( hGet( hHashHead, "uuid" ) ) + " )"

      	::ExecuteSqlStatement( cSql, @cStm )

   	end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lExisteUuid( uuid ) CLASS TransportistasModel

   local cStm     := "lExisteUuid"
   local cSql     := ""

   cSql     := "SELECT * FROM " + ::getTableName() + " WHERE uuid = " + quoted( uuid )

      if ::ExecuteSqlStatement( cSql, @cStm )

         if ( cStm )->( RecCount() ) > 0
            Return ( .t. )
         end if

      end if

Return ( .f. )

//---------------------------------------------------------------------------//