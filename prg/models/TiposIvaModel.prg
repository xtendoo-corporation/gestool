#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS TiposIvaModel FROM ADSBaseModel

   METHOD getTableName()                  INLINE ::getDatosTableName( "TIva" ) 

   METHOD getNombre( cCodigo )            INLINE ( ::getField( 'DescIva', 'Tipo', cCodigo ) )

   METHOD getIva( cCodigo )               INLINE ( ::getField( 'TpIva', 'Tipo', cCodigo ) )

   METHOD getRE( cCodigo )                INLINE ( ::getField( 'nRecEq', 'Tipo', cCodigo ) )

   METHOD getTipoIgic( nIva )             INLINE ( ::getField( 'lIgic', 'TpIva', nIva ) )

   METHOD exist( cCodigo )

   METHOD InsertTiposIva( hTipo )

END CLASS

//---------------------------------------------------------------------------//

METHOD exist( cCodigo )

   local cStm
   local cSql  := "SELECT Tipo "                                  + ;
                     "FROM " + ::getTableName() + " "             + ;
                     "WHERE TpIva = " + quoted( cCodigo ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD InsertTiposIva( hTipo )

   local cArea
   local cSql

   if !::exist( hGet( hTipo, "Porcentaje" ) )

      cSql         := "INSERT INTO " + ::getTableName() 
      cSql         += " ( Tipo, DescIva, TpIva, nRecEq ) VALUES "
      cSql         += " ( " + quoted( hGet( hTipo, "Codigo" ) )
      cSql         += ", " + quoted( hGet( hTipo, "Descripcion" ) )
      cSql         += ", " + Str( hGet( hTipo, "Porcentaje" ) )
      cSql         += ", " + Str( hGet( hTipo, "Recargo" ) )
      cSql         += " )"

      ::ExecuteSqlStatement( cSql, @cArea )

   end if

RETURN ( .f. )

//---------------------------------------------------------------------------//