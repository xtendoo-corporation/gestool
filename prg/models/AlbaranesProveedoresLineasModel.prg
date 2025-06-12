#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS AlbaranesProveedoresLineasModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "AlbProvL" )

   METHOD getExtraWhere()                    INLINE ( "AND nCtlStk < 2 AND NOT lFacturado " )

   METHOD getSQLSentenceFechaCaducidad()

   METHOD getFechaFieldName()                INLINE ( "dFecAlb" )
   METHOD getHoraFieldName()                 INLINE ( "tFecAlb" )

   METHOD getSerieFieldName()                INLINE ( "cSerAlb" )
   METHOD getNumeroFieldName()               INLINE ( "nNumAlb" )
   METHOD getSufijoFieldName()               INLINE ( "cSufAlb" )

   METHOD getTipoDocumento()                 INLINE ( ALB_PRV )

   METHOD getPrimerCosto( cCodigoArticulo, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   METHOD getFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   METHOD nUnidadesRecibidas( cNumPed, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote )

   METHOD getCostoFecha( cCodigoArticulo, dFecha )

   METHOD getUltimasCompras( cCodigoArticulo, cCodigoProveedor )

   METHOD getInfoPdtRecibir( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

   METHOD nLastNumLin( cSerie, nNumero, cSufijo )

   METHOD getComprasArticulo( cCodigoArticulo )

END CLASS

//---------------------------------------------------------------------------//

METHOD nLastNumLin( cSerie, nNumero, cSufijo ) CLASS AlbaranesProveedoresLineasModel

   local cStm        := "nLastNumLin"
   local cSql        := "SELECT TOP 1 nNumLin "                           + ;
                        "FROM " + ::getTableName()                        + ;
                        " WHERE cSerAlb = " + quoted( cSerie )            + ;
                           " AND nNumAlb = " + AllTrim( Str( nNumero ) )  + ;
                           " AND cSufAlb = " + quoted( cSufijo )          + ;
                        " ORDER BY nNumLin DESC"

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->nNumLin + 1 )
   end if

RETURN ( 0 )

//---------------------------------------------------------------------------//

METHOD nUnidadesRecibidas( cNumPed, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote ) CLASS AlbaranesProveedoresLineasModel

   local cStm        := "unidadesrecibidasalbprov"
   local cSql        := ""
   local nUnidades   := 0

   DEFAULT cCodPr1   := ""
   DEFAULT cCodPr2   := ""
   DEFAULT cValPr1   := ""
   DEFAULT cValPr2   := ""
   DEFAULT cLote     := ""

   cSql              += "SELECT * "
   cSql              += "FROM " + ::getTableName() + Space( 1 )
   cSql              += "WHERE cCodPed = " + quoted( cNumPed ) + " AND "
   cSql              += "cRef = " + quoted( cCodArt ) + " AND "
   cSql              += "cCodPr1 = " + quoted( cCodPr1 ) + " AND "
   cSql              += "cValPr1 = " + quoted( cValPr1 ) + " AND "
   cSql              += "cCodPr2 = " + quoted( cCodPr2 ) + " AND "
   cSql              += "cValPr2 = " + quoted( cValPr2 ) //+ " AND "
   //cSql              += "cLote = " + quoted( cLote )

   if ::ExecuteSqlStatement( cSql, @cStm )
    
      if ( cStm )->( OrdKeyCount() ) != 0
         
         ( cStm )->( dbGotop() )

         while !( cStm )->( eof() )

            nUnidades   += nTotNAlbPrv( cStm )

            ( cStm )->( dbSkip() )

         end while

      end if
      
   end if

Return ( nUnidades )

//---------------------------------------------------------------------------//

METHOD getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   local cSql  := "SELECT "                                          + ;
                     "cRef as cCodigoArticulo, "                     + ;
                     "cCodPr1 as cCodigoPrimeraPropiedad, "          + ;
                     "cCodPr2 as cCodigoSegundaPropiedad, "          + ;
                     "cValPr1 as cValorPrimeraPropiedad, "           + ;
                     "cValPr2 as cValorSegundaPropiedad, "           + ;
                     "cLote as cLote, "                              + ;
                     "dFecAlb as dFecDoc, "                          + ;
                     "dFecCad as dFecCad "                           + ;
                  "FROM " + ::getTableName() + " "                   + ;
                  "WHERE cRef = " + quoted( cCodigoArticulo ) + " "  + ;
                     "AND dFecCad IS NOT NULL "       

   cSql        += ::getExtraWhere()                                
   cSql        += "AND cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " "
   cSql        += "AND cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " "
   cSql        += "AND cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " "
   cSql        += "AND cValPr2 = " + quoted( cValorSegundaPropiedad ) + " "   
   cSql        += "AND cLote = " + quoted( cLote ) + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getPrimerCosto( cCodigoArticulo, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote ) CLASS AlbaranesProveedoresLineasModel

   local nVal  := 0
   local cStm
   local cSql  := "SELECT TOP 1 "                                                + ;
                     "nPreDiv "                                                  + ;
                  "FROM " + ::getTableName() + " "                               + ;
                  "WHERE cRef = " + quoted( cCodigoArticulo ) + " "

   if !empty(cValorPrimeraPropiedad)
      cSql     +=    "AND cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " "   
   end if 

   if !empty(cValorSegundaPropiedad)
      cSql     +=    "AND cValPr2 = " + quoted( cValorSegundaPropiedad ) + " "   
   end if 

   if !empty(cLote)
      cSql     +=    "AND cLote = " + quoted( cLote ) + " "
   end if 

   cSql        +=    "ORDER BY dFecAlb,tFecAlb"

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )
      nVal     := ( ( cStm )->nPreDiv )
   end if

RETURN ( nVal )

//---------------------------------------------------------------------------//

METHOD getFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote ) CLASS AlbaranesProveedoresLineasModel

   local nVal  := cTod( "" )
   local cStm
   local cSql  := "SELECT TOP 1 "                                                + ;
                     "dFecCad "                                                  + ;
                  "FROM " + ::getTableName() + " "                               + ;
                  "WHERE NOT lFacturado AND lLote AND cRef = " + quoted( cCodigoArticulo ) + " "
      cSql     +=    "AND cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " "   
      cSql     +=    "AND cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " "   
      cSql     +=    "AND cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " "   
      cSql     +=    "AND cValPr2 = " + quoted( cValorSegundaPropiedad ) + " "   
      cSql     +=    "AND cLote = " + quoted( cLote ) + " "
      cSql     +=    "ORDER BY dFecAlb DESC"

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )
      nVal     := ( ( cStm )->dFecCad )
   end if

RETURN ( nVal )

//---------------------------------------------------------------------------//

METHOD getCostoFecha( cCodigoArticulo, dFecha ) CLASS AlbaranesProveedoresLineasModel

   local hCosto   := {=>}
   local cStm
   local cSql     := "SELECT TOP 1 "                                             + ;
                        "lineas.nPreDiv, cabecera.dFecAlb "                     + ;
                     "FROM " + ::getTableName() + " AS lineas "                  + ;
                     "INNER JOIN " + ::getEmpresaTableName( "AlbProvT" ) + " AS cabecera ON cabecera.cSerAlb = lineas.cSerAlb AND cabecera.nNumAlb = lineas.nNumAlb AND cabecera.cSufAlb = lineas.cSufAlb " + ;
                     "WHERE NOT cabecera.lFacturado AND cRef = " + quoted( cCodigoArticulo ) + " "
      cSql        +=    "AND cabecera.dFecAlb <= " + quoted( Dtoc( dFecha ) ) + " "
      cSql        +=    "ORDER BY cabecera.dFecAlb DESC"

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )
      
      if ( cStm )->( ordkeycount() ) > 0
         hSet( hCosto, "Costo", ( cStm )->nPreDiv )
         hSet( hCosto, "Fecha", ( cStm )->dFecAlb )
      else
         hSet( hCosto, "Costo", 0 )
         hSet( hCosto, "Fecha", cTod( "" ) )
      end if

   end if

RETURN ( hCosto )

//---------------------------------------------------------------------------//

METHOD getUltimasCompras( cCodigoArticulo, cCodigoProveedor )

   local aValores    := {}
   local cStm        := "UltComAlbProv"
   local cSql        := "SELECT "                                                   + ;
                           "cabecera.cSerAlb AS serie, "                            + ;
                           "cabecera.nNumAlb AS numero, "                           + ;
                           "cabecera.cSufAlb AS sufijo, "                           + ;
                           "cabecera.dFecAlb AS fecha, "                            + ;
                           "lineas.nPreDiv AS precio "                              + ;
                        "FROM " + ::getTableName() + " AS lineas "                  + ;
                        "INNER JOIN " + ::getEmpresaTableName( "AlbProvT" ) + " AS cabecera ON cabecera.cSerAlb = lineas.cSerAlb AND cabecera.nNumAlb = lineas.nNumAlb AND cabecera.cSufAlb = lineas.cSufAlb " + ;
                        "WHERE lineas.cRef = " + quoted( cCodigoArticulo ) + " "    + ;
                           "AND NOT lineas.lFacturado "                             + ;
                           "AND cabecera.cCodPrv = " + quoted( cCodigoProveedor ) 

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbGoTop() )

      while !( cStm )->( Eof() )

         
         aAdd( aValores, { "tipo" => "Albarán proveedor",;
                           "numero" => ( cStm )->serie + "/" + AllTrim( Str( ( cStm )->numero ) ),;
                           "fecha" => ( cStm )->fecha,;
                           "precio" => ( cStm )->precio } )


         ( cStm )->( dbSkip() )

      end while

   end if

RETURN ( aValores )

//---------------------------------------------------------------------------//

METHOD getComprasArticulo( cCodigoArticulo )

   local aValores    := {}
   local cStm        := "getComprasArticuloAlb"
   local cSql        := "SELECT "                                                   + ;
                           "cabecera.cSerAlb AS serie, "                            + ;
                           "cabecera.nNumAlb AS numero, "                           + ;
                           "cabecera.cSufAlb AS sufijo, "                           + ;
                           "cabecera.dFecAlb AS fecha, "                            + ;
                           "cabecera.cCodPrv AS proveedor, "                        + ;
                           "lineas.nPreDiv AS precio, "                             + ;
                           "lineas.nUnicaja AS unidades "                           + ;
                        "FROM " + ::getTableName() + " AS lineas "                  + ;
                        "INNER JOIN " + ::getEmpresaTableName( "AlbProvT" ) + " AS cabecera ON cabecera.cSerAlb = lineas.cSerAlb AND cabecera.nNumAlb = lineas.nNumAlb AND cabecera.cSufAlb = lineas.cSufAlb " + ;
                        "WHERE lineas.cRef = " + quoted( cCodigoArticulo ) + " "    + ;
                           "AND NOT lineas.lFacturado " 

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbGoTop() )

      while !( cStm )->( Eof() )
         
         aAdd( aValores, { "tipo" => "Albarán proveedor",;
                           "id" => ( cStm )->serie + Str( ( cStm )->numero ) + ( cStm )->sufijo ,;
                           "idDoc" => ALB_PRV + ( cStm )->serie + Str( ( cStm )->numero ) + ( cStm )->sufijo ,;
                           "proveedor" => ( cStm )->proveedor ,;
                           "numero" => ( cStm )->serie + "/" + AllTrim( Str( ( cStm )->numero ) ),;
                           "fecha" => ( cStm )->fecha,;
                           "unidades" => ( cStm )->unidades,;
                           "precio" => ( cStm )->precio,;
                           "und_vendidas" => 0 } )

         ( cStm )->( dbSkip() )

      end while

   end if

RETURN ( aValores )

//---------------------------------------------------------------------------//

METHOD getInfoPdtRecibir( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

    local cSql        := ""

    cSql              := "SELECT "
    
    do case
      case lCalCaj() .and. lCalBul()
         cSql         += "( ( nBultos * nCanPed * nUniCaja ) * -1 ) as pdtrecibir, "

      case lCalCaj() .and. !lCalBul()
         cSql         += "( ( nCanPed * nUniCaja ) * -1 ) as pdtrecibir, "

      case !lCalCaj() .and. lCalBul()
         cSql         += "( ( nBultos * nUniCaja ) * -1 ) as pdtrecibir, "

      case !lCalCaj() .and. !lCalBul()
         cSql            += "( nUniCaja * - 1 ) as pdtrecibir, "

    end case

    cSql              += "0 as pdtentrega, "
    cSql              += quoted( ALB_PRV ) + " AS Document, "
    cSql              += "dFecAlb AS Fecha, "
    cSql              += "tFecAlb AS Hora, "
    cSql              += "cSerAlb AS Serie, "
    cSql              += "CAST( nNumAlb AS SQL_INTEGER ) AS Numero, "
    cSql              += "cSufAlb AS Sufijo, "
    cSql              += "CAST( nNumLin AS SQL_INTEGER ) AS nNumLin, "
    cSql              += "cRef AS Articulo, "
    cSql              += "cAlmLin AS Almacen "
    cSql              += "FROM " + ::getTableName()
    cSql              += " WHERE cCodPed is not null AND cRef = " + quoted( cCodigoArticulo ) + " " 

    if !empty( cCodigoAlmacen )
      cSql            += "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
    end if

    if hb_isdate( dFechaHasta )
      cSql            += "AND CAST( dFecAlb AS SQL_CHAR ) <= " + formatoFechaSql( dFechaHasta ) + " "
    end if

RETURN ( cSql )

//---------------------------------------------------------------------------//