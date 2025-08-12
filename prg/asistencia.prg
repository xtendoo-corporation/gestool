#include "FiveWin.Ch"
#include "Font.ch"
#include "Report.ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//----------------------------------------------------------------------------//

CLASS TAsistencias FROM TMant

   DATA cMru           INIT "server_id_card_16"
   DATA cBitmap        INIT  clrTopHerramientas

   DATA nView

   METHOD DefineFiles()
   
   METHOD New( cPath, oWndParent, oMenuItem )
   METHOD Create( cPath )

   METHOD Activate()

END CLASS

//----------------------------------------------------------------------------//

METHOD DefineFiles( cPath, cDriver ) CLASS TAsistencias

   DEFAULT cPath        := ::cPath
   DEFAULT cDriver      := cDriver()

   DEFINE DATABASE ::oDbf FILE "ASISTENCIA.DBF" CLASS "ASISTENCIA" PATH ( cPath ) VIA ( cDriver ) COMMENT "Registo de usuarios"
      
      FIELD NAME "uuid"       TYPE "C" LEN  40  DEC 0  COMMENT "Identificador"               HIDE                                            OF ::oDbf
      FIELD NAME "cCodUsr"    TYPE "C" LEN   3  DEC 0  COMMENT "Código"                      COLSIZE  50                                     OF ::oDbf
      FIELD CALCULATE NAME "cNomUsr"   LEN 100  DEC 0  COMMENT "Usuario"  VAL ( UsuariosModel():getNombre( ::oDbf:cCodUsr ) )  COLSIZE 250   OF ::oDbf
      FIELD CALCULATE NAME "cMailUsr"  LEN 100  DEC 0  COMMENT "Email"    VAL ( UsuariosModel():getMail( ::oDbf:cCodUsr ) )    COLSIZE 250   OF ::oDbf
      FIELD NAME "dFecEnt"    TYPE "D" LEN   8  DEC 0  COMMENT "Fecha entrada"               COLSIZE  80                                     OF ::oDbf
      FIELD NAME "cHorEnt"    TYPE "C" LEN   8  DEC 0  COMMENT "Hora entrada"                HIDE                                            OF ::oDbf
      FIELD CALCULATE NAME "cHorEntF"  LEN   8  DEC 0  COMMENT "Hora entrada"  VAL ( Trans( ::oDbf:cHorEnt, "@R 99:99:99" ) )  COLSIZE 80    OF ::oDbf
      FIELD NAME "dFecSal"    TYPE "D" LEN   8  DEC 0  COMMENT "Fecha salida"                COLSIZE  80                                     OF ::oDbf
      FIELD NAME "cHorSal"    TYPE "C" LEN   8  DEC 0  COMMENT "Hora salida"                 HIDE                                            OF ::oDbf
      FIELD CALCULATE NAME "cHorSalF"  LEN   8  DEC 0  COMMENT "Hora salida"   VAL ( Trans( ::oDbf:cHorSal, "@R 99:99:99" ) )  COLSIZE 80    OF ::oDbf

      INDEX TO "ASISTENCIA.CDX" TAG "dFecEnt" ON "Dtoc( dFecEnt )" COMMENT "Fecha entrada" NODELETED OF ::oDbf
      INDEX TO "ASISTENCIA.CDX" TAG "dFecSal" ON "Dtoc( dFecSal )" COMMENT "Fecha salida" NODELETED OF ::oDbf
      INDEX TO "ASISTENCIA.CDX" TAG "cCodUsr" ON "cCodUsr" COMMENT "Usuario" NODELETED OF ::oDbf

   END DATABASE ::oDbf

RETURN ( ::oDbf )

//----------------------------------------------------------------------------//

METHOD New( cPath, oWndParent, oMenuItem ) CLASS TAsistencias

   DEFAULT cPath        := cPatDat()
   DEFAULT oWndParent   := GetWndFrame()
   DEFAULT oMenuItem    := "asistencia"

   if Empty( ::nLevel )
      ::nLevel          := Auth():Level( oMenuItem )
   end if

   /*
   Cerramos todas las ventanas
   */

   if oWndParent != nil
      oWndParent:CloseAll()
   end if

   ::cPath              := cPath
   ::oWndParent         := oWndParent
   ::oDbf               := nil

   ::cHtmlHelp          := "asistencia"

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Create( cPath ) CLASS TAsistencias

   DEFAULT cPath        := cPatDat()

   ::cPath              := cPath
   ::oDbf               := nil

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Activate() CLASS TAsistencias

   if nAnd( ::nLevel, 1 ) == 0
      msgStop( "Acceso no permitido." )
      Return ( Self )
   end if

   /*
   Cerramos todas las ventanas
   */

   if ::oWndParent != nil
      ::oWndParent:CloseAll()
   end if

   if Empty( ::oDbf ) .or. !::oDbf:Used()
      ::lOpenFiles      := ::OpenFiles()
   end if

   /*
   Creamos el Shell
   */

   if ::lOpenFiles

      ::CreateShell( ::nLevel )

      ::oWndBrw:EndButtons( Self )

      if ::cHtmlHelp != nil
         ::oWndBrw:cHtmlHelp  := ::cHtmlHelp
      end if

      ::oWndBrw:Activate( nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, {|| ::CloseFiles() } )

   end if

RETURN ( Self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS AsistenciasModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getDatosTableName( "asistencia" )

   METHOD RegEntrada()

   METHOD RegSalida()

END CLASS

//---------------------------------------------------------------------------//

METHOD RegEntrada()

   local cAreaCount
   local cSqlCount

   cSqlCount         := "INSERT INTO " + ::getTableName() 
   cSqlCount         += " ( uuid, cCodUsr, dFecEnt, cHorEnt ) VALUES "

   cSqlCount         += " ( " + quoted( win_uuidcreatestring() )
   cSqlCount         += ", " + quoted( Auth():Codigo() )
   cSqlCount         += ", " + quoted( dToc( GetSysDate() ) )
   cSqlCount         += ", " + quoted( GetSysTime() ) + " )"

   ::ExecuteSqlStatement( cSqlCount, @cAreaCount )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD RegSalida()

   local cAreaCount  := "RegSal2"
   local cSqlCount
   local cStm        := "RegSal1"
   local cSql
   local uuid        := ""

   cSQL              := "SELECT * FROM " + ::getTableName()
   cSQL              += " WHERE cCodUsr = " + quoted( Auth():Codigo() )
   cSQL              += " AND cHorSal = ''"
   cSQL              += " ORDER BY dFecEnt DESC"

   if ::ExecuteSqlStatement( cSql, @cStm )
      uuid           := ( cStm )->uuid
   end if

   if !Empty( uuid )

      cSqlCount      := "UPDATE " + ::getTableName()
      cSqlCount      += " SET dFecSal = " + quoted( dToc( GetSysDate() ) )
      cSqlCount      += ", cHorSal = " + quoted( GetSysTime() )
      cSqlCount      += " WHERE uuid = " + quoted( uuid )
      cSqlCount      += " AND cCodUsr = " + quoted( Auth():Codigo() )

      ::ExecuteSqlStatement( cSqlCount, @cAreaCount )

   end if

RETURN ( Self )

//---------------------------------------------------------------------------//