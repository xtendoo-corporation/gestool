#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS AlbaranesClientesLineasModel FROM TransaccionesComercialesLineasModel

   METHOD getTableName()                          INLINE ::getEmpresaTableName( "AlbCliL" )

   METHOD getExtraWhere()                         INLINE ( "AND nCtlStk < 2 AND NOT lFacturado" )

   METHOD getFechaFieldName()                     INLINE ( "dFecAlb" )
   METHOD getHoraFieldName()                      INLINE ( "tFecAlb" )

   METHOD getSerieFieldName()                     INLINE ( "cSerAlb" )
   METHOD getNumeroFieldName()                    INLINE ( "nNumAlb" )
   METHOD getSufijoFieldName()                    INLINE ( "cSufAlb" )

   METHOD getTipoDocumento()                      INLINE ( ALB_CLI )

   METHOD lineasUnidadesEntregadas( cNumPed, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote )

   METHOD nUnidadesEntregadas( cNumPed, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote )

   METHOD getLinesFromDocument( cSerie, nNumero, cSufijo, lPrepare )

   METHOD getInfoPdtEntregar( cCodigoArticulo, cCodigoAlmacen, dFechaHasta )

   METHOD UpdateFacturado( cNumAlb, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote )

   METHOD UpdateAllFacturado( cNumAlb, lFacturado )

   METHOD getLines( cNumAlb )

   METHOD aLines( cNumAlb )                       INLINE ( DBHScatter( ::getLines( cNumAlb ) ) )

   METHOD getUndVendidasFromDocument( cCodArt, idDoc )

END CLASS

//---------------------------------------------------------------------------//

METHOD lineasUnidadesEntregadas( cNumPed, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote ) CLASS AlbaranesClientesLineasModel

	local cStm 		  := "lineasUnidadesEntregadasAlbCli"
	local cSql 	      := ""

  	DEFAULT cCodPr1   := ""
  	DEFAULT cCodPr2   := ""
  	DEFAULT cValPr1   := ""
  	DEFAULT cValPr2   := ""
  	DEFAULT cLote     := ""

	cSql  		      += "SELECT * "
  	cSql  		      += "FROM " + ::getTableName() + Space( 1 )
	cSql  		      += "WHERE cNumPed = " + quoted( cNumPed ) + " AND "
	cSql  		      += "cRef = " + quoted( cCodArt ) + " AND "
 	cSql              += "cCodPr1 = " + quoted( cCodPr1 ) + " AND "
  	cSql              += "cCodPr2 = " + quoted( cCodPr2 ) + " AND "
  	cSql  	          += "cValPr1 = " + quoted( cValPr1 ) + " AND "
	cSql  	          += "cValPr2 = " + quoted( cValPr2 ) // + " AND "
  	//cSql              += "cLote = " + quoted( cLote )

 	if ::ExecuteSqlStatement( cSql, @cStm )
      Return ( cStm )
   	end if

Return nil

//---------------------------------------------------------------------------//

METHOD nUnidadesEntregadas( cNumPed, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote ) CLASS AlbaranesClientesLineasModel

	local cStm
	local cSql 			:= ""
	local nUnidades 	:= 0

	DEFAULT cCodPr1 	:= ""
	DEFAULT cCodPr2 	:= ""
	DEFAULT cValPr1 	:= ""
	DEFAULT cValPr2 	:= ""
	DEFAULT cLote 		:= ""

	cSql	+= "SELECT * "
    cSql	+= "FROM " + ::getTableName() + Space( 1 )
	cSql	+= "WHERE not lFacturado AND cNumPed = " + quoted( cNumPed ) + " AND "
    cSql	+= "cRef = " + quoted( cCodArt ) + " AND "
	cSql	+= "cCodPr1 = " + quoted( cCodPr1 ) + " AND "
    cSql	+= "cValPr1 = " + quoted( cValPr1 ) + " AND "
	cSql	+= "cCodPr2 = " + quoted( cCodPr2 ) + " AND "
 	cSql	+= "cValPr2 = " + quoted( cValPr2 ) // + " AND "
 	//cSql	+= "cLote = " + quoted( cLote )

 	if ::ExecuteSqlStatement( cSql, @cStm )
    
 		if ( cStm )->( OrdKeyCount() ) != 0
    		
    		( cStm )->( dbGotop() )

    		while !( cStm )->( eof() )

    			nUnidades 	+= nTotNAlbCli( cStm )

				( cStm )->( dbSkip() )

			end while

		end if
   	
   	end if

Return ( nUnidades )

//---------------------------------------------------------------------------//

METHOD getLinesFromDocument( cSerie, nNumero, cSufijo, lPrepare ) CLASS AlbaranesClientesLineasModel
  
  local aLines      := {}
  local cStm        := "PrepareLineasAlbCli"
  local cSql        := ""

  DEFAULT lPrepare  := .f.

  cSql              += "SELECT * "
  cSql              += "FROM " + ::getTableName() + Space( 1 )
  cSql              += "WHERE cSerAlb = " + quoted( cSerie ) + " AND "
  cSql              += "nNumAlb = " + Str( nNumero ) + " AND "
  cSql              += "cSufAlb = " + quoted( cSufijo ) + " AND "
  
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

    cSql              += quoted( ALB_CLI ) + " AS Document, "
    cSql              += "dFecAlb AS Fecha, "
    cSql              += "tFecAlb AS Hora, "
    cSql              += "cSerAlb AS Serie, "
    cSql              += "CAST( nNumAlb AS SQL_INTEGER ) AS Numero, "
    cSql              += "cSufAlb AS Sufijo, "
    cSql              += "CAST( nNumLin AS SQL_INTEGER ) AS nNumLin, "
    cSql              += "cRef AS Articulo, "
    cSql              += "cAlmLin AS Almacen "
    cSql              += "FROM " + ::getTableName()
    cSql              += " WHERE NOT lFacturado AND NOT ( cNumPed = '' ) AND cRef = " + quoted( cCodigoArticulo ) + " " 

    if !empty( cCodigoAlmacen )
      cSql            += "AND cAlmLin = " + quoted( cCodigoAlmacen ) + " "
    end if

    if hb_isdate( dFechaHasta )
      cSql            += "AND CAST( dFecAlb AS SQL_CHAR ) <= " + formatoFechaSql( dFechaHasta ) + " "
    end if

RETURN ( cSql )

//---------------------------------------------------------------------------//

METHOD UpdateFacturado( cNumAlb, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, cLote, lFacturado )

  local cStm  := "UpdateFacturado"
  local cSql  := ""

  DEFAULT lFacturado := .t.

  cSql        := "UPDATE " + ::getTableName()
  cSql        += " SET lFacturado = " + if( lFacturado, ".t.", ".f." )
  cSql        += " WHERE cSerAlb = " + quoted( SubStr( cNumAlb, 1, 1 ) )
  cSql        += " AND nNumAlb = " + SubStr( cNumAlb, 2, 9 )
  cSql        += " AND cSufAlb = " + quoted( SubStr( cNumAlb, 11, 2 ) )
  cSql        += " AND cRef = " + quoted( cCodArt )
  cSql        += " AND cCodPr1 = " + quoted( cCodPr1 )
  cSql        += " AND cCodPr2 = " + quoted( cCodPr2 )
  cSql        += " AND cValPr1 = " + quoted( cValPr1 )
  cSql        += " AND cValPr2 = " + quoted( cValPr2 )
  cSql        += " AND cLote = " + quoted( cLote )

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD UpdateAllFacturado( cNumAlb, lFacturado )

  local cStm  := "UpdateFacturado"
  local cSql  := ""

  DEFAULT lFacturado := .t.

  cSql        := "UPDATE " + ::getTableName()
  cSql        += " SET lFacturado = " + if( lFacturado, ".t.", ".f." )
  cSql        += " WHERE cSerAlb = " + quoted( SubStr( cNumAlb, 1, 1 ) )
  cSql        += " AND nNumAlb = " + SubStr( cNumAlb, 2, 9 )
  cSql        += " AND cSufAlb = " + quoted( SubStr( cNumAlb, 11, 2 ) )

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD getLines( cNumAlb )

  local cStm  := "getLines"
  local cSql  := ""

  cSql        := "SELECT * FROM " + ::getTableName()
  cSql        += " WHERE cSerAlb = " + quoted( SubStr( cNumAlb, 1, 1 ) )
  cSql        += " AND nNumAlb = " + SubStr( cNumAlb, 2, 9 )
  cSql        += " AND cSufAlb = " + quoted( SubStr( cNumAlb, 11, 2 ) )

    if ::ExecuteSqlStatement( cSql, @cStm )
        Return ( cStm )
    end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getUndVendidasFromDocument( cCodArt, idDoc ) CLASS AlbaranesClientesLineasModel
  
  local cStm        := "UnidadesVendidasLineasAlbCli"
  local cSql        := ""
  local nUnd        := 0

  cSql              += "SELECT nUniCaja "
  cSql              += "FROM " + ::getTableName() + Space( 1 )
  cSql              += "WHERE cRef = " + quoted( cCodArt ) + " AND "
  cSql              += "cidNumCom = " + quoted( idDoc )
  
  if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbGoTop() )

      while !( cStm )->( Eof() )

        nUnd        += ( cStm )->nUniCaja

        ( cStm )->( dbSkip() )

      end while

  end if

Return ( nUnd )

//---------------------------------------------------------------------------//