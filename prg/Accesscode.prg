#include "FiveWin.ch"
#include "Factu.ch" 
#include "Empresa.ch"
#include "HbXml.ch"
#include "Xbrowse.ch"

//---------------------------------------------------------------------------//
//
// Controla los accesos al programa
//

CLASS AccessCode

   CLASSDATA   cAgente           INIT space( 3 )
   CLASSDATA   cRuta             INIT space( 4 )
   CLASSDATA   lFilterByAgent    INIT .f.
   CLASSDATA   lInvoiceModify    INIT .t.
   CLASSDATA   lUnitsModify      INIT .t.
   CLASSDATA   lSalesView        INIT .t.
   CLASSDATA   lAddLote          INIT .f.
   
   DATA  cGetUser                INIT  Space( 100 )

   DATA  cGetPassword            INIT  Space( 10 )

   DATA  cIniFile                INIT  cIniAplication()

   METHOD loadTableConfiguration()

   METHOD getLogicValueFromIni( cTag, cField, lDefaultValue );
                                 INLINE ( lower( getPvProfString( cTag, cField, lDefaultValue, ::cIniFile ) ) == ".t." ) 

END CLASS

//---------------------------------------------------------------------------//

METHOD loadTableConfiguration() CLASS AccessCode

   local cTag
   local lGetUser    := .f.
   local oUserPresenter

   sysRefresh()

   cTag              := "Tablet"

   if ( "TABLET:" $ appParamsMain() )
      cTag           += right( appParamsMain(), 1 )
   end if 

   ::cGetUser        := getPvProfString( cTag, "User",               "",      ::cIniFile )
   ::cGetPassword    := getPvProfString( cTag, "Password",           "",      ::cIniFile )
   ::cAgente         := getPvProfString( cTag, "Agente",             "",      ::cIniFile )
   ::cRuta           := getPvProfString( cTag, "Ruta",               "",      ::cIniFile )

   ::lInvoiceModify  := ::getLogicValueFromIni( cTag, "ModificarFactura",  ".t." )
   ::lUnitsModify    := ::getLogicValueFromIni( cTag, "ModificarUnidades", ".t." )
   ::lFilterByAgent  := ::getLogicValueFromIni( cTag, "FiltrarAgente",     ".f." )
   ::lSalesView      := ::getLogicValueFromIni( cTag, "VisualizarVentas",  ".t." )
   ::lAddLote        := ::getLogicValueFromIni( cTag, "AddLote",           ".f." )

   if empty( ::cGetUser )
      
      oUserPresenter := UserPresenter():New()
      
      oUserPresenter:Play()

      if !Empty( oUserPresenter:cSelectUser )

         ::cGetUser := AllTrim( oUserPresenter:cSelectUser )

         lGetUser    := .t.

      end if

   end if 

   if empty( ::cGetUser )
      Return .f.
   end if

   Auth():guardWhereCodigo( ::cGetUser )

   if lGetUser
      ::cAgente   := UsuariosModel():getUsuarioAgenteExclusivo( Auth():uuid )
      ::cRuta     := UsuariosModel():getUsuarioRutaExclusivo( Auth():uuid )
   end if

RETURN ( .t. )

//--------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//