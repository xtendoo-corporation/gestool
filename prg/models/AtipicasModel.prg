#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS AtipicasModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "CliAtp" )

   METHOD getEspecialName( cCodigoCliente, cCodigoArticulo )

   METHOD getToOdoo( cArea )

   METHOD getAtipicasFromArticulo( cCodigoArticulo )

   METHOD getDtoFromClienteArticulo( cCodigoCliente, cCodigoArticulo )

   METHOD getTarifaAtipicasFromFamilia( cCodigoCliente, cCodigoFamilia )
   
   METHOD addArticulo( hDatos )

   METHOD addReg( hDatos )

   METHOD SaveUltimoPrecioVenta( hAtipica )
      METHOD ExistAtipica( hAtipica )
      METHOD InsertAtipica( hAtipica )
      METHOD UpdateAtipica( hAtipica )

   METHOD getAtipicasFromCliente( cCodigoCliente )

   METHOD setAtipicasFromDplCliente( hAtipica )

END CLASS

//---------------------------------------------------------------------------//

METHOD getEspecialName( cCodigoCliente, cCodigoArticulo )

   local cStm
   local cSql  := "SELECT cDesEsp "                      + ;
                     "FROM " + ::getTableName() + " "             + ;
                     "WHERE cCodCli = " + quoted( cCodigoCliente ) + " AND cCodArt = " + quoted( cCodigoArticulo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( alltrim( ( cStm )->cDesEsp ) )
   end if 

RETURN ( "" )

//---------------------------------------------------------------------------//

METHOD getToOdoo( cArea ) CLASS AtipicasModel

   	local cSql  	:= "SELECT * FROM " + ::getTableName()

   	cSql 			   += " WHERE ( ( dFecIni is null AND dFecFin is null ) OR ( dFecIni <= '" + dToc( GetSysDate() ) + "' AND dFecFin >= '" + dToc( GetSysDate() ) + "' ) )"

RETURN ( ::ExecuteSqlStatement( cSql, @cArea ) )

//---------------------------------------------------------------------------//

METHOD getAtipicasFromArticulo( cCodigoArticulo ) CLASS AtipicasModel

      local aValores := {}
      local cStm
      local cSql     := "SELECT * FROM " + ::getTableName()

      cSql           += " WHERE cCodArt = " + quoted( cCodigoArticulo ) + " AND cCodCli is not null AND ( ( dFecIni is null AND dFecFin is null ) OR ( dFecIni <= '" + dToc( GetSysDate() ) + "' AND dFecFin >= '" + dToc( GetSysDate() ) + "' ) )"

      if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbGoTop() )

      while !( cStm )->( Eof() )
         
         aAdd( aValores, { "codigocliente" => ( cStm )->cCodCli,;
                           "nombrecliente" => AllTrim( RetClient( ( cStm )->cCodCli ) ),;
                           "costo" => ( cStm )->nPrcCom,;
                           "precio1" => ( cStm )->nPrcArt,;
                           "precio2" => ( cStm )->nPrcArt2,;
                           "precio3" => ( cStm )->nPrcArt3,;
                           "precio4" => ( cStm )->nPrcArt4,;
                           "precio5" => ( cStm )->nPrcArt5,;
                           "precio6" => ( cStm )->nPrcArt6,;
                           "prciva1" => ( cStm )->nPreIva1,;
                           "prciva2" => ( cStm )->nPreIva2,;
                           "prciva3" => ( cStm )->nPreIva3,;
                           "prciva4" => ( cStm )->nPreIva4,;
                           "prciva5" => ( cStm )->nPreIva5,;
                           "prciva6" => ( cStm )->nPreIva6,;
                           "ndto" => ( cStm )->nDtoArt } )

         ( cStm )->( dbSkip() )

      end while

   end if

RETURN ( aValores )

//---------------------------------------------------------------------------//

METHOD getDtoFromClienteArticulo( cCodigoCliente, cCodigoArticulo ) CLASS AtipicasModel
      
      local cStm     := "getDtoFromClienteArticulo"
      local cSql     := "SELECT nDtoArt FROM " + ::getTableName()
      local nDto     := 0

      cSql           += " WHERE cCodCli = " + quoted( cCodigoCliente ) + " AND cCodArt = " + quoted( cCodigoArticulo )

      if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

         ( cStm )->( dbGoTop() )
         nDto        := ( cStm )->nDtoArt

      end if

RETURN ( nDto )

//---------------------------------------------------------------------------//

METHOD getTarifaAtipicasFromFamilia( cCodigoCliente, cCodigoFamilia ) CLASS AtipicasModel

      local cStm
      local cSql     := "SELECT nTarifa FROM " + ::getTableName()
      local nTarifa  := 2

      cSql           += " WHERE nTipAtp = 2 AND cCodCli = " + quoted( cCodigoCliente ) + " AND cCodFam = " + quoted( cCodigoFamilia ) + " AND ( ( dFecIni is null AND dFecFin is null ) OR ( dFecIni <= '" + dToc( GetSysDate() ) + "' AND dFecFin >= '" + dToc( GetSysDate() ) + "' ) )"

      if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

         ( cStm )->( dbGoTop() )
         nTarifa        := ( cStm )->nTarifa

      end if

RETURN ( nTarifa )

//---------------------------------------------------------------------------//

METHOD AddArticulo( hDatos, lMsg ) CLASS AtipicasModel
   
   local cAreaCount
   local cSqlCount   := "SELECT Count(*) AS Counter FROM " + ::getTableName() 

   DEFAULT lMsg      := .t.

   cSqlCount         += " WHERE cCodCli = " + quoted( hGet( hDatos, "cCodCli" ) ) + " AND cCodArt = " + quoted( hGet( hDatos, "cCodArt" ) )

   ::ExecuteSqlStatement( cSqlCount, @cAreaCount )

   if ( cAreaCount )->Counter != 0
      RETURN ( nil )
   end if

   if lMsg

      if ApoloMsgNoYes(   "El artículo: " + AllTrim( hGet( hDatos, "cCodArt" ) ) + Space( 1 ) + AllTrim( hGet( hDatos, "cNomArt" ) ) + " no existe en la tarifa del cliente." +; 
                     "¿Desea añadirlo a la tarifa?", "Seleccione una opción" )

         ::addReg( hDatos )

      end if

   else

      ::addReg( hDatos )
      
   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD addReg( hDatos ) CLASS AtipicasModel

   local cAreaCount
   local cSqlCount

   cSqlCount         := "INSERT INTO " + ::getTableName() 
   cSqlCount         += " ( cCodCli, cCodArt, nPrcArt, lAplPre, lAplPed, lAplAlb, lAplFac, lAplSat, dFecIni, dFecFin ) VALUES "
   cSqlCount         += " ( " + quoted( hGet( hDatos, "cCodCli" ) )
   cSqlCount         += ", " + quoted( hGet( hDatos, "cCodArt" ) )
   cSqlCount         += ", " + Str( hGet( hDatos, "nPreUnit" ) ) + ",.t. ,.t., .t., .t., .t., '" + dToc( GetSysDate() ) + "', '01/01/2100' )"

   ::ExecuteSqlStatement( cSqlCount, @cAreaCount )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD SaveUltimoPrecioVenta( hAtipica ) CLASS AtipicasModel

   if !uFieldEmpresa( "lUltVta" )
      Return ( .f. )
   end if

   if !ClientesModel():getField( "lUltVta", "Cod", hGet( hAtipica, "cCodCli" ) )
      Return ( .f. )
   end if

   if !::ExistAtipica( hAtipica )
      ::InsertAtipica( hAtipica )
   else
      ::UpdateAtipica( hAtipica )
   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD ExistAtipica( hAtipica ) CLASS AtipicasModel

   local cStm  := "ExistAtipicaModel"
   local cSql  := "SELECT nPrcArt "                                      + ;
                     "FROM " + ::getTableName() + " "                    + ;
                     "WHERE cCodCli = " + quoted( hGet( hAtipica, "cCodCli" ) ) + ;
                     " AND cCodArt = " + quoted( hGet( hAtipica, "cCodArt" ) ) + ;
                     " AND cCodPr1 = " + quoted( hGet( hAtipica, "cCodPr1" ) ) + ;
                     " AND cCodPr2 = " + quoted( hGet( hAtipica, "cCodPr2" ) ) + ;
                     " AND cValPr1 = " + quoted( hGet( hAtipica, "cValPr1" ) ) + ;
                     " AND cValPr2 = " + quoted( hGet( hAtipica, "cValPr2" ) )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD InsertAtipica( hAtipica ) CLASS AtipicasModel

   local cStm  := "InsertAtipicaModel"
   local cSql

   cSql        := "INSERT INTO " + ::getTableName() 
   cSql        += " ( cCodCli, cCodArt, cCodPr1, cCodPr2, cValPr1, cValPr2, "

   do case
      case hGet( hAtipica, "nTarifa" ) == 2
      cSql     += "nPrcArt2"

      case hGet( hAtipica, "nTarifa" ) == 3
      cSql     += "nPrcArt3"

      case hGet( hAtipica, "nTarifa" ) == 4
      cSql     += "nPrcArt4"

      case hGet( hAtipica, "nTarifa" ) == 5
      cSql     += "nPrcArt5"

      case hGet( hAtipica, "nTarifa" ) == 6
      cSql     += "nPrcArt6"

      otherwise
      cSql     += "nPrcArt"

   end case

   cSql        += ", dUltPrc, cTimUPr, lAplPre, lAplPed, lAplAlb, lAplFac, lAplSat ) VALUES "
   cSql        += " ( " + quoted( hGet( hAtipica, "cCodCli" ) )
   cSql        += ", " + quoted( hGet( hAtipica, "cCodArt" ) )
   cSql        += ", " + quoted( hGet( hAtipica, "cCodPr1" ) )
   cSql        += ", " + quoted( hGet( hAtipica, "cCodPr2" ) )
   cSql        += ", " + quoted( hGet( hAtipica, "cValPr1" ) )
   cSql        += ", " + quoted( hGet( hAtipica, "cValPr2" ) )
   cSql        += ", " + AllTrim( Str( hGet( hAtipica, "nPrcArt" ) ) )
   cSql        += ", " + quoted( Dtoc( GetSysDate() ) ) 
   cSql        += ", " + quoted( GetSysTime() ) 
   cSql        += ", .t., .t., .t., .t., .t. )"

   ::ExecuteSqlStatement( cSql, @cStm )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD UpdateAtipica( hAtipica ) CLASS AtipicasModel

   local cStm  := "UpdateAtipicaModel"
   local cSql

   cSql        := "UPDATE " + ::getTableName() + " SET "
   
   do case
      case hGet( hAtipica, "nTarifa" ) == 2
      cSql     += "nPrcArt2=" + AllTrim( Str( hGet( hAtipica, "nPrcArt" ) ) )

      case hGet( hAtipica, "nTarifa" ) == 3
      cSql     += "nPrcArt3=" + AllTrim( Str( hGet( hAtipica, "nPrcArt" ) ) )

      case hGet( hAtipica, "nTarifa" ) == 4
      cSql     += "nPrcArt4=" + AllTrim( Str( hGet( hAtipica, "nPrcArt" ) ) )

      case hGet( hAtipica, "nTarifa" ) == 5
      cSql     += "nPrcArt5=" + AllTrim( Str( hGet( hAtipica, "nPrcArt" ) ) )

      case hGet( hAtipica, "nTarifa" ) == 6
      cSql     += "nPrcArt6=" + AllTrim( Str( hGet( hAtipica, "nPrcArt" ) ) )

      otherwise
      cSql     += "nPrcArt=" + AllTrim( Str( hGet( hAtipica, "nPrcArt" ) ) )

   end case

   cSql        += ", dFecIni=null, dFecFin=null, dUltPrc=" + quoted( Dtoc( GetSysDate() ) ) + ", cTimUPr=" + quoted( GetSysTime() ) + " "
   cSql        += "WHERE cCodCli = " + quoted( hGet( hAtipica, "cCodCli" ) )
   cSql        += " AND cCodArt = " + quoted( hGet( hAtipica, "cCodArt" ) )
   cSql        += " AND cCodPr1 = " + quoted( hGet( hAtipica, "cCodPr1" ) )
   cSql        += " AND cCodPr2 = " + quoted( hGet( hAtipica, "cCodPr2" ) )
   cSql        += " AND cValPr1 = " + quoted( hGet( hAtipica, "cValPr1" ) )
   cSql        += " AND cValPr2 = " + quoted( hGet( hAtipica, "cValPr2" ) )

   ::ExecuteSqlStatement( cSql, @cStm )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getAtipicasFromCliente( cCodigoCliente ) CLASS AtipicasModel

      local aValores := {}
      local cStm
      local cSql     := "SELECT * FROM " + ::getTableName()

      cSql           += " WHERE cCodCli = " + quoted( cCodigoCliente )

      if ADSBaseModel():ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbGoTop() )

      while !( cStm )->( Eof() )
         
         aAdd( aValores, { "lSel" => .t.,;
                           "codigocliente" => ( cStm )->cCodCli,;
                           "nombrecliente" => AllTrim( RetClient( ( cStm )->cCodCli ) ),;
                           "codigoarticulo" => ( cStm )->cCodArt,;
                           "nombrearticulo" => AllTrim( retArticulo( ( cStm )->cCodArt ) ),;
                           "codigoFamilia" => ( cStm )->cCodFam,;
                           "nTipAtp" => ( cStm )->nTipAtp,;
                           "dFecIni" => ( cStm )->dFecIni,;
                           "dFecFin" => ( cStm )->dFecFin,;
                           "costo" => ( cStm )->nPrcCom,;
                           "precio1" => ( cStm )->nPrcArt,;
                           "precio2" => ( cStm )->nPrcArt2,;
                           "precio3" => ( cStm )->nPrcArt3,;
                           "precio4" => ( cStm )->nPrcArt4,;
                           "precio5" => ( cStm )->nPrcArt5,;
                           "precio6" => ( cStm )->nPrcArt6,;
                           "prciva1" => ( cStm )->nPreIva1,;
                           "prciva2" => ( cStm )->nPreIva2,;
                           "prciva3" => ( cStm )->nPreIva3,;
                           "prciva4" => ( cStm )->nPreIva4,;
                           "prciva5" => ( cStm )->nPreIva5,;
                           "prciva6" => ( cStm )->nPreIva6,;
                           "ndto" => ( cStm )->nDtoArt } )

         ( cStm )->( dbSkip() )

      end while

   end if

RETURN ( aValores )

//---------------------------------------------------------------------------//

METHOD setAtipicasFromDplCliente( hAtipica, cCodCli ) CLASS AtipicasModel

   local cStm  := "InsertAtipicaDplModel"
   local cSql

   cSql        := "INSERT INTO " + ::getTableName() 
   cSql        += " ( cCodCli, cCodArt, nPrcArt, nPreIva1, nDtoArt, dUltPrc, cTimUPr, lAplPre, lAplPed, lAplAlb, lAplFac, lAplSat ) VALUES "
   cSql        += " ( " + quoted( cCodCli )
   cSql        += ", " + quoted( hGet( hAtipica, "codigoarticulo" ) )
   cSql        += ", " + AllTrim( Str( hGet( hAtipica, "precio1" ) ) )
   cSql        += ", " + AllTrim( Str( hGet( hAtipica, "prciva1" ) ) )
   cSql        += ", " + AllTrim( Str( hGet( hAtipica, "ndto" ) ) )
   cSql        += ", " + quoted( Dtoc( GetSysDate() ) ) 
   cSql        += ", " + quoted( GetSysTime() ) 
   cSql        += ", .t., .t., .t., .t., .t. )"

   ::ExecuteSqlStatement( cSql, @cStm )

   RETURN ( nil )

//---------------------------------------------------------------------------//