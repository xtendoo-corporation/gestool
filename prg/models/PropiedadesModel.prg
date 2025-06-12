#include "fivewin.ch"
#include "factu.ch" 
#include "hdo.ch"

//---------------------------------------------------------------------------//

CLASS PropiedadesModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "Pro" )

   MESSAGE getNombre( cCodigoPropiedad )     INLINE ::getField( "cDesPro", "cCodPro", cCodigoPropiedad )

   METHOD getNamesFromIdLanguagesPS( cCodigoPropiedad, aIdsLanguages )

   METHOD getListToWP()

   METHOD updateWpId( cIdWP, cCodPrp )

   METHOD getToOdoo( cArea )

END CLASS

//---------------------------------------------------------------------------//

METHOD getNamesFromIdLanguagesPS( cCodigoPropiedad, aIdsLanguages ) CLASS PropiedadesModel

   local cName
   local hNames   := {=>}

   if Len( aIdsLanguages ) == 0
      Return ( hNames )
   end if

   cName    := ::getNombre( cCodigoPropiedad )

   if Empty( cName )
      Return ( hNames )
   end if

   aEval( aIdsLanguages, {|id| hSet( hNames, AllTrim( Str( id ) ), AllTrim( cName ) ) } )

RETURN ( hNames )

//---------------------------------------------------------------------------//

METHOD getListToWP() CLASS PropiedadesModel

   local cArea := "getListToWP"
   local cSql  := ""

   cSql        += "SELECT * FROM " + ::getTableName()

   if ::ExecuteSqlStatement( cSql, @cArea )
      Return ( DBHScatter( cArea ) )
   end if

RETURN ( {} )

//---------------------------------------------------------------------------//

METHOD updateWpId( cIdWP, cCodPrp ) CLASS PropiedadesModel

   local cStm     := "updateWpId"
   local cSql     := ""
   local aList    := {}

   cSql           := "UPDATE " + ::getTableName()
   cSql           += " SET cIdWP = " + quoted( cIdWP )
   cSql           += " WHERE cCodPro = " + quoted( cCodPrp )

   ::ExecuteSqlStatement( cSql, @cStm )


RETURN ( self )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS PropiedadesModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS PropiedadesLineasModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "TblPro" )

   METHOD exist()

   METHOD getNombre()

   METHOD getColor()

   METHOD getPropiedadesGeneral( cCodigoPropiedad )

   METHOD getListToWP( cCodPrp )

   METHOD updateWpId( cIdWP, cCodPrp, cCodTbl )

   METHOD getToOdoo( cArea )

END CLASS

//---------------------------------------------------------------------------//

METHOD exist( cCodigoPropiedad, cValorPropiedad ) CLASS PropiedadesLineasModel

   local cStm
   local cSql  := "SELECT cDesTbl "                                     		+ ;
                     "FROM " + ::getTableName() + " "                   		+ ;
                     "WHERE cCodPro = " + quoted( cCodigoPropiedad ) + " " 	+ ;
                     	"AND cCodTbl = " + quoted( cValorPropiedad )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( "" )

//---------------------------------------------------------------------------//

METHOD getNombre( cCodigoPropiedad, cValorPropiedad ) CLASS PropiedadesLineasModel

   local cStm
   local cSql  := "SELECT cDesTbl "                                     		+ ;
                     "FROM " + ::getTableName() + " "                   		+ ;
                     "WHERE cCodPro = " + quoted( cCodigoPropiedad ) + " " 	+ ;
                     	"AND cCodTbl = " + quoted( cValorPropiedad )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( alltrim( ( cStm )->cDesTbl ) )
   end if 

RETURN ( "" )

//---------------------------------------------------------------------------//

METHOD getColor( cCodigoPropiedad, cValorPropiedad ) CLASS PropiedadesLineasModel

   local cStm
   local cSql  := "SELECT nColor "                                           + ;
                     "FROM " + ::getTableName() + " "                         + ;
                     "WHERE cCodPro = " + quoted( cCodigoPropiedad ) + " "    + ;
                        "AND cCodTbl = " + quoted( cValorPropiedad )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->nColor )
   end if 

RETURN ( 0 )

//---------------------------------------------------------------------------//

METHOD getPropiedadesGeneral( cCodigoArticulo, cCodigoPropiedad )

   local aPropiedades   := {}
   local cStm
   local cSql           := "SELECT "                                                            + ;
                              "header.cDesPro AS TipoPropiedad, "                               + ; 
                              "header.lColor AS ColorPropiedad, "                               + ; 
                              "line.cCodTbl AS ValorPropiedad, "                                + ; 
                              "line.nColor AS RgbPropiedad, "                                   + ; 
                              "line.cDesTbl AS CabeceraPropiedad "                              + ;
                           "FROM " + ::getTableName() + " line "                                + ;
                              "INNER JOIN " + PropiedadesModel():getTableName() + " header "    + ;
                              "ON header.cCodPro = " + quoted( cCodigoPropiedad )         

   if ::ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbeval( ;
         {|| aadd( aPropiedades ,;
            {  "CodigoArticulo"     => rtrim( cCodigoArticulo ),;
               "CodigoPropiedad"    => rtrim( cCodigoPropiedad ),;
               "TipoPropiedad"      => rtrim( Field->TipoPropiedad ),;
               "ValorPropiedad"     => rtrim( Field->ValorPropiedad ),;
               "CabeceraPropiedad"  => rtrim( Field->CabeceraPropiedad ),;
               "ColorPropiedad"     => Field->ColorPropiedad,;
               "RgbPropiedad"       => Field->RgbPropiedad } ) } ) )
   
   end if 

RETURN ( aPropiedades )

//---------------------------------------------------------------------------//

METHOD getListToWP( cCodPrp ) CLASS PropiedadesLineasModel

   local cArea := "getListToWP"
   local cSql  := ""

   cSql        += "SELECT * FROM " + ::getTableName()
   cSql        += " WHERE cCodPro = " + quoted( cCodPrp )

   if ::ExecuteSqlStatement( cSql, @cArea )
      Return ( DBHScatter( cArea ) )
   end if

RETURN ( {} )

//---------------------------------------------------------------------------//

METHOD updateWpId( cIdWP, cCodPrp, cCodTbl ) CLASS PropiedadesLineasModel

   local cStm     := "updateWpId"
   local cSql     := ""
   local aList    := {}

   cSql           := "UPDATE " + ::getTableName()
   cSql           += " SET cIdWP = " + quoted( cIdWP )
   cSql           += " WHERE cCodPro = " + quoted( cCodPrp )
   cSql           += " AND cCodTbl = " + quoted( cCodTbl )

   ::ExecuteSqlStatement( cSql, @cStm )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS PropiedadesLineasModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//