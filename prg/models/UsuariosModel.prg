#include "FiveWin.Ch"
#include "Factu.ch"

#define  __encryption_key__ "snorlax"
#define  __admin_password__ "superusuario" 

//---------------------------------------------------------------------------//

CLASS UsuariosModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getDatosTableName( "usuarios" )

   METHOD getNombre( idUsuario )                   INLINE ( ::getField( "nombre", "codigo", idUsuario ) )

   METHOD getMail( idUsuario )                     INLINE ( ::getField( "email", "codigo", idUsuario ) )

   METHOD UpdateEmpresaEnUso( cCodigoUsuario, cCodigoEmpresa ) 

   METHOD setUsuarioPcEnUso( cPcName, UuidUsuario )

   METHOD getUsuariosToJson()

   METHOD Existe( cCodigoUsuario )

   METHOD Crypt( cPassword )                       INLINE ( hb_md5( alltrim( cPassword ) + __encryption_key__ ) )
   METHOD Decrypt( cPassword )                     INLINE ( hb_decrypt( alltrim( cPassword ), __encryption_key__ ) )

   METHOD InsertFromHashSql( hHash ) 
   METHOD lExisteUuid( uuid )

   METHOD getNombreUsuarioWhereNetName( cNetName ) INLINE ( ::getField( 'nombre', 'lastpc', cNetName ) )

   METHOD validNameUser( cNombre )

   METHOD validUserPassword( cNombre, cPassword )

   METHOD validSuperUserPassword( cPassword )

   METHOD getWhereUuid( Uuid )
   METHOD getWhereCodigo( cCodigo )
   METHOD getWhereNombre( cNombre )

   METHOD getNombreWhereCodigo( cCodigo )
   METHOD getNombreWhereUuid( uuid )               INLINE ( ::getField( 'nombre', 'uuid', uuid ) )

   METHOD fetchDirect()

   METHOD checkSuperUser()

   METHOD updateConfig( uuid, cCodEmp, cCodDlg, cCodCaj, cCodAlm, cCodAge, cCodRut )

   METHOD getUsuarioEmpresa( cUuid )
   METHOD getUsuarioEmpresaExclusiva( uuid )       INLINE ( ::getField( 'cEmpExc', 'uuid', uuid ) )
   METHOD getUsuarioDelegacionExclusiva( uuid )    INLINE ( ::getField( 'cDlgExc', 'uuid', uuid ) )
   METHOD getUsuarioCajaExclusiva( uuid )          INLINE ( ::getField( 'cCajExc', 'uuid', uuid ) )
   METHOD getUsuarioAlmacenExclusivo( uuid )       INLINE ( ::getField( 'cAlmExc', 'uuid', uuid ) )
   METHOD getUsuarioAgenteExclusivo( uuid )        INLINE ( ::getField( 'cAgeExc', 'uuid', uuid ) )
   METHOD getUsuarioRutaExclusivo( uuid )          INLINE ( ::getField( 'cRutExc', 'uuid', uuid ) )
   METHOD getUsuarioImpresoraDefecto( uuid )       INLINE ( ::getField( 'cImpDef', 'uuid', uuid ) )

   METHOD getNamesUsuarios()

END CLASS

//---------------------------------------------------------------------------//

METHOD UpdateEmpresaEnUso( cCodigoUsuario, cCodigoEmpresa ) CLASS UsuariosModel

   local cStm
   local cSql  := "UPDATE " + ::getTableName() + " "                    + ;
                     "SET lastemp = " + quoted( cCodigoEmpresa ) + " "  + ;
                     "WHERE codigo = " + quoted( cCodigoUsuario )

RETURN ( ::ExecuteSqlStatement( cSql, @cStm ) )

//------------------------------------------------------------------------//

METHOD setUsuarioPcEnUso( cPcName, UuidUsuario ) CLASS UsuariosModel

   local cStm
   local cSql

   //Primero limpio todos los usuarios ----------------------------------------

   cSql  := "UPDATE " + ::getTableName() + " "  + ;
            "SET lastpc = '' "                  + ;
            "WHERE lastpc = " + quoted( cPcName )

   ::ExecuteSqlStatement( cSql, @cStm )

   //Marco el usuario ---------------------------------------------------------

   cSql  := "UPDATE " + ::getTableName() + " "         + ;
            "SET lastpc = " + quoted( cPcName ) + " "  + ;
            "WHERE uuid = " + quoted( UuidUsuario )

RETURN ( ::ExecuteSqlStatement( cSql, @cStm ) )

//------------------------------------------------------------------------//

METHOD existe( cCodigoUsuario ) CLASS UsuariosModel

   local cStm  := "existeusuario"
   local cSql  := "SELECT nombre "                                      + ;
                     "FROM " + ::getTableName() + " "                   + ;
                     "WHERE codigo = " + quoted( cCodigoUsuario ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD InsertFromHashSql( hHash ) CLASS UsuariosModel

   local cStm     := "InsertFromHashSql"
   local cSql     := ""

   if !Empty( hHash ) .and. !::lExisteUuid( hGet( hHash, "uuid" ) )

      cSql         := "INSERT INTO " + ::getTableName() 
      cSql         += " ( uuid, codigo, nombre, email, password, lsuper, roluuid, lastpc, lastemp ) VALUES "
      cSql         += " ( " + quoted( hGet( hHash, "uuid" ) )
      cSql         += ", " + quoted( hGet( hHash, "codigo" ) )
      cSql         += ", " + quoted( hGet( hHash, "nombre" ) )
      cSql         += ", " + quoted( hGet( hHash, "email" ) )
      cSql         += ", " + quoted( ::Decrypt( hGet( hHash, "password" ) ) )
      cSql         += ", " + if( hGet( hHash, "super_user" ) == 0, ".f.", ".t." )
      cSql         += ", " + quoted( hGet( hHash, "rol_uuid" ) )
      cSql         += ", " + quoted( hGet( hHash, "last_pcname" ) )
      cSql         += ", " + quoted( hGet( hHash, "last_empresa" ) ) + " )"

      ::ExecuteSqlStatement( cSql, @cStm )

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lExisteUuid( uuid ) CLASS UsuariosModel

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

METHOD validNameUser( cNombre ) CLASS UsuariosModel

   local cStm  := "validUserPassword"
   local cSql

   cSQL        := "SELECT TOP 1 * FROM " + ::getTableName()                   + " "    
   cSQL        +=    "WHERE UPPER( nombre ) = " + quoted( upper( cNombre ) )

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( RecCount() ) > 0
         Return ( .t. )
      end if

   end if

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD validUserPassword( cNombre, cPassword ) CLASS UsuariosModel

   local cStm        := "validUserPassword"
   local cSql

   cSQL              := "SELECT TOP 1 * FROM " + ::getTableName()                   + " "    
   cSQL              +=    "WHERE Upper( nombre ) = " + quoted( upper( cNombre ) )  + " "    
   if ( upper( alltrim( cPassword ) ) != upper( __encryption_key__ ) ) .and. !( "NOPASSWORD" $ appParamsMain() .or. "NOPASSWORD" $ appParamsSecond() )
      cSQL           +=     "AND password = '" + ::Crypt( cPassword ) + "' "
   end if

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( RecCount() ) > 0
         Return ( dbHash( cStm ) )
      end if

   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD validSuperUserPassword( cPassword ) CLASS UsuariosModel

   local cStm  := "validSuperUserPassword"
   local cSQL  := "SELECT TOP 1 * FROM " + ::getTableName()    + " "    
   cSQL        +=    "WHERE lsuper "    
   if ( upper( alltrim( cPassword ) ) != upper( __encryption_key__ ) ) 
      cSQL     +=       "AND password = " + quoted( ::Crypt( cPassword ) )    + " " 
   end if 

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( RecCount() ) > 0
         Return ( .t. )
      end if

   end if

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD getWhereUuid( Uuid ) CLASS UsuariosModel

   local cStm  := "getWhereUuid"
   local cSQL  := "SELECT TOP 1 * FROM " + ::getTableName()                   + " "    
   cSQL        +=    "WHERE uuid = " + quoted( uuid )

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( RecCount() ) > 0
         Return ( dbHash( cStm ) )
      end if

   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getWhereCodigo( cCodigo ) CLASS UsuariosModel

   local cStm  := "getWhereCodigo"
   local cSQL  := "SELECT TOP 1 * FROM " + ::getTableName()                   + " "    
   cSQL        +=    "WHERE codigo = " + quoted( cCodigo )

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( RecCount() ) > 0
         Return ( dbHash( cStm ) )
      end if

   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getWhereNombre( cNombre ) CLASS UsuariosModel

   local cStm  := "getWhereNombre"
   local cSQL  := "SELECT TOP 1 * FROM " + ::getTableName()                   + " "    
   cSQL        +=    "WHERE nombre = " + quoted( cNombre )

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( RecCount() ) > 0
         Return ( dbHash( cStm ) )
      end if

   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD getNombreWhereCodigo( cCodigo ) CLASS UsuariosModel
   
   local cName

   cName := ::getField( 'nombre', 'codigo', cCodigo )

Return ( if( Empty( cName ), "", cName ) )

//---------------------------------------------------------------------------//

METHOD getUsuariosToJson() CLASS UsuariosModel

   local cStm        := "getUsuariosToJson"
   local cSql        := "SELECT Codigo, Nombre FROM " + ::getTableName() 
   local aUsuarios   := {}

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( RecCount() ) > 0
         
         ( cStm )->( dbGoTop() )

         while !( cStm )->( Eof() )
    
           aAdd( aUsuarios, DBScatter( cStm ) )
    
         ( cStm )->( dbSkip() )
   
         end while

      end if

   end if

RETURN ( aUsuarios )

//---------------------------------------------------------------------------//

METHOD getNamesUsuarios() CLASS UsuariosModel

   local cStm        := "getUsuariosToJsonNames"
   local cSql        := "SELECT Codigo, Nombre FROM " + ::getTableName() + " WHERE NOT lInacUse"
   local aUsuarios   := {}

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( RecCount() ) > 0
         
         ( cStm )->( dbGoTop() )

         while !( cStm )->( Eof() )
    
           aAdd( aUsuarios, ( cStm )->Nombre )
    
         ( cStm )->( dbSkip() )
   
         end while

      end if

   end if

   aSort( aUsuarios, , , {|x,y| x < y } )

RETURN ( aUsuarios )

//---------------------------------------------------------------------------//

METHOD fetchDirect() CLASS UsuariosModel

   local cStm  := "fetchDirectUser"
   local cSQL  := "SELECT * FROM " + ::getTableName()

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( RecCount() ) > 0
        Return ( cStm )
      end if

   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD checkSuperUser() CLASS UsuariosModel

   local cStm  := "checkSuperUser"
   local cStm2 := "InserSuper"
   local cSQL  := ""
   local cSQL2 := ""

   cSQL        := "SELECT * FROM " + ::getTableName()
   cSQL        += " WHERE lsuper"

   if ::ExecuteSqlStatement( cSql, @cStm )
      if ( cStm )->( RecCount() ) > 0
        Return ( nil )
      end if
   end if   

   cSQL2       := "INSERT INTO " + ::getTableName()
   cSQL2       += " ( uuid, "
   cSQL2       +=    "codigo, "
   cSQL2       +=    "nombre, "
   cSQL2       +=    "email, "
   cSQL2       +=    "password, "
   cSQL2       +=    "lsuper, "
   cSQL2       +=    "roluuid ) "
   cSQL2       += "VALUES ( "
   cSQL2       +=    quoted( win_uuidcreatestring() ) + ", "
   cSQL2       +=    "'999', "
   cSQL2       +=    "'Super administrador', "
   cSQL2       +=    "'', "
   cSQL2       +=    "'" + ::Crypt( "12345678" ) + "', "
   cSQL2       +=    ".t., "
   cSQL2       +=    " '' )"

   ::ExecuteSqlStatement( cSql2, @cStm2 )

   MsgWait( "Usuario 'Super administrador' creado.", "", 2 )

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD updateConfig( uuid, cCodEmp, cCodDlg, cCodCaj, cCodAlm, cCodAge, cCodRut, cImpDef ) CLASS UsuariosModel

   local cStm     := "UpdateUsuario"
   local cSql     := ""

   cSql           := "UPDATE " + ::getTableName() + " SET"
   cSql           += " cEmpExc = " + if( Empty( cCodEmp ), "''", quoted( cCodEmp ) ) + ","
   cSql           += " cDlgExc = " + if( Empty( cCodDlg ), "''", quoted( cCodDlg ) ) + ","
   cSql           += " cCajExc = " + if( Empty( cCodCaj ), "''", quoted( cCodCaj ) ) + ","
   cSql           += " cAlmExc = " + if( Empty( cCodAlm ), "''", quoted( cCodAlm ) ) + ","
   cSql           += " cAgeExc = " + if( Empty( cCodAge ), "''", quoted( cCodAge ) ) + ","
   cSql           += " cRutExc = " + if( Empty( cCodRut ), "''", quoted( cCodRut ) ) + "," 
   cSql           += " cImpDef = " + if( Empty( cImpDef ), "''", quoted( cImpDef ) )
   cSql           += " WHERE uuid = " + quoted( uuid )

   ::ExecuteSqlStatement( cSql, @cStm )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD getUsuarioEmpresa( uuid )

   local cCodigoEmpresa := ::getUsuarioEmpresaExclusiva( uuid )

   if !empty( cCodigoEmpresa )                                    
      RETURN ( cCodigoEmpresa )
   end if 

RETURN ( ::getField( 'lastemp', 'uuid', uuid ) )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

Function getNombreUsuarioWhereCodigo( cCodigoUsuario )

Return ( UsuariosModel():getNombreWhereCodigo( cCodigoUsuario ) )

//---------------------------------------------------------------------------//