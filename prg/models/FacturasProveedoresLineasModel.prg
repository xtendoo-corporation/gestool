#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS FacturasProveedoresLineasModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "FacPrvL" )

   METHOD getExtraWhere()                          INLINE ( "AND nCtlStk < 2 " )

   METHOD getFechaFieldName()                      INLINE ( "dFecFac" )
   METHOD getHoraFieldName()                       INLINE ( "tFecFac" )

   METHOD getSerieFieldName()                      INLINE ( "cSerFac" )
   METHOD getNumeroFieldName()                     INLINE ( "nNumFac" )
   METHOD getSufijoFieldName()                     INLINE ( "cSufFac" )

   METHOD getTipoDocumento()                       INLINE ( FAC_PRV )

   METHOD getSQLSentenceFechaCaducidad( cCodigoArticulo, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   METHOD getFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

   METHOD getCostoFecha( cCodigoArticulo, dFecha )

   METHOD getUltimasCompras( cCodigoArticulo, cCodigoProveedor )

   METHOD getComprasArticulo( cCodigoArticulo )

END CLASS

//---------------------------------------------------------------------------//

METHOD getSQLSentenceFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote ) CLASS FacturasProveedoresLineasModel

   local cSql  := "SELECT "                                          + ;
                     "cRef as cCodigoArticulo, "                     + ;
                     "cCodPr1 as cCodigoPrimeraPropiedad, "          + ;
                     "cCodPr2 as cCodigoSegundaPropiedad, "          + ;
                     "cValPr1 as cValorPrimeraPropiedad, "           + ;
                     "cValPr2 as cValorSegundaPropiedad, "           + ;
                     "cLote as cLote, "                              + ;
                     "dFecFac as dFecDoc, "                          + ;
                     "dFecCad as dFecCad "                           + ;
                  "FROM " + ::getTableName() + " "                   + ;
                  "WHERE cRef = " + quoted( cCodigoArticulo ) + " "  + ;
                     "AND dFecCad IS NOT NULL "       

   cSql        += "AND cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " "
   cSql        += "AND cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " "
   cSql        += "AND cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " "
   cSql        += "AND cValPr2 = " + quoted( cValorSegundaPropiedad ) + " "   
   cSql        += "AND cLote = " + quoted( cLote ) + " "

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD getFechaCaducidad( cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote ) CLASS FacturasProveedoresLineasModel

   local nVal  := cTod( "" )
   local cStm
   local cSql  := "SELECT TOP 1 "                                                + ;
                     "dFecCad "                                                  + ;
                  "FROM " + ::getTableName() + " "                               + ;
                  "WHERE lLote AND cRef = " + quoted( cCodigoArticulo ) + " "
      cSql     +=    "AND cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " "   
      cSql     +=    "AND cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " "   
      cSql     +=    "AND cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " "   
      cSql     +=    "AND cValPr2 = " + quoted( cValorSegundaPropiedad ) + " "   
      cSql     +=    "AND cLote = " + quoted( cLote ) + " "
      cSql     +=    "ORDER BY dFecFac DESC"

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )
      nVal     := ( ( cStm )->dFecCad )
   end if

RETURN ( nVal )

//---------------------------------------------------------------------------//

METHOD getCostoFecha( cCodigoArticulo, dFecha ) CLASS FacturasProveedoresLineasModel

   local hCosto   := {=>}
   local cStm
   local cSql     := "SELECT TOP 1 "                                             + ;
                        "lineas.nPreUnit, cabecera.dFecFac "                     + ;
                     "FROM " + ::getTableName() + " AS lineas "                  + ;
                     "INNER JOIN " + ::getEmpresaTableName( "FacPrvT" ) + " AS cabecera ON cabecera.cSerFac = lineas.cSerFac AND cabecera.nNumFac = lineas.nNumFac AND cabecera.cSufFac = lineas.cSufFac " + ;
                     "WHERE cRef = " + quoted( cCodigoArticulo ) + " "
      cSql        +=    "AND cabecera.dFecFac <= " + quoted( Dtoc( dFecha ) ) + " "
      cSql        +=    "ORDER BY cabecera.dFecFac DESC"

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )
      
      if ( cStm )->( ordkeycount() ) > 0
         hSet( hCosto, "Costo", ( cStm )->nPreUnit )
         hSet( hCosto, "Fecha", ( cStm )->dFecFac )
      else
         hSet( hCosto, "Costo", 0 )
         hSet( hCosto, "Fecha", cTod( "" ) )
      end if

   end if

RETURN ( hCosto )

//---------------------------------------------------------------------------//

METHOD getUltimasCompras( cCodigoArticulo, cCodigoProveedor )

   local aValores    := {}
   local cStm        := "UltComFacProv"
   local cSql        := "SELECT "                                                   + ;
                           "cabecera.cSerFac AS serie, "                            + ;
                           "cabecera.nNumFac AS numero, "                           + ;
                           "cabecera.cSufFac AS sufijo, "                           + ;
                           "cabecera.dFecFac AS fecha, "                            + ;
                           "lineas.nPreUnit AS precio "                              + ;
                        "FROM " + ::getTableName() + " AS lineas "                  + ;
                        "INNER JOIN " + ::getEmpresaTableName( "FacPrvT" ) + " AS cabecera ON cabecera.cSerFac = lineas.cSerFac AND cabecera.nNumFac = lineas.nNumFac AND cabecera.cSufFac = lineas.cSufFac " + ;
                        "WHERE lineas.cRef = " + quoted( cCodigoArticulo ) + " "
   cSql              +=    "AND cabecera.cCodPrv = " + quoted( cCodigoProveedor )

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbGoTop() )

      while !( cStm )->( Eof() )

         
         aAdd( aValores, { "tipo" => "Factura proveedor",;
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
   local cStm        := "getComprasArticuloFac"
   local cSql        := "SELECT "                                                   + ;
                           "cabecera.cSerFac AS serie, "                            + ;
                           "cabecera.nNumFac AS numero, "                           + ;
                           "cabecera.cSufFac AS sufijo, "                           + ;
                           "cabecera.dFecFac AS fecha, "                            + ;
                           "cabecera.cCodPrv AS proveedor, "                        + ;
                           "lineas.nPreUnit AS precio, "                            + ;
                           "lineas.nUnicaja AS unidades "                           + ;
                        "FROM " + ::getTableName() + " AS lineas "                  + ;
                        "INNER JOIN " + ::getEmpresaTableName( "FacPrvT" ) + " AS cabecera ON cabecera.cSerFac = lineas.cSerFac AND cabecera.nNumFac = lineas.nNumFac AND cabecera.cSufFac = lineas.cSufFac " + ;
                        "WHERE lineas.cRef = " + quoted( cCodigoArticulo )

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbGoTop() )

      while !( cStm )->( Eof() )
         
         aAdd( aValores, { "tipo" => "Factura proveedor",;
                           "id" => ( cStm )->serie + Str( ( cStm )->numero ) + ( cStm )->sufijo ,;
                           "idDoc" => FAC_PRV + ( cStm )->serie + Str( ( cStm )->numero ) + ( cStm )->sufijo ,;
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