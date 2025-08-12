#include "FiveWin.Ch"
#include "Factu.ch" 

// Estructura del fichero de asientos diarios

#define _ASIEN                    1     //   N      6     0
#define _FECHA                    2     //   D      8     0
#define _SUBCTA                   3     //   C     12     0
#define _CONTRA                   4     //   C     12     0
#define _PTADEBE                  5     //   N     12     0
#define _CONCEPTO                 6     //   C     25     0
#define _PTAHABER                 7     //   N     12     0
#define _FACTURA                  8     //   N      7     0
#define _BASEIMPO                 9     //   N     11     0
#define _IVA                     10     //   N      5     2
#define _RECEQUIV                11     //   N      5     2
#define _DOCUMENTO               12     //   C      6     0
#define _DEPARTA                 13     //   C      3     0
#define _CLAVE                   14     //   C      6     0
#define _ESTADO                  15     //   C      1     0
#define _NCASADO                 16     //   N      6     0
#define _TCASADO                 17     //   N      1     0
#define _TRANS                   18     //   N      6     0
#define _CAMBIO                  19     //   N     16     6
#define _DEBEME                  20     //   N     16     6
#define _HABERME                 21     //   N     16     6
#define _AUXILIAR                22     //   C      1     0
#define _SERIE                   23     //   C      1     0
#define _SUCURSAL                24     //   C      4     0
#define _CODDIVISA               25     //   C      1     0
#define _IMPAUXME                26     //   N     16     6
#define _MONEDAUSO               27     //   C      1     0
#define _EURODEBE                28     //   N     16     2
#define _EUROHABER               29     //   N     16     2
#define _BASEEURO                30     //   N     16     2
#define _NOCONV                  31     //   L      1     0
#define _NUMEROINV               32     //   C     10     0

#define _NLENSUBCTAA3            10

static cDiario
static cCuenta
static cEmpresa
static cDiarioSii
static cSubCuenta

static aLenSubCuenta             := {}

static cProyecto

static dFechaInicioEmpresa
static dFechaFinEmpresa

static lOpenDiario               := .f.
static lOpenSubCuenta            := .f.

static nAplicacionContable

static aSerie                    := {"A","B","C","D","E","F","G","H","I","J","K","M","N","O","P","O","R","S","T","U","V","W","X","Y","Z"}

static lAsientoIntraComunitario  := .f.

//----------------------------------------------------------------------------//

FUNCTION getDiarioDatabaseContaplus()     ; RETURN ( cDiario )
FUNCTION getDiarioSiiDatabaseContaplus()  ; RETURN ( cDiarioSii )
FUNCTION getCuentaDatabaseContaplus()     ; RETURN ( cCuenta )
FUNCTION getSubCuentaDatabaseContaplus()  ; RETURN ( cSubCuenta )
FUNCTION getEmpresaDatabaseContaplus()    ; RETURN ( cEmpresa )

//----------------------------------------------------------------------------//

FUNCTION ChkRuta( cRutaConta, lMessage )

   local lReturn     := .f.

   DEFAULT lMessage  := .f.

   if lAplicacionA3()
      Return .t.
   end if

   if lAplicacionSage()
      Return .t.
   end if

   if lAplicacionSage50()
      Return .t.
   end if

   if lAplicacionMonitor()
      Return .t.
   end if

   if empty( cRutaConta )
      Return .f.
   end if

   cRutaConta        := cPath( cRutaConta )

   if file( cRutaConta + "\CONTAPLW.EXE" )      .OR. ;
      file( cRutaConta + "\CONTAPLU.EXE" )      .OR. ;
      file( cRutaConta + "\CONTABILIDAD.EXE" )

      lReturn := .t.

   else

      if lMessage
         msgStop( "Ruta invalida, fichero Contaplus no encontrado" + CRLF + "en ruta " + cRutaConta + "." )
      end if

      lReturn        := .f.

   end if

RETURN lReturn

//----------------------------------------------------------------------------//

FUNCTION chkEmpresaAsociada( cCodigoEmpresa )

   if lAplicacionA3()
      Return ( .t. )
   end if 

   if lAplicacionSage()
      Return ( .t. )
   end if

   if lAplicacionSage50()
      Return ( .t. )
   end if

   if lAplicacionMonitor()
      Return ( .t. )
   end if

Return ( !empty( cCodigoEmpresa ) )

//----------------------------------------------------------------------------//
/*
Comprueba si la fecha esta dentro del margen contable
*/

FUNCTION ChkFecha( cRuta, cCodEmp, dFecha, lMessage, oTree, cText )

   local lClose      := .f.
   local lValidFecha := .t.

   DEFAULT cRuta     := cRutCnt()
   DEFAULT cCodEmp   := cEmpCnt()
   DEFAULT lMessage  := .f.
   DEFAULT cText     := Space( 1 )

   if lAplicacionA3()
      Return ( .t. )
   end if

   if lAplicacionSage()
      Return ( .t. )
   end if

   if lAplicacionSage50()
      Return ( .t. )
   end if

   if lAplicacionMonitor()
      Return ( .t. )
   end if 

   if empty( cRuta )
      Return ( .f. )
   end if

   if ( empty( dFecha ) .or. empty( cRuta ) )
      Return ( .t. )
   end if

   if empty( cEmpresa )
      cEmpresa       := OpnEmpresa( cRuta, lMessage )
      if empty( cEmpresa )
         return .f.
      else
         lClose      := .t.
      end if
   end if

   if ( cEmpresa )->( dbSeek( cCodEmp ) )

      dFechaInicioEmpresa  := ( cEmpresa )->FechaIni
      dFechaFinEmpresa     := ( cEmpresa )->FechaFin

   else

      lValidFecha          := .f.
      cText                += "Empresa no encontrada"

      if lMessage
         msgStop( cText )
      end if

   end if

   if lClose
      CloEmpresa()
   end if

   if lValidFecha

      if ( dFecha >= dFechaInicioEmpresa .and. dFecha <= dFechaFinEmpresa )

         lValidFecha       := .t.

      else

         cText             += " fecha del documento " + Dtoc( dFecha ) + " fuera de intervalo de empresa " + cCodEmp + " desde " + Dtoc( dFechaInicioEmpresa ) + " hasta " + Dtoc( dFechaFinEmpresa ) + "."

         if lMessage
            msgStop( cText )
         end if

         if !empty( oTree )
            oTree:Select( oTree:Add( Alltrim( cText ) ) )
         end if

         lValidFecha       := .f.

      end if

   end if

RETURN ( lValidFecha )

//----------------------------------------------------------------------------//

/*
Comprueba si existe la empresa en Contaplus
*/

FUNCTION ChkEmpresaContaplus( cRuta, cCodEmp, oGetEmp, lMessage )

   local lClose      := .f.
   local lEmpresa    := .t.

   DEFAULT cRuta     := cRutCnt()
   DEFAULT cCodEmp   := cEmpCnt()
   DEFAULT lMessage  := .f.

   if lAplicacionA3()
      Return ( .t. )
   end if

   if lAplicacionSage()
      Return ( .t. )
   end if

   if lAplicacionSage50()
      Return ( .t. )
   end if

   if lAplicacionMonitor()
      Return ( .t. )
   end if 

   if empty( cRuta )
      Return ( .f. )
   end if

   if empty( cCodEmp )
      if !empty( oGetEmp )
         oGetEmp:cText( "" )
      end if
      Return ( .f. )
   end if

   if empty( cEmpresa )
      cEmpresa       := OpnEmpresa( cRuta, lMessage )
      if empty( cEmpresa )
         Return ( .f. )
      else
         lClose      := .t.
      end if
   end if

   lEmpresa          := ( cEmpresa )->( dbSeek( cCodEmp ) )
   if lEmpresa
      if !empty( oGetEmp )
         oGetEmp:cText( ( cEmpresa )->Nombre )
      end if
   else
      if lMessage
         msgStop( "Empresa no encontrada" )
      end if
   end if

   if lClose
      CloEmpresa()
   end if

Return ( lEmpresa )

//----------------------------------------------------------------------------//

FUNCTION cEmpresaContaplus( cRuta, cCodEmp )

   local lClose      := .f.
   local cNbrEmp     := ""

   DEFAULT cRuta     := cRutCnt()
   DEFAULT cCodEmp   := cEmpCnt()

   if !lAplicacionContaplus()
      Return ( cNbrEmp )
   end if

   if empty( cRuta )
      Return ( cNbrEmp )
   end if

   if empty( cCodEmp )
      Return ( cNbrEmp )
   end if

   if empty( cEmpresa )
      cEmpresa       := OpnEmpresa( cRuta, .f. )
      if empty( cEmpresa )
         Return ( cNbrEmp )
      else
         lClose      := .t.
      end if
   end if

   if ( cEmpresa )->( dbSeek( cCodEmp ) )
      cNbrEmp        := ( cEmpresa )->Nombre
   else
      cNbrEmp        := ""
   end if

   if lClose
      CloEmpresa()
   end if

RETURN ( cNbrEmp )

//----------------------------------------------------------------------------//

FUNCTION BrwEmpresaContaplus( cRuta, oGetEmp ) 

   local oDlg
	local oBrw
	local oGet1
	local cGet1
   local lClose      := .f.
	local oCbxOrd
   local aCbxOrd     := { "Código", "Empresa" }
   local cCbxOrd     := "Código"

   if lAplicacionA3()
      msgStop( "Opción no disponible para A3CON Â®" )
      Return( nil )
   end if

   if lAplicacionSage()
      msgStop( "Opción no disponible para SAGE" )
      Return( nil )
   end if

   if lAplicacionSage50()
      msgStop( "Opción no disponible para SAGE 50" )
      Return( nil )
   end if   

   if lAplicacionMonitor()
      msgStop( "Opción no disponible para MONITOR INFORMÁTICA" )
      Return( nil )
   end if 

   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      return .f.
   end if

   if empty( cEmpresa )
      cEmpresa       := OpnEmpresa( cRuta, .t. )
      if empty( cEmpresa )
         return .f.
      else
         lClose      := .t.
      end if
   end if

   ( cEmpresa )->( dbGoTop() )

   DEFINE DIALOG oDlg RESOURCE "HELPENTRY" TITLE "Empresas de contaplus"

   REDEFINE GET         oGet1 ;
      VAR               cGet1 ;
      ID                104 ;
      ON CHANGE         ( AutoSeek( nKey, nFlags, Self, oBrw, cEmpresa ) );
      VALID             ( OrdClearScope( oBrw, cEmpresa ) );
      BITMAP            "Find" ;
      OF                oDlg

   REDEFINE COMBOBOX    oCbxOrd ;
      VAR               cCbxOrd ;
      ID                102 ;
      ITEMS             aCbxOrd ;
      OF                oDlg

   oBrw                 := IXBrowse():New( oDlg )

   oBrw:bClrSel         := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
   oBrw:bClrSelFocus    := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

   oBrw:cAlias          := cEmpresa
   oBrw:nMarqueeStyle   := 5
   oBrw:cName           := "Browse.Empresas contaplus"

      with object ( oBrw:AddCol() )
         :cHeader       := "Código"
         :cSortOrder    := "Cod"
         :bEditValue    := {|| ( cEmpresa )->Cod }
         :nWidth        := 60
         :bLClickHeader := {| nMRow, nMCol, nFlags, oCol | oCbxOrd:Set( oCol:cHeader ) }
      end with

      with object ( oBrw:AddCol() )
         :cHeader       := "Empresa"
         :cSortOrder    := "Nombre"
         :bEditValue    := {|| ( cEmpresa )->Nombre }
         :nWidth        := 420
         :bLClickHeader := {| nMRow, nMCol, nFlags, oCol | oCbxOrd:Set( oCol:cHeader ) }
      end with

   oBrw:CreateFromResource( 105 )

   oBrw:bLDblClick      := {|| oDlg:end( IDOK ) }
   oBrw:bKeyDown        := {|nKey, nFalg| if( nKey == VK_RETURN, oDlg:end( IDOK ), ) }

   REDEFINE BUTTON ;
      ID       500 ;
      OF       oDlg ;
      WHEN     ( .f. ) ;
      ACTION   ( nil )

   REDEFINE BUTTON ;
      ID       501 ;
      OF       oDlg ;
      WHEN     ( .f. ) ;
      ACTION   ( nil )

   REDEFINE BUTTON ;
      ID       IDOK ;
      OF       oDlg ;
      ACTION   ( oDlg:end( IDOK ) )

   REDEFINE BUTTON ;
      ID       IDCANCEL ;
      OF       oDlg ;
      CANCEL ;
      ACTION   ( oDlg:end() )

   oDlg:AddFastKey( VK_RETURN,   {|| oDlg:end( IDOK ) } )
   oDlg:AddFastKey( VK_F5,       {|| oDlg:end( IDOK ) } )

   ACTIVATE DIALOG oDlg CENTER

   if oDlg:nResult == IDOK .and. !empty( oGetEmp )
      oGetEmp:cText( ( cEmpresa )->Cod )
   end if

   if lClose
      CloEmpresa()
   end if

RETURN ( nil )

//----------------------------------------------------------------------------//
/*
Devuelve el numero de digitos de una subcuenta
*/

FUNCTION nLenSubcuenta( cRuta, cCodEmp, lMensaje )

Return ( nLenCuentaContaplus( cRuta, cCodEmp, lMensaje ) + 3 )

//----------------------------------------------------------------------------//

FUNCTION nLenCuentaContaplus( cRuta, cCodEmp, lMensaje )

   local nLenCuentaContaplus  := nLenSubcuentaContaplus( cRuta, cCodEmp, lMensaje )

   if nLenCuentaContaplus != 0
      nLenCuentaContaplus -= 3
   end if

Return ( nLenCuentaContaplus )

//----------------------------------------------------------------------------//

FUNCTION nLenSubcuentaContaplus( cRuta, cCodEmp, lMensaje )

   local lClose      := .f.
   local nReturn     := 0
   local nPosition   

   if lAplicacionA3()
      Return ( _NLENSUBCTAA3 )
   end if

   if lAplicacionSage()
      Return ( _NLENSUBCTAA3 )
   end if

   if lAplicacionSage50()
      Return ( _NLENSUBCTAA3 )
   end if

   if lAplicacionMonitor()
      Return ( _NLENSUBCTAA3 )
   end if    

   DEFAULT cRuta     := cRutCnt()
   DEFAULT cCodEmp   := cEmpCnt()
   DEFAULT lMensaje  := .f.

   nPosition         := aScan( aLenSubCuenta, {|a| a[ 1 ] == cCodEmp } )
   if nPosition != 0
      Return ( aLenSubCuenta[ nPosition, 2 ] )
   end if

   if empty( cRuta )
      if lMensaje
         msgStop( "Ruta vacia" )
      end if
      Return ( nReturn )
   end if

   if empty( cEmpresa )
      cEmpresa       := OpnEmpresa( cRuta, lMensaje )
      if empty( cEmpresa )
         Return ( nReturn )
      else
         lClose      := .t.
      end if
   end if

   if ( cEmpresa )->( dbSeek( cCodEmp ) )

      // Nivel de desglose menos 3 que es el numero de digitos de la cuenta----

      nReturn        := ( cEmpresa )->Nivel

      // AÃ±adimos los valoresa al buffer---------------------------------------

      aAdd( aLenSubCuenta, { cCodEmp, nReturn } )

   else

      if lMensaje
         MsgStop( "Empresa " + cCodEmp + " no encontrada." )
      end if

   end if

   if lClose
      CloEmpresa()
   end if

Return ( nReturn )

//----------------------------------------------------------------------------//

FUNCTION nEjercicioContaplus( cRuta, cCodEmp, lMensaje )

   local lClose      := .f.
   local nReturn     := 0

   DEFAULT cRuta     := cRutCnt()
   DEFAULT cCodEmp   := cEmpCnt()
   DEFAULT lMensaje  := .f.

   if empty( cRuta )
      if lMensaje
         msgStop( "Ruta vacia" )
      end if
      Return ( nReturn )
   end if

   if empty( cEmpresa )
      cEmpresa       := OpnEmpresa( cRuta, lMensaje )
      if empty( cEmpresa )
         Return ( nReturn )
      else
         lClose      := .t.
      end if
   end if

   if ( cEmpresa )->( dbSeek( cCodEmp ) )

      nReturn        := ( cEmpresa )->Ejercicio
      
   else

      if lMensaje
         MsgStop( "Empresa " + cCodEmp + " no encontrada." )
      end if

   end if

   if lClose
      CloEmpresa()
   end if

Return ( nReturn )

//----------------------------------------------------------------------------//

/*
Cheque la existencia de una cuenta en contaplus
*/

FUNCTION ChkCta( cCodCuenta, oGetCta, lMessage, cRuta, cCodEmp )

	local cArea
   local lOld        := .t.
   local lReturn     := .t.

   if lAplicacionA3()
      Return ( .t. )
   end if

   if lAplicacionSage()
      Return ( .t. )
   end if

   if lAplicacionSage50()
      Return ( .t. )
   end if

   if lAplicacionMonitor()
      Return ( .t. )
   end if

   DEFAULT lMessage  := .f.
   DEFAULT cCodEmp   := cEmpCnt( "A" )
   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      Return ( .f. )
   end if

   cRuta             := cPath( cRuta )

   if empty( cCodCuenta )
      Return .t.
   end if

   if OpnCta( cRuta, cCodEmp, @cArea, lMessage )

      if ( cArea )->( dbSeek( cCodCuenta ) )

         if oGetCta != nil

            do case
               case oGetCta:ClassName() == "TGET" .or. oGetCta:ClassName() == "TGETHLP"
                  oGetCta:cText( ( cArea )->Descrip )
               case oGetCta:ClassName() == "TSAY"
                  oGetCta:SetText( ( cArea )->Descrip )
            end case

         end if

      else

         if lMessage
            msgStop( "Cuenta no encontrada" )
         end if

			lReturn  := .f.

      end if

      CLOSE ( cArea )

   end if

RETURN lReturn

//----------------------------------------------------------------------------//

FUNCTION ChkSubcuenta( cRuta, cCodEmp, cCodSubcuenta, oGetCta, lMessage, lempty )

   local lClose      := .f.
   local lReturn     := .t.

   if lAplicacionA3()
      Return ( .t. )
   end if

   if lAplicacionSage()
      Return ( .t. )
   end if

   if lAplicacionSage50()
      Return ( .t. )
   end if

   if lAplicacionMonitor()
      Return ( .t. )
   end if

   DEFAULT cCodEmp   := cEmpCnt( "A" )
   DEFAULT lMessage  := .f.
   DEFAULT lempty    := .t.
   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      Return ( .f. )
   end if

   cRuta             := cPath( cRuta )
   cCodSubcuenta        := Padr( cCodSubcuenta, 12 )

   if ( empty( cCodSubcuenta ) .or. empty( cRuta ) ) .and. lempty
      return .t.
   end if

   if empty( cSubCuenta )
      cSubCuenta     := OpnSubCuenta( cRuta, cCodEmp, lMessage )
      if empty( cSubCuenta )
         return .f.
      else
         lClose      := .t.
      end if
   end if

   if ( cSubCuenta )->( dbSeek( cCodSubcuenta ) )

      if !empty( oGetCta )
         oGetCta:cText( ( cSubCuenta )->Titulo )
      end if

   else

      if lMessage
         msgStop( "Subcuenta : " + cCodSubcuenta + CRLF + "no encontrada", "Contaplus" )
      end if

      lReturn        := .f.

   end if

   if lClose
      CloSubCuenta()
   end if

RETURN ( lReturn )

//----------------------------------------------------------------------------//

FUNCTION BrwChkCta( oCodCta, oGetCta, cRuta, cCodEmp )

	local oDlg
	local oBrw
	local oGet1
	local cGet1
	local oCbxOrd
	local cArea
   local aCbxOrd     := { "Código", "Cuenta" }
   local cCbxOrd     := "Código"

   if lAplicacionA3()
      msgStop( "Opción no disponible para A3CON" )
      Return( nil )
   end if

   if lAplicacionSage()
      msgStop( "Opción no disponible para SAGE" )
      Return( nil )
   end if

   if lAplicacionSage50()
      msgStop( "Opción no disponible para SAGE 50" )
      Return( nil )
   end if

   if lAplicacionMonitor()
      msgStop( "Opción no disponible para MONITOR INFORMÁTICA" )
      Return( nil )
   end if 

   DEFAULT cCodEmp   := cEmpCnt()
   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      Return ( nil )
   end if

   cRuta             := cPath( cRuta )

   if OpnCta( cRuta, cCodEmp, @cArea, .t. )

      ( cArea )->( dbSetFilter( {|| !empty( Field->Cta ) }, "!empty( Field->Cta )" ) )
      ( cArea )->( dbGoTop() )

      DEFINE DIALOG oDlg RESOURCE "HELPENTRY" TITLE "Cuentas de contaplus"

		REDEFINE GET oGet1 VAR cGet1;
			ID 		104 ;
         ON CHANGE( AutoSeek( nKey, nFlags, Self, oBrw, cArea ) );
         VALID    ( OrdClearScope( oBrw, cArea ) );
         BITMAP   "FIND" ;
         OF       oDlg

		REDEFINE COMBOBOX oCbxOrd ;
			VAR 		cCbxOrd ;
			ID 		102 ;
         ITEMS    aCbxOrd ;
         OF       oDlg

      oBrw                 := IXBrowse():New( oDlg )

      oBrw:bClrSel         := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      oBrw:bClrSelFocus    := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      oBrw:cAlias          := cArea
      oBrw:nMarqueeStyle   := 5
      oBrw:cName           := "Browse.Cuenta contaplus"

         with object ( oBrw:AddCol() )
            :cHeader       := "Código"
            :cSortOrder    := "Cta"
            :bEditValue    := {|| ( cArea )->Cta }
            :nWidth        := 60
            :bLClickHeader := {| nMRow, nMCol, nFlags, oCol | oCbxOrd:Set( oCol:cHeader ) }
         end with

         with object ( oBrw:AddCol() )
            :cHeader       := "Cuenta"
            :cSortOrder    := "Descrip"
            :bEditValue    := {|| ( cArea )->Descrip }
            :nWidth        := 420
            :bLClickHeader := {| nMRow, nMCol, nFlags, oCol | oCbxOrd:Set( oCol:cHeader ) }
         end with

      oBrw:CreateFromResource( 105 )

      oBrw:bLDblClick      := {|| oDlg:end( IDOK ) }
      oBrw:bKeyDown        := {|nKey, nFalg| if( nKey == VK_RETURN, oDlg:end( IDOK ), ) }

      REDEFINE BUTTON ;
			ID 		500 ;
			OF 		oDlg ;
         WHEN     ( .f. ) ;
         ACTION   ( nil )

		REDEFINE BUTTON ;
			ID 		501 ;
			OF 		oDlg ;
         WHEN     ( .f. ) ;
         ACTION   ( nil )

      REDEFINE BUTTON ;
         ID       IDOK ;
			OF 		oDlg ;
         ACTION   ( oDlg:end(IDOK) )

		REDEFINE BUTTON ;
         ID       IDCANCEL ;
			OF 		oDlg ;
         CANCEL ;
         ACTION   ( oDlg:end() )

      oDlg:AddFastKey( VK_RETURN,   {|| oDlg:end( IDOK ) } )
      oDlg:AddFastKey( VK_F5,       {|| oDlg:end( IDOK ) } )

      ACTIVATE DIALOG oDlg CENTER

      if oDlg:nResult == IDOK

         oCodCta:cText( ( cArea )->Cta )

         do case
            case oGetCta:ClassName() == "TGET" .or. oGetCta:ClassName() == "TGETHLP"
               oGetCta:cText( ( cArea )->Descrip )
            case oGetCta:ClassName() == "TSAY"
               oGetCta:SetText( ( cArea )->Descrip )
         end case

      end if

		CLOSE ( cArea )

   end if

	oCodCta:setFocus()

RETURN ( nil )

//----------------------------------------------------------------------------//

FUNCTION BrwChkSubcuenta( oCodCta, oGetCta, cRuta, cCodEmp )

	local oDlg
	local oBrw
	local oGet1
	local cGet1
	local oCbxOrd
   local cArea
   local cCbxOrd     := "Cuenta"

   if lAplicacionA3()
      msgStop( "Opción no disponible para A3CON" )
      Return( nil )
   end if 

   if lAplicacionSage()
      msgStop( "Opción no disponible para SAGE" )
      Return( nil )
   end if

   if lAplicacionSage50()
      msgStop( "Opción no disponible para SAGE 50" )
      Return( nil )
   end if

   if lAplicacionMonitor()
      msgStop( "Opción no disponible para MONITOR INFORMÁTICA" )
      Return( nil )
   end if

   DEFAULT cCodEmp   := cEmpCnt( "A" )
   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      msgStop( "Ruta no definida" )
      Return ( nil )
   end if

   cRuta             := cPath( cRuta )

   if OpenSubCuenta( cRuta, cCodEmp, @cArea, .t. )

		( cArea )->( dbGoTop() )

      DEFINE DIALOG oDlg RESOURCE "HELPENTRY" TITLE "Subcuentas de contaplus"

			REDEFINE GET oGet1 VAR cGet1;
				ID 		104 ;
				ON CHANGE AutoSeek( nKey, nFlags, Self, oBrw, cArea ) ;
            BITMAP   "FIND" ;
            OF       oDlg

			REDEFINE COMBOBOX oCbxOrd ;
				VAR 		cCbxOrd ;
				ID 		102 ;
            ITEMS    { "Cuenta", "Nombre" } ;
            OF       oDlg

         oBrw                 := IXBrowse():New( oDlg )

         oBrw:bClrSel         := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
         oBrw:bClrSelFocus    := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

         oBrw:cAlias          := cArea
         oBrw:nMarqueeStyle   := 5
         oBrw:cName           := "Browse.Cuentas de contaplus"

         with object ( oBrw:AddCol() )
            :cHeader          := "Cuenta"
            :cSortOrder       := "Cods"
            :bEditValue       := {|| ( cArea )->Cod }
            :nWidth           := 80
            :bLClickHeader    := {| nMRow, nMCol, nFlags, oCol | oCbxOrd:Set( oCol:cHeader ) }
         end with

         with object ( oBrw:AddCol() )
            :cHeader          := "Nombre"
            :cSortOrder       := "Tits"
            :bEditValue       := {|| ( cArea )->Titulo }
            :nWidth           := 400
            :bLClickHeader    := {| nMRow, nMCol, nFlags, oCol | oCbxOrd:Set( oCol:cHeader ) }
         end with

         oBrw:bLDblClick      := {|| oDlg:end( IDOK ) }
         oBrw:bRClicked       := {| nRow, nCol, nFlags | oBrw:RButtonDown( nRow, nCol, nFlags ) }

         oBrw:CreateFromResource( 105 )

         REDEFINE BUTTON ;
            ID       500 ;
            OF       oDlg ;
            WHEN     ( .f. ) ;
            ACTION   ( nil )

         REDEFINE BUTTON ;
            ID       501 ;
            OF       oDlg ;
            WHEN     ( .f. ) ;
            ACTION   ( nil )

         REDEFINE BUTTON ;
            ID       IDOK ;
				OF 		oDlg ;
            ACTION   ( oDlg:end(IDOK) )

			REDEFINE BUTTON ;
            ID       IDCANCEL ;
				OF 		oDlg ;
            CANCEL ;
            ACTION   ( oDlg:end() )

         oDlg:AddFastKey( VK_F5,       {|| oDlg:end( IDOK ) } )
         oDlg:AddFastKey( VK_RETURN,   {|| oDlg:end( IDOK ) } )

         oDlg:bStart := {|| oBrw:Load() }

      ACTIVATE DIALOG oDlg CENTER

      if oDlg:nResult == IDOK

         oCodCta:cText( ( cArea )->Cod )

         do case
            case oGetCta:ClassName() == "TGET" .or. oGetCta:ClassName() == "TGETHLP"
               oGetCta:cText( ( cArea )->Titulo )
            case oGetCta:ClassName() == "TSAY"
               oGetCta:SetText( ( cArea )->Titulo )
         end case

      end if

		CLOSE ( cArea )

   else

      msgStop( "Imposible abrir ficheros de Contaplus")
      Return .f.

   end if

	oCodCta:setFocus()

Return ( nil )

//----------------------------------------------------------------------------//

/*
Crea una subcuenta en contaplus
*/

FUNCTION mkSubcuenta( oGetSubcuenta, aTemp, oGet, cRuta, cCodEmp, oGetDebe, oGetHaber, oGetSaldo )

   local n
   local cArea
   local nSumaDB        := 0
   local nSumaHB        := 0
   local cTitCta        := ""
   local aEmpProced     := {}
   local cCodSubcuenta  

   if lAplicacionA3()
      Return ( .t. )
   end if 

   if lAplicacionSage()
      Return( .t. )
   end if

   if lAplicacionSage50()
      Return( .t. )
   end if

   if lAplicacionMonitor()
      Return( .t. )
   end if

   DEFAULT cCodEmp      := cEmpCnt( "A" )
   DEFAULT cRuta        := cRutCnt()

   if empty( cRuta )
      Return ( .f. )
   end if

   cRuta                := cPath( cRuta )

   cCodSubcuenta        := pntReplace( oGetSubcuenta, "0", nLenSubcuenta() )
   cCodSubcuenta        := padr( cCodSubcuenta, nLenSubcuenta() )
   cCodSubcuenta        := alltrim( cCodSubcuenta )

   if empty( cCodSubcuenta )
      RETURN .t.
   end if 

   for n := 1 to len( aSerie )

      cCodEmp           := cCodEmpCnt( aSerie[ n ] )

      if !empty( cCodEmp ) .and. aScan( aEmpProced, cCodEmp ) == 0

         if OpenSubCuenta( cRuta, cCodEmp, @cArea )

            if !( cArea )->( dbSeek( cCodSubcuenta, .t. ) ) .and. !empty( aTemp )

               if ApoloMsgNoYes( "Subcuenta : " + rtrim( cCodSubcuenta ) + " no existe en empresa : " + cCodEmp + CRLF + ;
                                 "¿ Desea crearla ?" ,;
                                 "Contabilidad" )

                  ( cArea )->( dbappend() )

                  ( cArea )->Cod          := cCodSubcuenta

                  if ( cArea )->( fieldpos( "IDNIF" ) ) != 0
                     ( cArea )->idNif     := 1
                  end if

                  if len( aTemp ) > 1
                     ( cArea )->Titulo    := aTemp[ 2 ]
                  end if

                  if len( aTemp ) > 2
                     ( cArea )->Nif       := aTemp[ 3 ]
                  end if

                  if len( aTemp ) > 3
                     ( cArea )->Domicilio := aTemp[ 4 ]
                  end if

                  if len( aTemp ) > 4
                     ( cArea )->Poblacion := aTemp[ 5 ]
                  end if

                  if len( aTemp ) > 5
                     ( cArea )->Provincia := aTemp[ 6 ]
                  end if

                  if len( aTemp ) > 6
                     ( cArea )->CodPostal := aTemp[ 7 ]
                  end if

                  if len( aTemp ) > 7
                     ( cArea )->Telef01   := aTemp[ 8 ]
                  end if

                  if len( aTemp ) > 8
                     ( cArea )->Fax01     := aTemp[ 9 ]
                  end if

                  if len( aTemp ) > 9
                     ( cArea )->eMail     := aTemp[ 10 ]
                  end if

                  ( cArea )->( dbcommit() )

                  if empty( cTitCta )
                     cTitCta              := ( cArea )->Titulo
                  end if

               end if

            else

               if empty( cTitCta )
                  cTitCta                 := ( cArea )->Titulo
               end if

               nSumaDB                    += ( cArea )->SumaDBEU
               nSumaHB                    += ( cArea )->SumaHBEU

            end if

            CLOSE ( cArea )

            aAdd( aEmpProced, cCodEmp )

         end if

      end if

   next

   if isObject( oGet )
      do case
         case oGet:ClassName() == "TGET" .or. oGet:ClassName() == "TGETHLP"
            oGet:cText( cTitCta )
         case oGet:ClassName() == "TSAY"
            oGet:SetText( cTitCta )
      end case
   end if

   if isObject( oGetDebe )
      oGetDebe:cText( nSumaDB )
   end if 

   if isNum( oGetDebe )
      oGetDebe := nSumaDB
   end if

   if isObject( oGetHaber )
      oGetHaber:cText( nSumaHB )
   end if 

   if isNum( oGetHaber )
      oGetHaber := nSumaHB
   end if

   if isObject( oGetSaldo )
      oGetSaldo:cText( nSumaDB - nSumaHB )
   end if

Return .t.

//----------------------------------------------------------------------------//

FUNCTION LoadSubcuenta( cCodSubcuenta, cRuta, dbfTmp )

   local n
   local cCodEmp
   local dbfDiario
   local aEmpProced  := {}

   if lAplicacionA3()
      Return ( .t. )
   end if

   if lAplicacionSage()
      Return ( .t. )
   end if

   if lAplicacionSage50()
      Return ( .t. )
   end if

   if lAplicacionMonitor()
      Return ( .t. )
   end if

   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      Return .f.
   end if

   cRuta             := cPath( cRuta )

   ( dbfTmp )->( __dbZap() )

   if empty( AllTrim( cCodSubcuenta ) )
      return .t.
   end if

   for n := 1 to len( aSerie )

      cCodEmp        := cCodEmpCnt( aSerie[ n ] )

      if !empty( cCodEmp ) .and. aScan( aEmpProced, cCodEmp ) == 0

         dbfDiario   := OpnDiario( cRuta, cCodEmp, .f. )
         if dbfDiario != nil

            ( dbfDiario )->( OrdSetFocus( "SubCd" ) )

            if ( dbfDiario )->( dbSeek( cCodSubcuenta ) )

               while ( dbfDiario )->SubCta == cCodSubcuenta .and. !( dbfDiario )->( eof() )

                  ( dbfTmp )->( dbAppend() )

                  ( dbfTmp )->nAsiento  := ( dbfDiario )->Asien
                  ( dbfTmp )->dFecha    := ( dbfDiario )->Fecha
                  ( dbfTmp )->cConcepto := ( dbfDiario )->Concepto
                  ( dbfTmp )->nDebe     := ( dbfDiario )->EuroDebe
                  ( dbfTmp )->nHaber    := ( dbfDiario )->EuroHaber
                  ( dbfTmp )->cDeparta  := ( dbfDiario )->Departa + "." + ( dbfDiario )->Clave
                  ( dbfTmp )->nFactura  := ( dbfDiario )->Factura
                  ( dbfTmp )->nBase     := ( dbfDiario )->BaseEuro
                  ( dbfTmp )->nIva      := ( dbfDiario )->Iva

                  ( dbfDiario )->( dbSkip() )

               end while

            end if

         end if

         ( dbfDiario )->( dbCloseArea() )

         aAdd( aEmpProced, cCodEmp )

      end if

   next

   ( dbfTmp )->( dbGoTop() )

RETURN .T.

//----------------------------------------------------------------------------//
// Esta funciÂ¢n devuelve la cuenta Especial de Contaplus

FUNCTION RetCtaEsp( nCuenta, cRuta, cCodEmp, lMessage )

	local cArea
   local oBlock
	local cCtaEsp		:= ""

   if lAplicacionA3()
      Return ( cCtaEsp )
   end if

   if lAplicacionSage()
      Return ( cCtaEsp )
   end if

   if lAplicacionSage50()
      Return ( cCtaEsp )
   end if

   if lAplicacionMonitor()
      Return ( cCtaEsp )
   end if

	DEFAULT nCuenta	:= 1
   DEFAULT cCodEmp   := cEmpCnt( "A" )
   DEFAULT lMessage  := .f.
   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      RETURN ( cCtaEsp )
   end if

   cRuta             := cPath( cRuta )

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      do case
      case File( cRuta + "EMP" + cCodEmp + "\TCTA" + cCodEmp + ".DBF" )

         USE ( cRuta + "EMP" + cCodEmp + "\TCTA" + cCodEmp + ".DBF" ) NEW VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "CUENTA", @cArea ) )

      case File( cRuta + "EMP" + cCodEmp + "\TCTA.DBF" )

         USE ( cRuta + "EMP" + cCodEmp + "\TCTA.DBF" ) NEW VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "CUENTA", @cArea ) )

      end case

      ( cArea )->( dbgoto( nCuenta ) )

      cCtaEsp           := rtrim( ( cArea )->Cuenta )

   	CLOSE ( cArea )

   RECOVER

      if lMessage
         MsgStop( "Imposible acceder a fichero de empresas de Contaplus", "Abriendo fichero de cuentas especiales" )
      end if

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( cCtaEsp )

//----------------------------------------------------------------------------//

FUNCTION lOpenDiario()

Return ( lOpenDiario )

//----------------------------------------------------------------------------//

FUNCTION OpenDiario( cRuta, cCodEmp, lMessage )

   local oError
   local oBlock

   if lAplicacionA3()
      Return ( .t. )
   end if

   if lAplicacionSage()
      Return ( .t. )
   end if

   if lAplicacionSage50()
      Return ( .t. )
   end if

   if lAplicacionMonitor()
      Return ( .t. )
   end if

   DEFAULT cRuta     := cRutCnt()
   DEFAULT cCodEmp   := cEmpCnt()
   DEFAULT lMessage  := .f.

   if lOpenDiario
      Return ( lOpenDiario )
   end if

   if empty( cRuta )
      if lMessage
         MsgStop( "Ruta de contaplus no válida" )
      end if
      lOpenDiario    := .f.
      Return ( lOpenDiario )
   end if

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      lOpenDiario    := .t.
      cRuta          := cPath( cRuta )

      cDiario        := OpnDiario( cRuta, cCodEmp, lMessage )
      if empty( cDiario )
         lOpenDiario := .f.
      end if

      cCuenta        := OpnBalance( cRuta, cCodEmp, lMessage )
      if empty( cCuenta )
         lOpenDiario := .f.
      end if

      cSubCuenta     := OpnSubCuenta( cRuta, cCodEmp, lMessage )
      if empty( cSubCuenta )
         lOpenDiario := .f.
      end if

      cEmpresa       := OpnEmpresa( cRuta, lMessage )
      if empty( cEmpresa )
         lOpenDiario := .f.
      end if

      cDiarioSii     := OpnDiarioSii( cRuta, cCodEmp, lMessage )

   RECOVER USING oError

      lOpenDiario    := .f.

      msgStop( "Imposible abrir todas las bases de datos de contaplus" + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( lOpenDiario )

//----------------------------------------------------------------------------//

FUNCTION CloseDiario()

   if !empty( cDiario )
      ( cDiario )->( dbCloseArea() )
   end if

   if !empty( cCuenta )
      ( cCuenta )->( dbCloseArea() )
   end if

   if !empty( cSubCuenta )
      ( cSubCuenta )->( dbCloseArea() )
   end if

   if !empty( cEmpresa )
      ( cEmpresa )->( dbCloseArea() )
   end if

   if !empty( cDiarioSii )
      ( cDiarioSii )->( dbCloseArea() )
   end if 

   cDiario           := nil
   cCuenta           := nil
   cEmpresa          := nil
   cSubCuenta        := nil
   cDiarioSii        := nil

   lOpenDiario       := .f.

Return ( lOpenDiario )

//----------------------------------------------------------------------------//
// Esta funciÂ¢n devuelve el ultimo numero de asiento de Contaplus

FUNCTION contaplusUltimoAsiento()

   local nRecno
   local contaplusUltimoAsiento    := 0

   if lAplicacionA3()
      Return ( contaplusUltimoAsiento )
   end if

   if lAplicacionSage()
      Return ( contaplusUltimoAsiento )
   end if

   if lAplicacionSage50()
      Return ( contaplusUltimoAsiento )
   end if

   if lAplicacionMonitor()
      Return ( contaplusUltimoAsiento )
   end if

   if !empty( cDiario ) .and. ( cDiario )->( Used() )

      nRecno                        := ( cDiario )->( Recno() )

      ( cDiario )->( dbGoBottom() )

      contaplusUltimoAsiento       := ( cDiario )->Asien + 1

      ( cDiario )->( dbGoTo( nRecno ) )

   end if

Return ( contaplusUltimoAsiento )

//----------------------------------------------------------------------------//
/*
Realiza los asientos
*/

FUNCTION MkAsiento( 	Asien,;
                     cDivisa,;
							Fecha,;
							Subcuenta,;
							Contrapartida,;
                     nImporteDebe,;
							Concepto,;
                     nImporteHaber,;
							Factura,;
							BaseImponible,;
                     IVA,;
							RecargoEquivalencia,;
							Documento,;
							Departamento,;
							Clave,;
                     lRectificativa,;
							nCasado,;
							tCasado,;
                     lSimula,;
                     cNif,;
                     cNombre,;
                     nEjeCon,;
                     cEjeCta,;
                     lSII )

   local cSerie            := "A"
   local oError
   local oBlock
   local nImporte
   local aAsiento
   local hAsiento

   if lAplicacionA3()
      return .t.
   end if 

   if lAplicacionSage()
      return .t.
   end if

   if lAplicacionSage50()
      return .t.
   end if

   if lAplicacionMonitor()
      return .t.
   end if

   DEFAULT cDivisa         := cDivEmp()
   DEFAULT lRectificativa  := .f.
   DEFAULT lSimula         := .t.
   DEFAULT nImporteDebe    := 0
   DEFAULT nImporteHaber   := 0
   DEFAULT nEjeCon         := 0
   DEFAULT lSII            := .f.

   if ischar( Factura ) 
      cSerie               := substr( Factura, 1, 1 )
      if len( Factura ) <= 12
         Factura           := substr( Factura, 2, 9 )
      else
         Factura           := substr( Factura, 2, 10 )
      end if 
   end if

   if isnum( Factura )
      Factura              := alltrim( str( Factura ) )
   end if

   if Factura != nil
      Factura              := val( substr( Factura, -7 ) )
   end if

   if IsChar( nEjeCon )
      nEjeCon              := val( nEjeCon )
   end if

   /*
   Solo para bancas importes cero no pasa--------------------------------------
   */

   if lBancas() .and. ( nImporteDebe == 0  ) .and. ( nImporteHaber == 0 )
      return ( nil )
   end if

   oBlock                  := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      /*
      Importes en negativo--------------------------------------------------------
      */

      if !uFieldEmpresa( "lAptNeg" ) .and. ( nImporteDebe < 0 .or. nImporteHaber < 0 )
         nImporte          := abs( nImporteDebe )
         nImporteDebe      := abs( nImporteHaber )
         nImporteHaber     := nImporte
         if IsNum( BaseImponible )
            BaseImponible  := abs( BaseImponible )
         end if 
      end if

      /*
      Asignacion de campos--------------------------------------------------------
      */

      aAsiento             :=  MkAsientoContaplus( Asien,;
                                                   cDivisa,;
                                                   Fecha,;
                                                   Subcuenta,;
                                                   Contrapartida,;
                                                   nImporteDebe,;
                                                   Concepto,;
                                                   nImporteHaber,;
                                                   cSerie,;
                                                   Factura,;
                                                   BaseImponible,;
                                                   IVA,;
                                                   RecargoEquivalencia,;
                                                   Documento,;
                                                   Departamento,;
                                                   Clave,;
                                                   lRectificativa,;
                                                   nCasado,;
                                                   tCasado,;
                                                   lSimula,;
                                                   cNif,;
                                                   cNombre,;
                                                   nEjeCon,;
                                                   cEjeCta,;
                                                   lSII )   

   RECOVER USING oError

      msgStop( "Error al realizar apunte contable." + CRLF + ErrorMessage( oError ) )

   END SEQUENCE
   ErrorBlock( oBlock )

RETURN ( aAsiento )

//----------------------------------------------------------------------------//

Static FUNCTION MkAsientoContaplus( Asien,;
                                    cDivisa,;
                                    Fecha,;
                                    Subcuenta,;
                                    Contrapartida,;
                                    nImporteDebe,;
                                    Concepto,;
                                    nImporteHaber,;
                                    cSerie,;
                                    Factura,;
                                    BaseImponible,;
                                    IVA,;
                                    RecargoEquivalencia,;
                                    Documento,;
                                    Departamento,;
                                    Clave,;
                                    lRectificativa,;
                                    nCasado,;
                                    tCasado,;
                                    lSimula,;
                                    cNif,;
                                    cNombre,;
                                    nEjeCon,;
                                    cEjeCta,;
                                    lSII )

   local aTemp

   // Asignacion de campos--------------------------------------------------------

   aTemp                   := dbBlankRec( cDiario )

   aTemp[ ( cDiario )->( fieldpos( "ASIEN" ) ) ]         := if( Asien    != nil, Asien,      contaplusUltimoAsiento() )
   aTemp[ ( cDiario )->( fieldpos( "FECHA" ) ) ]         := if( Fecha    != nil, Fecha,      aTemp[ ( cDiario )->( fieldpos( "FECHA" ) ) ] )

   if ( cDiario )->( fieldpos( "FECHA_OP" ) ) != 0
      aTemp[ ( cDiario )->( fieldpos( "FECHA_OP" ) ) ]   := if( Fecha    != nil, Fecha,      aTemp[ ( cDiario )->( fieldpos( "FECHA_OP" ) ) ] )
   end if

   if ( cDiario )->( fieldpos( "FECHA_EX" ) ) != 0
      aTemp[ ( cDiario )->( fieldpos( "FECHA_EX" ) ) ]   := if( Fecha    != nil, Fecha,      aTemp[ ( cDiario )->( fieldpos( "FECHA_EX" ) ) ] )
   end if

   aTemp[ ( cDiario )->( fieldpos( "SERIE" ) ) ]         := if( cSerie   != nil, cSerie,     aTemp[ ( cDiario )->( fieldpos( "SERIE" ) ) ] )
   aTemp[ ( cDiario )->( fieldpos( "FACTURA" ) ) ]       := if( Factura  != nil, Factura,    aTemp[ ( cDiario )->( fieldpos( "FACTURA" ) ) ] )

   aTemp[ ( cDiario )->( fieldpos( "BASEEURO" ) ) ]      := if( BaseImponible != nil, BaseImponible,   aTemp[ ( cDiario )->( fieldpos( "BASEEURO" ) ) ] )
   aTemp[ ( cDiario )->( fieldpos( "EURODEBE" ) ) ]      := if( nImporteDebe  != nil, nImporteDebe,    aTemp[ ( cDiario )->( fieldpos( "EURODEBE" ) ) ] )
   aTemp[ ( cDiario )->( fieldpos( "EUROHABER" ) ) ]     := if( nImporteHaber != nil, nImporteHaber,   aTemp[ ( cDiario )->( fieldpos( "EUROHABER" ) ) ] )

   aTemp[ ( cDiario )->( fieldpos( "SUBCTA" ) ) ]        := if( Subcuenta   != nil, Subcuenta,     aTemp[ ( cDiario )->( fieldpos( "SUBCTA" ) ) ] )
   aTemp[ ( cDiario )->( fieldpos( "CONTRA" ) ) ]        := if( Contrapartida   != nil, Contrapartida,     aTemp[ ( cDiario )->( fieldpos( "CONTRA" ) ) ] )

   aTemp[ ( cDiario )->( fieldpos( "CONCEPTO" ) ) ]      := if( Concepto != nil, Concepto,   aTemp[ ( cDiario )->( fieldpos( "CONCEPTO" ) ) ] )

   aTemp[ ( cDiario )->( fieldpos( "IVA" ) )       ]     := if( IVA      != nil, IVA,        aTemp[ ( cDiario )->( fieldpos( "IVA" ) )        ] )
   aTemp[ ( cDiario )->( fieldpos( "RECEQUIV" ) )  ]     := if( RecargoEquivalencia != nil, RecargoEquivalencia,   aTemp[ ( cDiario )->( fieldpos( "RECEQUIV" ) )   ] )
   aTemp[ ( cDiario )->( fieldpos( "DOCUMENTO" ) ) ]     := if( Documento!= nil, Documento,  aTemp[ ( cDiario )->( fieldpos( "DOCUMENTO" ) )  ] )
   aTemp[ ( cDiario )->( fieldpos( "DEPARTA" ) )   ]     := if( Departamento != nil, Departamento,    aTemp[ ( cDiario )->( fieldpos( "DEPARTA" ) )    ] )
   aTemp[ ( cDiario )->( fieldpos( "CLAVE" ) )     ]     := if( Clave    != nil, Clave,      aTemp[ ( cDiario )->( fieldpos( "CLAVE" ) )      ] )
   aTemp[ ( cDiario )->( fieldpos( "NCASADO" ) )   ]     := if( nCasado  != nil, nCasado,    aTemp[ ( cDiario )->( fieldpos( "NCASADO" ) )    ] )
   aTemp[ ( cDiario )->( fieldpos( "TCASADO" ) )   ]     := if( tCasado  != nil, tCasado,    aTemp[ ( cDiario )->( fieldpos( "TCASADO" ) )    ] )

   if ( cDiario )->( fieldpos( "TERNIF" ) ) != 0
      aTemp[ ( cDiario )->( fieldpos( "TERNIF" ) ) ]     := if( cNif  != nil, cNif,    aTemp[ ( cDiario )->( fieldpos( "TERNIF" ) ) ] )
   end if

   if ( cDiario )->( fieldpos( "TERNOM" ) ) != 0
      aTemp[ ( cDiario )->( fieldpos( "TERNOM" ) ) ]     := if( cNombre  != nil, cNombre,    aTemp[ ( cDiario )->( fieldpos( "TERNOM" ) ) ] )
   end if

   aTemp[ ( cDiario )->( fieldpos( "RECTIFICA" ) ) ]     := lRectificativa

   // Para contaplus euro 2000----------------------------------------------------

   aTemp[ ( cDiario )->( fieldpos( "MONEDAUSO" ) ) ]     := "2"

   // Pagos en metalico-----------------------------------------------------------

   if !empty( nEjeCon ) .and. !empty( cEjeCta )

      if ( cDiario )->( fieldpos( "METAL" ) ) != 0
         aTemp[ ( cDiario )->( fieldpos( "METAL") ) ]       := .t.
      end if
      if ( cDiario )->( fieldpos( "METALIMP" ) ) != 0      
         aTemp[ ( cDiario )->( fieldpos( "METALIMP" ) ) ]   := if( nImporteDebe != nil,  nImporteDebe,  aTemp[ ( cDiario )->( fieldpos( "METALIMP" ) ) ] )      
      end if
      if ( cDiario )->( fieldpos( "METALEJE" ) ) != 0
         aTemp[ ( cDiario )->( fieldpos( "METALEJE") ) ]    := nEjeCon 
      end if

   end if 

   // Operaciones intracomunitarias--------------------------------------------

   if ( cDiario )->( fieldpos( "TipoOpe" ) ) != 0
      aTemp[ ( cDiario )->( fieldpos( "TipoOpe" ) ) ]    := if( getAsientoIntraComunitario(), "P", "" )
   end if

   if ( cDiario )->( fieldpos( "TERIDNIF" ) ) != 0
      aTemp[ ( cDiario )->( fieldpos( "TERIDNIF" ) ) ]   := if( getAsientoIntraComunitario(), 2, 1 )
   end if

   // Conectores GUID----------------------------------------------------------

   if ( cDiario )->( fieldpos( "Guid" ) ) != 0
      aTemp[ ( cDiario )->( fieldpos( "Guid" ) ) ]       := win_uuidcreatestring()
   end if

   // l340/lSII----------------------------------------------------------------

   if ( cDiario )->( fieldpos( "l340" ) ) != 0
      aTemp[ ( cDiario )->( fieldpos( "l340" ) ) ]       := .t.
   end if

   // timestamp----------------------------------------------------------------

   if ( cDiario )->( fieldpos( "cTimeStamp" ) ) != 0
      aTemp[ ( cDiario )->( fieldpos( "cTimeStamp" ) ) ] := hb_ttoc( hb_datetime() )
   end if

   // escritura en el fichero--------------------------------------------------
   /*
   if !lSimula
      
      WriteAsiento( aTemp, cDivisa )


      WriteAsientoSII( aTemp, cDivisa )

   end if
   */

Return ( aTemp )

//---------------------------------------------------------------------------//

FUNCTION aWriteAsiento( aAsientos, cDivisa, lMessage )

Return ( aeval( aAsientos, {|aAsiento| WriteAsiento( aAsiento, cDivisa, lMessage ) } ) )

//----------------------------------------------------------------------------//

FUNCTION WriteAsiento( aAsiento, cDivisa, lMessage )

   local cMes
   local nFld
   local nVal
   local oBlock
   local oError

   DEFAULT lMessage  := .f.

   if isFalse( runEventScript( "Contaplus\beforeWriteAsiento", aAsiento ) )
      debug( "isFalse" )
      Return .f.
   end if    

   if empty( cDiario )
      Return .f.
   end if 

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

   if !empty( aAsiento[ ( cDiario )->( fieldpos( "FECHA" ) ) ] )

      WinGather( aAsiento, , cDiario, , APPD_MODE, , .f. )

      cMes                          := Rjust( Month( aAsiento[ ( cDiario )->( fieldpos( "FECHA" ) ) ] ), "0", 2 )

      if ( cSubCuenta )->( dbSeek( aAsiento[ ( cDiario )->( fieldpos( "SubCta" ) ) ] ) ) .and. ( cSubCuenta )->( dbRLock() )

         ( cSubCuenta )->SUMADBEU   += aAsiento[ ( cDiario )->( fieldpos( "EURODEBE" ) ) ]
         ( cSubCuenta )->SUMAHBEU   += aAsiento[ ( cDiario )->( fieldpos( "EUROHABER" ) ) ]

         nFld        := ( cSubCuenta )->( fieldpos( "SDB" + cMes + "EU" ) )
         nVal        := ( cSubCuenta )->( fieldget( nFld ) )
         ( cSubCuenta )->( fieldput( nFld, nVal + aAsiento[ ( cDiario )->( fieldpos( "EURODEBE" ) ) ] ) )

         nFld        := ( cSubCuenta )->( fieldpos( "SHB" + cMes + "EU" ) )
         nVal        := ( cSubCuenta )->( fieldget( nFld ) )
         ( cSubCuenta )->( fieldput( nFld, nVal + aAsiento[ ( cDiario )->( fieldpos( "EUROHABER" ) ) ] ) )

         nFld        := ( cSubCuenta )->( fieldpos( "NDB" + cMes + "EU" ) )
         nVal        := ( cSubCuenta )->( fieldget( nFld ) )
         ( cSubCuenta )->( fieldput( nFld, nVal + aAsiento[ ( cDiario )->( fieldpos( "EURODEBE" ) ) ] ) )

         nFld        := ( cSubCuenta )->( fieldpos( "NHB" + cMes + "EU" ) )
         nVal        := ( cSubCuenta )->( fieldget( nFld ) )
         ( cSubCuenta )->( fieldput( nFld, nVal + aAsiento[ ( cDiario )->( fieldpos( "EUROHABER" ) ) ] ) )

         ( cSubCuenta )->( dbUnLock() )

      else

         if lMessage
            MsgStop( "Subcuenta no encontrada " + aAsiento[ ( cDiario )->( fieldpos( "SubCta" ) ) ], "Imposible actualizar saldos" )
         end if

      end if

   end if

   RECOVER USING oError

      msgStop( "Error al escribir apunte contable." + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( nil )

//----------------------------------------------------------------------------//

FUNCTION mkAsientoSII( aAsiento, nTipoFactura )

   local guid
   local aTemp

   if empty( cDiario )
      Return ( nil )
   end if

   if empty( cDiarioSii )
      Return ( nil )
   end if  

   if ( cDiario )->( fieldpos( "Guid" ) ) == 0
      Return ( nil )
   end if

   if ( cDiario )->( fieldpos( "l340" ) ) == 0
      Return ( nil )
   end if

   if aAsiento[( cDiario )->( fieldpos( "l340" ) ) ]
      Return ( nil )
   end if 

   guid                                                  := aAsiento[ ( cDiario )->( fieldpos( "Guid" ) ) ]
   if empty( guid )
      Return ( nil )
   end if 

   DEFAULT nTipoFactura                                  := 1

   // Asignacion de campos--------------------------------------------------------

   aTemp                                                 := dbBlankRec( cDiarioSii )

   aTemp[ ( cDiarioSii )->( fieldpos( "Guid" ) ) ]       := guid
   aTemp[ ( cDiarioSii )->( fieldpos( "Estado" ) ) ]     := 0
   aTemp[ ( cDiarioSii )->( fieldpos( "TipoClave" ) ) ]  := 1
   aTemp[ ( cDiarioSii )->( fieldpos( "TipoExenci" ) ) ] := 1
   aTemp[ ( cDiarioSii )->( fieldpos( "TipoNoSuje" ) ) ] := 1
   aTemp[ ( cDiarioSii )->( fieldpos( "TipoFact" ) ) ]   := nTipoFactura

Return ( aTemp )

//----------------------------------------------------------------------------//

FUNCTION aWriteAsientoSII( aAsientos )

Return ( aeval( aAsientos, {|aAsiento| WriteAsientoSII( aAsiento) } ) )

//----------------------------------------------------------------------------//

FUNCTION WriteAsientoSII( aAsiento )

   local oBlock
   local oError

   if empty( cDiarioSii )
      Return .f.
   end if 

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      WinGather( aAsiento, , cDiarioSii, , APPD_MODE, , .f. )

   RECOVER USING oError

      msgStop( "Error al escribir apunte contable SII." + CRLF + ErrorMessage( oError ) )

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( nil )

//----------------------------------------------------------------------------//

/*
Devuelve la cuenta de venta de un articulo
*/

FUNCTION retCtaVta( cCodArt, lDevolucion, dbfArticulo )

   local cCtaVta        := ""

   DEFAULT lDevolucion  := .f.

   if ( dbfArticulo )->( dbSeek( cCodArt ) )

      if lDevolucion
         cCtaVta        := rtrim( ( dbfArticulo )->cCtaVtaDev )
      end if 

      if empty( cCtaVta )
         cCtaVta        := rtrim( ( dbfArticulo )->cCtaVta )
      end if 
   
   end if

RETURN ( cCtaVta )

//--------------------------------------------------------------------------//

/*
Devuelve la cuenta de compra de un articulo
*/

FUNCTION RetCtaCom( cCodArt, lDevolucion, dbfArticulo )

   local cCtaCom        := ""

   DEFAULT lDevolucion  := .f.

   if ( dbfArticulo )->( dbSeek( cCodArt ) )

      if lDevolucion
         cCtaCom        := rtrim( ( dbfArticulo )->cCtaComDev )
      end if 

      if empty(cCtaCom)
         cCtaCom        := rtrim( ( dbfArticulo )->cCtaCom )
      end if 

   end if

RETURN ( cCtaCom )

//---------------------------------------------------------------------------//

FUNCTION RetCtaTrn( cCodArt, dbfArticulo )

   local cCtaVta  := uFieldEmpresa( "cCtaPor" )

   if ( dbfArticulo )->( dbSeek( cCodArt ) )
      cCtaVta     := Rtrim( ( dbfArticulo )->cCtaTrn )
   end if

RETURN ( cCtaVta )

//--------------------------------------------------------------------------//

/*
Devuelve el grupo de venta de un articulo
*/

FUNCTION RetGrpVta( cCodArt, cRuta, cCodEmp, nIva )

   local cCtaVent := replicate( "0", nLenCuentaContaplus( cRuta, cCodEmp ) )

   if nIva != nil
      cCtaVent    := retGrpAsc( nIva, , cRuta, cCodEmp ) // Devuelve el grupo asociado TIVA.PRG
   end if

RETURN ( cCtaVent )

//--------------------------------------------------------------------------//

FUNCTION cCtaConta( oGet, dbfCuentas, oGet2 )

	local lClose 	:= .F.
	local lValid	:= .F.
	local xValor	:= oGet:varGet()
   local cRuta    := cRutCnt()
   local cCodEmp  := cEmpCnt()

   if empty( xValor )
      Return .t.
   elseif At( ".", xValor ) != 0
      xValor      := PntReplace( oGet, "0", nLenCuentaContaplus() )
   else
      xValor      := RJustObj( oGet, "0", nLenCuentaContaplus() )
   end if

   if dbfCuentas == nil

      if OpenSubCuenta( cRuta, cCodEmp, @dbfCuentas )
         lClose   := .t.
      else
         return .f.
      end if

   end if

	IF !(dbfCuentas)->( DbSeek( xValor, .t. ) )

      oGet:cText( ( dbfCuentas )->Cod )

		IF oGet2 != nil
         oGet2:cText( ( dbfCuentas )->Titulo )
		END IF

		lValid	:= .T.

	ELSE

		msgStop( "Subcuentas no encontrada" )

	END IF

	IF lClose
      CLOSE ( dbfCuentas )
	END IF

RETURN lValid

//---------------------------------------------------------------------------//

/*
Abre el Fichero de Empresas
*/

STATIC FUNCTION OpnEmpresa( cRuta, lMessage )

   local oBlock

   DEFAULT lMessage  := .f.
   DEFAULT lMessage  := .f.
   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      return ( nil )
   end if

   cRuta             := cPath( cRuta )

   if !File( cRuta + "Emp\Empresa.Dbf" ) .or. !File( cRuta + "Emp\Empresa.Cdx" )
      if lMessage
         MsgStop( "Fichero de empresa de Contaplus " +  cRuta + "Emp\Empresa.Dbf, no encontrado", "Abriendo fichero de empresas" )
      end if
      Return ( nil )
   end if

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      USE ( cRuta + "EMP\EMPRESA.DBF" ) NEW VIA ( cLocalDriver() ) SHARED ALIAS ( cCheckArea( "EMPRESA", @cEmpresa ) )
      SET INDEX TO ( cRuta + "EMP\EMPRESA.CDX" )

   RECOVER

      cEmpresa       := nil

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( cEmpresa )

//--------------------------------------------------------------------------//

FUNCTION CloEmpresa()

   if !empty( cEmpresa )
      ( cEmpresa )->( dbCloseArea() )
   end if

   cEmpresa          := nil

Return ( cEmpresa )

//--------------------------------------------------------------------------//
/*
Abre el fichero de Cuentas
*/

STATIC FUNCTION OpnCta( cRuta, cCodEmp, cArea, lMessage )

   local oBlock
   local lOpen       := .t.

   DEFAULT cRuta     := cRutCnt()
   DEFAULT lMessage  := .f.

   if empty( cRuta )
      return .f.
   end if

   cRuta             := cPath( cRuta )
   cCodEmp           := alltrim( cCodEmp )

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      if File( cRuta + "EMP" + cCodEmp + "\Balan.Dbf" )  .and.;
         File( cRuta + "EMP" + cCodEmp + "\Balan.Cdx" )

         USE ( cRuta + "EMP" + cCodEmp + "\Balan.Dbf" ) NEW SHARED VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "CUENTA", @cArea ) )
         SET INDEX TO ( cRuta + "EMP" + cCodEmp + "\Balan.Cdx" )
   		SET TAG TO "CTA"

      else

         if lMessage
            msgStop( "Ficheros no encontrados en ruta " + cRuta + " empresa " + cCodEmp, "Abriendo subcuentas" )
         end if

         lOpen          := .f.

      end if

      if ( cArea )->( RddName() ) == nil .or. NetErr()
         lOpen          := .f.
      end if

   RECOVER

      if lMessage
         msgStop( "Imposible acceder a fichero Contaplus", "Abriendo subcuentas" )
      end if
      lOpen          := .f.

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( lOpen )

//--------------------------------------------------------------------------//
/*
Abre fichero de Subcuentas
*/

FUNCTION OpenSubCuenta( cRuta, cCodEmp, cArea, lMessage )

   local oBlock
   local lOpen       := .t.

   if lAplicacionA3()
      msgStop( "Opción no disponible para A3CON" )
      Return ( .f. )
   end if

   if lAplicacionSage()
      msgStop( "Opción no disponible para SAGE" )
      Return ( .f. )
   end if

   if lAplicacionSage50()
      msgStop( "Opción no disponible para SAGE 50" )
      Return ( .f. )
   end if

   if lAplicacionMonitor()
      msgStop( "Opción no disponible para MONITOR INFORMÁTICA" )
      Return ( .f. )
   end if 

   DEFAULT cRuta     := cRutCnt()
   DEFAULT cCodEmp   := cEmpCnt()   
   DEFAULT lMessage  := .f.

   if empty( cRuta )
      msgStop( "Ruta de Contaplus esta vacia")
      Return ( .f. )
   end if

   cRuta             := cPath( cRuta )
   cCodEmp           := alltrim( cCodEmp )

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      if File( cRuta + "EMP" + cCodEmp + "\SubCta.Dbf" ) .and. ;
         File( cRuta + "EMP" + cCodEmp + "\SubCta.Cdx" ) 

         USE ( cRuta + "EMP" + cCodEmp + "\SubCta.Dbf" ) NEW SHARED VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "CUENTA", @cArea ) )
         SET INDEX TO ( cRuta + "EMP" + cCodEmp + "\SubCta.Cdx" ) ADDITIVE

      else

         if lMessage
            msgStop( "Ficheros no encontrados", "Abriendo subcuentas" )
         end if

         lOpen       := .f.

      end if

      if ( cArea )->( RddName() ) == nil .or. NetErr()
         if lMessage
            MsgStop( "Imposible acceder a fichero Contaplus", "Abriendo subcuentas" )
         end if
         lOpen       := .f.
      end if

   RECOVER

      if lMessage
         MsgStop( "Imposible acceder a fichero Contaplus", "Abriendo subcuentas" )
      end if
      lOpen          := .f.

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( lOpen )

//--------------------------------------------------------------------------//

FUNCTION OpenVencimientos( cRuta, cCodEmp, cArea, lMessage )

   local oBlock
   local lOpen       := .t.

   DEFAULT cRuta     := cRutCnt()
   DEFAULT cCodEmp   := cEmpCnt()   
   DEFAULT lMessage  := .f.

   if empty( cRuta )
      msgStop( "Ruta de Contaplus esta vacia")
      Return ( .f. )
   end if

   cRuta             := cPath( cRuta )
   cCodEmp           := alltrim( cCodEmp )

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      if File( cRuta + "EMP" + cCodEmp + "\Venci.Dbf" ) .and. ;
         File( cRuta + "EMP" + cCodEmp + "\Venci.Cdx" ) 

         USE ( cRuta + "EMP" + cCodEmp + "\Venci.Dbf" ) NEW SHARED VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "Venci", @cArea ) )
         SET INDEX TO ( cRuta + "EMP" + cCodEmp + "\Venci.Cdx" ) ADDITIVE

      else

         if lMessage
            msgStop( "Ficheros no encontrados", "Abriendo vencimientos" )
         end if

         lOpen       := .f.

      end if

      if ( cArea )->( RddName() ) == nil .or. NetErr()
         if lMessage
            MsgStop( "Imposible acceder a fichero Contaplus", "Abriendo vencimientos" )
         end if
         lOpen       := .f.
      end if

   RECOVER

      if lMessage
         MsgStop( "Imposible acceder a fichero de vencimientos Contaplus", "Abriendo vencimientos" )
      end if
      lOpen          := .f.

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( lOpen )

//--------------------------------------------------------------------------//

FUNCTION MsgTblCon( aTable, cDivisa, dbfDiv, lConAsi, cTitle, bConta )

   local oDlg
	local oBrw
   local oBtnCon
   local cPorDiv           := cPorDiv( cDivisa, dbfDiv )

   DEFAULT lConAsi         := .f.
   DEFAULT cTitle          := ""

   if !IsArray( aTable ) .or. len( aTable ) < 1
      return nil
   end if

   DEFINE DIALOG oDlg RESOURCE "CONTA" TITLE "Simulador de asientos." + Space( 1 ) + cTitle

   oBrw                    := IXBrowse():New( oDlg )

   oBrw:bClrSel            := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
   oBrw:bClrSelFocus       := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

   oBrw:SetArray( aTable, , , .f. )

   oBrw:lFooter            := .t.
   oBrw:nMarqueeStyle      := 5
   oBrw:cName              := "Simulador de asientos"

   oBrw:CreateFromResource( 100 )

      with object ( oBrw:AddCol() )
         :cHeader          := "Asiento"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "Asien" ) ) ] }
         :nWidth           := 50
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Fecha"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "Fecha" ) ) ] }
         :nWidth           := 70
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Subcuenta"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "SubCta" ) ) ] }
         :nWidth           := 80
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Contapartida"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "Contra" ) ) ] }
         :nWidth           := 80
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Debe"
         :bEditValue       := {|| if( .t. , aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "EuroDebe" ) ) ], aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "PtaDebe" ) ) ] ) }
         :bFooter          := {|| nTotDebe( aTable, cDivisa ) }
         :cEditPicture     := cPorDiv
         :nWidth           := 70
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
         :nFootStrAlign    := 1
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Concepto"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "Concepto" ) ) ] }
         :nWidth           := 170
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Haber"
         :bEditValue       := {|| if( .t., aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "EuroHaber" ) ) ], aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "PtaHaber" ) ) ] ) }
         :bFooter          := {|| nTotHaber( aTable, cDivisa ) }
         :cEditPicture     := cPorDiv
         :nWidth           := 70
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
         :nFootStrAlign    := 1
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Serie"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "Serie" ) ) ] }
         :nWidth           := 20
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Factura"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "Factura" ) ) ] }
         :nWidth           := 80
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Base imponible"
         :bEditValue       := {|| if( .t. , aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "BaseEuro" ) ) ], aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "BaseImponible" ) ) ] ) }
         :cEditPicture     := cPorDiv
         :nWidth           := 80
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := cImp()
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "IVA" ) ) ] }
         :cEditPicture     := cPorDiv
         :nWidth           := 80
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "R.E."
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "RecargoEquivalencia" ) ) ] }
         :cEditPicture     := cPorDiv
         :nWidth           := 80
         :nDataStrAlign    := 1
         :nHeadStrAlign    := 1
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Documento"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "Documento" ) ) ] }
         :nWidth           := 100
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Departamento"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "Departamento" ) ) ] }
         :nWidth           := 40
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Clave"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "Clave" ) ) ] }
         :nWidth           := 60
      end with

      with object ( oBrw:AddCol() )
         :cHeader          := "Estado"
         :bEditValue       := {|| aTable[ oBrw:nArrayAt, ( cDiario )->( fieldpos( "Estado" ) ) ] }
         :nWidth           := 40
      end with

      oBrw:bLDblClick      := {|| oDlg:end( IDOK ) }

      REDEFINE BUTTON oBtnCon ;
         ID       110 ;
			OF 		oDlg ;
         ACTION   ( if( !empty( bConta ), Eval( bConta ), ), oDlg:end() )

      REDEFINE BUTTON ;
         ID       120 ;
			OF 		oDlg ;
         ACTION   ( oDlg:end( IDOK ) )

		REDEFINE BUTTON ;
         ID       IDOK ;
			OF 		oDlg ;
         CANCEL ;
         ACTION   ( oDlg:end() )

      oDlg:AddFastKey( VK_F5, {|| if( !empty( bConta ), Eval( bConta ), ), oDlg:end() } )

      oDlg:bStart          := {|| if( !lConAsi .or. empty( bConta ), oBtnCon:Hide(), ) }

	ACTIVATE DIALOG oDlg CENTER

RETURN ( oDlg:nResult == IDOK )

//-------------------------------------------------------------------------//

FUNCTION nTotDebe( aTable, cDivisa, cPorDiv )

   local nTotal      := 0
   local oError
   local oBlock

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

   if !empty( aTable )

   if .t. // cDivisa == "EUR"
      aEval( aTable, {|x| nTotal += if( valType( x[ ( cDiario )->( fieldpos( "EURODEBE" ) ) ] ) == "N", x[ ( cDiario )->( fieldpos( "EURODEBE" ) ) ], 0 ) } )
   else
      aEval( aTable, {|x| nTotal += if( valType( x[ ( cDiario )->( fieldpos( "PTADEBE" ) ) ] ) == "N", x[ ( cDiario )->( fieldpos( "PTADEBE" ) ) ], 0 ) } )
   end if

   end if

   RECOVER USING oError

   END SEQUENCE

   ErrorBlock( oBlock )

return ( if( empty( cPorDiv ), nTotal, Trans( nTotal, cPorDiv ) ) )

//-------------------------------------------------------------------------//

FUNCTION nTotHaber( aTable, cDivisa, cPorDiv )

   local nTotal   := 0
   local oError
   local oBlock

   oBlock            := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

   if .t. // cDivisa == "EUR"
      aEval( aTable, {|x| nTotal += if( valType( x[ ( cDiario )->( fieldpos( "EUROHABER" ) ) ] ) == "N", x[ ( cDiario )->( fieldpos( "EUROHABER" ) ) ], 0 ) } )
   else
      aEval( aTable, {|x| nTotal += if( valType( x[ ( cDiario )->( fieldpos( "PTAHABER" ) ) ] ) == "N", x[ ( cDiario )->( fieldpos( "PTAHABER" ) ) ], 0 ) } )
   end if

   RECOVER USING oError

   END SEQUENCE

   ErrorBlock( oBlock )

return ( if( empty( cPorDiv ), nTotal, Trans( nTotal, cPorDiv ) ) )

//-------------------------------------------------------------------------//

FUNCTION BrwProyecto( oCodPro, oGetPro, cRuta, cCodEmp )

	local oDlg
	local oBrw
   local oAdd
   local oEdt
	local oGet1
	local cGet1
	local oCbxOrd
	local cCbxOrd		:= "Nombre"
	local cAreaAnt 	:= Alias()

   if lAplicacionA3()
      msgStop( "Opción no disponible para A3CON" )
      Return( nil )
   end if 

   if lAplicacionSage()
      msgStop( "Opción no disponible para SAGE" )
      Return ( .f. )
   end if

   if lAplicacionSage50()
      msgStop( "Opción no disponible para SAGE 50" )
      Return ( .f. )
   end if

   if lAplicacionMonitor()
      msgStop( "Opción no disponible para MONITOR INFORMÁTICA" )
      Return ( .f. )
   end if

   DEFAULT cCodEmp   := cEmpCnt( "A" )
   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      return .f.
   end if

   cRuta             := cPath( cRuta )

   IF OpnProyecto( cRuta, cCodEmp )

      ( cProyecto )->( dbGoTop() )

      DEFINE DIALOG oDlg RESOURCE "HELPENTRY" TITLE "Proyectos de contaplus®"

		REDEFINE GET oGet1 VAR cGet1;
			ID 		104 ;
         ON CHANGE AutoSeek( nKey, nFlags, Self, oBrw, cProyecto ) ;
         BITMAP   "FIND" ;
         OF       oDlg

		REDEFINE COMBOBOX oCbxOrd ;
			VAR 		cCbxOrd ;
			ID 		102 ;
         ITEMS    { "Código", "Proyecto" } ;
			OF oDlg

      oBrw                 := IXBrowse():New( oDlg )

      oBrw:bClrSel         := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      oBrw:bClrSelFocus    := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      oBrw:cAlias          := cProyecto
      oBrw:nMarqueeStyle   := 5
      oBrw:cName           := "Browse.Proyectos de contaplus"

         with object ( oBrw:AddCol() )
            :cHeader       := "Código"
            :cSortOrder    := "Proye"
            :bEditValue    := {|| ( cProyecto )->Proye }
            :cEditPicture  := "@R ####.######"
            :nWidth        := 80
            :bLClickHeader := {| nMRow, nMCol, nFlags, oCol | oCbxOrd:Set( oCol:cHeader ) }
         end with

         with object ( oBrw:AddCol() )
            :cHeader       := "Proyecto"
            :cSortOrder    := "Descrip"
            :bEditValue    := {|| ( cProyecto )->Descrip }
            :nWidth        := 260
            :bLClickHeader := {| nMRow, nMCol, nFlags, oCol | oCbxOrd:Set( oCol:cHeader ) }
         end with

      oBrw:CreateFromResource( 105 )

      oBrw:bLDblClick      := {|| oDlg:end( IDOK ) }
      oBrw:bKeyDown        := {|nKey, nFalg| if( nKey == VK_RETURN, oDlg:end( IDOK ), ) }

      REDEFINE BUTTON oAdd;
         ID       500 ;
         OF       oDlg ;
         ACTION   ( nil )

      REDEFINE BUTTON oEdt;
         ID       501 ;
         OF       oDlg ;
         ACTION   ( nil )

		REDEFINE BUTTON ;
         ID       IDOK ;
			OF 		oDlg ;
         ACTION   ( oDlg:end( IDOK ) )

		REDEFINE BUTTON ;
         ID       IDCANCEL ;
			OF 		oDlg ;
         CANCEL ;
         ACTION   ( oDlg:end() )

      ACTIVATE DIALOG oDlg CENTER ON INIT ( oAdd:Hide(), oEdt:Hide() )

      IF oDlg:nResult == IDOK

         oCodPro:cText( ( cProyecto )->Proye )

         IF ValType( oGetPro ) == "O"
            oGetPro:cText( ( cProyecto )->Descrip )
			END IF

		END IF

      CloseProyecto()

	END IF

	IF cAreaAnt != ""
		SELECT( cAreaAnt )
	END IF

   oCodPro:setFocus()

RETURN ( nil )

//----------------------------------------------------------------------------//

FUNCTION ChkProyecto( cCodPro, oGetPro, cRuta, cCodEmp, lMessage )

   local cNombreProyecto   := ""

   DEFAULT cRuta           := cRutCnt()
   DEFAULT cCodEmp         := cEmpCnt()
   DEFAULT lMessage        := .f.

   if empty( cRuta )
      return ( cNombreProyecto )
   end if

   cRuta                   := cPath( cRuta )

   if empty( cCodPro ) .OR. empty( cRuta )
      return ( cNombreProyecto )
   end if

   if OpnProyecto( cRuta, cCodEmp )

      if ( cProyecto )->( dbSeek( cCodPro ) )

         cNombreProyecto   := ( cProyecto )->Descrip

      else

         if lMessage
            msgStop( "Proyecto : " + cCodPro + CRLF + "no encontrada", "Contaplus" )
         end if

      end if

      if !empty( oGetPro )
         oGetPro:cText( cNombreProyecto )
      end if

      CloseProyecto()

   end if

Return ( cNombreProyecto )

//----------------------------------------------------------------------------//

FUNCTION OpnProyecto( cRuta, cCodEmp )

   local lRet        := .f.

   DEFAULT cCodEmp   := cEmpCnt()
   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      return .f.
   end if

   cRuta             := cPath( cRuta )

   do case
   case File( cRuta + "EMP" + cCodEmp + "\PROYEC" + cCodEmp + ".CDX" )

		/*
		Contaplus nuevo
		*/

      USE ( cRuta + "EMP" + cCodEmp + "\PROYEC" + cCodEmp + ".DBF" ) NEW VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "PROYEC", @cProyecto ) )
      SET INDEX TO ( cRuta + "EMP" + cCodEmp + "\PROYEC" + cCodEmp + ".CDX" )

      IF ( cProyecto )->( RddName() ) == nil .or. NetErr()
         MsgStop( "Imposible acceder a fichero Contaplus", "Abriendo fichero de proyecto" )
         lRet  := .f.
      ELSE
         lRet  := .t.
      END IF

   case File( cRuta + "EMP" + cCodEmp + "\PROYEC.CDX" )

		/*
		Contaplus primavera
		*/

      USE ( cRuta + "EMP" + cCodEmp + "\PROYEC.DBF" ) NEW VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "PROYEC", @cProyecto ) )
      SET INDEX TO ( cRuta + "EMP" + cCodEmp + "\PROYEC.CDX" )

      IF ( cProyecto )->( RddName() ) == nil .or. NetErr()
         MsgStop( "Imposible acceder a fichero Contaplus", "Abriendo fichero de proyecto" )
         lRet  := .f.
      ELSE
         lRet  := .t.
      END IF

   END case

RETURN lRet

//----------------------------------------------------------------------------//

FUNCTION CloseProyecto()

   ( cProyecto  )->( dbCloseArea() )

RETURN nil

//----------------------------------------------------------------------------//

FUNCTION cCodEmpCnt( cSer )

   local cCodEmp  := ""

   DEFAULT cSer   := "A"

   cCodEmp        := cEmpCnt( cSer )

RETURN ( cCodEmp )

//---------------------------------------------------------------------------//

FUNCTION dbfDiario() ; return ( cDiario )

//---------------------------------------------------------------------------//

FUNCTION dbfCuenta() ; return ( cCuenta )

//---------------------------------------------------------------------------//

FUNCTION dbfSubcuenta() ; return ( cSubCuenta )

//---------------------------------------------------------------------------//

FUNCTION dbfProyecto() ; return ( cProyecto )

//---------------------------------------------------------------------------//

FUNCTION OpnDiario( cRuta, cCodEmp, lMessage )

   local oBlock
   local dbfDiario      := nil

   DEFAULT cRuta        := cRutCnt()
   DEFAULT cCodEmp      := cEmpCnt()
   DEFAULT lMessage     := .f.

   if empty( cRuta )
      if lMessage
         MsgStop( "Ruta de Contaplus Â® no valida" )
      end if
      Return nil
   end if

   cRuta                := cPath( cRuta )
   cCodEmp              := alltrim( cCodEmp )

   oBlock               := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      if File( cRuta + "EMP" + cCodEmp + "\DIARIO.CDX" )

         USE ( cRuta + "EMP" + cCodEmp + "\DIARIO.DBF" ) NEW SHARED VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "DIARIO", @dbfDiario ) )
         SET INDEX TO ( cRuta + "EMP" + cCodEmp + "\DIARIO.CDX" ) ADDITIVE
         SET TAG TO "NUASI"

         if ( dbfDiario )->( RddName() ) == nil .or. ( dbfDiario )->( NetErr() )

            if lMessage
               msgStop( "Imposible abrir las bases de datos del diario de Contaplus Â®" )
            end if

            dbfDiario   := nil

         end if

      else

         if lMessage
            msgStop( "Ficheros no encontrados en ruta " + cRuta + " empresa " + cCodEmp, "Abriendo diario" )
         end if

         dbfDiario      := nil

      end if

   RECOVER

      msgStop( "Imposible abrir las bases de datos del diario de Contaplus Â®" )

      dbfDiario         := nil

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( dbfDiario )

//----------------------------------------------------------------------------//

FUNCTION OpnDiarioSii( cRuta, cCodEmp, lMessage )

   local oBlock
   local dbfDiarioSii   := nil

   DEFAULT cRuta        := cRutCnt()
   DEFAULT cCodEmp      := cEmpCnt()
   DEFAULT lMessage     := .f.

   if empty( cRuta )
      if lMessage
         MsgStop( "Ruta de Contaplus Â® no valida" )
      end if
      Return nil
   end if

   cRuta                := cPath( cRuta )
   cCodEmp              := alltrim( cCodEmp )

   oBlock               := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      if File( cRuta + "EMP" + cCodEmp + "\DIARIOF.CDX" )

         USE ( cRuta + "EMP" + cCodEmp + "\DIARIOF.DBF" ) NEW SHARED VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "DIARIO", @dbfDiarioSii ) )
         SET INDEX TO ( cRuta + "EMP" + cCodEmp + "\DIARIOF.CDX" ) ADDITIVE
         SET TAG TO "NUASI"

         if ( dbfDiarioSii )->( RddName() ) == nil .or. ( dbfDiarioSii )->( NetErr() )

            if lMessage
               msgStop( "Imposible abrir las bases de datos del diario de Contaplus Â®" )
            end if

            dbfDiarioSii   := nil

         end if

      else

         if lMessage
            msgStop( "Ficheros no encontrados en ruta " + cRuta + " empresa " + cCodEmp, "Abriendo diario" )
         end if

         dbfDiarioSii      := nil

      end if

   RECOVER

      msgStop( "Imposible abrir las bases de datos del diario de Contaplus Â®" )

      dbfDiarioSii         := nil

   END SEQUENCE

   ErrorBlock( oBlock )

Return ( dbfDiarioSii )

//----------------------------------------------------------------------------//

FUNCTION OpnBalance( cRuta, cCodEmp, lMessage )

   local dbfBalance

   DEFAULT cCodEmp   := cEmpCnt( "A" )
   DEFAULT lMessage  := .f.
   DEFAULT cRuta     := cRutCnt()

   if empty( cRuta )
      if lMessage
         MsgStop( "Ruta de Contaplus no valida" )
      end if
      Return nil
   end if

   cRuta             := cPath( cRuta )
   cCodEmp           := alltrim( cCodEmp )

   if file( cRuta + "EMP" + cCodEmp + "\Balan.Dbf" ) .and. ;
      file( cRuta + "EMP" + cCodEmp + "\Balan.Cdx" )

      USE ( cRuta + "EMP" + cCodEmp + "\Balan.Dbf" ) NEW SHARED VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "BALAN", @dbfBalance ) )
      SET INDEX TO ( cRuta + "EMP" + cCodEmp + "\Balan.Cdx" )
		SET TAG TO "CTA"

   else

      if lMessage
         msgStop( "Ficheros no encontrados en ruta " + cRuta + " empresa " + cCodEmp, "Abriendo balances" )
      end if

      Return nil

   end if

   if ( dbfBalance )->( RddName() ) == nil .or. NetErr()
      if lMessage
         msgStop( "Imposible acceder a fichero Contaplus", "Abriendo balances" )
      end if
      Return nil
   end if

Return ( dbfBalance )

//----------------------------------------------------------------------------//

FUNCTION OpnSubCuenta( cRuta, cCodEmp, lMessage )

   local dbfSubcuenta

   DEFAULT cRuta     := cRutCnt()
   DEFAULT cCodEmp   := cEmpCnt()
   DEFAULT lMessage  := .f.

   if empty( cRuta )
      if lMessage
         MsgStop( "Ruta de Contaplus Â® no valida" )
      end if
      Return nil
   end if

   cRuta             := cPath( cRuta )
   cCodEmp           := alltrim( cCodEmp )

   if file( cRuta + "EMP" + cCodEmp + "\SubCta.Dbf" ) .and. ;
      file( cRuta + "EMP" + cCodEmp + "\SubCta.Cdx" )

      USE ( cRuta + "EMP" + cCodEmp + "\SubCta.Dbf" ) NEW SHARED VIA ( cLocalDriver() ) ALIAS ( cCheckArea( "SUBCUENTA", @dbfSubcuenta ) )
      SET INDEX TO ( cRuta + "EMP" + cCodEmp + "\SubCta.Cdx" )

   else

      if lMessage
         msgStop( "Ficheros no encontrados en ruta " + cRuta + " empresa " + cCodEmp, "Abriendo subcuentas" )
      end if

      Return nil

   end if

   if ( dbfSubcuenta )->( RddName() ) == nil .or. NetErr()
      if lMessage
         msgStop( "Imposible acceder a fichero Contaplus", "Abriendo subcuentas" )
      end if
      Return nil
   end if

Return ( dbfSubcuenta )

//----------------------------------------------------------------------------//

FUNCTION CloSubCuenta()

   if !empty( cSubCuenta )
      ( cSubCuenta )->( dbCloseArea() )
   end if

   cSubCuenta  := nil

Return ( cSubCuenta )

//----------------------------------------------------------------------------//

FUNCTION ODiario()

Return ( nil )

//----------------------------------------------------------------------------//

FUNCTION CDiario()

Return ( nil )

//----------------------------------------------------------------------------//

FUNCTION SetAplicacionContable( nAplicacion )
   
   if nAplicacionContable != nAplicacion
      nAplicacionContable := nAplicacion
   end if 

Return ( nAplicacion )

//---------------------------------------------------------------------------//
       
FUNCTION lAplicacionContaplus()

Return ( nAplicacionContable <= 1 )

//---------------------------------------------------------------------------//

FUNCTION lAplicacionA3()

Return ( nAplicacionContable == 2 )

//---------------------------------------------------------------------------//

FUNCTION lAplicacionSage()

Return ( nAplicacionContable == 3 )

//---------------------------------------------------------------------------//

FUNCTION lAplicacionMonitor()

Return ( nAplicacionContable == 4 )

//---------------------------------------------------------------------------//

FUNCTION lAplicacionSage50()

Return ( nAplicacionContable == 5 )

//---------------------------------------------------------------------------//

FUNCTION setAsientoIntraComunitario( lIntracomunitario )

   lAsientoIntraComunitario   := lIntracomunitario

Return ( lAsientoIntraComunitario )

//---------------------------------------------------------------------------//

FUNCTION getAsientoIntraComunitario()

Return ( lAsientoIntraComunitario )

//---------------------------------------------------------------------------//

CLASS EnlaceA3

   CLASSDATA oInstance

   DATA hAsiento
   DATA aAsiento                          INIT {}

   DATA cDirectory                        INIT "C:\ENLACEA3"
   DATA cFile                             INIT "SUENLACE.DAT" 
   DATA hFile 
   DATA cDate                             INIT DateToString()

   DATA cBuffer                           INIT ""

   METHOD New()

   METHOD getInstance()
   METHOD destroyInstance()               INLINE ( ::oInstance := nil )

   METHOD Add( hAsiento )                 INLINE ( if( hhaskey( hAsiento, "Render" ) .and. !empty( hGet( hAsiento, "Render" ) ), aAdd( ::aAsiento, hAsiento ), ) )
   METHOD Show()                          INLINE ( msgInfo( ::cBuffer ) )

   METHOD Directory( cValue )             INLINE ( if( !empty( cValue ), ::cDirectory        := cValue,                 ::cDirectory ) )
   METHOD File( cValue )                  INLINE ( if( !empty( cValue ), ::cFile             := cValue,                 ::cFile ) )
   METHOD cDate( dValue )                 INLINE ( if( !empty( dValue ), ::cDate             := DateToString( dValue ), ::cDate ) )
   METHOD cFullFile()                     INLINE ( ::cDirectory + "\" + ::cFile )
   
   METHOD Render()
   METHOD AutoRender()
   METHOD RenderCabeceraFactura()
   METHOD RenderVentaFactura()
   METHOD RenderReciboFactura()
   METHOD RenderApuntesSinIVA() 

   METHOD GenerateFile()
   METHOD WriteASCII()   
   METHOD WriteInfo( oTree, cInfo )       INLINE ( oTree:Select( oTree:Add( cInfo, 1 ) ) )

   METHOD Signo( nImporte )      
   METHOD Porcentaje( nPorcentaje )         

   METHOD appendBuffer( cValue )          INLINE ( ::cBuffer   += cValue )

   METHOD TipoFormato()                   INLINE ( ::appendBuffer( '3' ) )
   METHOD Empresa()                       INLINE ( ::appendBuffer( padr( ::hAsiento[ "Empresa" ], 5 ) ) )
   METHOD FechaApunte()                   INLINE ( ::appendBuffer( dtos( ::hAsiento[ "Fecha"] ) ) )
   METHOD TipoRegistro()                  INLINE ( ::appendBuffer( if( hhaskey( ::hAsiento, "TipoRegistro" ), ::hAsiento[ "TipoRegistro" ], "0" ) ) )
   METHOD TipoImporte()                   INLINE ( ::appendBuffer( ::hAsiento[ "TipoImporte" ] ) )
   METHOD FechaFactura()                  INLINE ( ::appendBuffer( dtos( ::hAsiento[ "FechaFactura"] ) ) )
   METHOD NumeroFactura()                 INLINE ( ::appendBuffer( padr( ::hAsiento[ "NumeroFactura" ], 10 ) )  )
   METHOD DescripcionApunte()             INLINE ( ::appendBuffer( padr( ::hAsiento[ "DescripcionApunte" ], 30 ) ) )
   METHOD Importe()                       INLINE ( ::appendBuffer( ::Signo( ::hAsiento[ "Importe" ] ) ) )
   METHOD Reserva( nSpace )               INLINE ( ::appendBuffer( space( nSpace ) ) )
   METHOD NIF()                           INLINE ( ::appendBuffer( padr( trimNif( ::hAsiento[ "Nif" ] ), 14 ) ) )
   METHOD NombreCliente()                 INLINE ( ::appendBuffer( padr( ::hAsiento[ "NombreCliente" ], 40 ) ) )
   METHOD CodigoPostal()                  INLINE ( ::appendBuffer( padr( ::hAsiento[ "CodigoPostal" ], 5 ) ) )
   
   METHOD FechaOperacion()                INLINE ( ::appendBuffer( dtos( ::hAsiento[ "FechaOperacion"] ) ) )
   METHOD FechaFactura()                  INLINE ( ::appendBuffer( dtos( ::hAsiento[ "FechaFactura"] ) ) )
   METHOD Fecha()                         INLINE ( ::appendBuffer( dtos( ::hAsiento[ "Fecha" ] ) ) )
   
   METHOD Moneda()                        INLINE ( ::appendBuffer( ::hAsiento[ "Moneda" ] ) )

   METHOD Cuenta()                        INLINE ( ::appendBuffer( padr( ::hAsiento[ "Cuenta" ], 12 ) )  )
   METHOD CuentaTesoreria()               INLINE ( ::appendBuffer( padr( ::hAsiento[ "CuentaTesoreria" ], 12 ) )  )

   METHOD DescripcionCuenta()             INLINE ( ::appendBuffer( padr( ::hAsiento[ "DescripcionCuenta" ], 30 ) ) )

   METHOD SubtipoFactura()                INLINE ( ::appendBuffer( ::hAsiento[ "SubtipoFactura" ] )  )

   METHOD BaseImponible()                 INLINE ( ::appendBuffer( ::Signo( ::hAsiento[ "BaseImponible" ] ) ) )
   METHOD PorcentajeIVA()                 INLINE ( ::appendBuffer( ::Porcentaje( ::hAsiento[ "PorcentajeIVA" ], 5, 2 ) ) )
   METHOD CuotaIVA()                      INLINE ( ::appendBuffer( ::Signo( ::hAsiento[ "BaseImponible" ] * ::hAsiento[ "PorcentajeIVA" ] / 100 ) ) )

   METHOD PorcentajeRecargo()             INLINE ( ::appendBuffer( ::Porcentaje( ::hAsiento[ "PorcentajeRecargo" ], 5, 2 ) ) )
   METHOD CuotaRecargo()                  INLINE ( ::appendBuffer( ::Signo( ::hAsiento[ "BaseImponible" ] * ::hAsiento[ "PorcentajeRecargo" ] / 100 ) ) )

   METHOD PorcentajeRetencion()           INLINE ( ::appendBuffer( ::Porcentaje( ::hAsiento[ "PorcentajeRetencion" ], 5, 2 ) ) )
   METHOD CuotaRetencion()                INLINE ( ::appendBuffer( ::Signo( ::hAsiento[ "BaseImponible" ] * ::hAsiento[ "PorcentajeRetencion" ] / 100 ) ) )

   METHOD Impreso()                       INLINE ( ::appendBuffer( ::hAsiento[ "Impreso" ] ) )
   METHOD SujetaIVA()                     INLINE ( ::appendBuffer( ::hAsiento[ "SujetaIVA" ] ) )
   METHOD Modelo415()                     INLINE ( ::appendBuffer( ::hAsiento[ "Modelo415" ] ) )
   METHOD Analitico()                     INLINE ( ::appendBuffer( if( hhaskey( ::hAsiento, "Analitico" ), ::hAsiento[ "Analitico" ], space( 1 ) ) ) )

   METHOD TipoFacturaVenta()              INLINE ( ::appendBuffer( '1' ) )
   METHOD TipoFacturaCompras()            INLINE ( ::appendBuffer( '2' ) )
   METHOD TipoFacturaBienes()             INLINE ( ::appendBuffer( '3' ) )

   METHOD Generado()                      INLINE ( ::appendBuffer( 'N' ) )

   METHOD FechaVencimiento()              INLINE ( ::appendBuffer( dtos( ::hAsiento[ "FechaVencimiento"] ) ) )
   METHOD TipoVencimiento()               INLINE ( ::appendBuffer( ::hAsiento[ "TipoVencimiento" ] ) )
   METHOD DescripcionVencimiento()        INLINE ( ::appendBuffer( padr( ::hAsiento[ "DescripcionVencimiento" ], 30 ) ) )
   METHOD ImporteVencimiento()            INLINE ( ::appendBuffer( ::Signo( ::hAsiento[ "ImporteVencimiento" ] ) ) )
   METHOD NumeroVencimiento()             INLINE ( ::appendBuffer( str( ::hAsiento[ "NumeroVencimiento" ], 2 ) ) )
   METHOD FormaPago()                     INLINE ( ::appendBuffer( ::hAsiento[ "FormaPago" ] ) )

   METHOD Referencia()                    INLINE ( ::appendBuffer( padr( ::hAsiento[ "Concepto" ], 10 ) ) )
   METHOD ReferenciaDocumento()           INLINE ( ::appendBuffer( padr( ::hAsiento[ "ReferenciaDocumento" ], 10 ) ) )
   
   METHOD LineaApunte()                   INLINE ( ::appendBuffer( if( hb_enumindex() == 1, 'I', if( hb_enumindex() > 1 .and. hb_enumindex() < len( ::aAsiento ), 'M', 'U' ) ) )    )
   
   METHOD FinLinea()                      INLINE ( ::appendBuffer( CRLF ) )

ENDCLASS

//---------------------------------------------------------------------------//

   METHOD New() CLASS EnlaceA3

      if empty( cRutCnt() )
         ::cDirectory                     := "C:\ENLACEA3"
      else
         ::cDirectory                     := cRutCnt()
      end if 
      ::cFile                             := "SUENLACE.DAT" 

      ::aAsiento                          := {}
      ::cDate                             := DateToString()
      ::cBuffer                           := ""

   RETURN ( Self )

//---------------------------------------------------------------------------//

   METHOD GetInstance() CLASS EnlaceA3

      if empty( ::oInstance )
         ::oInstance                      := ::New()
      end if

   RETURN ( ::oInstance )

//---------------------------------------------------------------------------//

   METHOD Render() CLASS EnlaceA3

      local hAsiento

      for each hAsiento in ::aAsiento

         ::hAsiento     := hAsiento

         do case 
            case hAsiento[ "Render" ] == "CabeceraFactura"
               ::RenderCabeceraFactura()
            case hAsiento[ "Render" ] == "VentaFactura"
               ::RenderVentaFactura()
            case hAsiento[ "Render" ] == "ReciboFactura"
               ::RenderReciboFactura()
            case hAsiento[ "Render" ] == "ApuntesSinIVA"
               ::RenderApuntesSinIVA()
         end case

      next

      ::aAsiento        := {}

   RETURN ( Self )

//---------------------------------------------------------------------------//

   METHOD RenderCabeceraFactura() CLASS EnlaceA3

      ::TipoFormato()
      ::Empresa()
      ::FechaApunte()
      ::TipoRegistro( 1 )
      ::Cuenta()
      ::DescripcionCuenta()
      ::TipoFacturaVenta()
      ::NumeroFactura()
      ::LineaApunte()
      ::DescripcionApunte()
      ::Importe()
      ::Reserva( 62 )
      ::NIF()
      ::NombreCliente()
      ::CodigoPostal()
      ::Reserva( 2 )
      ::FechaOperacion()
      ::FechaOperacion()
      ::Moneda()
      ::Generado()

      ::FinLinea() 

   Return ( Self )

//------------------------------------------------------------------------//

   METHOD RenderVentaFactura() CLASS EnlaceA3

      ::TipoFormato()
      ::Empresa()
      ::FechaApunte()
      ::TipoRegistro()
      ::Cuenta()
      ::DescripcionCuenta()
      ::TipoImporte()
      ::NumeroFactura()
      ::LineaApunte()
      ::DescripcionApunte()
      ::SubtipoFactura()
      ::BaseImponible()
      ::PorcentajeIVA()
      ::CuotaIVA()
      ::PorcentajeRecargo()
      ::CuotaRecargo()
      ::PorcentajeRetencion()
      ::CuotaRetencion()
      ::Impreso()
      ::SujetaIVA()
      ::Modelo415()
      ::Reserva( 75 )
      ::Analitico()
      ::Moneda()
      ::Generado()

      ::FinLinea() 

   Return ( Self )

   //------------------------------------------------------------------------//

   METHOD RenderReciboFactura() CLASS EnlaceA3

      ::TipoFormato()
      ::Empresa()
      ::FechaVencimiento()
      ::TipoRegistro()
      ::Cuenta()
      ::DescripcionCuenta()
      ::TipoVencimiento()
      ::NumeroFactura()
      ::Reserva( 1 )             // Indicador de ampliacion   
      ::DescripcionVencimiento() 
      ::ImporteVencimiento()
      ::FechaFactura()
      ::CuentaTesoreria()
      ::FormaPago()
      ::NumeroVencimiento()
      ::Reserva( 115 )
      ::Moneda()
      ::Generado()

      ::FinLinea() 

   Return ( Self )

   //------------------------------------------------------------------------//

   METHOD RenderApuntesSinIVA() CLASS EnlaceA3

      ::TipoFormato()
      ::Empresa()
      ::Fecha()
      ::TipoRegistro()
      ::Cuenta()
      ::DescripcionCuenta()
      ::TipoImporte()
      ::ReferenciaDocumento()
      ::LineaApunte()
      ::DescripcionApunte()
      ::Importe()
      ::Reserva( 138 )
      ::Analitico()
      ::Moneda()
      ::Generado()

      ::FinLinea() 

   Return ( Self )

   //------------------------------------------------------------------------//

   METHOD Signo( nImporte ) CLASS EnlaceA3

      if nImporte == 0
         Return ( space( 14 ) )
      end if 

   RETURN ( if( nImporte > 0, '+', '-' ) + strzero( abs( nImporte ), 13, 2 ) )

   //------------------------------------------------------------------------//

   METHOD Porcentaje( nPorcentaje ) CLASS EnlaceA3

      if nPorcentaje == 0
         Return ( space( 5 ) )
      end if 

   RETURN ( strzero( ::hAsiento[ "PorcentajeIVA" ], 5, 2 ) ) 

//---------------------------------------------------------------------------//

   METHOD GenerateFile() CLASS EnlaceA3

      ferase( ::cFullFile() )

      ::hFile        := fCreate( ::cFullFile() )

   RETURN ( Self )   

//---------------------------------------------------------------------------//

   METHOD WriteASCII() CLASS EnlaceA3

      ferase( ::cFullFile() )

      if !file( ::cFullFile() ) .or. empty( ::hFile )
         ::hFile     := fCreate( ::cFullFile() )
      end if 

      if !empty( ::hFile )

         fWrite( ::hFile, ::cBuffer )
         fClose( ::hFile )

         ::cBuffer   := ""

         if apoloMsgNoYes( "Proceso de exportación realizado con éxito" + CRLF + ;
                           "en fichero " + ( ::cFullFile() )            + CRLF + ;
                           "¿ Desea abrir el fichero resultante ?",;
                           "Elija una opción." )
            shellExecute( 0, "open", ( ::cDirectory + "\" + ::cFile ), , , 1 )
         end if

         Return .t.

      end if

   Return ( .f. )

//---------------------------------------------------------------------------//

   METHOD AutoRender() CLASS EnlaceA3

   Return ( Self )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS EnlaceSage

   CLASSDATA oInstance

   DATA cBuffer                           INIT ""
   DATA nView
   DATA oTree

   DATA cConector                         INIT ";"

   DATA nContadorLinea                    INIT 1
   DATA nContadorAsiento                 INIT 1

   DATA cDirectory
   DATA cFile

   DATA cFullFile
   DATA hFile

   DATA aTotales                          INIT {}
   DATA aTotalesIva                       INIT {}

   DATA SubCtaVtaIva21
   DATA SubCtaVtaIva10
   DATA SubCtaVtaIva4
   DATA SubCtaVtaIva0
   DATA SubCtaVtaIvaRe21
   DATA SubCtaVtaIvaRe10
   DATA SubCtaVtaIvaRe4
   DATA SubCtaVtaIvaRe0
   DATA SubCtaVtaIva2
   DATA SubCtaVtaIvaRe2
   DATA SubCtaVtaIva75
   DATA SubCtaVtaIvaRe75
   DATA SubCtaVtaIva5
   DATA SubCtaVtaIvaRe5
   DATA SubCtaCaja

   METHOD New()
   METHOD GetInstance()
   METHOD destroyInstance()               INLINE ( ::oInstance := nil )

   METHOD ContabilizaFacturaCliente()
      METHOD addAsientos()
      METHOD addDebe()
      METHOD addHaber()
      METHOD addIva()
      METHOD addRe()
      METHOD addCobrosHaber()
      METHOD addCobrosDebe()

   METHOD CuentaIva( nIva )

   METHOD CuentaRe( nIva )

   METHOD changeState()

   METHOD WriteASCII()

   METHOD cFullFile()                     INLINE ( ::cDirectory + "\" + ::cFile )

   METHOD writeTree( cText, nState )      INLINE ( ::oTree:Select( ::oTree:Add( cText, nState ) ) )
   METHOD cNumero()                       INLINE ( ( D():FacturasClientes( ::nView ) )->cSerie + "/" + AllTrim( Str( ( D():FacturasClientes( ::nView ) )->nNumFac ) ) + "/" + ( D():FacturasClientes( ::nView ) )->cSufFac )

   METHOD cFormatoImporte()
   METHOD cFormatoPorcentaje()

   METHOD AddCabecera()

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS EnlaceSage

   if empty( cRutCnt() )
      ::cDirectory      := "C:\ENLACESAGE"
   else
      ::cDirectory      := cRutCnt()
   end if 

   ::cFile              := "FacturasClientes.csv"

   ::SubCtaVtaIva21     := "4770021"
   ::SubCtaVtaIvaRe21   := "4775221"
   ::SubCtaVtaIva10     := "4770010"
   ::SubCtaVtaIvaRe10   := "4771410"
   ::SubCtaVtaIva4      := "4770004"
   ::SubCtaVtaIvaRe4    := "4770504"
   ::SubCtaVtaIva0      := "4770000"
   ::SubCtaVtaIvaRe0    := "4770099"
   ::SubCtaVtaIva2      := "4770002"
   ::SubCtaVtaIvaRe2    := "4770226"
   ::SubCtaVtaIva75     := "4770075"
   ::SubCtaVtaIvaRe75   := "4770750"
   ::SubCtaVtaIva5      := "4770005"
   ::SubCtaVtaIvaRe5    := "4770562"
   ::SubCtaCaja         := "4310000"
   ::cBuffer            := ""

   ::nContadorAsiento  := 1

   ::AddCabecera()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD GetInstance() CLASS EnlaceSage

   if empty( ::oInstance )
      ::oInstance       := ::New()
   end if

RETURN ( ::oInstance )

//---------------------------------------------------------------------------//

METHOD ContabilizaFacturaCliente( nView, oTree ) CLASS EnlaceSage

   ::nView              := nView
   ::oTree              := oTree

   if ( D():FacturasClientes( ::nView ) )->lContab
      ::writeTree( "Factura anteriormente contabilizada : " + ::cNumero(), 0 )
      Return ( Self )
   end if

   ::addAsientos()

   ::changeState()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addAsientos() CLASS EnlaceSage

   ::nContadorLinea     := 1

   ::aTotales           := aTotFacCli( ( D():FacturasClientes( ::nView ) )->cSerie + Str( ( D():FacturasClientes( ::nView ) )->nNumFac ) + ( D():FacturasClientes( ::nView ) )->cSufFac,;
                                       D():FacturasClientes( ::nView ),;
                                       D():FacturasClientesLineas( ::nView ),;
                                       D():TiposIva( ::nView ),;
                                       D():Divisas( ::nView ),;
                                       D():FacturasClientesCobros( ::nView ),;
                                       D():AnticiposClientes( ::nView ) )

   ::aTotalesIva        := ::aTotales[8]

   ::addDebe()
   ::addHaber()
   ::addIva()
   
   if ( D():FacturasClientes( ::nView ) )->lRecargo
      ::addRe()
   end if

   ::addCobrosHaber()
   ::addCobrosDebe()

   ::nContadorAsiento ++

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addDebe() CLASS EnlaceSage

   ::cBuffer   += cCodEmpCnt( "A" ) + ::cConector  //"CodigoEmpresa"
   ::cBuffer   += AllTrim( Str( Year( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"Ejercicio"
   ::cBuffer   += Str( ::nContadorAsiento ) + ::cConector  //"Asiento"
   ::cBuffer   += "D" + ::cConector  //"CargoAbono"
   ::cBuffer   += if( Empty( cCliCta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ), AllTrim( ( D():FacturasClientes( ::nView ) )->cCodCli ), AllTrim( cCliCta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ) ) + ::cConector  //"CodigoCuenta"
   ::cBuffer   += Padr( AllTrim( cCliCtaVta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ), 7, "0" ) + ::cConector  //"Contrapartida"
   ::cBuffer   += dToc( ( D():FacturasClientes( ::nView ) )->dFecFac ) + ::cConector  //"Fechaasiento"
   ::cBuffer   += "" + ::cConector  //"TipoDocumento"
   ::cBuffer   += "" + ::cConector  //"DocumentoConta"
   ::cBuffer   += "N/F." + AllTrim( ::cNumero() ) + ::cConector  //"Comentario"
   ::cBuffer   += ::cFormatoImporte( ::aTotales[ 4 ] ) + ::cConector  //"ImporteAsiento"
   ::cBuffer   += "100" + ::cConector  //"CodigoDiario"
   ::cBuffer   += "" + ::cConector  //"CodigoCanal"
   ::cBuffer   += AllTrim( Str( Month( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"NumeroPeriodo"
   ::cBuffer   += Str( ::nContadorLinea ) + ::cConector  //"OrdenMovimientos"
   ::cBuffer   += AllTrim( Str( Year( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"EjercicioFactura"
   ::cBuffer   += ( D():FacturasClientes( ::nView ) )->cSerie + ::cConector  //"SerieFactura"
   ::cBuffer   += AllTrim( Str( ( D():FacturasClientes( ::nView ) )->nNumFac ) ) + ::cConector //"NumeroFactura"
   ::cBuffer   += dToc( ( D():FacturasClientes( ::nView ) )->dFecFac ) + ::cConector  //"FechaFactura"
   ::cBuffer   += "E" + ::cConector  //"TipoFactura"
   ::cBuffer   += dToc( ( D():FacturasClientes( ::nView ) )->dFecFac ) + ::cConector  //"FechaOperacion"
   ::cBuffer   += "" + ::cConector  //"SuFacturaNo"
   ::cBuffer   += if( ( len( ::aTotalesIva ) >= 1 .and. hGet( ::aTotalesIva[ 1 ], "porcentajeiva" ) != nil ), ::cFormatoImporte( hGet( ::aTotalesIva[ 1 ], "neto" ) ), "0" ) + ::cConector  //"BaseIva1"
   ::cBuffer   += if( ( len( ::aTotalesIva ) >= 2 .and. hGet( ::aTotalesIva[ 2 ], "porcentajeiva" ) != nil ), ::cFormatoImporte( hGet( ::aTotalesIva[ 2 ], "neto" ) ), "0" ) + ::cConector  //"BaseIva2"
   ::cBuffer   += if( ( len( ::aTotalesIva ) >= 3 .and. hGet( ::aTotalesIva[ 3 ], "porcentajeiva" ) != nil ), ::cFormatoImporte( hGet( ::aTotalesIva[ 3 ], "neto" ) ), "0" ) + ::cConector  //"BaseIva3"
   ::cBuffer   += if( ( len( ::aTotalesIva ) >= 1 .and. hGet( ::aTotalesIva[ 1 ], "porcentajeiva" ) != nil ), ::cFormatoImporte( hGet( ::aTotalesIva[ 1 ], "impiva" ) ), "0" ) + ::cConector  //"CuotaIva1"
   ::cBuffer   += if( ( len( ::aTotalesIva ) >= 2 .and. hGet( ::aTotalesIva[ 2 ], "porcentajeiva" ) != nil ), ::cFormatoImporte( hGet( ::aTotalesIva[ 2 ], "impiva" ) ), "0" ) + ::cConector  //"CuotaIva2"
   ::cBuffer   += if( ( len( ::aTotalesIva ) >= 3 .and. hGet( ::aTotalesIva[ 3 ], "porcentajeiva" ) != nil ), ::cFormatoImporte( hGet( ::aTotalesIva[ 3 ], "impiva" ) ), "0" ) + ::cConector  //"CuotaIva3"
   ::cBuffer   += if( ( len( ::aTotalesIva ) >= 1 .and. hGet( ::aTotalesIva[ 1 ], "porcentajeiva" ) != nil ), ::cFormatoImporte( hGet( ::aTotalesIva[ 1 ], "porcentajeiva" ) ), "0" ) + ::cConector  //"PorIva1"
   ::cBuffer   += if( ( len( ::aTotalesIva ) >= 2 .and. hGet( ::aTotalesIva[ 2 ], "porcentajeiva" ) != nil ), ::cFormatoImporte( hGet( ::aTotalesIva[ 2 ], "porcentajeiva" ) ), "0" ) + ::cConector  //"PorIva2"
   ::cBuffer   += if( ( len( ::aTotalesIva ) >= 3 .and. hGet( ::aTotalesIva[ 3 ], "porcentajeiva" ) != nil ), ::cFormatoImporte( hGet( ::aTotalesIva[ 3 ], "porcentajeiva" ) ), "0" ) + ::cConector  //"PorIva3"
   //::cBuffer   += if( ::aTotalesIva[ 1, 3 ] != nil, ::cFormatoImporte( ::aTotalesIva[ 1, 2 ] ), "0" ) + ::cConector  //"BaseIva1"
   //::cBuffer   += if( ::aTotalesIva[ 2, 3 ] != nil, ::cFormatoImporte( ::aTotalesIva[ 2, 2 ] ), "0" ) + ::cConector  //"BaseIva2"
   //::cBuffer   += if( ::aTotalesIva[ 3, 3 ] != nil, ::cFormatoImporte( ::aTotalesIva[ 3, 2 ] ), "0" ) + ::cConector  //"BaseIva3"
   //::cBuffer   += if( ::aTotalesIva[ 1, 3 ] != nil, ::cFormatoImporte( ::aTotalesIva[ 1, 8 ] ), "0" ) + ::cConector  //"CuotaIva1"
   //::cBuffer   += if( ::aTotalesIva[ 2, 3 ] != nil, ::cFormatoImporte( ::aTotalesIva[ 2, 8 ] ), "0" ) + ::cConector  //"CuotaIva2"
   //::cBuffer   += if( ::aTotalesIva[ 3, 3 ] != nil, ::cFormatoImporte( ::aTotalesIva[ 3, 8 ] ), "0" ) + ::cConector  //"CuotaIva3"
   //::cBuffer   += if( ::aTotalesIva[ 1, 3 ] != nil, ::cFormatoPorcentaje( ::aTotalesIva[ 1, 3 ] ), "0" ) + ::cConector  //"PorIva1"
   //::cBuffer   += if( ::aTotalesIva[ 2, 3 ] != nil, ::cFormatoPorcentaje( ::aTotalesIva[ 2, 3 ] ), "0" ) + ::cConector  //"PorIva2"
   //::cBuffer   += if( ::aTotalesIva[ 3, 3 ] != nil, ::cFormatoPorcentaje( ::aTotalesIva[ 3, 3 ] ), "0" ) + ::cConector  //"PorIva3"
   ::cBuffer   += dtoc( GetSysDate() )  + ::cConector  //"FechaGrabacion"
   ::cBuffer   += AllTrim( ( D():FacturasClientes( ::nView ) )->cDniCli ) + ::cConector  //"CifDNI"
   ::cBuffer   += ::cFormatoImporte( ::aTotales[ 4 ] ) + ::cConector  //"ImporteFactura"
   ::cBuffer   += ::cFormatoImporte( ::aTotales[ 12 ] ) + ::cConector  //"ImporteRetencion"
   ::cBuffer   += AllTrim( ( D():FacturasClientes( ::nView ) )->cNomCli ) + ::cConector  //"Nombre"
   ::cBuffer   += "" + ::cConector  //"CodigoCuentaFactura"
   ::cBuffer   += "" + ::cConector  //"LibreA1"
   ::cBuffer   += ::cFormatoImporte( ::aTotales[ 1 ] ) + ::cConector  //"Base Recargo"
   ::cBuffer   += ::cFormatoImporte( ::aTotales[ 3 ] ) + ::cConector  //"Cuota Recargo"
   ::cBuffer   += if( len( ::aTotalesIva ) >= 1 .and. ( D():FacturasClientes( ::nView ) )->lRecargo .and. hGet( ::aTotalesIva[ 1 ], "porcentajere" ) != nil, ::cFormatoPorcentaje( hGet( ::aTotalesIva[ 1 ], "porcentajere" ) ), "0" ) + ::cConector  //"PorRecargoEquivalencia1"
   ::cBuffer   += if( len( ::aTotalesIva ) >= 2 .and. ( D():FacturasClientes( ::nView ) )->lRecargo .and. hGet( ::aTotalesIva[ 2 ], "porcentajere" ) != nil, ::cFormatoPorcentaje( hGet( ::aTotalesIva[ 2 ], "porcentajere" ) ), "0" ) + ::cConector  //"PorRecargoEquivalencia2"
   ::cBuffer   += if( len( ::aTotalesIva ) >= 3 .and. ( D():FacturasClientes( ::nView ) )->lRecargo .and. hGet( ::aTotalesIva[ 3 ], "porcentajere" ) != nil, ::cFormatoPorcentaje( hGet( ::aTotalesIva[ 3 ], "porcentajere" ) ), "0" ) + ::cConector  //"PorRecargoEquivalencia3"
   //::cBuffer   += if( ( D():FacturasClientes( ::nView ) )->lRecargo .and. ::aTotalesIva[ 1, 4 ] != nil, ::cFormatoPorcentaje( ::aTotalesIva[ 1, 4 ] ), "0" ) + ::cConector  //"PorRecargoEquivalencia1"
   //::cBuffer   += if( ( D():FacturasClientes( ::nView ) )->lRecargo .and. ::aTotalesIva[ 2, 4 ] != nil, ::cFormatoPorcentaje( ::aTotalesIva[ 2, 4 ] ), "0" ) + ::cConector  //"PorRecargoEquivalencia2"
   //::cBuffer   += if( ( D():FacturasClientes( ::nView ) )->lRecargo .and. ::aTotalesIva[ 3, 4 ] != nil, ::cFormatoPorcentaje( ::aTotalesIva[ 3, 4 ] ), "0" ) + ::cConector  //"PorRecargoEquivalencia3"
   ::cBuffer   += "0" + CRLF         //"PorRecargoEquivalencia4"

   ::nContadorLinea ++

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addHaber() CLASS EnlaceSage

   ::cBuffer   += cCodEmpCnt( "A" ) + ::cConector  //"CodigoEmpresa"
   ::cBuffer   += AllTrim( Str( Year( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"Ejercicio"
   ::cBuffer   += Str( ::nContadorAsiento ) + ::cConector  //"Asiento"
   ::cBuffer   += "H" + ::cConector  //"CargoAbono"
   ::cBuffer   += Padr( AllTrim( cCliCtaVta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ), 7, "0" ) + ::cConector  //"CodigoCuenta"
   ::cBuffer   += if( Empty( cCliCta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ), AllTrim( ( D():FacturasClientes( ::nView ) )->cCodCli ), AllTrim( cCliCta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ) ) + ::cConector  //"CodigoCuenta"
   ::cBuffer   += dToc( ( D():FacturasClientes( ::nView ) )->dFecFac ) + ::cConector  //"Fechaasiento"
   ::cBuffer   += "" + ::cConector  //"TipoDocumento"
   ::cBuffer   += "" + ::cConector  //"DocumentoConta"
   ::cBuffer   += "N/F." + AllTrim( ::cNumero() ) + ::cConector  //"Comentario"
   ::cBuffer   += ::cFormatoImporte( ::aTotales[ 1 ] ) + ::cConector  //"ImporteAsiento"
   ::cBuffer   += "100" + ::cConector  //"CodigoDiario"
   ::cBuffer   += "" + ::cConector  //"CodigoCanal"
   ::cBuffer   += AllTrim( Str( Month( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"NumeroPeriodo"
   ::cBuffer   += Str( ::nContadorLinea ) + ::cConector  //"OrdenMovimientos"
   ::cBuffer   += "0" + ::cConector  //"EjercicioFactura"
   ::cBuffer   += "" + ::cConector  //"SerieFactura"
   ::cBuffer   += "" + ::cConector //"NumeroFactura"
   ::cBuffer   += "" + ::cConector  //"FechaFactura"
   ::cBuffer   += "" + ::cConector  //"TipoFactura"
   ::cBuffer   += "" + ::cConector  //"FechaOperacion"
   ::cBuffer   += "" + ::cConector  //"SuFacturaNo"
   ::cBuffer   += "" + ::cConector  //"BaseIva1"
   ::cBuffer   += "" + ::cConector  //"BaseIva2"
   ::cBuffer   += "" + ::cConector  //"BaseIva3"
   ::cBuffer   += "" + ::cConector  //"CuotaIva1"
   ::cBuffer   += "" + ::cConector  //"CuotaIva2"
   ::cBuffer   += "" + ::cConector  //"CuotaIva3"
   ::cBuffer   += "" + ::cConector  //"PorIva1"
   ::cBuffer   += "" + ::cConector  //"PorIva2"
   ::cBuffer   += "" + ::cConector  //"PorIva3"
   ::cBuffer   += dtoc( GetSysDate() ) + ::cConector  //"FechaGrabacion"
   ::cBuffer   += "" + ::cConector  //"CifDNI"
   ::cBuffer   += "" + ::cConector  //"ImporteFactura"
   ::cBuffer   += "" + ::cConector  //"ImporteRetencion"
   ::cBuffer   += "" + ::cConector  //"Nombre"
   ::cBuffer   += "" + ::cConector  //"CodigoCuentaFactura"
   ::cBuffer   += "" + ::cConector  //"LibreA1"
   ::cBuffer   += "" + ::cConector  //"Base Recargo"
   ::cBuffer   += "" + ::cConector  //"Cuota Recargo"
   ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia1"
   ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia2"
   ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia3"
   ::cBuffer   += "" + CRLF         //"PorRecargoEquivalencia4"

   ::nContadorLinea ++

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addCobrosHaber() CLASS EnlaceSage

   ::cBuffer   += cCodEmpCnt( "A" ) + ::cConector  //"CodigoEmpresa"
   ::cBuffer   += AllTrim( Str( Year( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"Ejercicio"
   ::cBuffer   += Str( ::nContadorAsiento ) + ::cConector  //"Asiento"
   ::cBuffer   += "H" + ::cConector  //"CargoAbono"
   ::cBuffer   += if( Empty( cCliCta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ), AllTrim( ( D():FacturasClientes( ::nView ) )->cCodCli ), AllTrim( cCliCta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ) ) + ::cConector  //"CodigoCuenta"
   ::cBuffer   += "" + ::cConector  //"Contrapartida"
   ::cBuffer   += dToc( ( D():FacturasClientes( ::nView ) )->dFecFac ) + ::cConector  //"Fechaasiento"
   ::cBuffer   += "" + ::cConector  //"TipoDocumento"
   ::cBuffer   += "" + ::cConector  //"DocumentoConta"
   ::cBuffer   += "RECIBO N/F." + AllTrim( ::cNumero() ) + ::cConector  //"Comentario"
   ::cBuffer   += ::cFormatoImporte( ::aTotales[ 4 ] ) + ::cConector  //"ImporteAsiento"
   ::cBuffer   += "100" + ::cConector  //"CodigoDiario"
   ::cBuffer   += "" + ::cConector  //"CodigoCanal"
   ::cBuffer   += AllTrim( Str( Month( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"NumeroPeriodo"
   ::cBuffer   += Str( ::nContadorLinea ) + ::cConector  //"OrdenMovimientos"
   ::cBuffer   += "0" + ::cConector  //"EjercicioFactura"
   ::cBuffer   += "" + ::cConector  //"SerieFactura"
   ::cBuffer   += "" + ::cConector //"NumeroFactura"
   ::cBuffer   += "" + ::cConector  //"FechaFactura"
   ::cBuffer   += "" + ::cConector  //"TipoFactura"
   ::cBuffer   += "" + ::cConector  //"FechaOperacion"
   ::cBuffer   += "" + ::cConector  //"SuFacturaNo"
   ::cBuffer   += "" + ::cConector  //"BaseIva1"
   ::cBuffer   += "" + ::cConector  //"BaseIva2"
   ::cBuffer   += "" + ::cConector  //"BaseIva3"
   ::cBuffer   += "" + ::cConector  //"CuotaIva1"
   ::cBuffer   += "" + ::cConector  //"CuotaIva2"
   ::cBuffer   += "" + ::cConector  //"CuotaIva3"
   ::cBuffer   += "" + ::cConector  //"PorIva1"
   ::cBuffer   += "" + ::cConector  //"PorIva2"
   ::cBuffer   += "" + ::cConector  //"PorIva3"
   ::cBuffer   += dtoc( GetSysDate() ) + ::cConector  //"FechaGrabacion"
   ::cBuffer   += "" + ::cConector  //"CifDNI"
   ::cBuffer   += "" + ::cConector  //"ImporteFactura"
   ::cBuffer   += "" + ::cConector  //"ImporteRetencion"
   ::cBuffer   += "" + ::cConector  //"Nombre"
   ::cBuffer   += "" + ::cConector  //"CodigoCuentaFactura"
   ::cBuffer   += "" + ::cConector  //"LibreA1"
   ::cBuffer   += "" + ::cConector  //"Base Recargo"
   ::cBuffer   += "" + ::cConector  //"Cuota Recargo"
   ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia1"
   ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia2"
   ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia3"
   ::cBuffer   += "" + CRLF         //"PorRecargoEquivalencia4"

   ::nContadorLinea ++

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addCobrosDebe() CLASS EnlaceSage

   ::cBuffer   += cCodEmpCnt( "A" ) + ::cConector  //"CodigoEmpresa"
   ::cBuffer   += AllTrim( Str( Year( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"Ejercicio"
   ::cBuffer   += Str( ::nContadorAsiento ) + ::cConector  //"Asiento"
   ::cBuffer   += "D" + ::cConector  //"CargoAbono"
   ::cBuffer   += ::SubCtaCaja + ::cConector  //"CodigoCuenta"
   ::cBuffer   += "" + ::cConector  //"Contrapartida"
   ::cBuffer   += dToc( ( D():FacturasClientes( ::nView ) )->dFecFac ) + ::cConector  //"Fechaasiento"
   ::cBuffer   += "" + ::cConector  //"TipoDocumento"
   ::cBuffer   += "" + ::cConector  //"DocumentoConta"
   ::cBuffer   += "RECIBO N/F." + AllTrim( ::cNumero() ) + ::cConector  //"Comentario"
   ::cBuffer   += ::cFormatoImporte( ::aTotales[ 4 ] ) + ::cConector  //"ImporteAsiento"
   ::cBuffer   += "100" + ::cConector  //"CodigoDiario"
   ::cBuffer   += "" + ::cConector  //"CodigoCanal"
   ::cBuffer   += AllTrim( Str( Month( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"NumeroPeriodo"
   ::cBuffer   += Str( ::nContadorLinea ) + ::cConector  //"OrdenMovimientos"
   ::cBuffer   += "0" + ::cConector  //"EjercicioFactura"
   ::cBuffer   += "" + ::cConector  //"SerieFactura"
   ::cBuffer   += "" + ::cConector //"NumeroFactura"
   ::cBuffer   += "" + ::cConector  //"FechaFactura"
   ::cBuffer   += "" + ::cConector  //"TipoFactura"
   ::cBuffer   += "" + ::cConector  //"FechaOperacion"
   ::cBuffer   += "" + ::cConector  //"SuFacturaNo"
   ::cBuffer   += "" + ::cConector  //"BaseIva1"
   ::cBuffer   += "" + ::cConector  //"BaseIva2"
   ::cBuffer   += "" + ::cConector  //"BaseIva3"
   ::cBuffer   += "" + ::cConector  //"CuotaIva1"
   ::cBuffer   += "" + ::cConector  //"CuotaIva2"
   ::cBuffer   += "" + ::cConector  //"CuotaIva3"
   ::cBuffer   += "" + ::cConector  //"PorIva1"
   ::cBuffer   += "" + ::cConector  //"PorIva2"
   ::cBuffer   += "" + ::cConector  //"PorIva3"
   ::cBuffer   += dtoc( GetSysDate() ) + ::cConector  //"FechaGrabacion"
   ::cBuffer   += "" + ::cConector  //"CifDNI"
   ::cBuffer   += "" + ::cConector  //"ImporteFactura"
   ::cBuffer   += "" + ::cConector  //"ImporteRetencion"
   ::cBuffer   += "" + ::cConector  //"Nombre"
   ::cBuffer   += "" + ::cConector  //"CodigoCuentaFactura"
   ::cBuffer   += "" + ::cConector  //"LibreA1"
   ::cBuffer   += "" + ::cConector  //"Base Recargo"
   ::cBuffer   += "" + ::cConector  //"Cuota Recargo"
   ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia1"
   ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia2"
   ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia3"
   ::cBuffer   += "" + CRLF         //"PorRecargoEquivalencia4"

   ::nContadorLinea ++

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addIva() CLASS EnlaceSage

   local aIva

   for each aIva in ::aTotalesIva

      //if aIva[3] != nil .and. aIva[2] != 0
      if hGet( aIva, "porcentajeiva" ) != nil

         ::cBuffer   += cCodEmpCnt( "A" ) + ::cConector  //"CodigoEmpresa"
         ::cBuffer   += AllTrim( Str( Year( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"Ejercicio"
         ::cBuffer   += Str( ::nContadorAsiento ) + ::cConector  //"Asiento"
         ::cBuffer   += "H" + ::cConector  //"CargoAbono"
         ::cBuffer   += ::CuentaIva( hget( aIva, "porcentajeiva" ) ) + ::cConector  //"CodigoCuenta"
         ::cBuffer   += "" + ::cConector  //"Contrapartida"
         ::cBuffer   += dToc( ( D():FacturasClientes( ::nView ) )->dFecFac ) + ::cConector  //"Fechaasiento"
         ::cBuffer   += "" + ::cConector  //"TipoDocumento"
         ::cBuffer   += "" + ::cConector  //"DocumentoConta"
         ::cBuffer   += "N/F." + AllTrim( ::cNumero() ) + ::cConector  //"Comentario"
         ::cBuffer   += ::cFormatoImporte( hGet( aIva, "impiva" ) ) + ::cConector  //"ImporteAsiento"
         ::cBuffer   += "100" + ::cConector  //"CodigoDiario"
         ::cBuffer   += "" + ::cConector  //"CodigoCanal"
         ::cBuffer   += AllTrim( Str( Month( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"NumeroPeriodo"
         ::cBuffer   += Str( ::nContadorLinea ) + ::cConector  //"OrdenMovimientos"
         ::cBuffer   += "0" + ::cConector  //"EjercicioFactura"
         ::cBuffer   += "" + ::cConector  //"SerieFactura"
         ::cBuffer   += "" + ::cConector //"NumeroFactura"
         ::cBuffer   += "" + ::cConector  //"FechaFactura"
         ::cBuffer   += "" + ::cConector  //"TipoFactura"
         ::cBuffer   += "" + ::cConector  //"FechaOperacion"
         ::cBuffer   += "" + ::cConector  //"SuFacturaNo"
         ::cBuffer   += "" + ::cConector  //"BaseIva1"
         ::cBuffer   += "" + ::cConector  //"BaseIva2"
         ::cBuffer   += "" + ::cConector  //"BaseIva3"
         ::cBuffer   += "" + ::cConector  //"CuotaIva1"
         ::cBuffer   += "" + ::cConector  //"CuotaIva2"
         ::cBuffer   += "" + ::cConector  //"CuotaIva3"
         ::cBuffer   += "" + ::cConector  //"PorIva1"
         ::cBuffer   += "" + ::cConector  //"PorIva2"
         ::cBuffer   += "" + ::cConector  //"PorIva3"
         ::cBuffer   += dtoc( GetSysDate() ) + ::cConector  //"FechaGrabacion"
         ::cBuffer   += "" + ::cConector  //"CifDNI"
         ::cBuffer   += "" + ::cConector  //"ImporteFactura"
         ::cBuffer   += "" + ::cConector  //"ImporteRetencion"
         ::cBuffer   += "" + ::cConector  //"Nombre"
         ::cBuffer   += "" + ::cConector  //"CodigoCuentaFactura"
         ::cBuffer   += "" + ::cConector  //"LibreA1"
         ::cBuffer   += "" + ::cConector  //"Base Recargo"
         ::cBuffer   += "" + ::cConector  //"Cuota Recargo"
         ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia1"
         ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia2"
         ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia3"
         ::cBuffer   += "" + CRLF         //"PorRecargoEquivalencia4"
      
         ::nContadorLinea ++

      end if

   next

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addRe() CLASS EnlaceSage

   local aIva

   for each aIva in ::aTotalesIva

      //if aIva[3] != nil .and. aIva[2] != 0
      if hGet( aIva, "porcentajeiva" ) != nil

         ::cBuffer   += cCodEmpCnt( "A" ) + ::cConector  //"CodigoEmpresa"
         ::cBuffer   += AllTrim( Str( Year( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"Ejercicio"
         ::cBuffer   += Str( ::nContadorAsiento ) + ::cConector  //"Asiento"
         ::cBuffer   += "H" + ::cConector  //"CargoAbono"
         ::cBuffer   += ::CuentaRe( hget( aIva, "porcentajeiva" ) ) + ::cConector  //"CodigoCuenta"
         ::cBuffer   += "" + ::cConector  //"Contrapartida"
         ::cBuffer   += dToc( ( D():FacturasClientes( ::nView ) )->dFecFac ) + ::cConector  //"Fechaasiento"
         ::cBuffer   += "" + ::cConector  //"TipoDocumento"
         ::cBuffer   += "" + ::cConector  //"DocumentoConta"
         ::cBuffer   += "N/F." + AllTrim( ::cNumero() ) + ::cConector  //"Comentario"
         ::cBuffer   += ::cFormatoImporte( hGet( aIva, "impre" ) ) + ::cConector  //"ImporteAsiento"
         ::cBuffer   += "100" + ::cConector  //"CodigoDiario"
         ::cBuffer   += "" + ::cConector  //"CodigoCanal"
         ::cBuffer   += AllTrim( Str( Month( ( D():FacturasClientes( ::nView ) )->dFecFac ) ) ) + ::cConector  //"NumeroPeriodo"
         ::cBuffer   += Str( ::nContadorLinea ) + ::cConector  //"OrdenMovimientos"
         ::cBuffer   += "0" + ::cConector  //"EjercicioFactura"
         ::cBuffer   += "" + ::cConector  //"SerieFactura"
         ::cBuffer   += "" + ::cConector //"NumeroFactura"
         ::cBuffer   += "" + ::cConector  //"FechaFactura"
         ::cBuffer   += "" + ::cConector  //"TipoFactura"
         ::cBuffer   += "" + ::cConector  //"FechaOperacion"
         ::cBuffer   += "" + ::cConector  //"SuFacturaNo"
         ::cBuffer   += "" + ::cConector  //"BaseIva1"
         ::cBuffer   += "" + ::cConector  //"BaseIva2"
         ::cBuffer   += "" + ::cConector  //"BaseIva3"
         ::cBuffer   += "" + ::cConector  //"CuotaIva1"
         ::cBuffer   += "" + ::cConector  //"CuotaIva2"
         ::cBuffer   += "" + ::cConector  //"CuotaIva3"
         ::cBuffer   += "" + ::cConector  //"PorIva1"
         ::cBuffer   += "" + ::cConector  //"PorIva2"
         ::cBuffer   += "" + ::cConector  //"PorIva3"
         ::cBuffer   += dtoc( GetSysDate() ) + ::cConector  //"FechaGrabacion"
         ::cBuffer   += "" + ::cConector  //"CifDNI"
         ::cBuffer   += "" + ::cConector  //"ImporteFactura"
         ::cBuffer   += "" + ::cConector  //"ImporteRetencion"
         ::cBuffer   += "" + ::cConector  //"Nombre"
         ::cBuffer   += "" + ::cConector  //"CodigoCuentaFactura"
         ::cBuffer   += "" + ::cConector  //"LibreA1"
         ::cBuffer   += "" + ::cConector  //"Base Recargo"
         ::cBuffer   += "" + ::cConector  //"Cuota Recargo"
         ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia1"
         ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia2"
         ::cBuffer   += "" + ::cConector  //"PorRecargoEquivalencia3"
         ::cBuffer   += "" + CRLF         //"PorRecargoEquivalencia4"
      
         ::nContadorLinea ++

      end if

   next

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD CuentaIva( nIva ) CLASS EnlaceSage

   local cSubCta := ""

      do case
         case nIva == 21
            if !( D():FacturasClientes( ::nView ) )->lRecargo
               cSubCta  := ::SubCtaVtaIva21
            else
               cSubCta  := ::SubCtaVtaIvaRe21
            end if

         case nIva == 10

            if !( D():FacturasClientes( ::nView ) )->lRecargo
               cSubCta  := ::SubCtaVtaIva10
            else
               cSubCta  := ::SubCtaVtaIvaRe10
            end if

         case nIva == 4

            if !( D():FacturasClientes( ::nView ) )->lRecargo
               cSubCta  := ::SubCtaVtaIva4
            else
               cSubCta  := ::SubCtaVtaIvaRe4
            end if

         case nIva == 0

            if !( D():FacturasClientes( ::nView ) )->lRecargo
               cSubCta  := ::SubCtaVtaIva0
            else
               cSubCta  := ::SubCtaVtaIvaRe0
            end if

         case nIva == 2

            if !( D():FacturasClientes( ::nView ) )->lRecargo
               cSubCta  := ::SubCtaVtaIva2
            else
               cSubCta  := ::SubCtaVtaIvaRe2
            end if

         case nIva == 7.5

            if !( D():FacturasClientes( ::nView ) )->lRecargo
               cSubCta  := ::SubCtaVtaIva75
            else
               cSubCta  := ::SubCtaVtaIvaRe75
            end if

         case nIva == 5

            if !( D():FacturasClientes( ::nView ) )->lRecargo
               cSubCta  := ::SubCtaVtaIva5
            else
               cSubCta  := ::SubCtaVtaIvaRe5
            end if

      end case

RETURN ( cSubCta )

//-------------------------------------------------------------------------------------//

METHOD CuentaRe( nIva ) CLASS EnlaceSage

   local cSubCta := ""

      do case
         case nIva == 21
               cSubCta  := "4750052"

         case nIva == 10
               cSubCta  := "4750014"

         case nIva == 4
               cSubCta  := "4750050"

         case nIva == 0
               cSubCta  := "4750099"

         case nIva == 2
               cSubCta  := "4750026"

         case nIva == 7.5
               cSubCta  := "4750751"

         case nIva == 5
               cSubCta  := "4750062"

      end case

RETURN ( cSubCta )

//---------------------------------------------------------------------------//

METHOD cFormatoImporte( nImporte ) CLASS EnlaceSage

   local cImporte    := ""

   cImporte          := AllTrim( Trans( nImporte, cPorDiv() ) )
   cImporte          := StrTran( cImporte, ".", "" )

RETURN ( cImporte )

//---------------------------------------------------------------------------//

METHOD cFormatoPorcentaje( nPorcentaje ) CLASS EnlaceSage

   local cPorcentaje    := ""

   cPorcentaje          := AllTrim( Trans( nPorcentaje, "@E 999.99" ) )
   cPorcentaje          := StrTran( cPorcentaje, ".", "" )

RETURN ( cPorcentaje )

//---------------------------------------------------------------------------//

METHOD changeState() CLASS EnlaceSage

   if dbLock( ( D():FacturasClientes( ::nView ) ) )
      ( D():FacturasClientes( ::nView ) )->lContab    := .t.
      ( D():FacturasClientes( ::nView ) )->( dbUnLock() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD WriteASCII() CLASS EnlaceSage

   if Empty( ::cBuffer )
      Return ( .f. )
   end if

   ferase( ::cFullFile() )

   if !file( ::cFullFile() ) .or. empty( ::hFile )
      ::hFile     := fCreate( ::cFullFile() )
   end if 

   if !empty( ::hFile )

      fWrite( ::hFile, ::cBuffer )
      fClose( ::hFile )

      ::cBuffer   := ""

      if apoloMsgNoYes( "Proceso de exportaciÃ³n realizado con Ã©xito" + CRLF + ;
                        "en fichero " + ( ::cFullFile() )            + CRLF + ;
                        "Â¿ Desea abrir el fichero resultante ?",;
                        "Elija una opciÃ³n." )
         shellExecute( 0, "open", ( ::cDirectory + "\" + ::cFile ), , , 1 )
      end if

      Return .t.

   end if

Return ( .f. )

//---------------------------------------------------------------------------//

METHOD AddCabecera() CLASS EnlaceSage

   ::cBuffer   += "CodigoEmpresa" + ::cConector
   ::cBuffer   += "Ejercicio" + ::cConector
   ::cBuffer   += "Asiento" + ::cConector
   ::cBuffer   += "CargoAbono" + ::cConector
   ::cBuffer   += "CodigoCuenta" + ::cConector
   ::cBuffer   += "Contrapartida" + ::cConector
   ::cBuffer   += "Fechaasiento" + ::cConector
   ::cBuffer   += "TipoDocumento" + ::cConector
   ::cBuffer   += "DocumentoConta" + ::cConector
   ::cBuffer   += "Comentario" + ::cConector
   ::cBuffer   += "ImporteAsiento" + ::cConector
   ::cBuffer   += "CodigoDiario" + ::cConector
   ::cBuffer   += "CodigoCanal" + ::cConector
   ::cBuffer   += "NumeroPeriodo" + ::cConector
   ::cBuffer   += "OrdenMovimientos" + ::cConector
   ::cBuffer   += "EjercicioFactura" + ::cConector
   ::cBuffer   += "SerieFactura" + ::cConector
   ::cBuffer   += "NumeroFactura" + ::cConector
   ::cBuffer   += "FechaFactura" + ::cConector
   ::cBuffer   += "TipoFactura" + ::cConector
   ::cBuffer   += "FechaOperacion" + ::cConector
   ::cBuffer   += "SuFacturaNo" + ::cConector
   ::cBuffer   += "BaseIva1" + ::cConector
   ::cBuffer   += "BaseIva2" + ::cConector
   ::cBuffer   += "BaseIva3" + ::cConector
   ::cBuffer   += "CuotaIva1" + ::cConector
   ::cBuffer   += "CuotaIva2" + ::cConector
   ::cBuffer   += "CuotaIva3" + ::cConector
   ::cBuffer   += "PorIva1" + ::cConector
   ::cBuffer   += "PorIva2" + ::cConector
   ::cBuffer   += "PorIva3" + ::cConector
   ::cBuffer   += "FechaGrabacion" + ::cConector
   ::cBuffer   += "CifDNI" + ::cConector
   ::cBuffer   += "ImporteFactura" + ::cConector
   ::cBuffer   += "ImporteRetencion" + ::cConector
   ::cBuffer   += "Nombre" + ::cConector
   ::cBuffer   += "CodigoCuentaFactura" + ::cConector
   ::cBuffer   += "LibreA1" + ::cConector
   ::cBuffer   += "Base Recargo" + ::cConector
   ::cBuffer   += "Cuota Recargo" + ::cConector
   ::cBuffer   += "PorRecargoEquivalencia1" + ::cConector
   ::cBuffer   += "PorRecargoEquivalencia2" + ::cConector
   ::cBuffer   += "PorRecargoEquivalencia3" + ::cConector
   ::cBuffer   += "PorRecargoEquivalencia4" + CRLF

Return ( .f. )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS EnlaceMonitor

   CLASSDATA oInstance

   DATA cBuffer                           INIT ""
   DATA nView
   DATA oTree

   DATA cDirectory
   DATA cFile

   DATA cFullFile
   DATA hFile

   DATA aTotalFactura

   DATA SubCtaVtaIva21
   DATA SubCtaVtaIva0
   DATA SubCtaVtaRe

   DATA SubCtaPrvIva21
   DATA SubCtaPrvIva0
   DATA SubCtaPrvRe

   DATA aSubCtaIngresos

   METHOD New()
   METHOD GetInstance()
   METHOD destroyInstance()               INLINE ( ::oInstance := nil )

   METHOD ContabilizaFacturaCliente()
   METHOD changeStateFacturaCliente()
   METHOD WriteASCII()

   METHOD addFacturaCliente()

   METHOD cFullFile()                     INLINE ( ::cDirectory + "\" + ::cFile )

   METHOD writeTree( cText, nState )      INLINE ( ::oTree:Select( ::oTree:Add( cText, nState ) ) )

   METHOD cNumeroFacturaCliente()         INLINE ( ( D():FacturasClientes( ::nView ) )->cSerie + Str( ( D():FacturasClientes( ::nView ) )->nNumFac ) + ( D():FacturasClientes( ::nView ) )->cSufFac )
   METHOD cFormatNumeroFacturaCliente()   INLINE ( ( D():FacturasClientes( ::nView ) )->cSerie + "/" + AllTrim( Str( ( D():FacturasClientes( ::nView ) )->nNumFac ) ) + "/" + ( D():FacturasClientes( ::nView ) )->cSufFac )

   METHOD cFormatoImporte()
   METHOD cFormatoPorcentaje()

   METHOD getSubcuentaCliente()
   METHOD getSubcuentaRet()

   METHOD getSubCtaIngresosFacturaClientes()

   METHOD ContabilizaFacturaProveedor()

   METHOD cNumeroFacturaProveedor()         INLINE ( ( D():FacturasProveedores( ::nView ) )->cSerFac + Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ) + ( D():FacturasProveedores( ::nView ) )->cSufFac )
   METHOD cFormatNumeroFacturaProveedor()   INLINE ( ( D():FacturasProveedores( ::nView ) )->cSerFac + "/" + AllTrim( Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ) ) + "/" + ( D():FacturasProveedores( ::nView ) )->cSufFac )

   METHOD getSubCtaIngresosFacturaProveedor()

   METHOD addFacturaProveedor()
   METHOD changeStateFacturaProveedor()

   METHOD getSubcuentaProveedor()

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS EnlaceMonitor

   if empty( cRutCnt() )
      ::cDirectory                     := "C:\ENLACEMONITOR"
   else
      ::cDirectory                     := cRutCnt()
   end if 

   ::cFile                             := "ENLACEMONITOR" + dtos( getsysdate() ) + ".MMB" 

   ::cBuffer                           := ""
   ::aTotalFactura                     := {}
   ::aSubCtaIngresos                   := {}

   ::SubCtaVtaIva21                    := "4770002100      "
   ::SubCtaVtaIva0                     := "4770888888      "
   ::SubCtaVtaRe                       := "4770005221      "
   
   ::SubCtaPrvIva21                    := "4720002100      "
   ::SubCtaPrvIva0                     := "4770999991      "
   ::SubCtaPrvRe                       := "4720005221      "

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD GetInstance() CLASS EnlaceMonitor

   if empty( ::oInstance )
      ::oInstance                      := ::New()
   end if

RETURN ( ::oInstance )

//---------------------------------------------------------------------------//

METHOD ContabilizaFacturaCliente( nView, oTree ) CLASS EnlaceMonitor

   ::nView     := nView
   ::oTree     := oTree

   if ( D():FacturasClientes( ::nView ) )->lContab
      ::writeTree( "Factura anteriormente contabilizada : " + ::cFormatNumeroFacturaCliente(), 0 )
      Return ( Self )
   end if

   ::aTotalFactura      := aTotFacCli( ::cNumeroFacturaCliente(),;
                                       D():FacturasClientes( ::nView ),;
                                       D():FacturasClientesLineas( ::nView ),;
                                       D():TiposIva( ::nView ),;
                                       D():Divisas( ::nView ),;
                                       D():FacturasClientesCobros( ::nView ),;
                                       D():AnticiposClientes( ::nView ) )


   ::getSubCtaIngresosFacturaClientes()

   aEval( ::aSubCtaIngresos, {|h| ::addFacturaCliente( h ) } )

   ::writeTree( "Factura contabilizada : " + ::cFormatNumeroFacturaCliente(), 1 )

   ::changeStateFacturaCliente()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addFacturaCliente( hHash ) CLASS EnlaceMonitor

   ::cBuffer   += if( len( ::aSubCtaIngresos ) > 1, "VM", "V " )                                                                                                        //Tipo de Factura                Long 2      Obligatorio
   ::cBuffer   += padr( dToc( ( D():FacturasClientes( ::nView ) )->dFecFac ), 10 )                                                                                      //Fecha del asiento              Long 10     Obligatorio
   ::cBuffer   += padr( dToc( ( D():FacturasClientes( ::nView ) )->dFecFac ), 10 )                                                                                      //Fecha de la factura            Long 10     Obligatorio
   ::cBuffer   += Space( 10 )                                                                                                                                           //Número de registro             Long 10
   ::cBuffer   += Padr( ( D():FacturasClientes( ::nView ) )->cSerie + Str( ( D():FacturasClientes( ::nView ) )->nNumFac ), 10 )                                         //Número de la factura           Long 10     Obligatorio
   ::cBuffer   += Space( 2 )                                                                                                                                            //Tipo de operación              Long 2
   ::cBuffer   += ::getSubcuentaCliente()                                                                                                                               //Subcuenta del cliente          Long 16     Obligatorio
   ::cBuffer   += Padr( SubStr( ( D():FacturasClientes( ::nView ) )->cDniCli, 1, 14 ), 14 )                                                                             //Nif del cliente                Long 14     Obligatorio
   ::cBuffer   += Padr( SubStr( ( D():FacturasClientes( ::nView ) )->cNomCli, 1, 30 ), 30 )                                                                             //Nombre del cliente             Long 30     Obligatorio
   ::cBuffer   += Padr( "N/Fcta. N. " + ::cFormatNumeroFacturaCliente(), 40 )                                                                                           //Concepto del asiento           Long 40
   ::cBuffer   += padr( ::cFormatoImporte( hGet( hHash, "importe" ) ), 15 )                                                                                             //Base imponible                 Long 15     Obligatorio
   ::cBuffer   += padr( ::cFormatoPorcentaje( hGet( ::aTotalFactura[8][1], "porcentajeiva" ) ), 5 )                                                                     //Porcentaje del I.V.A.          Long 5      Obligatorio
   ::cBuffer   += padr( ::cFormatoImporte( hGet( hHash, "iva" ) ), 15 )                                                                                                 //Importe del I.V.A.             Long 15     Obligatorio
   ::cBuffer   += if( hGet( ::aTotalFactura[8][1], "porcentajeiva" ) == 0, ::SubCtaVtaIva0, ::SubCtaVtaIva21 )                                                          //Subcuenta del I.V.A.           Long 16     Obligatorio si % I.V.A. > 0
   ::cBuffer   += if( ( D():FacturasClientes( ::nView ) )->lRecargo, padr( ::cFormatoPorcentaje( hGet( ::aTotalFactura[8][1], "porcentajere" ) ), 5 ), Space( 5 ) )     //Porcentaje R.E.                Long 5
   ::cBuffer   += if( ( D():FacturasClientes( ::nView ) )->lRecargo, padr( ::cFormatoImporte( ::aTotalFactura[ 3 ] ), 15 ), Space( 15 ) )                               //Importe R.E.                   Long 15
   ::cBuffer   += if( ( D():FacturasClientes( ::nView ) )->lRecargo, ::SubCtaVtaRe, Space( 16 ) )                                                                       //Subcuenta del R.E.             Long 16     Obligatorio si % R.E. > 0
   ::cBuffer   += if( ( D():FacturasClientes( ::nView ) )->nPctRet != 0, padr( ::cFormatoPorcentaje( ( D():FacturasClientes( ::nView ) )->nPctRet ), 5 ), Space( 5 ) )  //Porcentaje de retención        Long 5
   ::cBuffer   += if( ( D():FacturasClientes( ::nView ) )->nPctRet != 0, padr( ::cFormatoImporte( ::aTotalFactura[ 12 ] ), 15 ), Space( 15 ) )                          //Importe retención              Long 15
   ::cBuffer   += if( ( D():FacturasClientes( ::nView ) )->nPctRet != 0, ::getSubcuentaRet(), Space( 16 ) )                                                             //Subcuenta del retención        Long 16     Obligatorio si % retención > 0
   ::cBuffer   += padr( ::cFormatoImporte( ::aTotalFactura[ 4 ] ), 15 )                                                                                                 //Total factura                  Long 15     Obligatorio
   ::cBuffer   += Space( 1 )                                                                                                                                            //Identificador de rectificativa Long 1      "X" o blanco
   ::cBuffer   += Padr( hGet( hHash, "cuenta" ), 16 )                                                                                                                   //Subcuenta del ingreso          Long 16     Obligatorio
   ::cBuffer   += padr( ::cFormatoImporte( hGet( hHash, "importe" ) ), 15 )                                                                                             //Importe del ingreso            Long 15     Obligatorio
   ::cBuffer   += Padr( SubStr( ( D():FacturasClientes( ::nView ) )->cDirCli, 1, 30 ), 30 )                                                                             //Domicilio del cliente          Long 30
   ::cBuffer   += Space( 10 )                                                                                                                                           //Número, escalera....           Long 10
   ::cBuffer   += Padr( SubStr( ( D():FacturasClientes( ::nView ) )->cPobCli, 1, 30 ), 30 )                                                                             //Localidad del cliente          Long 30
   ::cBuffer   += Padr( SubStr( ( D():FacturasClientes( ::nView ) )->cPrvCli, 1, 30 ), 30 )                                                                             //Provincia del cliente          Long 30
   ::cBuffer   += Padr( SubStr( ( D():FacturasClientes( ::nView ) )->cPosCli, 1, 5 ), 5 )                                                                               //Código postal del cliente      Long 5
   ::cBuffer   += "N"                                                                                                                                                   //Flag de cobro al contado       Long 1      blanco, "S", "N"
   ::cBuffer   += Space( 16 )                                                                                                                                           //Subcuenta debe de cobro        Long 16     Obligatorio si es contado
   ::cBuffer   += Space( 16 )                                                                                                                                           //Subcuenta haber de cobro       Long 16     Obligatorio si es contado
   ::cBuffer   += Space( 15 )                                                                                                                                           //Importe de cobro al contado    Long 15     Obligatorio si es contado
   ::cBuffer   += "N"                                                                                                                                                   //Criterio de caja               Long 1      blanco, "S", "N"
   ::cBuffer   += Space( 1 )                                                                                                                                            //Medio de Rodriguez             Long 1      Obligatorio si criterio de caja
   ::cBuffer   += Space( 35 )                                                                                                                                           //Descripción del pago           Long 35     Obligatorio si criterio de caja
   ::cBuffer   += "N"                                                                                                                                                   //Ticket                         Long 1      Oblihatorio S/N
   ::cBuffer   += "N"                                                                                                                                                   //Comunicada S/N                 Long 1      Obligatorio SII
   ::cBuffer   += Space( 16 )                                                                                                                                           //Subcuenta IVA no deducible N   Long 16     Obligatorio si T. O. 18  NEW
   ::cBuffer   += Space( 15 )                                                                                                                                           //Importe de IVA no deducible N  Long 15     Obligatorio si T. O. 18  NEW
   ::cBuffer   += "X"                                                                                                                                                   //Código de control              Long 1      Obligatorio siempre una X
   ::cBuffer   += Space( 60 )                                                                                                                                           //Número Fac ampliado            Long 60     Vacío  NEW
   ::cBuffer   += Space( 2 )                                                                                                                                           //Código de pais para Fact. Ventanilla Única              Long 2     Vacío  NEW
   ::cBuffer   += Space( 1 )                                                                                                                                           //Tipo de IVA Fact. Ventanilla Única                      Long 1     "S" (Estandar) o "R" (Reducido) NEW
   ::cBuffer   += Space( 4 )                                                                                                                                           //Año del ejercicio para Fact. Ventanilla Única           Long 4     Solo si Rectificativa  NEW
   ::cBuffer   += Space( 1 )                                                                                                                                           //Periodo del Ejercicio para Fact. Ventanilla Única       Long 1     Vacío Solo si Rectificativa NEW
   ::cBuffer   += Space( 144 )                                                                                                                                         //Reserva                        Long 233    Blanco

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getSubCtaIngresosFacturaClientes() CLASS EnlaceMonitor

   local nPos           := 0
   local cCnt           := ""
   local cCuenta        := ""
   local nRecAnt        := ( D():FacturasClientesLineas( ::nView ) )->( Recno() )
   local nOrdAnt        := ( D():FacturasClientesLineas( ::nView ) )->( OrdSetFocus( "nNumFac" ) )

   ::aSubCtaIngresos       := {}

   if ( D():FacturasClientesLineas( ::nView ) )->( dbSeek( ::cNumeroFacturaCliente() ) )

      while ( D():FacturasClientesLineas( ::nView ) )->cSerie + Str( ( D():FacturasClientesLineas( ::nView ) )->nNumFac ) + ( D():FacturasClientesLineas( ::nView ) )->cSufFac == ::cNumeroFacturaCliente() .and.;
            !( D():FacturasClientesLineas( ::nView ) )->( Eof() )

            if !Empty( ( D():FacturasClientesLineas( ::nView ) )->cRef )

               cCnt           := retCtaVta( ( D():FacturasClientesLineas( ::nView ) )->cRef, .f., D():Articulos( ::nView ) ) 

               cCuenta        := SubStr( cCnt, 1, 3 ) + "0" + SubStr( cCnt, 4 )

               nPos           := aScan( ::aSubCtaIngresos, {|h| hGet( h, "cuenta" ) == cCuenta } )
               
               if nPos == 0
                  aAdd( ::aSubCtaIngresos, { "cuenta" => cCuenta,;
                                             "importe" => nTotLFacCli( D():FacturasClientesLineas( ::nView ) ),;
                                             "iva" => nIvaLFacCli( D():FacturasClientesLineas( ::nView ) ) } )
               else
                  hSet( ::aSubCtaIngresos[ nPos ], "importe", hGet( ::aSubCtaIngresos[ nPos ], "importe" ) + nTotLFacCli( D():FacturasClientesLineas( ::nView ) ) )
                  hSet( ::aSubCtaIngresos[ nPos ], "iva", hGet( ::aSubCtaIngresos[ nPos ], "iva" ) + nIvaLFacCli( D():FacturasClientesLineas( ::nView ) ) )
               end if

            end if

            ( D():FacturasClientesLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ( D():FacturasClientesLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():FacturasClientesLineas( ::nView ) )->( dbGoTo( nRecAnt ) )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getSubcuentaCliente() CLASS EnlaceMonitor

   local cSubCta := cCliCta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) )

RETURN ( Padr( cSubCta, 16 ) )

//---------------------------------------------------------------------------//

METHOD getSubcuentaProveedor() CLASS EnlaceMonitor

   local cSubCta := cPrvCta( ( D():FacturasProveedores( ::nView ) )->cCodPrv, D():Proveedores( ::nView ) )

RETURN ( Padr( cSubCta, 16 ) )

//---------------------------------------------------------------------------//

METHOD getSubcuentaRet() CLASS EnlaceMonitor

   local cSubCta := cCtaRet()

RETURN ( Padr( cSubCta, 16 ) )

//---------------------------------------------------------------------------//

METHOD ContabilizaFacturaProveedor( nView, oTree ) CLASS EnlaceMonitor

   ::nView     := nView
   ::oTree     := oTree

   if ( D():FacturasProveedores( ::nView ) )->lContab
      ::writeTree( "Factura anteriormente contabilizada : " + ::cFormatNumeroFacturaProveedor(), 0 )
      Return ( Self )
   end if

   ::aTotalFactura      := aTotFacPrv( ::cNumeroFacturaProveedor(),;
                                       D():FacturasProveedores( ::nView ),;
                                       D():FacturasProveedoresLineas( ::nView ),;
                                       D():TiposIva( ::nView ),;
                                       D():Divisas( ::nView ),;
                                       D():FacturasProveedoresPagos( ::nView ) )


   ::getSubCtaIngresosFacturaProveedor()

   aEval( ::aSubCtaIngresos, {|h| ::addFacturaProveedor( h ) } )

   ::writeTree( "Factura contabilizada : " + ::cFormatNumeroFacturaProveedor(), 1 )

   ::changeStateFacturaProveedor()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD getSubCtaIngresosFacturaProveedor() CLASS EnlaceMonitor

   local nPos           := 0
   local cCnt           := ""
   local cCuenta        := ""
   local nRecAnt        := ( D():FacturasProveedoresLineas( ::nView ) )->( Recno() )
   local nOrdAnt        := ( D():FacturasProveedoresLineas( ::nView ) )->( OrdSetFocus( "nNumFac" ) )

   ::aSubCtaIngresos       := {}

   if ( D():FacturasProveedoresLineas( ::nView ) )->( dbSeek( ::cNumeroFacturaProveedor() ) )

      while ( D():FacturasProveedoresLineas( ::nView ) )->cSerFac + Str( ( D():FacturasProveedoresLineas( ::nView ) )->nNumFac ) + ( D():FacturasProveedoresLineas( ::nView ) )->cSufFac == ::cNumeroFacturaProveedor() .and.;
            !( D():FacturasProveedoresLineas( ::nView ) )->( Eof() )

            if !Empty( ( D():FacturasProveedoresLineas( ::nView ) )->cRef )

               cCnt           := RetCtaCom( ( D():FacturasProveedoresLineas( ::nView ) )->cRef, .f., D():Articulos( ::nView ) ) 

               cCuenta        := SubStr( cCnt, 1, 3 ) + "0" + SubStr( cCnt, 4 )

               nPos           := aScan( ::aSubCtaIngresos, {|h| hGet( h, "cuenta" ) == cCuenta } )
               
               if nPos == 0
                  aAdd( ::aSubCtaIngresos, { "cuenta" => cCuenta,;
                                             "importe" => nTotLFacPrv( D():FacturasProveedoresLineas( ::nView ) ),;
                                             "iva" => nIvaLFacPrv( D():FacturasProveedoresLineas( ::nView ) ) } )
               else
                  hSet( ::aSubCtaIngresos[ nPos ], "importe", hGet( ::aSubCtaIngresos[ nPos ], "importe" ) + nTotLFacPrv( D():FacturasProveedoresLineas( ::nView ) ) )
                  hSet( ::aSubCtaIngresos[ nPos ], "iva", hGet( ::aSubCtaIngresos[ nPos ], "iva" ) + nIvaLFacPrv( D():FacturasProveedoresLineas( ::nView ) ) )
               end if

            end if

            ( D():FacturasProveedoresLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ( D():FacturasProveedoresLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():FacturasProveedoresLineas( ::nView ) )->( dbGoTo( nRecAnt ) )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addFacturaProveedor( hHash ) CLASS EnlaceMonitor

   ::cBuffer   += if( len( ::aSubCtaIngresos ) > 1, "CM", "C " )                                                                                                                    //Tipo de Factura                Long 2      Obligatorio
   ::cBuffer   += padr( dToc( ( D():FacturasProveedores( ::nView ) )->dFecEnt ), 10 )                                                                                               //Fecha del asiento              Long 10     Obligatorio
   ::cBuffer   += padr( dToc( ( D():FacturasProveedores( ::nView ) )->dFecFac ), 10 )                                                                                               //Fecha de la factura            Long 10     Obligatorio
   ::cBuffer   += Padr( AllTrim( ( D():FacturasProveedores( ::nView ) )->cNumDoc ), 10 )                                                                                            //Número de registro             Long 10
   ::cBuffer   += Padr( if( Empty( AllTrim( ( D():FacturasProveedores( ::nView ) )->cSuPed ) ), ( D():FacturasProveedores( ::nView ) )->cSerFac + Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ), AllTrim( ( D():FacturasProveedores( ::nView ) )->cSuPed ) ), 10 )   //Número de la factura           Long 10     Obligatorio
   ::cBuffer   += Space( 2 )                                                                                                                                                        //Tipo de operación              Long 2
   ::cBuffer   += ::getSubcuentaProveedor()                                                                                                                                         //Subcuenta del cliente          Long 16     Obligatorio
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cDniPrv, 1, 14 ), 14 )                                                                                      //Nif del cliente                Long 14     Obligatorio
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cNomPrv, 1, 30 ), 30 )                                                                                      //Nombre del cliente             Long 30     Obligatorio
   ::cBuffer   += Padr( "S/Fcta. N. " + AllTrim( ( D():FacturasProveedores( ::nView ) )->cSuPed ) + Space( 1 ) + AllTrim( ( D():FacturasProveedores( ::nView ) )->cNomPrv ), 40 )   //Concepto del asiento           Long 40
   ::cBuffer   += padr( ::cFormatoImporte( hGet( hHash, "importe" ) ), 15 )                                                                                                         //Base imponible                 Long 15     Obligatorio
   ::cBuffer   += padr( ::cFormatoPorcentaje( hGet( ::aTotalFactura[5][1], "porcentajeiva" ) ), 5 )                                                                                 //Porcentaje del I.V.A.          Long 5      Obligatorio
   ::cBuffer   += padr( ::cFormatoImporte( hGet( hHash, "iva" ) ), 15 )                                                                                                             //Importe del I.V.A.             Long 15     Obligatorio
   ::cBuffer   += if( hGet( ::aTotalFactura[5][1], "porcentajeiva" ) == 0, ::SubCtaPrvIva0, ::SubCtaPrvIva21 )                                                                      //Subcuenta del I.V.A.           Long 16     Obligatorio si % I.V.A. > 0
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->lRecargo, padr( ::cFormatoPorcentaje( hGet( ::aTotalFactura[5][1], "porcentajere" ) ), 5 ), Space( 5 ) )              //Porcentaje R.E.                Long 5
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->lRecargo, padr( ::cFormatoImporte( ::aTotalFactura[ 3 ] ), 15 ), Space( 15 ) )                                        //Importe R.E.                   Long 15
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->lRecargo, ::SubCtaPrvRe, Space( 16 ) )                                                                                //Subcuenta del R.E.             Long 16     Obligatorio si % R.E. > 0
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->nPctRet != 0, padr( ::cFormatoPorcentaje( ( D():FacturasProveedores( ::nView ) )->nPctRet ), 5 ), Space( 5 ) )        //Porcentaje de retención        Long 5
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->nPctRet != 0, padr( ::cFormatoImporte( ::aTotalFactura[ 6 ] ), 15 ), Space( 15 ) )                                    //Importe retención              Long 15
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->nPctRet != 0, ::getSubcuentaRet(), Space( 16 ) )                                                                      //Subcuenta del retención        Long 16     Obligatorio si % retención > 0
   ::cBuffer   += padr( ::cFormatoImporte( ::aTotalFactura[ 4 ] ), 15 )                                                                                                             //Total factura                  Long 15     Obligatorio
   ::cBuffer   += Space( 1 )                                                                                                                                                        //Identificador de rectificativa Long 1      "X" o blanco
   ::cBuffer   += Padr( hGet( hHash, "cuenta" ), 16 )                                                                                                                               //Subcuenta del ingreso          Long 16     Obligatorio
   ::cBuffer   += padr( ::cFormatoImporte( hGet( hHash, "importe" ) ), 15 )                                                                                                         //Importe del ingreso            Long 15     Obligatorio
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cDirPrv, 1, 30 ), 30 )                                                                                      //Domicilio del cliente          Long 30
   ::cBuffer   += Space( 10 )                                                                                                                                                       //Número, escalera....           Long 10
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cPobPrv, 1, 30 ), 30 )                                                                                      //Localidad del cliente          Long 30
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cProvProv, 1, 30 ), 30 )                                                                                    //Provincia del cliente          Long 30
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cPosPrv, 1, 5 ), 5 )                                                                                        //Código postal del cliente      Long 5
   ::cBuffer   += Space( 1 )                                                                                                                                                        //Flag de cobro al contado       Long 1      blanco, "S", "N"
   ::cBuffer   += Space( 16 )                                                                                                                                                       //Subcuenta debe de cobro        Long 16     Obligatorio si es contado
   ::cBuffer   += Space( 16 )                                                                                                                                                       //Subcuenta haber de cobro       Long 16     Obligatorio si es contado
   ::cBuffer   += Space( 15 )                                                                                                                                                       //Importe de cobro al contado    Long 15     Obligatorio si es contado
   ::cBuffer   += "N"                                                                                                                                                               //Criterio de caja               Long 1      blanco, "S", "N"
   ::cBuffer   += Space( 1 )                                                                                                                                                        //Medio de Rodriguez             Long 1      Obligatorio si criterio de caja
   ::cBuffer   += Space( 35 )                                                                                                                                                       //Descripción del pago           Long 35     Obligatorio si criterio de caja
   ::cBuffer   += Space( 1 )                                                                                                                                                               //Ticket                         Long 1      Oblihatorio S/N
   ::cBuffer   += Space( 1 )                                                                                                                                                               //Comunicada S/N                 Long 1      Obligatorio SII
   ::cBuffer   += Space( 16 )                                                                                                                                                       //Subcuenta IVA no deducible N   Long 16     Obligatorio si T. O. 18  NEW
   ::cBuffer   += Space( 15 )                                                                                                                                                       //Importe de IVA no deducible N  Long 15     Obligatorio si T. O. 18  NEW
   ::cBuffer   += "X"                                                                                                                                                               //Código de control              Long 1      Obligatorio siempre una X
   ::cBuffer   += Space( 60 )                                                                                                                                                       //Número Fac ampliado            Long 60     Vacío  NEW
   ::cBuffer   += Space( 2 )                                                                                                                                                        //Código de pais para Fact. Ventanilla Única              Long 2     Vacío  NEW
   ::cBuffer   += Space( 1 )                                                                                                                                                        //Tipo de IVA Fact. Ventanilla Única                      Long 1     "S" (Estandar) o "R" (Reducido) NEW
   ::cBuffer   += Space( 4 )                                                                                                                                                        //Año del ejercicio para Fact. Ventanilla Única           Long 4     Solo si Rectificativa  NEW
   ::cBuffer   += Space( 1 )                                                                                                                                                        //Periodo del Ejercicio para Fact. Ventanilla Única       Long 1     Vacío Solo si Rectificativa NEW
   ::cBuffer   += Space( 144 )                                                                                                                                                      //Reserva                        Long 233    Blanco




   /*ANTES DE CAMBIAR ELLOS LA ESTRUCTURA**
   ::cBuffer   += if( len( ::aSubCtaIngresos ) > 1, "CM", "C " )                                                                                                              //Tipo de Factura                Long 2      Obligatorio
   ::cBuffer   += padr( dToc( ( D():FacturasProveedores( ::nView ) )->dFecEnt ), 10 )                                                                                         //Fecha del asiento              Long 10     Obligatorio
   ::cBuffer   += padr( dToc( ( D():FacturasProveedores( ::nView ) )->dFecFac ), 10 )                                                                                         //Fecha de la factura            Long 10     Obligatorio
   ::cBuffer   += Padr( AllTrim( ( D():FacturasProveedores( ::nView ) )->cNumDoc ), 10 )                                                                                      //Número de registro             Long 10
   ::cBuffer   += Padr( if( Empty( AllTrim( ( D():FacturasProveedores( ::nView ) )->cSuPed ) ), ( D():FacturasProveedores( ::nView ) )->cSerFac + Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ), AllTrim( ( D():FacturasProveedores( ::nView ) )->cSuPed ) ), 10 )                                        //Número de la factura           Long 10     Obligatorio
   ::cBuffer   += Space( 2 )                                                                                                                                                  //Tipo de operación              Long 2
   ::cBuffer   += ::getSubcuentaProveedor()                                                                                                                                   //Subcuenta del cliente          Long 16     Obligatorio
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cDniPrv, 1, 14 ), 14 )                                                                                //Nif del cliente                Long 14     Obligatorio
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cNomPrv, 1, 30 ), 30 )                                                                                //Nombre del cliente             Long 30     Obligatorio
   ::cBuffer   += Padr( "S/Fcta. N. " + AllTrim( ( D():FacturasProveedores( ::nView ) )->cSuPed ) + Space( 1 ) + AllTrim( ( D():FacturasProveedores( ::nView ) )->cNomPrv ), 40 )  //Concepto del asiento           Long 40
   ::cBuffer   += padr( ::cFormatoImporte( hGet( hHash, "importe" ) ), 15 )                                                                                                   //Base imponible                 Long 15     Obligatorio
   ::cBuffer   += padr( ::cFormatoPorcentaje( hGet( ::aTotalFactura[5][1], "porcentajeiva" ) ), 5 )                                                                           //Porcentaje del I.V.A.          Long 5      Obligatorio
   ::cBuffer   += padr( ::cFormatoImporte( hGet( hHash, "iva" ) ), 15 )                                                                                                       //Importe del I.V.A.             Long 15     Obligatorio
   ::cBuffer   += if( hGet( ::aTotalFactura[5][1], "porcentajeiva" ) == 0, ::SubCtaPrvIva0, ::SubCtaPrvIva21 )                                                                //Subcuenta del I.V.A.           Long 16     Obligatorio si % I.V.A. > 0
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->lRecargo, padr( ::cFormatoPorcentaje( hGet( ::aTotalFactura[5][1], "porcentajere" ) ), 5 ), Space( 5 ) )          //Porcentaje R.E.                Long 5
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->lRecargo, padr( ::cFormatoImporte( ::aTotalFactura[ 3 ] ), 15 ), Space( 15 ) )                                  //Importe R.E.                   Long 15
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->lRecargo, ::SubCtaPrvRe, Space( 16 ) )                                                                          //Subcuenta del R.E.             Long 16     Obligatorio si % R.E. > 0
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->nPctRet != 0, padr( ::cFormatoPorcentaje( ( D():FacturasProveedores( ::nView ) )->nPctRet ), 5 ), Space( 5 ) )  //Porcentaje de retención        Long 5
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->nPctRet != 0, padr( ::cFormatoImporte( ::aTotalFactura[ 6 ] ), 15 ), Space( 15 ) )                              //Importe retención              Long 15
   ::cBuffer   += if( ( D():FacturasProveedores( ::nView ) )->nPctRet != 0, ::getSubcuentaRet(), Space( 16 ) )                                                                //Subcuenta del retención        Long 16     Obligatorio si % retención > 0
   ::cBuffer   += padr( ::cFormatoImporte( ::aTotalFactura[ 4 ] ), 15 )                                                                                                       //Total factura                  Long 15     Obligatorio
   ::cBuffer   += Space( 1 )                                                                                                                                                  //Identificador de rectificativa Long 1      "X" o blanco
   ::cBuffer   += Padr( hGet( hHash, "cuenta" ), 16 )                                                                                                                         //Subcuenta del ingreso          Long 16     Obligatorio
   ::cBuffer   += padr( ::cFormatoImporte( hGet( hHash, "importe" ) ), 15 )                                                                                                   //Importe del ingreso            Long 15     Obligatorio
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cDirPrv, 1, 30 ), 30 )                                                                                //Domicilio del cliente          Long 30
   ::cBuffer   += Space( 10 )                                                                                                                                                 //Número, escalera....           Long 10
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cPobPrv, 1, 30 ), 30 )                                                                                //Localidad del cliente          Long 30
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cProvProv, 1, 30 ), 30 )                                                                              //Provincia del cliente          Long 30
   ::cBuffer   += Padr( SubStr( ( D():FacturasProveedores( ::nView ) )->cPosPrv, 1, 5 ), 5 )                                                                                  //Código postal del cliente      Long 5
   ::cBuffer   += "N"                                                                                                                                                         //Flag de cobro al contado       Long 1      blanco, "S", "N"
   ::cBuffer   += Space( 16 )                                                                                                                                                 //Subcuenta debe de cobro        Long 16     Obligatorio si es contado
   ::cBuffer   += Space( 16 )                                                                                                                                                 //Subcuenta haber de cobro       Long 16     Obligatorio si es contado
   ::cBuffer   += Space( 15 )                                                                                                                                                 //Importe de cobro al contado    Long 15     Obligatorio si es contado
   ::cBuffer   += "N"                                                                                                                                                         //Criterio de caja               Long 1      blanco, "S", "N"
   ::cBuffer   += Space( 1 )                                                                                                                                                  //Medio de Rodriguez             Long 1      Obligatorio si criterio de caja
   ::cBuffer   += Space( 35 )                                                                                                                                                 //Descripción del pago           Long 35     Obligatorio si criterio de caja
   ::cBuffer   += "N"                                                                                                                                                         //Ticket                         Long 1      Oblihatorio S/N   
   ::cBuffer   += "N"                                                                                                                                                         //Comunicada S/N                 Long 1      Obligatorio SII
   ::cBuffer   += "X"                                                                                                                                                         //Código de control              Long 1      Obligatorio siempre una X
   ::cBuffer   += Space( 10 )                                                                                                                                                 //Reserva                        Long 39     Blanco
   ::cBuffer   += Space( 233 )                                                                                                                                                //Reserva                        Long 243    Blanco*/

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD cFormatoImporte( nImporte ) CLASS EnlaceMonitor

   local cImporte    := ""

   cImporte          := AllTrim( Trans( nImporte, cPorDiv() ) )
   cImporte          := StrTran( cImporte, ".", "" )

RETURN ( cImporte )

//---------------------------------------------------------------------------//

METHOD cFormatoPorcentaje( nPorcentaje ) CLASS EnlaceMonitor

   local cPorcentaje    := ""

   cPorcentaje          := AllTrim( Trans( nPorcentaje, "@E 999.99" ) )
   cPorcentaje          := StrTran( cPorcentaje, ".", "" )

RETURN ( cPorcentaje )

//---------------------------------------------------------------------------//

METHOD changeStateFacturaCliente() CLASS EnlaceMonitor

   if dbLock( ( D():FacturasClientes( ::nView ) ) )
      ( D():FacturasClientes( ::nView ) )->lContab    := .t.
      ( D():FacturasClientes( ::nView ) )->( dbUnLock() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD changeStateFacturaProveedor() CLASS EnlaceMonitor

   if dbLock( ( D():FacturasProveedores( ::nView ) ) )
      ( D():FacturasProveedores( ::nView ) )->lContab    := .t.
      ( D():FacturasProveedores( ::nView ) )->( dbUnLock() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD WriteASCII() CLASS EnlaceMonitor

   if Empty( ::cBuffer )
      Return ( .f. )
   end if

   ferase( ::cFullFile() )

   if !file( ::cFullFile() ) .or. empty( ::hFile )
      ::hFile     := fCreate( ::cFullFile() )
   end if 

   if !empty( ::hFile )

      fWrite( ::hFile, ::cBuffer )
      fClose( ::hFile )

      ::cBuffer   := ""

      if apoloMsgNoYes( "Proceso de exportación realizado con éxito" + CRLF + ;
                        "en fichero " + ( ::cFullFile() )            + CRLF + ;
                        "¿ Desea abrir el fichero resultante ?",;
                        "Elija una opción." )
         shellExecute( 0, "open", ( ::cDirectory + "\" + ::cFile ), , , 1 )
      end if

      Return .t.

   end if

Return ( .f. )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS EnlaceSage50

   CLASSDATA oInstance

   DATA cBufferSubCta                     INIT ""
   DATA cBufferAsiento                    INIT ""
   DATA nView
   DATA oTree

   DATA cConector                         INIT ";"

   DATA nLenSubcta                        INIT 6

   DATA cDirectory
   DATA cFileSubCta
   DATA cFileDiario
   DATA hFileSubCta
   DATA hFileDiario

   DATA aCtaClientes                      INIT {}
   DATA aCtaProveedores                   INIT {}

   DATA aSubCtaIngresos                   INIT {}

   DATA nContadorAsiento                  INIT 1

   DATA aTotales                          INIT {}
   DATA aTotalesIva                       INIT {}

   METHOD New()
   METHOD GetInstance()
   METHOD destroyInstance()               INLINE ( ::oInstance := nil )

   METHOD ContabilizaFacturaCliente()
   METHOD ContabilizaTicketCliente()
   METHOD changeState()
   METHOD changeStateTicket()

   METHOD ContabilizaReciboCliente()

   METHOD ContabilizaFacturaProveedor()
   METHOD changeStateFacturaProveedor()


   METHOD WriteASCII()

   METHOD cFullFileSubCta()                  INLINE ( ::cDirectory + "\" + ::cFileSubCta )
   METHOD cFullFileDiario()                  INLINE ( ::cDirectory + "\" + ::cFileDiario )

   METHOD writeTree( cText, nState )         INLINE ( ::oTree:Select( ::oTree:Add( cText, nState ) ) )
   METHOD cNumero()                          INLINE ( ( D():FacturasClientes( ::nView ) )->cSerie + "/" + AllTrim( Str( ( D():FacturasClientes( ::nView ) )->nNumFac ) ) + "/" + ( D():FacturasClientes( ::nView ) )->cSufFac )
   METHOD cNumeroFactura()                   INLINE ( ( D():FacturasClientes( ::nView ) )->cSerie + Str( ( D():FacturasClientes( ::nView ) )->nNumFac ) + ( D():FacturasClientes( ::nView ) )->cSufFac )
   METHOD cNumeroTicketFormato()             INLINE ( ( D():Tikets( ::nView ) )->cSerTik + "/" + AllTrim( ( D():Tikets( ::nView ) )->cNumTik ) + "/" + ( D():Tikets( ::nView ) )->cSufTik )
   METHOD cNumeroTicket()                    INLINE ( ( D():Tikets( ::nView ) )->cSerTik + ( D():Tikets( ::nView ) )->cNumTik + ( D():Tikets( ::nView ) )->cSufTik )

   METHOD cNumeroFacturaProveedorFormato()   INLINE ( ( D():FacturasProveedores( ::nView ) )->cSerFac + "/" + AllTrim( Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ) ) + "/" + ( D():FacturasProveedores( ::nView ) )->cSufFac )
   METHOD cNumeroFacturaProveedor()          INLINE ( ( D():FacturasProveedores( ::nView ) )->cSerFac + Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ) + ( D():FacturasProveedores( ::nView ) )->cSufFac )

   METHOD cNumeroReciboFormato()             INLINE ( ( D():FacturasClientesCobros( ::nView ) )->cSerie + "/" + AllTrim( Str( ( D():FacturasClientesCobros( ::nView ) )->nNumFac ) ) + "/" + ( D():FacturasClientesCobros( ::nView ) )->cSufFac + "-" + AllTrim( Str( ( D():FacturasClientesCobros( ::nView ) )->nNumRec ) ) )
   METHOD cNumeroRecibo()                    INLINE ( ( D():FacturasClientesCobros( ::nView ) )->cSerie + Str( ( D():FacturasClientesCobros( ::nView ) )->nNumFac ) + ( D():FacturasClientesCobros( ::nView ) )->cSufFac + Str( ( D():FacturasClientesCobros( ::nView ) )->nNumRec ) )

   METHOD AddSubCta()

   METHOD AddAsientos()
      METHOD addDebe()
      METHOD addHaber()
      METHOD addIva()

   METHOD lIncludeSubCta()
   METHOD lIncludeSubCtaPrv()

   METHOD cFormatoImporte( nImporte )
   METHOD cFormatoPorcentaje( nPorcentaje )
   METHOD cFormatoFecha( dFecha )

   METHOD AddSubCtaIngresos()

   METHOD getSubCuentaIva( nIva )
   METHOD getSubCuentaRe( nRe )
   METHOD getSubCuentaIvaCompras( nIva )

   METHOD AddSubCtaIngresosTickets()
   METHOD AddSubCtaTickets()

   METHOD AddAsientosTickets()
      METHOD addDebeTickets()
      METHOD addHaberTickets()
      METHOD addIvaTickets()

   METHOD AddSubCtaGastosFacPrv()
   METHOD AddSubCtaFacPrv()

   METHOD AddAsientosFacPrv()
      METHOD addDebeFacPrv()
      METHOD addHaberFacPrv()
      METHOD addIvaFacPrv()

   METHOD AddAsientosRecibos()
      METHOD addDebeRecibo()
      METHOD addHaberRecibo()

   METHOD addDescuentoLineal()

   METHOD changeStateReciboCliente()

ENDCLASS

//---------------------------------------------------------------------------//

METHOD New() CLASS EnlaceSage50

   if empty( cRutCnt() )
      ::cDirectory      := "C:\ENLACESAGE"
   else
      ::cDirectory      := cRutCnt()
   end if 

   ::cBufferSubCta      := ""
   ::cBufferAsiento     := ""

   ::cFileSubCta        := "xSubCta.txt"
   ::cFileDiario        := "xDiario.txt"

   ::aCtaClientes       := {}
   ::aCtaProveedores    := {}

   ::aTotales           := {}
   ::aTotalesIva        := {}

   ::nContadorAsiento   := Space( 6 )

   ::nLenSubcta         := ConfiguracionesEmpresaModel():getNumeric( 'lenSubCta', 1 )

   ferase( ::cFullFileDiario() )

   if !file( ::cFullFileDiario() ) .or. empty( ::hFileDiario )
      ::hFileDiario     := fCreate( ::cFullFileDiario() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD GetInstance() CLASS EnlaceSage50

   if empty( ::oInstance )
      
      ::oInstance       := ::New()

      if Empty( ::nContadorAsiento )

         MsgGet( "Seleccione un número de asiento", "asiento: ", @::nContadorAsiento )

         if Empty( ::nContadorAsiento )
            MsgStop( "Tiene que indicar un número de asiento" )
            Return ( Self )
         end if

         ::nContadorAsiento   := val( ::nContadorAsiento )

         if ::nContadorAsiento < 1
            MsgStop( "Tiene que indicar un número de asiento" )
            Return ( Self )
         end if

      end if

   end if

RETURN ( ::oInstance )

//---------------------------------------------------------------------------//

METHOD ContabilizaFacturaCliente( nView, oTree ) CLASS EnlaceSage50

   ::nView              := nView
   ::oTree              := oTree

   if Empty( ::nContadorAsiento )
      
      ::writeTree( "Error al indicar un asiento", 0 )
      
      if !empty( ::hFileDiario )
         fClose( ::hFileDiario )
      end if
      
      Return ( Self )

   end if

   if ( D():FacturasClientes( ::nView ) )->lContab
      
      ::writeTree( "Factura anteriormente contabilizada : " + ::cNumero(), 0 )
      
      if !empty( ::hFileDiario )
         fClose( ::hFileDiario )
      end if

      Return ( Self )

   end if

   ::AddSubCtaIngresos()
   ::AddSubCta()
   ::AddAsientos()

   ::changeState()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ContabilizaReciboCliente( nView, oTree ) CLASS EnlaceSage50

   ::nView              := nView
   ::oTree              := oTree

   if Empty( ::nContadorAsiento )
      
      ::writeTree( "Error al indicar un asiento", 0 )
      
      if !empty( ::hFileDiario )
         fClose( ::hFileDiario )
      end if
      
      Return ( Self )

   end if

   if ( D():FacturasClientesCobros( ::nView ) )->lConPgo
      
      ::writeTree( "Recibo anteriormente contabilizado : " + ::cNumeroReciboFormato(), 0 )
      
      if !empty( ::hFileDiario )
         fClose( ::hFileDiario )
      end if

      Return ( Self )

   end if

   ::AddAsientosRecibos()

   ::changeStateReciboCliente()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD changeState() CLASS EnlaceSage50

   if dbLock( ( D():FacturasClientes( ::nView ) ) )
      ( D():FacturasClientes( ::nView ) )->lContab    := .t.
      ( D():FacturasClientes( ::nView ) )->( dbUnLock() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD changeStateReciboCliente() CLASS EnlaceSage50

   if dbLock( ( D():FacturasClientesCobros( ::nView ) ) )
      ( D():FacturasClientesCobros( ::nView ) )->lConPgo    := .t.
      ( D():FacturasClientesCobros( ::nView ) )->( dbUnLock() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD WriteASCII() CLASS EnlaceSage50

   local lCreateSubCta     :=  .f.
   local lCreateDiario     :=  .f.

   if Empty( ::cBufferSubCta ) .and. Empty( ::cBufferAsiento )
      Return ( .f. )
   end if

   /*
   Fichero Subcuentas----------------------------------------------------------
   */

   ferase( ::cFullFileSubCta() )

   if !file( ::cFullFileSubCta() ) .or. empty( ::hFileSubCta )
      ::hFileSubCta     := fCreate( ::cFullFileSubCta() )
   end if 

   if !empty( ::hFileSubCta )

      fWrite( ::hFileSubCta, ::cBufferSubCta )
      fClose( ::hFileSubCta )

      ::cBufferSubCta   := ""

      lCreateSubCta     :=  .t.

   end if

   /*
   Fichero diarios-------------------------------------------------------------
   */

   if !empty( ::hFileDiario )

      fClose( ::hFileDiario )

      lCreateDiario     :=  .t.

   end if

   if lCreateSubCta
      ::writeTree( "Fichero : " + ::cFullFileSubCta + " creado correctamente ", 1 )
   else
      ::writeTree( "Fichero : " + ::cFullFileSubCta + " no se ha creado correctamente ", 0 )
   end if

   if lCreateDiario   
      ::writeTree( "Fichero : " + ::cFullFileDiario() + " creado correctamente ", 1 )
   else
      ::writeTree( "Fichero : " + ::cFullFileDiario() + " no se ha creado correctamente ", 0 )
   end if

   if apoloMsgNoYes( "Proceso de exportación realizado con éxito" + CRLF + ;
                     "¿ Desea abrir el directorio resultante ?",;
                     "Elija una opción." )
      shellExecute( 0, "open", ( ::cDirectory ), , , 1 )
   end if

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD lIncludeSubCta() CLASS EnlaceSage50

   if aScan( ::aCtaClientes, {|x| x == ( D():FacturasClientes( ::nView ) )->cCodCli } ) == 0
      Return ( .f. )
   end if

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD lIncludeSubCtaPrv() CLASS EnlaceSage50

   if aScan( ::aCtaProveedores, {|x| x == ( D():FacturasProveedores( ::nView ) )->cCodPrv } ) == 0
      Return ( .f. )
   end if

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD AddSubCtaIngresos() CLASS EnlaceSage50

   local nPos           := 0
   local cCnt           := ""
   local nRecAnt        := ( D():FacturasClientesLineas( ::nView ) )->( Recno() )
   local nOrdAnt        := ( D():FacturasClientesLineas( ::nView ) )->( OrdSetFocus( "nNumFac" ) )
   local nTotal         := 0

   ::aSubCtaIngresos       := {}

   if ( D():FacturasClientesLineas( ::nView ) )->( dbSeek( ::cNumeroFactura() ) )

      while ( D():FacturasClientesLineas( ::nView ) )->cSerie + Str( ( D():FacturasClientesLineas( ::nView ) )->nNumFac ) + ( D():FacturasClientesLineas( ::nView ) )->cSufFac == ::cNumeroFactura() .and.;
            !( D():FacturasClientesLineas( ::nView ) )->( Eof() )

            if !Empty( ( D():FacturasClientesLineas( ::nView ) )->cRef )

               cCnt           := retCtaVta( ( D():FacturasClientesLineas( ::nView ) )->cRef, .f., D():Articulos( ::nView ) ) 

               if Empty( cCnt )
                  cCnt        := cCtaCli() + replicate( "0", ::nLenSubcta - 3 )
               end if

               nPos           := aScan( ::aSubCtaIngresos, {|h| hGet( h, "cuenta" ) == cCnt } )

               //nTotal         := nTotLFacCli( D():FacturasClientesLineas( ::nView ), , , , .t. )


               nTotal         := nNetLFacCli( D():FacturasClientesLineas( ::nView ), , , , .t. )

               nRestaDescuentoVenta( @nTotal, ( D():FacturasClientes( ::nView ) )->nDtoEsp )
               nRestaDescuentoVenta( @nTotal, ( D():FacturasClientes( ::nView ) )->nDpp )
               nRestaDescuentoVenta( @nTotal, ( D():FacturasClientes( ::nView ) )->nDtoUno )
               nRestaDescuentoVenta( @nTotal, ( D():FacturasClientes( ::nView ) )->nDtoDos )
               nRestaDescuentoVenta( @nTotal, ( D():FacturasClientes( ::nView ) )->nPctDto )
               
               if nPos == 0
                  aAdd( ::aSubCtaIngresos, { "cuenta" => cCnt,;
                                             "importe" => nTotal } )

               else

                  hSet( ::aSubCtaIngresos[ nPos ], "importe", hGet( ::aSubCtaIngresos[ nPos ], "importe" ) + nTotal )

               end if

            end if

            ( D():FacturasClientesLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ( D():FacturasClientesLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():FacturasClientesLineas( ::nView ) )->( dbGoTo( nRecAnt ) )

   asort( ::aSubCtaIngresos, , , {|x,y| hget( x, "cuenta" ) < hget( y, "cuenta" ) } )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddSubCta() CLASS EnlaceSage50

   local nOrdAnt  := ( D():Clientes( ::nView ) )->( OrdSetFocus( "COD" ) )

   if ::lIncludeSubCta()
      Return ( nil )
   end if

   aAdd( ::aCtaClientes, ( D():FacturasClientes( ::nView ) )->cCodCli )

   if ( D():Clientes( ::nView ) )->( dbSeek( ( D():FacturasClientes( ::nView ) )->cCodCli ) )

      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Subcta, 12 )          // COD         CODIGO      C  12    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Titulo, 40 )          // TITULO      NOMBRE      C  40    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Nif, 15 )             // NIF         CIF         C  15    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Domicilio, 35 )       // DOMICILIO   DIRECCION   C  35    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Poblacion, 25 )       // POBLACION   POBLACION   C  25    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Provincia, 20 )       // PROVINCIA   PROVINCIA   C  20    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->CodPostal, 5 )        // CODPOSTAL   COD POSTAL  C   5    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // DIVISA                  L   1    0
      ::cBufferSubCta      += Padr( "", 5 )                                            // CODDIVISA   COD DIVISA  C   5    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // DOCUMENTO               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // AJUSTAME                L   1    0
      ::cBufferSubCta      += Padr( "", 1 )                                            // TIPOIVA     TIPO IVA    C   1    0
      ::cBufferSubCta      += Padr( "", 9 )                                            // PROYE       PLAN 1      C   9    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBEQUIV                C  12    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBCIERRE               C  12    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LINTERRUMP              L   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SEGMENTO    PALN 2      C  12    0
      ::cBufferSubCta      += Padr( " 0.00", 5 )                                       // TPC         PORC. IVA   N   5    2
      ::cBufferSubCta      += Padr( " 0.00", 5 )                                       // RECEQUIV    PORC. RE    N   5    2
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Fax, 15 )             // FAX01       FAX         C  15    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->cMeiInt, 50 )         // EMAIL       EMAIL       C  50    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Titulo, 100 )         // TITULOL     NOM LARGO   C 100    0
      ::cBufferSubCta      += Padr( "0", 1 )                                           // IDNIF       TIPO ID     C   1    0
      ::cBufferSubCta      += Padr( "", 2 )                                            // CODPAIS     ISO PAIS    C   2    0
      ::cBufferSubCta      += Padr( "", 9 )                                            // REP14NIF                C   9    0
      ::cBufferSubCta      += Padr( "", 40 )                                           // REP14NOM                C  40    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // METCOBRO                L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // METCOBFRE               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // SUPLIDO                 L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // PROVISION               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LESIRPF                 L   1    0
      ::cBufferSubCta      += Padr( " 0.00", 5 )                                       // NIRPF       PORC IRPF   N   5    2
      ::cBufferSubCta      += Padr( " 0", 2 )                                          // NCLAVEIRPF  CLAVE IRPF  N   2    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LESMOD130               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LDEDUCIBLE              L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LCRITCAJA               L   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // CSUBIVAAS               C  12    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LPEFECTIVO              L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LINGGASTO               L   1    0
      ::cBufferSubCta      += Padr( " 0", 2 )                                          // NTIPOIG                 N   2    0
      ::cBufferSubCta      += Padr( "", 1 )                                            // MEDIOCRIT               C   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBCTACON               C  12    0
      ::cBufferSubCta      += Padr( " 0", 2 )                                          // NTIPOEXIST              N   2    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBCTAVAR               C  12    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LMOD140                 L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LIRPF                   L   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SCTABANCO               C  12    0
      ::cBufferSubCta      += Padr( "", 5 )                                            // SCODMUN                 C   5    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Nif, 30 )             // NIFNEW                  C  30    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Titulo, 120 )  + CRLF // TITULONEW   NOM. AMPLI. C 120    0

   end if

   ( D():Clientes( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddAsientos() CLASS EnlaceSage50

   ::aTotales           := aTotFacCli( ( D():FacturasClientes( ::nView ) )->cSerie + Str( ( D():FacturasClientes( ::nView ) )->nNumFac ) + ( D():FacturasClientes( ::nView ) )->cSufFac,;
                                       D():FacturasClientes( ::nView ),;
                                       D():FacturasClientesLineas( ::nView ),;
                                       D():TiposIva( ::nView ),;
                                       D():Divisas( ::nView ),;
                                       D():FacturasClientesCobros( ::nView ),;
                                       D():AnticiposClientes( ::nView ) )

   ::aTotalesIva        := ::aTotales[8]

   ::addDebe()
   ::addHaber()
   ::addIva()
   ::addDescuentoLineal()

   ::nContadorAsiento ++

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addDebe() CLASS EnlaceSage50

   ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                               // Asien       N   6    0
   ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():FacturasClientes( ::nView ) )->dFecFac ), 8 )                                    // Fecha       D   8    0
   ::cBufferAsiento      += Padr( AllTrim( cCliCta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ), 12 )       // SubCta      C  12    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // Contra      C  12    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // PtaDebe     N  16    2
   ::cBufferAsiento      += Padr( "N/Fcta. " + ::cNumero(), 25 )                                                                          // Concepto    C  25    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // PtaHaber    N  16    2
   ::cBufferAsiento      += Right( Str( ( D():FacturasClientes( ::nView ) )->nNumFac ), 8 )                                               // Factura     N   8    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // BaseImpo    N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 5 )                                                                             // IVA         N   5    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 5 )                                                                             // Receqiv     N   5    2
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // Documento   C  10    0
   ::cBufferAsiento      += Padr( "", 3 )                                                                                                 // Departa     C   3    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Clave       C   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Estado      C   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // NCasado     N   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TCasado     N   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Trans       N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // Cambio      N  16    6
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // DebeMe      N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // HaberMe     N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Auxiliar    C   1    0
   ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cSerie, 1 )                                                        // Serie       C   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                                 // Sucursal    C   4    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // CodDivisa   C   5    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImpAuxMe    N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // MonedaUso   C   1    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( ( D():FacturasClientes( ::nView ) )->nTotFac ), 16 )                                 // EuroDebe    N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // EuroHaber   N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // BaseEuro    N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // NoConv      L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // NumeroInv   C  10    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Serie_RT    C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Factu_RT    N   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // BaseImp_RT  N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // BaseImp_RF  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Rectifica   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_RT    D   8    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Nic         C   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Libre       L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Libre       N   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Linyerrump  L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // SegActiv    C   6    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // SegGeog     C   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // IRect349    L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_OP    D   8    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_EX    D   8    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Departa5    C   5    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // Factura10   C  10    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Porcen_Ana  N   5    2
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Porcen_Seg  N   5    2
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // NumApunte   N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // EuroTotal   N  16    2
   ::cBufferAsiento      += Padr( "", 100 )                                                                                               // RazonSoc    C 100    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // Apellido1   C  50    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // Apellido2   C  50    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoOpe     C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // nFacTick    N   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NumAcuIni   C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NumAcuFin   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TerIdNif    N   1    0
   ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cDniCli, 15 )                                                      // TerNif      C  15    0
   ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cNomCli, 40 )                                                      // TerNom      C  40    0
   ::cBufferAsiento      += Padr( "", 9 )                                                                                                 // TerNif14    C   9    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // TBienTran   L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // TBienCod    C  10    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // TransInm    L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Metal       L   1    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // MetalImp    N  16    2
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // Cliente     C  12    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // OpBienes    N   1    0
   ::cBufferAsiento      += Padr( ::cNumero(), 40 )                                                                                       // FacturaEx   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoFac     C   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoIva     C   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // GUID        C  40    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // L340        L   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                                 // MetalEje    N   4    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                                // Document15  C  15    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // ClienteSup  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaSub    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImporteSup  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // DocSup      C  40    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // ClientePro  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaPro    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImportePro  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // DocPro      C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nClaveIRPF  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lArrend347  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // nSitInmueb  N   1    0
   ::cBufferAsiento      += Padr( "", 25 )                                                                                                // cRefCatast  C  25    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Concil347   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoRegula  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nCritCaja   N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lCritCaja   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // dMaxLiqui   D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // nTotalFac   N  16    2
   ::cBufferAsiento      += Padr( "", 32 )                                                                                                // idFactura   C  32    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // nCobrPago   N  16    2
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nTipoIG     N   2    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // DevoIvaId   C  50    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // iDevoluIva  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // MedioCrit   C   1    0
   ::cBufferAsiento      += Padr( "", 34 )                                                                                                // CuentaCrit  C  34    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // IconAc      L   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // GuidSPAY    C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoEntr    N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // Mod140      N   2    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaAnota  D   8    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nTipo140    N   2    0
   ::cBufferAsiento      += Padr( "", 11 )                                                                                                // Cuenta140   C  11    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // Importe140  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // LDepAduan   L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // LDifAduan   L   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nInter303   N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // idRecargo   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // EstadoSII   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave   N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoExenci  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoNoSuje  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoFact    N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NacuIniSII  C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NacuFinSII  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoRectif  N   2    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // bImpCoste   N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lEmiTercer  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // nEntrPrest  N   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FecRegCon   D   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // FactuEx_RT  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave1  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave2  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // ItaI        L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lExecl303   L   1    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // ConcepNew   C  50    0
   ::cBufferAsiento      += Padr( "", 30 )                                                                                                // TerNifNew   C  30    0
   ::cBufferAsiento      += Padr( "", 120 )                                                                                               // TerNomNew   C 120    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // SII_1415    L   1    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                                // cAutoriza   C  15    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lEmiTerDis  L   1    0
   ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                          // NifSuced    C   9    0
   //::cBufferAsiento      += Padr( "", 120 )                                                                                             // RazonSuced  C 120    0
   //::cBufferAsiento      += Padr( "F", 1 )                                                                                              // IfSimplifi  L   1    0
   //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                       // IfSinIdent  L   1    0

   if !empty( ::hFileDiario )
      fWrite( ::hFileDiario, ::cBufferAsiento )
   end if

   ::cBufferAsiento   := ""

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addHaber() CLASS EnlaceSage50

   local hCtaIng

   for each hCtaIng in ::aSubCtaIngresos

      ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                            // Asien       N   6    0
      ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():FacturasClientes( ::nView ) )->dFecFac ), 8 )                                 // Fecha       D   8    0
      ::cBufferAsiento      += Padr( AllTrim( hGet( hCtaIng, "cuenta" ) ), 12 )                                                           // SubCta      C  12    0
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // Contra      C  12    0
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // PtaDebe     N  16    2
      ::cBufferAsiento      += Padr( "N/Fcta. " + ::cNumero() + AllTrim( ( D():FacturasClientes( ::nView ) )->cNomCli ), 25 )             // Concepto    C  25    0
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // PtaHaber    N  16    2
      ::cBufferAsiento      += Right( Str( ( D():FacturasClientes( ::nView ) )->nNumFac ), 8 )                                            // Factura     N   8    0
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // BaseImpo    N  16    2
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 5 )                                                                          // IVA         N   5    2
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 5 )                                                                          // Receqiv     N   5    2
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // Documento   C  10    0
      ::cBufferAsiento      += Padr( "", 3 )                                                                                              // Departa     C   3    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Clave       C   6    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Estado      C   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // NCasado     N   6    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TCasado     N   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Trans       N   6    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // Cambio      N  16    6
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // DebeMe      N  16    2
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // HaberMe     N  16    2
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Auxiliar    C   1    0
      ::cBufferAsiento      += Pad( ( D():FacturasClientes( ::nView ) )->cSerie, 1 )                                                      // Serie       C   1    0
      ::cBufferAsiento      += Padr( "", 4 )                                                                                              // Sucursal    C   4    0
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // CodDivisa   C   5    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImpAuxMe    N  16    2
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // MonedaUso   C   1    0
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // EuroDebe    N  16    2
      ::cBufferAsiento      += Padl( ::cFormatoImporte( hGet( hCtaIng, "importe" ) ), 16 )                                                // EuroHaber   N  16    2
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // BaseEuro    N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // NoConv      L   1    0
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // NumeroInv   C  10    2
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Serie_RT    C   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Factu_RT    N   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // BaseImp_RT  N  16    2
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // BaseImp_RF  N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Rectifica   L   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_RT    D   8    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Nic         C   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Libre       L   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Libre       N   6    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Linyerrump  L   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // SegActiv    C   6    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // SegGeog     C   6    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // IRect349    L   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_OP    D   8    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_EX    D   8    0
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Departa5    C   5    0
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // Factura10   C  10    0
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Porcen_Ana  N   5    2
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Porcen_Seg  N   5    2
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // NumApunte   N   6    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // EuroTotal   N  16    2
      ::cBufferAsiento      += Padr( "", 100 )                                                                                            // RazonSoc    C 100    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // Apellido1   C  50    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // Apellido2   C  50    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoOpe     C   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // nFacTick    N   8    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NumAcuIni   C  40    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NumAcuFin   C  40    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TerIdNif    N   1    0
      ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cDniCli, 15 )                                                   // TerNif      C  15    0
      ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cNomCli, 40 )                                                   // TerNom      C  40    0
      ::cBufferAsiento      += Padr( "", 9 )                                                                                              // TerNif14    C   9    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // TBienTran   L   1    0
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // TBienCod    C  10    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // TransInm    L   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Metal       L   1    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // MetalImp    N  16    2
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // Cliente     C  12    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // OpBienes    N   1    0
      ::cBufferAsiento      += Padr( ::cNumero(), 40 )                                                                                    // FacturaEx   C  40    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoFac     C   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoIva     C   1    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // GUID        C  40    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // L340        L   1    0
      ::cBufferAsiento      += Padr( "", 4 )                                                                                              // MetalEje    N   4    0
      ::cBufferAsiento      += Padr( "", 15 )                                                                                             // Document15  C  15    0
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // ClienteSup  C  12    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaSub    D   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImporteSup  N  16    2
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // DocSup      C  40    0
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // ClientePro  C  12    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaPro    D   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImportePro  N  16    2
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // DocPro      C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nClaveIRPF  N   2    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lArrend347  L   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // nSitInmueb  N   1    0
      ::cBufferAsiento      += Padr( "", 25 )                                                                                             // cRefCatast  C  25    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Concil347   N   1    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoRegula  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nCritCaja   N   2    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lCritCaja   L   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // dMaxLiqui   D   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // nTotalFac   N  16    2
      ::cBufferAsiento      += Padr( "", 32 )                                                                                             // idFactura   C  32    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // nCobrPago   N  16    2
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nTipoIG     N   2    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // DevoIvaId   C  50    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // iDevoluIva  L   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // MedioCrit   C   1    0
      ::cBufferAsiento      += Padr( "", 34 )                                                                                             // CuentaCrit  C  34    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // IconAc      L   1    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // GuidSPAY    C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoEntr    N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // Mod140      N   2    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaAnota  D   8    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nTipo140    N   2    0
      ::cBufferAsiento      += Padr( "", 11 )                                                                                             // Cuenta140   C  11    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // Importe140  N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // LDepAduan   L   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // LDifAduan   L   1    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nInter303   N   2    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // idRecargo   C  40    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // EstadoSII   N   1    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave   N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoExenci  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoNoSuje  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoFact    N   2    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NacuIniSII  C  40    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NacuFinSII  C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoRectif  N   2    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // bImpCoste   N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lEmiTercer  L   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // nEntrPrest  N   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FecRegCon   D   8    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // FactuEx_RT  C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave1  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave2  N   2    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // ItaI        L   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lExecl303   L   1    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // ConcepNew   C  50    0
      ::cBufferAsiento      += Padr( "", 30 )                                                                                             // TerNifNew   C  30    0
      ::cBufferAsiento      += Padr( "", 120 )                                                                                            // TerNomNew   C 120    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // SII_1415    L   1    0
      ::cBufferAsiento      += Padr( "", 15 )                                                                                             // cAutoriza   C  15    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lEmiTerDis  L   1    0
      ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                       // NifSuced    C   9    0
      //::cBufferAsiento      += Padr( "", 120 )                                                                                          // RazonSuced  C 120    0
      //::cBufferAsiento      += Padr( "F", 1 )                                                                                           // IfSimplifi  L   1    0
      //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                    // IfSinIdent  L   1    0

      if !empty( ::hFileDiario )
         fWrite( ::hFileDiario, ::cBufferAsiento )
      end if

      ::cBufferAsiento   := ""

   next

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addIva() CLASS EnlaceSage50

   local aIva

   for each aIva in ::aTotalesIva

      if hGet( aIva, "porcentajeiva" ) != nil

         ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                         // Asien       N   6    0
         ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():FacturasClientes( ::nView ) )->dFecFac ), 8 )                              // Fecha       D   8    0
         ::cBufferAsiento      += Padr( ::getSubCuentaIva( hGet( aIva, "porcentajeiva" ) ), 12 )                                          // SubCta      C  12    0
         ::cBufferAsiento      += Padr( AllTrim( cCliCta( ( D():FacturasClientes( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ), 12 ) // Contra      C  12    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // PtaDebe     N  16    2
         ::cBufferAsiento      += Padr( "N/Fcta. " + ::cNumero() + AllTrim( ( D():FacturasClientes( ::nView ) )->cNomCli ), 25 )          // Concepto    C  25    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // PtaHaber    N  16    2
         ::cBufferAsiento      += Right( Str( ( D():FacturasClientes( ::nView ) )->nNumFac ), 8 )                                         // Factura     N   8    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // BaseImpo    N  16    2
         ::cBufferAsiento      += Padl( ::cFormatoPorcentaje( hGet( aIva, "porcentajeiva" ) ), 5 )                                        // IVA         N   5    2
         ::cBufferAsiento      += Padl( ::cFormatoPorcentaje( 0 ), 5 )                                                                    // Receqiv     N   5    2
         ::cBufferAsiento      += Padr( "", 10 )                                                                                          // Documento   C  10    0
         ::cBufferAsiento      += Padr( "", 3 )                                                                                           // Departa     C   3    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // Clave       C   6    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Estado      C   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // NCasado     N   6    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TCasado     N   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // Trans       N   6    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // Cambio      N  16    6
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // DebeMe      N  16    2
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // HaberMe     N  16    2
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Auxiliar    C   1    0
         ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cSerie, 1 )                                                  // Serie       C   1    0
         ::cBufferAsiento      += Padr( "", 4 )                                                                                           // Sucursal    C   4    0
         ::cBufferAsiento      += Padr( "", 5 )                                                                                           // CodDivisa   C   5    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // ImpAuxMe    N  16    2
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // MonedaUso   C   1    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // EuroDebe    N  16    2
         ::cBufferAsiento      += Padl( ::cFormatoImporte( hGet( aIva, "impiva" ) ), 16 )                                                 // EuroHaber   N  16    2
         ::cBufferAsiento      += Padl( ::cFormatoImporte( hGet( aIva, "neto" ) ), 16 )                                                   // BaseEuro    N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // NoConv      L   1    0
         ::cBufferAsiento      += Padr( "", 10 )                                                                                          // NumeroInv   C  10    2
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Serie_RT    C   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Factu_RT    N   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // BaseImp_RT  N  16    2
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // BaseImp_RF  N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Rectifica   L   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Fecha_RT    D   8    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Nic         C   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Libre       L   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // Libre       N   6    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Linyerrump  L   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // SegActiv    C   6    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // SegGeog     C   6    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // IRect349    L   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Fecha_OP    D   8    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Fecha_EX    D   8    0
         ::cBufferAsiento      += Padr( "", 5 )                                                                                           // Departa5    C   5    0
         ::cBufferAsiento      += Padr( "", 10 )                                                                                          // Factura10   C  10    0
         ::cBufferAsiento      += Padr( "", 5 )                                                                                           // Porcen_Ana  N   5    2
         ::cBufferAsiento      += Padr( "", 5 )                                                                                           // Porcen_Seg  N   5    2
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // NumApunte   N   6    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // EuroTotal   N  16    2
         ::cBufferAsiento      += Padr( "", 100 )                                                                                         // RazonSoc    C 100    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                          // Apellido1   C  50    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                          // Apellido2   C  50    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TipoOpe     C   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // nFacTick    N   8    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NumAcuIni   C  40    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NumAcuFin   C  40    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TerIdNif    N   1    0
         ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cDniCli, 15 )                                                // TerNif      C  15    0
         ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cNomCli, 40 )                                                // TerNom      C  40    0
         ::cBufferAsiento      += Padr( "", 9 )                                                                                           // TerNif14    C   9    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // TBienTran   L   1    0
         ::cBufferAsiento      += Padr( "", 10 )                                                                                          // TBienCod    C  10    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // TransInm    L   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Metal       L   1    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // MetalImp    N  16    2
         ::cBufferAsiento      += Padr( "", 12 )                                                                                          // Cliente     C  12    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // OpBienes    N   1    0
         ::cBufferAsiento      += Padr( ::cNumero(), 40 )                                                                                 // FacturaEx   C  40    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TipoFac     C   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TipoIva     C   1    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // GUID        C  40    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // L340        L   1    0
         ::cBufferAsiento      += Padr( "", 4 )                                                                                           // MetalEje    N   4    0
         ::cBufferAsiento      += Padr( "", 15 )                                                                                          // Document15  C  15    0
         ::cBufferAsiento      += Padr( "", 12 )                                                                                          // ClienteSup  C  12    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FechaSub    D   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // ImporteSup  N  16    2
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // DocSup      C  40    0
         ::cBufferAsiento      += Padr( "", 12 )                                                                                          // ClientePro  C  12    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FechaPro    D   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // ImportePro  N  16    2
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // DocPro      C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nClaveIRPF  N   2    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lArrend347  L   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // nSitInmueb  N   1    0
         ::cBufferAsiento      += Padr( "", 25 )                                                                                          // cRefCatast  C  25    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Concil347   N   1    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoRegula  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nCritCaja   N   2    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lCritCaja   L   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // dMaxLiqui   D   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // nTotalFac   N  16    2
         ::cBufferAsiento      += Padr( "", 32 )                                                                                          // idFactura   C  32    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // nCobrPago   N  16    2
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nTipoIG     N   2    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                          // DevoIvaId   C  50    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // iDevoluIva  L   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // MedioCrit   C   1    0
         ::cBufferAsiento      += Padr( "", 34 )                                                                                          // CuentaCrit  C  34    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // IconAc      L   1    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // GuidSPAY    C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoEntr    N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // Mod140      N   2    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FechaAnota  D   8    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nTipo140    N   2    0
         ::cBufferAsiento      += Padr( "", 11 )                                                                                          // Cuenta140   C  11    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // Importe140  N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // LDepAduan   L   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // LDifAduan   L   1    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nInter303   N   2    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // idRecargo   C  40    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // EstadoSII   N   1    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoClave   N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoExenci  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoNoSuje  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoFact    N   2    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NacuIniSII  C  40    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NacuFinSII  C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoRectif  N   2    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // bImpCoste   N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lEmiTercer  L   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // nEntrPrest  N   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FecRegCon   D   8    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // FactuEx_RT  C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoClave1  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoClave2  N   2    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // ItaI        L   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lExecl303   L   1    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                          // ConcepNew   C  50    0
         ::cBufferAsiento      += Padr( "", 30 )                                                                                          // TerNifNew   C  30    0
         ::cBufferAsiento      += Padr( "", 120 )                                                                                         // TerNomNew   C 120    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // SII_1415    L   1    0
         ::cBufferAsiento      += Padr( "", 15 )                                                                                          // cAutoriza   C  15    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lEmiTerDis  L   1    0
         ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                    // NifSuced    C   9    0
         //::cBufferAsiento      += Padr( "", 120 )                                                                                       // RazonSuced  C 120    0
         //::cBufferAsiento      += Padr( "F", 1 )                                                                                        // IfSimplifi  L   1    0
         //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                 // IfSinIdent  L   1    0
         
         if !empty( ::hFileDiario )
            fWrite( ::hFileDiario, ::cBufferAsiento )
         end if

         ::cBufferAsiento   := ""

      end if

   next

   if ( D():FacturasClientes( ::nView ) )->lRecargo

      for each aIva in ::aTotalesIva

         if hGet( aIva, "porcentajeiva" ) != nil

            ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                         // Asien       N   6    0
            ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():FacturasClientes( ::nView ) )->dFecFac ), 8 )                              // Fecha       D   8    0
            ::cBufferAsiento      += Padr( ::getSubCuentaRe( hGet( aIva, "porcentajere" ) ), 12 )                                            // SubCta      C  12    0
            ::cBufferAsiento      += Padr( "", 12 )                                                                                          // Contra      C  12    0
            ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // PtaDebe     N  16    2
            ::cBufferAsiento      += Padr( "N/Fcta. " + ::cNumero() + AllTrim( ( D():FacturasClientes( ::nView ) )->cNomCli ), 25 )          // Concepto    C  25    0
            ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // PtaHaber    N  16    2
            ::cBufferAsiento      += Right( Str( ( D():FacturasClientes( ::nView ) )->nNumFac ), 8 )                                         // Factura     N   8    0
            ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // BaseImpo    N  16    2
            ::cBufferAsiento      += Padl( ::cFormatoPorcentaje( hGet( aIva, "porcentajere" ) ), 5 )                                         // IVA         N   5    2
            ::cBufferAsiento      += Padl( ::cFormatoPorcentaje( 0 ), 5 )                                                                    // Receqiv     N   5    2
            ::cBufferAsiento      += Padr( "", 10 )                                                                                          // Documento   C  10    0
            ::cBufferAsiento      += Padr( "", 3 )                                                                                           // Departa     C   3    0
            ::cBufferAsiento      += Padr( "", 6 )                                                                                           // Clave       C   6    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Estado      C   1    0
            ::cBufferAsiento      += Padr( "", 6 )                                                                                           // NCasado     N   6    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TCasado     N   1    0
            ::cBufferAsiento      += Padr( "", 6 )                                                                                           // Trans       N   6    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // Cambio      N  16    6
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // DebeMe      N  16    2
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // HaberMe     N  16    2
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Auxiliar    C   1    0
            ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cSerie, 1 )                                                  // Serie       C   1    0
            ::cBufferAsiento      += Padr( "", 4 )                                                                                           // Sucursal    C   4    0
            ::cBufferAsiento      += Padr( "", 5 )                                                                                           // CodDivisa   C   5    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // ImpAuxMe    N  16    2
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // MonedaUso   C   1    0
            ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // EuroDebe    N  16    2
            ::cBufferAsiento      += Padl( ::cFormatoImporte( hGet( aIva, "impre" ) ), 16 )                                                  // EuroHaber   N  16    2
            ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // BaseEuro    N  16    2
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // NoConv      L   1    0
            ::cBufferAsiento      += Padr( "", 10 )                                                                                          // NumeroInv   C  10    2
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Serie_RT    C   1    0
            ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Factu_RT    N   8    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // BaseImp_RT  N  16    2
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // BaseImp_RF  N  16    2
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Rectifica   L   1    0
            ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Fecha_RT    D   8    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Nic         C   1    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Libre       L   1    0
            ::cBufferAsiento      += Padr( "", 6 )                                                                                           // Libre       N   6    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Linyerrump  L   1    0
            ::cBufferAsiento      += Padr( "", 6 )                                                                                           // SegActiv    C   6    0
            ::cBufferAsiento      += Padr( "", 6 )                                                                                           // SegGeog     C   6    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // IRect349    L   1    0
            ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Fecha_OP    D   8    0
            ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Fecha_EX    D   8    0
            ::cBufferAsiento      += Padr( "", 5 )                                                                                           // Departa5    C   5    0
            ::cBufferAsiento      += Padr( "", 10 )                                                                                          // Factura10   C  10    0
            ::cBufferAsiento      += Padr( "", 5 )                                                                                           // Porcen_Ana  N   5    2
            ::cBufferAsiento      += Padr( "", 5 )                                                                                           // Porcen_Seg  N   5    2
            ::cBufferAsiento      += Padr( "", 6 )                                                                                           // NumApunte   N   6    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // EuroTotal   N  16    2
            ::cBufferAsiento      += Padr( "", 100 )                                                                                         // RazonSoc    C 100    0
            ::cBufferAsiento      += Padr( "", 50 )                                                                                          // Apellido1   C  50    0
            ::cBufferAsiento      += Padr( "", 50 )                                                                                          // Apellido2   C  50    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TipoOpe     C   1    0
            ::cBufferAsiento      += Padr( "", 8 )                                                                                           // nFacTick    N   8    0
            ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NumAcuIni   C  40    0
            ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NumAcuFin   C  40    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TerIdNif    N   1    0
            ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cDniCli, 15 )                                                // TerNif      C  15    0
            ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cNomCli, 40 )                                                // TerNom      C  40    0
            ::cBufferAsiento      += Padr( "", 9 )                                                                                           // TerNif14    C   9    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // TBienTran   L   1    0
            ::cBufferAsiento      += Padr( "", 10 )                                                                                          // TBienCod    C  10    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // TransInm    L   1    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Metal       L   1    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // MetalImp    N  16    2
            ::cBufferAsiento      += Padr( "", 12 )                                                                                          // Cliente     C  12    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // OpBienes    N   1    0
            ::cBufferAsiento      += Padr( ::cNumero(), 40 )                                                                                 // FacturaEx   C  40    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TipoFac     C   1    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TipoIva     C   1    0
            ::cBufferAsiento      += Padr( "", 40 )                                                                                          // GUID        C  40    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // L340        L   1    0
            ::cBufferAsiento      += Padr( "", 4 )                                                                                           // MetalEje    N   4    0
            ::cBufferAsiento      += Padr( "", 15 )                                                                                          // Document15  C  15    0
            ::cBufferAsiento      += Padr( "", 12 )                                                                                          // ClienteSup  C  12    0
            ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FechaSub    D   8    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // ImporteSup  N  16    2
            ::cBufferAsiento      += Padr( "", 40 )                                                                                          // DocSup      C  40    0
            ::cBufferAsiento      += Padr( "", 12 )                                                                                          // ClientePro  C  12    0
            ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FechaPro    D   8    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // ImportePro  N  16    2
            ::cBufferAsiento      += Padr( "", 40 )                                                                                          // DocPro      C  40    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nClaveIRPF  N   2    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lArrend347  L   1    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // nSitInmueb  N   1    0
            ::cBufferAsiento      += Padr( "", 25 )                                                                                          // cRefCatast  C  25    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Concil347   N   1    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoRegula  N   2    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nCritCaja   N   2    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lCritCaja   L   1    0
            ::cBufferAsiento      += Padr( "", 8 )                                                                                           // dMaxLiqui   D   8    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // nTotalFac   N  16    2
            ::cBufferAsiento      += Padr( "", 32 )                                                                                          // idFactura   C  32    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // nCobrPago   N  16    2
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nTipoIG     N   2    0
            ::cBufferAsiento      += Padr( "", 50 )                                                                                          // DevoIvaId   C  50    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // iDevoluIva  L   1    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // MedioCrit   C   1    0
            ::cBufferAsiento      += Padr( "", 34 )                                                                                          // CuentaCrit  C  34    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // IconAc      L   1    0
            ::cBufferAsiento      += Padr( "", 40 )                                                                                          // GuidSPAY    C  40    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoEntr    N   2    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // Mod140      N   2    0
            ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FechaAnota  D   8    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nTipo140    N   2    0
            ::cBufferAsiento      += Padr( "", 11 )                                                                                          // Cuenta140   C  11    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // Importe140  N  16    2
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // LDepAduan   L   1    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // LDifAduan   L   1    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nInter303   N   2    0
            ::cBufferAsiento      += Padr( "", 40 )                                                                                          // idRecargo   C  40    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // EstadoSII   N   1    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoClave   N   2    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoExenci  N   2    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoNoSuje  N   2    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoFact    N   2    0
            ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NacuIniSII  C  40    0
            ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NacuFinSII  C  40    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoRectif  N   2    0
            ::cBufferAsiento      += Padr( "", 16 )                                                                                          // bImpCoste   N  16    2
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lEmiTercer  L   1    0
            ::cBufferAsiento      += Padr( "", 1 )                                                                                           // nEntrPrest  N   1    0
            ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FecRegCon   D   8    0
            ::cBufferAsiento      += Padr( "", 40 )                                                                                          // FactuEx_RT  C  40    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoClave1  N   2    0
            ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoClave2  N   2    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // ItaI        L   1    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lExecl303   L   1    0
            ::cBufferAsiento      += Padr( "", 50 )                                                                                          // ConcepNew   C  50    0
            ::cBufferAsiento      += Padr( "", 30 )                                                                                          // TerNifNew   C  30    0
            ::cBufferAsiento      += Padr( "", 120 )                                                                                         // TerNomNew   C 120    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // SII_1415    L   1    0
            ::cBufferAsiento      += Padr( "", 15 )                                                                                          // cAutoriza   C  15    0
            ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lEmiTerDis  L   1    0
            ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                    // NifSuced    C   9    0
            //::cBufferAsiento      += Padr( "", 120 )                                                                                       // RazonSuced  C 120    0
            //::cBufferAsiento      += Padr( "F", 1 )                                                                                        // IfSimplifi  L   1    0
            //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                 // IfSinIdent  L   1    0
            
            if !empty( ::hFileDiario )
               fWrite( ::hFileDiario, ::cBufferAsiento )
            end if

            ::cBufferAsiento   := ""

         end if

      next

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addDescuentoLineal() CLASS EnlaceSage50

   local hCtaIng

   if !ConfiguracionesEmpresaModel():getLogic( 'lDtoLinAfterTotal', .f. )
      return ( nil )
   end if

   ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                            // Asien       N   6    0
   ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():FacturasClientes( ::nView ) )->dFecFac ), 8 )                                 // Fecha       D   8    0
   ::cBufferAsiento      += Padr( AllTrim( ConfiguracionesEmpresaModel():getValue( 'cuenta_descuento_especial', "" ) ), 12 )           // SubCta      C  12    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                             // Contra      C  12    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // PtaDebe     N  16    2
   ::cBufferAsiento      += Padr( "N/Fcta. " + ::cNumero(), 25 )                                                                       // Concepto    C  25    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // PtaHaber    N  16    2
   ::cBufferAsiento      += Right( Str( ( D():FacturasClientes( ::nView ) )->nNumFac ), 8 )                                            // Factura     N   8    0
   ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 16 )                                                                         // BaseImpo    N  16    2
   ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 5 )                                                                          // IVA         N   5    2
   ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 5 )                                                                          // Receqiv     N   5    2
   ::cBufferAsiento      += Padr( "", 10 )                                                                                             // Documento   C  10    0
   ::cBufferAsiento      += Padr( "", 3 )                                                                                              // Departa     C   3    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Clave       C   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Estado      C   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // NCasado     N   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TCasado     N   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Trans       N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // Cambio      N  16    6
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // DebeMe      N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // HaberMe     N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Auxiliar    C   1    0
   ::cBufferAsiento      += Pad( ( D():FacturasClientes( ::nView ) )->cSerie, 1 )                                                      // Serie       C   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                              // Sucursal    C   4    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                              // CodDivisa   C   5    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImpAuxMe    N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // MonedaUso   C   1    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( ::aTotales[14] ), 16 )                                                            // EuroDebe    N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // EuroHaber   N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // BaseEuro    N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // NoConv      L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                             // NumeroInv   C  10    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Serie_RT    C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Factu_RT    N   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // BaseImp_RT  N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // BaseImp_RF  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Rectifica   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_RT    D   8    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Nic         C   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Libre       L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Libre       N   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Linyerrump  L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // SegActiv    C   6    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // SegGeog     C   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // IRect349    L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_OP    D   8    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_EX    D   8    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Departa5    C   5    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                             // Factura10   C  10    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Porcen_Ana  N   5    2
   ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Porcen_Seg  N   5    2
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // NumApunte   N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // EuroTotal   N  16    2
   ::cBufferAsiento      += Padr( "", 100 )                                                                                            // RazonSoc    C 100    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                             // Apellido1   C  50    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                             // Apellido2   C  50    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoOpe     C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // nFacTick    N   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NumAcuIni   C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NumAcuFin   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TerIdNif    N   1    0
   ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cDniCli, 15 )                                                   // TerNif      C  15    0
   ::cBufferAsiento      += Padr( ( D():FacturasClientes( ::nView ) )->cNomCli, 40 )                                                   // TerNom      C  40    0
   ::cBufferAsiento      += Padr( "", 9 )                                                                                              // TerNif14    C   9    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // TBienTran   L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                             // TBienCod    C  10    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // TransInm    L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Metal       L   1    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // MetalImp    N  16    2
   ::cBufferAsiento      += Padr( "", 12 )                                                                                             // Cliente     C  12    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // OpBienes    N   1    0
   ::cBufferAsiento      += Padr( ::cNumero(), 40 )                                                                                    // FacturaEx   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoFac     C   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoIva     C   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // GUID        C  40    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // L340        L   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                              // MetalEje    N   4    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                             // Document15  C  15    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                             // ClienteSup  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaSub    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImporteSup  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // DocSup      C  40    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                             // ClientePro  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaPro    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImportePro  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // DocPro      C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nClaveIRPF  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lArrend347  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // nSitInmueb  N   1    0
   ::cBufferAsiento      += Padr( "", 25 )                                                                                             // cRefCatast  C  25    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Concil347   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoRegula  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nCritCaja   N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lCritCaja   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // dMaxLiqui   D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // nTotalFac   N  16    2
   ::cBufferAsiento      += Padr( "", 32 )                                                                                             // idFactura   C  32    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // nCobrPago   N  16    2
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nTipoIG     N   2    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                             // DevoIvaId   C  50    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // iDevoluIva  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // MedioCrit   C   1    0
   ::cBufferAsiento      += Padr( "", 34 )                                                                                             // CuentaCrit  C  34    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // IconAc      L   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // GuidSPAY    C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoEntr    N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // Mod140      N   2    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaAnota  D   8    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nTipo140    N   2    0
   ::cBufferAsiento      += Padr( "", 11 )                                                                                             // Cuenta140   C  11    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // Importe140  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // LDepAduan   L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // LDifAduan   L   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nInter303   N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // idRecargo   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // EstadoSII   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave   N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoExenci  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoNoSuje  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoFact    N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NacuIniSII  C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NacuFinSII  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoRectif  N   2    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // bImpCoste   N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lEmiTercer  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // nEntrPrest  N   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FecRegCon   D   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // FactuEx_RT  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave1  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave2  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // ItaI        L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lExecl303   L   1    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                             // ConcepNew   C  50    0
   ::cBufferAsiento      += Padr( "", 30 )                                                                                             // TerNifNew   C  30    0
   ::cBufferAsiento      += Padr( "", 120 )                                                                                            // TerNomNew   C 120    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // SII_1415    L   1    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                             // cAutoriza   C  15    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lEmiTerDis  L   1    0
   ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                       // NifSuced    C   9    0
   //::cBufferAsiento      += Padr( "", 120 )                                                                                          // RazonSuced  C 120    0
   //::cBufferAsiento      += Padr( "F", 1 )                                                                                           // IfSimplifi  L   1    0
   //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                    // IfSinIdent  L   1    0

   if !empty( ::hFileDiario )
      fWrite( ::hFileDiario, ::cBufferAsiento )
   end if

   ::cBufferAsiento   := ""

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddAsientosRecibos() CLASS EnlaceSage50

   ::aTotales           := aTotFacCli( ( D():FacturasClientesCobros( ::nView ) )->cSerie + Str( ( D():FacturasClientesCobros( ::nView ) )->nNumFac ) + ( D():FacturasClientesCobros( ::nView ) )->cSufFac,;
                                       D():FacturasClientes( ::nView ),;
                                       D():FacturasClientesLineas( ::nView ),;
                                       D():TiposIva( ::nView ),;
                                       D():Divisas( ::nView ),;
                                       D():FacturasClientesCobros( ::nView ),;
                                       D():AnticiposClientes( ::nView ) )

   ::aTotalesIva        := ::aTotales[8]

   ::addDebeRecibo()
   ::addHaberRecibo()

   ::nContadorAsiento ++

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addDebeRecibo() CLASS EnlaceSage50

   ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                               // Asien       N   6    0
   ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():FacturasClientesCobros( ::nView ) )->dEntrada ), 8 )                              // Fecha       D   8    0
   ::cBufferAsiento      += Padr( AllTrim( cCliCta( ( D():FacturasClientesCobros( ::nView ) )->cCodCli, D():Clientes( ::nView ) ) ), 12 ) // SubCta      C  12    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // Contra      C  12    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // PtaDebe     N  16    2
   ::cBufferAsiento      += Padr( "N/Rec. " + ::cNumeroReciboFormato(), 25 )                                                              // Concepto    C  25    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // PtaHaber    N  16    2
   ::cBufferAsiento      += Right( Str( ( D():FacturasClientesCobros( ::nView ) )->nNumFac ), 8 )                                         // Factura     N   8    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // BaseImpo    N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 5 )                                                                             // IVA         N   5    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 5 )                                                                             // Receqiv     N   5    2
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // Documento   C  10    0
   ::cBufferAsiento      += Padr( "", 3 )                                                                                                 // Departa     C   3    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Clave       C   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Estado      C   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // NCasado     N   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TCasado     N   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Trans       N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // Cambio      N  16    6
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // DebeMe      N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // HaberMe     N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Auxiliar    C   1    0
   ::cBufferAsiento      += Padr( ( D():FacturasClientesCobros( ::nView ) )->cSerie, 1 )                                                  // Serie       C   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                                 // Sucursal    C   4    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // CodDivisa   C   5    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImpAuxMe    N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // MonedaUso   C   1    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                          // EuroDebe    N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( ( D():FacturasClientesCobros( ::nView ) )->nImporte ), 16 )                                                                            // EuroHaber   N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // BaseEuro    N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // NoConv      L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // NumeroInv   C  10    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Serie_RT    C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Factu_RT    N   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // BaseImp_RT  N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // BaseImp_RF  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Rectifica   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_RT    D   8    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Nic         C   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Libre       L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Libre       N   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Linyerrump  L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // SegActiv    C   6    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // SegGeog     C   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // IRect349    L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_OP    D   8    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_EX    D   8    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Departa5    C   5    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // Factura10   C  10    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Porcen_Ana  N   5    2
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Porcen_Seg  N   5    2
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // NumApunte   N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // EuroTotal   N  16    2
   ::cBufferAsiento      += Padr( "", 100 )                                                                                               // RazonSoc    C 100    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // Apellido1   C  50    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // Apellido2   C  50    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoOpe     C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // nFacTick    N   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NumAcuIni   C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NumAcuFin   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TerIdNif    N   1    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                                // TerNif      C  15    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // TerNom      C  40    0
   ::cBufferAsiento      += Padr( "", 9 )                                                                                                 // TerNif14    C   9    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // TBienTran   L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // TBienCod    C  10    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // TransInm    L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Metal       L   1    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // MetalImp    N  16    2
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // Cliente     C  12    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // OpBienes    N   1    0
   ::cBufferAsiento      += Padr( ::cNumeroReciboFormato(), 40 )                                                                          // FacturaEx   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoFac     C   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoIva     C   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // GUID        C  40    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // L340        L   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                                 // MetalEje    N   4    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                                // Document15  C  15    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // ClienteSup  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaSub    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImporteSup  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // DocSup      C  40    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // ClientePro  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaPro    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImportePro  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // DocPro      C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nClaveIRPF  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lArrend347  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // nSitInmueb  N   1    0
   ::cBufferAsiento      += Padr( "", 25 )                                                                                                // cRefCatast  C  25    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Concil347   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoRegula  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nCritCaja   N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lCritCaja   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // dMaxLiqui   D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // nTotalFac   N  16    2
   ::cBufferAsiento      += Padr( "", 32 )                                                                                                // idFactura   C  32    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // nCobrPago   N  16    2
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nTipoIG     N   2    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // DevoIvaId   C  50    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // iDevoluIva  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // MedioCrit   C   1    0
   ::cBufferAsiento      += Padr( "", 34 )                                                                                                // CuentaCrit  C  34    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // IconAc      L   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // GuidSPAY    C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoEntr    N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // Mod140      N   2    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaAnota  D   8    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nTipo140    N   2    0
   ::cBufferAsiento      += Padr( "", 11 )                                                                                                // Cuenta140   C  11    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // Importe140  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // LDepAduan   L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // LDifAduan   L   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nInter303   N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // idRecargo   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // EstadoSII   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave   N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoExenci  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoNoSuje  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoFact    N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NacuIniSII  C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NacuFinSII  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoRectif  N   2    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // bImpCoste   N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lEmiTercer  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // nEntrPrest  N   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FecRegCon   D   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // FactuEx_RT  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave1  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave2  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // ItaI        L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lExecl303   L   1    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // ConcepNew   C  50    0
   ::cBufferAsiento      += Padr( "", 30 )                                                                                                // TerNifNew   C  30    0
   ::cBufferAsiento      += Padr( "", 120 )                                                                                               // TerNomNew   C 120    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // SII_1415    L   1    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                                // cAutoriza   C  15    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lEmiTerDis  L   1    0
   ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                          // NifSuced    C   9    0

   if !empty( ::hFileDiario )
      fWrite( ::hFileDiario, ::cBufferAsiento )
   end if

   ::cBufferAsiento   := ""

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addHaberRecibo() CLASS EnlaceSage50

   local cCtaPgo

   cCtaPgo               := ( D():FacturasClientesCobros( ::nView ) )->cCtaRec

   if Empty( cCtaPgo )
      cCtaPgo            := cCtaFPago( ( D():FacturasClientesCobros( ::nView ) )->cCodPgo, D():FormasPago( ::nView ) )
   end if

   if Empty( cCtaPgo )
      cCtaPgo        := cCtaCob()
   end if

   ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                            // Asien       N   6    0
   ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():FacturasClientesCobros( ::nView ) )->dEntrada ), 8 )                           // Fecha       D   8    0
   ::cBufferAsiento      += Padr( AllTrim( cCtaPgo ), 12 )                                                                             // SubCta      C  12    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                             // Contra      C  12    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // PtaDebe     N  16    2
   ::cBufferAsiento      += Padr( "N/Rec. " + ::cNumeroReciboFormato(), 25 )                                                           // Concepto    C  25    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // PtaHaber    N  16    2
   ::cBufferAsiento      += Right( Str( ( D():FacturasClientesCobros( ::nView ) )->nNumFac ), 8 )                                      // Factura     N   8    0
   ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 16 )                                                                         // BaseImpo    N  16    2
   ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 5 )                                                                          // IVA         N   5    2
   ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 5 )                                                                          // Receqiv     N   5    2
   ::cBufferAsiento      += Padr( "", 10 )                                                                                             // Documento   C  10    0
   ::cBufferAsiento      += Padr( "", 3 )                                                                                              // Departa     C   3    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Clave       C   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Estado      C   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // NCasado     N   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TCasado     N   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Trans       N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // Cambio      N  16    6
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // DebeMe      N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // HaberMe     N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Auxiliar    C   1    0
   ::cBufferAsiento      += Pad( ( D():FacturasClientesCobros( ::nView ) )->cSerie, 1 )                                                // Serie       C   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                              // Sucursal    C   4    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                              // CodDivisa   C   5    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImpAuxMe    N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // MonedaUso   C   1    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( ( D():FacturasClientesCobros( ::nView ) )->nImporte ), 16 )                                                                         // EuroDebe    N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                       // EuroHaber   N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // BaseEuro    N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // NoConv      L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                             // NumeroInv   C  10    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Serie_RT    C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Factu_RT    N   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // BaseImp_RT  N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // BaseImp_RF  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Rectifica   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_RT    D   8    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Nic         C   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Libre       L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Libre       N   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Linyerrump  L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // SegActiv    C   6    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // SegGeog     C   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // IRect349    L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_OP    D   8    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_EX    D   8    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Departa5    C   5    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                             // Factura10   C  10    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Porcen_Ana  N   5    2
   ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Porcen_Seg  N   5    2
   ::cBufferAsiento      += Padr( "", 6 )                                                                                              // NumApunte   N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // EuroTotal   N  16    2
   ::cBufferAsiento      += Padr( "", 100 )                                                                                            // RazonSoc    C 100    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                             // Apellido1   C  50    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                             // Apellido2   C  50    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoOpe     C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // nFacTick    N   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NumAcuIni   C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NumAcuFin   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TerIdNif    N   1    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                             // TerNif      C  15    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // TerNom      C  40    0
   ::cBufferAsiento      += Padr( "", 9 )                                                                                              // TerNif14    C   9    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // TBienTran   L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                             // TBienCod    C  10    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // TransInm    L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Metal       L   1    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // MetalImp    N  16    2
   ::cBufferAsiento      += Padr( "", 12 )                                                                                             // Cliente     C  12    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // OpBienes    N   1    0
   ::cBufferAsiento      += Padr( ::cNumeroReciboFormato(), 40 )                                                                       // FacturaEx   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoFac     C   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoIva     C   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // GUID        C  40    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // L340        L   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                              // MetalEje    N   4    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                             // Document15  C  15    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                             // ClienteSup  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaSub    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImporteSup  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // DocSup      C  40    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                             // ClientePro  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaPro    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImportePro  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // DocPro      C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nClaveIRPF  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lArrend347  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // nSitInmueb  N   1    0
   ::cBufferAsiento      += Padr( "", 25 )                                                                                             // cRefCatast  C  25    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Concil347   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoRegula  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nCritCaja   N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lCritCaja   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // dMaxLiqui   D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // nTotalFac   N  16    2
   ::cBufferAsiento      += Padr( "", 32 )                                                                                             // idFactura   C  32    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // nCobrPago   N  16    2
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nTipoIG     N   2    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                             // DevoIvaId   C  50    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // iDevoluIva  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // MedioCrit   C   1    0
   ::cBufferAsiento      += Padr( "", 34 )                                                                                             // CuentaCrit  C  34    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // IconAc      L   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // GuidSPAY    C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoEntr    N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // Mod140      N   2    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaAnota  D   8    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nTipo140    N   2    0
   ::cBufferAsiento      += Padr( "", 11 )                                                                                             // Cuenta140   C  11    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // Importe140  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // LDepAduan   L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // LDifAduan   L   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nInter303   N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // idRecargo   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // EstadoSII   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave   N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoExenci  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoNoSuje  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoFact    N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NacuIniSII  C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NacuFinSII  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoRectif  N   2    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                             // bImpCoste   N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lEmiTercer  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                              // nEntrPrest  N   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FecRegCon   D   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                             // FactuEx_RT  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave1  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave2  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // ItaI        L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lExecl303   L   1    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                             // ConcepNew   C  50    0
   ::cBufferAsiento      += Padr( "", 30 )                                                                                             // TerNifNew   C  30    0
   ::cBufferAsiento      += Padr( "", 120 )                                                                                            // TerNomNew   C 120    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // SII_1415    L   1    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                             // cAutoriza   C  15    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lEmiTerDis  L   1    0
   ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                       // NifSuced    C   9    0

   if !empty( ::hFileDiario )
      fWrite( ::hFileDiario, ::cBufferAsiento )
   end if

   ::cBufferAsiento   := ""

Return ( nil )

//---------------------------------------------------------------------------//

METHOD cFormatoImporte( nImporte ) CLASS EnlaceSage50

   local cImporte    := ""

   cImporte          := AllTrim( Trans( nImporte, cPorDiv() ) )
   cImporte          := StrTran( cImporte, ".", "" )
   cImporte          := StrTran( cImporte, ",", "." )

RETURN ( cImporte )

//---------------------------------------------------------------------------//

METHOD cFormatoPorcentaje( nPorcentaje ) CLASS EnlaceSage50

   local cPorcentaje    := ""

   cPorcentaje          := AllTrim( Trans( nPorcentaje, "@E 999.99" ) )
   cPorcentaje          := StrTran( cPorcentaje, ".", "" )
   cPorcentaje          := StrTran( cPorcentaje, ",", "." )

RETURN ( cPorcentaje )

//---------------------------------------------------------------------------//

METHOD cFormatoFecha( dFecha ) CLASS EnlaceSage50

   local cFecha         := ""

   cFecha               += AllTrim( Str( Year( dFecha ) ) )
   cFecha               += AllTrim( RJust( Str( Month( dFecha ) ), "0", 2 ) )
   cFecha               += AllTrim( RJust( Str( Day( dFecha ) ), "0", 2 ) )

RETURN ( cFecha )

//---------------------------------------------------------------------------//

METHOD getSubCuentaIva( nIva ) CLASS EnlaceSage50

   local cSubCta        := ""
   local cPrefijo       := "477"
   local cSufijo        := AllTrim( Str( int( nIva ) ) )

   cSubCta              += cPrefijo
   cSubCta              := LJust( cSubCta, "0", ::nLenSubcta - len( cSufijo ) )
   cSubCta              += cSufijo

RETURN ( cSubCta )

//---------------------------------------------------------------------------//

METHOD getSubCuentaRe( nRe ) CLASS EnlaceSage50

   local cSubCta        := ""
   local cPrefijo       := "475"
   local cSufijo        := AllTrim( Str( int( nRe ) ) )

   cSubCta              += cPrefijo
   cSubCta              := LJust( cSubCta, "0", ::nLenSubcta - len( cSufijo ) )
   cSubCta              += cSufijo

RETURN ( cSubCta )

//---------------------------------------------------------------------------//

METHOD getSubCuentaIvaCompras( nIva ) CLASS EnlaceSage50

   local cSubCta        := ""
   local cPrefijo       := "472"
   local cSufijo        := AllTrim( Str( int( nIva ) ) )

   cSubCta              += cPrefijo
   cSubCta              := LJust( cSubCta, "0", ::nLenSubcta - len( cSufijo ) )
   cSubCta              += cSufijo

RETURN ( cSubCta )

//---------------------------------------------------------------------------//

METHOD ContabilizaTicketCliente( nView, oTree ) CLASS EnlaceSage50

   ::nView              := nView
   ::oTree              := oTree

   if Empty( ::nContadorAsiento )
      
      ::writeTree( "Error al indicar un asiento", 0 )
      
      if !empty( ::hFileDiario )
         fClose( ::hFileDiario )
      end if
      
      Return ( Self )

   end if

   if ( D():Tikets( ::nView ) )->lConTik
      
      ::writeTree( "Simplificada anteriormente contabilizada : " + ::cNumeroTicketFormato(), 0 )
      
      if !empty( ::hFileDiario )
         fClose( ::hFileDiario )
      end if

      Return ( Self )

   end if

   ::AddSubCtaIngresosTickets()
   ::AddSubCtaTickets()
   ::AddAsientosTickets()

   ::changeStateTicket()

Return ( .t. )

//---------------------------------------------------------------------------//

METHOD changeStateTicket() CLASS EnlaceSage50

   if dbLock( ( D():Tikets( ::nView ) ) )
      ( D():Tikets( ::nView ) )->lConTik    := .t.
      ( D():Tikets( ::nView ) )->( dbUnLock() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddSubCtaIngresosTickets() CLASS EnlaceSage50

   local nPos           := 0
   local cCnt           := ""
   local nRecAnt        := ( D():TiketsLineas( ::nView ) )->( Recno() )
   local nOrdAnt        := ( D():TiketsLineas( ::nView ) )->( OrdSetFocus( "CNUMTIL" ) )

   ::aSubCtaIngresos    := {}

   if ( D():TiketsLineas( ::nView ) )->( dbSeek( ::cNumeroTicket() ) )

      while ( D():TiketsLineas( ::nView ) )->cSerTil + ( D():TiketsLineas( ::nView ) )->cNumTil + ( D():TiketsLineas( ::nView ) )->cSufTil == ::cNumeroTicket() .and.;
            !( D():TiketsLineas( ::nView ) )->( Eof() )

            if !Empty( ( D():TiketsLineas( ::nView ) )->cCbaTil )

               cCnt           := retCtaVta( ( D():TiketsLineas( ::nView ) )->cCbaTil, .f., D():Articulos( ::nView ) ) 

               if Empty( cCnt )
                  cCnt        := cCtaCli() + replicate( "0", ::nLenSubcta - 3 )
               end if

               nPos           := aScan( ::aSubCtaIngresos, {|h| hGet( h, "cuenta" ) == cCnt } )
               
               if nPos == 0
                  aAdd( ::aSubCtaIngresos, { "cuenta" => cCnt,;
                                             "importe" => nNetLTpv( D():TiketsLineas( ::nView ) ) } )
               else

                  hSet( ::aSubCtaIngresos[ nPos ], "importe", hGet( ::aSubCtaIngresos[ nPos ], "importe" ) + nNetLTpv( D():TiketsLineas( ::nView ) ) )

               end if

            end if

            ( D():TiketsLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ( D():TiketsLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():TiketsLineas( ::nView ) )->( dbGoTo( nRecAnt ) )

   asort( ::aSubCtaIngresos, , , {|x,y| hget( x, "cuenta" ) < hget( y, "cuenta" ) } )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddSubCtaTickets() CLASS EnlaceSage50

   local nOrdAnt  := ( D():Clientes( ::nView ) )->( OrdSetFocus( "COD" ) )

   if ::lIncludeSubCta()
      Return ( nil )
   end if

   aAdd( ::aCtaClientes, ( D():Tikets( ::nView ) )->cCliTik )

   if ( D():Clientes( ::nView ) )->( dbSeek( ( D():Tikets( ::nView ) )->cCliTik ) )

      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Subcta, 12 )          // COD         CODIGO      C  12    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Titulo, 40 )          // TITULO      NOMBRE      C  40    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Nif, 15 )             // NIF         CIF         C  15    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Domicilio, 35 )       // DOMICILIO   DIRECCION   C  35    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Poblacion, 25 )       // POBLACION   POBLACION   C  25    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Provincia, 20 )       // PROVINCIA   PROVINCIA   C  20    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->CodPostal, 5 )        // CODPOSTAL   COD POSTAL  C   5    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // DIVISA                  L   1    0
      ::cBufferSubCta      += Padr( "", 5 )                                            // CODDIVISA   COD DIVISA  C   5    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // DOCUMENTO               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // AJUSTAME                L   1    0
      ::cBufferSubCta      += Padr( "", 1 )                                            // TIPOIVA     TIPO IVA    C   1    0
      ::cBufferSubCta      += Padr( "", 9 )                                            // PROYE       PLAN 1      C   9    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBEQUIV                C  12    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBCIERRE               C  12    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LINTERRUMP              L   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SEGMENTO    PALN 2      C  12    0
      ::cBufferSubCta      += Padr( " 0.00", 5 )                                       // TPC         PORC. IVA   N   5    2
      ::cBufferSubCta      += Padr( " 0.00", 5 )                                       // RECEQUIV    PORC. RE    N   5    2
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Fax, 15 )             // FAX01       FAX         C  15    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->cMeiInt, 50 )         // EMAIL       EMAIL       C  50    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Titulo, 100 )         // TITULOL     NOM LARGO   C 100    0
      ::cBufferSubCta      += Padr( "0", 1 )                                           // IDNIF       TIPO ID     C   1    0
      ::cBufferSubCta      += Padr( "", 2 )                                            // CODPAIS     ISO PAIS    C   2    0
      ::cBufferSubCta      += Padr( "", 9 )                                            // REP14NIF                C   9    0
      ::cBufferSubCta      += Padr( "", 40 )                                           // REP14NOM                C  40    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // METCOBRO                L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // METCOBFRE               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // SUPLIDO                 L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // PROVISION               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LESIRPF                 L   1    0
      ::cBufferSubCta      += Padr( " 0.00", 5 )                                       // NIRPF       PORC IRPF   N   5    2
      ::cBufferSubCta      += Padr( " 0", 2 )                                          // NCLAVEIRPF  CLAVE IRPF  N   2    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LESMOD130               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LDEDUCIBLE              L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LCRITCAJA               L   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // CSUBIVAAS               C  12    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LPEFECTIVO              L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LINGGASTO               L   1    0
      ::cBufferSubCta      += Padr( " 0", 2 )                                          // NTIPOIG                 N   2    0
      ::cBufferSubCta      += Padr( "", 1 )                                            // MEDIOCRIT               C   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBCTACON               C  12    0
      ::cBufferSubCta      += Padr( " 0", 2 )                                          // NTIPOEXIST              N   2    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBCTAVAR               C  12    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LMOD140                 L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LIRPF                   L   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SCTABANCO               C  12    0
      ::cBufferSubCta      += Padr( "", 5 )                                            // SCODMUN                 C   5    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Nif, 30 )             // NIFNEW                  C  30    0
      ::cBufferSubCta      += Padr( ( D():Clientes( ::nView ) )->Titulo, 120 )  + CRLF // TITULONEW   NOM. AMPLI. C 120    0

   end if

   ( D():Clientes( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddAsientosTickets() CLASS EnlaceSage50

   ::aTotales           := aTotTik( ( D():Tikets( ::nView ) )->cSerTik + ( D():Tikets( ::nView ) )->cNumTik + ( D():Tikets( ::nView ) )->cSufTik,;
                                      D():Tikets( ::nView ),;
                                      D():TiketsLineas( ::nView ),;
                                      D():Divisas( ::nView ) )

   ::aTotalesIva        := ::aTotales[5]

   ::addDebeTickets()
   ::addHaberTickets()
   ::addIvaTickets()

   ::nContadorAsiento ++

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addDebeTickets() CLASS EnlaceSage50

   ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                               // Asien       N   6    0
   ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():Tikets( ::nView ) )->dFecTik ), 8 )                                              // Fecha       D   8    0
   ::cBufferAsiento      += Padr( AllTrim( cCliCta( ( D():Tikets( ::nView ) )->cCliTik, D():Clientes( ::nView ) ) ), 12 )                 // SubCta      C  12    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // Contra      C  12    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // PtaDebe     N  16    2
   ::cBufferAsiento      += Padr( "N/Sinplificada " + ::cNumeroTicketFormato(), 25 )                                                      // Concepto    C  25    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // PtaHaber    N  16    2
   ::cBufferAsiento      += Right( ( D():Tikets( ::nView ) )->cNumTik, 8 )                                                                // Factura     N   8    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // BaseImpo    N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 5 )                                                                             // IVA         N   5    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 5 )                                                                             // Receqiv     N   5    2
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // Documento   C  10    0
   ::cBufferAsiento      += Padr( "", 3 )                                                                                                 // Departa     C   3    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Clave       C   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Estado      C   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // NCasado     N   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TCasado     N   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Trans       N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // Cambio      N  16    6
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // DebeMe      N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // HaberMe     N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Auxiliar    C   1    0
   ::cBufferAsiento      += Padr( ( D():Tikets( ::nView ) )->cSerTik, 1 )                                                                 // Serie       C   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                                 // Sucursal    C   4    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // CodDivisa   C   5    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImpAuxMe    N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // MonedaUso   C   1    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( ( D():Tikets( ::nView ) )->nTotTik ), 16 )                                           // EuroDebe    N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // EuroHaber   N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // BaseEuro    N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // NoConv      L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // NumeroInv   C  10    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Serie_RT    C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Factu_RT    N   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // BaseImp_RT  N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // BaseImp_RF  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Rectifica   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_RT    D   8    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Nic         C   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Libre       L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Libre       N   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Linyerrump  L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // SegActiv    C   6    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // SegGeog     C   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // IRect349    L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_OP    D   8    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_EX    D   8    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Departa5    C   5    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // Factura10   C  10    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Porcen_Ana  N   5    2
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Porcen_Seg  N   5    2
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // NumApunte   N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // EuroTotal   N  16    2
   ::cBufferAsiento      += Padr( "", 100 )                                                                                               // RazonSoc    C 100    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // Apellido1   C  50    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // Apellido2   C  50    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoOpe     C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // nFacTick    N   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NumAcuIni   C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NumAcuFin   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TerIdNif    N   1    0
   ::cBufferAsiento      += Padr( ( D():Tikets( ::nView ) )->cDniCli, 15 )                                                                // TerNif      C  15    0
   ::cBufferAsiento      += Padr( ( D():Tikets( ::nView ) )->cNomTik, 40 )                                                                // TerNom      C  40    0
   ::cBufferAsiento      += Padr( "", 9 )                                                                                                 // TerNif14    C   9    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // TBienTran   L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // TBienCod    C  10    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // TransInm    L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Metal       L   1    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // MetalImp    N  16    2
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // Cliente     C  12    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // OpBienes    N   1    0
   ::cBufferAsiento      += Padr( ::cNumeroTicketFormato(), 40 )                                                                          // FacturaEx   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoFac     C   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoIva     C   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // GUID        C  40    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // L340        L   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                                 // MetalEje    N   4    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                                // Document15  C  15    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // ClienteSup  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaSub    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImporteSup  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // DocSup      C  40    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // ClientePro  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaPro    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImportePro  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // DocPro      C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nClaveIRPF  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lArrend347  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // nSitInmueb  N   1    0
   ::cBufferAsiento      += Padr( "", 25 )                                                                                                // cRefCatast  C  25    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Concil347   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoRegula  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nCritCaja   N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lCritCaja   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // dMaxLiqui   D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // nTotalFac   N  16    2
   ::cBufferAsiento      += Padr( "", 32 )                                                                                                // idFactura   C  32    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // nCobrPago   N  16    2
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nTipoIG     N   2    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // DevoIvaId   C  50    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // iDevoluIva  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // MedioCrit   C   1    0
   ::cBufferAsiento      += Padr( "", 34 )                                                                                                // CuentaCrit  C  34    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // IconAc      L   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // GuidSPAY    C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoEntr    N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // Mod140      N   2    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaAnota  D   8    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nTipo140    N   2    0
   ::cBufferAsiento      += Padr( "", 11 )                                                                                                // Cuenta140   C  11    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // Importe140  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // LDepAduan   L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // LDifAduan   L   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nInter303   N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // idRecargo   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // EstadoSII   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave   N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoExenci  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoNoSuje  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoFact    N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NacuIniSII  C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NacuFinSII  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoRectif  N   2    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // bImpCoste   N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lEmiTercer  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // nEntrPrest  N   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FecRegCon   D   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // FactuEx_RT  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave1  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave2  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // ItaI        L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lExecl303   L   1    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // ConcepNew   C  50    0
   ::cBufferAsiento      += Padr( "", 30 )                                                                                                // TerNifNew   C  30    0
   ::cBufferAsiento      += Padr( "", 120 )                                                                                               // TerNomNew   C 120    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // SII_1415    L   1    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                                // cAutoriza   C  15    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lEmiTerDis  L   1    0
   ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                          // NifSuced    C   9    0
   //::cBufferAsiento      += Padr( "", 120 )                                                                                             // RazonSuced  C 120    0
   //::cBufferAsiento      += Padr( "F", 1 )                                                                                              // IfSimplifi  L   1    0
   //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                       // IfSinIdent  L   1    0

   if !empty( ::hFileDiario )
      fWrite( ::hFileDiario, ::cBufferAsiento )
   end if

   ::cBufferAsiento   := ""

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addHaberTickets() CLASS EnlaceSage50

   local hCtaIng

   for each hCtaIng in ::aSubCtaIngresos

      ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                            // Asien       N   6    0
      ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():Tikets( ::nView ) )->dFecTik ), 8 )                                           // Fecha       D   8    0
      ::cBufferAsiento      += Padr( AllTrim( hGet( hCtaIng, "cuenta" ) ), 12 )                                                           // SubCta      C  12    0
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // Contra      C  12    0
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // PtaDebe     N  16    2
      ::cBufferAsiento      += Padr( "N/Simplificada " + ::cNumeroTicketFormato(), 25 )                                                   // Concepto    C  25    0
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // PtaHaber    N  16    2
      ::cBufferAsiento      += Right( ( D():Tikets( ::nView ) )->cNumTik, 8 )                                                             // Factura     N   8    0
      ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 16 )                                                                         // BaseImpo    N  16    2
      ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 5 )                                                                          // IVA         N   5    2
      ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 5 )                                                                          // Receqiv     N   5    2
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // Documento   C  10    0
      ::cBufferAsiento      += Padr( "", 3 )                                                                                              // Departa     C   3    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Clave       C   6    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Estado      C   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // NCasado     N   6    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TCasado     N   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Trans       N   6    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // Cambio      N  16    6
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // DebeMe      N  16    2
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // HaberMe     N  16    2
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Auxiliar    C   1    0
      ::cBufferAsiento      += Pad( ( D():Tikets( ::nView ) )->cSerTik, 1 )                                                               // Serie       C   1    0
      ::cBufferAsiento      += Padr( "", 4 )                                                                                              // Sucursal    C   4    0
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // CodDivisa   C   5    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImpAuxMe    N  16    2
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // MonedaUso   C   1    0
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // EuroDebe    N  16    2
      ::cBufferAsiento      += Padl( ::cFormatoImporte( hGet( hCtaIng, "importe" ) ), 16 )                                                // EuroHaber   N  16    2
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // BaseEuro    N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // NoConv      L   1    0
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // NumeroInv   C  10    2
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Serie_RT    C   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Factu_RT    N   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // BaseImp_RT  N  16    2
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // BaseImp_RF  N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Rectifica   L   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_RT    D   8    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Nic         C   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Libre       L   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Libre       N   6    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Linyerrump  L   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // SegActiv    C   6    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // SegGeog     C   6    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // IRect349    L   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_OP    D   8    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_EX    D   8    0
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Departa5    C   5    0
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // Factura10   C  10    0
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Porcen_Ana  N   5    2
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Porcen_Seg  N   5    2
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // NumApunte   N   6    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // EuroTotal   N  16    2
      ::cBufferAsiento      += Padr( "", 100 )                                                                                            // RazonSoc    C 100    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // Apellido1   C  50    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // Apellido2   C  50    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoOpe     C   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // nFacTick    N   8    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NumAcuIni   C  40    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NumAcuFin   C  40    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TerIdNif    N   1    0
      ::cBufferAsiento      += Padr( ( D():Tikets( ::nView ) )->cDniCli, 15 )                                                             // TerNif      C  15    0
      ::cBufferAsiento      += Padr( ( D():Tikets( ::nView ) )->cNomTik, 40 )                                                             // TerNom      C  40    0
      ::cBufferAsiento      += Padr( "", 9 )                                                                                              // TerNif14    C   9    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // TBienTran   L   1    0
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // TBienCod    C  10    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // TransInm    L   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Metal       L   1    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // MetalImp    N  16    2
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // Cliente     C  12    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // OpBienes    N   1    0
      ::cBufferAsiento      += Padr( ::cNumeroTicketFormato(), 40 )                                                                       // FacturaEx   C  40    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoFac     C   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoIva     C   1    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // GUID        C  40    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // L340        L   1    0
      ::cBufferAsiento      += Padr( "", 4 )                                                                                              // MetalEje    N   4    0
      ::cBufferAsiento      += Padr( "", 15 )                                                                                             // Document15  C  15    0
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // ClienteSup  C  12    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaSub    D   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImporteSup  N  16    2
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // DocSup      C  40    0
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // ClientePro  C  12    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaPro    D   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImportePro  N  16    2
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // DocPro      C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nClaveIRPF  N   2    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lArrend347  L   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // nSitInmueb  N   1    0
      ::cBufferAsiento      += Padr( "", 25 )                                                                                             // cRefCatast  C  25    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Concil347   N   1    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoRegula  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nCritCaja   N   2    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lCritCaja   L   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // dMaxLiqui   D   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // nTotalFac   N  16    2
      ::cBufferAsiento      += Padr( "", 32 )                                                                                             // idFactura   C  32    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // nCobrPago   N  16    2
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nTipoIG     N   2    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // DevoIvaId   C  50    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // iDevoluIva  L   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // MedioCrit   C   1    0
      ::cBufferAsiento      += Padr( "", 34 )                                                                                             // CuentaCrit  C  34    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // IconAc      L   1    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // GuidSPAY    C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoEntr    N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // Mod140      N   2    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaAnota  D   8    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nTipo140    N   2    0
      ::cBufferAsiento      += Padr( "", 11 )                                                                                             // Cuenta140   C  11    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // Importe140  N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // LDepAduan   L   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // LDifAduan   L   1    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nInter303   N   2    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // idRecargo   C  40    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // EstadoSII   N   1    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave   N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoExenci  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoNoSuje  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoFact    N   2    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NacuIniSII  C  40    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NacuFinSII  C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoRectif  N   2    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // bImpCoste   N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lEmiTercer  L   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // nEntrPrest  N   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FecRegCon   D   8    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // FactuEx_RT  C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave1  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave2  N   2    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // ItaI        L   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lExecl303   L   1    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // ConcepNew   C  50    0
      ::cBufferAsiento      += Padr( "", 30 )                                                                                             // TerNifNew   C  30    0
      ::cBufferAsiento      += Padr( "", 120 )                                                                                            // TerNomNew   C 120    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // SII_1415    L   1    0
      ::cBufferAsiento      += Padr( "", 15 )                                                                                             // cAutoriza   C  15    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lEmiTerDis  L   1    0
      ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                       // NifSuced    C   9    0
      //::cBufferAsiento      += Padr( "", 120 )                                                                                          // RazonSuced  C 120    0
      //::cBufferAsiento      += Padr( "F", 1 )                                                                                           // IfSimplifi  L   1    0
      //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                    // IfSinIdent  L   1    0

      if !empty( ::hFileDiario )
         fWrite( ::hFileDiario, ::cBufferAsiento )
      end if

      ::cBufferAsiento   := ""

   next

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addIvaTickets() CLASS EnlaceSage50

   local n 

   for n:= 1 to 3

      if ::aTotales[ 5, n ] != nil

         ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                         // Asien       N   6    0
         ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():Tikets( ::nView ) )->dFecTik ), 8 )                                        // Fecha       D   8    0
         ::cBufferAsiento      += Padr( ::getSubCuentaIva( ::aTotales[ 5, n ] ), 12 )                                                     // SubCta      C  12    0
         ::cBufferAsiento      += Padr( AllTrim( cCliCta( ( D():Tikets( ::nView ) )->cCliTik, D():Clientes( ::nView ) ) ), 12 )           // Contra      C  12    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // PtaDebe     N  16    2
         ::cBufferAsiento      += Padr( "N/Simplificada " + ::cNumeroTicketFormato(), 25 )                                                // Concepto    C  25    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // PtaHaber    N  16    2
         ::cBufferAsiento      += Right( ( D():Tikets( ::nView ) )->cNumTik, 8 )                                                          // Factura     N   8    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // BaseImpo    N  16    2
         ::cBufferAsiento      += Padl( ::cFormatoPorcentaje( ::aTotales[ 5, n ] ), 5 )                                                   // IVA         N   5    2
         ::cBufferAsiento      += Padl( ::cFormatoPorcentaje( 0 ), 5 )                                                                    // Receqiv     N   5    2
         ::cBufferAsiento      += Padr( "", 10 )                                                                                          // Documento   C  10    0
         ::cBufferAsiento      += Padr( "", 3 )                                                                                           // Departa     C   3    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // Clave       C   6    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Estado      C   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // NCasado     N   6    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TCasado     N   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // Trans       N   6    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // Cambio      N  16    6
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // DebeMe      N  16    2
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // HaberMe     N  16    2
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Auxiliar    C   1    0
         ::cBufferAsiento      += Padr( ( D():Tikets( ::nView ) )->cSerTik, 1 )                                                           // Serie       C   1    0
         ::cBufferAsiento      += Padr( "", 4 )                                                                                           // Sucursal    C   4    0
         ::cBufferAsiento      += Padr( "", 5 )                                                                                           // CodDivisa   C   5    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // ImpAuxMe    N  16    2
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // MonedaUso   C   1    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                      // EuroDebe    N  16    2
         ::cBufferAsiento      += Padl( ::cFormatoImporte( ::aTotales[ 7, n ] ), 16 )                                                     // EuroHaber   N  16    2
         ::cBufferAsiento      += Padl( ::cFormatoImporte( ::aTotales[ 6, n ] ), 16 )                                                     // BaseEuro    N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // NoConv      L   1    0
         ::cBufferAsiento      += Padr( "", 10 )                                                                                          // NumeroInv   C  10    2
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Serie_RT    C   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Factu_RT    N   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // BaseImp_RT  N  16    2
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // BaseImp_RF  N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Rectifica   L   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Fecha_RT    D   8    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Nic         C   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Libre       L   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // Libre       N   6    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Linyerrump  L   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // SegActiv    C   6    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // SegGeog     C   6    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // IRect349    L   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Fecha_OP    D   8    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // Fecha_EX    D   8    0
         ::cBufferAsiento      += Padr( "", 5 )                                                                                           // Departa5    C   5    0
         ::cBufferAsiento      += Padr( "", 10 )                                                                                          // Factura10   C  10    0
         ::cBufferAsiento      += Padr( "", 5 )                                                                                           // Porcen_Ana  N   5    2
         ::cBufferAsiento      += Padr( "", 5 )                                                                                           // Porcen_Seg  N   5    2
         ::cBufferAsiento      += Padr( "", 6 )                                                                                           // NumApunte   N   6    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // EuroTotal   N  16    2
         ::cBufferAsiento      += Padr( "", 100 )                                                                                         // RazonSoc    C 100    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                          // Apellido1   C  50    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                          // Apellido2   C  50    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TipoOpe     C   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // nFacTick    N   8    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NumAcuIni   C  40    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NumAcuFin   C  40    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TerIdNif    N   1    0
         ::cBufferAsiento      += Padr( ( D():Tikets( ::nView ) )->cDniCli, 15 )                                                          // TerNif      C  15    0
         ::cBufferAsiento      += Padr( ( D():Tikets( ::nView ) )->cNomTik, 40 )                                                          // TerNom      C  40    0
         ::cBufferAsiento      += Padr( "", 9 )                                                                                           // TerNif14    C   9    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // TBienTran   L   1    0
         ::cBufferAsiento      += Padr( "", 10 )                                                                                          // TBienCod    C  10    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // TransInm    L   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // Metal       L   1    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // MetalImp    N  16    2
         ::cBufferAsiento      += Padr( "", 12 )                                                                                          // Cliente     C  12    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // OpBienes    N   1    0
         ::cBufferAsiento      += Padr( ::cNumeroTicketFormato(), 40 )                                                                    // FacturaEx   C  40    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TipoFac     C   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // TipoIva     C   1    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // GUID        C  40    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // L340        L   1    0
         ::cBufferAsiento      += Padr( "", 4 )                                                                                           // MetalEje    N   4    0
         ::cBufferAsiento      += Padr( "", 15 )                                                                                          // Document15  C  15    0
         ::cBufferAsiento      += Padr( "", 12 )                                                                                          // ClienteSup  C  12    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FechaSub    D   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // ImporteSup  N  16    2
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // DocSup      C  40    0
         ::cBufferAsiento      += Padr( "", 12 )                                                                                          // ClientePro  C  12    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FechaPro    D   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // ImportePro  N  16    2
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // DocPro      C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nClaveIRPF  N   2    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lArrend347  L   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // nSitInmueb  N   1    0
         ::cBufferAsiento      += Padr( "", 25 )                                                                                          // cRefCatast  C  25    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // Concil347   N   1    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoRegula  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nCritCaja   N   2    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lCritCaja   L   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // dMaxLiqui   D   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // nTotalFac   N  16    2
         ::cBufferAsiento      += Padr( "", 32 )                                                                                          // idFactura   C  32    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // nCobrPago   N  16    2
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nTipoIG     N   2    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                          // DevoIvaId   C  50    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // iDevoluIva  L   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // MedioCrit   C   1    0
         ::cBufferAsiento      += Padr( "", 34 )                                                                                          // CuentaCrit  C  34    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // IconAc      L   1    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // GuidSPAY    C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoEntr    N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // Mod140      N   2    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FechaAnota  D   8    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nTipo140    N   2    0
         ::cBufferAsiento      += Padr( "", 11 )                                                                                          // Cuenta140   C  11    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // Importe140  N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // LDepAduan   L   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // LDifAduan   L   1    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // nInter303   N   2    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // idRecargo   C  40    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // EstadoSII   N   1    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoClave   N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoExenci  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoNoSuje  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoFact    N   2    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NacuIniSII  C  40    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // NacuFinSII  C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoRectif  N   2    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                          // bImpCoste   N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lEmiTercer  L   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                           // nEntrPrest  N   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                           // FecRegCon   D   8    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                          // FactuEx_RT  C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoClave1  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                           // TipoClave2  N   2    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // ItaI        L   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lExecl303   L   1    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                          // ConcepNew   C  50    0
         ::cBufferAsiento      += Padr( "", 30 )                                                                                          // TerNifNew   C  30    0
         ::cBufferAsiento      += Padr( "", 120 )                                                                                         // TerNomNew   C 120    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // SII_1415    L   1    0
         ::cBufferAsiento      += Padr( "", 15 )                                                                                          // cAutoriza   C  15    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                          // lEmiTerDis  L   1    0
         ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                    // NifSuced    C   9    0
         //::cBufferAsiento      += Padr( "", 120 )                                                                                       // RazonSuced  C 120    0
         //::cBufferAsiento      += Padr( "F", 1 )                                                                                        // IfSimplifi  L   1    0
         //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                 // IfSinIdent  L   1    0

         if !empty( ::hFileDiario )
            fWrite( ::hFileDiario, ::cBufferAsiento )
         end if

         ::cBufferAsiento   := ""

      end if

   next

Return ( nil )

//---------------------------------------------------------------------------//

METHOD ContabilizaFacturaProveedor( nView, oTree ) CLASS EnlaceSage50

   ::nView              := nView
   ::oTree              := oTree

   if Empty( ::nContadorAsiento )
      
      ::writeTree( "Error al indicar un asiento", 0 )
      
      if !empty( ::hFileDiario )
         fClose( ::hFileDiario )
      end if
      
      Return ( Self )

   end if

   if ( D():FacturasProveedores( ::nView ) )->lContab
      
      ::writeTree( "Factura anteriormente contabilizada : " + ::cNumeroFacturaProveedor(), 0 )
      
      if !empty( ::hFileDiario )
         fClose( ::hFileDiario )
      end if

      Return ( Self )

   end if

   ::AddSubCtaGastosFacPrv()
   ::AddSubCtaFacPrv()
   ::AddAsientosFacPrv()

   ::changeStateFacturaProveedor()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD changeStateFacturaProveedor() CLASS EnlaceSage50

   if dbLock( ( D():FacturasProveedores( ::nView ) ) )
      ( D():FacturasProveedores( ::nView ) )->lContab    := .t.
      ( D():FacturasProveedores( ::nView ) )->( dbUnLock() )
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD AddSubCtaGastosFacPrv() CLASS EnlaceSage50

   local nPos           := 0
   local cCnt           := ""
   local nRecAnt        := ( D():FacturasProveedoresLineas( ::nView ) )->( Recno() )
   local nOrdAnt        := ( D():FacturasProveedoresLineas( ::nView ) )->( OrdSetFocus( "nNumFac" ) )

   ::aSubCtaIngresos    := {}

   if ( D():FacturasProveedoresLineas( ::nView ) )->( dbSeek( ::cNumeroFacturaProveedor() ) )

      while ( D():FacturasProveedoresLineas( ::nView ) )->cSerFac + Str( ( D():FacturasProveedoresLineas( ::nView ) )->nNumFac ) + ( D():FacturasProveedoresLineas( ::nView ) )->cSufFac == ::cNumeroFacturaProveedor() .and.;
            !( D():FacturasProveedoresLineas( ::nView ) )->( Eof() )

            if !Empty( ( D():FacturasProveedoresLineas( ::nView ) )->cRef )

               cCnt           := RetCtaCom( ( D():FacturasProveedoresLineas( ::nView ) )->cRef, .f., D():Articulos( ::nView ) ) 

               if Empty( cCnt )
                  cCnt        := cCtaPrv() + replicate( "0", ::nLenSubcta - 3 )
               end if

               nPos           := aScan( ::aSubCtaIngresos, {|h| hGet( h, "cuenta" ) == cCnt } )
               
               if nPos == 0
                  aAdd( ::aSubCtaIngresos, { "cuenta" => cCnt,;
                                             "importe" => nNetLFacPrv( D():FacturasProveedoresLineas( ::nView ), D():FacturasProveedores( ::nView ) ) } )
               else

                  hSet( ::aSubCtaIngresos[ nPos ], "importe", hGet( ::aSubCtaIngresos[ nPos ], "importe" ) + nNetLFacPrv( D():FacturasProveedoresLineas( ::nView ), D():FacturasProveedores( ::nView ) ) )

               end if

            end if

            ( D():FacturasProveedoresLineas( ::nView ) )->( dbSkip() )

      end while

   end if

   ( D():FacturasProveedoresLineas( ::nView ) )->( OrdSetFocus( nOrdAnt ) )
   ( D():FacturasProveedoresLineas( ::nView ) )->( dbGoTo( nRecAnt ) )

   asort( ::aSubCtaIngresos, , , {|x,y| hget( x, "cuenta" ) < hget( y, "cuenta" ) } )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddSubCtaFacPrv() CLASS EnlaceSage50

   local nOrdAnt  := ( D():Proveedores( ::nView ) )->( OrdSetFocus( "COD" ) )

   if ::lIncludeSubCtaPrv()
      Return ( nil )
   end if

   aAdd( ::aCtaProveedores, ( D():FacturasProveedores( ::nView ) )->cCodPrv )

   if ( D():Proveedores( ::nView ) )->( dbSeek( ( D():FacturasProveedores( ::nView ) )->cCodPrv ) )

      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->Subcta, 12 )          // COD         CODIGO      C  12    0
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->Titulo, 40 )          // TITULO      NOMBRE      C  40    0
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->Nif, 15 )             // NIF         CIF         C  15    0
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->Domicilio, 35 )       // DOMICILIO   DIRECCION   C  35    0
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->Poblacion, 25 )       // POBLACION   POBLACION   C  25    0
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->Provincia, 20 )       // PROVINCIA   PROVINCIA   C  20    0
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->CodPostal, 5 )        // CODPOSTAL   COD POSTAL  C   5    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // DIVISA                  L   1    0
      ::cBufferSubCta      += Padr( "", 5 )                                            // CODDIVISA   COD DIVISA  C   5    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // DOCUMENTO               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // AJUSTAME                L   1    0
      ::cBufferSubCta      += Padr( "", 1 )                                            // TIPOIVA     TIPO IVA    C   1    0
      ::cBufferSubCta      += Padr( "", 9 )                                            // PROYE       PLAN 1      C   9    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBEQUIV                C  12    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBCIERRE               C  12    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LINTERRUMP              L   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SEGMENTO    PALN 2      C  12    0
      ::cBufferSubCta      += Padr( " 0.00", 5 )                                       // TPC         PORC. IVA   N   5    2
      ::cBufferSubCta      += Padr( " 0.00", 5 )                                       // RECEQUIV    PORC. RE    N   5    2
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->Fax, 15 )             // FAX01       FAX         C  15    0
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->cMeiInt, 50 )         // EMAIL       EMAIL       C  50    0
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->Titulo, 100 )         // TITULOL     NOM LARGO   C 100    0
      ::cBufferSubCta      += Padr( "0", 1 )                                           // IDNIF       TIPO ID     C   1    0
      ::cBufferSubCta      += Padr( "", 2 )                                            // CODPAIS     ISO PAIS    C   2    0
      ::cBufferSubCta      += Padr( "", 9 )                                            // REP14NIF                C   9    0
      ::cBufferSubCta      += Padr( "", 40 )                                           // REP14NOM                C  40    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // METCOBRO                L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // METCOBFRE               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // SUPLIDO                 L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // PROVISION               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LESIRPF                 L   1    0
      ::cBufferSubCta      += Padr( " 0.00", 5 )                                       // NIRPF       PORC IRPF   N   5    2
      ::cBufferSubCta      += Padr( " 0", 2 )                                          // NCLAVEIRPF  CLAVE IRPF  N   2    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LESMOD130               L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LDEDUCIBLE              L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LCRITCAJA               L   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // CSUBIVAAS               C  12    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LPEFECTIVO              L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LINGGASTO               L   1    0
      ::cBufferSubCta      += Padr( " 0", 2 )                                          // NTIPOIG                 N   2    0
      ::cBufferSubCta      += Padr( "", 1 )                                            // MEDIOCRIT               C   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBCTACON               C  12    0
      ::cBufferSubCta      += Padr( " 0", 2 )                                          // NTIPOEXIST              N   2    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SUBCTAVAR               C  12    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LMOD140                 L   1    0
      ::cBufferSubCta      += Padr( "F", 1 )                                           // LIRPF                   L   1    0
      ::cBufferSubCta      += Padr( "", 12 )                                           // SCTABANCO               C  12    0
      ::cBufferSubCta      += Padr( "", 5 )                                            // SCODMUN                 C   5    0
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->Nif, 30 )             // NIFNEW                  C  30    0
      ::cBufferSubCta      += Padr( ( D():Proveedores( ::nView ) )->Titulo, 120 )  + CRLF // TITULONEW   NOM. AMPLI. C 120    0

   end if

   ( D():Proveedores( ::nView ) )->( OrdSetFocus( nOrdAnt ) )

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddAsientosFacPrv() CLASS EnlaceSage50

   ::aTotales           := aTotFacPrv( ( D():FacturasProveedores( ::nView ) )->cSerFac + Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ) + ( D():FacturasProveedores( ::nView ) )->cSufFac,;
                                       D():FacturasProveedores( ::nView ),;
                                       D():FacturasProveedoresLineas( ::nView ),;
                                       D():TiposIva( ::nView ),;
                                       D():Divisas( ::nView ),;
                                       D():FacturasProveedoresPagos( ::nView ) )

   ::aTotalesIva        := ::aTotales[5]

   ::addDebeFacPrv()
   ::addHaberFacPrv()
   ::addIvaFacPrv()

   ::nContadorAsiento ++

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addDebeFacPrv() CLASS EnlaceSage50

   ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                               // Asien       N   6    0
   ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():FacturasProveedores( ::nView ) )->dFecFac ), 8 )                                 // Fecha       D   8    0
   ::cBufferAsiento      += Padr( AllTrim( cPrvCta( ( D():FacturasProveedores( ::nView ) )->cCodPrv, D():Proveedores( ::nView ) ) ), 12 ) // SubCta      C  12    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // Contra      C  12    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // PtaDebe     N  16    2
   ::cBufferAsiento      += Padr( "N/Fcta. " + ::cNumeroFacturaProveedorFormato(), 25 )                                                   // Concepto    C  25    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // PtaHaber    N  16    2
   ::cBufferAsiento      += Right( Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ), 8 )                                            // Factura     N   8    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // BaseImpo    N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 5 )                                                                             // IVA         N   5    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 5 )                                                                             // Receqiv     N   5    2
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // Documento   C  10    0
   ::cBufferAsiento      += Padr( "", 3 )                                                                                                 // Departa     C   3    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Clave       C   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Estado      C   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // NCasado     N   6    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TCasado     N   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Trans       N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // Cambio      N  16    6
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // DebeMe      N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // HaberMe     N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Auxiliar    C   1    0
   ::cBufferAsiento      += Padr( ( D():FacturasProveedores( ::nView ) )->cSerFac, 1 )                                                    // Serie       C   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                                 // Sucursal    C   4    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // CodDivisa   C   5    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImpAuxMe    N  16    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // MonedaUso   C   1    0
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // EuroDebe    N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( ( D():FacturasProveedores( ::nView ) )->nTotFac ), 16 )                              // EuroHaber   N  16    2
   ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // BaseEuro    N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // NoConv      L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // NumeroInv   C  10    2
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Serie_RT    C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Factu_RT    N   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // BaseImp_RT  N  16    2
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // BaseImp_RF  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Rectifica   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_RT    D   8    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Nic         C   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Libre       L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Libre       N   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Linyerrump  L   1    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // SegActiv    C   6    0
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // SegGeog     C   6    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // IRect349    L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_OP    D   8    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_EX    D   8    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Departa5    C   5    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // Factura10   C  10    0
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Porcen_Ana  N   5    2
   ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Porcen_Seg  N   5    2
   ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // NumApunte   N   6    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // EuroTotal   N  16    2
   ::cBufferAsiento      += Padr( "", 100 )                                                                                               // RazonSoc    C 100    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // Apellido1   C  50    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // Apellido2   C  50    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoOpe     C   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // nFacTick    N   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NumAcuIni   C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NumAcuFin   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TerIdNif    N   1    0
   ::cBufferAsiento      += Padr( ( D():FacturasProveedores( ::nView ) )->cDniPrv, 15 )                                                   // TerNif      C  15    0
   ::cBufferAsiento      += Padr( ( D():FacturasProveedores( ::nView ) )->cNomPrv, 40 )                                                   // TerNom      C  40    0
   ::cBufferAsiento      += Padr( "", 9 )                                                                                                 // TerNif14    C   9    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // TBienTran   L   1    0
   ::cBufferAsiento      += Padr( "", 10 )                                                                                                // TBienCod    C  10    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // TransInm    L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Metal       L   1    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // MetalImp    N  16    2
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // Cliente     C  12    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // OpBienes    N   1    0
   ::cBufferAsiento      += Padr( ::cNumeroFacturaProveedorFormato(), 40 )                                                                // FacturaEx   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoFac     C   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoIva     C   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // GUID        C  40    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // L340        L   1    0
   ::cBufferAsiento      += Padr( "", 4 )                                                                                                 // MetalEje    N   4    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                                // Document15  C  15    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // ClienteSup  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaSub    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImporteSup  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // DocSup      C  40    0
   ::cBufferAsiento      += Padr( "", 12 )                                                                                                // ClientePro  C  12    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaPro    D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImportePro  N  16    2
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // DocPro      C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nClaveIRPF  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lArrend347  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // nSitInmueb  N   1    0
   ::cBufferAsiento      += Padr( "", 25 )                                                                                                // cRefCatast  C  25    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Concil347   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoRegula  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nCritCaja   N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lCritCaja   L   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // dMaxLiqui   D   8    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // nTotalFac   N  16    2
   ::cBufferAsiento      += Padr( "", 32 )                                                                                                // idFactura   C  32    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // nCobrPago   N  16    2
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nTipoIG     N   2    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // DevoIvaId   C  50    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // iDevoluIva  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // MedioCrit   C   1    0
   ::cBufferAsiento      += Padr( "", 34 )                                                                                                // CuentaCrit  C  34    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // IconAc      L   1    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // GuidSPAY    C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoEntr    N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // Mod140      N   2    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaAnota  D   8    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nTipo140    N   2    0
   ::cBufferAsiento      += Padr( "", 11 )                                                                                                // Cuenta140   C  11    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // Importe140  N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // LDepAduan   L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // LDifAduan   L   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nInter303   N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // idRecargo   C  40    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // EstadoSII   N   1    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave   N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoExenci  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoNoSuje  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoFact    N   2    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NacuIniSII  C  40    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NacuFinSII  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoRectif  N   2    0
   ::cBufferAsiento      += Padr( "", 16 )                                                                                                // bImpCoste   N  16    2
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lEmiTercer  L   1    0
   ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // nEntrPrest  N   1    0
   ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FecRegCon   D   8    0
   ::cBufferAsiento      += Padr( "", 40 )                                                                                                // FactuEx_RT  C  40    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave1  N   2    0
   ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave2  N   2    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // ItaI        L   1    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lExecl303   L   1    0
   ::cBufferAsiento      += Padr( "", 50 )                                                                                                // ConcepNew   C  50    0
   ::cBufferAsiento      += Padr( "", 30 )                                                                                                // TerNifNew   C  30    0
   ::cBufferAsiento      += Padr( "", 120 )                                                                                               // TerNomNew   C 120    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // SII_1415    L   1    0
   ::cBufferAsiento      += Padr( "", 15 )                                                                                                // cAutoriza   C  15    0
   ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lEmiTerDis  L   1    0
   ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                          // NifSuced    C   9    0
   //::cBufferAsiento      += Padr( "", 120 )                                                                                             // RazonSuced  C 120    0
   //::cBufferAsiento      += Padr( "F", 1 )                                                                                              // IfSimplifi  L   1    0
   //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                       // IfSinIdent  L   1    0

   if !empty( ::hFileDiario )
      fWrite( ::hFileDiario, ::cBufferAsiento )
   end if

   ::cBufferAsiento   := ""

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addHaberFacPrv() CLASS EnlaceSage50

   local hCtaIng

   for each hCtaIng in ::aSubCtaIngresos

      ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                            // Asien       N   6    0
      ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():FacturasProveedores( ::nView ) )->dFecFac ), 8 )                              // Fecha       D   8    0
      ::cBufferAsiento      += Padr( AllTrim( hGet( hCtaIng, "cuenta" ) ), 12 )                                                           // SubCta      C  12    0
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // Contra      C  12    0
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // PtaDebe     N  16    2
      ::cBufferAsiento      += Padr( "N/Fcta. " + ::cNumeroFacturaProveedorFormato(), 25 )                                                // Concepto    C  25    0
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // PtaHaber    N  16    2
      ::cBufferAsiento      += Right( Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ), 8 )                                         // Factura     N   8    0
      ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 16 )                                                                         // BaseImpo    N  16    2
      ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 5 )                                                                          // IVA         N   5    2
      ::cBufferAsiento      += Padr( ::cFormatoImporte( 0 ), 5 )                                                                          // Receqiv     N   5    2
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // Documento   C  10    0
      ::cBufferAsiento      += Padr( "", 3 )                                                                                              // Departa     C   3    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Clave       C   6    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Estado      C   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // NCasado     N   6    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TCasado     N   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Trans       N   6    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // Cambio      N  16    6
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // DebeMe      N  16    2
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // HaberMe     N  16    2
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Auxiliar    C   1    0
      ::cBufferAsiento      += Pad( ( D():FacturasProveedores( ::nView ) )->cSerFac, 1 )                                                  // Serie       C   1    0
      ::cBufferAsiento      += Padr( "", 4 )                                                                                              // Sucursal    C   4    0
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // CodDivisa   C   5    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImpAuxMe    N  16    2
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // MonedaUso   C   1    0
      ::cBufferAsiento      += Padl( ::cFormatoImporte( hGet( hCtaIng, "importe" ) ), 16 )                                                // EuroDebe    N  16    2
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // EuroHaber   N  16    2
      ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                         // BaseEuro    N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // NoConv      L   1    0
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // NumeroInv   C  10    2
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Serie_RT    C   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Factu_RT    N   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // BaseImp_RT  N  16    2
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // BaseImp_RF  N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Rectifica   L   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_RT    D   8    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Nic         C   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Libre       L   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // Libre       N   6    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Linyerrump  L   1    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // SegActiv    C   6    0
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // SegGeog     C   6    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // IRect349    L   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_OP    D   8    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // Fecha_EX    D   8    0
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Departa5    C   5    0
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // Factura10   C  10    0
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Porcen_Ana  N   5    2
      ::cBufferAsiento      += Padr( "", 5 )                                                                                              // Porcen_Seg  N   5    2
      ::cBufferAsiento      += Padr( "", 6 )                                                                                              // NumApunte   N   6    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // EuroTotal   N  16    2
      ::cBufferAsiento      += Padr( "", 100 )                                                                                            // RazonSoc    C 100    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // Apellido1   C  50    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // Apellido2   C  50    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoOpe     C   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // nFacTick    N   8    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NumAcuIni   C  40    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NumAcuFin   C  40    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TerIdNif    N   1    0
      ::cBufferAsiento      += Padr( ( D():FacturasProveedores( ::nView ) )->cDniPrv, 15 )                                                // TerNif      C  15    0
      ::cBufferAsiento      += Padr( ( D():FacturasProveedores( ::nView ) )->cNomPrv, 40 )                                                // TerNom      C  40    0
      ::cBufferAsiento      += Padr( "", 9 )                                                                                              // TerNif14    C   9    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // TBienTran   L   1    0
      ::cBufferAsiento      += Padr( "", 10 )                                                                                             // TBienCod    C  10    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // TransInm    L   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // Metal       L   1    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // MetalImp    N  16    2
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // Cliente     C  12    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // OpBienes    N   1    0
      ::cBufferAsiento      += Padr( ::cNumeroFacturaProveedorFormato(), 40 )                                                             // FacturaEx   C  40    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoFac     C   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // TipoIva     C   1    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // GUID        C  40    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // L340        L   1    0
      ::cBufferAsiento      += Padr( "", 4 )                                                                                              // MetalEje    N   4    0
      ::cBufferAsiento      += Padr( "", 15 )                                                                                             // Document15  C  15    0
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // ClienteSup  C  12    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaSub    D   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImporteSup  N  16    2
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // DocSup      C  40    0
      ::cBufferAsiento      += Padr( "", 12 )                                                                                             // ClientePro  C  12    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaPro    D   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // ImportePro  N  16    2
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // DocPro      C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nClaveIRPF  N   2    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lArrend347  L   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // nSitInmueb  N   1    0
      ::cBufferAsiento      += Padr( "", 25 )                                                                                             // cRefCatast  C  25    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // Concil347   N   1    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoRegula  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nCritCaja   N   2    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lCritCaja   L   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // dMaxLiqui   D   8    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // nTotalFac   N  16    2
      ::cBufferAsiento      += Padr( "", 32 )                                                                                             // idFactura   C  32    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // nCobrPago   N  16    2
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nTipoIG     N   2    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // DevoIvaId   C  50    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // iDevoluIva  L   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // MedioCrit   C   1    0
      ::cBufferAsiento      += Padr( "", 34 )                                                                                             // CuentaCrit  C  34    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // IconAc      L   1    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // GuidSPAY    C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoEntr    N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // Mod140      N   2    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FechaAnota  D   8    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nTipo140    N   2    0
      ::cBufferAsiento      += Padr( "", 11 )                                                                                             // Cuenta140   C  11    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // Importe140  N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // LDepAduan   L   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // LDifAduan   L   1    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // nInter303   N   2    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // idRecargo   C  40    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // EstadoSII   N   1    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave   N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoExenci  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoNoSuje  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoFact    N   2    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NacuIniSII  C  40    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // NacuFinSII  C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoRectif  N   2    0
      ::cBufferAsiento      += Padr( "", 16 )                                                                                             // bImpCoste   N  16    2
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lEmiTercer  L   1    0
      ::cBufferAsiento      += Padr( "", 1 )                                                                                              // nEntrPrest  N   1    0
      ::cBufferAsiento      += Padr( "", 8 )                                                                                              // FecRegCon   D   8    0
      ::cBufferAsiento      += Padr( "", 40 )                                                                                             // FactuEx_RT  C  40    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave1  N   2    0
      ::cBufferAsiento      += Padr( "", 2 )                                                                                              // TipoClave2  N   2    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // ItaI        L   1    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lExecl303   L   1    0
      ::cBufferAsiento      += Padr( "", 50 )                                                                                             // ConcepNew   C  50    0
      ::cBufferAsiento      += Padr( "", 30 )                                                                                             // TerNifNew   C  30    0
      ::cBufferAsiento      += Padr( "", 120 )                                                                                            // TerNomNew   C 120    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // SII_1415    L   1    0
      ::cBufferAsiento      += Padr( "", 15 )                                                                                             // cAutoriza   C  15    0
      ::cBufferAsiento      += Padr( "F", 1 )                                                                                             // lEmiTerDis  L   1    0
      ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                       // NifSuced    C   9    0
      //::cBufferAsiento      += Padr( "", 120 )                                                                                          // RazonSuced  C 120    0
      //::cBufferAsiento      += Padr( "F", 1 )                                                                                           // IfSimplifi  L   1    0
      //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                    // IfSinIdent  L   1    0

      if !empty( ::hFileDiario )
         fWrite( ::hFileDiario, ::cBufferAsiento )
      end if

      ::cBufferAsiento   := ""

   next

Return ( nil )

//---------------------------------------------------------------------------//

METHOD addIvaFacPrv() CLASS EnlaceSage50

   local aIva

   for each aIva in ::aTotalesIva

      if aIva[3] != nil

         ::cBufferAsiento      += Padl( AllTrim( Str( ::nContadorAsiento ) ), 6 )                                                               // Asien       N   6    0
         ::cBufferAsiento      += Padr( ::cFormatoFecha( ( D():FacturasProveedores( ::nView ) )->dFecFac ), 8 )                                 // Fecha       D   8    0
         ::cBufferAsiento      += Padr( ::getSubCuentaIvaCompras( aIva[3] ), 12 )                                                               // SubCta      C  12    0
         ::cBufferAsiento      += Padr( AllTrim( cPrvCta( ( D():FacturasProveedores( ::nView ) )->cCodPrv, D():Proveedores( ::nView ) ) ), 12 ) // Contra      C  12    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // PtaDebe     N  16    2
         ::cBufferAsiento      += Padr( "N/Fcta." + ::cNumeroFacturaProveedorFormato(), 25 )                                                    // Concepto    C  25    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // PtaHaber    N  16    2
         ::cBufferAsiento      += Right( Str( ( D():FacturasProveedores( ::nView ) )->nNumFac ), 8 )                                            // Factura     N   8    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // BaseImpo    N  16    2
         ::cBufferAsiento      += Padl( ::cFormatoPorcentaje( aIva[3] ), 5 )                                                                    // IVA         N   5    2
         ::cBufferAsiento      += Padl( ::cFormatoPorcentaje( 0 ), 5 )                                                                          // Receqiv     N   5    2
         ::cBufferAsiento      += Padr( "", 10 )                                                                                                // Documento   C  10    0
         ::cBufferAsiento      += Padr( "", 3 )                                                                                                 // Departa     C   3    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Clave       C   6    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Estado      C   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // NCasado     N   6    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TCasado     N   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Trans       N   6    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // Cambio      N  16    6
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // DebeMe      N  16    2
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // HaberMe     N  16    2
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Auxiliar    C   1    0
         ::cBufferAsiento      += Padr( ( D():FacturasProveedores( ::nView ) )->cSerFac, 1 )                                                    // Serie       C   1    0
         ::cBufferAsiento      += Padr( "", 4 )                                                                                                 // Sucursal    C   4    0
         ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // CodDivisa   C   5    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImpAuxMe    N  16    2
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // MonedaUso   C   1    0
         ::cBufferAsiento      += Padl( ::cFormatoImporte( aIva[ 8 ] ), 16 )                                                                    // EuroDebe    N  16    2
         ::cBufferAsiento      += Padl( ::cFormatoImporte( 0 ), 16 )                                                                            // EuroHaber   N  16    2
         ::cBufferAsiento      += Padl( ::cFormatoImporte( aIva[2] ), 16 )                                                                      // BaseEuro    N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // NoConv      L   1    0
         ::cBufferAsiento      += Padr( "", 10 )                                                                                                // NumeroInv   C  10    2
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Serie_RT    C   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Factu_RT    N   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // BaseImp_RT  N  16    2
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // BaseImp_RF  N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Rectifica   L   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_RT    D   8    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Nic         C   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Libre       L   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // Libre       N   6    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Linyerrump  L   1    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // SegActiv    C   6    0
         ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // SegGeog     C   6    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // IRect349    L   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_OP    D   8    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // Fecha_EX    D   8    0
         ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Departa5    C   5    0
         ::cBufferAsiento      += Padr( "", 10 )                                                                                                // Factura10   C  10    0
         ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Porcen_Ana  N   5    2
         ::cBufferAsiento      += Padr( "", 5 )                                                                                                 // Porcen_Seg  N   5    2
         ::cBufferAsiento      += Padr( "", 6 )                                                                                                 // NumApunte   N   6    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // EuroTotal   N  16    2
         ::cBufferAsiento      += Padr( "", 100 )                                                                                               // RazonSoc    C 100    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                                // Apellido1   C  50    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                                // Apellido2   C  50    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoOpe     C   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // nFacTick    N   8    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NumAcuIni   C  40    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NumAcuFin   C  40    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TerIdNif    N   1    0
         ::cBufferAsiento      += Padr( ( D():FacturasProveedores( ::nView ) )->cDniPrv, 15 )                                                   // TerNif      C  15    0
         ::cBufferAsiento      += Padr( ( D():FacturasProveedores( ::nView ) )->cNomPrv, 40 )                                                   // TerNom      C  40    0
         ::cBufferAsiento      += Padr( "", 9 )                                                                                                 // TerNif14    C   9    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // TBienTran   L   1    0
         ::cBufferAsiento      += Padr( "", 10 )                                                                                                // TBienCod    C  10    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // TransInm    L   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // Metal       L   1    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // MetalImp    N  16    2
         ::cBufferAsiento      += Padr( "", 12 )                                                                                                // Cliente     C  12    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // OpBienes    N   1    0
         ::cBufferAsiento      += Padr( ::cNumeroFacturaProveedorFormato(), 40 )                                                                // FacturaEx   C  40    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoFac     C   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // TipoIva     C   1    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                                // GUID        C  40    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // L340        L   1    0
         ::cBufferAsiento      += Padr( "", 4 )                                                                                                 // MetalEje    N   4    0
         ::cBufferAsiento      += Padr( "", 15 )                                                                                                // Document15  C  15    0
         ::cBufferAsiento      += Padr( "", 12 )                                                                                                // ClienteSup  C  12    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaSub    D   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImporteSup  N  16    2
         ::cBufferAsiento      += Padr( "", 40 )                                                                                                // DocSup      C  40    0
         ::cBufferAsiento      += Padr( "", 12 )                                                                                                // ClientePro  C  12    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaPro    D   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // ImportePro  N  16    2
         ::cBufferAsiento      += Padr( "", 40 )                                                                                                // DocPro      C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nClaveIRPF  N   2    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lArrend347  L   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // nSitInmueb  N   1    0
         ::cBufferAsiento      += Padr( "", 25 )                                                                                                // cRefCatast  C  25    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // Concil347   N   1    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoRegula  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nCritCaja   N   2    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lCritCaja   L   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // dMaxLiqui   D   8    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // nTotalFac   N  16    2
         ::cBufferAsiento      += Padr( "", 32 )                                                                                                // idFactura   C  32    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // nCobrPago   N  16    2
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nTipoIG     N   2    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                                // DevoIvaId   C  50    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // iDevoluIva  L   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // MedioCrit   C   1    0
         ::cBufferAsiento      += Padr( "", 34 )                                                                                                // CuentaCrit  C  34    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // IconAc      L   1    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                                // GuidSPAY    C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoEntr    N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // Mod140      N   2    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FechaAnota  D   8    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nTipo140    N   2    0
         ::cBufferAsiento      += Padr( "", 11 )                                                                                                // Cuenta140   C  11    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // Importe140  N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // LDepAduan   L   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // LDifAduan   L   1    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // nInter303   N   2    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                                // idRecargo   C  40    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // EstadoSII   N   1    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave   N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoExenci  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoNoSuje  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoFact    N   2    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NacuIniSII  C  40    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                                // NacuFinSII  C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoRectif  N   2    0
         ::cBufferAsiento      += Padr( "", 16 )                                                                                                // bImpCoste   N  16    2
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lEmiTercer  L   1    0
         ::cBufferAsiento      += Padr( "", 1 )                                                                                                 // nEntrPrest  N   1    0
         ::cBufferAsiento      += Padr( "", 8 )                                                                                                 // FecRegCon   D   8    0
         ::cBufferAsiento      += Padr( "", 40 )                                                                                                // FactuEx_RT  C  40    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave1  N   2    0
         ::cBufferAsiento      += Padr( "", 2 )                                                                                                 // TipoClave2  N   2    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // ItaI        L   1    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lExecl303   L   1    0
         ::cBufferAsiento      += Padr( "", 50 )                                                                                                // ConcepNew   C  50    0
         ::cBufferAsiento      += Padr( "", 30 )                                                                                                // TerNifNew   C  30    0
         ::cBufferAsiento      += Padr( "", 120 )                                                                                               // TerNomNew   C 120    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // SII_1415    L   1    0
         ::cBufferAsiento      += Padr( "", 15 )                                                                                                // cAutoriza   C  15    0
         ::cBufferAsiento      += Padr( "F", 1 )                                                                                                // lEmiTerDis  L   1    0
         ::cBufferAsiento      += Padr( "", 9 ) + CRLF                                                                                          // NifSuced    C   9    0
         //::cBufferAsiento      += Padr( "", 120 )                                                                                             // RazonSuced  C 120    0
         //::cBufferAsiento      += Padr( "F", 1 )                                                                                              // IfSimplifi  L   1    0
         //::cBufferAsiento      += Padr( "F", 1 ) + CRLF                                                                                       // IfSinIdent  L   1    0

         if !empty( ::hFileDiario )
            fWrite( ::hFileDiario, ::cBufferAsiento )
         end if

         ::cBufferAsiento   := ""

      end if

   next

Return ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//