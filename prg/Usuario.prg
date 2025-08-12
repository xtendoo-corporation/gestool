#include "FiveWin.Ch"
#include "Font.ch"
#include "Report.ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//----------------------------------------------------------------------------//

CLASS TUsuarios FROM TMant

   DATA cMru           INIT "gc_businesspeople_16"
   DATA cBitmap        INIT  clrTopHerramientas

   DATA nView

   DATA oGetCodigo
   DATA oGetNombre

   DATA oGetUser
   DATA cGetUser
   DATA aGetUser

   DATA oGetPassword
   DATA cGetPassword
   DATA oGetRepeatPassword
   DATA cGetRepeatPassword

   DATA oComboRoles
   DATA cComboRoles
   DATA aComboRoles

   DATA oDialog

   DATA oListView
   DATA oImageList

   DATA oCodEmp
   DATA cCodEmp
   DATA oCodDlg
   DATA cCodDlg
   DATA oCodCaj
   DATA cCodCaj
   DATA oCodAlm
   DATA cCodAlm
   DATA oCodAge
   DATA cCodAge
   DATA oCodRut
   DATA cCodRut
   DATA oImpDef
   DATA cImpDef

   METHOD DefineFiles()
   
   METHOD New( cPath, oWndParent, oMenuItem )
   METHOD Create( cPath )

   METHOD Activate()

   METHOD OpenFiles( lExclusive )
   METHOD CloseFiles()

   METHOD Resource( nMode )

   METHOD lPreSave()

   METHOD isLogin()
      METHOD initRecourceLogin()
      METHOD resourceLogin()
      METHOD ValidateLogin( oDlg )

   METHOD isLoginTCT()           INLINE ( ::ResourceTCT() == IDOK )
      METHOD ResourceTCT()
      METHOD startResourceTct()
      METHOD initResourceTct()
      METHOD ValidateTCT( nOpt )

   METHOD Config()
   METHOD SaveConfig()

END CLASS

//----------------------------------------------------------------------------//

METHOD DefineFiles( cPath, cDriver ) CLASS TUsuarios

   DEFAULT cPath        := ::cPath
   DEFAULT cDriver      := cDriver()

   DEFINE DATABASE ::oDbf FILE "USUARIOS.DBF" CLASS "USUARIOS" PATH ( cPath ) VIA ( cDriver ) COMMENT "Usuarios"
      
      FIELD CALCULATE NAME "bstate"    LEN  14  DEC 0  COMMENT "Estado"                      VAL {|| if( isUserActive( ::oDbf:uuid ), "En uso", "" ) } COLSIZE 100 OF ::oDbf
      FIELD CALCULATE NAME "bInacUse"  LEN  14  DEC 0  COMMENT "Inactivo"                    VAL {|| if( ::oDbf:lInacUse, "Inactivo", "" ) } COLSIZE 100 OF ::oDbf
      FIELD NAME "uuid"       TYPE "C" LEN  40  DEC 0  COMMENT "Identificador"               HIDE           DEFAULT win_uuidcreatestring()   OF ::oDbf
      FIELD NAME "codigo"     TYPE "C" LEN   3  DEC 0  COMMENT "Código"                      COLSIZE  50                                     OF ::oDbf
      FIELD NAME "nombre"     TYPE "C" LEN 100  DEC 0  COMMENT "Nombre"                      COLSIZE 250                                     OF ::oDbf
      FIELD NAME "email"      TYPE "C" LEN 100  DEC 0  COMMENT "Email"                       COLSIZE 250                                     OF ::oDbf
      FIELD NAME "password"   TYPE "C" LEN 100  DEC 0  COMMENT "Password"                    HIDE                                            OF ::oDbf
      FIELD NAME "lsuper"     TYPE "L" LEN   1  DEC 0  COMMENT "Lógico super usuario"        HIDE                                            OF ::oDbf
      FIELD NAME "roluuid"    TYPE "C" LEN  40  DEC 0  COMMENT "Uuid rol"                    HIDE                                            OF ::oDbf
      FIELD NAME "lastpc"     TYPE "C" LEN 100  DEC 0  COMMENT "Última pc"                   HIDE                                            OF ::oDbf
      FIELD NAME "lastemp"    TYPE "C" LEN   4  DEC 0  COMMENT "Última empresa"              HIDE                                            OF ::oDbf
      FIELD NAME "cEmpExc"    TYPE "C" LEN   4  DEC 0  COMMENT "Empresa exclusiva"           HIDE                                            OF ::oDbf
      FIELD NAME "cDlgExc"    TYPE "C" LEN   2  DEC 0  COMMENT "Delegaión exclusiva"         HIDE                                            OF ::oDbf
      FIELD NAME "cCajExc"    TYPE "C" LEN   3  DEC 0  COMMENT "Caja exclusiva"              HIDE                                            OF ::oDbf
      FIELD NAME "cAlmExc"    TYPE "C" LEN  16  DEC 0  COMMENT "Almacén exclusivo"           HIDE                                            OF ::oDbf
      FIELD NAME "cAgeExc"    TYPE "C" LEN   3  DEC 0  COMMENT "Agente exclusivo"            HIDE                                            OF ::oDbf
      FIELD NAME "cRutExc"    TYPE "C" LEN   4  DEC 0  COMMENT "Ruta exclusivo"              HIDE                                            OF ::oDbf
      FIELD NAME "cImpDef"    TYPE "C" LEN 200  DEC 0  COMMENT "Impresora por defecto"       HIDE                                            OF ::oDbf
      FIELD NAME "lInacUse"   TYPE "L" LEN   1  DEC 0  COMMENT "Usuario inactivo"            HIDE                                            OF ::oDbf

      INDEX TO "USUARIOS.CDX" TAG "Código" ON "codigo" COMMENT "Código" NODELETED OF ::oDbf
      INDEX TO "USUARIOS.CDX" TAG "Nombre" ON "nombre" COMMENT "Nombre" NODELETED OF ::oDbf
      INDEX TO "USUARIOS.CDX" TAG "Email"  ON "email"  COMMENT "Email"  NODELETED OF ::oDbf

   END DATABASE ::oDbf

RETURN ( ::oDbf )

//----------------------------------------------------------------------------//

METHOD New( cPath, oWndParent, oMenuItem ) CLASS TUsuarios

   DEFAULT cPath        := cPatEmp()
   DEFAULT oWndParent   := GetWndFrame()
   DEFAULT oMenuItem    := "usuarios"

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
   ::lReport            := .f.

   ::aComboRoles        := RolesModel():getNameList()

   ::cHtmlHelp          := "Usuarios"

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Create( cPath ) CLASS TUsuarios

   DEFAULT cPath        := cPatEmp()

   ::cPath              := cPath
   ::oDbf               := nil

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD OpenFiles( lExclusive, cPath ) CLASS TUsuarios

   local lOpen          := .t.
   local oError
   local oBlock         

   DEFAULT lExclusive   := .f.
   DEFAULT cPath        := cPatDat()

   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      ::nView           := D():CreateView()

      if Empty( ::oDbf )
         ::oDbf         := ::DefineFiles( cPath )
      end if

      ::oDbf:Activate( .f., !( lExclusive ) )

   RECOVER USING oError

      lOpen             := .f.

      ::CloseFiles()

      msgStop( ErrorMessage( oError ), "Imposible abrir las bases de datos de usuarios" )

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( lOpen )

//---------------------------------------------------------------------------//

METHOD CloseFiles() CLASS TUsuarios

   if ::oDbf != nil .and. ::oDbf:Used()
      ::oDbf:End()
   end if

   D():DeleteView( ::nView )

   ::oDbf               := nil
   ::nView              := nil

RETURN .t.

//---------------------------------------------------------------------------//

METHOD Activate() CLASS TUsuarios

   if !Auth():isSuperAdmin()
      MsgStop( "Solo puede acceder el ususario Super administrador" )
      Return ( Self )
   end if

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

      ::oWndBrw:bDup    := nil
      ::oWndBrw:GralButtons( Self )
         
      DEFINE BTNSHELL RESOURCE "CNFCLI" GROUP OF ::oWndBrw ;
         NOBORDER ;
         ACTION   ( ::Config() ) ;
         TOOLTIP  "Confi(g)uración" ;
         HOTKEY   "G" ;
         LEVEL    ACC_EDIT

      ::oWndBrw:EndButtons( Self )

      if ::cHtmlHelp != nil
         ::oWndBrw:cHtmlHelp  := ::cHtmlHelp
      end if

      ::oWndBrw:Activate( nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, {|| ::CloseFiles() } )

   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Resource( nMode ) CLASS TUsuarios

   local oDlg
   local oBmp

   ::cGetPassword          := Space( 100 )
   ::cGetRepeatPassword    := Space( 100 )

   ::cComboRoles           := RolesModel():getNombre( ::oDbf:roluuid )

   DEFINE DIALOG oDlg RESOURCE "USUARIO" TITLE LblTitle( nMode ) + " usuario"

      REDEFINE BITMAP oBmp ;
         ID          900 ;
         RESOURCE    "gc_businesspeople_48" ;
         TRANSPARENT ;
         OF          oDlg

      REDEFINE GET   ::oGetCodigo VAR ::oDbf:codigo ;
         ID          100 ;
         WHEN        ( nMode == APPD_MODE .or. nMode == DUPL_MODE ) ;
         OF          oDlg

      REDEFINE GET   ::oGetNombre VAR ::oDbf:nombre ;
         ID          110 ;
         WHEN        ( nMode != ZOOM_MODE ) ;
         OF          oDlg

      REDEFINE GET   ::oDbf:email ;
         ID          120 ;
         WHEN        ( nMode != ZOOM_MODE ) ;
         OF          oDlg

      REDEFINE GET   ::oGetPassword ;
         VAR         ::cGetPassword ;
         ID          130 ;
         WHEN        ( nMode != ZOOM_MODE ) ;
         OF          oDlg

      REDEFINE GET   ::oGetRepeatPassword ;
         VAR         ::cGetRepeatPassword ;
         ID          131 ;
         WHEN        ( nMode != ZOOM_MODE ) ;
         OF          oDlg

      REDEFINE COMBOBOX ::oComboRoles ;
         VAR         ::cComboRoles ;
         ID          140 ;
         ITEMS       ::aComboRoles ;
         WHEN        ( nMode != ZOOM_MODE ) ;
         OF          oDlg

      REDEFINE CHECKBOX ::oDbf:lInacUse ;
         ID          150 ;
         WHEN        ( !::oDbf:lsuper ) ;
         OF          oDlg

      REDEFINE BUTTON ;
         ID          IDOK ;
         OF          oDlg ;
         WHEN        ( nMode != ZOOM_MODE ) ;
         ACTION      ( if( ::lPreSave( nMode ), oDlg:end( IDOK ), ) )

      REDEFINE BUTTON ;
         ID          IDCANCEL ;
         OF          oDlg ;
         CANCEL ;
         ACTION      ( oDlg:end() )

      if nMode != ZOOM_MODE
         oDlg:AddFastKey( VK_F5, {|| if( ::lPreSave( nMode ), oDlg:end( IDOK ), ) } )
      end if

      oDlg:bStart    := {|| ::oGetCodigo:SetFocus() }

   ACTIVATE DIALOG oDlg CENTER

   if !Empty( oBmp )
      oBmp:end()
   end if
   
RETURN ( oDlg:nResult == IDOK )

//----------------------------------------------------------------------------//

METHOD lPreSave( nMode ) CLASS TUsuarios

   if Empty( ::oDbf:codigo )
      MsgStop( "El campo codigo es obligatorio" )
      ::oGetCodigo:SetFocus()
      Return .f.
   end if

   if nMode == APPD_MODE .and. UsuariosModel():existe( ::oDbf:codigo )
      MsgStop( "Código ya existente" )
      ::oGetCodigo:SetFocus()
      Return .f.
   end if

   if Empty( ::oDbf:nombre )
      MsgStop( "El campo nombre es obligatorio" )
      ::oGetNombre:SetFocus()
      Return .f.
   end if

   if !Empty( ::oGetPassword:VarGet() )

      if Len( AllTrim( ::oGetPassword:VarGet() ) ) < 8 .or. Len( AllTrim( ::oGetPassword:VarGet() ) ) > 18
         MsgStop( "- Contraseña debe de tener al menos ocho caracteres y un máximo de dieciocho" + CRLF + ;
                  "- No puede contener espacios" )
         ::oGetPassword:SetFocus()
         Return .f.
      end if
      
      if AllTrim( ::oGetPassword:VarGet() ) != AllTrim( ::oGetRepeatPassword:VarGet() )
         MsgStop( "Las contraseñas no coinciden" )
         ::oGetPassword:SetFocus()
         Return .f.
      end if

      ::oDbf:password   := UsuariosModel():Crypt( AllTrim( ::oGetPassword:VarGet() ) )

   end if

   if nMode == APPD_MODE
      ::oDbf:uuid       := win_uuidcreatestring()
   end if

   if Empty( ::oComboRoles:VarGet() )
      ::oDbf:roluuid    := ""
   else
      ::oDbf:roluuid    := RolesModel():getuuid( ::oComboRoles:VarGet() )
   end if

RETURN ( .t. )

//----------------------------------------------------------------------------//

METHOD isLogin() CLASS TUsuarios

   UsuariosModel():checkSuperUser()

   if ( ::resourceLogin() != IDOK )
      RETURN ( .f. )
   end if 

   UsuariosModel():setUsuarioPcEnUso( Alltrim( netname() ) + AllTrim( WNetGetUser() ), Auth():uuid() )

   AsistenciasModel():RegEntrada()

RETURN ( .t. )

//----------------------------------------------------------------------------//

METHOD initRecourceLogin() CLASS TUsuarios

   if Upper( GetPvProfString(  "main",    "SeleccionUltimoUsuario", ".T.",     cIniAplication() ) ) == ".T."
      ::cGetUser              := Padr( UsuariosModel():getNombreUsuarioWhereNetName( Alltrim( netname() ) + AllTrim( WNetGetUser() ) ), 100 )
   else
      ::cGetUser              := space( 100 )
   end if

   ::cGetPassword             := space( 100 )

   ::aGetUser                 := UsuariosModel():getNamesUsuarios()

RETURN ( .t. )

//----------------------------------------------------------------------------//

METHOD resourceLogin() CLASS TUsuarios

   local oBitmap

   ::initRecourceLogin()   

   DEFINE DIALOG  ::oDialog ;
      RESOURCE    "LOGINADS" 

   REDEFINE BITMAP oBitmap ;
      ID          900 ;
      RESOURCE    "gestool_logo" ;
      TRANSPARENT ;
      OF          ::oDialog

   REDEFINE COMBOBOX ::oGetUser ;
      VAR         ::cGetUser ;
      ITEMS       ::aGetUser ;
      ID          100 ;
      OF          ::oDialog

   REDEFINE GET   ::oGetPassword ;
      VAR         ::cGetPassword ;
      ID          110 ;
      OF          ::oDialog

   REDEFINE BUTTON ;
      ID          IDOK ;
      OF          ::oDialog ;
      ACTION      ( ::ValidateLogin() )

   ::oDialog:AddFastKey( VK_F5, {|| ::ValidateLogin() } )

   ::oDialog:Activate( , , , .t. )

   if !Empty( oBitmap )
      oBitmap:end()
   end if 

RETURN ( ::oDialog:nResult )

//---------------------------------------------------------------------------//

METHOD ValidateLogin() CLASS TUsuarios

   local hUsuario

   if Empty( AllTrim( ::cGetUser ) )
      MsgStop( "Nombre de usuario no puede estar vacío." )
      ::oGetUser:SetFocus()
      RETURN ( nil )
   end if

   if !UsuariosModel():validNameUser( ::cGetUser )
      MsgStop( "El usuario introducido no existe." )
      ::oGetUser:SetFocus()
      RETURN ( nil )
   end if

   hUsuario    := UsuariosModel():validUserPassword( ::cGetUser, ::cGetPassword )

   if Empty( hUsuario )
      MsgStop( "Contraseña erronea" )
      ::oGetPassword:SetFocus()
      RETURN ( nil )
   end if

   if setUserActive( hget( hUsuario, "UUID" ) )
      MsgStop( "Usuario actualmente en uso" )
      RETURN ( nil )
   end if

   Auth( hUsuario )

RETURN ( ::oDialog:end( IDOK )  )

//---------------------------------------------------------------------------//

METHOD ResourceTCT() CLASS TUsuarios

   local oBitmap

   ::oImageList   := TImageList():New( 50, 50 ) 

   ::oImageList:AddMasked( TBitmap():Define( "gc_businessman2_50" ),   Rgb( 255, 0, 255 ) )
   ::oImageList:AddMasked( TBitmap():Define( "gc_user2_50" ),          Rgb( 255, 0, 255 ) )

   DEFINE DIALOG  ::oDialog ;
      RESOURCE    "LOGIN_TACTIL_ADS" 

   REDEFINE BITMAP oBitmap ;
      ID          900 ;
      RESOURCE    "gestool_logo" ;
      TRANSPARENT ;
      OF          ::oDialog

   ::oListView          := TListView():Redefine( 100, ::oDialog )
   ::oListView:nOption  := 0
   ::oListView:bClick   := {| nOpt | ::ValidateTCT( nOpt ) }

   REDEFINE BUTTON ;
      ID          IDCANCEL ;
      OF          ::oDialog ;
      ACTION      ( ::oDialog:End( IDCANCEL ) )

   ::oDialog:bStart := {|| ::startResourceTct() }

   ::oDialog:Activate( , , , .t., , , {|| ::initResourceTct() } )

   if !Empty( oBitmap )
      oBitmap:end()
   end if

RETURN ( ::oDialog:nResult )

//----------------------------------------------------------------------------//

METHOD startResourceTct() CLASS TUsuarios

   local oStatement

   oStatement  := UsuariosModel():fetchDirect()
   
   if !empty( oStatement )

      while !( oStatement )->( Eof() )

         if !isUserActive( ( oStatement )->uuid )
   
            with object ( TListViewItem():New() )
               :Cargo   := ( oStatement )->nombre
               :cText   := Capitalize( ( oStatement )->nombre )
               :nImage  := 0
               :nGroup  := 1
               :Create( ::oListView )
            end with

         end if

         ( oStatement )->( dbSkip() )
   
      end while
   
   end if 

   ::oListView:Refresh()

Return ( nil )

//----------------------------------------------------------------------------//

METHOD initResourceTct() CLASS TUsuarios

   ::oListView:SetImageList( ::oImageList )
   ::oListView:EnableGroupView()
   ::oListView:SetIconSpacing( 120, 140 )

   with object ( TListViewGroup():New() )
      :cHeader := "Usuarios"
      :Create( ::oListView )
   end with

RETURN ( nil )

//----------------------------------------------------------------------------//

METHOD ValidateTCT( nOpt ) CLASS TUsuarios 

   local cUsuario    
   local cPassword   
   local hUsuario

   if empty( ::oListView )
      RETURN ( nil )
   end if 

   if empty( ::oListView:getItem( nOpt ) )
      RETURN ( nil )
   end if 

   cUsuario          := ::oListView:GetItem( nOpt ):Cargo
   
   cPassword         := VirtualKey( .t., , "Introduzca contraseña" )

   hUsuario          := UsuariosModel():validUserPassword( cUsuario, cPassword )

   if Empty( hUsuario )

      ApoloMsgStop( "Contraseña erronea" )

   else

      if setUserActive( hget( hUsuario, "UUID" ) )
         ApoloMsgStop( "Usuario actualmente en uso" )
      else
         Auth( hUsuario )
         ::oDialog:End( IDOK )
      end if   

   end if

RETURN ( nil )

//---------------------------------------------------------------------------//

METHOD Config() CLASS TUsuarios

   local oDlg
   local oBmp

   ::cCodEmp      := ::oDbf:cEmpExc
   ::cCodDlg      := ::oDbf:cDlgExc
   ::cCodCaj      := ::oDbf:cCajExc
   ::cCodAlm      := ::oDbf:cAlmExc
   ::cCodAge      := ::oDbf:cAgeExc
   ::cCodRut      := ::oDbf:cRutExc
   ::cImpDef      := ::oDbf:cImpDef

   DEFINE DIALOG oDlg RESOURCE "CFG_USER" TITLE "Configuraciones"

      REDEFINE BITMAP oBmp ;
         ID          500 ;
         RESOURCE    "gc_wrench_48" ;
         TRANSPARENT ;
         OF          oDlg

      REDEFINE GET ::oCodEmp VAR ::cCodEmp ;
         ID          110 ;
         IDTEXT      111 ;
         BITMAP      "LUPA" ;
         OF          oDlg

         ::oCodEmp:bValid     := {|| cEmpresa( ::oCodEmp, D():Empresa( ::nView ), ::oCodEmp:oHelpText ) }
         ::oCodEmp:bHelp      := {|| BrwEmpresa( ::oCodEmp, D():Empresa( ::nView ), ::oCodEmp:oHelpText ) }

      REDEFINE GET ::oCodDlg VAR ::cCodDlg;
         ID          120 ;
         IDTEXT      121 ;
         BITMAP      "LUPA" ;
         WHEN        ( !Empty( ::oCodEmp:VarGet() ) ) ;
         OF          oDlg

         ::oCodDlg:bValid     := {|| cDelegacion( ::oCodDlg, D():Delegaciones( ::nView ), ::oCodDlg:oHelpText, AllTrim( ::oCodEmp:VarGet() ) ) }
         ::oCodDlg:bHelp      := {|| BrwDelegacion( ::oCodDlg, D():Delegaciones( ::nView ), ::oCodDlg:oHelpText, AllTrim( ::oCodEmp:VarGet() ) ) }

      REDEFINE GET ::oCodCaj VAR ::cCodCaj;
         ID          130 ;
         IDTEXT      131 ;
         BITMAP      "LUPA" ;
         OF          oDlg

         ::oCodCaj:bValid     := {|| cCajas( ::oCodCaj, ,::oCodCaj:oHelpText ) }
         ::oCodCaj:bHelp      := {|| BrwCajas( ::oCodCaj, ::oCodCaj:oHelpText ) }

      REDEFINE GET ::oCodAlm VAR ::cCodAlm;
         ID          140 ;
         IDTEXT      141 ;
         BITMAP      "LUPA" ;
         OF          oDlg

         ::oCodAlm:bValid     := {|| cAlmacen( ::oCodAlm, ,::oCodAlm:oHelpText ) }
         ::oCodAlm:bHelp      := {|| BrwAlmacen( ::oCodAlm, ::oCodAlm:oHelpText ) }

      REDEFINE GET ::oCodAge VAR ::cCodAge;
         ID          150 ;
         IDTEXT      151 ;
         BITMAP      "LUPA" ;
         OF          oDlg

         ::oCodAge:bValid     := {|| cAgentes( ::oCodAge, , ::oCodAge:oHelpText ) }
         ::oCodAge:bHelp      := {|| BrwAgentes( ::oCodAge, ::oCodAge:oHelpText ) }

      REDEFINE GET ::oCodRut VAR ::cCodRut;
         ID          160 ;
         IDTEXT      161 ;
         BITMAP      "LUPA" ;
         OF          oDlg

         ::oCodRut:bValid     := {|| cRuta( ::oCodRut, ,::oCodRut:oHelpText ) }
         ::oCodRut:bHelp      := {|| BrwRuta( ::oCodRut, , ::oCodRut:oHelpText ) }

      REDEFINE GET ::oImpDef VAR ::cImpDef;
         ID          170 ;
         OF          oDlg

      TBtnBmp():ReDefine( 171, "gc_printer2_check_16",,,,,{|| PrinterPreferences( ::oImpDef ) }, oDlg, .f., , .f.,  )

      REDEFINE BUTTON ;
         ID          IDOK ;
         OF          oDlg ;
         ACTION      ( ::SaveConfig(), oDlg:end( IDOK ) )

      REDEFINE BUTTON ;
         ID          IDCANCEL ; 
         OF          oDlg ;
         CANCEL ;
         ACTION      ( oDlg:end() )

      oDlg:AddFastKey( VK_F5, {|| ::SaveConfig(), oDlg:end( IDOK ) } )

      oDlg:bStart := {|| ::oCodEmp:lValid(), ::oCodDlg:lValid(), ::oCodCaj:lValid(), ::oCodAlm:lValid(), ::oCodAge:lValid(), ::oCodRut:lValid() }

   ACTIVATE DIALOG oDlg CENTER

   if !Empty( oBmp )
      oBmp:end()
   end if

RETURN ( oDlg:nResult == IDOK )

//----------------------------------------------------------------------------//

METHOD SaveConfig() CLASS TUsuarios

   UsuariosModel():updateConfig( ::oDbf:uuid,;
                                 ::oCodEmp:VarGet() ,;
                                 ::oCodDlg:VarGet() ,;                              
                                 ::oCodCaj:VarGet() ,;
                                 ::oCodAlm:VarGet() ,;
                                 ::oCodAge:VarGet() ,;
                                 ::oCodRut:VarGet() ,;
                                 ::oImpDef:VarGet() )

RETURN ( nil )

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

Function CryptUsersPasswords()

   local oUser    := TUsuarios():New( cPatDat() )

   if !Empty( oUser )

      if oUser:OpenFiles()

         oUser:oDbf:GoTop()

         while !oUser:oDbf:Eof()

            oUser:oDbf:Load()
            oUser:oDbf:password  := UsuariosModel():Crypt( oUser:oDbf:password )
            oUser:oDbf:Save()

            oUser:oDbf:Skip()

         end while

         oUser:CloseFiles()

      end if

      oUser:end()

   end if

RETURN ( nil )

//----------------------------------------------------------------------------//

Function lGetUsuario( oGetUsuario, dbfUsr )

   local oDlg
   local oSayUsuario
   local oBmpUsuario
   local oCodigoUsuario
   local cCodigoUsuario := Space( 3 )
   local oUser          := TUsuarios():New( cPatDat() )

   if !lRecogerUsuario()
      Return .t.
   end if

   oUser:OpenFiles()

   DEFINE DIALOG oDlg RESOURCE "GetUsuario"

      REDEFINE BITMAP oBmpUsuario ;
         ID       500 ;
         RESOURCE "gc_businessman_48" ;
         TRANSPARENT ;
         OF       oDlg

      REDEFINE SAY oSayUsuario ;
         VAR      "Usuario" ;
         ID       510 ;
         OF       oDlg

      REDEFINE GET oCodigoUsuario VAR cCodigoUsuario ;
         ID       100 ;
         IDTEXT   110 ;
         VALID    ( oUser:Existe( oCodigoUsuario, oCodigoUsuario:oHelpText, "Nombre" ) ) ;
         BITMAP   "LUPA" ;
         ON HELP  ( oUser:Buscar( oCodigoUsuario, "codigo" ) ) ;
         OF       oDlg

      REDEFINE BUTTON ;
         ID       IDOK ;
         OF       oDlg ;
         ACTION   ( oDlg:end( IDOK ) )

      REDEFINE BUTTON ;
         ID       IDCANCEL ;
         OF       oDlg ;
         CANCEL ;
         ACTION   ( oDlg:end() )

      oDlg:bStart       := { || oCodigoUsuario:SetFocus(), oCodigoUsuario:SelectAll() }

   ACTIVATE DIALOG oDlg CENTER

   oBmpUsuario:End()

   if oDlg:nResult == IDOK

      if !Empty( oGetUsuario )
         oGetUsuario:cText( cCodigoUsuario )
         oGetUsuario:lValid()
      end if

   end if

   oUser:CloseFiles()
   oUser:end()

Return ( oDlg:nResult == IDOK )

//---------------------------------------------------------------------------//

Function ImpresoraDefectoUsuario()

   local cImpresora  := UsuariosModel():getUsuarioImpresoraDefecto( Auth():uuid )

   if Empty( cImpresora )
      cImpresora     := PrnGetName()
   end if

Return ( AllTrim( cImpresora ) )

//---------------------------------------------------------------------------//