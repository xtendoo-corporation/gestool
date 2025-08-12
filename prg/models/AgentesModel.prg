#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS AgentesModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "Agentes" )

   METHOD getUuid( cCodigo )                 INLINE ( ::getField( 'uuid', 'cCodAge', cCodigo ) )

   METHOD exist( cCodigoAgente )

   METHOD getNombre( cCodigoAgente )

   METHOD getComision( cCodigoAgente )       INLINE ( ::getField( 'nCom1', 'cCodAge', cCodigoAgente ) )

   METHOD getEmail( cCodigoAgente )          INLINE ( ::getField( 'cMailAge', 'cCodAge', cCodigoAgente ) )

   METHOD getToOdoo( cArea )

END CLASS

//---------------------------------------------------------------------------//

METHOD exist( cCodigoAgente ) CLASS AgentesModel

   local cStm
   local cSql  := "SELECT cCodAge "                               + ;
                     "FROM " + ::getTableName() + " "             + ;
                     "WHERE cCodAge = " + quoted( cCodigoAgente ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD getNombre( cCodigoAgente ) CLASS AgentesModel

   local cStm
   local cSql  := "SELECT cApeAge, cNbrAge "                      + ;
                     "FROM " + ::getTableName() + " "             + ;
                     "WHERE cCodAge = " + quoted( cCodigoAgente ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( alltrim( ( cStm )->cNbrAge ) + Space(1) + alltrim( ( cStm )->cApeAge ) )
   end if 

RETURN ( "" )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS AgentesModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//