#include "FiveWin.Ch"
#include "Factu.ch" 

//---------------------------------------------------------------------------//

CLASS DelegacionesModel FROM ADSBaseModel

   METHOD getTableName()           INLINE ::getDatosTableName( "Delega" )

   METHOD UpdateDelegacionCodigoEmpresa()

   METHOD DeleteDelegacionesEmpresa( cCodigoEmpresa )

   METHOD arrayDelegaciones( cCodigoEmpresa )

   METHOD aNombres()
   METHOD aNombresSeleccionables()           INLINE ( ains( ::aNombres(), 1, "", .t. ) )

   METHOD getUuidFromNombre( cNombre )       INLINE ( ::getField( "Uuid", "cNomDlg", cNombre ) )
   METHOD getNombreFromUuid( cUuid )         INLINE ( ::getField( "cNomDlg", "Uuid", cUuid ) )

   METHOD getCodigoFromNombre( cNombre )     INLINE ( ::getField( "cCodDlg", "cNomDlg", cNombre ) )
   METHOD getNombreFromCodigo( cCodigo )     INLINE ( ::getField( "cNomDlg", "cCodDlg", cCodigo ) )

   METHOD getNombre( cCodigo )

END CLASS

//---------------------------------------------------------------------------//

METHOD UpdateDelegacionCodigoEmpresa()

   local cStm
   local cSql  := "UPDATE " + ::getTableName() + " " + ;
                     "SET cCodEmp = CONCAT( '00', TRIM( cCodEmp ) ) WHERE ( LENGTH( cCodEmp ) < 4 )"

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD DeleteDelegacionesEmpresa( cCodigoEmpresa )

   local cStm
   local cSql  := "DELETE FROM " + ::getTableName() + " " + ;
                     "WHERE cCodEmp = " + quoted( cCodigoEmpresa )

Return ( ::ExecuteSqlStatement( cSql, @cStm ) )

//---------------------------------------------------------------------------//

METHOD arrayDelegaciones( cCodigoEmpresa )

   local cStm
   local aDlg  := {}
   local cSql  := "SELECT cCodDlg FROM " + ::getTableName() + " "
   cSql        +=    "WHERE cCodEmp = " + quoted( cCodigoEmpresa )

   if ::ExecuteSqlStatement( cSql, @cStm )
      ( cStm )->( dbgotop() )
      while !( cStm )->( eof() ) 
         aadd( aDlg, ( cStm )->cCodDlg )
         ( cStm )->( dbskip() )
      end while
   end if 

Return ( aDlg )

//---------------------------------------------------------------------------//

METHOD aNombres( cCodigoEmpresa )

   local cStm
   local cSql  
   local aDlg              := {}

   DEFAULT cCodigoEmpresa  := cCodEmp()

   cSql                    := "SELECT * FROM " + ::getTableName() + " " 
   cSql                    +=    "WHERE cCodEmp = " + quoted( cCodigoEmpresa )

   if !::ExecuteSqlStatement( cSql, @cStm )
      RETURN ( aDlg )
   endif 

   while !( cStm )->( eof() ) 
      aadd( aDlg, alltrim( ( cStm )->cNomDlg ) )
      ( cStm )->( dbskip() )
   end while

RETURN ( aDlg )

//---------------------------------------------------------------------------//

METHOD getNombre( cCodigo )

   local cStm
   local cSql  
   local cNombre           := ""

   cSql                    := "SELECT * FROM " + ::getTableName() + " " 
   cSql                    +=    "WHERE cCodDlg = " + quoted( cCodigo ) +  " AND cCodEmp = " + quoted( cCodEmp() )

   if ::ExecuteSqlStatement( cSql, @cStm )
      ( cStm )->( dbGoTop() )
      cNombre  := ( cStm )->cNomDlg
   end if 

RETURN ( cNombre )

//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//

function cNameDelegacion( cCodigo )

Return ( DelegacionesModel():getNombre( cCodigo ) )

//---------------------------------------------------------------------------//