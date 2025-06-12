#include "FiveWin.Ch"
#include "Report.ch"
#include "Xbrowse.ch"
#include "MesDbf.ch"
#include "Factu.ch"
#include "FastRepH.ch"

#define IDFOUND            3
#define _MENUITEM_         "det_escandallos"

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS TDetEscandallos FROM TDet

   METHOD DefineFiles()

   METHOD OpenFiles( lExclusive )
   METHOD CloseFiles()

   MESSAGE OpenService( lExclusive )               METHOD OpenFiles( lExclusive )

   /*METHOD Resource( nMode, lLiteral )
      METHOD ValidResource( nMode, oDlg, oBtn )
      METHOD MenuResource( oDlg )*/

END CLASS

//--------------------------------------------------------------------------//

METHOD DefineFiles( cPath, cDriver, lUniqueName, cFileName ) CLASS TDetEscandallos

   local oDbf

   DEFAULT cPath        := ::cPath
   DEFAULT cDriver      := ::cDriver
   DEFAULT lUniqueName  := .f.
   DEFAULT cFileName    := "DETESCAN"

   if lUniqueName
      cFileName         := cGetNewFileName( cFileName, , , cPatTmp() )
   end if

   DEFINE TABLE oDbf FILE ( cFileName ) CLASS "DETESCAN" ALIAS ( cFileName ) PATH ( cPath ) VIA ( cDriver )

      FIELD NAME "cParUuid"  TYPE "C" LEN  40 DEC 0 COMMENT "Uuid parent"                         OF oDbf
      FIELD NAME "cCodKit"   TYPE "C" LEN  18 DEC 0 COMMENT "Código del contenedor"               OF oDbf
      FIELD NAME "cRefKit"   TYPE "C" LEN  18 DEC 0 COMMENT "Código de artículo escandallo"       OF oDbf
      FIELD NAME "nUndKit"   TYPE "N" LEN  18 DEC 8 COMMENT "Unidades de escandallo"              OF oDbf
      FIELD NAME "nPreKit"   TYPE "N" LEN  18 DEC 8 COMMENT "Precio de escandallo"                OF oDbf
      FIELD NAME "cDesKit"   TYPE "C" LEN  50 DEC 0 COMMENT "Descripción del escandallo"          OF oDbf
      FIELD NAME "cUnidad"   TYPE "C" LEN   2 DEC 0 COMMENT "Unidad de medición"                  OF oDbf
      FIELD NAME "nValPnt"   TYPE "N" LEN  18 DEC 8 COMMENT ""                                    OF oDbf
      FIELD NAME "nDtoPnt"   TYPE "N" LEN   6 DEC 2 COMMENT "Descuento del punto"                 OF oDbf
      FIELD NAME "lAplDto"   TYPE "L" LEN   1 DEC 0 COMMENT "Lógico aplicar descuentos"           OF oDbf
      FIELD NAME "lExcPro"   TYPE "L" LEN   1 DEC 0 COMMENT "Lógico para excluir de producción"   OF oDbf

      INDEX TO ( cFileName ) TAG "cParUuid"     ON "cParUuid"        NODELETED                     OF oDbf
      INDEX TO ( cFileName ) TAG "cCodKit"      ON "cCodKit"         NODELETED                     OF oDbf
      INDEX TO ( cFileName ) TAG "cRefKit"      ON "cRefKit"         NODELETED                     OF oDbf

   END DATABASE oDbf

RETURN ( oDbf )

//--------------------------------------------------------------------------//

METHOD OpenFiles( lExclusive) CLASS TDetEscandallos

   local lOpen             := .t.
   local oBlock

   DEFAULT  lExclusive     := .f.

   oBlock                  := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      if empty( ::oDbf )
         ::oDbf            := ::defineFiles()
      end if

      ::oDbf:Activate( .f., !lExclusive )

  RECOVER

     msgstop( "Imposible abrir todas las bases de datos movimientos de almacén" )
     lOpen                := .f.

  END SEQUENCE

  ErrorBlock( oBlock )

   if !lOpen
      ::CloseFiles()
   end if

RETURN ( lOpen )

//--------------------------------------------------------------------------//

METHOD CloseFiles() CLASS TDetEscandallos

   if ::oDbf != nil .and. ::oDbf:Used()
      ::oDbf:End()
   end if

   ::oDbf         := nil

RETURN .t.

//---------------------------------------------------------------------------//

/*METHOD Resource( nMode ) CLASS TDetEscandallos

   local oDlg
   local oBtn
   local oSayPre
   local nStockOrigen      := 0
   local nStockDestino     := 0
   local oTotUnd
   local cSayLote          := 'Lote'
   local oBtnSer
   local oSayTotal
   local cCodArt

   if nMode == APPD_MODE
      ::oDbfVir:nNumLin    := nLastNum( ::oDbfVir:cAlias )
   end if

   ::cOldCodArt            := ::oDbfVir:cRefMov
   ::cOldValPr1            := ::oDbfVir:cValPr1
   ::cOldValPr2            := ::oDbfVir:cValPr2
   ::cOldLote              := ::oDbfVir:cLote

   cCodArt                 := Padr( ::oDbfVir:cRefMov, 128 )

   ::cGetDetalle           := oRetFld( ::oDbfVir:cRefMov, ::oParent:oArt, "Nombre" )

   ::cTxtAlmacenOrigen     := oRetFld( ::oParent:oDbf:cAlmOrg, ::oParent:oAlmacenOrigen )
   ::cTxtAlmacenDestino    := oRetFld( ::oParent:oDbf:cAlmDes, ::oParent:oAlmacenDestino )

   DEFINE DIALOG oDlg RESOURCE "LMovAlm" TITLE lblTitle( nMode ) + "lineas de movimientos de almacén"

      REDEFINE GET ::oRefMov VAR cCodArt ;
         ID       100 ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         BITMAP   "LUPA" ;
         OF       oDlg

      ::oRefMov:bValid     := {|| if( !empty( cCodArt ), ::loadArticulo( cCodArt, nMode ), .t. ) }
      ::oRefMov:bHelp      := {|| BrwArticulo( ::oRefMov, ::oGetDetalle , , , , ::oGetLote, ::oDbfVir:cCodPr1, ::oDbfVir:cCodPr2, ::oValPr1, ::oValPr2  ) }

      REDEFINE GET ::oGetDetalle VAR ::oDbfVir:cNomMov ;
         ID       110 ;
         WHEN     ( .f. ) ;
         OF       oDlg

      // Lote------------------------------------------------------------------

      REDEFINE SAY ::oSayLote VAR cSayLote ;
         ID       154;
         OF       oDlg

      REDEFINE GET ::oGetLote VAR ::oDbfVir:cLote ;
         ID       155 ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         OF       oDlg

      ::oGetLote:bValid          := {|| if( !empty( ::oDbfVir:cLote ), ::loadArticulo( cCodArt, nMode ), .t. ) }

      // Browse de propiedades-------------------------------------------------

      ::oBrwPrp                  := IXBrowse():New( oDlg )

      ::oBrwPrp:nDataType        := DATATYPE_ARRAY

      ::oBrwPrp:bClrSel          := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrwPrp:bClrSelFocus     := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrwPrp:lHScroll         := .t.
      ::oBrwPrp:lVScroll         := .t.

      ::oBrwPrp:nMarqueeStyle    := 3
      ::oBrwPrp:nFreeze          := 1

      ::oBrwPrp:lRecordSelector  := .f.
      ::oBrwPrp:lFastEdit        := .t.
      ::oBrwPrp:lFooter          := .t.

      ::oBrwPrp:SetArray( {}, .f., 0, .f. )

      ::oBrwPrp:MakeTotals()

      ::oBrwPrp:CreateFromResource( 600 )

      // Valor de primera propiedad--------------------------------------------

      REDEFINE GET ::oValPr1 VAR ::oDbfVir:cValPr1;
         ID       120 ;
         BITMAP   "LUPA" ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         OF       oDlg

      ::oValPr1:bValid     := {|| if( lPrpAct( ::oValPr1, ::oSayVp1, ::oDbfVir:cCodPr1, ::oParent:oTblPro:cAlias ), ::loadArticulo( cCodArt, nMode ), .f. ) }
      ::oValPr1:bHelp      := {|| brwPropiedadActual( ::oValPr1, ::oSayVp1, ::oDbfVir:cCodPr1 ) }

      REDEFINE GET ::oSayVp1 VAR ::cSayVp1;
         ID       121 ;
         WHEN     .f. ;
         OF       oDlg

      REDEFINE SAY ::oSayPr1 PROMPT "Propiedad 1";
         ID       122 ;
         OF       oDlg

      // Valor de segunda propiedad--------------------------------------------

      REDEFINE GET ::oValPr2 VAR ::oDbfVir:cValPr2;
         ID       130 ;
         BITMAP   "LUPA" ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         OF       oDlg

      ::oValPr2:bValid     := {|| if( lPrpAct( ::oValPr2, ::oSayVp2, ::oDbfVir:cCodPr2, ::oParent:oTblPro:cAlias ), ::loadArticulo( cCodArt, nMode ), .f. ) }
      ::oValPr2:bHelp      := {|| brwPropiedadActual( ::oValPr2, ::oSayVp2, ::oDbfVir:cCodPr2 ) }

      REDEFINE GET ::oSayVp2 VAR ::cSayVp2 ;
         ID       131 ;
         WHEN     .f. ;
         OF       oDlg

      REDEFINE SAY ::oSayPr2 PROMPT "Propiedad 2";
         ID       132 ;
         OF       oDlg

      REDEFINE GET ::oFechaCaducidad VAR ::oDbfVir:dFecCad ;
         ID       340 ;
         IDSAY    341 ;
         SPINNER ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         OF       oDlg

      REDEFINE GET ::oGetBultos VAR ::oDbfVir:nBultos;
         ID       430 ;
         SPINNER  ;
         WHEN     ( uFieldEmpresa( "lUseBultos" ) .AND. nMode != ZOOM_MODE ) ;
         PICTURE  ::oParent:cPicUnd;
         OF       oDlg

      REDEFINE SAY ::oSayBultos PROMPT uFieldempresa( "cNbrBultos" );
         ID       431;
         OF       oDlg

      REDEFINE GET ::oCajMov VAR ::oDbfVir:nCajMov;
         ID       140;
         SPINNER ;
         WHEN     ( lUseCaj() .and. nMode != ZOOM_MODE ) ;
         ON CHANGE( oTotUnd:Refresh(), oSayPre:Refresh() );
         VALID    ( oTotUnd:Refresh(), oSayPre:Refresh(), .t. );
         PICTURE  ::oParent:cPicUnd ;
         OF       oDlg

      REDEFINE SAY ::oSayCaj PROMPT cNombreCajas(); 
         ID       142 ;
         OF       oDlg

      REDEFINE GET ::oUndMov VAR ::oDbfVir:nUndMov ;
         ID       150;
         SPINNER ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         ON CHANGE( oTotUnd:Refresh(), oSayPre:Refresh() );
         VALID    ( oTotUnd:Refresh(), oSayPre:Refresh(), .t. );
         PICTURE  ::oParent:cPicUnd ;
         OF       oDlg

      REDEFINE SAY ::oSayUnd PROMPT cNombreUnidades() ;
         ID       152 ;
         OF       oDlg

      REDEFINE SAY oTotUnd PROMPT nTotNMovAlm( ::oDbfVir ) ;
         ID       160;
         PICTURE  ::oParent:cPicUnd ;
         OF       oDlg

      REDEFINE GET ::oPreDiv ;
         VAR      ::oDbfVir:nPreDiv ;
         ID       180 ;
         IDSAY    181 ;
         SPINNER ;
         ON CHANGE( oSayPre:Refresh() ) ;
         VALID    ( oSayPre:Refresh(), .t. ) ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         PICTURE  ::oParent:cPinDiv ;
         OF       oDlg

      REDEFINE SAY oSayTotal ;
         ID       191 ;
         OF       oDlg

      REDEFINE SAY oSayPre PROMPT nTotLMovAlm( ::oDbfVir ) ;
         ID       190 ;
         PICTURE  ::oParent:cPirDiv ;
         OF       oDlg
     
      /*
      Almacen origen-----------------------------------------------------------
      */

      /*REDEFINE GET ::oGetAlmacenOrigen VAR ::oParent:oDbf:cAlmOrg ;
         ID       400 ;
         IDSAY    403 ;
         WHEN     ( .f. ) ;
         BITMAP   "Lupa" ;
         OF       oDlg

      REDEFINE GET ::oTxtAlmacenOrigen VAR ::cTxtAlmacenOrigen ;
         ID       401 ;
         WHEN     ( .f. ) ;
         OF       oDlg

      REDEFINE GET ::oGetStockOrigen VAR nStockOrigen ;
         WHEN     ( .f. ) ;
         PICTURE  ::oParent:cPicUnd ;
         ID       402 ;
         OF       oDlg

      /*
      Almacen destino-----------------------------------------------------------
      */

      /*REDEFINE GET ::oGetAlmacenDestino VAR ::oParent:oDbf:cAlmDes ;
         ID       410 ;
         WHEN     ( .f. ) ;
         BITMAP   "Lupa" ;
         OF       oDlg

      REDEFINE GET ::oTxtAlmacenDestino VAR ::cTxtAlmacenDestino ;
         ID       411 ;
         WHEN     ( .f. ) ;
         OF       oDlg

      REDEFINE GET ::oGetStockDestino VAR nStockDestino ;
         WHEN     ( .f. ) ;
         PICTURE  ::oParent:cPicUnd ;
         ID       412 ;
         OF       oDlg

      /*
      Peso y volumen-----------------------------------------------------------
      */

      /*REDEFINE GET ::oDbfVir:nPesoKg ;
         ID       200 ;
         WHEN     ( .f. ) ;
         PICTURE  "@E 999.99";
         OF       oDlg

      REDEFINE GET ::oDbfVir:cPesoKg ;
         ID       210 ;
         WHEN     ( .f. ) ;
         OF       oDlg

      REDEFINE GET ::oDbfVir:nVolumen ;
         ID       220 ;
         WHEN     ( .f. ) ;
         PICTURE  "@E 999.99";
         OF       oDlg

      REDEFINE GET ::oDbfVir:cVolumen ;
         ID       230 ;
         WHEN     ( .f. ) ;
         OF       oDlg

      REDEFINE GET ::oGetFormato VAR ::oDbfVir:cFormato;
         ID       440;
         OF       oDlg

      REDEFINE BUTTON ::oBtnSerie ;
         ID       500 ;
         OF       oDlg ;
         ACTION   ( nil )

      ::oBtnSerie:bAction     := {|| ::oParent:oDetSeriesMovimientos:Resource( nMode ) }

      REDEFINE BUTTON oBtn;
         ID       510 ;
         OF       oDlg ;
         WHEN     ( nMode != ZOOM_MODE ) ;
         ACTION   ( ::ValidResource( nMode, oDlg, oBtn ) )

      REDEFINE BUTTON ;
         ID       520 ;
         OF       oDlg ;
         ACTION   ( oDlg:end() )

      if nMode != ZOOM_MODE

         if uFieldEmpresa( "lGetLot")
            oDlg:AddFastKey( VK_RETURN, {|| ::oRefMov:lValid(), oBtn:SetFocus(), oBtn:Click() } )
         end if 

         oDlg:AddFastKey( VK_F5, {|| oBtn:Click() } )

         oDlg:AddFastKey( VK_F6, {|| ::oBtnSerie:Click() } )
         
      end if

      oDlg:bStart             := {|| ::SetDlgMode( nMode, oSayTotal, oSayPre ) }

   oDlg:Activate( , , , .t., , , {|| ::MenuResource( oDlg ) } )

   // Salida del dialogo----------------------------------------------------------

   ::oMenu:end()

   ::cOldCodArt            := ""
   ::cOldValPr1            := ""
   ::cOldValPr2            := ""
   ::cOldLote              := ""

RETURN ( oDlg:nResult )*/

//--------------------------------------------------------------------------//