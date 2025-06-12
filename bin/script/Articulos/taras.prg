#include "Factu.ch"

static nView
static dbfTranspor

//---------------------------------------------------------------------------//

function InicioHRB( nVista )

   local cSentence   := ""

   nView       := nVista

   USE ( cPatEmp() + "TRANSPOR.DBF" ) NEW VIA ( cDriver() ) ALIAS ( cCheckArea( "TRANSPOR", @dbfTranspor ) )
   SET ADSINDEX TO ( cPatEmp() + "TRANSPOR.CDX" ) ADDITIVE

   ( dbfTranspor )->( dbGoTop() )

   while !( dbfTranspor )->( Eof() )

      MsgWait( ( dbfTranspor )->cNomTrn + "--" + Str( ( dbfTranspor )->nKgsTrn ), "", 0.1 )

      cSentence     := "UPDATE transportistas SET tara=" + AllTrim( Str( ( dbfTranspor )->nKgsTrn ) ) + " WHERE uuid = " + quoted( ( dbfTranspor )->uuid )

      getSQLDatabase():Query( cSentence )

      ( dbfTranspor )->( dbSkip() )

   end if

   if( !Empty( dbfTranspor ), ( dbfTranspor )->( dbCloseArea() ), )

return .t.

//---------------------------------------------------------------------------//