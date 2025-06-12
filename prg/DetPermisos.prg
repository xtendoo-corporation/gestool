#include "FiveWin.Ch"
#include "Font.ch"
#include "Report.ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//---------------------------------------------------------------------------//

CLASS TDetPermisos FROM TDet

   METHOD New()

   METHOD DefineFiles()

END CLASS

//---------------------------------------------------------------------------//   

METHOD New( cPath, cDriver, oParent ) CLASS TDetPermisos

   DEFAULT cPath        := cPatEmp()
   DEFAULT cDriver      := cDriver()

   ::cPath              := cPath
   ::cDriver            := cDriver
   ::oParent            := oParent

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD DefineFiles( cPath, cDriver ) CLASS TDetPermisos

   DEFAULT cPath        := ::cPath
   DEFAULT cDriver      := cDriver()

   DEFINE DATABASE ::oDbf FILE "DETPERMISOS.DBF" CLASS "DETPERMISOS" PATH ( cPath ) VIA ( cDriver ) COMMENT "Detatte de permisos"

      FIELD NAME "uuid"       TYPE "C" LEN  40  DEC 0  COMMENT "Identificador"   DEFAULT win_uuidcreatestring()   OF ::oDbf
      FIELD NAME "uuidperm"   TYPE "C" LEN 100  DEC 0  COMMENT "Uuid de permiso"                                  OF ::oDbf
      FIELD NAME "nombre"     TYPE "C" LEN 100  DEC 0  COMMENT "Nombre"                                           OF ::oDbf
      FIELD NAME "nivel"      TYPE "N" LEN   3  DEC 0  COMMENT "Nivel de permisos"                                OF ::oDbf

      INDEX TO "DETPERMISOS.CDX" TAG "Uuid" ON "uuid" COMMENT "uuid" NODELETED OF ::oDbf

   END DATABASE ::oDbf

RETURN ( ::oDbf )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS DetPermisosModel FROM ADSBaseModel

   METHOD getTableName()            INLINE ::getDatosTableName( "detpermisos" )

   METHOD getNivel( cPermisoUuid, cNombre )

   METHOD exist( uuidperm, nombre )
   METHOD set( uuidperm, nombre, nivel )
      METHOD exist( uuidperm, nombre )
      METHOD insert( uuidperm, nombre, nivel )
      METHOD update( uuidperm, nombre, nivel )

   METHOD InsertFromHashSql( hHash )
   METHOD lExisteUuid( uuid )

   METHOD getNivelRol( cUuidRol, cOption )

   METHOD deleteLines( uuidperm )

END CLASS

//---------------------------------------------------------------------------//

METHOD getNivel( cPermisoUuid, cNombre ) CLASS DetPermisosModel

   local cStm  := "getNivel"
   local cSQL  := "SELECT nivel FROM " + ::getTableName()           + " " + ;
                     "WHERE uuidperm = " + quoted( cPermisoUuid )   + " " + ;
                        "AND nombre = " + quoted( cNombre )

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( lastrec() ) > 0

         ( cStm )->( dbGoTop() )
         
         RETURN ( ( cStm )->nivel )

      end if

   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD exist( uuidperm, nombre ) CLASS DetPermisosModel

   local cStm  := "ExistDetPerm"
   local cSql  := "SELECT nivel " + ;
                     "FROM " + ::getTableName()                   + " " + ;
                     "WHERE uuidperm = " + quoted( uuidperm )     + " AND " + ;
                           "nombre = " + quoted( nombre )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD set( uuidperm, nombre, nivel ) CLASS DetPermisosModel

   if ::exist( uuidperm, nombre )
      RETURN ( ::update( uuidperm, nombre, nivel ) )
   end if 

RETURN ( ::insert( uuidperm, nombre, nivel ) )

//---------------------------------------------------------------------------//

METHOD insert( uuidperm, nombre, nivel ) CLASS DetPermisosModel

   local cStm              := "insertDetPerm"
   local cSql  

   cSql                    := "INSERT INTO " + ::getTableName() + " "      
   cSql                    +=    "( uuid, "                                   
   cSql                    +=       "uuidperm, "   
   cSql                    +=       "nombre, "                                  
   cSql                    +=       "nivel ) "                                 
   cSql                    += "VALUES "                                          
   cSql                    +=    "( " + quoted( win_uuidcreatestring() ) + ", "
   cSql                    +=       quoted( uuidperm ) + ", "
   cSql                    +=       quoted( nombre ) + ", "             
   cSql                    +=       alltrim( str( nivel ) ) + " )" 

RETURN ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD update( uuidperm, nombre, nivel ) CLASS DetPermisosModel

   local cStm              := "updateDetPerm"
   local cSql

   cSql                    := "UPDATE " + ::getTableName() + " "
   cSql                    +=    "SET "
   cSql                    +=       "nivel = " + alltrim( str( nivel ) ) + " " 
   cSql                    +=    "WHERE uuidperm = " + quoted( uuidperm ) + " AND " 
   cSql                    +=        "nombre = " + quoted( nombre )

RETURN ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD getNivelRol( cUuidRol, cOption ) CLASS DetPermisosModel

   local cStm  := "getNivelRol"
   local cSQL  := "SELECT nivel FROM " + ::getTableName() + " detpermisos " +  ;
                     "INNER JOIN " + ::getDatosTableName( "permisos" ) + " AS permisos " +  ;
                        "ON permisos.uuid = detpermisos.uuidperm"       + " " +  ;
                     "INNER JOIN " + ::getDatosTableName( "roles" ) + " AS roles " +  ;
                        "ON roles.permuuid = permisos.uuid"                   + " " +  ;
                     "WHERE roles.uuid = " + quoted( cUuidRol )               + " " +  ;
                        "AND detpermisos.nombre = " + quoted( cOption )

   if ::ExecuteSqlStatement( cSql, @cStm )

      if ( cStm )->( RecCount() ) > 0
         return ( cStm )->nivel
      end if

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD InsertFromHashSql( hHash ) CLASS DetPermisosModel

   local cStm     := "InsertFromHashSql"
   local cSql     := ""

   if !Empty( hHash ) .and. !::lExisteUuid( hGet( hHash, "uuid" ) )

      cSql         := "INSERT INTO " + ::getTableName() 
      cSql         += " ( uuid, uuidperm, nombre, nivel ) VALUES "
      cSql         += " ( " + quoted( hGet( hHash, "uuid" ) )
      cSql         += ", " + quoted( hGet( hHash, "permiso_uuid" ) )
      cSql         += ", " + quoted( hGet( hHash, "nombre" ) )
      cSql         += ", " + AllTrim( Str( hGet( hHash, "nivel" ) ) ) + " )"

      ::ExecuteSqlStatement( cSql, @cStm )

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lExisteUuid( uuid ) CLASS DetPermisosModel

   local cStm     := "lExisteUuid"
   local cSql     := ""

   cSql     := "SELECT * FROM " + ::getTableName() + " WHERE uuid = " + quoted( uuid )

      if ::ExecuteSqlStatement( cSql, @cStm )

         if ( cStm )->( RecCount() ) > 0
            Return ( .t. )
         end if

      end if

Return ( .f. )

//----------------------------------------------------------------------------//

METHOD deleteLines( uuidperm ) CLASS DetPermisosModel

   local cStm     := "deleteLines"
   local cSql     := ""

   cSql     := "DELETE FROM " + ::getTableName() + " WHERE uuidperm = " + quoted( uuidperm )

   ::ExecuteSqlStatement( cSql, @cStm )

Return ( nil )

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//