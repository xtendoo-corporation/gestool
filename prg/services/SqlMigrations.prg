#include "fiveWin.ch"
#include "hdo.ch"

//----------------------------------------------------------------------------//

CLASS SQLMigrations

   DATA hJson                             INIT {=>}

   DATA aModels                           INIT {}

   DATA aRepositories                     INIT {}

   METHOD Run()

   METHOD checkDatabase()
   
   METHOD createDatabase()

   METHOD readgestoolDatabaseJSON()

   METHOD addModels()

   METHOD checkModels()   

   METHOD checkModel( oModel )

   METHOD checkRepositories()

   METHOD checkRepository( oRepository )

   METHOD getSchemaColumns( cDatabaseMySQL, cTableName )    

ENDCLASS

//----------------------------------------------------------------------------//

METHOD checkDatabase()

   getSQLDatabase():ConnectWithoutDataBase()

   if !::readgestoolDatabaseJSON()
      RETURN ( self )
   end if 

   if hhaskey( ::hJson, "Databases" )
      aeval( hget( ::hJson, "Databases" ),;
         {|hDatabase| ::Run( hget( hDatabase, "Database" ) ) } )
   end if 

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD Run( cDatabaseMySQL ) 

   ::createDatabase( cDatabaseMySQL )

   ::addModels()

   ::checkModels( cDatabaseMySQL )

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD createDatabase( cDatabaseMySQL )

   DEFAULT cDatabaseMySQL  := getSQLDatabase():cDatabaseMySQL

   getSQLDatabase():ExecWithOutParse( "CREATE DATABASE IF NOT EXISTS " + cDatabaseMySQL + ";" )
   
   getSQLDatabase():ExecWithOutParse( "USE " + cDatabaseMySQL + ";" )
       
RETURN ( self )    

//----------------------------------------------------------------------------//

METHOD checkModels( cDatabaseMySQL )

RETURN ( aeval( ::aModels, {|oModel| ::checkModel( cDatabaseMySQL, oModel ) } ) )

//----------------------------------------------------------------------------//

METHOD checkModel( cDatabaseMySQL, oModel )

   local aSchemaColumns    := ::getSchemaColumns( cDatabaseMySQL, oModel:cTableName )

   if empty( aSchemaColumns )
      getSQLDatabase():Exec( oModel:getCreateTableSentence( cDatabaseMySQL ) )
   else
      getSQLDatabase():Execs( oModel:getAlterTableSentences( cDatabaseMySQL, aSchemaColumns ) )
   end if 
  
RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD checkRepositories()

RETURN ( aeval( ::aRepositories, {|oRepository| ::checkRepository( oRepository ) } ) )

//----------------------------------------------------------------------------//

METHOD checkRepository( oRepository )

   getSQLDatabase():Execs( oRepository:getSQLFunctions() )

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD getSchemaColumns( cDatabaseMySQL, cTableName )

   local oError
   local cSentence
   local oStatement
   local aSchemaColumns

   DEFAULT cDatabaseMySQL  := getSQLDatabase():cDatabaseMySQL

   if empty( cTableName )
      RETURN ( nil )  
   end if  

   if empty( getSQLDatabase():oConexion )
      msgstop( "No hay conexiones disponibles" )
      RETURN ( nil )  
   end if  

   cSentence               := "SELECT COLUMN_NAME "                                       + ;
                                 "FROM INFORMATION_SCHEMA.COLUMNS "                       + ;
                                 "WHERE table_schema = " + quoted( cDatabaseMySQL ) + " " + ; 
                                    "AND table_name = " + quoted( cTableName )
                                  
   try

      oStatement           := getSQLDatabase():oConexion:Query( cSentence )
   
      aSchemaColumns       := oStatement:fetchAll( FETCH_HASH )

   catch oError

      eval( errorBlock(), oError )

   finally

      if !empty( oStatement )
        oStatement:free()
      end if    
   
   end

   if empty( aSchemaColumns ) .or. !hb_isarray( aSchemaColumns )
      RETURN ( nil )
   end if

RETURN ( aSchemaColumns )

//---------------------------------------------------------------------------//

METHOD addModels()
 
RETURN ( ::aModels )
 
//----------------------------------------------------------------------------//

METHOD readgestoolDatabaseJSON()

   local hJson
   local cgestoolDatabase     := "gestoolDatabase.json"

   hb_jsonDecode( memoread( cgestoolDatabase ), @hJson )      

   if empty( hJson )
      RETURN ( .f. )
   end if 

   ::hJson                    := hJson

RETURN ( .t. )

//---------------------------------------------------------------------------//
