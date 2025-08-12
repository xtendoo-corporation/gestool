#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS CajasModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getDatosTableName( "Cajas" )

   METHOD aNombres()
   METHOD aNombresSeleccionables()           INLINE ( ains( ::aNombres(), 1, "", .t. ) )

   METHOD getUuidFromNombre( cNombre )       INLINE ( ::getField( "Uuid", "cNomCaj", cNombre ) )
   METHOD getNombreFromUuid( cUuid )         INLINE ( ::getField( "cNomCaj", "Uuid", cUuid ) ) 
   METHOD getCajonUuidFromCodigo( cCodigo )  INLINE ( ::getField( "cCajon", "cCodCaj", cCodigo ) ) 

END CLASS

//---------------------------------------------------------------------------//

METHOD aNombres()

   local cStm
   local aEmp  := {}
   local cSql  := "SELECT * FROM " + ::getTableName() 

   if !::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( aEmp )
   endif 

   while !( cStm )->( eof() ) 
      aadd( aEmp, alltrim( ( cStm )->cNomCaj ) )
      ( cStm )->( dbskip() )
   end while

RETURN ( aEmp )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS CajasLineasModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getDatosTableName( "CajL" )

   METHOD getImpresoraComanda()
   
   METHOD getFormatoComanda()

   METHOD getFormatoAnulacion()

END CLASS

//---------------------------------------------------------------------------//

METHOD getImpresoraComanda( cUuidSalon, cTipImp ) CLASS CajasLineasModel

   local cImpresora  := ""
   local cSql        := ""
   local dbfSql

   cSql              := "SELECT cNomPrn FROM " + ::getTableName()    + ;
                        " WHERE cParUuid = " + quoted( cUuidSalon )  + ;
                        " AND cTipImp = " + quoted( cTipImp )

   if ::ExecuteSqlStatement( cSql, @dbfSql )
      cImpresora     := AllTrim( ( dbfSql )->cNomPrn )
   end if

Return ( cImpresora )

//---------------------------------------------------------------------------//
   
METHOD getFormatoComanda( cUuidSalon, cTipImp ) CLASS CajasLineasModel

   local cFormato    := ""
   local cSql        := ""
   local dbfSql

   cSql              := "SELECT cPrnCom FROM " + ::getTableName()    + ;
                        " WHERE cParUuid = " + quoted( cUuidSalon )  + ;
                        " AND cTipImp = " + quoted( cTipImp )

   if ::ExecuteSqlStatement( cSql, @dbfSql )
      cFormato     := AllTrim( ( dbfSql )->cPrnCom )
   end if

Return ( cFormato )

//---------------------------------------------------------------------------//

METHOD getFormatoAnulacion( cUuidSalon, cTipImp ) CLASS CajasLineasModel

   local cFormato    := ""
   local cSql        := ""
   local dbfSql

   cSql              := "SELECT cPrnAnu FROM " + ::getTableName()    + ;
                        " WHERE cParUuid = " + quoted( cUuidSalon )  + ;
                        " AND cTipImp = " + quoted( cTipImp )

   if ::ExecuteSqlStatement( cSql, @dbfSql )
      cFormato     := AllTrim( ( dbfSql )->cPrnAnu )
   end if

Return ( cFormato )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

CLASS CajonesModel FROM ADSBaseModel

   METHOD getTableName()                     INLINE ::getDatosTableName( "CajPorta" )

END CLASS

//---------------------------------------------------------------------------// 