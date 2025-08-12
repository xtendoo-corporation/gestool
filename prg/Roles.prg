#include "FiveWin.Ch"
#include "Font.ch"
#include "Report.ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//----------------------------------------------------------------------------//

CLASS TRoles FROM TMant

   DATA cMru           INIT "GC_ID_CARDS_16"
   DATA cBitmap        INIT  clrTopHerramientas

   DATA oGetNombre

   DATA aComboPermisos
   DATA oComboPermisos
   DATA cComboPermisos

   DATA oVieRnt 
   DATA lVieRnt 
   DATA oChgPrc 
   DATA lChgPrc 
   DATA oVieCos 
   DATA lVieCos 
   DATA oConfDel
   DATA lConfDel
   DATA oVtaUsr 
   DATA lVtaUsr 
   DATA oOpnCaj 
   DATA lOpnCaj 
   DATA oCobTct 
   DATA lCobTct 
   DATA oFastCob 
   DATA lFastCob 
   DATA oEstAlb 
   DATA lEstAlb 
   DATA oAssGFac
   DATA lAssGFac
   DATA oChgSta 
   DATA lChgSta 
   DATA oChgFld 
   DATA lChgFld 
   DATA oNotCom 
   DATA lNotCom 

   METHOD DefineFiles()

   METHOD New( cPath, oWndParent, oMenuItem )
   METHOD Create( cPath )

   METHOD Activate()

   METHOD Resource( nMode )

   METHOD lPresave()

   METHOD Config()
   METHOD SaveConfig()

END CLASS

//----------------------------------------------------------------------------//

METHOD DefineFiles( cPath, cDriver ) CLASS TRoles

   DEFAULT cPath        := ::cPath
   DEFAULT cDriver      := cDriver()

   DEFINE DATABASE ::oDbf FILE "ROLES.DBF" CLASS "ROLES" PATH ( cPath ) VIA ( cDriver ) COMMENT "Roles"

      FIELD NAME "uuid"       TYPE "C" LEN  40  DEC 0  COMMENT "Identificador"               HIDE         DEFAULT win_uuidcreatestring()     OF ::oDbf
      FIELD NAME "nombre"     TYPE "C" LEN 100  DEC 0  COMMENT "Nombre"                      COLSIZE 250                                     OF ::oDbf
      FIELD NAME "permuuid"   TYPE "C" LEN  40  DEC 0  COMMENT "Uuid permisos"               HIDE                                            OF ::oDbf
      FIELD NAME "lVieRnt"    TYPE "L" LEN   1  DEC 0  COMMENT "Mostrar rentabilidad"        HIDE                                            OF ::oDbf
      FIELD NAME "lChgPrc"    TYPE "L" LEN   1  DEC 0  COMMENT "Cambiar precios"             HIDE                                            OF ::oDbf
      FIELD NAME "lVieCos"    TYPE "L" LEN   1  DEC 0  COMMENT "Ver precios de costo"        HIDE                                            OF ::oDbf
      FIELD NAME "lConfDel"   TYPE "L" LEN   1  DEC 0  COMMENT "Confirmar eliminación"       HIDE                                            OF ::oDbf
      FIELD NAME "lVtaUsr"    TYPE "L" LEN   1  DEC 0  COMMENT "Filtrar ventas por usuarios" HIDE                                            OF ::oDbf
      FIELD NAME "lOpnCaj"    TYPE "L" LEN   1  DEC 0  COMMENT "Abrir cajón"                 HIDE                                            OF ::oDbf
      FIELD NAME "lCobTct"    TYPE "L" LEN   1  DEC 0  COMMENT "Cobrar en táctil"            HIDE                                            OF ::oDbf
      FIELD NAME "lEstAlb"    TYPE "L" LEN   1  DEC 0  COMMENT "Estado albarán entregado"    HIDE                                            OF ::oDbf
      FIELD NAME "lAssGFac"   TYPE "L" LEN   1  DEC 0  COMMENT "Asistente generar facturas"  HIDE                                            OF ::oDbf
      FIELD NAME "lChgSta"    TYPE "L" LEN   1  DEC 0  COMMENT "Cambiar estado"              HIDE                                            OF ::oDbf
      FIELD NAME "lChgFld"    TYPE "L" LEN   1  DEC 0  COMMENT "Cambiar campos"              HIDE                                            OF ::oDbf
      FIELD NAME "lNotCom"    TYPE "L" LEN   1  DEC 0  COMMENT "No imprimir comandas"        HIDE                                            OF ::oDbf
      FIELD NAME "lFastCob"   TYPE "L" LEN   1  DEC 0  COMMENT "Mostrar cobors rápidos"      HIDE                                            OF ::oDbf

      INDEX TO "ROLES.CDX" TAG "nombre" ON "Nombre" COMMENT "Nombre" NODELETED OF ::oDbf

   END DATABASE ::oDbf

RETURN ( ::oDbf )

//----------------------------------------------------------------------------//

METHOD New( cPath, oWndParent, oMenuItem ) CLASS TRoles

   DEFAULT cPath        := cPatEmp()
   DEFAULT oWndParent   := GetWndFrame()
   DEFAULT oMenuItem    := "roles"

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

   ::aComboPermisos     := PermisosModel():getNameList()

   ::cHtmlHelp          := "Roles"

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Create( cPath ) CLASS TRoles

   DEFAULT cPath        := cPatEmp()

   ::cPath              := cPath
   ::oDbf               := nil

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD Activate() CLASS TRoles

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

METHOD Resource( nMode ) CLASS TRoles

   local oDlg
   local oBmp

   ::cComboPermisos     := PermisosModel():getNombre( ::oDbf:permuuid )

   DEFINE DIALOG oDlg RESOURCE "ROL" TITLE LblTitle( nMode ) + "rol"

      REDEFINE BITMAP oBmp ;
         ID          900 ;
         RESOURCE    "GC_ID_CARDS_48" ;
         TRANSPARENT ;
         OF          oDlg

      REDEFINE GET   ::oGetNombre VAR ::oDbf:nombre ;
         ID          110 ;
         WHEN        ( nMode != ZOOM_MODE ) ;
         OF          oDlg

      REDEFINE COMBOBOX ::oComboPermisos VAR ::cComboPermisos ;
         ID          120 ;
         ITEMS       ::aComboPermisos ;
         WHEN        ( nMode != ZOOM_MODE ) ;
         OF          oDlg

      REDEFINE BUTTON ;
         ID          IDOK ;
         OF          oDlg ;
         WHEN        ( nMode != ZOOM_MODE ) ;
         ACTION      ( if( ::lPresave(), oDlg:end( IDOK ), ) )

      REDEFINE BUTTON ;
         ID          IDCANCEL ;
         OF          oDlg ;
         CANCEL ;
         ACTION      ( oDlg:end() )

      if nMode != ZOOM_MODE
         oDlg:AddFastKey( VK_F5, {|| if( ::lPresave(), oDlg:end( IDOK ), ) } )
      end if

      oDlg:bStart       := {|| ::oGetNombre:SetFocus()  }

   ACTIVATE DIALOG oDlg CENTER

   if !Empty( oBmp )
      oBmp:end()
   end if

RETURN ( oDlg:nResult == IDOK )

//----------------------------------------------------------------------------//

METHOD lPresave() CLASS TRoles

   if Empty( ::oDbf:nombre )
      MsgStop( "El campo nombre es obligatorio" )
      ::oGetNombre:SetFocus()
      Return .f.
   end if

   if Empty( ::oComboPermisos:VarGet() )
      ::oDbf:permuuid   := ""
   else
      ::oDbf:permuuid   := PermisosModel():getuuid( ::oComboPermisos:VarGet() )
   end if

RETURN ( .t. )

//----------------------------------------------------------------------------//

METHOD Config() CLASS TRoles

   local oDlg
   local oBmp

   ::lVieRnt         := ::oDbf:lVieRnt                //Mostrar rentabilidad"       
   ::lChgPrc         := ::oDbf:lChgPrc                //Cambiar precios"            
   ::lVieCos         := ::oDbf:lVieCos                //Ver precios de costo"       
   ::lConfDel        := ::oDbf:lConfDel               //Confirmar eliminación"      
   ::lVtaUsr         := ::oDbf:lVtaUsr                //Filtrar ventas por usuarios"
   ::lOpnCaj         := ::oDbf:lOpnCaj                //Abrir cajón"                
   ::lCobTct         := ::oDbf:lCobTct                //Cobrar en táctil"           
   ::lFastCob        := ::oDbf:lFastCob               //Mostrar Cobros rápidos"           
   ::lEstAlb         := ::oDbf:lEstAlb                //Estado albarán entregado"   
   ::lAssGFac        := ::oDbf:lAssGFac               //Asistente generar facturas" 
   ::lChgSta         := ::oDbf:lChgSta                //Cambiar estado"             
   ::lChgFld         := ::oDbf:lChgFld                //Cambiar campos"             
   ::lNotCom         := ::oDbf:lNotCom                //No imprimir comandas

   DEFINE DIALOG oDlg RESOURCE "CFG_ROL" TITLE "Configuraciones"

      REDEFINE BITMAP oBmp ;
         ID          500 ;
         RESOURCE    "gc_wrench_48" ;
         TRANSPARENT ;
         OF          oDlg

      REDEFINE CHECKBOX ::oVieRnt ;
         VAR         ::lVieRnt ;
         ID          110 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oChgPrc ;
         VAR         ::lChgPrc ;
         ID          120 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oVieCos ;
         VAR         ::lVieCos ;
         ID          130 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oConfDel ;
         VAR         ::lConfDel ;
         ID          140 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oVtaUsr ;
         VAR         ::lVtaUsr ;
         ID          150 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oOpnCaj ;
         VAR         ::lOpnCaj ;
         ID          160 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oCobTct ;
         VAR         ::lCobTct ;
         ID          170 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oFastCob ;
         VAR         ::lFastCob ;
         ID          230 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oEstAlb ;
         VAR         ::lEstAlb ;
         ID          180 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oAssGFac ;
         VAR         ::lAssGFac ;
         ID          190 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oChgSta ;
         VAR         ::lChgSta ;
         ID          200 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oChgFld ;
         VAR         ::lChgFld ;
         ID          210 ;
         OF          oDlg

      REDEFINE CHECKBOX ::oNotCom ;
         VAR         ::lNotCom ;
         ID          220 ;
         OF          oDlg

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

   ACTIVATE DIALOG oDlg CENTER

   if !Empty( oBmp )
      oBmp:end()
   end if

RETURN ( oDlg:nResult == IDOK )

//----------------------------------------------------------------------------//

METHOD SaveConfig() CLASS TRoles

   RolesModel():updateConfig( ::odbf:uuid,;
                              ::lVieRnt ,;
                              ::lChgPrc ,;                              
                              ::lVieCos ,;
                              ::lConfDel ,;
                              ::lVtaUsr ,;
                              ::lOpnCaj ,;
                              ::lCobTct ,;
                              ::lEstAlb ,;
                              ::lAssGFac ,;
                              ::lChgSta ,;
                              ::lChgFld ,;
                              ::lNotCom ,;
                              ::lFastCob )

RETURN ( nil )

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

CLASS RolesModel FROM ADSBaseModel

   METHOD getTableName()                                    INLINE ::getDatosTableName( "roles" )

   METHOD getNombre( uuid )                                 INLINE ( ::getField( "nombre", "uuid", uuid ) )

   METHOD getuuid( nombre )                                 INLINE ( ::getField( "uuid", "nombre", nombre ) )

   METHOD getNameList()

   METHOD InsertFromHashSql( hHash )
   METHOD lExisteUuid( uuid )

   METHOD updateConfig()

   METHOD getLogic( uuid, cFld )                            INLINE ( if( Empty( uuid ), .t., ::getField( cFld, "uuid", uuid ) ) )

   METHOD getRolMostrarRentabilidad( uuid )                 INLINE ( ::getLogic( uuid, "lVieRnt" ) )
   METHOD getRolNoMostrarRentabilidad( uuid )               INLINE ( !::getRolMostrarRentabilidad( uuid ) )   
   
   METHOD getRolCambiarPrecios( uuid )                      INLINE ( ::getLogic( uuid, "lChgPrc" ) )
   METHOD getRolNoCambiarPrecios( uuid )                    INLINE ( !::getRolCambiarPrecios( uuid ) )   
   
   METHOD getRolVerPreciosCosto( uuid )                     INLINE ( ::getLogic( uuid, "lVieCos" ) )
   METHOD getRolNoVerPreciosCosto( uuid )                   INLINE ( !::getRolVerPreciosCosto( uuid ) )

   METHOD getRolConfirmacionEliminacion( uuid )             INLINE ( ::getLogic( uuid, "lConfDel" ) )   
   METHOD getRolNoConfirmacionEliminacion( uuid )           INLINE ( !::getRolConfirmacionEliminacion( uuid ) )   
   
   METHOD getRolFiltrarVentas( uuid )                       INLINE ( ::getLogic( uuid, "lVtaUsr" ) )   
   METHOD getRolNoFiltrarVentas( uuid )                     INLINE ( !::getRolFiltrarVentas( uuid ) )

   METHOD getRolAbrirCajonPortamonedas( uuid )              INLINE ( ::getLogic( uuid, "lOpnCaj" ) )
   METHOD getRolCobrarEnTactil( uuid )                      INLINE ( ::getLogic( uuid, "lCobTct" ) )
   METHOD getRolNoMostrarCobrosRapidos( uuid )              INLINE ( if( Empty( uuid ), .f., ::getField( "lFastCob", "uuid", uuid ) ) )

   METHOD getRolAlbaranEntregado( uuid )                    INLINE ( ::getLogic( uuid, "lEstAlb" ) )   
   METHOD getRolNoAlbaranEntregado( uuid )                  INLINE ( !::getRolAlbaranEntregado( uuid ) )

   METHOD getRolAsistenteGenerarFacturas( uuid )            INLINE ( ::getLogic( uuid, "lAssGFac" ) )   
   METHOD getRolNoAsistenteGenerarFacturas( uuid )          INLINE ( !::getRolAsistenteGenerarFacturas( uuid ) )

   METHOD getRolCambiarEstado( uuid )                       INLINE ( ::getLogic( uuid, "lChgSta" ) )
   METHOD getRolNoCambiarEstado( uuid )                     INLINE ( !::getRolCambiarEstado( uuid ) )

   METHOD getRolCambiarCampos( uuid )                       INLINE ( ::getLogic( uuid, "lChgFld" ) )
   METHOD getRolNoCambiarCampos( uuid )                     INLINE ( !::getRolCambiarCampos( uuid ) )

   METHOD getRolNotComandas( uuid )                         INLINE ( ::getLogic( uuid, "lNotCom" ) )
   
END CLASS

//---------------------------------------------------------------------------//

METHOD getNameList() CLASS RolesModel

   local aNames   := { "" }
   local cStm     := "getNameList"
   local cSql     := "SELECT nombre FROM " + ::getTableName()

   if ::ExecuteSqlStatement( cSql, @cStm )

      ( cStm )->( dbGoTop() )

      while !( cStm )->( Eof() )

         aAdd( aNames, ( cStm )->nombre )

         ( cStm )->( dbSkip() )

      end while

   end if

RETURN ( aNames )

//---------------------------------------------------------------------------//

METHOD InsertFromHashSql( hHash ) CLASS RolesModel

   local cStm     := "InsertFromHashSql"
   local cSql     := ""

   if !Empty( hHash ) .and. !::lExisteUuid( hGet( hHash, "uuid" ) )

      cSql         := "INSERT INTO " + ::getTableName() 
      cSql         += " ( uuid, nombre, permuuid ) VALUES "
      cSql         += " ( " + quoted( hGet( hHash, "uuid" ) )
      cSql         += ", " + quoted( hGet( hHash, "nombre" ) )
      cSql         += ", " + quoted( hGet( hHash, "permiso_uuid" ) ) + " )"

      ::ExecuteSqlStatement( cSql, @cStm )

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lExisteUuid( uuid ) CLASS RolesModel

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

METHOD updateConfig( uuid, lVieRnt, lChgPrc, lVieCos, lConfDel, lVtaUsr, lOpnCaj, lCobTct, lEstAlb, lAssGFac, lChgSta, lChgFld, lNotCom, lFastCob ) CLASS RolesModel

   local cStm     := "UpdateRol"
   local cSql     := ""

   cSql           := "UPDATE " + ::getTableName() + " SET"
   cSql           += " lVieRnt = " + if( lVieRnt, ".t.", ".f." ) + ","
   cSql           += " lChgPrc = " + if( lChgPrc, ".t.", ".f." ) + ","
   cSql           += " lVieCos = " + if( lVieCos, ".t.", ".f." ) + ","
   cSql           += " lConfDel = " + if( lConfDel, ".t.", ".f." ) + ","
   cSql           += " lVtaUsr = " + if( lVtaUsr, ".t.", ".f." ) + ","
   cSql           += " lOpnCaj = " + if( lOpnCaj, ".t.", ".f." ) + ","
   cSql           += " lCobTct = " + if( lCobTct, ".t.", ".f." ) + ","
   cSql           += " lEstAlb = " + if( lEstAlb, ".t.", ".f." ) + ","
   cSql           += " lAssGFac = " + if( lAssGFac, ".t.", ".f." ) + ","
   cSql           += " lChgSta = " + if( lChgSta, ".t.", ".f." ) + ","
   cSql           += " lChgFld = " + if( lChgFld, ".t.", ".f." ) + ","
   cSql           += " lNotCom = " + if( lNotCom, ".t.", ".f." ) + ","
   cSql           += " lFastCob = " + if( lFastCob, ".t.", ".f." )
   cSql           += " WHERE uuid = " + quoted( uuid )

   ::ExecuteSqlStatement( cSql, @cStm )

Return ( nil )

//---------------------------------------------------------------------------//