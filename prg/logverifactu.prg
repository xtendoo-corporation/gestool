#include "FiveWin.Ch"
#include "Font.ch"
#include "Report.ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//----------------------------------------------------------------------------//

CLASS TLogVerifactu FROM TMant

   DATA cMru           INIT "GC_VERYFACTU_16"
   DATA cBitmap        INIT  clrTopHerramientas

   DATA nView

   METHOD DefineFiles()
   
   METHOD New( cPath, oWndParent, oMenuItem )
   METHOD Create( cPath )

   METHOD Activate()

END CLASS

//----------------------------------------------------------------------------//

METHOD DefineFiles( cPath, cDriver ) CLASS TLogVerifactu

   DEFAULT cPath        := ::cPath
   DEFAULT cDriver      := cDriver()

   DEFINE DATABASE ::oDbf FILE "LOGVERI.DBF" CLASS "LOGVERI" PATH ( cPath ) VIA ( cDriver ) COMMENT "Log Verifactu"
      
      FIELD NAME "uuid"       TYPE "C" LEN  40  DEC 0  COMMENT "Identificador"               HIDE                                            OF ::oDbf
      FIELD NAME "uuidFac"    TYPE "C" LEN  40  DEC 0  COMMENT "Identificador factura"       COLSIZE  200                             OF ::oDbf
      FIELD NAME "cTipDoc"    TYPE "C" LEN   2  DEC 0  COMMENT "Tipo documento"        COLSIZE  80                                     OF ::oDbf
      FIELD NAME "cCodUsr"    TYPE "C" LEN   3  DEC 0  COMMENT "Código"                      COLSIZE  50                                     OF ::oDbf
      FIELD CALCULATE NAME "cNomUsr"   LEN 100  DEC 0  COMMENT "Usuario"  VAL ( UsuariosModel():getNombre( ::oDbf:cCodUsr ) )  COLSIZE 250   OF ::oDbf
      FIELD NAME "dFecha"    TYPE "D" LEN   8  DEC 0  COMMENT "Fecha"               COLSIZE  80                                     OF ::oDbf
      FIELD NAME "cHora"    TYPE "C" LEN   8  DEC 0  COMMENT "Hora"                HIDE                                            OF ::oDbf
      FIELD CALCULATE NAME "cHoraLog"  LEN   8  DEC 0  COMMENT "Hora"  VAL ( Trans( ::oDbf:cHora, "@R 99:99:99" ) )  COLSIZE 80    OF ::oDbf
      FIELD NAME "cEstado"    TYPE "C" LEN   20  DEC 0  COMMENT "Estado"     COLSIZE  80                                            OF ::oDbf
      FIELD NAME "cCodErr"    TYPE "C" LEN  200  DEC 0  COMMENT "Código error"     COLSIZE  150                                            OF ::oDbf
      FIELD NAME "cDesErr"    TYPE "C" LEN  200  DEC 0  COMMENT "Descripción error"     COLSIZE  150                                            OF ::oDbf
      FIELD NAME "cStCode"    TYPE "C" LEN  200  DEC 0  COMMENT "Codigo estado"     COLSIZE  150                                            OF ::oDbf
      FIELD NAME "cStText"    TYPE "C" LEN  200  DEC 0  COMMENT "Texto estado"     COLSIZE  150                                            OF ::oDbf

      INDEX TO "LOGVERI.CDX" TAG "cTipDoc" ON "cTipDoc" COMMENT "Documento" NODELETED OF ::oDbf
      INDEX TO "LOGVERI.CDX" TAG "cCodUsr" ON "cCodUsr" COMMENT "Usuario" NODELETED OF ::oDbf

   END DATABASE ::oDbf

RETURN ( ::oDbf )

//----------------------------------------------------------------------------//

METHOD New( cPath, oWndParent, oMenuItem ) CLASS TLogVerifactu

   DEFAULT cPath        := cPatEmp()
   DEFAULT oWndParent   := GetWndFrame()
   DEFAULT oMenuItem    := "Log Verifactu"

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

   ::cHtmlHelp          := "Log Verifactu"

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Create( cPath ) CLASS TLogVerifactu

   DEFAULT cPath        := cPatEmp()

   ::cPath              := cPath
   ::oDbf               := nil

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Activate() CLASS TLogVerifactu

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

CLASS LogverifactuModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "LOGVERI" )

   METHOD RegEntrada()

END CLASS

//---------------------------------------------------------------------------//

METHOD RegEntrada( uuidDoc, cTipDoc, cEstado, cCodErr, cDesErr, cStCode, cStText ) CLASS LogverifactuModel

   local cAreaCount
   local cSqlCount

   cSqlCount         := "INSERT INTO " + ::getTableName() 
   cSqlCount         += " ( uuid, uuidFac, cTipDoc, cCodUsr, dFecha, cHora, cEstado, cCodErr, cDesErr, cStCode, cStText ) VALUES "
   cSqlCount         += " ( " + quoted( win_uuidcreatestring() )
   cSqlCount         += ", " + quoted( uuidDoc )
   cSqlCount         += ", " + quoted( cTipDoc )
   cSqlCount         += ", " + quoted( Auth():Codigo() )
   cSqlCount         += ", " + quoted( dToc( GetSysDate() ) )
   cSqlCount         += ", " + quoted( GetSysTime() )
   cSqlCount         += ", " + quoted( cEstado )
   cSqlCount         += ", " + quoted( cCodErr )
   cSqlCount         += ", " + quoted( cDesErr )
   cSqlCount         += ", " + quoted( cStCode )
   cSqlCount         += ", " + quoted( cStText ) + " )"

   ::ExecuteSqlStatement( cSqlCount, @cAreaCount )

RETURN ( Self )

//---------------------------------------------------------------------------//