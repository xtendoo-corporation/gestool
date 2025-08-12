#include "fivewin.ch"
#include "factu.ch" 
#include "hdo.ch"

//---------------------------------------------------------------------------//

CLASS PedidosClientesLineasModel FROM TransaccionesComercialesLineasModel

	METHOD getTableName()                           INLINE ::getEmpresaTableName( "PedCliL" )

	METHOD ExisteLinea( cNumPed, cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote )

  METHOD getLinesFromDocument( cSerie, nNumero, cSufijo, lPrepare )

  METHOD getLinesKitsFromDocument( cSerie, nNumero, cSufijo )

  METHOD getInfoPdtEntregar( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

END CLASS

//---------------------------------------------------------------------------//

METHOD ExisteLinea( cNumPed, cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote ) CLASS PedidosClientesLineasModel

	  local lExiste  := .f.
   	local cStm 		 := "existePedCliL"
   	local cSql  	 := ""

	  cSql  			   += "SELECT * "
    cSql  			   += "FROM " + ::getTableName() + " "
    cSql  			   += "WHERE cSerPed = " + quoted( SubStr( cNumPed, 1, 1 ) ) + " AND "
    cSql     		   += "nNumPed = " + AllTrim( SubStr( cNumPed, 2, 9 ) ) + " AND "   
    cSql     		   += "cSufPed = " + quoted( SubStr( cNumPed, 11, 2 ) ) + " AND "   
    cSql     		   += "cRef = " + quoted( cCodigoArticulo ) + " AND "   
    cSql     		   += "cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " AND "   
    cSql     		   += "cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " AND "   
    cSql     		   += "cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " AND "   
    cSql     		   += "cValPr2 = " + quoted( cValorSegundaPropiedad ) + " AND "   
    cSql     		   += "cLote = " + quoted( cLote )

    if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )
        lExiste 	 :=  ( cStm )->( OrdKeyCount() ) > 0
    end if

RETURN lExiste

//---------------------------------------------------------------------------//

METHOD getLinesFromDocument( cSerie, nNumero, cSufijo, lPrepare ) CLASS PedidosClientesLineasModel
  
  local aLines      := {}
  local cStm        := "PrepareLineasPedCli"
  local cSql        := ""

  DEFAULT lPrepare  :=  .f.

  cSql              += "SELECT * "
  cSql              += "FROM " + ::getTableName() + Space( 1 )
  cSql              += "WHERE cSerPed = " + quoted( cSerie ) + " AND "
  cSql              += "nNumPed = " + Str( nNumero ) + " AND "
  cSql              += "cSufPed = " + quoted( cSufijo ) + " AND "
  cSql              += "NOT lKitChl AND "
  
  if lPrepare
    cSql            += "lPreparado"
  else
    cSql            += "NOT lPreparado"
  end if

  if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbGoTop() )

      while !( cStm )->( Eof() )

        aAdd( aLines, DBScatter( cStm ) )

        ( cStm )->( dbSkip() )

      end while

  end if

Return ( aLines )


//---------------------------------------------------------------------------//

METHOD getLinesKitsFromDocument( cSerie, nNumero, cSufijo )

  local aLines      := {}
  local cStm        := "PrepareLineasPedCli"
  local cSql        := ""

  cSql              += "SELECT * "
  cSql              += "FROM " + ::getTableName() + Space( 1 )
  cSql              += "WHERE cSerPed = " + quoted( cSerie ) + " AND "
  cSql              += "nNumPed = " + Str( nNumero ) + " AND "
  cSql              += "cSufPed = " + quoted( cSufijo ) + " AND "
  cSql              += "lKitChl"
  
  if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbGoTop() )

      while !( cStm )->( Eof() )

        aAdd( aLines, DBScatter( cStm ) )

        ( cStm )->( dbSkip() )

      end while

  end if

Return ( aLines )

//---------------------------------------------------------------------------//

METHOD getInfoPdtEntregar( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

    local cSql        := ""

    cSql              := "SELECT "
    cSql              += "0 as pdtrecibir, "
    do case
      case lCalCaj() .and. lCalBul()
         cSql         += "( TablaLineas.nBultos * TablaLineas.nCanPed * TablaLineas.nUniCaja ) AS pdtentrega, "

      case lCalCaj() .and. !lCalBul()
         cSql         += "( TablaLineas.nCanPed * TablaLineas.nUniCaja ) AS pdtentrega, "

      case !lCalCaj() .and. lCalBul()
         cSql         += "( TablaLineas.nBultos * TablaLineas.nUniCaja ) AS pdtentrega, "

      case !lCalCaj() .and. !lCalBul()
         cSql            += " TablaLineas.nUniCaja AS pdtentrega, "

    end case
    cSql              += quoted( PED_CLI ) + " AS Document, "
    cSql              += "TablaCabecera.dFecPed AS Fecha, "
    cSql              += "'' AS Hora, "
    cSql              += "TablaLineas.cSerPed AS Serie, "
    cSql              += "CAST( TablaLineas.nNumPed AS SQL_INTEGER ) AS Numero, "
    cSql              += "TablaLineas.cSufPed AS Sufijo, "
    cSql              += "CAST( TablaLineas.nNumLin AS SQL_INTEGER ) AS nNumLin, "
    cSql              += "TablaLineas.cRef AS Articulo, "
    cSql              += "TablaLineas.cAlmLin AS Almacen "
    cSql              += "FROM " + ::getTableName() + " TablaLineas "
    cSql              += "INNER JOIN " + ::getEmpresaTableName( "PedCliT" ) + " AS TablaCabecera ON TablaCabecera.cSerPed = TablaLineas.cSerPed AND TablaCabecera.nNumPed = TablaLineas.nNumPed AND TablaCabecera.cSufPed = TablaLineas.cSufPed "
    cSql              += "WHERE TablaLineas.cRef = " + quoted( cCodigoArticulo ) + " " 

    if !empty( cCodigoAlmacen )
      cSql            += "AND TablaLineas.cAlmLin = " + quoted( cCodigoAlmacen ) + " "
    end if

    if hb_isdate( dFechaHasta )
      cSql            += "AND CAST( TablaCabecera.dFecPed AS SQL_CHAR ) <= " + formatoFechaSql( dFechaHasta ) + " "
    end if

RETURN ( cSql )

//---------------------------------------------------------------------------//