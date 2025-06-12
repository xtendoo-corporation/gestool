#include "FiveWin.ch"  
#include "Factu.ch" 
#include "Report.ch"
#include "FastRepH.ch"
#include "MesDbf.ch"

memvar dFechaInicio
memvar dFechaFin
memvar cGrupoArticuloDesde
memvar cGrupoArticuloHasta

//---------------------------------------------------------------------------//

CLASS TFastReportGeneral FROM TFastReportInfGen 

   DATA  cType                            INIT "Generales"

   DATA  cJson
   DATA  aJson

   DATA  aFlds
   DATA  cSql 
   DATA  cGroup
   DATA  cOrder

   METHOD lResource( cFld )

   METHOD Play( uParam )
   METHOD DesignReport( cNombre )
   METHOD GenReport( nOption )

   METHOD Create()
   METHOD loadJson()

   METHOD OpenFiles()
   METHOD CloseFiles()

   METHOD DataReport()

   Method AddVariable()

   METHOD StartDialog()

   METHOD BuildTree()
   METHOD BuildReportCorrespondences()

   METHOD ExecSql()
      METHOD prepareSentenceSql()
      METHOD execMacro()
      METHOD addGroup()
      METHOD addOrder()

   METHOD lCompruebaArticulo()

END CLASS

//----------------------------------------------------------------------------//

METHOD lResource( cFld ) CLASS TFastReportGeneral

   ::lNewInforme     := .t.
   ::lDefCondiciones := .f.

   ::cSubTitle       := "Informes generales"

   ::cTipoInforme    := "Generales"
   ::cBmpInforme     := "gc_cabinet_open_64"

   if !::lTabletVersion .and. !::NewResource()
      return .f.
   end if

   /*
   Carga controles-------------------------------------------------------------
   */

   if !::lGrupoArticulo( .t. )
      return .f.
   end if

   if !::lGrupoSufijo( .t. )
      return .f.
   end if

RETURN .t.

//---------------------------------------------------------------------------//

METHOD OpenFiles() CLASS TFastReportGeneral

   local lOpen          := .t.
   local oError
   local oBlock   

   oBlock               := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      ::cDriver         := cDriver()

      ::nView           := D():CreateView( ::cDriver )

   RECOVER USING oError

      msgStop( ErrorMessage( oError ), "Imposible abrir las bases de datos de artículos" )

      ::CloseFiles()

      lOpen       := .f.

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN ( lOpen )

//---------------------------------------------------------------------------//

METHOD CloseFiles() CLASS TFastReportGeneral

   local oBlock   

   oBlock         := ErrorBlock( {| oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      if !Empty( ::nView )
         D():DeleteView( ::nView )
      end if

      ::nView     := nil

   RECOVER

      msgStop( "Imposible cerrar todas las bases de datos" )

   END SEQUENCE

   ErrorBlock( oBlock )

RETURN .t.

//---------------------------------------------------------------------------//

METHOD Play() CLASS TFastReportGeneral

   if ::lOpenFiles

      if ::lResource()
         ::Activate()
      end if

   end if

   ::End()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD Create() CLASS TFastReportGeneral

   local h

   if !::loadJson()
      Return .f.
   end if   

   if hb_isnil( ::oDbf )
      ::oDbf                  := TDbf():New( ::cFileName, "InfMov", ( cLocalDriver() ), , ( cPatTmp() ) )
   end if

   for each h in ::aFlds
      ::AddField( hGet( h, "name" ),hGet( h, "type" ), hGet( h, "size" ), hGet( h, "decimal" ), {|| hGet( h, "picture" ) }, hGet( h, "description" ) )
   next

RETURN ( .t. )

//---------------------------------------------------------------------------//

Method loadJson() CLASS TFastReportGeneral

   local uSql

   ::cSql         := ""
   ::cGroup       := ""
   ::cOrder       := ""

   ::cReportJson  := ::cReportDirectory + "\" + ::cReportName + ".json"

   if !file( ::cReportJson )
      Return .f.
   end if

   ::cJson                      := memoread( ::cReportJson )

   if Empty( ::cJson )
      Return .f.
   end if   

   hb_jsondecode( ::cJson, @::aJson )

   ::aFlds     := hGet( ::aJson, "fields" )
   uSql        := hGet( ::aJson, "sql" )
   ::cGroup    := hGet( ::aJson, "group" )
   ::cOrder    := hGet( ::aJson, "order" )

   if hb_isArray( uSql )
      aEval( uSql, {|c| ::cSql += c } )
   else
      ::cSql      := uSql
   end if

   if !hb_ishash( ::aFlds ) .or. len( ::aFlds ) == 0
      MsgInfo( "Errores en la configuración de campos del Json" )
      Return .f.
   end if

   if Empty( ::cSql )
      MsgInfo( "Errores en la configuración de SQL del Json" )
      Return .f.
   end if

RETURN ( .t. )

//---------------------------------------------------------------------------//

Method DesignReport( cNombre ) CLASS TFastReportGeneral

   if !::lInformesPersonalizados
      MsgStop( "No se puede diseñar un informe básico" )
      Return ( self )
   end if

   /*
   Obtenemos los datos necesarios para el informe------------------------------
   */

   if !::lLoadInfo()
      msgStop( "No se ha podido cargar el informe." )
      Return ( Self )
   end if

   /*
   Obtenemos el informe personalizado------------------------------------------
   */

   if !::lLoadReport()
      MsgStop( "No se ha podido cargar un diseño de informe valido." + CRLF + ::cReportFile )
      Return ( Self )
   end if 

   if !Empty( cNombre )
      ::lPersonalizado  := .t.
      ::cReportName     := cNombre
   end if

   if !::create()
      MsgStop( "No de ha podido cargar el json con la configuración del informe." )
      Return ( self )
   end if

   if ::OpenTemporal()

      /*
      Creacion del objeto---------------------------------------------------------
      */

      ::oFastReport                    := frReportManager():new()

      ::oFastReport:LoadLangRes(       "Spanish.Xml" )
      ::oFastReport:SetIcon( 1 )

      ::oFastReport:SetEventHandler(   "Designer", "OnSaveReport", {|lSaveAs| ::SaveReport( lSaveAs ) } )

      ::oFastReport:ClearDataSets()

      ::DataReport()

      if !Empty( ::cInformeFastReport )

         ::oFastReport:LoadFromString( ::cInformeFastReport )

      else

         ::oFastReport:AddPage(        "MainPage" )

         ::oFastReport:AddBand(        "CabeceraDocumento", "MainPage", frxPageHeader )
         ::oFastReport:SetProperty(    "CabeceraDocumento", "Top", 0 )
         ::oFastReport:SetProperty(    "CabeceraDocumento", "Height", 200 )

         ::oFastReport:AddBand(        "MasterData",  "MainPage", frxMasterData )
         ::oFastReport:SetProperty(    "MasterData",  "Top", 200 )
         ::oFastReport:SetProperty(    "MasterData",  "Height", 100 )
         ::oFastReport:SetProperty(    "MasterData",  "StartNewPage", .t. )
         ::oFastReport:SetObjProperty( "MasterData",  "DataSet", "Informe" )

         ::oFastReport:AddBand(        "DetalleColumnas",   "MainPage", frxDetailData  )
         ::oFastReport:SetProperty(    "DetalleColumnas",   "Top", 230 )
         ::oFastReport:SetProperty(    "DetalleColumnas",   "Height", 28 )
         ::oFastReport:SetObjProperty( "DetalleColumnas",   "DataSet", "Informe" )

      end if

      ::AddVariable()

      ::oFastReport:SetTitle(                "Diseñando : " + ::cReportType )
      ::oFastReport:ReportOptions:SetName(   "Diseñando : " + ::cReportType )

      ::oFastReport:PreviewOptions:SetMaximized( .t. )

      ::oFastReport:SetTabTreeExpanded( FR_tvAll, .f. )

      ::oFastReport:DesignReport()

      if !Empty( ::oFastReport )
         ::oFastReport:DestroyFR()
      end if

      if !Empty( cNombre )
         ::LoadPersonalizado()
      end if

      ::CloseTemporal()

   end if 

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD GenReport( nOption ) CLASS TFastReportGeneral

   local oDlg

   /*
   Obtenemos los datos necesarios para el informe------------------------------
   */

   if !::lLoadInfo()
      msgStop( "No se ha podido cargar el nombre del informe." )
      Return ( Self )
   end if

   /*
   Obtenemos el informe -------------------------------------------------------
   */

   if !::lLoadReport()
      MsgStop( "No se ha podido cargar un diseño de informe valido." + CRLF + ::cReportFile )
      Return ( Self )
   end if

   if !::create()
      MsgStop( "No de ha podido cargar el json con la configuración del informe." )
      Return ( self )
   end if

   if ::OpenTemporal() 

      /*
      Ponemos el dialogo a disable------------------------------------------------
      */

      ::SetDialog( .f. )

      ::lBreak             := .f.
      ::oBtnCancel:bAction := {|| ::lBreak := .t. }

      /*
      Extraer el orden------------------------------------------------------------
      */

      ::ExtractOrder()

      /*
      Comienza la generacion del informe------------------------------------------
      */

      if hb_isBlock( ::bPreGenerate )
         Eval( ::bPreGenerate )
      end if

      if ::lGenerate()

         if !::lBreak

            DEFINE DIALOG  oDlg ;
                  FROM     0, 0 ;
                  TO       4, 30 ;
                  TITLE    "Generando informe" ;
                  STYLE    DS_MODALFRAME

            oDlg:bStart    := { || ::FastReport( nOption ), oDlg:End(), SysRefresh() }
            oDlg:cMsg      := "Por favor espere..."

            ACTIVATE DIALOG oDlg ;
               CENTER ;
               ON PAINT oDlg:Say( 11, 0, xPadC( oDlg:cMsg, ( oDlg:nRight - oDlg:nLeft ) ), , , , .t. )

         end if

      else

         if !::lBreak
            msgStop( "No hay registros en las condiciones solictadas" )
         end if

      end if

      if hb_isBlock( ::bPostGenerate )
         Eval( ::bPostGenerate )
      end if

      ::oMtrInf:cText         := ""
      ::oMtrInf:Set( 0 )

      ::oBtnCancel:bAction    := {|| ::lBreak := .t., ::End() }

      ::SetDialog( .t. )

      ::CloseTemporal()

   end if

RETURN ( Self )

//----------------------------------------------------------------------------//

Method AddVariable() CLASS TFastReportGeneral

   public dFechaInicio                 := Dtos( ::dIniInf )
   public dFechaFin                    := Dtos( ::dFinInf )

   ::oFastReport:AddVariable(          "Informe",  "Desde fecha",                   "GetHbVar('dFechaInicio')" )
   ::oFastReport:AddVariable(          "Informe",  "Hasta fecha",                   "GetHbVar('dFechaFin')" )

   if !Empty( ::oGrupoArticulo )
      public cGrupoArticuloDesde       := ::oGrupoArticulo:Cargo:Desde
      public cGrupoArticuloHasta       := ::oGrupoArticulo:Cargo:Hasta

      ::oFastReport:AddVariable(       "Informe", "Desde código de artículo",       "GetHbVar('cGrupoArticuloDesde')" )
      ::oFastReport:AddVariable(       "Informe", "Hasta código de artículo",       "GetHbVar('cGrupoArticuloHasta')" )
   end if

RETURN ( Self )

//----------------------------------------------------------------------------//   

METHOD BuildReportCorrespondences() CLASS TFastReportGeneral
   
   ::hReport   := {  "Generales" => ;
                        {  "Generate" =>  {|| ::ExecSql() },;
                           "Variable" =>  {|| nil },;
                           "Data" =>      {|| nil } } }

Return ( Self )

//---------------------------------------------------------------------------//

METHOD BuildTree( oTree, lLoadFile ) CLASS TFastReportGeneral

   local aReports

   DEFAULT oTree           := ::oTreeReporting
   DEFAULT lLoadFile       := .t. 

   aReports    := {  {  "Title"     => "Generales",;  
                        "Image"     => 22,;
                        "Type"      => "Generales",;
                        "Directory" => "Generales",;
                        "File"      => "Generales.fr3"  } }

   ::BuildNode( aReports, oTree, lLoadFile )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD DataReport() CLASS TFastReportGeneral

   ::oFastReport:ClearDataSets()

   ::oFastReport:SetWorkArea(       "Informe",                    ::oDbf:nArea )
   ::oFastReport:SetFieldAliases(   "Informe",                    cObjectsToReport( ::oDbf ) )

   ::SetDataReport()

Return ( Self )

//---------------------------------------------------------------------------//

METHOD StartDialog() CLASS TFastReportGeneral

   ::CreateTreeImageList()

   ::BuildTree()

   ::BuildReportCorrespondences()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ExecSql() CLASS TFastReportGeneral

   if Empty( ::cSql )
      Return ( Self )
   end if

   ::prepareSentenceSql()

   ADSBaseModel():ExecuteSqlStatement( ::cSql, @::oDbf:cAlias )

   if ::lCompruebaArticulo()

      ( ::oDbf:cAlias )->( dbSetFilter( {|| ( Field->cCodArt >= ::oGrupoArticulo:Cargo:getDesde() .and. Field->cCodArt <= ::oGrupoArticulo:Cargo:getHasta() ) .and. ( Field->cDelega >= ::oGrupoSufijo:Cargo:getDesde() .and. Field->cDelega <= ::oGrupoSufijo:Cargo:getHasta() ) },;
                                          "( cCodArt >= " + ::oGrupoArticulo:Cargo:getDesde() + " .and. cCodArt <= " + ::oGrupoArticulo:Cargo:getHasta() + ") .and. ( cDelega >= " + ::oGrupoSufijo:Cargo:getDesde() + " .and. cDelega <= " + ::oGrupoSufijo:Cargo:getHasta() + " )" ) )

   else

      ( ::oDbf:cAlias )->( dbSetFilter( {|| Field->cDelega >= ::oGrupoSufijo:Cargo:getDesde() .and. Field->cDelega <= ::oGrupoSufijo:Cargo:getHasta() },;
                                          "cDelega >= " + ::oGrupoSufijo:Cargo:getDesde() + " .and. cDelega <= " + ::oGrupoSufijo:Cargo:getHasta() ) )

   end if

   ::oDbf:GoTop()

RETURN ( Self )


//---------------------------------------------------------------------------//

METHOD prepareSentenceSql() CLASS TFastReportGeneral

   ::execMacro()
   ::addGroup()
   ::addOrder()

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD execMacro() CLASS TFastReportGeneral

   /*
   Cambiamos la empresa-------------------------------------------------------
   */

   ::cSql   := StrTran( ::cSql, "{{empresa}}", AllTrim( cPatEmp() ) )

   /*
   Cambiamos la datos----------------------------------------------------------
   */

   ::cSql   := StrTran( ::cSql, "{{datos}}", AllTrim( cPatDat() ) )

   /*
   Cambiamos la fecha inicio---------------------------------------------------
   */

   ::cSql   := StrTran( ::cSql, "{{dIniInf}}", quoted( dToc( ::dIniInf ) ) )

   /*
   Cambiamos la fecha fin------------------------------------------------------
   */

   ::cSql   := StrTran( ::cSql, "{{dFinInf}}", quoted( dToc( ::dFinInf ) ) )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addGroup() CLASS TFastReportGeneral

   if Empty( ::cGroup )
      Return ( self )
   end if

   ::cSql   += " GROUP BY "
   ::cSql   += AllTrim( ::cGroup )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD addOrder() CLASS TFastReportGeneral

   if Empty( ::cOrder )
      Return ( self )
   end if

   ::cSql   += " ORDER BY "
   ::cSql   += AllTrim( ::cOrder )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD lCompruebaArticulo()

   local h
   local lExist   := .f.

    for each h in ::aFlds

      if hGet( h, "name" ) == "cCodArt"
         lExist := .t.
      end if

   next

RETURN ( lExist )

//---------------------------------------------------------------------------//