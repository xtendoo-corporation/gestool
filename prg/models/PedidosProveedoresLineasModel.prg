#include "fivewin.ch"
#include "factu.ch" 
#include "hdo.ch"

//---------------------------------------------------------------------------//

CLASS PedidosProveedoresLineasModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "PedProvL" )

   METHOD ExisteLinea()

   METHOD getInfoPdtRecibir( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

END CLASS

//---------------------------------------------------------------------------//

METHOD ExisteLinea( cNumPed, cCodigoArticulo, cCodigoPrimeraPropiedad, cCodigoSegundaPropiedad, cValorPrimeraPropiedad, cValorSegundaPropiedad, cLote ) CLASS PedidosProveedoresLineasModel

	  local lExiste 	 := .f.
   	local cStm
   	local cSql  	   := ""
      	
	  cSql  			+= "SELECT * "
    cSql  			+= "FROM " + ::getTableName() + " "
    cSql  			+= "WHERE cSerPed = " + quoted( SubStr( cNumPed, 1, 1 ) ) + " AND "
    cSql     		+= "nNumPed = " + AllTrim( SubStr( cNumPed, 2, 9 ) ) + " AND "   
    cSql     		+= "cSufPed = " + quoted( SubStr( cNumPed, 11, 2 ) ) + " AND "   
    cSql     		+= "cRef = " + quoted( cCodigoArticulo ) + " AND "   
    cSql     		+= "cCodPr1 = " + quoted( cCodigoPrimeraPropiedad ) + " AND "   
    cSql     		+= "cCodPr2 = " + quoted( cCodigoSegundaPropiedad ) + " AND "   
    cSql     		+= "cValPr1 = " + quoted( cValorPrimeraPropiedad ) + " AND "   
    cSql     		+= "cValPr2 = " + quoted( cValorSegundaPropiedad ) + " AND "   
    cSql     		+= "cLote = " + quoted( cLote )

   if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )
      lExiste 		:=  ( cStm )->( OrdKeyCount() ) > 0
   end if

RETURN lExiste

//---------------------------------------------------------------------------//

METHOD getInfoPdtRecibir( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

    local cSql        := ""

    cSql              := "SELECT "
    do case
      case lCalCaj() .and. lCalBul()
         cSql         += "( TablaLineas.nBultos * TablaLineas.nCanPed * TablaLineas.nUniCaja ) AS pdtrecibir, "

      case lCalCaj() .and. !lCalBul()
         cSql         += "( TablaLineas.nCanPed * TablaLineas.nUniCaja ) AS pdtrecibir, "

      case !lCalCaj() .and. lCalBul()
         cSql         += "( TablaLineas.nBultos * TablaLineas.nUniCaja ) AS pdtrecibir, "

      case !lCalCaj() .and. !lCalBul()
         cSql            += " TablaLineas.nUniCaja AS pdtrecibir, "

    end case
    cSql              += "0 as pdtentrega, "
    cSql              += quoted( PED_PRV ) + " AS Document, "
    cSql              += "TablaCabecera.dFecPed AS Fecha, "
    cSql              += "'' AS Hora, "
    cSql              += "TablaLineas.cSerPed AS Serie, "
    cSql              += "CAST( TablaLineas.nNumPed AS SQL_INTEGER ) AS Numero, "
    cSql              += "TablaLineas.cSufPed AS Sufijo, "
    cSql              += "CAST( TablaLineas.nNumLin AS SQL_INTEGER ) AS nNumLin, "
    cSql              += "TablaLineas.cRef AS Articulo, "
    cSql              += "TablaLineas.cAlmLin AS Almacen "
    cSql              += "FROM " + ::getTableName() + " TablaLineas "
    cSql              += "INNER JOIN " + ::getEmpresaTableName( "PedProvT" ) + " AS TablaCabecera ON TablaCabecera.cSerPed = TablaLineas.cSerPed AND TablaCabecera.nNumPed = TablaLineas.nNumPed AND TablaCabecera.cSufPed = TablaLineas.cSufPed "
    cSql              += "WHERE TablaLineas.cRef = " + quoted( cCodigoArticulo ) + " " 
    cSql              += "AND NOT TablaLineas.lAnulado "

    if !empty( cCodigoAlmacen )
      cSql            += "AND TablaLineas.cAlmLin = " + quoted( cCodigoAlmacen ) + " "
    end if

    if hb_isdate( dFechaHasta )
      cSql            += "AND CAST( TablaCabecera.dFecPed AS SQL_CHAR ) <= " + formatoFechaSql( dFechaHasta ) + " "
    end if

RETURN ( cSql )

//---------------------------------------------------------------------------//