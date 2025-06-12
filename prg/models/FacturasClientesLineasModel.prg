#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS FacturasClientesLineasModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                          INLINE ::getEmpresaTableName( "FacCliL" )

   METHOD getExtraWhere()                         INLINE ( "AND nCtlStk < 2" )

   METHOD getFechaFieldName()                     INLINE ( "dFecFac" )
   METHOD getHoraFieldName()                      INLINE ( "tFecFac" )

   METHOD getSerieFieldName()                     INLINE ( "cSerie" )
   METHOD getNumeroFieldName()                    INLINE ( "nNumFac" )
   METHOD getSufijoFieldName()                    INLINE ( "cSufFac" )

   METHOD getTipoDocumento()                      INLINE ( FAC_CLI )

   METHOD deleteWherId( cSerie, nNumero, cDelegacion )

   METHOD lineasUnidadesEntregadas( cNumPed, cCodArt, cValPr1, cValPr2 )

   METHOD nUnidadesEntregadas( cNumPed, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote )

   METHOD getInfoPdtEntregar( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

END CLASS

//---------------------------------------------------------------------------//

METHOD deleteWherId( cSerie, nNumero, cDelegacion )

   local cSentence

   cSentence         := "DELETE FROM " + ::getTableName() + " " + ;
                           "WHERE cSerie = '" + cSerie + "' AND nNumFac = " + alltrim( nNumero ) + " AND cSufFac = '" + cDelegacion + "'" 
   
   ADSBaseModel():ExecuteSqlStatement( cSentence )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD lineasUnidadesEntregadas( cNumPed, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote ) CLASS FacturasClientesLineasModel

	local cStm        := "lineasUnidadesEntregadasFacCli"
	local cSql 	      := ""

  DEFAULT cCodPr1   := ""
  DEFAULT cCodPr2   := ""
  DEFAULT cValPr1   := ""
  DEFAULT cValPr2   := ""
  DEFAULT cLote     := ""

	cSql  		        += "SELECT * "
  cSql  		        += "FROM " + ::getTableName() + Space( 1 )
	cSql  		        += "WHERE cNumPed = " + quoted( cNumPed ) + " AND "
  cSql  		        += "cRef = " + quoted( cCodArt )
 	cSql              += " AND cCodPr1 = " + quoted( cCodPr1 )
  cSql              += " AND cCodPr2 = " + quoted( cCodPr2 )
  cSql  	          += " AND cValPr1 = " + quoted( cValPr1 )
	cSql  	          += " AND cValPr2 = " + quoted( cValPr2 )
  //cSql              += " AND cLote = " + quoted( cLote )

 	if ::ExecuteSqlStatement( cSql, @cStm )
    Return ( cStm )
  end if

Return nil

//---------------------------------------------------------------------------//

METHOD nUnidadesEntregadas( cNumPed, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote ) CLASS FacturasClientesLineasModel

  local cStm
  local cSql        := ""
  local nUnidades   := 0

  DEFAULT cCodPr1   := ""
  DEFAULT cCodPr2   := ""
  DEFAULT cValPr1   := ""
  DEFAULT cValPr2   := ""
  DEFAULT cLote     := ""

  cSql  += "SELECT * "
  cSql  += "FROM " + ::getTableName() + Space( 1 )
  cSql  += "WHERE cNumPed = " + quoted( cNumPed ) + " AND "
  cSql  += "cRef = " + quoted( cCodArt ) + " AND "
  cSql  += "cCodPr1 = " + quoted( cCodPr1 ) + " AND "
  cSql  += "cValPr1 = " + quoted( cValPr1 ) + " AND "
  cSql  += "cCodPr2 = " + quoted( cCodPr2 ) + " AND "
  cSql  += "cValPr2 = " + quoted( cValPr2 ) // + " AND "
  //cSql  += "cLote = " + quoted( cLote )

  if ::ExecuteSqlStatement( cSql, @cStm )
    
    if ( cStm )->( OrdKeyCount() ) != 0
        
        ( cStm )->( dbGotop() )

        while !( cStm )->( eof() )

          nUnidades   += nTotNFacCli( cStm )

        ( cStm )->( dbSkip() )

      end while

    end if
    
    end if

Return ( nUnidades )

//---------------------------------------------------------------------------//

METHOD getInfoPdtEntregar( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

    local cSql        := ""

    cSql              := "SELECT "
    cSql              += "0 as pdtrecibir, "
    do case
      case lCalCaj() .and. lCalBul()
         cSql         += "( ( nBultos * nCanEnt * nUniCaja ) * -1 ) as pdtentrega, "

      case lCalCaj() .and. !lCalBul()
         cSql         += "( ( nCanEnt * nUniCaja ) * -1 ) as pdtentrega, "

      case !lCalCaj() .and. lCalBul()
         cSql         += "( ( nBultos * nUniCaja ) * -1 ) as pdtentrega, "

      case !lCalCaj() .and. !lCalBul()
         cSql            += "( nUniCaja * - 1 ) as pdtentrega, "

    end case
    cSql              += quoted( FAC_CLI ) + " AS Document, "
    cSql              += "dFecFac AS Fecha, "
    cSql              += "tFecFac AS Hora, "
    cSql              += "cSerie AS Serie, "
    cSql              += "CAST( nNumFac AS SQL_INTEGER ) AS Numero, "
    cSql              += "cSufFac AS Sufijo, "
    cSql              += "CAST( nNumLin AS SQL_INTEGER ) AS nNumLin, "
    cSql              += "cRef AS Articulo, "
    cSql              += "cAlmLin AS Almacen "
    cSql              += "FROM " + ::getTableName()
    cSql              += " WHERE NOT ( cNumPed = '' ) AND cRef = " + quoted( cCodigoArticulo ) + " " 

    if !empty( cCodigoAlmacen )
      cSql            += "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
    end if

    if hb_isdate( dFechaHasta )
      cSql            += "AND CAST( dFecFac AS SQL_CHAR ) <= " + formatoFechaSql( dFechaHasta ) + " "
    end if

RETURN ( cSql )

//---------------------------------------------------------------------------//