#include "FiveWin.Ch"
#include "Factu.ch" 

//------------------------------------------------------------------//

CLASS ArticulosModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "Articulo" )

   METHOD exist()

   METHOD existName( cNombreArticulo )

   METHOD get()

   METHOD getUuid( cCodigoArticulo )               INLINE ( ::getField( 'Uuid', 'Codigo', cCodigoArticulo ) )
   
   METHOD getNombre( cCodigoArticulo )             INLINE ( ::getField( 'Nombre', 'Codigo', cCodigoArticulo ) )

   METHOD getHash()

   METHOD getArticulosToJson()

   METHOD getArticulosToImport( cArea, hRange ) 

   METHOD getValoresPropiedades( cCodPro )

   METHOD getPrimerValorPropiedad( cCodPro, cArea )

   METHOD getArticulosToPrestaShopInFamilia( idFamilia, cWebShop, cArea )

   METHOD getListArticulos()
   METHOD aListArticulo()                          INLINE ( DBHScatter( ::getListArticulos() ) )

   METHOD aListWebArticulos()
   
   METHOD getToOdoo( cArea )

   METHOD updateCosto( cCodArt, nCosto )

   METHOD lExistContadores()

   METHOD getNamesFromIdLanguagesPS( cCodArt, aIdsLanguages )

   METHOD getListToWP()

   METHOD updateWpId( cIdWP, cCodArt )

END CLASS

//---------------------------------------------------------------------------//

METHOD exist( cCodigoArticulo )

   local cStm  
   local cSql  := "SELECT Nombre "                                      + ;
                     "FROM " + ::getTableName() + " "                   + ;
                     "WHERE Codigo = " + quoted( cCodigoArticulo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD existName( cNombreArticulo )

   local cStm  
   local cSql  := "SELECT Nombre "                                      + ;
                     "FROM " + ::getTableName() + " "                   + ;
                     "WHERE Nombre = " + quoted( cNombreArticulo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD get( cCodigoArticulo )

   local cStm  
   local cSql  := "SELECT * "                                           + ;
                     "FROM " + ::getTableName() + " "                   + ;
                     "WHERE Codigo = " + quoted( cCodigoArticulo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getHash( cCodigoArticulo )

   local cStm 
   local hRecord  
   
   cStm           := ::get( cCodigoArticulo )

   if !empty( cStm ) .and. ( ( cStm )->( lastrec() ) > 0 )
      hRecord     := getHashFromWorkArea( cStm )
   end if 

RETURN ( hRecord )

//---------------------------------------------------------------------------//

METHOD getValoresPropiedades( cCodPro, cArea ) CLASS ArticulosModel

   local cSql  := "SELECT * FROM " + ::getEmpresaTableName( "TblPro" )     + ;
                     " WHERE cCodPro = " + quoted( cCodPro )

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD getPrimerValorPropiedad( cCodPro, cArea ) CLASS ArticulosModel

   local cSql  := "SELECT TOP 1 * FROM " + ::getEmpresaTableName( "TblPro" ) + ;
                     " WHERE cCodPro = " + quoted( cCodPro ) + ""

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD getArticulosToPrestaShopInFamilia( idFamilia, cWebShop, cArea ) CLASS ArticulosModel

   local cSql  := "SELECT Codigo, cWebShop FROM " + ::getTableName()       + ;
                     " WHERE Familia = " + quoted( idFamilia ) + " AND "   + ;
                        "cWebShop = " + quoted( cWebShop ) + " AND "       + ;        
                        "lPubInt"

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD getArticulosToJson( cArea ) CLASS ArticulosModel

   local cSql  := "SELECT Articulos.Codigo, "                  + ;
                     "Articulos.Nombre, "                      + ;
                     "Articulos.pVenta1, "                     + ;
                     "Articulos.pVtaIva1, "                    + ;
                     "Articulos.uuid, "                        + ;
                     "CodigosBarras.cCodBar, "                 + ;
                     "TipoIva.TpIva "                          + ;
                  "FROM " + ::getTableName() + " Articulos "   + ;
                     "LEFT JOIN " + ArticulosCodigosBarraModel():getTableName() + " CodigosBarras ON Articulos.Codigo = CodigosBarras.cCodArt " + ;
                     "INNER JOIN DATOSTIva TipoIva ON Articulos.tipoIva = TipoIva.Tipo " + ;
                  "WHERE NOT Articulos.lObs"

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD getArticulosToImport( cArea, hRange ) CLASS ArticulosModel

   local cSql  := "SELECT Codigo, Nombre, pCosto"                                      + " " + ;
                  "FROM " + ::getTableName()                                           + " " + ;
                     "WHERE Familia >= "  + quoted( hRange[ "FamiliaInicio" ] )        + " " + ;
                        "AND Familia <= " + quoted( hRange[ "FamiliaFin" ] )           + " " + ;
                        "AND cCodTip >= " + quoted( hRange[ "TipoArticuloInicio" ] )   + " " + ;
                        "AND cCodTip <= " + quoted( hRange[ "TipoArticuloFin" ] )      + " " + ;
                        "AND Codigo >= "  + quoted( hRange[ "ArticuloInicio" ] )       + " " + ;
                        "AND Codigo <= "  + quoted( hRange[ "ArticuloFin" ] )     

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD getListArticulos( cArea ) CLASS ArticulosModel

   local cSql  := "SELECT * FROM " + ::getTableName()

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD aListWebArticulos() CLASS ArticulosModel

   local cArea := "aListWebArticulos"
   local cSql  := ""

   cSql        += "SELECT Codigo FROM " + ::getTableName()
   cSql        += " WHERE lPubInt"

   if ::ExecuteSqlStatement( cSql, @cArea )
      Return ( DBHScatter( cArea ) )
   end if

RETURN ( {} )

//---------------------------------------------------------------------------//

METHOD getListToWP() CLASS ArticulosModel

   local cArea := "getListToWP"
   local cSql  := ""

   cSql        += "SELECT * FROM " + ::getTableName()
   cSql        += " WHERE lPubInt"

   if ::ExecuteSqlStatement( cSql, @cArea )
      Return ( DBHScatter( cArea ) )
   end if

RETURN ( {} )

//---------------------------------------------------------------------------//

METHOD updateWpId( cIdWP, cCodArt ) CLASS ArticulosModel

   local cStm     := "updateWpId"
   local cSql     := ""
   local aList    := {}

   cSql           := "UPDATE " + ::getTableName()
   cSql           += " SET cIdWP = " + quoted( cIdWP )
   cSql           += " WHERE Codigo = " + quoted( cCodArt )

   ::ExecuteSqlStatement( cSql, @cStm )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD lExistContadores() CLASS ArticulosModel

   local cArea := "getListContadores"
   local cSql  := "SELECT * FROM " + ::getTableName() + " WHERE NCTLSTOCK = 2"

   if ::ExecuteSqlStatement( cSql, @cArea )
      Return ( ( cArea )->( lastrec() ) > 0 )
   end if

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS ArticulosModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

   cSql        += " WHERE lSndDoc AND NOT lObs"

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD updateCosto( cCodArt, nCosto ) CLASS ArticulosModel

   local cArea
   local cSql

   cSql        := "UPDATE " + ::getTableName() + Space( 1 )
   cSql        += "SET pCosto=" + toSQLString( nCosto ) + Space( 1 )
   cSql        += "WHERE Codigo = " + toSQLString( cCodArt )

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD getNamesFromIdLanguagesPS( cCodArt, aIdsLanguages ) CLASS ArticulosModel

   local cName
   local hNames   := {=>}

   if Len( aIdsLanguages ) == 0
      Return ( hNames )
   end if

   cName    := ::getNombre( cCodArt )

   if Empty( cName )
      Return ( hNames )
   end if

   aEval( aIdsLanguages, {|id| hSet( hNames, AllTrim( Str( id ) ), AllTrim( cName ) ) } )

RETURN ( hNames )

//---------------------------------------------------------------------------//

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ArticulosPrecios FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "ArtDiv" )

   METHOD getHashProperties( cCodArt )

   METHOD getWpCode( cCodArt, cCodPr1, cValPr1, cCodPr2, cValPr2 )

   METHOD listWpCode()

   METHOD updateWpId( cIdWP, cCodArt, cCodPrp1, cCodPrp2, cValPrp1, cValPrp2 )

END CLASS

//---------------------------------------------------------------------------//

METHOD updateWpId( cIdWP, cCodArt, cCodPrp1, cCodPrp2, cValPrp1, cValPrp2 ) CLASS ArticulosPrecios

   local cStm     := "updateWpId"
   local cSql     := ""
   local aList    := {}

   cSql           := "UPDATE " + ::getTableName()
   cSql           += " SET cIdWP = " + quoted( cIdWP )
   cSql           += " WHERE cCodArt = " + quoted( cCodArt )
   cSql           += " AND cCodPr1 = " + quoted( cCodPrp1 )
   cSql           += " AND cCodPr2 = " + quoted( cCodPrp2 )
   cSql           += " AND cValPr1 = " + quoted( cValPrp1 )
   cSql           += " AND cValPr2 = " + quoted( cValPrp2 )

   ::ExecuteSqlStatement( cSql, @cStm )

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD listWpCode() CLASS ArticulosPrecios

   local cArea := "listWpCode"
   local cSql  := ""

   cSql        += "SELECT * FROM " + ::getTableName()
   cSql        += " WHERE cCodWp is not null"

   if ::ExecuteSqlStatement( cSql, @cArea )
      Return ( DBHScatter( cArea ) )
   end if

RETURN ( {} )

//---------------------------------------------------------------------------//

METHOD getWpCode( cCodArt, cCodPr1, cValPr1, cCodPr2, cValPr2 ) CLASS ArticulosPrecios

   local cCode := ""
   local cArea := "getWpCode"
   local cSql  := ""

   cSql        += "SELECT cCodWp FROM " + ::getTableName()
   cSql        += " WHERE cCodArt = " + quoted( cCodArt )
   cSql        += " AND cCodPr1 = " + quoted( cCodPr1 )
   cSql        += " AND cValPr1 = " + quoted( cValPr1 )
   cSql        += " AND cCodPr2 = " + quoted( cCodPr2 )
   cSql        += " AND cValPr2 = " + quoted( cValPr2 )

   if ::ExecuteSqlStatement( cSql, @cArea )
      if ( ( cArea )->( lastrec() ) > 0 )
         Return ( ( cArea )->cCodWp )
      end if
   end if

Return cCode

//---------------------------------------------------------------------------//

METHOD getHashProperties( cCodArt ) CLASS ArticulosPrecios

   local cCodPr1        := ""
   local cCodPr2        := ""
   local hProperties    := {=>}
   local aProperties    := {}
   local aValores       := {}
   local cListValores   := "ListValores"
   local cSql           := ""

   /*
   Creamos un array con las propiedades y lo añadimos al hash------------------
   */

   cCodPr1              := ArticulosModel():getField( 'cCodPrp1', 'Codigo', cCodArt )
   cCodPr2              := ArticulosModel():getField( 'cCodPrp2', 'Codigo', cCodArt )

   aAdd( aProperties, {    "Codigo" => cCodPr1,;
                           "Nombre" => PropiedadesModel():getField( "cDesPro", "cCodPro", cCodPr1 ),;
                           "lColor" => PropiedadesModel():getField( "lColor", "cCodPro", cCodPr1 ) } )

   aAdd( aProperties, {    "Codigo" => cCodPr2,;
                           "Nombre" => PropiedadesModel():getField( "cDesPro", "cCodPro", cCodPr2 ),;
                           "lColor" => PropiedadesModel():getField( "lColor", "cCodPro", cCodPr2 ) } )

   hSet( hProperties, "aProperties", aProperties )

   /*
   Creamos los valores de propiedades------------------------------------------
   */

   cSql     := "SELECT * FROM " + ::getTableName() + " WHERE cCodArt = " + quoted( cCodArt )

   
   if ::ExecuteSqlStatement( cSql, @cListValores )

      if ( cListValores )->( lastrec() ) > 0
         hSet( hProperties, "aValuesCombinations", DBHScatter( cListValores ) )
      end if

      ( cListValores )->( dbGoTop() )

      while !( cListValores )->( Eof() )

         if len( aValores ) == 0
            
            aAdd( aValores, { "codigo" => ( cListValores )->cCodPr1,;
                              "valor" => ( cListValores )->cValPr1,;
                              "nombre" => allTrim( PropiedadesLineasModel():getNombre( ( cListValores )->cCodPr1, ( cListValores )->cValPr1 ) ),;
                              "color" => alltrim( RgbToRgbHex( PropiedadesLineasModel():getColor( ( cListValores )->cCodPr1, ( cListValores )->cValPr1 ) ) ) } )

         end if

         if AScan( aValores, { |h| hGet( h, "codigo" ) == ( cListValores )->cCodPr1 .and. hGet( h, "valor" ) == ( cListValores )->cValPr1 } ) == 0

            aAdd( aValores, { "codigo" => ( cListValores )->cCodPr1,;
                              "valor" => ( cListValores )->cValPr1,;
                              "nombre" => allTrim( PropiedadesLineasModel():getNombre( ( cListValores )->cCodPr1, ( cListValores )->cValPr1 ) ),;
                              "color" => alltrim( RgbToRgbHex( PropiedadesLineasModel():getColor( ( cListValores )->cCodPr1, ( cListValores )->cValPr1 ) ) ) } )

         end if

         if AScan( aValores, { |h| hGet( h, "codigo" ) == ( cListValores )->cCodPr2 .and. hGet( h, "valor" ) == ( cListValores )->cValPr2 } ) == 0

            aAdd( aValores, { "codigo" => ( cListValores )->cCodPr2,;
                              "valor" => ( cListValores )->cValPr2,;
                              "nombre" => allTrim( PropiedadesLineasModel():getNombre( ( cListValores )->cCodPr2, ( cListValores )->cValPr2 ) ),;
                              "color" => alltrim( RgbToRgbHex( PropiedadesLineasModel():getColor( ( cListValores )->cCodPr1, ( cListValores )->cValPr2 ) ) ) } )

         end if

         ( cListValores )->( dbSkip() )

      end while

      hSet( hProperties, "aValues", aValores )

   end if

RETURN ( hProperties )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ArticulosCodigosBarraModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "ArtCodeBar" )

   METHOD getCodigo( cId )                   INLINE ( ::getField( 'cCodArt', 'cCodBar', cId ) )

   METHOD getDefaultCodigo( cId )            INLINE ( ::getField( 'cCodBar', 'lDefBar AND cCodArt', cId ) )

END CLASS

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS CategoriasModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "Categorias" )

   METHOD getSelectFromCategoria( dbfSql, cCodigoCategoria )

END CLASS

//---------------------------------------------------------------------------//

METHOD getSelectFromCategoria( dbfSql, cCodigoCategoria )

   local cSql  := "SELECT * FROM " + ADSBaseModel():getEmpresaTableName( "Categorias" )     + ;
                        " WHERE cCodigo = " + quoted( cCodigoCategoria )

   ADSBaseModel():ExecuteSqlStatement( cSql, @dbfSql )

return ( dbfSql )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ArticulosImagenesModel FROM ADSBaseModel

   METHOD exist()

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "ArtImg" )

   METHOd idImagenArticulo( cCodigoArticulo, cNombreImagen )

   METHOD getList( cCodigoArticulo )

   METHOD setDirImage( cCodigoArticulo, nIdImagen, cDirImage )

END CLASS

//---------------------------------------------------------------------------//

METHOD exist( cCodigoArticulo, cNombreImagen ) CLASS ArticulosImagenesModel

   local cStm  
   local cSql  := "SELECT cNbrArt "                                           + ;
                     "FROM " + ::getTableName() + " "                         + ;
                     "WHERE cCodArt = " + quoted( cCodigoArticulo ) + " AND " + ; 
                           "cImgArt = " + quoted( cNombreImagen )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD idImagenArticulo( cCodigoArticulo, cNombreImagen ) CLASS ArticulosImagenesModel

   local cStm  := "idArtImg"
   local cSql  := "SELECT nId "                                           + ;
                     "FROM " + ::getTableName() + " "                         + ;
                     "WHERE cCodArt = " + quoted( cCodigoArticulo ) + " AND " + ; 
                           "cImgArt = " + quoted( cNombreImagen )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->nId )
   end if 

RETURN ( 0 )

//---------------------------------------------------------------------------//

METHOD getList( cCodigoArticulo ) CLASS ArticulosImagenesModel

   local cArea := "getListImages"
   local cSql  := ""

   cSql        += "SELECT * FROM " + ::getTableName()
   cSql        += " WHERE cCodArt = " + quoted( cCodigoArticulo )

   if ::ExecuteSqlStatement( cSql, @cArea )
      Return ( DBHScatter( cArea ) )
   end if

RETURN ( {} )

//---------------------------------------------------------------------------//

METHOD setDirImage( cCodigoArticulo, nIdImagen, cDirImage ) CLASS ArticulosImagenesModel

   local cArea
   local cSql

   cSql        := "UPDATE " + ::getTableName() + Space( 1 )
   cSql        += "SET cRmtArt =" + quoted( cDirImage ) + Space( 1 )
   cSql        += "WHERE cCodArt = " + quoted( cCodigoArticulo ) + Space( 1 )
   cSql        += "AND nId = " + toSQLString( nIdImagen )

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ArticulosDocumentosModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "ArtDoc" )

END CLASS

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ProveedorArticuloModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "ProvArt" )

END CLASS

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS EscandallosArticuloModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "ArtKit" )

   METHOD get( cCodigoArticulo )
   METHOD getList( cCodigoArticulo )
   METHOD getListByUuid( cUuid )

   METHOD getToOdoo( cArea )

END CLASS

//---------------------------------------------------------------------------//

METHOD get( cCodigoArticulo ) CLASS EscandallosArticuloModel

   local cStm  
   local cSql  := "SELECT * "                                           + ;
                     "FROM " + ::getTableName() + " "                   + ;
                     "WHERE cCodKit = " + quoted( cCodigoArticulo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getList( cCodigoArticulo ) CLASS EscandallosArticuloModel

   local cStm 
   local aList

   cStm           := ::get( cCodigoArticulo )

   if !empty( cStm ) .and. ( ( cStm )->( lastrec() ) > 0 )
      aList     := DBHScatter( cStm )
   end if 

RETURN ( aList )

//---------------------------------------------------------------------------//

METHOD getListByUuid( cUuid ) CLASS EscandallosArticuloModel

   local hList
   local cStm  
   local cSql  := "SELECT * "                                     + ;
                     "FROM " + ::getTableName() + " "             + ;
                     "WHERE cParUuid = " + quoted( cUuid ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      
      if !empty( cStm ) .and. ( ( cStm )->( lastrec() ) > 0 )
      
         hList     := DBHScatter( cStm )

      end if

   end if

RETURN ( hList )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS EscandallosArticuloModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ListaEscandallosModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "ParKit" )

   METHOD getUuidFromName( cName )           INLINE ( ::getField( 'cUuid', 'cNomKit', cName ) )

   METHOD get( cCodigoArticulo )
   METHOD getList( cCodigoArticulo )
   METHOD getListNames( cCodigoArticulo )

END CLASS

//---------------------------------------------------------------------------//

METHOD get( cCodigoArticulo ) CLASS ListaEscandallosModel

   local cStm  
   local cSql  := "SELECT * "                                           + ;
                     "FROM " + ::getTableName() + " "                   + ;
                     "WHERE cCodArt = " + quoted( cCodigoArticulo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getList( cCodigoArticulo ) CLASS ListaEscandallosModel

   local cStm 
   local aList

   cStm           := ::get( cCodigoArticulo )

   if !empty( cStm ) .and. ( ( cStm )->( lastrec() ) > 0 )
      aList     := DBHScatter( cStm )
   end if 

RETURN ( aList )

//---------------------------------------------------------------------------//

METHOD getListNames( cCodigoArticulo ) CLASS ListaEscandallosModel

   local alist := {}
   local hList
   local cStm  
   local cSql  := "SELECT cNomKit "                                     + ;
                     "FROM " + ::getTableName() + " "                   + ;
                     "WHERE cCodArt = " + quoted( cCodigoArticulo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      
      if !empty( cStm ) .and. ( ( cStm )->( lastrec() ) > 0 )
      
         hList     := DBHScatter( cStm )

         aeval( hList, {|a| aAdd( aList, hGet( a, "cNomKit" ) ) } )

      end if

   end if

RETURN ( aList )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

FUNCTION getValueArticulo( cCodigoArticulo, cCampo )

RETURN ( ArticulosModel():getField( AllTrim( cCampo ), 'Codigo', AllTrim( cCodigoArticulo ) ) )

//---------------------------------------------------------------------------//

FUNCTION getDefCodigoBarra( cCodigoArticulo )

RETURN ( ArticulosCodigosBarraModel():getDefaultCodigo( Padr( cCodigoArticulo, 18 ) ) )

//---------------------------------------------------------------------------//