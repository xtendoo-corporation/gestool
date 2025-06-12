#include "FiveWin.Ch"
#include "Font.ch"
#include "Report.ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//----------------------------------------------------------------------------//

CLASS TPermisos FROM TMant

   DATA cMru            INIT "GC_ID_BADGE_16"
   DATA cBitmap         INIT  clrTopHerramientas

   DATA oGetNombre

   DATA oBrowse
   DATA oTree

   METHOD DefineFiles()

   METHOD New( cPath, oWndParent, oMenuItem )
   METHOD Create( cPath )

   METHOD Activate()

   METHOD Resource( nMode )

   METHOD lPresave()

   METHOD addTreeItems( aAccesos )

   METHOD addTreeItem( oAcceso )

   METHOD loadOption( cPermisoUuid, cNombre )

   METHOD saveOption( cUuid, oTree )

   METHOD getTreeItem( cKey )   
      METHOD getTreeItemAccess()             INLINE ( ::getTreeItem( "Access" ) )
      METHOD getTreeItemAppend()             INLINE ( ::getTreeItem( "Append" ) )
      METHOD getTreeItemEdit()               INLINE ( ::getTreeItem( "Edit" ) )
      METHOD getTreeItemZoom()               INLINE ( ::getTreeItem( "Zoom" ) )
      METHOD getTreeItemDelete()             INLINE ( ::getTreeItem( "Delete" ) )
      METHOD getTreeItemPrint()              INLINE ( ::getTreeItem( "Print" ) )

      METHOD setTreeItem( cKey, uValue )
      METHOD setTreeItemAccess( uValue )     INLINE ( ::setTreeItem( "Access", uValue ) )
      METHOD setTreeItemAppend( uValue )     INLINE ( ::setTreeItem( "Append", uValue ) )
      METHOD setTreeItemEdit( uValue )       INLINE ( ::setTreeItem( "Edit", uValue ) )
      METHOD setTreeItemZoom( uValue )       INLINE ( ::setTreeItem( "Zoom", uValue ) )
      METHOD setTreeItemDelete( uValue )     INLINE ( ::setTreeItem( "Delete", uValue ) )
      METHOD setTreeItemPrint( uValue )      INLINE ( ::setTreeItem( "Print", uValue ) )

END CLASS

//----------------------------------------------------------------------------//

METHOD DefineFiles( cPath, cDriver ) CLASS TPermisos

   DEFAULT cPath        := ::cPath
   DEFAULT cDriver      := cDriver()

   DEFINE DATABASE ::oDbf FILE "PERMISOS.DBF" CLASS "PERMISOS" PATH ( cPath ) VIA ( cDriver ) COMMENT "Permisos"

      FIELD NAME "uuid"       TYPE "C" LEN  40  DEC 0  COMMENT "Identificador"       HIDE          DEFAULT win_uuidcreatestring()   OF ::oDbf
      FIELD NAME "nombre"     TYPE "C" LEN 100  DEC 0  COMMENT "Nombre"              COLSIZE 250                                    OF ::oDbf

      INDEX TO "PERMISOS.CDX" TAG "Nombre" ON "nombre" COMMENT "Nombre" NODELETED OF ::oDbf

   END DATABASE ::oDbf

RETURN ( ::oDbf )

//----------------------------------------------------------------------------//

METHOD New( cPath, oWndParent, oMenuItem ) CLASS TPermisos

   DEFAULT cPath        := cPatEmp()
   DEFAULT oWndParent   := GetWndFrame()
   DEFAULT oMenuItem    := "permisos"

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

   ::cHtmlHelp          := "Permisos"

   ::bOnPreDelete       := {|| DetPermisosModel():deleteLines( ::oDbf:uuid ) }

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Create( cPath ) CLASS TPermisos

   DEFAULT cPath        := cPatEmp()

   ::cPath              := cPath
   ::oDbf               := nil

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD Activate() CLASS TPermisos

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

      ::oWndBrw:AutoButtons( Self )

      if ::cHtmlHelp != nil
         ::oWndBrw:cHtmlHelp  := ::cHtmlHelp
      end if

      ::oWndBrw:Activate( nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, {|| ::CloseFiles() } )

   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Resource( nMode ) CLASS TPermisos

   local oDlg
   local oBmp

   ::oTree  := nil
   ::addTreeItems( oWndBar():aAccesos )

   DEFINE DIALOG oDlg RESOURCE "PERMISOS" TITLE LblTitle( nMode ) + "permisos"

      REDEFINE BITMAP oBmp ;
         ID          900 ;
         RESOURCE    "gc_id_badge_48" ;
         TRANSPARENT ;
         OF          oDlg

      REDEFINE GET   ::oGetNombre VAR ::oDbf:nombre ;
         ID          110 ;
         WHEN        ( nMode != ZOOM_MODE ) ;
         OF          oDlg

      ::oBrowse                  := IXBrowse():New( oDlg )
      ::oBrowse:bWhen            := {|| nMode != ZOOM_MODE }

      ::oBrowse:bClrSel          := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrowse:bClrSelFocus     := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrowse:lVScroll         := .t.
      ::oBrowse:lHScroll         := .f.
      ::oBrowse:nMarqueeStyle    := 5
      ::oBrowse:lRecordSelector  := .f.

      with object ( ::oBrowse:AddCol() )
         :cHeader                := "Acceso"
         :bStrData               := {|| "" }
         :bEditValue             := {|| ::getTreeItemAccess() }
         :nWidth                 := 60
         :SetCheck( { "Sel16", "Nil16" }, {|o, v| ::setTreeItemAccess( v ) } )
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader                := "Añadir"
         :bStrData               := {|| "" }
         :bEditValue             := {|| ::getTreeItemAppend() }
         :nWidth                 := 60
         :SetCheck( { "Sel16", "Nil16" }, {|o, v| ::setTreeItemAppend( v ) } )
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader                := "Modificar"
         :bStrData               := {|| "" }
         :bEditValue             := {|| ::getTreeItemEdit() }
         :nWidth                 := 60
         :SetCheck( { "Sel16", "Nil16" }, {|o, v| ::setTreeItemEdit( v ) } )
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader                := "Zoom"
         :bStrData               := {|| "" }
         :bEditValue             := {|| ::getTreeItemZoom() }
         :nWidth                 := 60
         :SetCheck( { "Sel16", "Nil16" }, {|o, v| ::setTreeItemZoom( v ) } )
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader                := "Eliminar"
         :bStrData               := {|| "" }
         :bEditValue             := {|| ::getTreeItemDelete() }
         :nWidth                 := 60
         :SetCheck( { "Sel16", "Nil16" }, {|o, v| ::setTreeItemDelete( v ) } )
      end with

      with object ( ::oBrowse:AddCol() )
         :cHeader                := "Imprimir"
         :bStrData               := {|| "" }
         :bEditValue             := {|| ::getTreeItemPrint() }
         :nWidth                 := 60
         :SetCheck( { "Sel16", "Nil16" }, {|o, v| ::setTreeItemPrint( v ) } )
      end with

      ::oBrowse:CreateFromResource( 120 )

      ::oBrowse:SetTree( ::oTree, { "gc_navigate_minus_16", "gc_navigate_plus_16", "nil16" } ) 
      
      if len( ::oBrowse:aCols ) > 1
         ::oBrowse:aCols[ 1 ]:cHeader  := ""
         ::oBrowse:aCols[ 1 ]:nWidth   := 200
      end if

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

      oDlg:bStart    := {|| ::oGetNombre:SetFocus() }

   ACTIVATE DIALOG oDlg CENTER

   if !Empty( oBmp )
      oBmp:end()
   end if

RETURN ( oDlg:nResult == IDOK )

//----------------------------------------------------------------------------//

METHOD lPresave() CLASS TPermisos

   if Empty( ::oDbf:nombre )
      MsgStop( "El campo nombre es obligatorio" )
      ::oGetNombre:SetFocus()
      Return .f.
   end if

   ::oTree:eval( {|oItem| iif( !empty( hget( oItem:Cargo, "Id" ) ), ::saveOption( oItem ), ) } )

RETURN ( .t. )

//----------------------------------------------------------------------------//

METHOD addTreeItems( aAccesos ) CLASS TPermisos 

   if empty( ::oTree )
      ::oTree  := TreeBegin()
   else
      TreeBegin()
   end if 

   aeval( aAccesos,;
      {|oAcceso|  ::addTreeItem( oAcceso ),;
                  iif(  len( oAcceso:aAccesos ) > 0,;
                        ::addTreeItems( oAcceso:aAccesos ), ) } )

   TreeEnd()

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD addTreeItem( oAcceso ) CLASS TPermisos 

   local cUuid     
   local oItem  

   cUuid          := ::oDbf:uuid 
   oItem          := treeAddItem( oAcceso:cPrompt )

   if empty( oAcceso:cId )
      oItem:Cargo := hPermiso()
   else
      oItem:Cargo := hPermiso( oAcceso:cId, ::loadOption( cUuid, oAcceso:cId ) )
   end if 

RETURN ( self )

//---------------------------------------------------------------------------//

METHOD getTreeItem( cKey ) CLASS TPermisos 

   if !empty( ::oBrowse:oTreeItem )
      RETURN ( hget( ::oBrowse:oTreeItem:Cargo, cKey ) )
   endif 

RETURN ( "" )

//---------------------------------------------------------------------------//

METHOD setTreeItem( cKey, uValue ) CLASS TPermisos 

   if empty( ::oBrowse:oTreeItem )
      RETURN ( uValue )
   end if 
   
   if empty( ::oBrowse:oTreeItem:oTree )
      hset( ::oBrowse:oTreeItem:Cargo, cKey, uValue ) 
      RETURN ( uValue )
   end if 

   if msgyesno( "¿Desea cambiar los valores de los nodos inferiores?", "Seleccione una opción" )
      hset( ::oBrowse:oTreeItem:Cargo, cKey, uValue ) 
      ::oBrowse:oTreeItem:oTree:eval( {|oItem| hset( oItem:Cargo, cKey, uValue ) } )
   end if 

RETURN ( uValue )

//----------------------------------------------------------------------------//

METHOD loadOption( cPermisoUuid, cNombre ) CLASS TPermisos 

   local nPermiso

   //nPermiso       := PermisosOpcionesRepository():getNivel( cPermisoUuid, cNombre )

   nPermiso       := DetPermisosModel():getNivel( cPermisoUuid, cNombre )

   if hb_isnil( nPermiso )
      RETURN ( __permission_full__ )
   end if 

RETURN ( nPermiso )

//----------------------------------------------------------------------------//

METHOD saveOption( oItem ) CLASS TPermisos

   DetPermisosModel():set( ::oDbf:uuid, hget( oItem:Cargo, "Id" ), nPermiso( oItem:Cargo ) )

RETURN ( nil )

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

CLASS PermisosModel FROM ADSBaseModel

   METHOD getTableName()            INLINE ::getDatosTableName( "permisos" )

   METHOD getNombre( uuid )         INLINE ( ::getField( "nombre", "uuid", uuid ) )

   METHOD getuuid( nombre )         INLINE ( ::getField( "uuid", "nombre", nombre ) )

   METHOD getNameList()

   METHOD InsertFromHashSql( hHash )
   METHOD lExisteUuid( uuid )

END CLASS

//---------------------------------------------------------------------------//

METHOD getNameList() CLASS PermisosModel

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

//----------------------------------------------------------------------------//

METHOD InsertFromHashSql( hHash ) CLASS PermisosModel

   local cStm     := "InsertFromHashSql"
   local cSql     := ""

   if !Empty( hHash ) .and. !::lExisteUuid( hGet( hHash, "uuid" ) )

      cSql         := "INSERT INTO " + ::getTableName() 
      cSql         += " ( uuid, nombre ) VALUES "
      cSql         += " ( " + quoted( hGet( hHash, "uuid" ) )
      cSql         += ", " + quoted( hGet( hHash, "nombre" ) ) + " )"

      ::ExecuteSqlStatement( cSql, @cStm )

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD lExisteUuid( uuid ) CLASS PermisosModel

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
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

FUNCTION nPermiso( hPermisos )

   local nPermiso    := 0

   if hget( hPermisos, "Access" )   ; nPermiso := nOr( nPermiso, __permission_access__ )  ; endif
   if hget( hPermisos, "Append" )   ; nPermiso := nOr( nPermiso, __permission_append__ )  ; endif
   if hget( hPermisos, "Edit" )     ; nPermiso := nOr( nPermiso, __permission_edit__ )    ; endif
   if hget( hPermisos, "Zoom" )     ; nPermiso := nOr( nPermiso, __permission_zoom__ )    ; endif
   if hget( hPermisos, "Delete" )   ; nPermiso := nOr( nPermiso, __permission_delete__ )  ; endif
   if hget( hPermisos, "Print" )    ; nPermiso := nOr( nPermiso, __permission_print__ )   ; endif

RETURN ( nPermiso )

//---------------------------------------------------------------------------//

FUNCTION hPermiso( cId, nPermiso )

   local hPermiso    := {=>}

   DEFAULT cId       := ""
   DEFAULT nPermiso  := __permission_full__ 

   hset( hPermiso, "Id",      cId )
   hset( hPermiso, "Access",  nAnd( nPermiso, __permission_access__  ) != 0 )
   hset( hPermiso, "Append",  nAnd( nPermiso, __permission_append__  ) != 0 )
   hset( hPermiso, "Edit",    nAnd( nPermiso, __permission_edit__    ) != 0 )
   hset( hPermiso, "Zoom",    nAnd( nPermiso, __permission_zoom__    ) != 0 )
   hset( hPermiso, "Delete",  nAnd( nPermiso, __permission_delete__  ) != 0 )
   hset( hPermiso, "Print",   nAnd( nPermiso, __permission_print__   ) != 0 )

RETURN ( hPermiso )

//---------------------------------------------------------------------------//