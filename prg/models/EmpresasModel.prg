#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS EmpresasModel FROM ADSBaseModel

   METHOD getTableName()                              INLINE ::getDatosTableName( "Empresa" )

   METHOD UpdateEmpresaCodigoEmpresa()

   METHOD getCodigoActiva()

   METHOD getCodigoGrupo( cCodigoEmpresa )

   METHOD getRegistrosActivos()

   METHOD getPrimera()

   METHOD getCodigoGrupoCliente( cCodigoEmpresa )     INLINE ( ::getCodigoGrupoCampoLogico( cCodigoEmpresa, "lGrpCli" ) )

   METHOD getCodigoGrupoProveedor( cCodigoEmpresa )   INLINE ( ::getCodigoGrupoCampoLogico( cCodigoEmpresa, "lGrpPrv" ) )

   METHOD getCodigoGrupoArticulo( cCodigoEmpresa )    INLINE ( ::getCodigoGrupoCampoLogico( cCodigoEmpresa, "lGrpArt" ) )

   METHOD getCodigoGrupoAlmacen( cCodigoEmpresa )     INLINE ( ::getCodigoGrupoCampoLogico( cCodigoEmpresa, "lGrpAlm" ) )

   METHOD getCodigoGrupoCampoLogico( cCodigoEmpresa, cCampoLogico )

   METHOD scatter( cCodigoEmpresa )

   METHOD DeleteEmpresa( cCodigoEmpresa )

   METHOD aNombres()
   METHOD aNombresSeleccionables()                    INLINE ( ains( ::aNombres(), 1, "", .t. ) )

   METHOD getUuidFromNombre( cNombre )                INLINE ( ::getField( "Uuid", "cNombre", cNombre ) )
   METHOD getNombreFromUuid( cUuid )                  INLINE ( ::getField( "cNombre", "Uuid", cUuid ) )

   METHOD getCodigoFromNombre( cNombre )              INLINE ( ::getField( "CodEmp", "cNombre", cNombre ) )
   METHOD getNombreFromCodigo( cCodigo )              INLINE ( ::getField( "cNombre", "CodEmp", cCodigo ) )

END CLASS

//---------------------------------------------------------------------------//

METHOD UpdateEmpresaCodigoEmpresa()

   local cStm
   local cSql  := "UPDATE " + ::getTableName() + " " + ;
                  "SET CodEmp = CONCAT( '00', TRIM( CodEmp ) ) WHERE ( LENGTH( CodEmp ) < 4 )"

RETURN ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD getCodigoGrupo( cCodigoEmpresa )

   local cStm
   local cSql  := "SELECT cCodGrp FROM " + ::getTableName() + " WHERE CodEmp = '" + alltrim( cCodigoEmpresa ) + "'"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->cCodGrp )
   end if 

RETURN ( "" )

//---------------------------------------------------------------------------//

METHOD getCodigoActiva()

   local cStm
   local cSql  := "SELECT CodEmp FROM " + ::getTableName() + " WHERE lActiva"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->CodEmp )
   end if 

RETURN ( "" )

//---------------------------------------------------------------------------//

METHOD getRegistrosActivos()

   local cStm
   local cSql  := "SELECT Count(*) AS Counter FROM " + ::getTableName() 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->Counter )
   end if 

RETURN ( 0 )

//---------------------------------------------------------------------------//

METHOD getPrimera()

   local cStm
   local cSql  := "SELECT TOP 1 CodEmp FROM " + ::getTableName() + " WHERE NOT lGrupo"

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->CodEmp )
   end if 

RETURN ( "" )

//---------------------------------------------------------------------------//

METHOD getCodigoGrupoCampoLogico( cCodigoEmpresa, cCampoLogico )

   local cStm
   local cSql

   cSql              := "SELECT cCodGrp FROM " + ::getTableName()   + " " + ;
                                 "WHERE CodEmp = " + quoted( cCodigoEmpresa )    + " " + ;
                                 "AND " + cCampoLogico + " = TRUE"

   if ::ExecuteSqlStatement( cSql, @cStm )
      if !empty( ( cStm )->cCodGrp )
         cCodigoEmpresa    := ( cStm )->cCodGrp
      end if 
   end if 

RETURN ( cCodigoEmpresa )

//---------------------------------------------------------------------------//

METHOD scatter( cCodigoEmpresa )

   local cStm
   local cSql  := "SELECT * FROM " + ::getTableName() + " WHERE CodEmp = " + quoted( cCodigoEmpresa )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( dbScatter( cStm ) )
   end if 

RETURN ( {} )

//---------------------------------------------------------------------------//

METHOD DeleteEmpresa( cCodigoEmpresa )

   local cStm
   local cSql  := "DELETE FROM " + ::getTableName() + " " + ;
                     "WHERE CodEmp = " + quoted( cCodigoEmpresa )

RETURN ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD aNombres()

   local cStm
   local aEmp  := {}
   local cSql  := "SELECT * FROM " + ::getTableName() 

   if !::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( aEmp )
   endif 

   while !( cStm )->( eof() ) 
      aadd( aEmp, alltrim( ( cStm )->cNombre ) )
      ( cStm )->( dbskip() )
   end while

RETURN ( aEmp )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS ConfiguracionesEmpresaModel FROM ADSBaseModel

   METHOD getTableName()                              INLINE ::getDatosTableName( "ConfEmp" )

   METHOD InsertFromHashSql( hHash )
   
   METHOD lExisteUuid( uuid )

   METHOD getValue()

   METHOD setValue()

   METHOD getNumeric( name, default )

   METHOD getChar( name, default )                    INLINE ( ::getValue( name, default ) )

   METHOD getLogic()

END CLASS

//---------------------------------------------------------------------------//

METHOD InsertFromHashSql( hHash ) CLASS ConfiguracionesEmpresaModel

   local cStm     := "InsertFromHashSql"
   local cSql     := ""

   if !Empty( hHash ) .and. !::lExisteUuid( Str( hGet( hHash, "id" ) ) ) 

      cSql         := "INSERT INTO " + ::getTableName() 
      cSql         += " ( cCodEmp, cName, cValue, uuid ) VALUES "
      cSql         += " ( " + quoted( hGet( hHash, "empresa" ) )
      cSql         += ", " + quoted( hGet( hHash, "name" ) )
      cSql         += ", " + quoted( hGet( hHash, "value" ) )
      cSql         += ", " + quoted( Str( hGet( hHash, "id" ) ) ) + " )"

      ::ExecuteSqlStatement( cSql, @cStm )

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lExisteUuid( uuid ) CLASS ConfiguracionesEmpresaModel

   local cStm     := "lExisteUuid"
   local cSql     := ""

   cSql     := "SELECT * FROM " + ::getTableName() + " WHERE uuid = " + quoted( uuid )

      if ::ExecuteSqlStatement( cSql, @cStm )

         if ( cStm )->( RecCount() ) > 0
            Return ( .t. )
         end if

      end if

Return ( .f. )

//---------------------------------------------------------------------------//

METHOD getValue( name, default ) CLASS ConfiguracionesEmpresaModel

   local cStm        := "getValueConfigEmp"
   local cSentence   := "SELECT cValue FROM " + ::getTableName()            + space( 1 ) + ;
                           "WHERE cCodEmp = " + quoted( cCodEmp() )        + space( 1 ) + ;
                           "AND cName = " + quoted( name )

   if ::ExecuteSqlStatement( cSentence, @cStm )

      if ( cStm )->( RecCount() ) > 0
         ( cStm )->( dbGoTop() )
         Return ( ( cStm )->cValue )
      end if

   end if

RETURN ( default )

//---------------------------------------------------------------------------//

METHOD getNumeric( name, default ) CLASS ConfiguracionesEmpresaModel

   local uValue      := ::getValue( name, default )

   if !hb_isnumeric( uValue ) 
      RETURN ( val( uValue ) )
   end if 

RETURN ( uValue )

//---------------------------------------------------------------------------//

METHOD getLogic( name, default ) CLASS ConfiguracionesEmpresaModel

   local cValue

   if !hb_islogical( default )
      default  := .f.
   end if 

   cValue      := ::getValue( name )

   if !empty( cValue )
      RETURN ( ".T." $ upper( cValue ) )
   end if 

RETURN ( default )

//---------------------------------------------------------------------------//

METHOD setValue( name, value ) CLASS ConfiguracionesEmpresaModel

   local id
   local cStm1    := "SetValue1"
   local cStm2    := "SetValue2"
   local cSentence

   value          := cValToStr( value )

   cSentence      := "SELECT uuid FROM " + ::getTableName()                + space( 1 )   + ;
                        "WHERE cCodEmp = " + quoted( cCodEmp() )           + space( 1 )   + ;
                        "AND cName = " + quoted( name ) 

   if ::ExecuteSqlStatement( cSentence, @cStm1 )

      if ( cStm1 )->( RecCount() ) > 0
         
         ( cStm1 )->( dbGoTop() )
         
         id       := ( cStm1 )->uuid

      end if

   end if

   if empty( id )

      cSentence   := "INSERT INTO " + ::getTableName()                  + space( 1 )   + ;
                     "( cCodEmp,"                                       + space( 1 )   + ;
                        "cName,"                                        + space( 1 )   + ;
                        "cValue,"                                       + space( 1 )   + ;
                        "uuid )"                                        + space( 1 )   + ;
                     "VALUES"                                           + space( 1 )   + ;
                     "( " + quoted( cCodEmp() ) + ","                   + space( 1 )   + ;
                        quoted( name ) + ","                            + space( 1 )   + ;
                        quoted( value ) + ","                           + space( 1 )   + ;
                        quoted( win_uuidcreatestring() ) + " )" 

   else 

      cSentence   := "UPDATE " + ::getTableName()                       + space( 1 )   + ;
                     "SET"                                              + space( 1 )   + ;
                        "cValue = " + toSQLString( value )              + space( 1 )   + ;
                     "WHERE uuid = " + quoted( id )

   end if 

   ::ExecuteSqlStatement( cSentence, @cStm2 )

RETURN ( Self )

//---------------------------------------------------------------------------//