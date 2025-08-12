#include "FiveWin.Ch"
#include "Factu.ch" 

//------------------------------------------------------------------//

CLASS FamiliasModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "Familias" )

   METHOD exist()

   METHOD getNombre( cCodigoFamilia )        INLINE ( ::getField( 'cNomFam', 'cCodFam', cCodigoFamilia ) )

   METHOD getGrupo( cCodigoFamilia )

   METHOD getToOdoo( cArea )

   METHOD getNamesFromIdLanguagesPS( cCodFam, aIdsLanguages )

   METHOD getListToWP()

   METHOD updateWpId( cIdWP, cCodFam )

END CLASS

//---------------------------------------------------------------------------//

METHOD exist( cCodigoFamilia )

   local cStm  
   local cSql  := "SELECT cNomFam "                                     + ;
                     "FROM " + ::getTableName() + " "                   + ;
                     "WHERE cCodFam = " + quoted( cCodigoFamilia ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD getGrupo( cCodigoFamilia )

   local cCodGrp  := ::getField( 'cCodFam', 'cCodGrp', cCodigoFamilia )

RETURN ( if( Empty( cCodGrp ), Space( 3 ), Padr( cCodGrp, 3 ) ) )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS FamiliasModel

      local cSql     := "SELECT * FROM " + ::getTableName()
      cSql           += " WHERE lSelDoc"

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD getListToWP() CLASS FamiliasModel

      local cStm     := "getToWPFamilias"
      local cSql     := ""
      local aList    := {}

      cSql           := "SELECT * FROM " + ::getTableName()

      if ::ExecuteSqlStatement( cSql, @cStm )
         aList       := DBHScatter( cStm )
      end if 

RETURN ( aList )

//---------------------------------------------------------------------------//

METHOD updateWpId( cIdWP, cCodFam ) CLASS FamiliasModel

   local cStm     := "updateWpId"
   local cSql     := ""
   local aList    := {}

   cSql           := "UPDATE " + ::getTableName()
   cSql           += " SET cIdWP = " + quoted( cIdWP )
   cSql           += " WHERE cCodFam = " + quoted( cCodFam )

   ::ExecuteSqlStatement( cSql, @cStm )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD getNamesFromIdLanguagesPS( cCodFam, aIdsLanguages )

   local cName
   local hNames   := {=>}

   if Len( aIdsLanguages ) == 0
      Return ( hNames )
   end if

   cName    := ::getNombre( cCodFam )

   if Empty( cName )
      Return ( hNames )
   end if

   aEval( aIdsLanguages, {|id| hSet( hNames, AllTrim( Str( id ) ), AllTrim( cName ) ) } )

RETURN ( hNames )

//---------------------------------------------------------------------------//