#include "HbXml.ch"
#include "TDbfDbf.ch"
#include "fivewin.ch"

//---------------------------------------------------------------------------//

static dbfArticulo     

static hFile
static cFile  
static oText    

//---------------------------------------------------------------------------//

Function Luncher()

   local oDlg, oMeter, oBtn, oFont
   local nVal     := 0
   local cMsg     := "Proceso de exportacion a fichero"
   local cTitle   := "Espere por favor..."

   cFile          := fullCurDir() + Dtos( date() ) + Strtran( Time(), ":", "" ) + ".txt"

   DEFINE FONT oFont NAME GetSysFont() SIZE 0, -8

   DEFINE DIALOG oDlg FROM 5, 5 TO 13, 45 TITLE cTitle FONT oFont

   @ 0.2, 0.5  SAY oText VAR cMsg SIZE 130, 20 OF oDlg

   @ 2.2, 0.5  METER oMeter VAR nVal TOTAL 10 SIZE 150, 2 OF oDlg

   oDlg:bStart = { || ExportaStock( oMeter, oDlg ) }

   ACTIVATE DIALOG oDlg CENTERED

   oFont:End()

   ferase( cFile )

Return nil

//---------------------------------------------------------------------------//

Function ExportaStock( oMeter, oDlg )

   	local oInt
   	local oFtp
   	local nTotStockAct  

   	if lOpenFiles()

      	if File( cFile )
         	fErase( cFile )
      	end if 

      	hFile       := fCreate( cFile )

      	( dbfArticulo )->( dbGoTop() )

      	if !empty(oMeter)
         	oMeter:setTotal( ( dbfArticulo )->( ordkeyCount() ) )
      	end if

      	while !( dbfArticulo )->( eof() )

         	if ( dbfArticulo )->lPubInt

	            nTotStockAct   := StocksModel():nStockArticulo( ( dbfArticulo )->Codigo, "006             " )

	            oText:setText( alltrim( ( dbfArticulo )->Codigo ) + space(1) + alltrim( ( dbfArticulo )->Nombre ) )

	            fWrite( hFile, AllTrim( ( dbfArticulo )->Codigo ) + ";" + ;
	                           AllTrim( Trans( nTotStockAct, "@E 999,999,999" ) ) + ";" + ;
	                           AllTrim( Trans( ( dbfArticulo )->pVenta1, "@E 999,999,999.999" ) ) + ";" + ;
	                           AllTrim( Trans( ( dbfArticulo )->pCosto, "@E 999,999,999.999" ) ) + ;
	                           Chr( 13 ) + Chr( 10 ) )

         	end if

         	( dbfArticulo )->( dbSkip() )

         	if !empty(oMeter)
	            oMeter:set( ( dbfArticulo )->( ordkeyno() ) )
         	end if

      	end while

      	fClose( hFile )

      	CloseFiles()

      	// Subimos el fichero al ftp---------------------------------------------

      	oText:setText( "Subimos el fichero resultante al Ftp" )

      	envioFtp()

       	oText:setText( "Fichero subido" )

   	end if 

   	oDlg:End()

Return ( nil )

//---------------------------------------------------------------------------//

STATIC FUNCTION envioFtp()

    local oFtp
    local ftpSit            := "ftp.arguelles360.com"
    local ftpDir            := cNoPathLeft( Rtrim( ftpSit ) )
    local nbrUsr            := "stock@arguelles360.com"
    local accUsr            := "7pePMlfxcLXBbS83"
    local pasInt            := .f.
    local nPuerto           := 21
    local cCarpeta          := ""

    if !file( cFile )
        Return ( Self )
    end if

    oFtp               := TFtpCurl():New( nbrUsr, accUsr, ftpSit, nPuerto )
    oFtp:setPassive( pasInt )

    if oFtp:CreateConexion()

        oText:setText( "Conexión creada con el ftp." )

        if isFalse( oFtp:createFile( cFile, cCarpeta ) )
            oText:setText( "Error subiendo fichero " + cFile )
        else
            oText:setText( "Subido correctamente:  " + cFile )
        end if

        oFtp:EndConexion()

        oText:setText( "Conexión cerrada con el ftp." )

    else

        msgStop( "Imposible conectar al sitio ftp " + oFtp:cServer )

    end if

Return ( nil )

//---------------------------------------------------------------------------//

STATIC FUNCTION lOpenFiles( lExt, cPath )

   local oError
   local oBlock

   CursorWait()

   oBlock         := ErrorBlock( { | oError | ApoloBreak( oError ) } )
   BEGIN SEQUENCE

      oMsgText( "Abriendo ficheros artículos" )

      lOpenFiles  := .t.

      dbUseArea( .T., ( cDriver() ), ( cPatEmp() + "ARTICULO.DBF" ), ( cCheckArea( "ARTICULO", @dbfArticulo ) ), if(.T. .OR. .F., !.F., NIL), .F.,, )
      if !lAIS() ; ordListAdd( ( cPatEmp() + "ARTICULO.CDX" ) ) ; else ; ordSetFocus( 1 ) ; end

   RECOVER USING oError

      lOpenFiles           := .f.

      msgStop( ErrorMessage( oError ), "Imposible abrir las bases de datos de artículos" )

   end

   ErrorBlock( oBlock )

   if !lOpenFiles
      CloseFiles()
   end

   CursorWE()

RETURN ( lOpenFiles )

//---------------------------------------------------------------------------//

STATIC FUNCTION CloseFiles( )

   if dbfArticulo <> nil
      ( dbfArticulo )->( dbCloseArea() )
   end

   dbfArticulo    := nil

   lOpenFiles     := .F.

RETURN ( .T. )

//---------------------------------------------------------------------------//