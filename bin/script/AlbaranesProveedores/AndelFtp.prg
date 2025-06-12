#include "FiveWin.Ch"
#include "Struct.ch"
#include "Factu.ch" 
#include "Ini.ch"
#include "MesDbf.ch"
#include "Report.ch"
#include "Print.ch"

//----------------------------------------------------------------------------//

Function AndelFtpConexion()
   
   AndelFtp():New()

RETURN nil

//----------------------------------------------------------------------------//
   
CLASS AndelFtp

   DATA  cFtpSite
   DATA  cUserName
   DATA  cPassword
   DATA  lPassive

   DATA  oFtp

   DATA  oAlbPrvT
   DATA  oFacPrvT

   Method New()
   METHOD Run()
   METHOD ftpConexion()
   METHOD closeConexion()

   METHOD ftpGetFiles()
   
   METHOD fileNotProccess( cFile )
   METHOD fileDownload( cFile )

   METHOD fileAlbaran( cFile )
   METHOD fileFactura( cFile )

END CLASS

//----------------------------------------------------------------------------//

METHOD New()

   ::cFtpSite              := "pedidos.andelautomocion.com"
   ::cUserName             := "andelftp"
   ::cPassword             := "ftp123"
   ::lPassive              := .t.

   msgRun( "Conectando con el sito ftp:" + ::cFtpSite, "Espere por favor...", {|| ::Run() } )

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD Run()

   DATABASE NEW ::oAlbPrvT PATH ( cPatEmp() ) FILE "AlbProvT.DBF" VIA ( cDriver() ) SHARED INDEX "AlbProvT.Cdx"
   ::oAlbPrvT:ordsetfocus( "cSuAlb" )

   DATABASE NEW ::oFacPrvT PATH ( cPatEmp() ) FILE "FacPrvT.DBF" VIA ( cDriver() ) SHARED INDEX "FacPrvT.Cdx"
   ::oFacPrvT:ordsetfocus( "cSuPed" )

   if ::ftpConexion()
      ::ftpGetFiles()
      ::closeConexion()
   else 
      msgInfo( "Error al conectar" )
   end if 

   ::oAlbPrvT:End()
   ::oFacPrvT:End()

RETURN ( Self )

//----------------------------------------------------------------------------//

METHOD ftpConexion()

   ::oFtp               := TFTPCurl():New( ::cUserName, ::cPassword, ::cFtpSite, 21 )
   ::oFtp:setPassive( ::lPassive )

   if !::oFtp:CreateConexion()
      msgStop( "Imposible conectar con el sitio ftp " + ::cFtpSite, "Error" )
      Return ( .f. )
   end if

RETURN ( .t. )

//---------------------------------------------------------------------------//

METHOD closeConexion() 

   if !Empty( ::oFtp )
      ::oFtp:EndConexion()
   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD ftpGetFiles()

   local cFile
   local aFiles            := {}

   if ::oFtp:testConexion()

      aFiles                  := ::oFTP:listFiles()
   
      for each cFile in aFiles 
         if SubStr( cFile, 1, 9 ) == "430000093"
            if ::fileNotProccess( cFile )
               ::fileDownload( cFile )
            end if 
         end if
      next

   end if

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD fileNotProccess( cFile )

   local cFileDocument  

   if ( "Albaran" $ cFile )
      RETURN ( !::oAlbPrvT:Seek( ::fileAlbaran( cFile ) ) )      
   end if 

   if ( "Factura" $ cFile )
      RETURN ( !::oFacPrvT:Seek( ::fileFactura( cFile ) ) )      
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD fileDownload( cFile )

   msgRun( "Descargando fichero " + cFile, "Espere por favor...", {|| ::oFtp:downLoadFile( cFile, "c:\ImportacionAlbaranes\" + cFile ) } )

RETURN ( Self )

//---------------------------------------------------------------------------//

METHOD fileAlbaran( cFile )

/*
430000093-AlbaranIS0080133.txt -> I/00080133/IS
430000093-Albaran3A0073313
*/
   local cSerie   := SubStr( cFile, 19, 1 ) 
   local nNumero  := "0" + SubStr( cFile, 20, 7 ) 
   local cSufijo  := SubStr( cFile, 18, 2 ) 

RETURN ( cSerie + nNumero + cSufijo )

//---------------------------------------------------------------------------//

METHOD fileFactura( cFile )

/*
430000093-FacturaFS1705028.txt -> FS1705028
*/

   local cPrefijo    := substr( cFile, 18, 2 ) 
   local cNumero     := substr( cFile, 20, at( ".", cFile ) - 20 ) 

   cNumero           := rjust( cNumero, '0', 8 )

RETURN ( cPrefijo + cNumero )

//---------------------------------------------------------------------------//
