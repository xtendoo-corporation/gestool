#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS ClientesModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "Client" )

   METHOD Riesgo( idCliente )

   METHOD getNombre( idCliente )                   INLINE ( ::getField( "Titulo", "Cod", idCliente ) )

   METHOD getUuid( idCliente )                     INLINE ( ::getField( 'Uuid', 'Cod', idCliente, .t. ) )

   METHOD getClientesPorRuta( cWhere, cOrderBy )

   METHOD getObrasPorCliente( dbfSql, cCodigoCliente )

   METHOD lClienteSinVentas( idCliente, dFechaInicio, dFechaFin )

   METHOD getToOdoo( cArea )

   METHOD get( cCodigoCliente )

   METHOD getHash( cCodigoCliente )

   METHOD existEmail( cEmail )

   METHOD existInWP( cId )

END CLASS

//---------------------------------------------------------------------------//

METHOD Riesgo( idCliente )

   local nRiesgo  := 0

   nRiesgo        += AlbaranesClientesModel():Riesgo( idCliente )

   nRiesgo        += RecibosClientesModel():Riesgo( idCliente )

   nRiesgo        += TicketsClientesModel():Riesgo( idCliente )

Return ( nRiesgo )

//---------------------------------------------------------------------------//

METHOD getClientesPorRuta( cWhere, cAgente, cOrderBy )

   local cStm  := "ADSRutas"
   local cSql  := "SELECT "                                                + ;
                     "rownum() AS recno, "                                 + ;
                     "Cod, "                                               + ;
                     "Titulo "                                             + ;
                  "FROM " + ::getTableName() + " "                         

   if !empty( cWhere )
      cSql     += "WHERE " + cWhere + " "
      if !empty( cAgente )
         cSql  += "AND cAgente = " + quoted( cAgente ) + " "
      end if
   else 
      if !empty( cAgente )
         cSql  += "WHERE cAgente = " + quoted( cAgente ) + " "
      end if
   end if 

   if !empty( cOrderBy )
         cSql  += "ORDER BY " + cOrderBy + " ASC"
   end if 

   if ::ExecuteSqlStatement( cSql, @cStm )
      ::clearFocus( cStm )
      RETURN ( cStm )
   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getObrasPorCliente( dbfSql, cCodigoCliente )

   local cSql  := "SELECT * FROM " + ADSBaseModel():getEmpresaTableName( "ObrasT" )     + ;
                        " WHERE cCodCli = " + quoted( cCodigoCliente )

   ADSBaseModel():ExecuteSqlStatement( cSql, @dbfSql )

return ( dbfSql )

//---------------------------------------------------------------------------//

METHOD lClienteSinVentas( idCliente, dFechaInicio, dFechaFin )

   local dbfSql
   local cSql
   local lReturn := .f.

   cSql  := "SELECT * FROM " + ADSBaseModel():getEmpresaTableName( "FacCliT" )     + ;
                        " WHERE cCodCli = " + quoted( idCliente ) + " AND dFecFac >= " + quoted( dToc( dFechaInicio ) ) + " AND dFecFac <= " + quoted( dToc( dFechaFin ) )

   if ADSBaseModel():ExecuteSqlStatement( cSql, @dbfSql )
      lReturn  := ( ( dbfSql )->( lastrec() ) > 0 )
   end if 

   if !lReturn
      
      cSql  := "SELECT * FROM " + ADSBaseModel():getEmpresaTableName( "AlbCliT" )     + ;
                        " WHERE NOT lFacturado AND cCodCli = " + quoted( idCliente ) + " AND dFecAlb >= " + quoted( dToc( dFechaInicio ) ) + " AND dFecAlb <= " + quoted( dToc( dFechaFin ) )

      if ADSBaseModel():ExecuteSqlStatement( cSql, @dbfSql )
         lReturn  := ( ( dbfSql )->( lastrec() ) > 0 )
      end if 

   end if

   if !lReturn
      
      cSql  := "SELECT * FROM " + ADSBaseModel():getEmpresaTableName( "TikeT" )     + ;
                        " WHERE cCliTik = " + quoted( idCliente ) + " AND dFecTik >= " + quoted( dToc( dFechaInicio ) ) + " AND dFecTik <= " + quoted( dToc( dFechaFin ) )

      if ADSBaseModel():ExecuteSqlStatement( cSql, @dbfSql )
         lReturn  := ( ( dbfSql )->( lastrec() ) > 0 )
      end if 

   end if

return ( lReturn )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS ClientesModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

   cSql        += " WHERE lSndInt"

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD get( cCodigoCliente ) CLASS ClientesModel

   local cStm  
   local cSql  := "SELECT * "                                           + ;
                     "FROM " + ::getTableName() + " "                   + ;
                     "WHERE Cod = " + quoted( cCodigoCliente ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( cStm )
   end if 

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getHash( cCodigoCliente ) CLASS ClientesModel

   local cStm 
   local hRecord  
   
   cStm           := ::get( cCodigoCliente )

   if !empty( cStm ) .and. ( ( cStm )->( lastrec() ) > 0 )
      hRecord     := getHashFromWorkArea( cStm )
   end if 

RETURN ( hRecord )

//---------------------------------------------------------------------------//

METHOD existEmail( cEmail ) CLASS ClientesModel

   local cStm
   local cSql  := "SELECT Cod "                                   + ;
                     "FROM " + ::getTableName() + " "             + ;
                     "WHERE cMeiInt = " + quoted( cEmail ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD existInWP( cId ) CLASS ClientesModel

   local cStm
   local cSql  := "SELECT Cod "                                   + ;
                     "FROM " + ::getTableName() + " "             + ;
                     "WHERE cIdWP = " + quoted( cId ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ClientesBancosModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "CliBnc" )

   METHOD getToOdoo( cArea )

END CLASS

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea, cCodCli ) CLASS ClientesBancosModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

   cSql        += " WHERE cCodCli = " + quoted( cCodCli )

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ClientesDireccionesModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "ObrasT" )

   METHOD nCount( cCodCli )

   METHOD getToOdoo( cArea, cCodCli )

   METHOD getName( cCodCli, cCodObr )

END CLASS

//---------------------------------------------------------------------------//

METHOD nCount( cCodCli ) CLASS ClientesDireccionesModel

   local cArea
   local cSql  := "SELECT Count(*) AS Counter FROM " + ::getTableName() 

   cSql        += " WHERE cCodCli = " + quoted( cCodCli )

   ::ExecuteSqlStatement( cSql, @cArea )

RETURN ( ( cArea )->Counter )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea, cCodCli ) CLASS ClientesDireccionesModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

   cSql        += " WHERE cCodCli = " + quoted( cCodCli )

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD getName( cCodCli, cCodObr )

   local cArea       := "GetNameDir"
   local cSql        := "" 
   local cNameObra   := ""

   if Empty( cCodCli ) .or. Empty( cCodObr )
      Return cNameObra
   end if

   cSql              := "SELECT cNomObr FROM " + ::getTableName() 
   cSql              += " WHERE cCodCli = " + quoted( cCodCli )
   cSql              += " AND cCodObr = " + quoted( cCodObr )

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cArea )
      cNameObra      := ( cArea )->cNomObr
   end if 

RETURN ( cNameObra )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS RutasModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "Ruta" )

   METHOD getToOdoo( cArea )

   METHOD getNombre( idRuta )                      INLINE ::getField( "CDESRUT", "CCODRUT", idRuta )

END CLASS

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS RutasModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS GrupoClientesModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "GrpCli" )

   METHOD getToOdoo( cArea )

   METHOD getName( cCodGrp )                       INLINE ( ::getField( "cNomGrp", "cCodGrp", cCodGrp ) )

END CLASS

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS GrupoClientesModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS FormasPagoModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "FPago" )

   METHOD getToOdoo( cArea )

   METHOD getName( cCodPgo )                       INLINE ( ::getField( "CDESPAGO", "CCODPAGO", cCodPgo ) )

END CLASS

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS FormasPagoModel

   local cSql  := "SELECT * FROM " + ::getTableName() 

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TarifasModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "TarPreT" )

   METHOD getName( cCodTar )                       INLINE ( ::getField( "CNOMTAR", "CCODTAR", cCodTar ) )

END CLASS

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TarifasLineasModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "TarPreL" )

   METHOD SaveSelTar( cCodTar, cCodArt, lSel )

   METHOD getToOdoo( cArea )

END CLASS

//---------------------------------------------------------------------------//

METHOD SaveSelTar( cCodTar, cCodArt, lSel, nPosprint ) CLASS TarifasLineasModel

   local cStm     := "UpdateTarifa"
   local cSql     := ""

   cSql           := "UPDATE " + ::getTableName() + " SET"
   cSql           += " lSel = " + if( lSel, ".T.", ".F." )
   cSql           += ", nPosPrint = " + quoted( nPosPrint )
   cSql           += " WHERE CCODTAR = " + quoted( cCodTar )
   cSql           += " AND CCODART = " + quoted( cCodArt )

   ::ExecuteSqlStatement( cSql, @cStm )

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS TarifasLineasModel

      local cSql     := "SELECT * FROM " + ::getTableName()

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//