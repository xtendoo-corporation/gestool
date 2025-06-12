#include "Factu.ch"

static nView
static dbfTmpObr

//---------------------------------------------------------------------------//

function InicioHRB( nVista )

   nView       := nVista

   Msginfo( "Voy a crear la temporal" )   

   Creotemporal()

   Msginfo( "Paso los registros válidos" )
   pasoRegistros()

   CierroTemporal()

   Msginfo( "Proceso realizado con éxito" )

return .t.

//---------------------------------------------------------------------------//

Static Function CreoTemporal()

   local cTmpObr           := cGetNewFileName( "c:\ficheros\TmpObr" )

   if file( cTmpObr + ".dbf" ) .or. file( cTmpObr + ".cdx" )
      dbfErase( cTmpObr )
   end if

   dbCreate( cTmpObr, aSqlStruct( aItmObr() ), cLocalDriver() )
   dbUseArea( .t., cLocalDriver(), cTmpObr, cCheckArea( "TmpObr", @dbfTmpObr ), .f. )

   ( dbfTmpObr )->( ordCondSet( "!Deleted()", {||!Deleted()}  ) )
   ( dbfTmpObr )->( OrdCreate( cTmpObr, "cCliObr", "CCODCLI + CCODOBR", {|| Field->CCODCLI + Field->CCODOBR } ) )

   ( dbfTmpObr )->( OrdSetFocus( "cCliObr" ) )

Return .t.

//---------------------------------------------------------------------------//

Static Function CierroTemporal()

   if !Empty( dbfTmpObr ) .and. ( dbfTmpObr )->( Used() )
      ( dbfTmpObr )->( dbCloseArea() )
   end if

Return .t.

//---------------------------------------------------------------------------//

Static Function pasoRegistros()

   local nScan
   local n := 1

   ( D():ClientesDirecciones( nView ) )->( dbGoTop() )

   while !( D():ClientesDirecciones( nView ) )->( eof() )

      MsgWait( Str( n ) + Space( 1 ) + ( D():ClientesDirecciones( nView ) )->cCodCli + ( D():ClientesDirecciones( nView ) )->cCodObr, "Tit", 0,1 )

      if !( dbfTmpObr )->( dbSeek( ( D():ClientesDirecciones( nView ) )->CCODCLI + ( D():ClientesDirecciones( nView ) )->CCODOBR ) )
          dbPass( D():ClientesDirecciones( nView ), dbfTmpObr, .t. )
      end if

      n++

      ( D():ClientesDirecciones( nView ) )->( dbSkip() )

   end while

Return .t.

//---------------------------------------------------------------------------//