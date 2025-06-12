#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS AlmacenesModel FROM ADSBaseModel

   METHOD getTableName()                           INLINE ::getEmpresaTableName( "Almacen" )

   METHOD exist()

   METHOD aAlmacenes()

   METHOD getNombre( idAlmacen )                   INLINE ( ::getField( "cNomAlm", "cCodAlm", idAlmacen ) )

   METHOD aNombres()
   METHOD aNombresSeleccionables()                 INLINE ( ains( ::aNombres(), 1, "", .t. ) )

   METHOD getUuidFromNombre( cNombre )             INLINE ( ::getField( "Uuid", "cNomAlm", cNombre ) )
   METHOD getNombreFromUuid( cUuid )               INLINE ( ::getField( "cNomAlm", "Uuid", cUuid ) )

   METHOD getUuidFromNombreAndEmpresa( cNombre, cCodEmpresa )
   METHOD getNombreFromUuidAndEmpresa( cUuid, cCodEmpresa )

   METHOD getCodigoFromNombre( cNombre )           INLINE ( ::getField( "cCodAlm", "cNomAlm", cNombre ) )
   METHOD getNombreFromCodigo( cCodigo )           INLINE ( ::getField( "cNomAlm", "cCodAlm", cCodigo ) )

   METHOD aNombresFromEmpresa( cCodEmpresa )

END CLASS

//---------------------------------------------------------------------------//

METHOD exist( cCodigoAlmacen )

   local cStm
   local cSql  := "SELECT cNomAlm "                               + ;
                     "FROM " + ::getTableName() + " "             + ;
                     "WHERE cCodAlm = " + quoted( cCodigoAlmacen ) 

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( lastrec() ) > 0 )
   end if 

RETURN ( .f. )

//---------------------------------------------------------------------------//

METHOD aNombres()

   local cStm
   local aAlm  := {}
   local cSql  := "SELECT * FROM " + ::getTableName() 

   if !::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( aAlm )
   endif 

   while !( cStm )->( eof() ) 
      aadd( aAlm, alltrim( ( cStm )->cNomAlm ) )
      ( cStm )->( dbskip() )
   end while

RETURN ( aAlm )

//---------------------------------------------------------------------------//

METHOD aAlmacenes()

   local cStm
   local aAlm  := {}
   local cSql  := "SELECT * FROM " + ::getTableName() 

   if !::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( aAlm )
   endif 

   while !( cStm )->( eof() ) 
      aadd( aAlm, { "cCodAlm" => ( cStm )->cCodAlm, "cNomAlm" => ( cStm )->cNomAlm } )
      ( cStm )->( dbskip() )
   end while

RETURN ( aAlm )

//---------------------------------------------------------------------------//

METHOD aNombresFromEmpresa( cCodEmpresa )

   local cStm
   local aAlm           := {}
   local cSql

   DEFAULT cCodEmpresa  := cCodEmp()

   cSql                 := "SELECT * FROM " + ::getEmpresaTableNameFromEmpresa( "Almacen", cCodEmpresa )

   if !::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( aAlm )
   endif 

   while !( cStm )->( eof() ) 
      aadd( aAlm, alltrim( ( cStm )->cNomAlm ) )
      ( cStm )->( dbskip() )
   end while

RETURN ( aAlm )

//---------------------------------------------------------------------------//

METHOD getUuidFromNombreAndEmpresa( cNombre, cCodEmpresa )

   local cSql
   local cStm

   cSql                 := "SELECT Uuid FROM "
   cSql                 += ::getEmpresaTableNameFromEmpresa( "Almacen", cCodEmpresa ) + space( 1 )
   cSql                 += "WHERE cNomAlm=" + quoted( cNombre )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( fieldget( fieldpos( "Uuid" ) ) ) )
   endif

RETURN ( space( 1 ) )

//---------------------------------------------------------------------------//
   
METHOD getNombreFromUuidAndEmpresa( cUuid, cCodEmpresa )

   local cSql
   local cStm
   
   cSql                 := "SELECT cNomAlm FROM "
   cSql                 += ::getEmpresaTableNameFromEmpresa( "Almacen", cCodEmpresa ) + space( 1 )
   cSql                 += "WHERE Uuid=" + quoted( cUuid )

   if ::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( ( cStm )->( fieldget( fieldpos( "cNomAlm" ) ) ) )
   endif

RETURN ( space( 1 ) )

//---------------------------------------------------------------------------//