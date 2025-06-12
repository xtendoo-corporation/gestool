#include "FiveWin.Ch"
#include "Factu.ch"
#include "MesDbf.ch"

static oWndBrw
static bEdit      := { |aTmp, aGet, dbfSitua, oBrw, bWhen, bValid, nMode | EdtRec( aTmp, aGet, dbfSitua, oBrw, bWhen, bValid, nMode ) }
static dbfSitua

//---------------------------------------------------------------------------//

STATIC FUNCTION OpenFiles()

   local lOpen    := .t.
   local oBlock   := ErrorBlock( {| oError | ApoloBreak( oError ) } )

   BEGIN SEQUENCE

      if !lExistTable( cPatDat() + "SITUA.DBF" )
         mkSitua( cPatDat() )
      end if

      USE ( cPatDat() + "SITUA.DBF" ) NEW VIA ( cDriver() ) SHARED ALIAS ( cCheckArea( "SITUA", @dbfSitua ) )
      SET ADSINDEX TO ( cPatDat() + "SITUA.CDX" ) ADDITIVE

   RECOVER

      msgStop( "Imposible abrir todas las bases de datos" )
      CloseFiles ()
      lOpen       := .f.

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( lOpen )

//----------------------------------------------------------------------------//

STATIC FUNCTION CloseFiles()

   if dbfSitua != nil
      ( dbfSitua ) -> ( dbCloseArea() )
   end if

   dbfSitua := nil
   oWndBrw  := nil

RETURN .T.

//----------------------------------------------------------------------------//

FUNCTION Situaciones( oMenuItem, oWnd )

   local nLevel

   DEFAULT  oMenuItem   := "situaciones"
   DEFAULT  oWnd        := oWnd()

   if oWndBrw == NIL

      /*
      Obtenemos el nivel de acceso
      */

      nLevel            := Auth():Level( oMenuItem )

      if nAnd( nLevel, 1 ) == 0
         msgStop( "Acceso no permitido." )
         return nil
      end if

      /*
      Cerramos todas las ventanas
      */

      if oWnd != nil
         SysRefresh(); oWnd:CloseAll(); SysRefresh()
      end if

      /*
      Apertura de ficheros
      */

      if !OpenFiles()
         return Nil
      end if

      /*
      Anotamos el movimiento para el navegador
      */

      AddMnuNext( "Situaciones", ProcName() )

      DEFINE SHELL oWndBrw FROM 2, 10 TO 18, 70 ;
         XBROWSE ;
         TITLE    "Situaciones" ;
         PROMPT   "Situaciones" ;
         MRU      "gc_document_attachment_16";
         ALIAS    ( dbfSitua ) ;
         BITMAP   clrTopArchivos ;
         APPEND   ( WinAppRec( oWndBrw:oBrw, bEdit, dbfSitua ) ) ;
         EDIT     ( WinEdtRec( oWndBrw:oBrw, bEdit, dbfSitua ) ) ;
         DELETE   ( WinDelRec( oWndBrw:oBrw, dbfSitua ) );
         DUPLICAT ( WinDupRec( oWndBrw:oBrw, bEdit, dbfSitua ) ) ;
         LEVEL    nLevel ;
         OF       oWnd

      with object ( oWndBrw:AddXCol() )
         :cHeader          := "Situaciones"
         :cSortOrder       := "cSitua"
         :bEditValue       := {|| ( dbfSitua )->cSitua }
         :nWidth           := 800
         :bLClickHeader    := {| nMRow, nMCol, nFlags, oCol | oWndBrw:ClickOnHeader( oCol ) }
      end with

      oWndBrw:cHtmlHelp    := "Situaciones"

      oWndBrw:CreateXFromCode()

      DEFINE BTNSHELL RESOURCE "BUS" OF oWndBrw ;
         NOBORDER ;
         ACTION   ( oWndBrw:SearchSetFocus() ) ;
         TOOLTIP  "(B)uscar" ;
         HOTKEY   "B"

      oWndBrw:AddSeaBar()

      DEFINE BTNSHELL RESOURCE "NEW" OF oWndBrw ;
         NOBORDER ;
         ACTION   ( oWndBrw:RecAdd() );
         ON DROP  ( oWndBrw:RecDup() );
         TOOLTIP  "(A)�adir";
         BEGIN GROUP;
         HOTKEY   "A";
         LEVEL    ACC_APPD

      DEFINE BTNSHELL RESOURCE "EDIT" OF oWndBrw ;
         NOBORDER ;
         ACTION   ( oWndBrw:RecEdit() );
         TOOLTIP  "(M)odificar";
         MRU ;
         HOTKEY   "M";
         LEVEL    ACC_EDIT

      DEFINE BTNSHELL RESOURCE "ZOOM" OF oWndBrw ;
         NOBORDER ;
         ACTION   ( WinZooRec( oWndBrw:oBrw, bEdit, dbfSitua ) );
         TOOLTIP  "(Z)oom";
         MRU ;
         HOTKEY   "Z";
         LEVEL    ACC_ZOOM

      DEFINE BTNSHELL RESOURCE "DEL" OF oWndBrw ;
         NOBORDER ;
         ACTION   ( oWndBrw:RecDel() );
         TOOLTIP  "(E)liminar";
         MRU ;
         HOTKEY   "E";
         LEVEL    ACC_DELE

      DEFINE BTNSHELL RESOURCE "END" GROUP OF oWndBrw ;
         NOBORDER ;
         ACTION   ( oWndBrw:end() ) ;
         TOOLTIP  "(S)alir" ;
         HOTKEY   "S"

      ACTIVATE WINDOW oWndBrw VALID ( CloseFiles() )

   else

      oWndBrw:SetFocus()

   end if

 RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION EdtRec( aTmp, aGet, dbfSitua, oBrw, bWhen, bValid, nMode )

   local oDlg

   DEFINE DIALOG oDlg RESOURCE "SITUACION" TITLE LblTitle( nMode ) + "situaci�n"

   REDEFINE GET aGet[ ( dbfSitua )->( FieldPos( "cSitua" ) ) ] ;
      VAR      aTmp[ ( dbfSitua )->( FieldPos( "cSitua" ) ) ] ;
      ID       100 ;
      WHEN     ( nMode != ZOOM_MODE ) ;
      OF       oDlg

   REDEFINE BUTTON ;
      ID       IDOK ;
      OF       oDlg ;
      WHEN     ( nMode != ZOOM_MODE ) ;
      ACTION   ( EndTrans( aTmp, aGet, dbfSitua, oBrw, nMode, oDlg ) )

   REDEFINE BUTTON ;
      ID       IDCANCEL ;
      OF       oDlg ;
      CANCEL ;
      ACTION   ( oDlg:end() )

   if nMode != ZOOM_MODE
      oDlg:AddFastKey( VK_F5, {|| EndTrans( aTmp, aGet, dbfSitua, oBrw, nMode, oDlg ) } )
   end if

   oDlg:bStart := {|| aGet[ ( dbfSitua )->( FieldPos( "cSitua" ) ) ]:SetFocus() }

   ACTIVATE DIALOG oDlg CENTER

RETURN ( oDlg:nResult == IDOK )

//----------------------------------------------------------------------------//

STATIC FUNCTION EndTrans( aTmp, aGet, dbfSitua, oBrw, nMode, oDlg )

   //Comprobamos que el c�digo no est� vac�o y que no exista

   if nMode == APPD_MODE .or. nMode == DUPL_MODE
      if Existe( Upper( aTmp[ ( dbfSitua )->( FieldPos( "cSitua" ) ) ] ), dbfSitua, "cSitua" )
         msgStop( "Situaci�n existente" )
         aGet[ ( dbfSitua )->( FieldPos( "cSitua" ) ) ]:SetFocus()
         return nil
      end if
   end if

   if Empty( aTmp[ ( dbfSitua )->( FieldPos( "cSitua" ) ) ] )
      MsgStop( "La situaci�n no puede estar vac�a" )
      aGet[ ( dbfSitua )->( FieldPos( "cSitua" ) ) ]:SetFocus()
      return nil
   end if

   //Escribimos definitivamente la temporal a la base de datos

   WinGather( aTmp, aGet, dbfSitua, oBrw, nMode )

RETURN ( oDlg:end( IDOK ) )

//---------------------------------------------------------------------------//

Function aSituacion( dbfSitua )

   local oError
   local oBlock
   local aSitua   := {}

   oBlock         := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      aAdd( aSitua, "" )

      ( dbfSitua )->( dbGoTop() )
      while !( dbfSitua )->( Eof() )
         aAdd( aSitua, ( dbfSitua )->cSitua )
         ( dbfSitua )->( dbSkip() )
      end while

   RECOVER USING oError

      msgStop( "Imposible cargar situaciones" + CRLF + ErrorMessage( oError )  )

   END SEQUENCE

   ErrorBlock( oBlock )

Return aSitua

//---------------------------------------------------------------------------//

FUNCTION mkSitua( cPath, lAppend, cPathOld )

   local dbfSitua

   DEFAULT cPath     := cPatDat()
   DEFAULT lAppend   := .f.

   if !lExistTable( cPatDat() + "Situa.Dbf" )
      dbCreate( cPatDat() + "Situa.Dbf", { { "cSitua", "C", 30, 0 } }, cDriver() )
   end if

   if lExistIndex( cPatDat() + "Situa.Cdx" )
      fErase( cPatDat() + "Situa.Cdx" )
   end if

   if !lExistTable( cPath + "Situa.Dbf" )
      dbCreate( cPath + "Situa.Dbf", { { "cSitua", "C", 30, 0 } }, cDriver() )
   end if

   if lExistIndex( cPath + "Situa.Cdx" )
      fErase( cPath + "Situa.Cdx" )
   end if

   if lAppend .and. lExistTable( cPathOld + "Situa.Dbf" )

      dbUseArea( .t., cDriver(), "Situa.Dbf", cCheckArea( "Situa", @dbfSitua ), .f. )
      ( dbfSitua )->( __dbApp( cPathOld + "Situa.Dbf" ) )
      ( dbfSitua )->( dbCloseArea() )

   end if

   rxSitua( cPath )

RETURN .t.

//----------------------------------------------------------------------------//

FUNCTION rxSitua( cPath, oMeter )

   local dbfSitua

   DEFAULT cPath := cPatDat()

   IF !lExistTable( cPath + "SITUA.DBF" )
      dbCreate( cPath + "Situa.Dbf", { { "cSitua", "C", 30, 0 } }, cDriver() )
   END IF

   IF lExistIndex( cPath + "SITUA.CDX" )
      fErase( cPath + "SITUA.CDX" )
   END IF

   if lExistTable( cPath + "SITUA.DBF" )
      dbUseArea( .t., cDriver(), cPath + "SITUA.DBF", cCheckArea( "SITUA", @dbfSitua ), .f. )

      if !( dbfSitua )->( neterr() )
         ( dbfSitua )->( __dbPack() )

         ( dbfSitua )->( ordCondSet("!Deleted()", {||!Deleted()}  ) )
         ( dbfSitua )->( ordCreate( cPath + "SITUA.CDX", "CSITUA", "Upper( Field->cSitua )", {|| Upper( Field->cSitua ) } ) )

         ( dbfSitua )->( dbCloseArea() )
      else

         msgStop( "Imposible abrir en modo exclusivo situaciones" )

      end if

   end if

RETURN NIL

//----------------------------------------------------------------------------//

FUNCTION IsSitua()

   local oError
   local oBlock   := ErrorBlock( {| oError | ApoloBreak( oError ) } )

   BEGIN SEQUENCE

   if !lExistTable( cPatDat() + "SITUA.DBF" )
      mkSitua( cPatDat() )
   end if

   if !lExistIndex( cPatDat() + "SITUA.CDX" )
      rxSitua( cPatDat() )
   end if

   RECOVER USING oError

      msgStop( "Imposible realizar las comprobaci�n inicial de situaciones" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

 RETURN ( .t. )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS SituacionesModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getDatosTableName( "Situa" )

   METHOD getArrayNombres()

END CLASS

//---------------------------------------------------------------------------//

METHOD getArrayNombres() CLASS SituacionesModel

   local cStm           := "getSituaciones"
   local cSql           := ""
   local aSituaciones   := {}

   cSql                 := "SELECT cSitua FROM " + ::getTableName()

   if ::ExecuteSqlStatement( cSql, @cStm )
      
      if ( ( cStm )->( ordKeyCount() ) > 0 )

         ( cStm )->( dbGoTop() )

         while !( cStm )->( Eof() )

            aAdd( aSituaciones, ( cStm )->cSitua )

            ( cStm )->( dbSkip() )

         end if

      end if

   end if

Return ( aSituaciones )

//---------------------------------------------------------------------------//