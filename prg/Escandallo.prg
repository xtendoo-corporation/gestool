#include "FiveWin.Ch"
#include "Report.ch"
#include "Xbrowse.ch"
#include "MesDbf.ch"
#include "Factu.ch" 
#include "FastRepH.ch"
#include "Directry.ch"

#define IDFOUND            3
#define _MENUITEM_         "escandallos"

//---------------------------------------------------------------------------//

CLASS TEscandallos FROM TMant

   DATA  oDbf
   DATA  oMenuItem

   DATA  oDetEscandallos

   DATA  lOpenFiles                                      INIT  .f.

   METHOD New( cPath, cDriver, oWndParent, oMenuItem )   CONSTRUCTOR

   METHOD OpenFiles( lExclusive )
   METHOD CloseFiles()

   METHOD OpenService( lExclusive )
   METHOD CloseService()
   METHOD CloseIndex()

   METHOD DefineFiles()

   METHOD Reindexa( oMeter )

   //METHOD Resource( nMode )
   //METHOD Activate()

   //METHOD EditDetalleMovimientos( oDlg )
   //METHOD DeleteDet( oDlg )

END CLASS

//---------------------------------------------------------------------------//

METHOD New( cPath, cDriver, oWndParent, oMenuItem ) CLASS TEscandallos

   DEFAULT cPath           := cPatEmp()
   DEFAULT cDriver         := cDriver()
   DEFAULT oWndParent      := oWnd()
   DEFAULT oMenuItem       := "escandallos"

   ::cPath                 := cPath
   ::cDriver               := cDriver
   ::oMenuItem             := oMenuItem

   ::oWndParent            := oWndParent
   ::oDbf                  := nil

   ::oDetEscandallos       := TDetEscandallos():New( cPath, cDriver, Self )
   ::addDetail( ::oDetEscandallos )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD DefineFiles( cPath, cDriver ) CLASS TEscandallos

   DEFAULT cPath        := ::cPath
   DEFAULT cDriver      := ::cDriver

   DEFINE DATABASE ::oDbf FILE "ESCAND.DBF" CLASS "ESCAND" ALIAS "ESCAND" PATH ( cPath ) VIA ( cDriver ) COMMENT "Escandallos de artículos"

      FIELD NAME "cUuid"               TYPE "C" LEN 40  DEC 0                                                                                     COMMENT "Guid de la cabecera"             COLSIZE 40  OF ::oDbf
      FIELD NAME "cCodArt"             TYPE "C" LEN 18  DEC 0                                                                                     COMMENT "Artículo"                        COLSIZE 40  OF ::oDbf
      FIELD NAME "cNomEsc"             TYPE "N" LEN 80  DEC 0                                                                                     COMMENT "Nombre escandallo"               COLSIZE 40  OF ::oDbf
      
      INDEX TO "ESCAND.CDX" TAG "cUuid"     ON "cUuid"     COMMENT "cUuid"         NODELETED   OF ::oDbf

   END DATABASE ::oDbf

RETURN ( ::oDbf )

//---------------------------------------------------------------------------//

/*METHOD Activate() CLASS TEscandallos 

   local oSnd
   local oDel
   local oImp
   local oPrv
   local nLevel   := Auth():Level( ::oMenuItem )

   if nAnd( nLevel, 1 ) == 0
      msgStop( "Acceso no permitido." )
      return .f.
   end if

   /*
   Cerramos todas las ventanas----------------------------------------------
   */

   /*if ::oWndParent != nil
      ::oWndParent:CloseAll()
   end if

   ::CreateShell( nLevel )

   DEFINE BTNSHELL RESOURCE "BUS" OF ::oWndBrw ;
      NOBORDER ;
      ACTION   ( ::oWndBrw:SearchSetFocus() ) ;
      TOOLTIP  "(B)uscar" ;
      HOTKEY   "B";

      ::oWndBrw:AddSeaBar()

   DEFINE BTNSHELL RESOURCE "NEW" OF ::oWndBrw ;
      NOBORDER ;
      ACTION   ( ::oWndBrw:RecAdd() );
      ON DROP  ( ::oWndBrw:RecAdd() );
      TOOLTIP  "(A)ñadir";
      BEGIN GROUP ;
      HOTKEY   "A" ;
      LEVEL    ACC_APPD

   DEFINE BTNSHELL RESOURCE "DUP" OF ::oWndBrw ;
      NOBORDER ;
      ACTION   ( ::oWndBrw:RecDup() );
      TOOLTIP  "(D)uplicar";
      HOTKEY   "D" ;
      LEVEL    ACC_APPD

   DEFINE BTNSHELL RESOURCE "EDIT" OF ::oWndBrw ;
      NOBORDER ;
      ACTION   ( ::oWndBrw:RecEdit() );
      TOOLTIP  "(M)odificar";
      HOTKEY   "M" ;
      LEVEL    ACC_EDIT

   DEFINE BTNSHELL RESOURCE "ZOOM" OF ::oWndBrw ;
      NOBORDER ;
      ACTION   ( ::oWndBrw:RecZoom() );
      TOOLTIP  "(Z)oom";
      HOTKEY   "Z" ;
      LEVEL    ACC_ZOOM

   DEFINE BTNSHELL oDel RESOURCE "DEL" OF ::oWndBrw ;
      NOBORDER ;
      ACTION   ( ::oWndBrw:RecDel() );
      TOOLTIP  "(E)liminar";
      HOTKEY   "E";
      LEVEL    ACC_DELE

   DEFINE BTNSHELL oImp RESOURCE "IMP" OF ::oWndBrw ;
      ACTION   ( ::GenRemMov( .t. ) ) ;
      TOOLTIP  "(I)mprimir";
      HOTKEY   "I";
      LEVEL    ACC_IMPR

   ::lGenRemMov( ::oWndBrw:oBrw, oImp, .t. )

   DEFINE BTNSHELL oImp RESOURCE "GC_PRINTER2_" OF ::oWndBrw ;
      ACTION   ( ::ImprimirSeries() ) ;
      TOOLTIP  "Imp(r)imir series";
      HOTKEY   "R";
      LEVEL    ACC_IMPR

   DEFINE BTNSHELL oPrv RESOURCE "PREV1" OF ::oWndBrw ;
      ACTION   ( ::GenRemMov( .f. ) ) ;
      TOOLTIP  "(P)revisualizar";
      HOTKEY   "P";
      LEVEL    ACC_IMPR

   ::lGenRemMov( ::oWndBrw:oBrw, oPrv, .f. )

   DEFINE BTNSHELL oSnd RESOURCE "LBL" OF ::oWndBrw ;
      ACTION   ( ::lSelMov(), ::oWndBrw:Refresh() );
      MENU     This:Toggle() ;
      TOOLTIP  "En(v)iar" ;
      HOTKEY   "V";
      LEVEL    ACC_EDIT

      DEFINE BTNSHELL RESOURCE "LBL" OF ::oWndBrw ;
         NOBORDER ;
         ACTION   ( ::lSelAll( .t. ) );
         TOOLTIP  "Todos" ;
         FROM     oSnd ;
         LEVEL    ACC_EDIT

      DEFINE BTNSHELL RESOURCE "LBL" OF ::oWndBrw ;
         NOBORDER ;
         ACTION   ( ::lSelAll( .f. ) );
         TOOLTIP  "Ninguno" ;
         FROM     oSnd ;
         LEVEL    ACC_EDIT

   ::oWndBrw:EndButtons( Self )

   if ::cHtmlHelp != nil
      ::oWndBrw:cHtmlHelp  := ::cHtmlHelp
   end if

   ::oWndBrw:Activate( nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, {|| ::CloseFiles() }, nil, nil )

RETURN ( Self )*/

//----------------------------------------------------------------------------//

METHOD OpenFiles( lExclusive ) CLASS TEscandallos 

   local oError
   local oBlock               

   DEFAULT lExclusive         := .f.

   oBlock                     := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

   if !::lOpenFiles

      if empty( ::oDbf )
         ::DefineFiles()
      end if

      ::oDbf:Activate( .f., !( lExclusive ) )

      ::lOpenFiles         := .t.

   end if

   RECOVER USING oError

      ::lOpenFiles         := .f.

      msgstop( "Imposible abrir todas las bases de datos" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

   if !::lOpenFiles
      ::CloseFiles()
   end if

RETURN ( ::lOpenFiles )

//---------------------------------------------------------------------------//

METHOD CloseFiles() CLASS TEscandallos 

   if ::oDbf != nil .and. ::oDbf:Used()
      ::oDbf:End()
   end if

   ::oDbf               := nil

   ::lOpenFiles         := .f.

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD OpenService( lExclusive, cPath ) CLASS TEscandallos 

   local lOpen          := .t.
   local oError
   local oBlock

   DEFAULT lExclusive   := .f.
   DEFAULT cPath        := ::cPath

   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      if empty( ::oDbf )
         ::oDbf         := ::DefineFiles( cPath )
      end if

      ::oDbf:Activate( .f., !( lExclusive ) )

   RECOVER USING oError

      lOpen             := .f.

      msgstop( ErrorMessage( oError ), "Imposible abrir todas las bases de datos de remesas de movimientos" )

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( lOpen )

//---------------------------------------------------------------------------//

METHOD CloseService() CLASS TEscandallos

   if !empty( ::oDbf ) .and. ::oDbf:Used()
      ::oDbf:End()
   end if

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD CloseIndex() CLASS TEscandallos  

   if !empty( ::oDbf ) .and. ::oDbf:Used()
      ::oDbf:OrdListClear()
   end if

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD Reindexa() CLASS TEscandallos

   if empty( ::oDbf )
      ::oDbf   := ::DefineFiles()
   end if

   ::oDbf:IdxFDel()

   if ::OpenService( .t. )
      ::oDbf:IdxFCheck()
      ::oDbf:Pack()
   end if

   ::CloseFiles()

RETURN ( Self )

//--------------------------------------------------------------------------//

/*METHOD Resource( nMode ) CLASS TEscandallos

   local oDlg
   local oSay        := Array( 7 )
   local cSay        := Array( 7 )
   local oBtnImp
   local oBmpGeneral

   // Ordeno oDbfVir por el numero de linea------------------------------------

   ::oDetMovimientos:oDbfVir:OrdSetFocus( "nNumLin" )

   if nMode == APPD_MODE
      ::oDbf:lSelDoc := .t.
      ::oDbf:cCodUsr := Auth():Codigo()
      ::oDbf:cGuid   := win_uuidcreatestring()
   end if

   cSay[ 1 ]         := oRetFld( ::oDbf:cAlmOrg, ::oAlmacenOrigen )
   cSay[ 2 ]         := oRetFld( ::oDbf:cAlmDes, ::oAlmacenDestino )
   cSay[ 5 ]         := oRetFld( cCodEmp() + ::oDbf:cCodDlg, ::oDelega, "cNomDlg" )
   cSay[ 6 ]         := Rtrim( oRetFld( ::oDbf:cCodAge, ::oDbfAge, 2 ) ) + ", " + Rtrim( oRetFld( ::oDbf:cCodAge, ::oDbfAge, 3 ) )

   DEFINE DIALOG oDlg RESOURCE "RemMov" TITLE LblTitle( nMode ) + "movimientos de almacén"

      REDEFINE BITMAP oBmpGeneral ;
        ID       990 ;
        RESOURCE "gc_package_pencil_48" ;
        TRANSPARENT ;
        OF       oDlg

      REDEFINE GET ::oNumRem VAR ::oDbf:nNumRem ;
         ID       100 ;
         WHEN     ( .f. ) ;
         PICTURE  ::oDbf:FieldByName( "nNumRem" ):cPict ;
         OF       oDlg

      REDEFINE GET ::oSufRem VAR ::oDbf:cSufRem ;
         ID       110 ;
         WHEN     ( .f. ) ;
         PICTURE  ::oDbf:FieldByName( "cSufRem" ):cPict ;
         OF       oDlg

      REDEFINE GET ::oFecRem VAR ::oDbf:dFecRem ;
         ID       120 ;
         SPINNER ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         OF       oDlg

      REDEFINE GET ::oTimRem VAR ::oDbf:cTimRem ;
         ID       121 ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         PICTURE  ( ::oDbf:FieldByName( "cTimRem" ):cPict );
         VALID    ( iif(   !validTime( ::oDbf:cTimRem  ),;
                           ( msgstop( "El formato de la hora no es correcto" ), .f. ),;
                           .t. ) );
         OF       oDlg

      REDEFINE GET ::oDbf:cCodUsr ;
         ID       220 ;
         WHEN     ( .f. ) ;
         OF       oDlg

      REDEFINE GET oSay[ 7 ] VAR cSay[ 7 ] ;
         ID       230 ;
         WHEN     .f. ;
         OF       oDlg

      REDEFINE GET ::oDbf:cCodDlg ;
         ID       240 ;
         WHEN     ( .f. ) ;
         OF       oDlg

      REDEFINE GET oSay[ 5 ] VAR cSay[ 5 ] ;
         ID       250 ;
         WHEN     .f. ;
         OF       oDlg

      REDEFINE RADIO ::oRadTipoMovimiento ;
         VAR      ::oDbf:nTipMov ;
         ID       130, 131, 132, 133 ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         ON CHANGE( ::ShwAlm( oSay, oBtnImp ) ) ;
         OF       oDlg

      REDEFINE SAY oSay[ 4 ] PROMPT "Almacén origen" ;
         ID       152 ;
         OF       oDlg

      REDEFINE GET ::oAlmOrg VAR ::oDbf:cAlmOrg UPDATE ;
         ID       150 ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         PICTURE  ::oDbf:FieldByName( "cAlmOrg" ):cPict ;
         BITMAP   "LUPA" ;
         OF       oDlg
      ::oAlmOrg:bValid     := {|| cAlmacen( ::oAlmOrg, ::oAlmacenOrigen:cAlias, oSay[1] ) }
      ::oAlmOrg:bHelp      := {|| BrwAlmacen( ::oAlmOrg, oSay[1] ) }

      REDEFINE GET oSay[ 1 ] VAR cSay[ 1 ] ;
         UPDATE ;
         ID       151 ;
         WHEN     ( .f. ) ;
         OF       oDlg

      REDEFINE GET ::oAlmDes VAR ::oDbf:cAlmDes UPDATE ;
         ID       160 ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         PICTURE  ::oDbf:FieldByName( "cAlmDes" ):cPict ;
         BITMAP   "LUPA" ;
         OF       oDlg

      ::oAlmDes:bValid     := {|| cAlmacen( ::oAlmDes, ::oAlmacenDestino:cAlias, oSay[2] ) }
      ::oAlmDes:bHelp      := {|| BrwAlmacen( ::oAlmDes, oSay[2] ) }

      REDEFINE GET oSay[ 2 ] VAR cSay[ 2 ] UPDATE ;
         ID       161 ;
         WHEN     ( .f. ) ;
         OF       oDlg

      ::oDefDiv( 190, 191, 192, oDlg, nMode )

      REDEFINE GET ::oDbf:cComMov ;
         ID       170 ;
         SPINNER ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         OF       oDlg

      REDEFINE GET ::oCodAge VAR ::oDbf:cCodAge;
         ID       210;
         BITMAP   "LUPA" ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         OF       oDlg

         ::oCodAge:bValid  := {|| cAgentes( ::oCodAge, ::oDbfAge:cAlias, oSay[ 6 ] ) }
         ::oCodAge:bHelp   := {|| BrwAgentes( ::oCodAge, oSay[ 6 ] ) }

      REDEFINE GET oSay[ 6 ] VAR cSay[ 6 ] ;
         ID       211;
         WHEN     .f.;
         OF       oDlg

       /*
       Botones de acceso________________________________________________________________
       */

/*      REDEFINE BUTTON ;
         ID       500 ;
         OF       oDlg ;
         WHEN     ( nMode != ZOOM_MODE .and. !empty( ::oDbf:cAlmDes ) ) ;
         ACTION   ( ::oDetMovimientos:AppendDetail() )

      REDEFINE BUTTON ;
         ID       501 ;
         OF       oDlg ;
         WHEN     ( nMode != ZOOM_MODE .and. !empty( ::oDbf:cAlmDes ) ) ;
         ACTION   ( ::EditDetalleMovimientos( oDlg ) )

      REDEFINE BUTTON ;
         ID       502 ;
         OF       oDlg ;
         WHEN     ( nMode != ZOOM_MODE .and. !empty( ::oDbf:cAlmDes ) ) ;
         ACTION   ( ::DeleteDet() )

      REDEFINE BUTTON ;
         ID       503 ;
         OF       oDlg ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         ACTION   ( ::Search() )

      REDEFINE BUTTON ::oBtnKit ;
         ID       508 ;
         OF       oDlg ;
         ACTION   ( ::ShowKit( .t. ) )

      REDEFINE BUTTON ::oBtnImportarInventario ;
         ID       509 ;
         OF       oDlg ;
         WHEN     ( nMode != ZOOM_MODE .and. !empty( ::oDbf:cAlmDes ) ) ;
         ACTION   ( ::importarInventario() )

      REDEFINE BUTTON ::oBtnImportarInventarioPDA ;
         ID       510 ;
         OF       oDlg ;
         WHEN     ( nMode != ZOOM_MODE .and. !empty( ::oDbf:cAlmDes ) ) ;
         ACTION   ( ::importarInventarioPDA() )

      REDEFINE BUTTON oBtnImp ;
         ID       506 ;
         OF       oDlg ;
         WHEN     ( nMode != ZOOM_MODE .and. !empty( ::oDbf:cAlmDes ) ) ;
         ACTION   ( ::ImportAlmacen( nMode, oDlg ) )

      ::oBrwDet               := IXBrowse():New( oDlg )

      ::oBrwDet:bClrSel       := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrwDet:bClrSelFocus  := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrwDet:nMarqueeStyle := 6
      ::oBrwDet:lHScroll      := .f.
      ::oBrwDet:lFooter       := .t.
      if nMode != ZOOM_MODE
         ::oBrwDet:bLDblClick := {|| ::EditDetalleMovimientos( oDlg ) }
      end if

      ::oBrwDet:cName         := "Detalle movimientos de almacén"

      ::oDetMovimientos:oDbfVir:SetBrowse( ::oBrwDet )

      ::oBrwDet:CreateFromResource( 180 )

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Se.  Seleccionado"
         :bStrData      := {|| "" }
         :bEditValue    := {|| ::oDetMovimientos:oDbfVir:FieldGetByName( "lSelDoc" ) }
         :nWidth        := 24
         :SetCheck( { "Sel16", "Nil16" } )
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Número"
         :bStrData      := {|| if( ::oDetMovimientos:oDbfVir:FieldGetByName( "lKitEsc" ), "", Trans( ::oDetMovimientos:oDbfVir:FieldGetByName( "nNumLin" ), "@EZ 9999" ) ) }
         :nWidth        := 60
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Código"
         :bStrData      := {|| ::oDetMovimientos:oDbfVir:FieldGetByName( "cRefMov" ) }
         :nWidth        := 100
         :cSortOrder    := "cRefAlm"
         :bLClickHeader := {| nMRow, nMCol, nFlags, oCol | if( !empty( oCol ), oCol:SetOrder(), ) }         
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Nombre"
         :bStrData      := {|| ::oDetMovimientos:oDbfVir:FieldGetByName( "cNomMov" ) }
         :nWidth        := 300
         :cSortOrder    := "cNomMov"
         :bLClickHeader := {| nMRow, nMCol, nFlags, oCol | if( !empty( oCol ), oCol:SetOrder(), ) }         
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Prop. 1"
         :bStrData      := {|| ::oDetMovimientos:oDbfVir:FieldGetByName( "cValPr1" ) }
         :nWidth        := 40
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Prop. 2"
         :bStrData      := {|| ::oDetMovimientos:oDbfVir:FieldGetByName( "cValPr2" ) }
         :nWidth        := 40
      end with

      with object ( ::oBrwDet:AddCol() )
         :cHeader       := "Nombre propiedad 1"
         :bEditValue    := {|| nombrePropiedad( ::oDetMovimientos:oDbfVir:FieldGetByName( "cCodPr1" ), ::oDetMovimientos:oDbfVir:FieldGetByName( "cValPr1" ), ::nView ) }
         :nWidth        := 60
         :lHide         := .t.
      end with

      with object ( ::oBrwDet:AddCol() )
         :cHeader       := "Nombre propiedad 2"
         :bEditValue    := {|| nombrePropiedad( ::oDetMovimientos:oDbfVir:FieldGetByName( "cCodPr2" ), ::oDetMovimientos:oDbfVir:FieldGetByName( "cValPr2" ), ::nView ) }
         :nWidth        := 60
         :lHide         := .t.
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Lote"
         :bStrData      := {|| ::oDetMovimientos:oDbfVir:FieldGetByName( "cLote" ) }
         :nWidth        := 80
         :lHide         := .t.
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Serie"
         :bStrData      := {|| ::cMostrarSerie() }
         :nWidth        := 80
         :lHide         := .t.
      end with

      with object ( ::oBrwDet:AddCol() )
         :cHeader       := "Bultos"
         :bEditValue    := {|| ::oDetMovimientos:oDbfVir:FieldGetByName( "nBultos" ) }
         :cEditPicture  := MasUnd()
         :nWidth        := 60
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
         :lHide         := .t.
      end with

      with object ( ::oBrwDet:AddCol() )
         :cHeader       := cNombreCajas()
         :bEditValue    := {|| ::oDetMovimientos:oDbfVir:FieldGetByName( "nCajMov" ) }
         :cEditPicture  := MasUnd()
         :nWidth        := 60
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
         :lHide         := .t.
      end with

      with object ( ::oBrwDet:AddCol() )
         :cHeader       := cNombreUnidades()
         :bEditValue    := {|| ::oDetMovimientos:oDbfVir:FieldGetByName( "nUndMov" ) }
         :cEditPicture  := MasUnd()
         :nWidth        := 60
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
         :lHide         := .t.
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Total " + cNombreUnidades()
         :bEditValue    := {|| nTotNMovAlm( ::oDetMovimientos:oDbfVir ) }
         :bFooter       := {|| ::oDetMovimientos:nTotUnidadesVir( .t. ) }
         :cEditPicture  := ::cPicUnd
         :nWidth        := 80
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Und. anteriores"
         :bEditValue    := {|| nTotNMovOld( ::oDetMovimientos:oDbfVir ) }
         :cEditPicture  := ::cPicUnd
         :lHide         := .t.
         :nWidth        := 80
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Und. diferencia"
         :bEditValue    := {|| abs( nTotNMovAlm( ::oDetMovimientos:oDbfVir ) - nTotNMovOld( ::oDetMovimientos:oDbfVir ) ) }
         :cEditPicture  := ::cPicUnd
         :lHide         := .t.
         :nWidth        := 80
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
      end with
      
   if !oUser():lNotCostos()

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Importe"
         :bEditValue    := {|| ::oDetMovimientos:oDbfVir:FieldGetByName( "nPreDiv" ) }
         :cEditPicture  := ::cPinDiv
         :nWidth        := 100
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Total"
         :bEditValue    := {|| nTotLMovAlm( ::oDetMovimientos:oDbfVir ) }
         :bFooter       := {|| ::oDetMovimientos:nTotRemVir( .t. ) }
         :cEditPicture  := ::cPirDiv
         :nWidth        := 100
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
         :nFootStrAlign := 1
      end with

   end if      

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Total peso"
         :bEditValue    := {|| ( nTotNMovAlm( ::oDetMovimientos:oDbfVir ) * ::oDetMovimientos:oDbfVir:nPesoKg ) }
         :bFooter       := {|| ::oDetMovimientos:nTotPesoVir() }
         :cEditPicture  := MasUnd()
         :nWidth        := 80
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
         :nFootStrAlign := 1
         :lHide         := .t.
      end with

      with object ( ::oBrwDet:addCol() )
         :cHeader       := "Total volumen"
         :bEditValue    := {|| ( nTotNMovAlm( ::oDetMovimientos:oDbfVir ) * ::oDetMovimientos:oDbfVir:nVolumen ) }
         :bFooter       := {|| ::oDetMovimientos:nTotVolumenVir() }
         :cEditPicture  := MasUnd()
         :nWidth        := 80
         :nDataStrAlign := 1
         :nHeadStrAlign := 1
         :nFootStrAlign := 1
         :lHide         := .t.
      end with

      ::nMeter          := 0
      ::oMeter          := TApoloMeter():ReDefine( 400, { | u | if( pCount() == 0, ::nMeter, ::nMeter := u ) }, 10, oDlg, .f., , , .t., rgb( 255,255,255 ), , rgb( 128,255,0 ) )

      REDEFINE BUTTON ::buttonSaveResourceWithCalculate;
         ID       IDOK ;
         OF       oDlg ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         ACTION   ( ::saveResourceWithCalculate( nMode, oDlg ) )

      REDEFINE BUTTON ;
         ID       IDCANCEL ;
         OF       oDlg ;
         CANCEL ;
         ACTION   ( oDlg:End() )

      REDEFINE BUTTON ;
         ID       3 ;
         OF       oDlg ;
         ACTION   ( ::RecalcularPrecios() )

      if nMode != ZOOM_MODE
         oDlg:AddFastKey( VK_F2, {|| ::oDetMovimientos:AppendDetail() } )
         oDlg:AddFastKey( VK_F3, {|| ::EditDetalleMovimientos( oDlg ) } )
         oDlg:AddFastKey( VK_F4, {|| ::DeleteDet() } )
         oDlg:AddFastKey( VK_F5, {|| ::saveResourceWithCalculate( nMode, oDlg ) } )
      end if

      oDlg:AddFastKey( VK_F1, {|| ChmHelp( "Movimientosalmacen" ) } )

      oDlg:bStart := {|| ::ShwAlm( oSay, oBtnImp ), ::ShowKit( .f. ), ::oBrwDet:Load() }

   ACTIVATE DIALOG oDlg CENTER

   oBmpGeneral:End()

   if oDlg:nResult != IDOK
      ::endResource( .f., nMode )
   end if

   // Guardamos los datos del browse----------------------------------------------

   ::oBrwDet:CloseData()

RETURN ( oDlg:nResult == IDOK )*/

//---------------------------------------------------------------------------//