#include "FiveWin.Ch"
#include "Factu.ch" 
#include "MesDbf.ch"

//----------------------------------------------------------------------------//

CLASS TAuditoria FROM TMant

   DATA oDialog
   DATA oOfficeBar

   DATA aInforme

   DATA uuidDoc
   DATA cTipDoc

   DATA cNumeroDocumento
   DATA cTerceroDocumento
   DATA cFechaHoraDocumento

   DATA oBrwInforme

   DATA aTemporal

   METHOD Create( cPath )                       CONSTRUCTOR

   METHOD New( cPath, oWndParent, oMenuItem )   CONSTRUCTOR

   METHOD DefineFiles()

   METHOD InformeAuditoria( uuid, cTipDoc )
   
   METHOD cNumeroFromDocument()
   METHOD cTerceroFromDocument()
   METHOD cFechaHoraFromDocumento()

   METHOD lResource()
      METHOD StartResource()

   METHOD initTemporal()
   METHOD AddTemporal( hHash )
   METHOD SaveTemporal()

END CLASS

//----------------------------------------------------------------------------//

METHOD Create( cPath ) CLASS TAuditoria

   DEFAULT cPath     := cPatEmp()

   ::cPath           := cPath
   ::oDbf            := nil

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD New( cPath, oWndParent, oMenuItem ) CLASS TAuditoria

   DEFAULT cPath        := cPatEmp()
   DEFAULT oWndParent   := GetWndFrame()

   if oMenuItem != nil
      ::nLevel          := Auth():Level( oMenuItem )
   else
      ::nLevel          := Auth():Level( "auditoria" )
   end if

   ::cPath              := cPath
   ::oWndParent         := oWndParent

   ::oDbf               := nil

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD DefineFiles( cPath, cDriver ) CLASS TAuditoria

   DEFAULT cPath        := ::cPath
   DEFAULT cDriver      := cDriver()

   DEFINE DATABASE ::oDbf FILE "auditor.dbf" CLASS "auditor" ALIAS "auditor" PATH ( cPath ) VIA ( cDriver ) COMMENT "Auditoria"

      FIELD NAME "uuid"                TYPE "C" LEN  40  DEC 0 COMMENT "uuid"                                        OF ::oDbf
      FIELD NAME "cUuidDoc"            TYPE "C" LEN  40  DEC 0 COMMENT "Identificador documento"                     OF ::oDbf
      FIELD NAME "dFecha"              TYPE "D" LEN   8  DEC 0 COMMENT "Fecha"                                       OF ::oDbf
      FIELD NAME "cHora"               TYPE "C" LEN  10  DEC 0 COMMENT "Hora"                                        OF ::oDbf
      FIELD NAME "cUsuario"            TYPE "C" LEN   3  DEC 0 COMMENT "Usuario"                                     OF ::oDbf
      FIELD NAME "cDescrip"            TYPE "C" LEN 200  DEC 0 COMMENT "Descipción acción realizada"                 OF ::oDbf

      INDEX TO "auditor.cdx"   TAG "uuid" ON "uuid"                     COMMENT "uuid"     NODELETED OF ::oDbf

   END DATABASE ::oDbf

RETURN ( ::oDbf )

//-------------------------------------------------------------------------//

METHOD InformeAuditoria( uuid, cTipDoc ) CLASS TAuditoria

   if Empty( uuid )
      Return nil
   end if

   ::uuidDoc         := uuid
   ::cTipDoc         := cTipDoc

   ::aInforme        := AuditoriaModel():getInfoFromUuid( ::uuidDoc )

   if !hb_isArray( ::aInforme ) .or. len( ::aInforme ) == 0
      MsgStop( "No existe ningun dato para esta clave" )
      Return nil
   end if

   ::cNumeroFromDocument()
   ::cTerceroFromDocument()
   ::cFechaHoraFromDocumento()

   ::lResource()

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD lResource() CLASS TAuditoria

   DEFINE DIALOG ::oDialog RESOURCE ( "auditoria" ) TITLE ( "Informe de auditoría" )

      ::oBrwInforme                       := IXBrowse():New( ::oDialog )

      ::oBrwInforme:bClrSel               := {|| { CLR_BLACK, Rgb( 229, 229, 229 ) } }
      ::oBrwInforme:bClrSelFocus          := {|| { CLR_BLACK, Rgb( 167, 205, 240 ) } }

      ::oBrwInforme:SetArray( ::aInforme, , , .f. )

      ::oBrwInforme:nMarqueeStyle         := 6
      ::oBrwInforme:cName                 := "Informeauditoria"
      ::oBrwInforme:lHScroll              := .f.

      ::oBrwInforme:CreateFromResource( 100 )

      with object ( ::oBrwInforme:AddCol() )
         :cHeader                         := "Fecha"
         :bStrData                        := {|| if( hGet( ::aInforme[ ::oBrwInforme:nArrayAt ], "DFECHA" ) != nil, hGet( ::aInforme[ ::oBrwInforme:nArrayAt ], "DFECHA" ), "" ) }
         :nWidth                          := 80
      end with

      with object ( ::oBrwInforme:AddCol() )
         :cHeader                         := "Hora"
         :bStrData                        := {|| if( hGet( ::aInforme[ ::oBrwInforme:nArrayAt ], "CHORA" ) != nil, Trans( hGet( ::aInforme[ ::oBrwInforme:nArrayAt ], "CHORA" ), "@R 99:99:99" ), "" ) }
         :nWidth                          := 60     
      end with

      with object ( ::oBrwInforme:AddCol() )
         :cHeader                         := "Descripción"
         :bStrData                        := {|| if( hGet( ::aInforme[ ::oBrwInforme:nArrayAt ], "CDESCRIP" ) != nil, hGet( ::aInforme[ ::oBrwInforme:nArrayAt ], "CDESCRIP" ), "" ) }
         :nWidth                          := 550
      end with

      with object ( ::oBrwInforme:AddCol() )
         :cHeader                         := "Usuario"
         :bStrData                        := {|| if( hGet( ::aInforme[ ::oBrwInforme:nArrayAt ], "CUSUARIO" ) != nil, ( hGet( ::aInforme[ ::oBrwInforme:nArrayAt ], "CUSUARIO" ) + " - " + UsuariosModel():getNombre( hGet( ::aInforme[ ::oBrwInforme:nArrayAt ], "CUSUARIO" ) ) ), "" ) }
         :nWidth                          := 250
      end with

      ::oDialog:bStart                    := {|| ::StartResource() }

   ACTIVATE DIALOG ::oDialog CENTER

Return .t.

//---------------------------------------------------------------------------//

METHOD StartResource() CLASS TAuditoria

   local oBoton
   local oGrupo
   local oCarpeta

   if Empty( ::oOfficeBar )

      ::oOfficeBar            := TDotNetBar():New( 0, 0, 1020, 120, ::oDialog, 1 )

      ::oOfficeBar:lPaintAll  := .f.
      ::oOfficeBar:lDisenio   := .f.

      ::oOfficeBar:SetStyle( 1 )

      ::oDialog:oTop             := ::oOfficeBar

      oCarpeta                   := TCarpeta():New( ::oOfficeBar, "Inicio" )

      oGrupo                     := TDotNetGroup():New( oCarpeta, 366, "", .f., , "gc_user_32" )
         oBoton                  := TDotNetButton():New( 320, oGrupo, "gc_document_white_16",         ::cNumeroDocumento,      1, {|| nil }, , , .f., .f., .f. )
         oBoton                  := TDotNetButton():New( 320, oGrupo, "gc_user_16",                   ::cTerceroDocumento,     1, {|| nil }, , , .f., .f., .f. )
         oBoton                  := TDotNetButton():New( 320, oGrupo, "gc_calendar_16",               ::cFechaHoraDocumento,   1, {|| nil }, , , .f., .f., .f. )

      oGrupo                     := TDotNetGroup():New( oCarpeta, 66,  "", .f. )
         oBoton                  := TDotNetButton():New( 60, oGrupo,    "End32",                      "Salida",   1, {|| ::oDialog:End() }, , , .f., .f., .f. )

   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD cNumeroFromDocument() CLASS TAuditoria

   do case
      case ::cTipDoc == TIK_CLI
         ::cNumeroDocumento := "Simplificada: " + TicketsClientesModel():getNumeroFromUuid( ::uuidDoc )

   end case
   

Return ( nil )

//---------------------------------------------------------------------------//

METHOD cTerceroFromDocument() CLASS TAuditoria

   do case
      case ::cTipDoc == TIK_CLI
         ::cTerceroDocumento := "Cliente: " + TicketsClientesModel():getClienteFromUuid( ::uuidDoc )

   end case

Return ( nil )

//---------------------------------------------------------------------------//

METHOD cFechaHoraFromDocumento() CLASS TAuditoria
   
   do case
      case ::cTipDoc == TIK_CLI
         ::cFechaHoraDocumento := "Fecha/hora : " + TicketsClientesModel():getFechaHoraFromUuid( ::uuidDoc )

   end case

Return ( nil )

//---------------------------------------------------------------------------//

METHOD initTemporal() CLASS TAuditoria

   ::aTemporal := {}

Return ( nil )

//---------------------------------------------------------------------------//

METHOD AddTemporal( hHash ) CLASS TAuditoria

   if !Empty( hHash )
      aAdd( ::aTemporal, hHash )
   end if

Return ( nil )

//---------------------------------------------------------------------------//

METHOD SaveTemporal() CLASS TAuditoria

   if len( ::aTemporal ) == 0
      Return ( nil )
   end if

   aEval( ::aTemporal, {|h| AuditoriaModel():addRegister(   hGet( h, "parent_uuid" ),;
                                                            hGet( h, "description" ),;
                                                            hGet( h, "tipodocumento" ) ) } )
   
Return ( nil )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

Function InformeAuditoria( uuid, cTipDoc )

   TAuditoria():InformeAuditoria( uuid, cTipDoc )

Return nil

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS AuditoriaModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getEmpresaTableName( "auditor" )

   METHOD addRegister()

   METHOD getInfoFromUuid( uuid )

END CLASS

//---------------------------------------------------------------------------//

METHOD addRegister( uuidDoc, cDescripcion, cTipDoc ) CLASS AuditoriaModel

   local cStm     := "addRegisterAuditoriaModel"
   local cSql     := ""

   cSql         := "INSERT INTO " + ::getTableName() 
   cSql         += " ( uuid, cUuidDoc, dFecha, cHora, cUsuario, cDescrip ) VALUES "
   cSql         += " ( " + quoted( win_uuidcreatestring() )
   cSql         += ", " + quoted( uuidDoc )
   cSql         += ", " + quoted( Dtoc( GetSysDate() ) )
   cSql         += ", " + quoted( GetSysTime() )
   cSql         += ", " + quoted( Auth():Codigo() )
   cSql         += ", " + quoted( cDescripcion ) + " )"

   ::ExecuteSqlStatement( cSql, @cStm )

Return nil

//---------------------------------------------------------------------------//

METHOD getInfoFromUuid( uuid )

   local cStm        := "getInfoFromUuid"
   local cSql        := ""
   local aInforme    := {}

   cSql              := "SELECT * FROM " + ::getTableName() + " WHERE cUuidDoc = " + quoted( uuid )

   if ::ExecuteSqlStatement( cSql, @cStm )
      aInforme       := DBHScatter( cStm )

      aSort( aInforme, , , {|x, y| ( dtos( hGet( x, "DFECHA" ) ) + hGet( x, "CHORA" ) ) > ( dtos( hGet( y, "DFECHA" ) ) + hGet( y, "CHORA" ) ) }  )

   end if

Return ( aInforme )

//---------------------------------------------------------------------------//